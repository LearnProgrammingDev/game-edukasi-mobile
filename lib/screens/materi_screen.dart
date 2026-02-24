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
        // Area scroll untuk materi markdown
        Expanded(
          child: Markdown(
            data: _node!.content ?? '_Tidak ada konten_',
            styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              h2: const TextStyle(color: Colors.white70, fontSize: 20),
              p: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.6,
              ),
              code: const TextStyle(
                color: Colors.greenAccent,
                backgroundColor: Color(0xFF0F3460),
              ),
              codeblockDecoration: BoxDecoration(
                color: const Color(0xFF0F3460),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // Tombol mulai tantangan (hanya muncul jika ada kuis)
        if (_node!.quizzes.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text(
                'Mulai Tantangan!',
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
                    builder: (_) =>
                        QuizScreen(quizzes: _node!.quizzes, nodeId: _node!.id),
                  ),
                );
              },
            ),
          ),

        // Kalau tidak ada kuis, tampilkan tombol kembali
        if (_node!.quizzes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Kembali ke Roadmap',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
