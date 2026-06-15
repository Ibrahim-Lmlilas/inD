class FaqItem {
  final String id;
  final String question;
  final String answer;

  FaqItem({required this.id, required this.question, required this.answer});

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'question': question, 'answer': answer};
  }
}
