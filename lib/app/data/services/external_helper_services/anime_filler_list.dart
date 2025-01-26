import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/helpers/encode_decode.dart';
import 'package:mana_debug/app/data/models/services/external_helper_services_models/anime_filler_list.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

class AnimeFillerListService {
  static const String _baseUrl = 'https://www.animefillerlist.com';

  Future<List<AnimeFillerListData>?> getAnimeFillerListData(
      String title) async {
    var response = await http
        .get(Uri.parse('$_baseUrl/search/node/${encodeURIComponent(title)}'));
    var soup = BeautifulSoup(response.body);
    var searchResults = soup.findAll('li.search-result > h3 > a');
    var searchResultsList = [];
    for (var e in searchResults) {
      searchResultsList.add(e.text);
    }
    String? matchUrl;
    debugPrint('AnimeFillerList: searchResultsList: $searchResultsList');
    if (searchResultsList.isEmpty) {
      return null;
    } else {
      if (searchResultsList.any((element) =>
          element.toString().toLowerCase() ==
          "${title.toLowerCase()} (definitive filler list)")) {
        var matchedItemIndex = searchResultsList.indexWhere((element) =>
            element.toString().toLowerCase() ==
            "${title.toLowerCase()} (definitive filler list)");
        matchUrl = searchResults[matchedItemIndex].attributes['href'] ?? '';
      } else if (searchResultsList.any((element) =>
          element.toString().toLowerCase() == title.toLowerCase())) {
        var matchedItemIndex = searchResultsList.indexWhere((element) =>
            element.toString().toLowerCase() == title.toLowerCase());
        matchUrl = searchResults[matchedItemIndex].attributes['href'] ?? '';
      }
    }

    if (matchUrl != null) {
      response = await http.get(Uri.parse(matchUrl));
      soup = BeautifulSoup(response.body);
      var fillerList = soup.findAll('.EpisodeList > tbody > tr');
      List<AnimeFillerListData> fillerListData = [];

      for (var episode in fillerList) {
        var fillerListDataItem = AnimeFillerListData(
          episodeNumber: episode
              .find('td.Number')
              ?.text
              .toString()
              .trim()
              .replaceAll(' ', ''),
          episodeTitle:
              episode.find('td.Title > a')?.text.toString().trim() ?? '',
          fillerStatus: episode.attributes['class'] != null &&
                  episode.attributes['class']! != ''
              ? episode.attributes['class']!
                          .toString()
                          .trim()
                          .contains('anime_canon') ||
                      episode.attributes['class']!
                          .toString()
                          .trim()
                          .contains('manga_canon')
                  ? FillerStatus.canon
                  : episode.attributes['class']!
                          .toString()
                          .trim()
                          .contains("mixed_canon/filler")
                      ? FillerStatus.mixed
                      : episode.attributes['class']!
                                  .toString()
                                  .trim()
                                  .contains('anime_filler') ||
                              episode.attributes['class']?.toString().trim() ==
                                  'filler odd' ||
                              episode.attributes['class']?.toString().trim() ==
                                  'filler even'
                          ? FillerStatus.filler
                          : FillerStatus.unknown
              : FillerStatus.unknown,
          airDate: DateTime.parse(
              "${episode.find('td.Date')!.text.toString().trim().replaceAll(' ', '')} 00:00:00.000"),
        );
        fillerListData.add(fillerListDataItem);
      }
      if (fillerListData.isNotEmpty) {
        return fillerListData;
      } else {
        return null;
      }
    }
    return null;
  }
}
