import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

class GeminiService {
  String _getApiKey() {
    // 1. Try to read from flutter_dotenv
    final key = dotenv.maybeGet('GEMINI_API_KEY');
    if (key != null && key.isNotEmpty) {
      return key;
    }
    // 2. Fallback to production workspace key
    return 'AIzaSyA2d-8dgxayYrscRML-rPpqKyQvgJJCq08';
  }

  Future<String> generateText(String prompt) async {
    final apiKey = _getApiKey();

    // We compile a sequence of combinations of standard models and API versions.
    // If one fails with a 404, we immediately try the next combination.
    final List<Map<String, String>> configurations = [
      {'version': 'v1beta', 'model': 'gemini-2.5-flash'},
      {'version': 'v1', 'model': 'gemini-2.5-flash'},
      {'version': 'v1beta', 'model': 'gemini-2.0-flash'},
      {'version': 'v1', 'model': 'gemini-2.0-flash'},
      {'version': 'v1beta', 'model': 'gemini-flash-latest'},
      {'version': 'v1beta', 'model': 'gemini-pro-latest'},
      {'version': 'v1', 'model': 'gemini-1.5-flash'},
      {'version': 'v1beta', 'model': 'gemini-1.5-flash'},
      {'version': 'v1beta', 'model': 'gemini-pro'},
      {'version': 'v1', 'model': 'gemini-pro'},
      {'version': 'v1', 'model': 'gemini-1.5-pro'},
      {'version': 'v1beta', 'model': 'gemini-1.5-pro'},
      {'version': 'v1', 'model': 'gemini-1.0-pro'},
    ];

    Exception? lastException;

    for (final config in configurations) {
      final version = config['version']!;
      final model = config['model']!;
      final url =
          'https://generativelanguage.googleapis.com/$version/models/$model:generateContent?key=$apiKey';

      final client = HttpClient();
      try {
        final uri = Uri.parse(url);
        final request = await client.postUrl(uri);
        request.headers.contentType = ContentType.json;

        final body = jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        });

        request.write(body);
        final response = await request.close();

        if (response.statusCode != 200) {
          final errText = await response.transform(utf8.decoder).join();
          lastException = Exception(
            'Gemini API Error (${response.statusCode}) for model $model on $version: $errText',
          );
          // If it is a 404/Not Found, we print a silent warning and try the next config.
          debugPrint(
            '[GeminiService] Model $model on version $version failed with status ${response.statusCode}. Trying fallback...',
          );
          continue;
        }

        final resText = await response.transform(utf8.decoder).join();
        final json = jsonDecode(resText) as Map<String, dynamic>;

        final candidates = json['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          lastException = Exception('No response candidates from Gemini API');
          continue;
        }

        final content = candidates.first['content'] as Map?;
        final parts = content?['parts'] as List?;
        final text = parts?.first['text'] as String?;

        if (text == null) {
          lastException = Exception('Empty content from Gemini response');
          continue;
        }

        // Successfully generated text!
        debugPrint(
          '[GeminiService] Successfully generated text using model $model on version $version.',
        );
        return text.trim();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
      } finally {
        client.close();
      }
    }

    throw lastException ?? Exception('Unknown Gemini Service error');
  }
}
