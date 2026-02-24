import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/node.dart';
import '../services/node_service.dart';
import '../widgets/loading_widget.dart';
import 'quiz_screen.dart';

class MateriScreen extends StatefulWidget {
  final int nodeId;
  const MateriScreen({super.key, required this.nodeId});

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _MateriScreenState extends State<MateriScreen> {
  Node? _node;
  bool _isLoading = true;
  bool _isCompleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNode();
  }

  Future<void> _loadNode() async {
    final result = await NodeService().getNodeDetail(widget.nodeId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _node = result['node'];
      } else {
        _error = result['message'];
      }
    });
  }

  // =============================================
  // SELESAI MEMBACA → kirim ke Laravel
  // =============================================
  Future<void> _completeMateri() async {
    setState(() => _isCompleting = true);

    final result = await NodeService().completeMateri(widget.nodeId);

    if (!mounted) return;
    setState(() => _isCompleting = false);

    if (result['success'] == true) {
      final expGained = result['exp_gained'] ?? 0;
      final totalExp = result['total_exp'] ?? 0;
      final alreadyDone = result['already_done'] ?? false;

      // Tampilkan dialog sukses
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                alreadyDone ? Icons.check_circle : Icons.emoji_events,
                color: alreadyDone ? Colors.green : Colors.amber,
                size: 60,
              ),
              const SizedBox(height: 12),
              Text(
                alreadyDone ? 'Sudah Selesai!' : 'Materi Selesai! 🎉',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (!alreadyDone) ...[
                Text(
                  '+$expGained EXP',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total EXP: $totalExp',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
              const SizedBox(height: 8),
              const Text(
                'Node berikutnya sudah terbuka!',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
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
                  Navigator.pop(context); // Kembali ke roadmap (auto refresh)
                },
                child: const Text(
                  'Lihat Peta 🗺️',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Terjadi kesalahan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          _node?.title ?? 'Materi',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        // Badge EXP reward di kanan atas
        actions: [
          if (_node != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber),
              ),
              child: Text(
                '+${_node!.expReward} EXP',
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.white)),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Badge status sudah selesai
        if (_node!.isCompleted)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.green.withOpacity(0.15),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 6),
                Text(
                  'Kamu sudah menyelesaikan materi ini',
                  style: TextStyle(color: Colors.green, fontSize: 13),
                ),
              ],
            ),
          ),

        // Area konten markdown
        Expanded(
          child: Markdown(
            data: _node!.content ?? '_Tidak ada konten_',
            styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              h2: const TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              h3: const TextStyle(color: Colors.white70, fontSize: 17),
              p: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.7,
              ),
              code: const TextStyle(
                color: Colors.greenAccent,
                backgroundColor: Color(0xFF0F3460),
                fontSize: 13,
              ),
              codeblockDecoration: BoxDecoration(
                color: const Color(0xFF0F3460),
                borderRadius: BorderRadius.circular(10),
              ),
              tableHead: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              tableBody: const TextStyle(color: Colors.white70),
              blockquote: const TextStyle(color: Colors.amber, fontSize: 14),
              blockquoteDecoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.amber, width: 4)),
              ),
            ),
          ),
        ),

        // Tombol bawah
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Tombol Mulai Tantangan (jika ada kuis)
              if (_node!.quizzes.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text(
                      'Mulai Tantangan! ⚔️',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            quizzes: _node!.quizzes,
                            nodeId: _node!.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Tombol Selesai Membaca (selalu muncul untuk node materi)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _node!.isCompleted
                        ? Colors.green
                        : const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    _node!.isCompleted ? Icons.check : Icons.done_all,
                    color: Colors.white,
                  ),
                  label: _isCompleting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _node!.isCompleted
                              ? '✅ Sudah Selesai'
                              : 'Selesai Membaca',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  // Kalau sudah completed, tombol tidak bisa diklik lagi
                  onPressed: _node!.isCompleted || _isCompleting
                      ? null
                      : _completeMateri,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
