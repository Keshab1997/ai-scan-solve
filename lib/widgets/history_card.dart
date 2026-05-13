import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import '../models/scan_result.dart';

class HistoryCard extends StatelessWidget {
  final ScanResult result;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const HistoryCard({
    super.key,
    required this.result,
    required this.onTap,
    required this.onDelete,
    required this.onCopy,
  });

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'জানু', 'ফেব্রু', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
        'জুলাই', 'আগস্ট', 'সেপ্ট', 'অক্টো', 'নভে', 'ডিসে'
      ];
      final month = months[date.month - 1];
      return '$month ${date.day}, ${date.year}\n${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  String _getFirstLine(String text) {
    final lines =
        text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return 'কোনো টেক্সট নেই';
    final first = lines.first;
    return first.length > 60 ? '${first.substring(0, 57)}...' : first;
  }

  ImageProvider _getThumbnailProvider() {
    if (result.imageBase64 != null && result.imageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(result.imageBase64!);
        return MemoryImage(Uint8List.fromList(bytes));
      } catch (_) {
        // Fallback
      }
    }
    if (result.imagePath != null) {
      return FileImage(File(result.imagePath!));
    }
    return const AssetImage('assets/placeholder.png') as ImageProvider;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: thumbnail + timestamp
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                      image: _getThumbnailProvider(),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported,
                            size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text preview
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFirstLine(result.extractedText),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(result.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.copy_all_rounded, size: 20),
                    tooltip: 'কপি',
                    onPressed: onCopy,
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 20),
                    tooltip: 'মুছুন',
                    onPressed: onDelete,
                    splashRadius: 20,
                    color: Colors.red[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}