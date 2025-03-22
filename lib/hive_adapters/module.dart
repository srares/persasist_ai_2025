import 'package:hive/hive.dart';

part 'module.g.dart';

@HiveType(typeId: 2) // Use a unique typeId (e.g., 2)
class Module {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String information;

  Module({required this.title, required this.information});
}
