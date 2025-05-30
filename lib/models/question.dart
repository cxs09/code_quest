class Question {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
    );
  }
} 