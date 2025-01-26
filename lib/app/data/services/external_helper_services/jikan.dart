import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mana_debug/app/data/models/services/external_helper_services_models/jikan.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

class JikanService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';

  Future<int?> getAnimeMalIdFromSearch(
      String query, List<String> altTitles, ItemType type) async {
    var response = await http.get(Uri.parse('$_baseUrl/anime?q=$query'));
    var rJson = jsonDecode(response.body);
    if (rJson['data'] == null) {
      return null;
    }

    var queryLower = query.toLowerCase();
    List<Datum> jikanSearchResponseJson =
        List<Datum>.from(rJson['data'].map((x) => Datum.fromJson(x)));

    for (var e in jikanSearchResponseJson) {
      if (e.approved == true && e.type == type) {
        if (e.title.toLowerCase().trim() == queryLower) {
          return e.malId;
        }

        if (e.titleEnglish != null) {
          if (e.titleEnglish?.toLowerCase().trim() == queryLower) {
            return e.malId;
          }
        }
        if (e.titleJapanese?.trim() == query) {
          return e.malId;
        }
        var titles = [];

        for (var title in e.titles) {
          titles.add(title.title);
        }

        if (titles.any(
            (title) => title.toString().toLowerCase().trim() == queryLower)) {
          return e.malId;
        }
        var synonyms = [];
        for (var synonym in e.titleSynonyms) {
          synonyms.add(synonym);
        }

        if (synonyms.any((synonym) =>
            synonym.toString().toLowerCase().trim() == queryLower)) {
          return e.malId;
        }
        for (var altTitle in altTitles) {
          if (e.title.toLowerCase().trim() == altTitle.toLowerCase()) {
            return e.malId;
          }
          if (e.titleEnglish != null) {
            if (e.titleEnglish?.toLowerCase().trim() ==
                altTitle.toLowerCase()) {
              return e.malId;
            }
          }
          if (e.titleJapanese?.toLowerCase().trim() == altTitle.toLowerCase()) {
            return e.malId;
          }
          if (titles.any((title) =>
              title.toString().toLowerCase().trim() ==
              altTitle.toLowerCase())) {
            return e.malId;
          }
          if (synonyms.any((synonym) =>
              synonym.toString().toLowerCase().trim() ==
              altTitle.toLowerCase())) {
            return e.malId;
          }
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getFullInfoFromMalId(int malId) async {
    var response = await http.get(Uri.parse('$_baseUrl/anime/$malId/full'));
    var rJson = jsonDecode(response.body);
    return rJson;
  }

  Future<Map<String, dynamic>?> getAnimeCharactersFromMalId(int malId) async {
    var response =
        await http.get(Uri.parse('$_baseUrl/anime/$malId/characters'));
    var rJson = jsonDecode(response.body);
    return rJson;
  }
}
