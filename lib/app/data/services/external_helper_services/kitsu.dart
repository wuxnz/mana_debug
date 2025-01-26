import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/data/models/services/external_helper_services_models/kitsu.dart';

class KitsuService {
  static const String _baseUrl = 'https://kitsu.io/api/graphql';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Connection': 'keep-alive',
    'DNT': '1',
    'Origin': 'https://kitsu.io',
  };

  Future<int?> getAnimeKitsuIdFromSearch(
      String query, List<String> altTitles) async {
    var response = await http.post(Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'query': '''
        query Query {
        searchAnimeByTitle(title: "$query", first: 20) {
          nodes {
            id
            titles {
              alternatives
              original
              localized
              canonical
              romanized
              translated
            }
          }
        }
      }
      ''',
        }));
    var rJson = jsonDecode(response.body);
    if (rJson['data'] == null) {
      return null;
    }
    var queryLower = query.toLowerCase();
    List<BaseKitsuResponse> kitsuSearchResponseJson =
        List<BaseKitsuResponse>.from(rJson['data']['searchAnimeByTitle']
                ['nodes']
            .map((x) => BaseKitsuResponse.fromJson(x)));
    debugPrint(
        'Kitsu Results Length: ${kitsuSearchResponseJson.length} results found for $query');
    for (var e in kitsuSearchResponseJson) {
      if (e.titles.canonical?.toLowerCase().trim() == queryLower) {
        return int.parse(e.id);
      }
      debugPrint('Passed title check');
      if (e.titles.romanized != null) {
        if (e.titles.romanized?.toLowerCase().trim() == queryLower) {
          return int.parse(e.id);
        }
      }
      if (e.titles.translated != null) {
        if (e.titles.translated?.toLowerCase().trim() == queryLower) {
          return int.parse(e.id);
        }
      }
      if (e.titles.original?.trim() == query) {
        return int.parse(e.id);
      }
      var titles = [];

      for (var title in e.titles.alternatives) {
        titles.add(title);
      }
      debugPrint('Jikan: titles: $titles');
      if (titles.any(
          (title) => title.toString().toLowerCase().trim() == queryLower)) {
        return int.parse(e.id);
      }
      var synonyms = [];

      if (e.titles.localized?.en != null) {
        synonyms.add(e.titles.localized?.en);
      }
      if (e.titles.localized?.enJp != null) {
        synonyms.add(e.titles.localized?.enJp);
      }
      if (e.titles.localized?.jaJp != null) {
        synonyms.add(e.titles.localized?.jaJp);
      }
      if (e.titles.localized?.enUs != null) {
        synonyms.add(e.titles.localized?.enUs);
      }
      debugPrint('Jikan: synonyms: $synonyms');
      if (synonyms.any(
          (synonym) => synonym.toString().toLowerCase().trim() == queryLower)) {
        return int.parse(e.id);
      }
      for (var altTitle in altTitles) {
        if (e.titles.canonical?.toLowerCase().trim() == queryLower) {
          return int.parse(e.id);
        }
        debugPrint('Passed title check');
        if (e.titles.romanized != null) {
          if (e.titles.romanized?.toLowerCase().trim() == queryLower) {
            return int.parse(e.id);
          }
        }
        if (e.titles.translated != null) {
          if (e.titles.translated?.toLowerCase().trim() == queryLower) {
            return int.parse(e.id);
          }
        }
        if (e.titles.original?.trim() == query) {
          return int.parse(e.id);
        }
        if (titles.any((title) =>
            title.toString().toLowerCase().trim() == altTitle.toLowerCase())) {
          return int.parse(e.id);
        }
        if (synonyms.any((synonym) =>
            synonym.toString().toLowerCase().trim() ==
            altTitle.toLowerCase())) {
          return int.parse(e.id);
        }
      }
    }
    return null;
  }

  Future<KitsuEpisodeData?> getKitsuEpisodeDataFromMalId(int malId) async {
    var response = await http.post(Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'query': '''
        query Query {
          lookupMapping(externalId: $malId, externalSite: MYANIMELIST_ANIME) {
            __typename
            ... on Anime {
              episodes(first: 2000) {
                nodes {
                  number
                  titles {
                    canonical
                  }
                  description
                  thumbnail {
                    original {
                      url
                    }
                  }
                }
              }
            }
          }
        }
      ''',
        }));
    var rJson = jsonDecode(response.body);
    if (rJson['data'] == null) {
      return null;
    }
    try {
      var kitsuEpisodeDataJson =
          KitsuEpisodeData.fromJson(rJson['data']['lookupMapping']['episodes']);
      return kitsuEpisodeDataJson;
    } catch (e) {
      debugPrint('Kitsu: $e');
      return null;
    }
  }
}
