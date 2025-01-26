import 'dart:convert';
import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/helpers/encode_decode.dart';
import 'package:mana_debug/app/core/values/regex_patterns.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../../../services/source_service.dart';

class SoapTodaySource {
  static const String _baseUrl = 'https://soap2day.rs';
  static const String _sourceId = 'soap-today';
  static const SourceType _sourceType = SourceType.movie;
  static const String _sourceName = 'Soap2day';

  BaseItemModel _parseItem(Bs4Element soup) {
    var id = soup.find('a')!.attributes['href']!;
    var title = soup.find('.film-name > a')!.text.trim();
    var imageUrl = soup.find('img')!.attributes['data-src']!;
    var languages = <LanguageType>[LanguageType.dub];
    return BaseItemModel(
      source: BaseSourceModel(
        id: _sourceId,
        type: _sourceType,
        sourceName: _sourceName,
        baseUrl: _baseUrl,
      ),
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
    );
  }

  Future<BaseCategoryModel> scrapeSearch(String query) async {
    var newQuery = encodeURIComponent(query.replaceAll(' ', '-').toLowerCase());
    var response = await http.get(Uri.parse('$_baseUrl/search/$newQuery'));
    var soup = BeautifulSoup(response.body);
    var results = soup.findAll('div.flw-item');
    var animeList = <BaseItemModel>[];
    for (var result in results) {
      animeList.add(_parseItem(result));
    }
    return BaseCategoryModel(
      categoryName: 'Soap2day',
      items: animeList,
      source: this,
    );
  }

  Future<BaseCategoryModel> getItemsForSlider() async {
    const List<String> alphaWithoutVowels = [
      "b",
      "c",
      "d",
      "f",
      "g",
      "h",
      "j",
      "k",
      "l",
      "m",
      "n",
      "p",
      "q",
      "r",
      "s",
      "t",
      "v",
      "w",
      "x",
      "y",
      "z"
    ];
    const List<String> vowels = ["a", "e", "i", "o", "u"];
    String randomString = alphaWithoutVowels[Random().nextInt(21)];
    final BaseCategoryModel animeList = await scrapeSearch(randomString);
    if (animeList.items.length < 5) {
      while (animeList.items.length < 5) {
        randomString =
            "${vowels[Random().nextInt(5)]}${alphaWithoutVowels[Random().nextInt(21)]}${vowels[Random().nextInt(5)]}";
        var searchResults = await scrapeSearch(randomString);
        animeList.items.addAll(searchResults.items);
      }
    }
    animeList.items.shuffle();
    return BaseCategoryModel(
        categoryName: "Random", items: animeList.items, source: this);
  }

  Future<BaseCategoryModel> parseHomeScreenCategory(Bs4Element soup) {
    String categoryName = soup.find('h2.cat-heading')!.text.trim();
    var items = <BaseItemModel>[];
    var results = soup.findAll('div.flw-item');
    for (var result in results) {
      try {
        items.add(_parseItem(result));
      } catch (e) {
        // debugPrint(e.toString());
      }
    }
    return Future.value(BaseCategoryModel(
      categoryName: categoryName,
      items: items,
      source: this,
    ));
  }

  List<Future<BaseCategoryModel>> getCategories(Bs4Element soup) => [];

  Future<List<BaseCategoryModel>> scrapeCategories() async {
    var response = await http.get(Uri.parse('$_baseUrl/home'));
    var soup = BeautifulSoup(response.body);
    var categories = soup.findAll('section.block_area_home');
    var categoryList = <BaseCategoryModel>[];
    for (var category in categories) {
      try {
        categoryList.add(await parseHomeScreenCategory(category));
      } catch (e) {
        // debugPrint(e.toString());
      }
    }
    return categoryList;
  }

  Future<List<RawVideoSourceInfoModel>> getVideoSources(
      String episodeId) async {
    var response = await http.get(Uri.parse(episodeId));
    var soup = BeautifulSoup(response.body);
    var sourcesRaw = soup.findAll('.nav-item > a');
    var sources = <RawVideoSourceInfoModel>[];
    for (var source in sourcesRaw) {
      var sourceDataId =
          source.attributes['data-linkid'] ?? source.attributes['data-id'];
      var sourceResponse =
          await http.get(Uri.parse("$_baseUrl/ajax/sources/$sourceDataId"));
      var sourceJson = jsonDecode(sourceResponse.body);
      var embedUrl = sourceJson['link'];
      var sourceId = source.find('span')!.text.trim().toLowerCase();
      var sourceName = source.find('span')!.text.trim();
      var baseUrl = Uri.parse(embedUrl).origin;
      var extractor = SourceService().detectExtractor(sourceId);
      sources.add(RawVideoSourceInfoModel(
        embedUrl: embedUrl,
        sourceId: sourceId,
        sourceName: sourceName,
        baseUrl: baseUrl,
        extractor: extractor,
      ));
    }
    return sources;
  }

  Future<BaseDetailedItemModel> scrapeDetails(String id) async {
    var response = await http.get(Uri.parse('$_baseUrl$id'));
    var soup = BeautifulSoup(response.body);
    var baseInfo = soup.findAll('div.dpe-content');
    var title = baseInfo[0].find('strong')!.text.trim();
    // debugPrint("Title: $title");
    var imageUrl = soup.find('.mb-2 > img')!.attributes['src']!;
    // debugPrint("Image: $imageUrl");
    var languages = <LanguageType>[LanguageType.dub];

    EpisodeCount? episodeCount;
    List<Genre> genres = [];
    for (var genre in baseInfo[3].findAll('a')) {
      genres.add(Genre(id: genre.attributes['href'], name: genre.text.trim()));
    }
    // debugPrint("Genres: $genres");
    String itemDataId = id.split('-').last;

    ItemType itemType = id.contains('/tv/') ? ItemType.tv : ItemType.movie;

    var synopsis = soup
        .find('section.section-description > div.bah-content > p')!
        .text
        .trim();
    // debugPrint("Synopsis: $synopsis");
    var releaseDate = DateTime.parse(
      baseInfo[2].find('a')!.text.trim(),
    );
    // debugPrint("Release Date: $releaseDate");
    var episodes = <DetailedEpisodeModel>[];
    if (itemType == ItemType.tv) {
      var seasonResponse = await http.get(
        Uri.parse('$_baseUrl/ajax/v2/tv/seasons/$itemDataId'),
      );
      var seasonSoup = BeautifulSoup(seasonResponse.body);
      var seasonsListRaw = seasonSoup.findAll('.dropdown-menu > a');
      int seasonNumber = 1;
      int episodeNumber = 1;
      int relativeEpisodeNumber = 1;
      for (var season in seasonsListRaw) {
        var seasonId = season.attributes['data-id']!;
        var seasonName = season.text.trim();
        var seasonResponse = await http.get(
          Uri.parse('$_baseUrl/ajax/v2/season/episodes/$seasonId'),
        );
        var seasonSoup = BeautifulSoup(seasonResponse.body);
        var episodesListRaw = seasonSoup.findAll('ul > li > a');
        for (var episode in episodesListRaw) {
          var episodeId =
              "$_baseUrl/ajax/v2/episode/servers/${episode.attributes['data-id']!}";
          var episodeMatch =
              soap2dayEpsNameRegExp.firstMatch(episode.text.trim())!;
          var episodeName = episodeMatch.group(2)!;
          var episodeUrl = episodeId;
          var languageType = LanguageType.dub;
          episodes.add(DetailedEpisodeModel(
            episodeId: episodeId,
            episodeName: episodeName,
            episodeUrl: episodeUrl,
            languageType: languageType,
            episodeNumber: episodeNumber.toString(),
            seasonNumber: seasonNumber,
            relativeEpisodeNumber: relativeEpisodeNumber,
          ));
          episodeNumber++;
          relativeEpisodeNumber++;
        }
        seasonNumber++;
        relativeEpisodeNumber = 1;
      }
    } else {
      var episodeId = "$_baseUrl/ajax/movie/episodes/$itemDataId";
      var episodeName = title;
      var episodeUrl = episodeId;
      var languageType = LanguageType.dub;
      var episodeNumber = 1;
      episodes.add(DetailedEpisodeModel(
        episodeId: episodeId,
        episodeName: episodeName,
        episodeUrl: episodeUrl,
        languageType: languageType,
        episodeNumber: episodeNumber.toString(),
      ));
    }

    episodeCount = EpisodeCount(
      episodeCount: episodes.length,
      altEpisodeCount: 0,
    );

    List<BaseRelatedVideosModel> relatedVideos = [];
    relatedVideos.add(BaseRelatedVideosModel(
      videoId:
          soup.find('#iframe-trailer')!.attributes['data-src']!.split('/').last,
      videoUrl: soup.find('#iframe-trailer')!.attributes['data-src']!,
      videoTitle: "$title Trailer",
    ));

    List<BaseItemModel> relatedItems = [];
    for (var relatedItem in soup.findAll("div.film_list-wrap > div.flw-item")) {
      relatedItems.add(_parseItem(relatedItem));
    }
    return BaseDetailedItemModel(
      source: BaseSourceModel(
        id: _sourceId,
        type: _sourceType,
        sourceName: _sourceName,
        baseUrl: _baseUrl,
      ),
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
      episodeCount: episodeCount,
      genres: genres,
      type: itemType,
      synopsis: synopsis,
      releaseDate: releaseDate,
      episodes: episodes,
      relatedVideos: relatedVideos,
      relatedItems: relatedItems,
    );
  }
}
