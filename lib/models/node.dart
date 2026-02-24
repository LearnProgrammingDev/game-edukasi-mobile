import 'package:game_edukasi_mobile/models/quiz.dart';

class Node {
  final int id;
  final String title;
  final String type;
  final String? content;
  final int xPosition;
  final int yPosition;
  final int order;
  final int expReward;
  String status; // locked / unlocked / completed
  final List<Quiz> quizzes;

  Node({
    required this.id,
    required this.title,
    required this.type,
    this.content,
    required this.xPosition,
    required this.yPosition,
    required this.order,
    required this.expReward,
    required this.status,
    required this.quizzes,
  });

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      content: json['content'],
      xPosition: json['x_position'] ?? 0,
      yPosition: json['y_position'] ?? 0,
      order: json['order'] ?? 0,
      expReward: json['exp_reward'] ?? 100,
      status: json['status'] ?? 'locked',
      quizzes: (json['quizzes'] as List<dynamic>? ?? [])
          .map((q) => Quiz.fromJson(q))
          .toList(),
    );
  }

  bool get isLocked => status == 'locked';
  bool get isUnlocked => status == 'unlocked';
  bool get isCompleted => status == 'completed';
}

class NodeConnection {
  final int sourceNodeId;
  final int targetNodeId;

  NodeConnection({required this.sourceNodeId, required this.targetNodeId});

  factory NodeConnection.fromJson(Map<String, dynamic> json) {
    return NodeConnection(
      sourceNodeId: json['source_node_id'],
      targetNodeId: json['target_node_id'],
    );
  }
}
