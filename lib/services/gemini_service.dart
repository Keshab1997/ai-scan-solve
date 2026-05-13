import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ⚠️ Replace with your actual API key from https://aistudio.google.com/app/apikey
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Extracts structured Bengali text (questions & answers) from image bytes.
  /// Use this to get organized question-answer output.
  Future<String> extractBengaliTextFromImage(Uint8List imageBytes) async {
    try {
      final prompt = '''
তুমি একজন বাংলা ভাষার বিশেষজ্ঞ সহকারী। দেওয়া ছবিটিতে যা লেখা আছে, সেটা সম্পূর্ণ এবং সঠিকভাবে বাংলায় টাইপ করো।

নিচের নিয়ম মেনে চলো:
1. প্রতিটি প্রশ্নের আগে "প্রশ্ন ১:", "প্রশ্ন ২:" এইভাবে নম্বর দাও।
2. প্রতিটি উত্তরের আগে "উত্তর:" লেখো।
3. যদি শুধু প্রশ্ন থাকে (উত্তর না থাকলে), তাহলে শুধু "প্রশ্ন X:" দাও।
4. ছবির টেক্সট যতটুকু সম্ভব মূল তথ্য অনুযায়ী সঠিকভাবে লিখো।
5. কোনো অতিরিক্ত তথ্য যোগ করবে না। শুধু ছবিতে যা আছে তাই লিখবে।
6. বাংলা অক্ষর সঠিকভাবে বজায় রাখবে।

শুধু ফরম্যাটেড টেক্সট রিটার্ন করো। অন্য কোনো ব্যাখ্যা দেবে না।
''';

      final promptContent = [
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ];

      final response = await _model.generateContent(promptContent);
      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        throw Exception('AI কোনো টেক্সট বের করতে পারেনি');
      }

      return text.trim();
    } catch (e) {
      if (e is GenerativeAIException) {
        throw Exception('API Error: ${(e as GenerativeAIException).message}');
      }
      rethrow;
    }
  }

  /// Simple extraction — returns raw Bengali text from image.
  Future<String> extractRawTextFromImage(Uint8List imageBytes) async {
    try {
      final prompt = '''
তুমি একটি OCR সহকারী। দেওয়া ছবিটিতে যা লেখা আছে, সেটা সম্পূর্ণ বাংলায় ঠিক যেমন দেখাচ্ছো লেখো। কোনো পরিবর্তন করবে না। শুধু ছবির টেক্সট টাইপ করো।
''';

      final promptContent = [
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ];

      final response = await _model.generateContent(promptContent);
      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        throw Exception('AI কোনো টেক্সট বের করতে পারেনি');
      }

      return text.trim();
    } catch (e) {
      if (e is GenerativeAIException) {
        throw Exception('API Error: ${(e as GenerativeAIException).message}');
      }
      rethrow;
    }
  }
}