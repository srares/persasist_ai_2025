import 'package:hive/hive.dart';

part 'question.g.dart'; // This line is important for code generation

@HiveType(typeId: 0) // typeId must be unique for each model
class Question {
  @HiveField(0)
  final String question;

  @HiveField(1)
  final List<String> options;

  @HiveField(2)
  final int correctAnswerIndex;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}
