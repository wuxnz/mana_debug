import 'dart:convert';
import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/formatters/time_formatters.dart';
import 'package:mana_debug/app/core/utils/network/cloudflare_client.dart';
import 'package:mana_debug/app/core/utils/network/interceptor_client.dart';
import 'package:mana_debug/app/core/values/regex_patterns.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

class FMoviesSource {
  static const String _baseUrl = "https://fmovies.to";
  static final BaseSourceModel _source = BaseSourceModel(
    id: "fmovies",
    type: SourceType.movie,
    sourceName: "FMovies",
    baseUrl: _baseUrl,
  );
  static final _cloudFlareClient = CloudFlareClient();
  static final _interceptorClient = InterceptorClient();
  static RegExp episodeListUrlRegex = RegExp(r"ajax/episode/list/");
  static RegExp serverListUrlRegex = RegExp(r"(ajax/server/list/.*\?vrf=.*)");
  static RegExp serverRequestUrlRegex = RegExp(r"(ajax/server/\\d+\?vrf=.*)");
  static RegExp vrfRegex = RegExp(r"vrf=(.*)");

  BaseItemModel parseRegularItem(Bs4Element item) {
    var id = item.find('a')!.attributes['href']!.trim();
    var title = item.find('.meta > a')!.text.trim();
    var imageUrl = item.find('img')?.attributes['src']?.trim() ??
        item.find('img')!.attributes['data-src']!.trim();
    var languages = <LanguageType>[];
    return BaseItemModel(
      source: _source,
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
    );
  }

  Future<BaseCategoryModel> scrapeSearch(String query) async {
    var response = await _cloudFlareClient
        .get("$_baseUrl/filter?keyword=$query", sleepSeconds: 8);
    var soup = BeautifulSoup(response.data);
    var results = soup.findAll('.movies > .item');
    var animeList = <BaseItemModel>[];
    for (var result in results) {
      animeList.add(parseRegularItem(result));
    }
    return BaseCategoryModel(
      categoryName: 'FMovies',
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

  BaseItemModel parseHomeScreenListItem(Bs4Element item) {
    var id = item.attributes['href']!.trim();
    var title = item.find('.name')!.text.trim();
    var imageUrl = item.find('img')?.attributes['src']?.trim() ??
        item.find('img')!.attributes['data-src']!.trim();
    var languages = <LanguageType>[];
    return BaseItemModel(
      source: _source,
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
    );
  }

  BaseCategoryModel _parseHomeCategory(Bs4Element category, int index) {
    String categoryName = "";
    switch (index) {
      case 0:
        categoryName = "Top Today";
        break;
      case 1:
        categoryName = "Top Week";
        break;
      case 2:
        categoryName = "Top Month";
        break;
      case 3:
        categoryName = "Recently Updated";
        break;
      default:
        categoryName = "Unknown";
    }
    var items = <BaseItemModel>[];
    var itemsList = category.findAll('.item');
    for (var item in itemsList) {
      items.add(parseHomeScreenListItem(item));
    }
    return BaseCategoryModel(
      categoryName: categoryName,
      items: items,
      source: this,
    );
  }

  List<Future<BaseCategoryModel>> getCategories() {
    throw UnimplementedError();
  }

  Future<List<BaseCategoryModel>> scrapeCategories() async {
    var response =
        await _cloudFlareClient.get("$_baseUrl/home", sleepSeconds: 7);
    var soup = BeautifulSoup(response.data);
    var categories = [
      ...soup.findAll(".top9"),
    ];
    var categoriesList = <BaseCategoryModel>[];
    int index = 0;
    for (var category in categories) {
      categoriesList.add(_parseHomeCategory(category, index++));
    }
    return categoriesList;
  }

  Future<List<RawVideoSourceInfoModel>> getVideoSources(String id) async {
    id = "$_baseUrl$id";
    debugPrint("Getting video sources for $id");
    var interceptor = InterceptorClient();
    List<String> matches = await interceptor.get(id, [serverListUrlRegex]);
    List<RawVideoSourceInfoModel> sources = [];

    return sources;
  }

  Future<BaseDetailedItemModel> scrapeDetails(String id) async {
    var response =
        await _cloudFlareClient.get("$_baseUrl$id/1-1", sleepSeconds: 7);
    var soup = BeautifulSoup(response.data);
    var title = soup.find('h1.name')!.text.trim();
    debugPrint("Title: $title");
    var imageUrl = soup.find('.poster > img')!.attributes['src']!.trim();
    debugPrint("Image: $imageUrl");
    var languages = <LanguageType>[LanguageType.dub];
    var coverImageUrl = bgImageUrlRegExp.firstMatch(response.data)!.group(1)!;
    debugPrint("Cover Image: $coverImageUrl");
    EpisodeCount? episodeCount;
    var genres = <Genre>[];
    for (var genre in soup
        .find('.detail')!
        .findAll('div')[2]
        .findAll('span')[0]
        .findAll('a')) {
      genres.add(Genre(
        name: genre.text.trim(),
        id: genre.attributes['href']!.trim(),
      ));
    }
    debugPrint("Genres: $genres");
    double? rating =
        double.tryParse(soup.findAll('.meta > span')[2].text.trim());
    debugPrint("Rating: $rating");
    ItemType? type = itemTypeFromString(
        soup.find('.detail > div')!.findAll('span')[0].find('a')!.text.trim());
    debugPrint("Type: $type");
    var synopsis = soup
        .findAll('div.description')[0]
        .findAll('div')
        .last
        .text
        .replaceFirst("[less]", '')
        .trim();
    debugPrint("Synopsis: $synopsis");
    DateTime? releaseDate =
        yearStringToDateTime(soup.find('.year')!.text.trim());
    debugPrint("Release Date: $releaseDate");
    var episodes = <DetailedEpisodeModel>[];
    List<String> matchedUrls =
        await _interceptorClient.get("$_baseUrl$id", [episodeListUrlRegex]);
    int altEpisodeCount = 0;
    if (matchedUrls.isNotEmpty) {
      var response = await http.get(Uri.parse(matchedUrls[0]));
      var rJson = jsonDecode(response.body);
      var episodeListSoup = BeautifulSoup(rJson['result']);
      List<Bs4Element> episodeList = episodeListSoup.findAll('li');

      int index = 0;
      for (var episode in episodeList) {
        var episodeId = episode.find('a')!.attributes['href']!;
        var episodeUrl = "$_baseUrl$episodeId";
        var episodeNumber = (index + 1).toString();
        var episodeName = episode.find('a')?.findAll('span').last.text.trim();
        if (episode.find('a')?.attributes['data-ids']?.contains(',') ?? false) {
          altEpisodeCount++;
        }
        episodes.add(DetailedEpisodeModel(
          episodeId: episodeId,
          episodeUrl: episodeUrl,
          episodeNumber: episodeNumber,
          episodeName: episodeName,
        ));
        index++;
      }
    }
    episodeCount = EpisodeCount(
      episodeCount: episodes.length,
      altEpisodeCount: altEpisodeCount,
    );
    if (altEpisodeCount > 0) {
      languages = [LanguageType.sub, LanguageType.dub];
    } else {
      languages = [LanguageType.sub];
    }
    List<BaseItemModel> relatedItems = [];
    var itemsList = soup.find(".top9")!.findAll('.item');
    for (var item in itemsList) {
      relatedItems.add(parseHomeScreenListItem(item));
    }
    return BaseDetailedItemModel(
      source: _source,
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
      coverImageUrl: coverImageUrl,
      episodeCount: episodeCount,
      genres: genres,
      rating: rating,
      type: type,
      synopsis: synopsis,
      releaseDate: releaseDate,
      episodes: episodes,
      relatedItems: relatedItems,
    );
  }
}
