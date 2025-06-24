class Question {
  final String imagePath;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String funFact; 

  Question({
    required this.imagePath,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.funFact,
  });
}
