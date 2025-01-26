import 'dart:convert';
import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/extractors/rabbit_stream_extractor.dart';
import 'package:mana_debug/app/core/utils/formatters/time_formatters.dart';
import 'package:mana_debug/app/core/utils/misc/misc_utils.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../../../../core/utils/extractors/streamsb_extractor.dart';
import '../../../../core/utils/extractors/streamtape_extractor.dart';

class ZoroSource {
  static const String _baseUrl = 'https://aniwatch.to';

  ItemType _itemNameToItemType(String itemName) {
    if (itemName.contains('Movie')) {
      return ItemType.movie;
    } else if (itemName.contains('TV')) {
      return ItemType.tv;
    } else if (itemName.contains('OVA')) {
      return ItemType.ova;
    } else if (itemName.contains('ONA')) {
      return ItemType.ona;
    } else if (itemName.contains('Special')) {
      return ItemType.special;
    } else {
      return ItemType.unknown;
    }
  }

  Future<BaseCategoryModel> scrapeSearch(String query, {int page = 1}) async {
    List<BaseItemModel> searchResultItems = [];
    var response = await http.get(Uri.parse("$_baseUrl/search?keyword=$query"));

    var soup = BeautifulSoup(response.body);
    var items = soup.findAll('div.flw-item');

    for (var e in items) {
      try {
        var id = e
            .findAll('div > a')[0]
            .attributes['href']!
            .replaceFirst("/", "")
            .trim();
        var title = e.find('div > h3 > a')!.text.trim();
        var imageUrl = e.findAll('div > img')[0].attributes['data-src']!.trim();
        List<LanguageType> languages = e
            .findAll("div > div > div.tick-item")
            .map((e) => e.className.contains("tick-sub")
                ? LanguageType.sub
                : LanguageType.dub)
            .toList();
        var episodeCount =
            e.findAll("div > div > div.tick-item")[0].text.trim();
        if (episodeCount.contains("/")) {
          episodeCount =
              episodeCount.split("/")[0].replaceFirst("Ep ", "").trim();
        } else if (episodeCount.contains("Full")) {
          episodeCount = "1";
        } else {
          episodeCount = episodeCount.replaceFirst("Ep ", "").trim();
        }
        var item = BaseItemModel(
          source: BaseSourceModel(
            id: "zoro",
            type: SourceType.anime,
            sourceName: "Zoro",
            baseUrl: _baseUrl,
          ),
          id: id,
          title: title,
          imageUrl: imageUrl,
          languages: languages,
          episodeCount: EpisodeCount(
            episodeCount: int.parse(episodeCount),
            altEpisodeCount: 0,
          ),
        );
        searchResultItems.add(item);
      } catch (e) {}
    }
    return BaseCategoryModel(
        categoryName: "Zoro", items: searchResultItems, source: this);
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
    String randomString =
        "${vowels[Random().nextInt(5)]}${alphaWithoutVowels[Random().nextInt(21)]}${vowels[Random().nextInt(5)]}";
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

  Future<BaseCategoryModel> scrapeCategoryOne(http.Response response) async {
    var soup = BeautifulSoup(response.body);
    var categoryOne = soup.findAll('div.anif-block')[0];
    var categoryOneName = categoryOne.find('div.anif-block-header')!.text;
    var categoryOneItems = categoryOne.findAll('div.anif-block-ul > ul > li');

    List<BaseItemModel> categoryOneItemsList = [];

    for (var e in categoryOneItems) {
      try {
        var id = e
            .find('div:nth-child(1) > a:nth-child(1)')!
            .attributes['href']!
            .replaceFirst("/", "")
            .trim();
        String finalId;
        if (id.contains('?')) {
          finalId = id.split('?')[0];
        } else {
          finalId = id;
        }

        var title = e.find('div > h3 > a')!.text.trim();

        var imageUrl =
            e.find('div.film-poster > a > img')!.attributes['data-src']!.trim();

        var languages = <LanguageType>[];
        var episodeSets = e.findAll('div.tick > div.tick-item');
        int subEps = 0;
        int dubEps = 0;
        EpisodeCount? episodeCount;
        for (var e in episodeSets) {
          var languageClassname = e.className;

          if (languageClassname.contains("tick-sub")) {
            languages.add(LanguageType.sub);
            subEps = int.parse(e.text.trim().replaceAll("Ep ", ""));
          } else if (languageClassname.contains("tick-dub")) {
            languages.add(LanguageType.dub);
            dubEps = int.parse(e.text.trim().replaceAll("Ep ", ""));
          }
        }
        episodeCount = EpisodeCount(
          episodeCount: subEps,
          altEpisodeCount: dubEps,
        );

        categoryOneItemsList.add(BaseItemModel(
            source: BaseSourceModel(
              id: "zoro",
              type: SourceType.anime,
              sourceName: "Zoro",
              baseUrl: _baseUrl,
            ),
            id: finalId,
            title: title,
            imageUrl: imageUrl,
            languages: languages,
            episodeCount: episodeCount));
      } catch (e) {}
    }

    return Future.value(BaseCategoryModel(
      categoryName: categoryOneName,
      items: categoryOneItemsList,
      source: this,
    ));
  }

  Future<BaseCategoryModel> scrapeCategoryTwo(http.Response response) async {
    var response = await http.get(Uri.parse("$_baseUrl/home"));
    var soup = BeautifulSoup(response.body);
    var categoryTwo = soup.findAll('div.anif-block')[1];
    var categoryTwoName = categoryTwo.find('div.anif-block-header')!.text;
    var categoryTwoItems = categoryTwo.findAll('div.anif-block-ul > ul > li');

    List<BaseItemModel> categoryTwoItemsList = [];

    for (var e in categoryTwoItems) {
      try {
        var id = e
            .find('div:nth-child(1) > a:nth-child(1)')!
            .attributes['href']!
            .replaceFirst("/", "")
            .trim();
        String finalId;
        if (id.contains('?')) {
          finalId = id.split('?')[0];
        } else {
          finalId = id;
        }

        var title = e.find('div > h3 > a')!.text.trim();

        var imageUrl =
            e.find('div.film-poster > a > img')!.attributes['data-src']!.trim();

        var languages = <LanguageType>[];
        var episodeSets = e.findAll('div.tick > div.tick-item');
        int subEps = 0;
        int dubEps = 0;
        EpisodeCount? episodeCount;
        for (var e in episodeSets) {
          var languageClassname = e.className;

          if (languageClassname.contains("tick-sub")) {
            languages.add(LanguageType.sub);
            subEps = int.parse(e.text.trim().replaceAll("Ep ", ""));
          } else if (languageClassname.contains("tick-dub")) {
            languages.add(LanguageType.dub);
            dubEps = int.parse(e.text.trim().replaceAll("Ep ", ""));
          }
        }
        episodeCount = EpisodeCount(
          episodeCount: subEps,
          altEpisodeCount: dubEps,
        );

        categoryTwoItemsList.add(BaseItemModel(
            source: BaseSourceModel(
              id: "zoro",
              type: SourceType.anime,
              sourceName: "Zoro",
              baseUrl: _baseUrl,
            ),
            id: finalId,
            title: title,
            imageUrl: imageUrl,
            languages: languages,
            episodeCount: episodeCount));
      } catch (e) {}
    }

    return Future.value(BaseCategoryModel(
      categoryName: categoryTwoName,
      items: categoryTwoItemsList,
      source: this,
    ));
  }

  Future<BaseCategoryModel> scrapeCategoryThree(http.Response response) async {
    var soup = BeautifulSoup(response.body);
    var categoryThree = soup.findAll('div.anif-block')[2];
    var categoryThreeName = categoryThree.find('div.anif-block-header')!.text;
    var categoryThreeItems =
        categoryThree.findAll('div.anif-block-ul > ul > li');

    List<BaseItemModel> categoryThreeItemsList = [];

    for (var e in categoryThreeItems) {
      try {
        var id = e
            .find('div:nth-child(1) > a:nth-child(1)')!
            .attributes['href']!
            .replaceFirst("/", "")
            .trim();
        String finalId;
        if (id.contains('?')) {
          finalId = id.split('?')[0];
        } else {
          finalId = id;
        }

        var title = e.find('div > h3 > a')!.text.trim();

        var imageUrl =
            e.find('div.film-poster > a > img')!.attributes['data-src']!.trim();

        var languages = <LanguageType>[];
        var episodeSets = e.findAll('div.tick > div.tick-item');
        int subEps = 0;
        int dubEps = 0;
        EpisodeCount? episodeCount;
        for (var e in episodeSets) {
          var languageClassname = e.className;

          if (languageClassname.contains("tick-sub")) {
            languages.add(LanguageType.sub);
            subEps = int.parse(e.text.trim().replaceAll("Ep ", ""));
          } else if (languageClassname.contains("tick-dub")) {
            languages.add(LanguageType.dub);
            dubEps = int.parse(e.text.trim().replaceAll("Ep ", ""));
          }
        }
        episodeCount = EpisodeCount(
          episodeCount: subEps,
          altEpisodeCount: dubEps,
        );

        categoryThreeItemsList.add(BaseItemModel(
            source: BaseSourceModel(
              id: "zoro",
              type: SourceType.anime,
              sourceName: "Zoro",
              baseUrl: _baseUrl,
            ),
            id: finalId,
            title: title,
            imageUrl: imageUrl,
            languages: languages,
            episodeCount: episodeCount));
      } catch (e) {}
    }

    return Future.value(BaseCategoryModel(
      categoryName: categoryThreeName,
      items: categoryThreeItemsList,
      source: this,
    ));
  }

  Future<BaseCategoryModel> scrapeCategoryFour(http.Response response) async {
    var soup = BeautifulSoup(response.body);
    var categoryFour = soup.findAll('div.anif-block')[3];
    var categoryFourName = categoryFour.find('div.anif-block-header')!.text;
    var categoryFourItems = categoryFour.findAll('div.anif-block-ul > ul > li');

    List<BaseItemModel> categoryFourItemsList = [];

    for (var e in categoryFourItems) {
      try {
        var id = e
            .find('div:nth-child(1) > a:nth-child(1)')!
            .attributes['href']!
            .replaceFirst("/", "")
            .trim();
        String finalId;
        if (id.contains('?')) {
          finalId = id.split('?')[0];
        } else {
          finalId = id;
        }

        var title = e.find('div > h3 > a')!.text.trim();

        var imageUrl =
            e.find('div.film-poster > a > img')!.attributes['data-src']!.trim();

        var languages = <LanguageType>[];
        var episodeSets = e.findAll('div.tick > div.tick-item');
        int subEps = 0;
        int dubEps = 0;
        EpisodeCount? episodeCount;
        for (var e in episodeSets) {
          var languageClassname = e.className;

          if (languageClassname.contains("tick-sub")) {
            languages.add(LanguageType.sub);
            subEps = int.parse(e.text.trim().replaceAll("Ep ", ""));
          } else if (languageClassname.contains("tick-dub")) {
            languages.add(LanguageType.dub);
            dubEps = int.parse(e.text.trim().replaceAll("Ep ", ""));
          }
        }
        episodeCount = EpisodeCount(
          episodeCount: subEps,
          altEpisodeCount: dubEps,
        );

        categoryFourItemsList.add(BaseItemModel(
            source: BaseSourceModel(
              id: "zoro",
              type: SourceType.anime,
              sourceName: "Zoro",
              baseUrl: _baseUrl,
            ),
            id: finalId,
            title: title,
            imageUrl: imageUrl,
            languages: languages,
            episodeCount: episodeCount));
      } catch (e) {}
    }

    return Future.value(BaseCategoryModel(
      categoryName: categoryFourName,
      items: categoryFourItemsList,
      source: this,
    ));
  }

  List<Future<BaseCategoryModel>> getCategories(http.Response response) {
    return [
      scrapeCategoryOne(response),
      scrapeCategoryTwo(response),
      scrapeCategoryThree(response),
      scrapeCategoryFour(response),
    ];
  }

  Future<List<BaseCategoryModel>?> scrapeCategories() async {
    var response = await http.get(Uri.parse("$_baseUrl/home"));
    var categories = getCategories(response);

    var results = await Future.wait(categories);

    return results;
  }

  Future<List<RawVideoSourceInfoModel>> getVideoSources(String id) async {
    var episodeId = id.split('=')[1];
    var response = await http.get(
        Uri.parse("$_baseUrl/ajax/v2/episode/servers?episodeId=$episodeId"));
    var soup = BeautifulSoup(jsonDecode(response.body)['html']);
    var servers = soup.findAll('div.server-item');
    var serversList = [];
    List<String> languages = [];
    for (var server in servers) {
      var langType = server.attributes['data-type'] == 'sub'
          ? LanguageType.sub
          : LanguageType.dub;
      languages.add(languageTypeToString(langType));
      var id = server.attributes['data-id']!;
      var sourceId = server.find('a')!.text.trim().toLowerCase();
      var sourceName = server.find('a')!.text.trim();
      serversList.add({
        'id': id,
        'sourceId': sourceId,
        'sourceName': sourceName,
        'langType': langType,
      });
    }
    languages = removeDuplicates(languages);
    List<RawVideoSourceInfoModel> videoSources = [];
    for (var server in serversList) {
      var response = await http.get(
          Uri.parse("$_baseUrl/ajax/v2/episode/sources?id=${server['id']}"));
      var rJson = jsonDecode(response.body);
      var embedUrl = rJson['link'];
      var language = server['langType'];
      dynamic extractor;
      switch (server['sourceId']) {
        case 'vidstreaming':
          extractor = RabbitStreamExtractor;
          break;
        case 'megacloud':
          extractor = RabbitStreamExtractor;
          break;
        case 'vidcloud':
          extractor = RabbitStreamExtractor;
          break;
        case 'streamsb':
          extractor = StreamSBExtractor;
          embedUrl = embedUrl.replaceAll('.html', '');
          break;
        case 'streamtape':
          extractor = StreamtapeExtractor;
          break;
      }
      videoSources.add(RawVideoSourceInfoModel(
        baseUrl: Uri.parse(embedUrl).origin,
        embedUrl: embedUrl,
        language: language,
        extractor: extractor,
        sourceId: server['sourceId'] == 'vidstreaming'
            // ||
            // server['sourceId'] == 'vidcloud' ||
            // server['sourceId'] == 'megacloud'
            ? 'rapid-cloud'
            : server['sourceId'],
        sourceName: server['sourceName'] == 'Vidstreaming'
            ? 'Zoro'
            : server['sourceName'],
      ));
    }
    return Future.value(videoSources);
  }

  Future<BaseDetailedItemModel> scrapeDetails(String id) async {
    var response = await http.get(Uri.parse("$_baseUrl/$id"));
    var soup = BeautifulSoup(response.body);
    var title = soup.find('h2.film-name')!.text.trim();

    var imageUrl = soup.find('img.film-poster-img')!.attributes['src']!.trim();

    var languages = <LanguageType>[];
    var langsRaw = soup.findAll('.film-stats .tick .tick-item');
    if (langsRaw.any((element) => element.className.contains('tick-sub'))) {
      languages.add(LanguageType.sub);
    } else if (langsRaw
        .any((element) => element.className.contains('tick-dub'))) {
      languages.add(LanguageType.dub);
    }

    EpisodeCount episodeCount = EpisodeCount(
        episodeCount: langsRaw
                .any((element) => element.className.contains('tick-sub'))
            ? int.parse(langsRaw
                .firstWhere((element) => element.className.contains('tick-sub'))
                .text
                .trim())
            : int.parse(langsRaw
                .firstWhere((element) => element.className.contains('tick-dub'))
                .text
                .trim()),
        altEpisodeCount: languages.length > 1
            ? int.parse(langsRaw
                .firstWhere((element) => element.className.contains('tick-dub'))
                .text
                .trim())
            : 0);

    var type = _itemNameToItemType(
        soup.findAll('.film-stats .tick .item')[0].text.trim());

    var synopsis = soup
        .find('div.text:nth-child(1)')!
        .text
        .trim()
        .replaceFirst("+ More", "")
        .replaceAll('\n', ' ')
        .replaceAll('  ', '');

    var genres = <Genre>[];
    var genresRaw = soup.findAll('div.item-list > a');
    for (var genre in genresRaw) {
      genres.add(
        Genre(
          id: genre.attributes['href']!.replaceFirst("/genre/", "").trim(),
          name: genre.text.trim(),
        ),
      );
    }

    var sideItems = soup.findAll('div.item-title');
    List<String> dateStringList = [];
    dateStringList = sideItems[2].findAll('span')[1].text.trim().split(", ");

    if (dateStringList.length < 2 ||
        (!dateStringList[1].contains(" to ?") ||
            !dateStringList[1].contains(" to ") ||
            dateStringList[1].split(" ")[0].length != 4)) {
      dateStringList = sideItems[3].findAll('span')[1].text.trim().split(", ");
    }

    RegExp releaseDateRegex = RegExp(r"(\d+) to");
    DateTime? releaseDate;
    if (dateStringList.length > 1) {
      releaseDate = yearStringToDateTime(
          releaseDateRegex.firstMatch(dateStringList[1])?.group(1) ?? "0000");
      if (releaseDate.year == 0000) {
        releaseDate = yearStringToDateTime(dateStringList[1]);
      }
    } else {
      releaseDate = null;
    }
    DateTime? endDate;
    if (dateStringList.length > 1) {
      endDate = dateStringList.length > 2
          ? yearStringToDateTime(dateStringList[2])
          : null;
    } else {
      endDate = null;
    }
    var status = endDate != null ? AiringStatus.completed : AiringStatus.airing;

    var otherTitles = <String>[];
    var japaneseTitle = sideItems[1].findAll('span')[1].text.trim();
    otherTitles.add(japaneseTitle);

    var animeId = "";
    if (id.contains("?")) {
      animeId = id.split("?")[0].split("-").last;
    } else {
      animeId = id.split("-").last;
    }
    var episodesResponse =
        await http.get(Uri.parse("$_baseUrl/ajax/v2/episode/list/$animeId"));
    var episodesSoup = BeautifulSoup(jsonDecode(episodesResponse.body)["html"]);
    var episodeList = episodesSoup.findAll('a.ep-item');
    var episodesList = <DetailedEpisodeModel>[];
    for (var episode in episodeList) {
      var episodeId =
          episode.attributes['href']!.replaceFirst("/watch/", "").trim();
      var episodeName = episode.attributes['title']!.trim();
      var episodeUrl = "$_baseUrl/watch/$episodeId";
      var languageType = LanguageType.sub;
      var episodeNumber = episode.attributes['data-number']!.trim();
      var filler =
          episode.attributes['class'].toString().contains("ssl-item-filler");

      episodesList.add(
        DetailedEpisodeModel(
          episodeId: episodeId,
          episodeName: episodeName,
          episodeUrl: episodeUrl,
          languageType: languageType,
          episodeNumber: episodeNumber,
          fillerStatus:
              filler == true ? FillerStatus.filler : FillerStatus.canon,
        ),
      );
    }

    var actors = <BaseActorModel>[];
    var actorsRaw = soup
        .findAll('div.block-actors-content > div:nth-child(1) > div.bac-item');
    for (var actor in actorsRaw) {
      if (actor.findAll('div > div > h4 > a').length == 2) {
        var actorName = actor
            .findAll('div > div > h4 > a')[1]
            .text
            .trim()
            .replaceAll('\n', '')
            .replaceAll('\t', '');

        var actorImageUrl =
            actor.findAll('div > a > img')[1].attributes['data-src']!.trim();

        var version = actor
            .findAll('div > div > span')[1]
            .text
            .trim()
            .replaceAll('\n', '')
            .replaceAll('\t', '');

        var characterName = actor
            .findAll('div > div > h4 > a')[0]
            .text
            .trim()
            .replaceAll('\n', '')
            .replaceAll('\t', '');

        var characterImageUrl =
            actor.findAll('div > a > img')[0].attributes['data-src']!.trim();

        var characterDescription = actor
            .findAll('div > div > span')[0]
            .text
            .trim()
            .replaceAll('\n', '')
            .replaceAll('\t', '');

        var actorId =
            actor.findAll('div > div > h4 > a')[1].attributes['href']!.trim();

        var characterId =
            actor.findAll('div > div > h4 > a')[0].attributes['href']!.trim();

        actors.add(
          BaseActorModel(
            actorId: actorId,
            actorName: actorName,
            actorImageUrl: actorImageUrl,
            characterId: characterId,
            characterName: characterName,
            characterImageUrl: characterImageUrl,
            characterDescription: characterDescription,
            sourceId: 'zoro',
            version: version,
          ),
        );
      } else {
        var characterName = actor
            .findAll('div > div > h4 > a')[0]
            .text
            .trim()
            .replaceAll('\n', '')
            .replaceAll('\t', '');

        var characterImageUrl =
            actor.findAll('div > a > img')[0].attributes['data-src']!.trim();

        var characterDescription = actor
            .findAll('div > div > span')[0]
            .text
            .trim()
            .replaceAll('\n', '')
            .replaceAll('\t', '');

        var characterId =
            actor.findAll('div > div > h4 > a')[0].attributes['href']!.trim();

        actors.add(
          BaseActorModel(
            actorId: null,
            actorName: "",
            actorImageUrl: null,
            characterId: characterId,
            characterName: characterName,
            characterImageUrl: characterImageUrl,
            characterDescription: characterDescription,
            sourceId: 'zoro',
            version: null,
          ),
        );
      }
    }

    var relatedVideos = <BaseRelatedVideosModel>[];
    var relatedVideosRaw = soup.findAll('.screen-items > .item');
    for (var video in relatedVideosRaw) {
      var videoId = video.attributes['data-src']!.trim().split('/').last;

      var videoUrl = video.attributes['data-src']!.trim();

      var videoTitle = video.attributes['data-title']!.trim();

      var videoThumbnail = video.find('img.sit-img')!.attributes['src']!.trim();

      relatedVideos.add(
        BaseRelatedVideosModel(
          videoId: videoId,
          videoUrl: videoUrl,
          videoTitle: videoTitle,
          videoThumbnail: videoThumbnail,
        ),
      );
    }

    var relatedItemsRaw =
        soup.find("div.anif-block-ul > ul.ulclear")!.findAll("li");
    var relatedItems = <BaseItemModel>[];
    for (var e in relatedItemsRaw) {
      try {
        var id = e
            .find('.film-name > a')!
            .attributes['href']!
            .replaceFirst("/", "")
            .trim();
        String finalId;
        if (id.contains('?')) {
          finalId = id.split('?')[0];
        } else {
          finalId = id;
        }

        var title = e.find('.film-name > a')!.text.trim();

        var imageUrl =
            e.find('div.film-poster > img')!.attributes['data-src']!.trim();

        var languages = <LanguageType>[];
        var episodeSets = e.findAll('div.tick > div.tick-item');
        int subEps = 0;
        int dubEps = 0;
        EpisodeCount? episodeCount;
        for (var e in episodeSets) {
          var languageClassname = e.className;

          if (languageClassname.contains("tick-sub")) {
            languages.add(LanguageType.sub);
            subEps = int.parse(e.text.trim().replaceAll("Ep ", ""));
          } else if (languageClassname.contains("tick-dub")) {
            languages.add(LanguageType.dub);
            dubEps = int.parse(e.text.trim().replaceAll("Ep ", ""));
          }
        }
        episodeCount = EpisodeCount(
          episodeCount: subEps,
          altEpisodeCount: dubEps,
        );

        relatedItems.add(BaseItemModel(
            source: BaseSourceModel(
              id: "zoro",
              type: SourceType.anime,
              sourceName: "Zoro",
              baseUrl: _baseUrl,
            ),
            id: finalId,
            title: title,
            imageUrl: imageUrl,
            languages: languages,
            episodeCount: episodeCount));
      } catch (e) {}
    }

    return BaseDetailedItemModel(
      source: BaseSourceModel(
        id: "zoro",
        type: SourceType.anime,
        sourceName: "Zoro",
        baseUrl: _baseUrl,
      ),
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
      episodeCount: episodeCount,
      type: type,
      status: status,
      synopsis: synopsis,
      genres: genres,
      releaseDate: releaseDate,
      endDate: endDate,
      episodes: episodesList,
      altEpisodes: [],
      otherTitles: otherTitles,
      actors: actors,
      relatedVideos: relatedVideos,
      relatedItems: relatedItems,
    );
  }
}
