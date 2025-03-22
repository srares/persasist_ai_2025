import 'package:hive/hive.dart';

part 'question.g.dart';

@HiveType(typeId: 0)
class Question {
  @HiveField(0)
  final String question;

  @HiveField(1)
  String? answer; // Make answer nullable

  Question({
    required this.question,
    this.answer, // Answer is optional in the constructor
  });
}
