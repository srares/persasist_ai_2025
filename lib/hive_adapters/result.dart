import 'package:hive/hive.dart';

part 'result.g.dart';

@HiveType(typeId: 1) // Use a unique typeId (e.g., 1)
class Result {
  @HiveField(0)
  final int score;

  @HiveField(1)
  final String level;

  Result({required this.score, required this.level});
}
