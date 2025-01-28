import 'package:dio/dio.dart';

class Query {
  final String response;
  final String language;

  Query({required this.response, required this.language});

  factory Query.fromJson(Map<String, dynamic> json) {
    return Query(
      response: json['response'] as String,
      language: json['language'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response': response,
      'language': language,
    };
  }
}
