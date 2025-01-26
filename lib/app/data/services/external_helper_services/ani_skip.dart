import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mana_debug/app/data/models/services/external_helper_services_models/ani_skip.dart';

class AniSkipService {
  static const String _baseUrl = 'https://api.aniskip.com/v1';

  Future<AniSkipSkipData?> getAnimeEpisodeOpeningSkipData(
      int malId, String episodeNumber) async {
    var response = await http.get(
        Uri.parse('$_baseUrl/skip-times/$malId/$episodeNumber?types[]=op'));
    var rJson = jsonDecode(response.body);
    
    
    
    if (rJson['found'] == false) {
      return null;
    } else {
      return AniSkipSkipData(
        startTime: double.parse(
            rJson['results'][0]['interval']['start_time'].toString()),
        endTime: double.parse(
            rJson['results'][0]['interval']['end_time'].toString()),
      );
    }
  }

  Future<AniSkipSkipData?> getAnimeEpisodeEndingSkipData(
      int malId, String episodeNumber) async {
    var response = await http.get(
        Uri.parse('$_baseUrl/skip-times/$malId/$episodeNumber?types[]=ed'));
    var rJson = jsonDecode(response.body);
    if (rJson['found'] == false) {
      return null;
    } else {
      return AniSkipSkipData(
        startTime: double.parse(
            rJson['results'][0]['interval']['start_time'].toString()),
        endTime: double.parse(
            rJson['results'][0]['interval']['end_time'].toString()),
      );
    }
  }
}
