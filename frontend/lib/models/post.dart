import 'dart:io';

import 'package:flutter/foundation.dart';

class Post {
  final int id;
  final String? text;
  final String authorEmail;
  final String authorName;
  final DateTime createdDate;
  final int imageCount;
  final List<String> imageUrls;

  Post({
    required this.id,
    this.text,
    required this.authorEmail,
    required this.authorName,
    required this.createdDate,
    required this.imageCount,
    required this.imageUrls,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    List<String> imageUrls = [];

    if (json['imageUrls'] != null) {
      final raw = json['imageUrls'].toString();
      final matches = RegExp(r'http[^\s\]]+').allMatches(raw);
      imageUrls = matches.map((m) {
        var url = m.group(0)!;

        if (kIsWeb) {
          return url;
        } else if (Platform.isAndroid) {
          return url.replaceFirst('localhost', '10.0.2.2');
        } else {
          return url;
        }
      }).toList();
    }

    String? text;
    if (json['text'] != null) {
      final t = json['text'].toString();
      final match = RegExp(r'"text"\s*:\s*"([^"]+)"').firstMatch(t);
      text = match != null ? match.group(1) : t;
    }

    return Post(
      id: json['id'] as int,
      text: text,
      authorEmail: json['authorEmail'] as String,
      authorName: json['authorName'] as String,
      createdDate: DateTime.parse(json['createdDate']),
      imageCount: json['imageCount'] as int,
      imageUrls: imageUrls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'authorEmail': authorEmail,
      'authorName': authorName,
      'createdDate': createdDate.toIso8601String(),
      'imageCount': imageCount,
      'imageNames': imageUrls.isEmpty ? null : imageUrls,
    };
  }
}