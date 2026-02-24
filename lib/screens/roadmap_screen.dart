import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/node.dart';
import '../services/node_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/node_widget.dart';
import '../widgets/loading_widget.dart';
import 'materi_screen.dart';
import 'login_screen.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  List<Node> _nodes = [];
  List<NodeConnection> _connections = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoadmap();
  }

  Future<void> _loadRoadmap() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await NodeService().getNodes();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _nodes = result['nodes'];
        _connections = result['connections'];
      } else {
        _error = result['message'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Laravel Quest',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (user != null)
              Text(
                '⚡ ${user.expPoints} EXP',
                style: const TextStyle(color: Colors.amber, fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRoadmap,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Memuat peta...')
          : _error != null
          ? _buildError()
          : _buildRoadmap(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white54, size: 60),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRoadmap,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmap() {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(300),
      minScale: 0.3,
      maxScale: 2.0,
      child: SizedBox(
        width: 600,
        height: 900,
        child: Stack(
          children: [
            // Layer 1: Gambar garis koneksi antar node
            CustomPaint(
              size: const Size(600, 900),
              painter: _ConnectionPainter(_nodes, _connections),
            ),
            // Layer 2: Gambar setiap node
            ..._nodes.map(
              (node) => Positioned(
                left: node.xPosition.toDouble(),
                top: node.yPosition.toDouble(),
                child: NodeWidget(
                  node: node,
                  onTap: () => _handleNodeTap(node),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNodeTap(Node node) {
    if (node.isLocked) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock, color: Colors.orange),
              SizedBox(width: 8),
              Text('Terkunci!'),
            ],
          ),
          content: const Text('Selesaikan level sebelumnya dulu ya!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MateriScreen(nodeId: node.id)),
    ).then((_) => _loadRoadmap()); // Refresh roadmap setelah kembali
  }
}

// Painter untuk menggambar garis antar node
class _ConnectionPainter extends CustomPainter {
  final List<Node> nodes;
  final List<NodeConnection> connections;

  _ConnectionPainter(this.nodes, this.connections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final conn in connections) {
      final source = nodes.firstWhere(
        (n) => n.id == conn.sourceNodeId,
        orElse: () => nodes.first,
      );
      final target = nodes.firstWhere(
        (n) => n.id == conn.targetNodeId,
        orElse: () => nodes.first,
      );

      // Gambar dari tengah node source ke tengah node target
      canvas.drawLine(
        Offset(source.xPosition + 50, source.yPosition + 50),
        Offset(target.xPosition + 50, target.yPosition + 50),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
