import 'dart:convert';
import 'package:http/http.dart' as http;

class ExerciseApiService {
  static const String _apiKey =
      '3a6501e785msh0a30fbd58f812bfp1dec66jsn6b427176348c';
  static const String _apiHost = 'exercisedb.p.rapidapi.com';
  static const String _baseUrl = 'https://exercisedb.p.rapidapi.com';

  static Future<Map<String, dynamic>?> fetchExerciseByName(String name) async {
    final url = Uri.parse(
      '$_baseUrl/exercises/name/${Uri.encodeComponent(name)}',
    );

    try {
      final response = await http.get(
        url,
        headers: {'X-RapidAPI-Key': _apiKey, 'X-RapidAPI-Host': _apiHost},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(
          response.statusCode == 200 ? response.body : '[]',
        );
        if (data.isNotEmpty) {
          // Return the first match
          return data[0] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching exercise from API: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchExerciseById(String id) async {
    final url = Uri.parse('$_baseUrl/exercises/exercise/$id');

    try {
      final response = await http.get(
        url,
        headers: {'X-RapidAPI-Key': _apiKey, 'X-RapidAPI-Host': _apiHost},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching exercise by ID from API: $e');
      return null;
    }
  }
}
