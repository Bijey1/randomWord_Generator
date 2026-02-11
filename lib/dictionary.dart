import 'package:flutter/material.dart';

class Dictionary {
  static List<Map<String, String>> pageContent = [];

  static void page(
    String word,
    String phonetic,
    String meaning,
    String partOfSpeech,
  ) {
    List<Map<String, String>> tempPage = [
      {
        "word": word,
        "phonetic": phonetic,
        "meaning": meaning,
        "partOfSpeech": partOfSpeech,
      },
    ];
    pageContent.addAll(tempPage);
  }

  static void seeDictContent() {
    print(pageContent);
  }
}
