import 'dart:convert';
import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/formatters/time_formatters.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../../../services/source_service.dart';

class NineAnimeSource {
  static const String _baseUrl = 'https://9animetv.to';
  static final BaseSourceModel _source = BaseSourceModel(
    id: 'nine-anime',
    type: SourceType.anime,
    sourceName: '9Anime',
    baseUrl: _baseUrl,
  );
  static RegExp episodeListUrlRegex = RegExp(r"ajax/episode/list/");
  static RegExp serverListUrlRegex = RegExp(r"(ajax/server/list/.*\?vrf=.*)");
  static RegExp vrfRegex = RegExp(r"vrf=(.*)");

  BaseItemModel parseRegularItem(Bs4Element item) {
    var id = item.find('.film-name > a')!.attributes['href']!.trim();
    var title = item.find('.film-name > a')!.text.trim();
    var imageUrl =
        item.find('img.film-poster-img')!.attributes['data-src']!.trim();
    var languages = <LanguageType>[];
    if (item.find('div.tick-sub') != null) {
      languages.add(LanguageType.sub);
    }
    if (item.find('div.tick-dub') != null) {
      languages.add(LanguageType.dub);
    }
    EpisodeCount? episodeCount;
    episodeCount = EpisodeCount(
      episodeCount: item.find("div.tick-eps") != null
          ? int.parse(item.find("div.tick-eps")!.text.trim().contains("Full")
              ? "1"
              : item
                  .find("div.tick-eps")!
                  .text
                  .trim()
                  .split(" ")[1]
                  .split("/")[0])
          : 0,
      altEpisodeCount: 0,
    );
    return BaseItemModel(
      source: _source,
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
      episodeCount: episodeCount,
    );
  }

  Future<BaseCategoryModel> scrapeSearch(String query, {int page = 1}) async {
    var response = await http.get(Uri.parse('$_baseUrl/search?keyword=$query'));
    var soup = BeautifulSoup(response.body);
    var results = soup.findAll('body .film_list-wrap > .flw-item');
    var items = <BaseItemModel>[];
    for (var item in results) {
      items.add(parseRegularItem(item));
    }
    return BaseCategoryModel(
      categoryName: '9anime',
      items: items,
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

  BaseItemModel _parseHomeItem(Bs4Element item) {
    var id = item.find(".film-name > a")!.attributes["href"]!.trim();
    var title = item.find(".film-name > a")!.text.trim();
    var imageUrl =
        item.find(".film-poster > img")!.attributes["data-src"]!.trim();
    var languages = <LanguageType>[];
    EpisodeCount? episodeCount;
    var count =
        item.find("span.fdi-duration")?.text.trim().split(" ")[1].split("/")[0];
    episodeCount = EpisodeCount(
      episodeCount: count != null && count != "null"
          ? int.parse(
              item.find("span.fdi-duration")!.text.trim().contains("Full")
                  ? "1"
                  : count)
          : 0,
      altEpisodeCount: 0,
    );
    if (episodeCount.episodeCount == 0) {
      episodeCount = null;
    }
    return BaseItemModel(
      source: _source,
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
      episodeCount: episodeCount,
    );
  }

  BaseCategoryModel _parseHomeCategory(Bs4Element category, int index) {
    String categoryName;
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
        categoryName = "Recently Added";
        break;
      default:
        categoryName = "Unknown";
    }
    var items = <BaseItemModel>[];
    var itemsList = category.findAll("ul > li");
    for (var item in itemsList) {
      items.add(_parseHomeItem(item));
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
    var response = await http.get(Uri.parse("$_baseUrl/home"));
    var soup = BeautifulSoup(response.body);
    var categories = [
      ...soup.findAll("body .anime-block-ul"),
    ];
    var categoriesList = <BaseCategoryModel>[];
    int index = 0;
    for (var category in categories) {
      try {
        categoriesList.add(_parseHomeCategory(category, index++));
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return categoriesList;
  }

  Future<List<RawVideoSourceInfoModel>> getVideoSources(String id) async {
    String serverListUrl = "$_baseUrl/ajax/episode/servers?episodeId=$id";
    var serverListResponse = await http.get(Uri.parse(serverListUrl));

    var serverList = jsonDecode(serverListResponse.body);

    var serverListSoup = BeautifulSoup(serverList['html']);
    var subServers =
        serverListSoup.find('div.servers-sub')?.findAll('.server-item') ?? [];
    debugPrint(subServers.length.toString());
    var dubServers =
        serverListSoup.find('div.servers-dub')?.findAll('.server-item') ?? [];
    debugPrint(dubServers.length.toString());
    List<RawVideoSourceInfoModel> sources = [];
    for (var subServer in subServers) {
      var serverId = subServer.attributes['data-id']!;
      var serverName = subServer.text.trim();
      var subServerUrl = "$_baseUrl/ajax/episode/sources?id=$serverId";
      var subServerResponse = await http.get(Uri.parse(subServerUrl), headers: {
        "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0"
      });
      var sJson = jsonDecode(subServerResponse.body);
      var subServerEncUrl = sJson['link'];
      debugPrint(subServerEncUrl);
      if (subServerEncUrl == "" || subServerEncUrl == null) {
        continue;
      }
      if (serverName.toLowerCase() == "vidstreaming") {
        serverName = "Rapid-Cloud";
      }
      sources.add(RawVideoSourceInfoModel(
        sourceId: serverName.toLowerCase(),
        sourceName: serverName,
        baseUrl: Uri.parse(subServerEncUrl).origin,
        embedUrl: subServerEncUrl,
        language: LanguageType.sub,
        extractor: SourceService().detectExtractor(serverName.toLowerCase()),
      ));
    }
    for (var dubServer in dubServers) {
      var serverId = dubServer.attributes['data-id']!;
      var serverName = dubServer.text.trim();
      var subServerUrl = "$_baseUrl/ajax/episode/sources?id=$serverId";
      var subServerResponse = await http.get(Uri.parse(subServerUrl), headers: {
        "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0"
      });
      var sJson = jsonDecode(subServerResponse.body);
      var subServerEncUrl = sJson['link'];
      debugPrint(serverName);
      debugPrint(subServerEncUrl);
      if (subServerEncUrl == "" || subServerEncUrl == null) {
        continue;
      }
      if (serverName.toLowerCase() == "vidstreaming") {
        serverName = "Rapid-Cloud";
      }
      sources.add(RawVideoSourceInfoModel(
        sourceId: serverName.toLowerCase(),
        sourceName: serverName,
        baseUrl: Uri.parse(subServerEncUrl).origin,
        embedUrl: subServerEncUrl,
        language: LanguageType.dub,
        extractor: SourceService().detectExtractor(serverName.toLowerCase()),
      ));
    }

    return sources;
  }

  Future<BaseDetailedItemModel> scrapeDetails(String id) async {
    try {
      var idMeat = id.split("/").last;
      var idMeatNum = idMeat.split("-").last;
      var response = await http.get(Uri.parse("$_baseUrl$id"));
      var soup = BeautifulSoup(response.body);
      var title = soup.find("h2.film-name")!.text.trim();
      debugPrint("Title: $title");
      var imageUrl = soup.find(".anime-poster > div > img")!.attributes["src"]!;
      debugPrint("Image: $imageUrl");
      var languages = <LanguageType>[];
      EpisodeCount? episodeCount;
      var genres = <Genre>[];
      try {
        for (var genre in soup
            .find(".col1")!
            .findAll("div.item")[4]
            .findAll("div")[1]
            .findAll("a")) {
          genres.add(Genre(
            id: genre.attributes["href"]?.trim(),
            name: genre.text.trim(),
          ));
        }
      } catch (e) {
        for (var genre in soup
            .find(".col1")!
            .findAll("div.item")[3]
            .findAll("div")[1]
            .findAll("a")) {
          genres.add(Genre(
            id: genre.attributes["href"]?.trim(),
            name: genre.text.trim(),
          ));
        }
      }
      debugPrint("Genres: $genres");
      double? rating = double.tryParse(soup
          .find(".col2")!
          .findAll("div.item")[0]
          .find("div > span")!
          .text
          .split("by")[0]
          .trim());
      debugPrint("Rating: $rating");
      var type = itemTypeFromString(
        soup
            .find(".col1 > div")!
            .findAll('div')[1]
            .find('a')!
            .text
            .trim()
            .split(" ")
            .first,
      );
      debugPrint("Type: $type");
      var status = soup
                  .find(".col1")!
                  .findAll("div.item")[3]
                  .find("div.item-content > span")!
                  .text
                  .trim() ==
              'Currently Airing'
          ? AiringStatus.airing
          : AiringStatus.completed;
      debugPrint("Status: $status");
      var synopsis = soup
          .find("body .shorting")!
          .text
          .trim()
          .replaceAll('\n', '')
          .replaceAll('\t', '');
      debugPrint("Synopsis: $synopsis");
      DateTime? releaseDate;
      try {
        releaseDate = yearStringToDateTime(soup
            .find(".col2")!
            .findAll("div.item")[1]
            .findAll('div')[1]
            .find("span")!
            .text
            .trim()
            .split(" ")
            .last);
      } catch (e) {
        releaseDate = null;
      }
      debugPrint("Release Date: $releaseDate");
      List<DetailedEpisodeModel> episodes = [];
      List<String>? otherTitles;
      for (var otherTitle in soup.find('div.alias')!.text.trim().split(", ")) {
        if (otherTitle != title) {
          otherTitles ??= [];
          otherTitles.add(otherTitle);
        }
      }
      var epResponse =
          await http.get(Uri.parse("$_baseUrl/ajax/episode/list/$idMeatNum"));
      var rJson = jsonDecode(epResponse.body);
      var episodeListSoup = BeautifulSoup(rJson['html']);
      List<Bs4Element> episodeList = episodeListSoup.findAll('a');
      int index = 0;
      for (var episode in episodeList) {
        var episodeId = episode.attributes['href']!.trim().split('=').last;
        var episodeUrl = "$_baseUrl${episode.attributes['href']!.trim()}";
        var episodeNumber = episode.find('div.order')?.text.trim() ??
            episode.find('a')?.text.trim() ??
            (index + 1).toString();
        var episodeName = episode.attributes['title']?.trim();
        episodes.add(DetailedEpisodeModel(
          episodeId: episodeId,
          episodeUrl: episodeUrl,
          episodeNumber: episodeNumber,
          episodeName: episodeName,
        ));
        index++;
      }
      debugPrint("Episodes: $episodes");
      episodeCount = EpisodeCount(
        episodeCount: episodes.length,
        altEpisodeCount: 0,
      );
      debugPrint("Episode Count: $episodeCount");
      List<BaseItemModel> relatedItems = [];
      var relatedItemsRaw =
          soup.find("div.anime-block-ul > ul.ulclear")!.findAll("li");
      for (var relatedItem in relatedItemsRaw) {
        relatedItems.add(_parseHomeItem(relatedItem));
      }
      return BaseDetailedItemModel(
        source: _source,
        id: id,
        title: title,
        imageUrl: imageUrl,
        languages: languages,
        episodeCount: episodeCount,
        genres: genres,
        rating: rating,
        type: type,
        status: status,
        synopsis: synopsis,
        releaseDate: releaseDate,
        episodes: episodes,
        otherTitles: otherTitles,
        relatedItems: relatedItems,
      );
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Failed to scrape details");
    }
  }
}
