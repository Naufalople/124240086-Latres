import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/episode.dart';

class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  // Fetch list of characters with optional status filter and name search (Bonus)
  static Future<List<Character>> getCharacters({
    String? status,
    String? name,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
    };

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }

    if (name != null && name.trim().isNotEmpty) {
      queryParams['name'] = name.trim();
    }

    final uri = Uri.parse('$baseUrl/character').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        return results.map((e) => Character.fromJson(e)).toList();
      } else if (response.statusCode == 404) {
        // Rick & Morty API returns 404 when no results match query
        return [];
      } else {
        throw Exception('Server error: HTTP ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda.');
    } on http.ClientException {
      throw Exception('Gagal terhubung ke server Rick & Morty.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  // Fetch single character details
  static Future<Character> getCharacterDetail(int id) async {
    final uri = Uri.parse('$baseUrl/character/$id');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Character.fromJson(data);
      } else {
        throw Exception('Karakter tidak ditemukan (HTTP ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal memuat detail karakter: $e');
    }
  }

  // Fetch list of episodes
  static Future<List<Episode>> getEpisodes({int page = 1}) async {
    final uri = Uri.parse('$baseUrl/episode?page=$page');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        return results.map((e) => Episode.fromJson(e)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Gagal memuat episode (HTTP ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan saat memuat episode: $e');
    }
  }
}
