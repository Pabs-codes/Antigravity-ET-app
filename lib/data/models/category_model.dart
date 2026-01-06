import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String iconCode; // Storing IconData as codePoint or string identifier

  @HiveField(3)
  final double budgetLimit;

  @HiveField(4)
  final int colorValue; // Storing Color as int (0xAARRGGBB)

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.budgetLimit,
    required this.colorValue,
  });
}
