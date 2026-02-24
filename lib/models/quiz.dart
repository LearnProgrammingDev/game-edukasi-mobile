class Quiz {
  final int id;
  final int nodeId;
  final String type;
  final String question;
  final List<String>? options;
  final String? hint;
  final int order;

  Quiz({
    required this.id,
    required this.nodeId,
    required this.type,
    required this.question,
    this.options,
    this.hint,
    required this.order,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      nodeId: json['node_id'],
      type: json['type'],
      question: json['question'],
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      hint: json['hint'],
      order: json['order'] ?? 1,
    );
  }
}
