import 'package:flutter/material.dart';
import 'faves.dart';

class Dictionary {
  static List<List<Map<String, String>>> pageContent = [];

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
    pageContent.add(tempPage);
  }

  static void seeDictContent() {
    print(pageContent);
  }

  static void deletePage() {
    pageContent.removeLast();
  }

  static void deleteFrom(dynamic word) {
    for (int i = 0; i < pageContent.length; i++) {
      if (pageContent[i][0]["word"] == word) {
        pageContent.remove(pageContent[i]);

        favorites.removeAWord(word);
        return;
      }
    }
  }
}
