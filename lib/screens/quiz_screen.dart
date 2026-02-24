import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../widgets/loading_widget.dart';

class QuizScreen extends StatefulWidget {
  final List<Quiz> quizzes;
  final int nodeId;

  const QuizScreen({super.key, required this.quizzes, required this.nodeId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _isSubmitting = false;
  String? _feedbackMessage;
  bool? _isCorrect;
  String? _hint;

  Quiz get _currentQuiz => widget.quizzes[_currentIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          'Soal ${_currentIndex + 1} / ${widget.quizzes.length}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.quizzes.length,
              backgroundColor: Colors.white24,
              color: const Color(0xFF6C63FF),
            ),
            const SizedBox(height: 24),

            // Soal
            Text(
              _currentQuiz.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Pilihan jawaban atau input teks
            if (_currentQuiz.type == 'multiple_choice')
              ..._buildMultipleChoice()
            else
              _buildFillBlank(),

            const SizedBox(height: 16),

            // Feedback benar/salah
            if (_feedbackMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isCorrect == true
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCorrect == true ? Colors.green : Colors.red,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _feedbackMessage!,
                      style: TextStyle(
                        color: _isCorrect == true ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_hint != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '💡 Hint: $_hint',
                        style: const TextStyle(color: Colors.amber),
                      ),
                    ],
                  ],
                ),
              ),

            const Spacer(),

            // Tombol submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting || _selectedAnswer == null
                    ? null
                    : _submitAnswer,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Jawab',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMultipleChoice() {
    return (_currentQuiz.options ?? []).map((option) {
      final isSelected = _selectedAnswer == option;
      return GestureDetector(
        onTap: _isCorrect == true
            ? null
            : () => setState(() => _selectedAnswer = option),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6C63FF)
                : const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF6C63FF) : Colors.white24,
            ),
          ),
          child: Text(option, style: const TextStyle(color: Colors.white)),
        ),
      );
    }).toList();
  }

  Widget _buildFillBlank() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      onChanged: (val) => setState(() => _selectedAnswer = val),
      decoration: InputDecoration(
        hintText: 'Ketik jawaban kamu di sini...',
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF16213E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswer == null) return;

    setState(() {
      _isSubmitting = true;
      _feedbackMessage = null;
    });

    final result = await QuizService().checkAnswer(
      quizId: _currentQuiz.id,
      answer: _selectedAnswer!,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['correct'] == true) {
      setState(() {
        _isCorrect = true;
        _feedbackMessage = '🎉 Jawaban Benar!';
      });

      // Kalau node selesai
      if (result['node_completed'] == true) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) _showNodeCompletedDialog(result);
        return;
      }

      // Kalau masih ada soal berikutnya
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted && _currentIndex < widget.quizzes.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _feedbackMessage = null;
          _isCorrect = null;
        });
      }
    } else {
      setState(() {
        _isCorrect = false;
        _feedbackMessage = result['message'] ?? 'Jawaban salah, coba lagi!';
        _hint = result['hint'];
        _selectedAnswer = null; // Reset pilihan
      });
    }
  }

  void _showNodeCompletedDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
            const SizedBox(height: 12),
            const Text(
              'Level Selesai! 🎉',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '+${result['exp_gained'] ?? 100} EXP',
              style: const TextStyle(color: Colors.green, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Total: ${result['total_exp'] ?? 0} EXP',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke materi
                Navigator.pop(context); // Kembali ke roadmap
              },
              child: const Text(
                'Kembali ke Peta',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
