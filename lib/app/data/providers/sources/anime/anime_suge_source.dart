import 'dart:convert';
import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/helpers/encode_decode.dart';
import 'package:mana_debug/app/core/utils/network/cloudflare_client.dart';
import 'package:mana_debug/app/core/utils/network/interceptor_client.dart';
import 'package:mana_debug/app/core/values/constants.dart';
import 'package:mana_debug/app/data/models/services/external_helper_services_models/ani_skip.dart';

import '../../../../core/utils/formatters/time_formatters.dart';
import '../../../models/sources/base_model.dart';
import '../../../services/source_service.dart';

class AnimeSugeSource {
  String baseUrl = 'https://animesuge.to';
  static RegExp episodeListUrlRegex =
      RegExp(r"(ajax/episode/list/\d+\?vrf=.*)");
  static RegExp serverListUrlRegex = RegExp(r"(ajax/server/list/.*\?vrf=.*)");
  static RegExp serverRequestUrlRegex = RegExp(r"(ajax/server/.*\?vrf=.*)");
  static RegExp vrfRegex = RegExp(r"vrf=(.*)");
  static final _cloudFlareClient = CloudFlareClient();
  static CookieManager _cookieManager = CookieManager.instance();

  // AnimeSugeSource() {
  //   init();
  // }

  // Future<void> init() async {
  //   // var cookies = await _cookieManager.getCookies(url: Uri.parse(baseUrl));
  //   // if (cookies.isEmpty) {
  //   //   await _cloudFlareClient.get(baseUrl, sleepSeconds: 5);
  //   // }
  //   await _cloudFlareClient.get(baseUrl, sleepSeconds: 3);
  // }

  BaseItemModel _parseRegItem(Bs4Element item) {
    var id = item.find('a')!.attributes['href']!.trim();
    var title = item.find('.name > a')!.text.trim();
    var imageUrl = item.find('img')!.attributes['data-src'] ??
        item.find('img')!.attributes['src']!;
    List<LanguageType> languages = [];
    int subEps = 0;
    var subStatus = item.find('.dub-sub-total > .sub') != null;
    int dubEps = 0;
    var dubStatus = item.find('.dub-sub-total > .dub') != null;
    if (subStatus) {
      languages.add(LanguageType.sub);
      try {
        subEps = int.parse(item.find('.dub-sub-total > .sub')!.text.trim());
      } catch (e) {
        subEps = 0;
      }
    }
    if (dubStatus) {
      languages.add(LanguageType.dub);
      try {
        dubEps = int.parse(item.find('.dub-sub-total > .dub')!.text.trim());
      } catch (e) {
        dubEps = 0;
      }
    }
    EpisodeCount episodeCount = EpisodeCount(
      episodeCount: subEps != 0 ? subEps : dubEps,
      altEpisodeCount: subEps != 0 ? dubEps : 0,
    );
    var anime = BaseItemModel(
      source: BaseSourceModel(
        id: "anime-suge",
        type: SourceType.anime,
        sourceName: "AnimeSuge",
        baseUrl: baseUrl,
      ),
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
      episodeCount: episodeCount,
    );
    return anime;
  }

  Future<BaseCategoryModel> _parseRegCategory(
      List<Bs4Element> items, String categoryName) {
    List<BaseItemModel> parsedItems = [];
    for (var item in items) {
      parsedItems.add(_parseRegItem(item));
    }
    return Future.value(
      BaseCategoryModel(
        categoryName: categoryName,
        source: this,
        items: parsedItems,
      ),
    );
  }

  Future<BaseCategoryModel> scrapeSearch(String query, {int page = 1}) async {
    try {
      // await init();
      var response = await http.get(
          Uri.parse('$baseUrl/filter?keyword=${encodeURIComponent(query)}'));
      var soup = BeautifulSoup(response.body);
      var results = soup.findAll('.original .item');
      return _parseRegCategory(results, "AnimeSuge");
    } catch (e) {
      debugPrint(e.toString());
      return BaseCategoryModel(
        categoryName: 'AnimeSuge',
        source: this,
        items: [],
      );
    }
  }

  Future<BaseCategoryModel> getItemsForSlider() async {
    const List<String> allAlpha = [
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
      "r",
      "s",
      "t",
      "u",
      "v",
      "w",
      "x",
      "y",
      "z"
    ];
    String randomLetter = allAlpha[Random().nextInt(26)];
    final BaseCategoryModel animeList = await scrapeSearch(randomLetter);
    if (animeList.items.length < 5) {
      while (animeList.items.length < 5) {
        randomLetter = allAlpha[Random().nextInt(26)];
        var searchResults = await scrapeSearch(randomLetter);
        animeList.items.addAll(searchResults.items);
      }
    }
    animeList.items.shuffle();
    return BaseCategoryModel(
        categoryName: "Random", items: animeList.items, source: this);
  }

  Future<BaseCategoryModel> scrapeTopCategory(Bs4Element soup) async {
    var categoryName = soup.find('h2.title')!.text.trim();
    var categoryItems = soup.findAll('ul.itemlist > li');
    List<BaseItemModel> items = [];
    for (var item in categoryItems) {
      var id = item.find('a')!.attributes['href']!;
      var title = item.find('h3 > a')!.text.trim();
      var imageUrl = item.find('img')!.attributes['src']!;
      List<LanguageType> languages = [];
      int subEps = 0;
      var subStatus = item.find('.meta > .ep-status-wrap > span.sub') != null;
      int dubEps = 0;
      var dubStatus = item.find('.meta > .ep-status-wrap > span.dub') != null;
      if (subStatus) {
        languages.add(LanguageType.sub);
        try {
          subEps = int.parse(item
              .find('.meta > .ep-status-wrap > span.sub > span')!
              .text
              .trim());
        } catch (e) {
          subEps = 0;
        }
      }
      if (dubStatus) {
        languages.add(LanguageType.dub);
        try {
          dubEps = int.parse(item
              .find('.meta > .ep-status-wrap > span.dub > span')!
              .text
              .trim());
        } catch (e) {
          dubEps = 0;
        }
      }
      EpisodeCount episodeCount = EpisodeCount(
        episodeCount: subEps != 0 ? subEps : dubEps,
        altEpisodeCount: subEps != 0 ? dubEps : 0,
      );
      var anime = BaseItemModel(
        source: BaseSourceModel(
          id: "anime-suge",
          type: SourceType.anime,
          sourceName: "AnimeSuge",
          baseUrl: baseUrl,
        ),
        id: id,
        title: title,
        imageUrl: imageUrl,
        languages: languages,
        episodeCount: episodeCount,
      );
      items.add(anime);
    }
    return BaseCategoryModel(
      categoryName: categoryName,
      source: this,
      items: items,
    );
  }

  Future<BaseCategoryModel> scrapeRegBottomCategory(Bs4Element soup) async {
    var categoryName = soup.find('.heading > h2')!.text.trim();
    var categoryItems = soup.findAll('a.item');
    List<BaseItemModel> items = [];
    for (var item in categoryItems) {
      var id = item.attributes['href']!;
      var title = item.find('p.name')!.text.trim();
      var imageUrl = item.find('.poster img')!.attributes['data-src'] ??
          item.find('.poster img')!.attributes['src']!;
      List<LanguageType> languages = [];
      int subEps = 0;
      var subStatus = item.find('.dub-sub-total > .sub') != null;
      int dubEps = 0;
      var dubStatus = item.find('.dub-sub-total > .dub') != null;
      if (subStatus) {
        languages.add(LanguageType.sub);
        try {
          subEps = int.parse(item.find('.dub-sub-total > .sub')!.text.trim());
        } catch (e) {
          subEps = 0;
        }
      }
      if (dubStatus) {
        languages.add(LanguageType.dub);
        try {
          dubEps = int.parse(item.find('.dub-sub-total > .dub')!.text.trim());
        } catch (e) {
          dubEps = 0;
        }
      }
      EpisodeCount episodeCount = EpisodeCount(
        episodeCount: subEps != 0 ? subEps : dubEps,
        altEpisodeCount: subEps != 0 ? dubEps : 0,
      );
      var anime = BaseItemModel(
        source: BaseSourceModel(
          id: "anime-suge",
          type: SourceType.anime,
          sourceName: "AnimeSuge",
          baseUrl: baseUrl,
        ),
        id: id,
        title: title,
        imageUrl: imageUrl,
        languages: languages,
        episodeCount: episodeCount,
      );
      items.add(anime);
    }
    return BaseCategoryModel(
      categoryName: categoryName,
      source: this,
      items: items,
    );
  }

  Future<BaseCategoryModel> scrapeOthBottomCategory(Bs4Element soup) {
    var categoryName = soup.find('.heading > h2')!.text.trim();
    var categoryItems = soup.findAll('a.item');
    List<BaseItemModel> items = [];
    for (var item in categoryItems) {
      var id = item.attributes['href']!;
      var title = item.find('p.name')!.text.trim();
      var imageUrl = item.find('.poster img')!.attributes['data-src'] ??
          item.find('.poster img')!.attributes['src']!;
      List<LanguageType> languages = [];
      int subEps = 0;
      var subStatus = item.find('.dub-sub-total > .sub') != null;
      int dubEps = 0;
      var dubStatus = item.find('.dub-sub-total > .dub') != null;
      if (subStatus) {
        languages.add(LanguageType.sub);
        try {
          subEps = int.parse(item.find('.dub-sub-total > .sub')!.text.trim());
        } catch (e) {
          subEps = 0;
        }
      }
      if (dubStatus) {
        languages.add(LanguageType.dub);
        try {
          dubEps = int.parse(item.find('.dub-sub-total > .dub')!.text.trim());
        } catch (e) {
          dubEps = 0;
        }
      }
      EpisodeCount episodeCount = EpisodeCount(
        episodeCount: subEps != 0 ? subEps : dubEps,
        altEpisodeCount: subEps != 0 ? dubEps : 0,
      );
      var anime = BaseItemModel(
        source: BaseSourceModel(
          id: "anime-suge",
          type: SourceType.anime,
          sourceName: "AnimeSuge",
          baseUrl: baseUrl,
        ),
        id: id,
        title: title,
        imageUrl: imageUrl,
        languages: languages,
        episodeCount: episodeCount,
      );
      items.add(anime);
    }
    return Future.value(BaseCategoryModel(
      categoryName: categoryName,
      source: this,
      items: items,
    ));
  }

  List<Future<BaseCategoryModel>> getCategories(
      List<Bs4Element> topCategorySoup,
      List<Bs4Element> regBottomCategoriesSoup,
      Bs4Element othBottomCategorySoup) {
    List<Future<BaseCategoryModel>> categories = [];
    categories.add(_parseRegCategory(topCategorySoup, "Recently Updated"));
    for (var category in regBottomCategoriesSoup) {
      try {
        categories.add(scrapeRegBottomCategory(category));
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    categories.add(scrapeRegBottomCategory(othBottomCategorySoup));
    return categories;
  }

  Future<List<BaseCategoryModel>?> scrapeCategories() async {
    // await init();
    // var response = await _cloudFlareClient.get("$baseUrl/home");
    var response = await http.get(Uri.parse("$baseUrl/home"));
    debugPrint(response.statusCode.toString());
    var soup = BeautifulSoup(response.body);
    // var topCategory = soup.find('section#recent-update')!;
    var topCategory = soup.findAll('.original .item');
    // debugPrint(topCategory.toString());
    var bottomCategories = soup.findAll('div.hot-stat > section');
    var regBottomCategories = [bottomCategories[0], bottomCategories[2]];
    // debugPrint(regBottomCategories.length.toString());
    var othBottomCategory = bottomCategories[1];
    // debugPrint(othBottomCategory.toString());
    var results = await Future.wait(
        getCategories(topCategory, regBottomCategories, othBottomCategory));
    return results;
  }

  Future<List<RawVideoSourceInfoModel>> getVideoSources(String id) async {
    id = "$baseUrl$id";
    // await init();
    var interceptor = InterceptorClient();
    List<String> matches = await interceptor.get(id, [serverListUrlRegex]);
    var serverListUrl = matches
            .firstWhere((element) => element.contains(serverListUrlRegex))
            .startsWith("http")
        ? matches.firstWhere((element) => element.contains(serverListUrlRegex))
        : matches
                .firstWhere((element) => element.contains(serverListUrlRegex))
                .startsWith("/")
            ? "$baseUrl${matches.firstWhere((element) => element.contains(serverListUrlRegex))}"
            : "$baseUrl/${matches.firstWhere((element) => element.contains(serverListUrlRegex))}";

    // var serverListResponse =
    //     await _cloudFlareClient.get(serverListUrl, sleepSeconds: 5);

    var serverListResponse = await http.get(Uri.parse(serverListUrl));
    debugPrint("serverListResponse: ${serverListResponse.statusCode}");
    debugPrint("serverListResponse: ${serverListResponse.body}");
    // var soup = BeautifulSoup(serverListResponse.body);
    // var serverList = jsonDecode(soup.text);
    var serverList = jsonDecode(serverListResponse.body);
    var serverListSoup = BeautifulSoup(serverList['result']);
    debugPrint("serverListSoup: ${serverListSoup.toString()}");
    var subServers = serverListSoup.find('div',
            attrs: {'data-type': 'sub'})?.findAll('.server-list > div') ??
        [];
    debugPrint("subServers: ${subServers.length.toString()}");
    var dubServers = serverListSoup.find('div',
            attrs: {'data-type': 'dub'})?.findAll('.server-list > div') ??
        [];
    debugPrint("dubServers: ${dubServers.length.toString()}");
    List<RawVideoSourceInfoModel> sources = [];
    for (var subServer in subServers) {
      var serverId = subServer.attributes['data-link-id']!;
      var serverRequestVrfResponse = await http
          .get(Uri.parse("$nineAnimeConsumet?query=$serverId&action=vrf"));
      var vrfJson = jsonDecode(serverRequestVrfResponse.body);
      var serverRequestVrf = vrfJson['url'];
      var serverName = subServer.text.trim();
      var subServerUrl = "$baseUrl/ajax/server/$serverId?vrf=$serverRequestVrf";
      // var subServerResponse = await _cloudFlareClient.get(subServerUrl);
      var subServerResponse = await http.get(Uri.parse(subServerUrl));
      // var sSoup = BeautifulSoup(subServerResponse.data);
      var sSoup = BeautifulSoup(subServerResponse.body);
      var sJson = jsonDecode(sSoup.text);
      var subServerEncUrl = sJson['result']['url'];
      var subServerEncSkipData = sJson['result']['skip_data'];
      String? embedUrl;
      AniSkipSkipData? opSkipData;
      AniSkipSkipData? edSkipData;
      if (subServerEncUrl != null && subServerEncUrl != "") {
        var subServerDecResponse = await http.get(
          Uri.parse("$nineAnimeConsumet?query=$subServerEncUrl&action=decrypt"),
        );
        var ssJson = jsonDecode(subServerDecResponse.body);
        embedUrl = ssJson['url'];
      }
      if (subServerEncSkipData != null && subServerEncSkipData != "") {
        var subServerDecResponse = await http.get(
          Uri.parse(
              "$nineAnimeConsumet?query=$subServerEncSkipData&action=decrypt"),
        );
        var ssJson = jsonDecode(subServerDecResponse.body);
        var skipData = jsonDecode(ssJson['url']);
        opSkipData = AniSkipSkipData(
          startTime: double.parse(skipData['intro'][0].toString()),
          endTime: double.parse(skipData['intro'][1].toString()),
        );
        edSkipData = AniSkipSkipData(
          startTime: double.parse(skipData['outro'][0].toString()),
          endTime: double.parse(skipData['outro'][1].toString()),
        );
      }
      if (serverName.toLowerCase() == "vidstream") {
        serverName = "VizCloud";
      }
      sources.add(RawVideoSourceInfoModel(
        sourceId: serverName.toLowerCase(),
        sourceName: serverName,
        baseUrl: Uri.tryParse(embedUrl ?? "fail")!.origin,
        embedUrl: embedUrl,
        language: LanguageType.sub,
        extractor: SourceService().detectExtractor(serverName.toLowerCase()),
        opSkipData: opSkipData,
        edSkipData: edSkipData,
      ));
    }
    for (var dubServer in dubServers) {
      var serverId = dubServer.attributes['data-link-id']!;
      var serverRequestVrfResponse = await http
          .get(Uri.parse("$nineAnimeConsumet?query=$serverId&action=vrf"));
      var vrfJson = jsonDecode(serverRequestVrfResponse.body);
      var serverRequestVrf = vrfJson['url'];
      var serverName = dubServer.text.trim();
      var dubServerUrl = "$baseUrl/ajax/server/$serverId?vrf=$serverRequestVrf";
      // var dubServerResponse = await _cloudFlareClient.get(dubServerUrl);
      var dubServerResponse = await http.get(Uri.parse(dubServerUrl));
      // var sSoup = BeautifulSoup(dubServerResponse.data);
      var sSoup = BeautifulSoup(dubServerResponse.body);
      var sJson = jsonDecode(sSoup.text);
      var dubServerEncUrl = sJson['result']['url'];
      var dubServerEncSkipData = sJson['result']['skip_data'];
      String? embedUrl;
      AniSkipSkipData? opSkipData;
      AniSkipSkipData? edSkipData;
      if (dubServerEncUrl != null && dubServerEncUrl != "") {
        var dubServerDecResponse = await http.get(
          Uri.parse("$nineAnimeConsumet?query=$dubServerEncUrl&action=decrypt"),
        );
        var ssJson = jsonDecode(dubServerDecResponse.body);
        embedUrl = ssJson['url'];
      }
      if (dubServerEncSkipData != null && dubServerEncSkipData != "") {
        var dubServerDecResponse = await http.get(
          Uri.parse(
              "$nineAnimeConsumet?query=$dubServerEncSkipData&action=decrypt"),
        );
        var ssJson = jsonDecode(dubServerDecResponse.body);
        var skipData = jsonDecode(ssJson['url']);
        opSkipData = AniSkipSkipData(
          startTime: double.parse(skipData['intro'][0].toString()),
          endTime: double.parse(skipData['intro'][1].toString()),
        );
        edSkipData = AniSkipSkipData(
          startTime: double.parse(skipData['outro'][0].toString()),
          endTime: double.parse(skipData['outro'][1].toString()),
        );
      }
      if (serverName.toLowerCase() == "vidstream") {
        serverName = "VizCloud";
      }
      sources.add(RawVideoSourceInfoModel(
        sourceId: serverName.toLowerCase(),
        sourceName: serverName,
        baseUrl: Uri.tryParse(embedUrl ?? "fail")!.origin,
        embedUrl: embedUrl,
        language: LanguageType.dub,
        extractor: SourceService().detectExtractor(serverName.toLowerCase()),
        opSkipData: opSkipData,
        edSkipData: edSkipData,
      ));
    }

    return sources;
  }

  Future<BaseDetailedItemModel> scrapeDetails(String id) async {
    // await init();
    // var response = await _cloudFlareClient.get("$baseUrl$id/ep-1");
    var response = await http.get(Uri.parse("$baseUrl$id/ep-1"));
    // var soup = BeautifulSoup(response.data);
    var soup = BeautifulSoup(response.body);
    var title = soup.find('h1.title')!.text.trim();
    var imageUrl = soup.find('div.poster > div > img')!.attributes['src']!;
    var languages = <LanguageType>[];
    EpisodeCount? episodeCount;
    var genres = <Genre>[];
    try {
      for (var genre in soup
          .find('.data')!
          .findAll('div')[0]
          .findAll('div')
          .last
          .findAll('span > a')) {
        genres.add(Genre(
          id: genre.attributes['href']!,
          name: genre.text.trim(),
        ));
      }
    } catch (e) {
      for (var genre in soup
          .find('.data')!
          .findAll('div')[0]
          .findAll('div')
          .last
          .findAll('span > a')) {
        genres.add(Genre(
          id: genre.attributes['href']!,
          name: genre.text.trim(),
        ));
      }
    }
    double? rating = double.tryParse(soup
            .find('.data')
            ?.findAll('div')[0]
            .findAll('div')[5]
            .find('span')
            ?.text
            .split('by')[0]
            .trim() ??
        'fail');
    var type = itemTypeFromString(
        soup.find('.data > div > div > span > a')?.text.trim() ?? 'unknown');
    AiringStatus? status;
    try {
      status = soup
                  .findAll('.data > div')[0]
                  .findAll('div')
                  .firstWhere((element) => element.text.contains('Status'))
                  .find('span')!
                  .text
                  .trim() ==
              'Releasing'
          ? AiringStatus.airing
          : AiringStatus.completed;
    } catch (e) {
      status = AiringStatus.unknown;
    }
    var synopsis = soup
        .findAll('.description > div')
        .last
        .text
        .replaceAll('\n', '')
        .trim();
    DateTime? releaseDate;
    try {
      releaseDate = yearStringToDateTime(soup
          .findAll('.data > div')[0]
          .findAll('div')
          .firstWhere((element) => element.text.contains('Premiered'))
          .find('span > a')!
          .text
          .trim()
          .split(' ')[1]);
    } catch (e) {
      releaseDate = null;
    }
    DateTime? endDate;
    try {
      endDate = yearStringToDateTime(soup
          .findAll('.data > div')[0]
          .findAll('div')[3]
          .find('span')!
          .text
          .trim()
          .split(' ')
          .last);
    } catch (e) {
      endDate = null;
    }
    List<DetailedEpisodeModel> episodes = [];
    var interceptor = InterceptorClient();
    List<String> matchedUrls =
        await interceptor.get("$baseUrl$id", [episodeListUrlRegex]);
    int altEpisodeCount = 0;
    if (matchedUrls.isNotEmpty) {
      // var response = await _cloudFlareClient
      //     .get(matchedUrls[0], sleepSeconds: 3, headers: {
      var response = await http.get(Uri.parse(matchedUrls[0]), headers: {
        'Referer': '$baseUrl/',
        // 'User-Agent':
        //     'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0',
        'X-Requested-With': 'XMLHttpRequest'
      });
      // debugPrint("Episode List Response: ${response.data}");
      // var soup = BeautifulSoup(response.data);
      // var rJson = jsonDecode(soup.text);
      var rJson = jsonDecode(response.body);
      var episodeListSoup = BeautifulSoup(rJson['result']);
      List<Bs4Element> episodeList = episodeListSoup.findAll('.range-wrap a');

      int index = 0;
      for (var episode in episodeList) {
        var episodeId = "$id/ep-${episode.attributes['data-num']}";
        var episodeUrl = "$baseUrl$episodeId";
        var episodeNumber = episode.text.trim();
        if (episode.attributes['data-ids']!.contains(',')) {
          altEpisodeCount++;
        }
        episodes.add(DetailedEpisodeModel(
          episodeId: episodeId,
          episodeUrl: episodeUrl,
          episodeNumber: episodeNumber,
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
    for (var item in soup
        .findAll("section.related a.item")
        .sublist(0, min(20, soup.findAll("section.related a.item").length))) {
      relatedItems.add(BaseItemModel(
        source: BaseSourceModel(
          id: "anime-suge",
          type: SourceType.anime,
          sourceName: "AnimeSuge",
          baseUrl: baseUrl,
        ),
        id: item.attributes['href']!.trim(),
        title: item.find('p.name')!.text.trim(),
        imageUrl: item.find('div.poster > div > img')!.attributes['src']!,
        languages: [],
        episodeCount: EpisodeCount(
          episodeCount: int.tryParse(item
                  .findAll(".meta span.dot")
                  .last
                  .text
                  .trim()
                  .split(" ")
                  .first) ??
              0,
          altEpisodeCount: 0,
        ),
      ));
    }
    return BaseDetailedItemModel(
      source: BaseSourceModel(
        id: "anime-suge",
        type: SourceType.anime,
        sourceName: "AnimeSuge",
        baseUrl: baseUrl,
      ),
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
      endDate: endDate,
      episodes: episodes,
      relatedItems: relatedItems,
    );
  }
}
