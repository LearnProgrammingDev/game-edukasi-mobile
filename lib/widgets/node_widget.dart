import 'package:flutter/material.dart';
import '../models/node.dart';

class NodeWidget extends StatelessWidget {
  final Node node;
  final VoidCallback onTap;

  const NodeWidget({super.key, required this.node, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: _getColor(),
          shape: node.type == 'percabangan'
              ? BoxShape.rectangle
              : BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _getColor().withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(), color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                node.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    if (node.isLocked) return Colors.grey;
    if (node.isCompleted) return const Color(0xFF4CAF50); // hijau
    // unlocked
    return node.type == 'kuis'
        ? const Color(0xFFFF9800) // orange untuk kuis
        : const Color(0xFF6C63FF); // ungu untuk materi
  }

  IconData _getIcon() {
    if (node.isLocked) return Icons.lock;
    if (node.isCompleted) return Icons.check_circle;
    if (node.type == 'kuis') return Icons.quiz;
    if (node.type == 'percabangan') return Icons.call_split;
    return Icons.book;
  }
}
