import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/values/constants.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../../../../core/utils/extractors/streamsb_extractor.dart';
import '../../../../core/utils/extractors/vidmoly_extractor.dart';
import '../../../../core/utils/extractors/xstreamcdn_extractor.dart';
import '../../../services/external_helper_services/anime_filler_list.dart';

class KimCartoonSource {
  static const _baseUrl = "https://kimcartoon.li";
  final RegExp _episodeNumberRegex = RegExp(r'Episode\s(\d+)');

  Future<BaseCategoryModel> scrapeSearch(String query) async {
    var response = await http.post(
      Uri.parse('$_baseUrl/Search/Cartoon'),
      body: {'keyword': query},
      headers: {
        'User-Agent': kimCartoonUserAgent,
      },
    );
    var soup = BeautifulSoup(response.body);
    var searchResultsRaw = soup.findAll('div.list-cartoon > div.item');
    List<BaseItemModel> searchResults = [];
    for (var result in searchResultsRaw) {
      var id = result.find('a')!.attributes['href'].toString().trim();
      var title = result.find('a')!.find('span')?.text.trim() ?? '';

      var imageUrl = result
              .find('a')!
              .find('img')!
              .attributes['src']!
              .trim()
              .startsWith('http')
          ? result.find('a')!.find('img')?.attributes['src'].toString().trim()
          : '$_baseUrl${result.find('a')!.find('img')?.attributes['src'].toString().trim()}';

      List<LanguageType> languages =
          result.find('a')!.find('span.title')?.text.contains('(Sub)') ?? false
              ? [LanguageType.sub]
              : [LanguageType.dub];
      searchResults.add(
        BaseItemModel(
          source: BaseSourceModel(
            id: 'kim-cartoon',
            type: SourceType.cartoon,
            sourceName: 'KimCartoon',
            baseUrl: _baseUrl,
          ),
          id: id,
          title: title,
          imageUrl: imageUrl ?? '',
          languages: languages,
        ),
      );
    }
    return BaseCategoryModel(
      categoryName: 'KimCartoon',
      items: searchResults,
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

  Future<BaseCategoryModel> scrapeTopCategory(Bs4Element soup) async {
    var categoryName = soup.find('span.title-list')?.text.trim() ?? '';
    var categoryItems = soup.findAll('div.items > div > a');
    List<BaseItemModel> items = [];
    for (var item in categoryItems) {
      var id = item.attributes['href'].toString().trim();

      var title = item
              .find('div.item-title')
              ?.text
              .replaceFirst(item.find('div.item-title > span')?.text ?? '', '')
              .trim() ??
          '';

      var imageUrl = item.find('img')?.attributes['src']?.trim() != null &&
              item.find('img')?.attributes['src']?.trim() != ''
          ? item.find('img')!.attributes['src']!.trim().startsWith('http')
              ? item.find('img')?.attributes['src'].toString().trim()
              : '$_baseUrl${item.find('img')?.attributes['src'].toString().trim()}'
          : item.find('img')?.attributes['srctemp']?.trim() != null &&
                  item.find('img')?.attributes['srctemp']?.trim() != ''
              ? item
                      .find('img')!
                      .attributes['srctemp']!
                      .trim()
                      .startsWith('http')
                  ? item.find('img')?.attributes['srctemp'].toString().trim()
                  : '$_baseUrl${item.find('img')?.attributes['srctemp'].toString().trim()}'
              : '';

      var languages =
          item.find('div.item-title > span')?.text.contains('(Sub)') ?? false
              ? [LanguageType.sub]
              : [LanguageType.dub];

      EpisodeCount episodeCount = EpisodeCount(
        episodeCount: int.parse(_episodeNumberRegex
                .firstMatch(
                    item.find('div.item-title > span')?.text ?? 'Episode 0')
                ?.group(1)
                .toString() ??
            '0'),
        altEpisodeCount: 0,
      );

      items.add(BaseItemModel(
        source: BaseSourceModel(
          id: 'kim-cartoon',
          type: SourceType.cartoon,
          sourceName: 'KimCartoon',
          baseUrl: _baseUrl,
        ),
        id: id,
        title: title,
        imageUrl: imageUrl ?? '',
        languages: languages,
        episodeCount: episodeCount,
      ));
    }

    return BaseCategoryModel(
      categoryName: categoryName,
      items: items,
      source: this,
    );
  }

  Future<BaseCategoryModel> scrapeHomeScreenCategory(
      List<Bs4Element> soup, int index, String categoryName) async {
    Bs4Element newSoup = soup[index];
    List<BaseItemModel> items = [];
    var categoryItems =
        newSoup.findAll('div', attrs: {'style': 'position:relative'});

    if (index == 0) {
      categoryItems.removeLast();
    }
    for (var item in categoryItems) {
      var id = item.find('a')?.attributes['href'].toString().trim() ?? '';

      var title = item.find('a > span')?.text ?? '';

      var imageUrl = item
                  .find('a > img')
                  ?.attributes['src']
                  ?.trim()
                  .startsWith('http') ??
              false
          ? item.find('a > img')?.attributes['src'].toString().trim()
          : '$_baseUrl${item.find('a > img')?.attributes['src'].toString().trim()}';

      var languages = [LanguageType.dub];
      EpisodeCount episodeCount = EpisodeCount(
        episodeCount: int.parse(_episodeNumberRegex
                .firstMatch(
                    item.find('div.item-title > span')?.text ?? 'Episode 0')
                ?.group(1)
                .toString() ??
            '0'),
        altEpisodeCount: 0,
      );

      List<Genre> genres = [];
      for (var genre in item.findAll('p').first.findAll('a')) {
        genres.add(Genre(
          id: genre.attributes['href'].toString().trim(),
          name: genre.text,
        ));
      }

      items.add(BaseItemModel(
        source: BaseSourceModel(
          id: "kim-cartoon",
          type: SourceType.multi,
          sourceName: "KimCartoon",
          baseUrl: _baseUrl,
        ),
        id: id,
        title: title,
        imageUrl: imageUrl ?? '',
        languages: languages,
        episodeCount: episodeCount,
        genres: genres,
      ));
    }

    return BaseCategoryModel(
      categoryName: categoryName,
      items: items,
      source: this,
    );
  }

  List<Future<BaseCategoryModel>> getCategories(List<Bs4Element> soup,
      Bs4Element soup2, int numberOfCategories, List<String> categoryNames) {
    var categories = <Future<BaseCategoryModel>>[];
    for (var i = 0; i < numberOfCategories; i++) {
      if (i == numberOfCategories - 1) {
        categories.insert(0, scrapeTopCategory(soup2));
      } else {
        categories.add(scrapeHomeScreenCategory(soup, i, categoryNames[i]));
      }
    }

    return categories;
  }

  Future<List<BaseCategoryModel>?> scrapeCategories() async {
    var response = await http.get(Uri.parse(_baseUrl), headers: {
      'User-Agent': kimCartoonUserAgent,
    });

    var soup = BeautifulSoup(response.body);
    var categoriesSoup = soup.findAll('#subcontent > div').sublist(3, 7);

    var categoriesSoup2 = soup.find('#container')!;
    var categoriesNames = soup
        .findAll('#tabmenucontainer > ul > li > a')
        .map((e) => e.text.trim())
        .toList();

    var categories = getCategories(categoriesSoup, categoriesSoup2,
        categoriesSoup.length + 1, categoriesNames);

    var results = await Future.wait(categories);

    return results;
  }

  Future<List<RawVideoSourceInfoModel>> getVideoSources(
      String episodeId) async {
    var newId = episodeId;

    var streamSBResponse =
        await http.get(Uri.parse("$_baseUrl$newId&s=sb"), headers: {
      'User-Agent': kimCartoonUserAgent,
    });

    var streamSBResponseSoup = BeautifulSoup(streamSBResponse.body);
    var streamSBResponseEmbedUrl = streamSBResponseSoup
        .find('#my_video_1')
        ?.attributes['src']
        .toString()
        .trim();

    var fembedResponse =
        await http.get(Uri.parse("$_baseUrl$newId&s=fe"), headers: {
      'User-Agent': kimCartoonUserAgent,
    });

    var fembedResponseSoup = BeautifulSoup(fembedResponse.body);
    var fembedResponseEmbedUrl = fembedResponseSoup
        .find('#my_video_1')
        ?.attributes['src']
        .toString()
        .trim();

    var vidmolyResponse =
        await http.get(Uri.parse("$_baseUrl$newId&s=vm"), headers: {
      'User-Agent': kimCartoonUserAgent,
    });

    var vidmolyResponseSoup = BeautifulSoup(vidmolyResponse.body);
    var vidmolyResponseEmbedUrl = vidmolyResponseSoup
        .find('#my_video_1')
        ?.attributes['src']
        .toString()
        .trim();

    var hydraxResponse =
        await http.get(Uri.parse("$_baseUrl$newId&s=fe"), headers: {
      'User-Agent': kimCartoonUserAgent,
    });

    var hydraxResponseSoup = BeautifulSoup(hydraxResponse.body);
    var hydraxResponseEmbedUrl = hydraxResponseSoup
            .find('#my_video_1')!
            .attributes['src']
            .toString()
            .trim()
            .startsWith('http')
        ? hydraxResponseSoup
            .find('#my_video_1')
            ?.attributes['src']
            .toString()
            .trim()
        : hydraxResponseSoup
            .find('#my_video_1')
            ?.attributes['src']
            .toString()
            .trim()
            .replaceFirst('//', 'https://');

    List<RawVideoSourceInfoModel> sourcesToReturn = [];
    if (streamSBResponseEmbedUrl != null) {
      sourcesToReturn.add(RawVideoSourceInfoModel(
        embedUrl: streamSBResponseEmbedUrl.replaceFirst('.html', '') ?? '',
        sourceId: 'streamsb',
        sourceName: 'StreamSB',
        baseUrl: Uri.parse(streamSBResponseEmbedUrl).origin,
        extractor: StreamSBExtractor(),
      ));
    }
    if (fembedResponseEmbedUrl != null) {
      sourcesToReturn.add(RawVideoSourceInfoModel(
        embedUrl: fembedResponseEmbedUrl,
        sourceId: 'xstreamcdn',
        sourceName: 'XStreamCDN',
        baseUrl: Uri.parse(fembedResponseEmbedUrl).origin,
        extractor: XstreamCdnExtractor(),
      ));
    }

    if (vidmolyResponseEmbedUrl != null) {
      sourcesToReturn.add(RawVideoSourceInfoModel(
        embedUrl: vidmolyResponseEmbedUrl,
        sourceId: 'vidmoly',
        sourceName: 'Vidmoly',
        baseUrl: Uri.parse(vidmolyResponseEmbedUrl).origin,
        extractor: VidmolyExtractor(),
      ));
    }
    if (hydraxResponseEmbedUrl != null) {
      sourcesToReturn.add(RawVideoSourceInfoModel(
        embedUrl: hydraxResponseEmbedUrl,
        sourceId: 'hydrax',
        sourceName: 'Hydrax',
        baseUrl: Uri.parse(hydraxResponseEmbedUrl).origin,
        extractor: null,
      ));
    }

    return sourcesToReturn;
  }

  Future<List<BaseItemModel>> scrapeGenre(String id) async {
    var response = await http.get(Uri.parse('$_baseUrl$id'), headers: {
      'User-Agent': kimCartoonUserAgent,
    });
    var soup = BeautifulSoup(response.body);
    var items = soup.findAll('div.list-cartoon > div.item');
    List<BaseItemModel> itemsList = [];
    for (var result in items) {
      var id = result.find('a')!.attributes['href'].toString().trim();
      var title = result.find('a')!.find('span')?.text.trim() ?? '';

      var imageUrl = result
              .find('a')!
              .find('img')!
              .attributes['src']!
              .trim()
              .startsWith('http')
          ? result.find('a')!.find('img')?.attributes['src'].toString().trim()
          : '$_baseUrl${result.find('a')!.find('img')?.attributes['src'].toString().trim()}';

      List<LanguageType> languages =
          result.find('a')!.find('span.title')?.text.contains('(Sub)') ?? false
              ? [LanguageType.sub]
              : [LanguageType.dub];
      itemsList.add(
        BaseItemModel(
          source: BaseSourceModel(
            id: 'kim-cartoon',
            type: SourceType.cartoon,
            sourceName: 'KimCartoon',
            baseUrl: _baseUrl,
          ),
          id: id,
          title: title,
          imageUrl: imageUrl ?? '',
          languages: languages,
        ),
      );
    }
    return itemsList;
  }

  Future<BaseDetailedItemModel> scrapeDetails(String id) async {
    var newId = id.startsWith('/') ? id : '/$id';
    var response = await http.get(Uri.parse(_baseUrl + newId), headers: {
      'User-Agent': kimCartoonUserAgent,
    });

    var soup = BeautifulSoup(response.body);
    var title = soup.find('a.bigChar')?.text.trim() ?? '';

    var imageUrl = soup
                .find('div.bigBarContainer > div > div > img')
                ?.attributes['src']
                ?.trim()
                .startsWith('http') ??
            false
        ? soup
                .find('div.bigBarContainer > div > div > img')
                ?.attributes['src'] ??
            ''
        : '$_baseUrl${soup.find('div.bigBarContainer > div > div > img')?.attributes['src'] ?? ''}';

    var languages =
        title.contains('(Sub)') ? [LanguageType.sub] : [LanguageType.dub];

    var episodesRaw = soup.findAll('table.listing > tbody > tr > td > a');
    var episodeCount =
        EpisodeCount(episodeCount: episodesRaw.length, altEpisodeCount: 0);

    List<String> otherTitles = [];
    var genres = <Genre>[];
    if (!soup
        .findAll('div.bigBarContainer > div > div')[1]
        .find('p')!
        .text
        .contains('Other name:')) {
      for (var genre in soup
              .findAll('div.bigBarContainer > div > div')[1]
              .find('p')
              ?.findAll('a') ??
          []) {
        genres.add(Genre(
          id: genre.attributes['href'].toString().trim(),
          name: genre.text.toString().trim(),
        ));
      }
    } else {
      for (var genre in soup
          .findAll('div.bigBarContainer > div > div')[1]
          .findAll('p')[1]
          .findAll('a')) {
        genres.add(Genre(
          id: genre.attributes['href'].toString().trim(),
          name: genre.text.toString().trim(),
        ));
      }
      for (var genre in soup
              .findAll('div.bigBarContainer > div > div')[1]
              .find('p')
              ?.findAll('a') ??
          []) {
        otherTitles.add(genre.text.toString().trim());
      }
    }

    var type = ItemType.cartoon;
    var status = soup
            .findAll('div.bigBarContainer > div > div')[1]
            .findAll('p')[2]
            .text
            .contains('Ongoing')
        ? AiringStatus.airing
        : AiringStatus.completed;

    String synopsis;
    synopsis = soup
        .findAll('div.bigBarContainer > div > div')[1]
        .findAll('p')[4]
        .text
        .trim();
    if (synopsis == "Summary:") {
      synopsis = soup
          .findAll('div.bigBarContainer > div > div')[1]
          .findAll('p')[5]
          .text
          .trim();
    }

    DateTime? releaseDate;
    List<DetailedEpisodeModel> episodes = [];
    var animeFillerList = AnimeFillerListService();
    var episodeNumber = 1;
    RegExp seasonRegex = RegExp(r'Season \d+');
    var offset = 0;
    for (var episode in episodesRaw.reversed.toList()) {
      var episodeId = episode.attributes['href'].toString().trim();
      var episodeName = episode.text.trim().split(title).last.trim();
      var episodeUrl = episodeId.startsWith('/')
          ? _baseUrl + episodeId
          : '$_baseUrl/$episodeId';
      var languageType = languages.first;
      var episodeNumberString = episodeName.contains('Episode')
          ? RegExp(r'[a-zA-Z]').hasMatch(
                  episodeName.split('Episode ')[1].split(" ")[0].toLowerCase())
              ? 0.toString()
              : episodeName.split('Episode ')[1].split(" ")[0].toLowerCase()
          : 0.toString();
      var seasonNumber =
          int.tryParse(seasonRegex.firstMatch(episodeName)?.group(0) ?? 'fail');
      if (episodeNumberString == '0') {
        offset++;
      }

      episodes.add(DetailedEpisodeModel(
        episodeId: episodeId,
        episodeName: episodeName,
        episodeUrl: episodeUrl,
        languageType: languageType,
        episodeNumber: int.tryParse(episodeNumberString) == 0
            ? '0'
            : (episodeNumber - offset).toString(),
        relativeEpisodeNumber: int.tryParse(episodeNumberString),
        seasonNumber: seasonNumber,
      ));
      episodeNumber++;
    }
    List<BaseItemModel> relatedItems = [];
    if (genres.isNotEmpty) {
      Genre randomGenre = genres[Random().nextInt(genres.length)];
      relatedItems = await scrapeGenre(randomGenre.id!);
    }
    return BaseDetailedItemModel(
      source: BaseSourceModel(
        id: "kim-cartoon",
        type: SourceType.multi,
        sourceName: "KimCartoon",
        baseUrl: _baseUrl,
      ),
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
      episodeCount: episodeCount,
      genres: genres,
      type: type,
      status: status,
      synopsis: synopsis,
      releaseDate: releaseDate,
      episodes: episodes,
      otherTitles: otherTitles,
      relatedItems: relatedItems,
    );
  }
}
