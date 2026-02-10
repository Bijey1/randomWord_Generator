import 'package:flutter/material.dart';

class favorites {
  static List<String> wordVault = [];

  static void storeWord(String word) {
    wordVault.add(word);
  }

  static void showWords() {
    print(wordVault);
  }

  static int countWords() {
    return wordVault.length;
  }

  static void removeWord() {
    wordVault.removeLast();
  }
}
