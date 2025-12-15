import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class MusicApiService {
  static const String _url =
      'https://raw.githubusercontent.com/FaroukEldars/music-json/refs/heads/main/songs.json';

  static Future<List<Song>> fetchSongs() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List songsJson = data['songs'];

      return songsJson.map((e) => Song.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load songs');
    }
  }
}
