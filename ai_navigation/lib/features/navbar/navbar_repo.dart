import 'model.dart';
import 'package:dio/dio.dart';

import '../../core/global_var.dart';

class QueryRepository {
  final Dio _dio = Dio();

  Future<Query> store({required String query, required String language}) async {
    try {
      String? ip=(GlobalSettings.instance).ip;
      final response = await _dio.post(
        'http://${ip!}:5000/api/change_page',
        data: {'query': query, 'language': language},
      );

      if (response.statusCode == 201) {
        // Parse the response into a User object
        return Query.fromJson(response.data);
      } else {
        throw Exception('Failed to login. Please try again.');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
}
