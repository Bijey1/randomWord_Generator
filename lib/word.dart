import 'package:flutter/material.dart';
import 'dictionary.dart';

class Word {
  //Creating a word or page object
  String word;
  String phonetic;
  String meaning;
  String partOfSpeech;

  factory Word.getFromJson(Map<String, dynamic> json) {
    String w = "";
    String pho = "";
    String mean = "";
    String part = "";

    //get the word
    if (json["word"] != null) {
      //if i found the key "word"
      w = json["word"];

      if (json["phonetic"] != null) {
        pho = json["phonetic"];
      }

      if (json["meanings"] != null) {
        mean = json["meanings"][0]["definitions"][0]["definition"];
      }

      part = json["meanings"][1]["partOfSpeech"];
    }

    return Word._internal(w, pho, mean, part);
  }

  Word._internal(
    this.word,
    this.phonetic,
    this.meaning,
    this.partOfSpeech,
  ); //internal

  void transferToDictionary() {
    print("NAG DICTRIO");
    Dictionary.page(word, phonetic, meaning, partOfSpeech);
  }
}
