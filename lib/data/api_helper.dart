import 'dart:io';
import 'package:chyawanprash/data/url.dart';
import 'package:google_generative_ai/google_generative_ai.dart';


class ApiHelper {
  Future<String?> generateAiMsg({required String prompt}) async {
    try {
      // For text-only input, use the gemini-pro model
      final model = GenerativeModel(model: 'gemini-pro', apiKey:urls.apiKey);
      final content = [Content.text(prompt)];
      final output = await model.generateContent(content);
      print(output.text);
      return output.text;


    }
    catch(e) {
      throw(HttpException(e.toString()));
    }
  }
}