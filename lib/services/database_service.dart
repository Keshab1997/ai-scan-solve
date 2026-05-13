import 'package:hive/hive.dart';
import '../models/scan_result.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Box<ScanResult>? _box;

  Future<Box<ScanResult>> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<ScanResult>('scan_results');
    return _box!;
  }

  Future<void> init() async {
    if (!Hive.isBoxOpen('scan_results')) {
      _box = await Hive.openBox<ScanResult>('scan_results');
    }
  }

  Future<int> insertScanResult(ScanResult result) async {
    final box = await _getBox();
    return await box.add(result);
  }

  Future<List<ScanResult>> getAllScanResults() async {
    final box = await _getBox();
    return box.values.toList().reversed.toList();
  }

  Future<ScanResult?> getScanResult(int key) async {
    final box = await _getBox();
    return box.get(key);
  }

  Future<void> deleteScanResult(int key) async {
    final box = await _getBox();
    await box.delete(key);
  }

  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
  }

  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}