import 'package:flutter/material.dart';
import 'package:mana_debug/app/data/models/services/external_helper_services_models/tmdb.dart';
import 'package:tmdb_api/tmdb_api.dart' hide MediaType;

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  final String imageBaseUrl = 'https://image.tmdb.org/t/p/original';
  static const List<String> _apiKeys = [
    'fb7bb23f03b6994dafc674c074d01761',
    'e55425032d3d0f371fc776f302e7c09b',
    '8301a21598f8b45668d5711a814f01f6',
    '8cf43ad9c085135b9479ad5cf6bbcbda',
    'da63548086e399ffc910fbc08526df05',
    '13e53ff644a8bd4ba37b3e1044ad24f3',
    '269890f657dddf4635473cf4cf456576',
    'a2f888b27315e62e471b2d587048f32e',
    '8476a7ab80ad76f0936744df0430e67c',
    '5622cafbfe8f8cfe358a29c53e19bba0',
    'ae4bd1b6fce2a5648671bfc171d15ba4',
    '257654f35e3dff105574f97fb4b97035',
    '2f4038e83265214a0dcd6ec2eb3276f5',
    '9e43f45f94705cc8e1d5a0400d19a7b7',
    'af6887753365e14160254ac7f4345dd2',
    '06f10fc8741a672af455421c239a1ffc',
    'fb7bb23f03b6994dafc674c074d01761',
    '09ad8ace66eec34302943272db0e8d2c',
  ];
  int numInstances = _apiKeys.length;
  final List<TMDB> _tmdbInstances = [];
  final RegExp _seasonRegex = RegExp(r'(Season (\d*))');
  final RegExp _seasonRegex2 = RegExp(r'((\d*)(st|nd|rd|th) Season)');

  TMDBService() {
    for (var apiKey in _apiKeys) {
      _tmdbInstances.add(TMDB(ApiKeys(apiKey, 'apiReadAccessTokenv4'),
          logConfig: const ConfigLogger(showLogs: true, showErrorLogs: true)));
    }
  }

  Future<Map<String, dynamic>?> getItemImdbIdFromName(String name,
      {bool isAnime = false}) async {
    int currentInstance = 0;
    var seasonMatches = _seasonRegex.allMatches(name);
    if (seasonMatches.isNotEmpty) {
      name = name.substring(0, seasonMatches.first.start).trim();
    } else {
      try {
        seasonMatches = _seasonRegex2.allMatches(name);
        if (seasonMatches.isNotEmpty) {
          name = name.substring(0, seasonMatches.first.start).trim();
        }
      } catch (e) {
        debugPrint('TMDB: Error getting season number: $e');
      }
    }
    int? seasonNumber;
    try {
      seasonNumber = int.parse(seasonMatches.first.group(2).toString());
    } catch (e) {
      debugPrint('TMDB: Error getting season number: $e');
    }
    debugPrint('TMDB: Getting item from name: $name');
    while (currentInstance < numInstances) {
      try {
        final result = TMDBSearchResponseModel.fromJson(
            await _tmdbInstances[currentInstance].v3.search.queryMulti(name)
                as Map<String, dynamic>);

        List<Result> matches = [];
        for (var item in result.results) {
          if (item.name?.toLowerCase() == name.toLowerCase() ||
              item.originalName?.toLowerCase() == name.toLowerCase() ||
              item.title?.toLowerCase() == name.toLowerCase() ||
              item.originalTitle?.toLowerCase() == name.toLowerCase()) {
            matches.add(item);
          }
        }
        if (matches.isNotEmpty) {
          if (matches.length > 1) {
            if (isAnime) {
              var matchJapanese = matches
                  .where((element) => element.originalLanguage == "ja")
                  .toList();
              if (matchJapanese.isNotEmpty) {
                return {
                  'id': matchJapanese.first.id.toString(),
                  'type': matchJapanese.first.mediaType,
                  'seasonNumber': seasonNumber
                };
              }
              var matchEnglish = matches
                  .where((element) => element.originalLanguage == "en")
                  .toList();
              if (matchEnglish.isNotEmpty) {
                return {
                  'id': matchEnglish.first.id.toString(),
                  'type': matchEnglish.first.mediaType,
                  'seasonNumber': seasonNumber
                };
              }
              return {
                'id': matches.first.id.toString(),
                'type': matches.first.mediaType,
                'seasonNumber': seasonNumber
              };
            } else {
              var matchEnglish = matches
                  .where((element) => element.originalLanguage == "en")
                  .toList();
              if (matchEnglish.isNotEmpty) {
                return {
                  'id': matchEnglish.first.id.toString(),
                  'type': matchEnglish.first.mediaType,
                  'seasonNumber': seasonNumber
                };
              }
            }
          }
          return {
            'id': matches.first.id.toString(),
            'type': matches.first.mediaType,
            'seasonNumber': seasonNumber
          };
        }
      } catch (e) {
        debugPrint('TMDB: Error getting item from name: $e');
        return null;
      }
      currentInstance++;
    }
    return null;
  }

  Future<TMDBDetailsResponseModel?> getItemDetails(
      String id, MediaType type) async {
    int currentInstance = 0;
    debugPrint('TMDB: Getting item details: $id, $type');
    while (currentInstance < numInstances) {
      try {
        if (type == MediaType.MOVIE) {
          return TMDBDetailsResponseModel.fromJson(
              await _tmdbInstances[currentInstance]
                  .v3
                  .movies
                  .getDetails(int.parse(id)) as Map<String, dynamic>);
        } else if (type == MediaType.TV) {
          return TMDBDetailsResponseModel.fromJson(
              await _tmdbInstances[currentInstance]
                  .v3
                  .tv
                  .getDetails(int.parse(id)) as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('TMDB: Error getting item details: $e');
        return null;
      }
      currentInstance++;
    }
    debugPrint('TMDB: Error getting item details');
    return null;
  }

  Future<TMDBSeasonResponseModel?> getItemSeasonData(
      String id, int? seasonNumber) async {
    seasonNumber ??= 1;
    int currentInstance = 0;
    debugPrint('TMDB: Getting item season data: $id, $seasonNumber');
    while (currentInstance < numInstances) {
      try {
        return TMDBSeasonResponseModel.fromJson(
            await _tmdbInstances[currentInstance].v3.tvSeasons.getDetails(
                int.parse(id), seasonNumber) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('TMDB: Error getting item season data: $e');
      }
      currentInstance++;
    }
    return null;
  }
}
