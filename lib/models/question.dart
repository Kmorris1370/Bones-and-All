class Question {
  final String id;
  final String blockId;
  final String questionText;
  final String questionType; // 'scale', 'tags', 'text'
  final int displayOrder;

  Question({
    required this.id,
    required this.blockId,
    required this.questionText,
    required this.questionType,
    required this.displayOrder,
  });

  factory Question.fromJson(Map<String, dynamic> j) => Question(
    id: j['id'],
    blockId: j['block_id'],
    questionText: j['question_text'],
    questionType: j['question_type'],
    displayOrder: j['display_order'] ?? 0,
  );
}