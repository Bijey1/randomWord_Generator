import 'package:flutter/material.dart';

class favorites {
  static List<String> wordVault = [];

  static void storeWord(String word) {
    wordVault.add(word);
  }

  static void printWords() {
    print(wordVault);
  }

  static int countWords() {
    return wordVault.length;
  }

  static void removeWord() {
    wordVault.removeLast();
  }

  static void removeAWord(String word) {
    print(wordVault);
    int wordRem = wordVault.indexOf(word);
    if (wordRem == -1) wordRem = 0;
    print("The index of $word is $wordRem");
    wordVault.removeAt(wordRem);
    print(wordVault);
  }
}
