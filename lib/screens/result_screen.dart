import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import '../models/scan_result.dart';
import '../services/database_service.dart';

class ResultScreen extends StatefulWidget {
  final Uint8List? imageBytes; // Web-safe image
  final String extractedText;
  final bool isFromHistory;

  const ResultScreen({
    super.key,
    this.imageBytes,
    required this.extractedText,
    required this.isFromHistory,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<String> _questions = [];
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _parseQuestions();
  }

  void _parseQuestions() {
    final regex = RegExp(r'(?=প্রশ্ন\s*\d+\s*:?\s*)');
    final parts = widget.extractedText
        .split(regex)
        .where((p) => p.trim().isNotEmpty)
        .toList();
    _questions = parts;
  }

  ImageProvider get _imageProvider {
    if (widget.imageBytes != null) {
      return MemoryImage(widget.imageBytes!);
    }
    return const AssetImage('assets/placeholder.png') as ImageProvider;
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.extractedText));
    Fluttertoast.showToast(msg: 'কপি হয়ে গেছে! ✓');
  }

  Future<void> _shareText() async {
    await Share.share(widget.extractedText);
  }

  Future<void> _saveToHistory() async {
    String? base64Image;
    if (widget.imageBytes != null) {
      base64Image = base64Encode(widget.imageBytes!);
    }

    final result = ScanResult(
      imagePath: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      extractedText: widget.extractedText,
      createdAt: DateTime.now().toIso8601String(),
      imageBase64: base64Image,
    );
    await _dbService.insertScanResult(result);
    if (mounted) {
      Fluttertoast.showToast(msg: 'সেভ হয়েছে ইতিহাসে! ✓');
      setState(() {
        _isSaved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ফলাফল'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all_rounded),
            onPressed: _copyToClipboard,
            tooltip: 'কপি করুন',
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareText,
            tooltip: 'শেয়ার করুন',
          ),
        ],
      ),
      body: Column(
        children: [
          // Image Preview (top portion)
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(color: Colors.black12),
            child: Image(
              image: _imageProvider,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image_not_supported,
                      size: 48, color: Colors.grey),
                );
              },
            ),
          ),

          // Extracted Text (bottom portion)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: _questions.isEmpty
                  ? _buildRawText()
                  : _buildStructuredList(),
            ),
          ),

          // Action Buttons
          if (!widget.isFromHistory)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy_all_rounded),
                      label: const Text('কপি করুন'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareText,
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('শেয়ার'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC143C),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaved ? null : _saveToHistory,
                      icon: Icon(
                          _isSaved ? Icons.check_circle : Icons.save_rounded),
                      label: Text(_isSaved ? 'সেভ হয়েছে' : 'সেভ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaved
                            ? Colors.green
                            : const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStructuredList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index].trim();
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  question,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRawText() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        widget.extractedText,
        style: const TextStyle(fontSize: 15, height: 1.7),
      ),
    );
  }
}