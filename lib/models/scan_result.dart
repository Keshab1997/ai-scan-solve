import 'package:hive/hive.dart';

part 'scan_result.g.dart';

@HiveType(typeId: 0)
class ScanResult extends HiveObject {
  @HiveField(0)
  final String imagePath;

  @HiveField(1)
  final String extractedText;

  @HiveField(2)
  final String createdAt;

  @HiveField(3)
  String? imageBase64; // Store base64 for web compatibility

  ScanResult({
    required this.imagePath,
    required this.extractedText,
    required this.createdAt,
    this.imageBase64,
  });
}