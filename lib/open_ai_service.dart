import 'dart:convert';

import 'package:chat_assistant/secret.dart';
import 'package:http/http.dart' as http;

//integrate chatGPT, Dell E
class OpenAIService {
  final List<Map<String, String>> messages = [];
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAiKey'
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "message": [
              {"role": "user", "content": "You are generating image."}
            ]
          }));
      print(res.body);
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choice'][0]['message']['content'];
        content = content.trim();
        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'YES':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      return 'An internal error has ocurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAiKey'
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "message": messages,
          }));
      print(res.body);
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choice'][0]['message']['content'];
        content = content.trim();
        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error has ocurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
