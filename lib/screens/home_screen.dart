import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/scan_result.dart';
import '../services/database_service.dart';
import '../widgets/history_card.dart';
import 'scan_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  final DatabaseService _dbService = DatabaseService();
  List<ScanResult> _scanResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    final results = await _dbService.getAllScanResults();
    if (mounted) {
      setState(() {
        _scanResults = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToScan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    _loadHistory();
  }

  Future<void> _deleteResult(int key) async {
    await _dbService.deleteScanResult(key);
    _loadHistory();
    if (mounted) {
      Fluttertoast.showToast(msg: 'ইতিহাস থেকে মুছে ফেলা হয়েছে');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(msg: 'কপি হয়ে গেছে!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Scan & Solve',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'রিফ্রেশ',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scanResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.document_scanner_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'কোনো স্ক্যান করা হয়নি',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'নিচের + বাটনে চাপে নতুন ছবি স্ক্যান করুন',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _scanResults.length,
                  itemBuilder: (context, index) {
                    final result = _scanResults[index];
                    final key = result.key ?? index;
                    return HistoryCard(
                      result: result,
                      key: ValueKey(key),
                      onTap: () => _navigateToResult(result),
                      onDelete: () => _deleteResult(key),
                      onCopy: () => _copyToClipboard(result.extractedText),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToScan,
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('স্ক্যান করুন'),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _navigateToResult(ScanResult result) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          imagePath: result.imagePath,
          imageBase64: result.imageBase64,
          extractedText: result.extractedText,
          isFromHistory: true,
        ),
      ),
    );
  }
}