import 'dart:typed_data';
import 'package:hive/hive.dart';
import '../models/scan_result.dart';

class ScanResultAdapter extends TypeAdapter<ScanResult> {
  @override
  final int typeId = 0;

  @override
  ScanResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ScanResult(
      imagePath: fields[0] as String,
      extractedText: fields[1] as String,
      createdAt: fields[2] as String,
      imageBase64: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ScanResult obj) {
    writer
      ..writeByte(4) // number of fields
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj.extractedText)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.imageBase64);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}