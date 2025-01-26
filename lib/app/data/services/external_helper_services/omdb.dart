import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/data/models/services/external_helper_services_models/omdb.dart';

class OMDBService {
  static const _baseUrl = 'http://www.omdbapi.com';
  static const _openSubtitlesBaseUrl = 'https://rest.opensubtitles.org';
  static const _apiKeys = [
    '4b447405',
    'eb0c0475',
    '7776cbde',
    'ff28f90b',
    '6c3a2d45',
    'b07b58c8',
    'ad04b643',
    'a95b5205',
    '777d9323',
    '2c2c3314',
    'b5cff164',
    '89a9f57d',
    '73a9858a',
    'efbd8357'
  ];

  Future<List<OMDBSubtitleSearchResponse>?> getTVSubtitles(
      String imdbId, int season, double episode) async {
    try {
      var response = await http.get(
          Uri.parse(
              '$_openSubtitlesBaseUrl/search/episode-$episode/imdbid-$imdbId/season-$season/sublanguageid-en'),
          headers: {
            'User-Agent': 'obadasub',
          });
      var results = <OMDBSubtitleSearchResponse>[];
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        for (var result in json) {
          results.add(OMDBSubtitleSearchResponse.fromJson(result));
        }
      }
      return results;
    } catch (e) {
      debugPrint('OMDB: Error getting subtitles: $e');
      return null;
    }
  }

  Future<List<OMDBSubtitleSearchResponse>?> getMovieSubtitles(
      String imdbId) async {
    try {
      var response = await http.get(
          Uri.parse(
              '$_openSubtitlesBaseUrl/search/imdbid-$imdbId/sublanguageid-en'),
          headers: {
            'User-Agent': 'obadasub',
          });
      var results = <OMDBSubtitleSearchResponse>[];
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        for (var result in json) {
          results.add(OMDBSubtitleSearchResponse.fromJson(result));
        }
      }
      return results;
    } catch (e) {
      debugPrint('OMDB: Error getting subtitles: $e');
      return null;
    }
  }

  Future<OMDBBaseInfoResponse?> getBaseInfo(String modifiedTitle) async {
    try {
      OMDBBaseInfoResponse? data;
      for (var apiKey in _apiKeys) {
        var response = await http.get(
            Uri.parse('$_baseUrl/?apikey=$apiKey&t=$modifiedTitle&plot=full'),
            headers: {
              'User-Agent': 'obadasub',
            });
        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          try {
            data = OMDBBaseInfoResponse.fromJson(json);
            break;
          } catch (e) {
            debugPrint('OMDB: Error getting base info: $e');
          }
        }
      }
      if (data == null) {
        debugPrint('OMDB: Error getting base info: No API keys left');
      }
      return data;
    } catch (e) {
      debugPrint('OMDB: Error getting base info: $e');
      return null;
    }
  }

  Future<List<OMDBSubtitleSearchResponse>?> getSubtitles(String modifiedTitle,
      {int? season, double? episode}) async {
    OMDBBaseInfoResponse? baseInfo;
    try {
      baseInfo = await getBaseInfo(modifiedTitle);
    } catch (e) {
      debugPrint('OMDB: Error getting base info: $e');
    }
    if (baseInfo == null) {
      return null;
    }
    if (season != null && episode != null) {
      return await getTVSubtitles(baseInfo.imdbId, season, episode);
    } else {
      return await getMovieSubtitles(baseInfo.imdbId);
    }
  }
}
