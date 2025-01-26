import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/formatters/time_formatters.dart';
import 'package:mana_debug/app/core/values/constants.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../../../../core/utils/helpers/encode_decode.dart';
import '../../../../core/values/regex_patterns.dart';
import '../../../services/source_service.dart';

class GogoAnimeSource {
  static const String _baseUrl = 'https://gogoanime.hu';
  static const String _ajaxUrl = 'https://ajax.gogo-load.com/ajax';
  static final BaseSourceModel _source = BaseSourceModel(
    id: 'gogoanime',
    type: SourceType.anime,
    sourceName: 'Gogoanime',
    baseUrl: _baseUrl,
  );

  BaseItemModel _parseRegItem(Bs4Element item) {
    var id = item.find('a')!.attributes['href']!.trim().split('/').last;
    var title = item.find('a')!.attributes['title']!.trim();
    var imageUrl = item.find('.img > a > img')?.attributes['src']?.trim();
    imageUrl ??= bgImageUrlRegExp
        .firstMatch(item.find('a > div')!.attributes['style']!.trim())
        ?.group(1);

    var languages =
        title.contains('(Dub)') ? [LanguageType.dub] : [LanguageType.sub];
    var numberOfEpisodes = item.findAll('p').last.text.contains("Episode")
        ? item.findAll('p').last.text.trim().split('Episode ').last
        : null;
    EpisodeCount? episodeCount;
    if (numberOfEpisodes != null) {
      var numberOfEpisodesInt = double.parse(numberOfEpisodes).ceil();
      episodeCount = EpisodeCount(
        episodeCount: numberOfEpisodesInt,
        altEpisodeCount: 0,
      );
    }
    return BaseItemModel(
      source: _source,
      id: id,
      imageUrl: imageUrl ?? '',
      title: title,
      languages: languages,
      episodeCount: episodeCount,
    );
  }

  Future<BaseCategoryModel> scrapeSearch(String query, {int page = 1}) async {
    var response = await http.get(Uri.parse(
        "$_baseUrl/search.html?keyword=${encodeURIComponent(query)}"));
    var soup = BeautifulSoup(response.body);
    var items = soup.findAll('.items > li');
    var itemsList = items.map((item) => _parseRegItem(item)).toList();
    return BaseCategoryModel(
      categoryName: 'Gogoanime',
      items: itemsList,
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

  Future<BaseCategoryModel> _getAjaxCategory(
      String ajaxPath, String categoryName) async {
    var response = await http.get(Uri.parse("$_ajaxUrl/$ajaxPath"));
    var soup = BeautifulSoup(response.body);
    var items = soup.findAll('ul').last.findAll('li');
    var itemsList = items.map((item) => _parseRegItem(item)).toList();
    return BaseCategoryModel(
      categoryName: categoryName,
      items: itemsList,
      source: this,
    );
  }

  List<Future<BaseCategoryModel>> getCategories() {
    return [
      _getAjaxCategory(
          'page-recent-release.html?page=1&type=1', 'Recent Release Japanese'),
      _getAjaxCategory(
          'page-recent-release.html?page=1&type=2', 'Recent Release English'),
      _getAjaxCategory(
          'page-recent-release.html?page=1&type=3', 'Recent Release Chinese'),
      _getAjaxCategory(
          'page-recent-release-ongoing.html?page=1', 'Popular Ongoing'),
    ];
  }

  Future<List<BaseCategoryModel>?> scrapeCategories() async {
    return Future.value(null);
  }

  Future<List<RawVideoSourceInfoModel>> getVideoSources(
    String episodeId,
  ) async {
    String newId;
    if (episodeId.startsWith("/")) {
      newId = episodeId;
    } else {
      newId = "/$episodeId";
    }
    var response = await http.get(Uri.parse('$_baseUrl$newId'));
    var soup = BeautifulSoup(response.body);
    var sourceIds = soup
        .findAll('.anime_muti_link > ul > li > a')
        .toList()
        .map((e) => e.text
            .toLowerCase()
            .replaceAll(' ', '-')
            .replaceFirst('choose-this-server', '')
            .replaceAll('--', '')
            .replaceAll('-', '')
            .replaceAll(' ', '')
            .trim())
        .toList();

    var videoSources = soup
        .findAll('.anime_muti_link > ul > li > a')
        .toList()
        //map with index of element
        .asMap()
        .map((index, e) => MapEntry(
            index,
            RawVideoSourceInfoModel(
                sourceId: sourceIds[index] == "vidstreaming"
                    ? "goload"
                    : sourceIds[index],
                sourceName: sourceIds[index] == "vidstreaming"
                    ? "Gogoanime"
                    : e.text
                        .replaceAll(' ', '-')
                        .replaceFirst('Choose-this-server', '')
                        .replaceAll('--', '')
                        .replaceAll('-', ''),
                baseUrl: e.attributes['data-video']!.contains("https://")
                    ? Uri.parse(e.attributes['data-video']!).host
                    : Uri.parse(("https:${e.attributes['data-video']!}")).host,
                embedUrl: e.attributes['data-video']!.contains("https://")
                    ? e.attributes['data-video']
                    : 'https:${e.attributes['data-video']!}',
                extractor: sourceIds[index] == "vidstreaming"
                    ? SourceService().detectExtractor("goload")
                    : SourceService().detectExtractor(sourceIds[index]))))
        .values
        .toList();

    return videoSources;
  }

  String replaceNumberWithRomanNumeralLowercase(String input) {
    RegExp exp = RegExp(r'-\d+');
    Iterable<Match> matches = exp.allMatches(input);
    var lastMatch = matches.last.group(0);
    var newInput = input.replaceFirst(
        lastMatch!,
        lastMatch
            .replaceAll('10', 'x')
            .replaceAll('2', 'ii')
            .replaceAll('3', 'iii')
            .replaceAll('4', 'iv')
            .replaceAll('5', 'v')
            .replaceAll('6', 'vi')
            .replaceAll('7', 'vii')
            .replaceAll('8', 'viii')
            .replaceAll('9', 'ix')
            .replaceAll('1', 'i'));

    return newInput;
  }

  Future<List<BaseItemModel>> scrapeGenre(String id) async {
    var response = await http.get(Uri.parse('$_baseUrl/genre/$id'));
    var soup = BeautifulSoup(response.body);
    var items = soup.findAll('ul.items > li');
    var itemsList = items.map((item) => _parseRegItem(item)).toList();
    return itemsList;
  }

  Future<BaseDetailedItemModel> scrapeDetails(String id) async {
    RegExp episodeExp = RegExp(r'-episode-\d+');
    var newId = id.split(episodeExp).first;
    http.Response response;
    response = await http.get(Uri.parse('$_baseUrl/category/$newId'), headers: {
      'Referer': _baseUrl,
      'User-Agent': gogoUserAgent,
    });
    BeautifulSoup soup;
    soup = BeautifulSoup(response.body);

    if (soup.find('h1.entry-title')?.text.contains("404") ?? false) {
      response = await http.get(
          Uri.parse(
              '$_baseUrl/category/${replaceNumberWithRomanNumeralLowercase(newId)}'),
          headers: {
            'Referer': _baseUrl,
            'User-Agent': gogoUserAgent,
          });
      soup = BeautifulSoup(response.body);
    }
    String imageUrl = soup
            .find('.anime_info_body_bg > img:nth-child(1)')
            ?.attributes['src'] ??
        '';
    String title = soup
            .find('div.anime_info_body_bg > h1')
            ?.text
            .replaceAll('\n', '')
            .replaceAll('\t', '')
            .trim() ??
        '';
    String itemType = soup
            .find('div.anime_info_body_bg > p.type')
            ?.text
            .replaceFirst('Type:', '')
            .replaceAll('\n', '')
            .replaceAll('\t', '')
            .trim() ??
        '';
    String synopsis = soup
        .findAll('p.type')[1]
        .text
        .replaceAll('Plot Summary:', '')
        .replaceAll('\n', '')
        .replaceAll('\t', '')
        .trim();
    List<Genre> genres = List.generate(
        soup
            .findAll('p.type')[2]
            .text
            .replaceAll('\n', '')
            .replaceAll('\t', '')
            .trim()
            .replaceAll('Genre:', '')
            .trim()
            .split(', ')
            .length,
        (index) => Genre(
            id: soup
                .findAll('p.type')[2]
                .text
                .replaceAll('\n', '')
                .replaceAll('\t', '')
                .trim()
                .replaceAll('Genre:', '')
                .trim()
                .split(', ')[index]
                .replaceAll(' ', '-')
                .toLowerCase(),
            name: soup
                .findAll('p.type')[2]
                .text
                .replaceAll('\n', '')
                .replaceAll('\t', '')
                .trim()
                .replaceAll('Genre:', '')
                .trim()
                .split(', ')[index]));
    // for (var genre in genres) {
    //   debugPrint(genre.id);
    // }
    String releaseYear = soup
        .findAll('p.type')[3]
        .text
        .replaceAll('Released:', '')
        .replaceAll('\n', '')
        .replaceAll('\t', '')
        .trim();
    String status = soup
        .findAll('p.type')[4]
        .text
        .replaceAll('Status:', '')
        .replaceAll('\n', '')
        .replaceAll('\t', '')
        .trim();
    List<String> otherTitles = List.generate(
        soup
            .findAll('p.type')[5]
            .text
            .replaceAll('\n', '')
            .replaceAll('\t', '')
            .trim()
            .replaceAll('Other name:', '')
            .replaceAll(', ', '; ')
            .split('; ')
            .length,
        (index) => soup
            .findAll('p.type')[5]
            .text
            .replaceAll('\n', '')
            .replaceAll('\t', '')
            .trim()
            .replaceAll('Other name:', '')
            .replaceAll(', ', '; ')
            .split('; ')[index]);

    String movieID = soup.find('#movie_id')?.attributes['value'] ?? '';
    String alias = soup.find('#alias_anime')?.attributes['value'] ?? '';
    var episodesListPage = await http.get(Uri.parse(
        '$_ajaxUrl/load-list-episode?ep_start=0&ep_end=99999&id=$movieID&default_ep=0&alias=$alias'));
    var episodesListSoup = BeautifulSoup(episodesListPage.body);
    List<DetailedEpisodeModel> episodes = [];

    for (var episode in episodesListSoup.findAll('li').reversed) {
      String episodeID =
          episode.find('a')?.attributes['href']?.replaceFirst(' /', '') ?? '';
      String episodeNumber = episode
          .findAll('a > div')[0]
          .text
          .replaceAll('\n', '')
          .replaceAll('\t', '')
          .trim()
          .replaceAll('EP', '');

      String episodeUrl = '$_baseUrl$episodeID';

      try {
        episodes.add(DetailedEpisodeModel(
          episodeId: episodeID,
          episodeUrl: episodeUrl,
          languageType:
              title.contains('(Dub)') ? LanguageType.dub : LanguageType.sub,
          episodeNumber: episodeNumber,
        ));
      } catch (e) {
        episodes.add(DetailedEpisodeModel(
          episodeId: episodeID,
          episodeUrl: episodeUrl,
          languageType:
              title.contains('(Dub)') ? LanguageType.dub : LanguageType.sub,
          episodeNumber: episodeNumber,
        ));
      }
    }
    List<BaseItemModel> relatedItems = [];
    if (genres.isNotEmpty) {
      Genre randomGenre = genres[Random().nextInt(genres.length)];
      relatedItems = await scrapeGenre(randomGenre.id!);
    }
    return BaseDetailedItemModel(
      source: BaseSourceModel(
        id: 'gogoanime',
        type: SourceType.anime,
        sourceName: 'Gogoanime',
        baseUrl: _baseUrl,
      ),
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages:
          title.contains('(Dub)') ? [LanguageType.dub] : [LanguageType.sub],
      episodeCount: EpisodeCount(
        episodeCount: episodes.length,
        altEpisodeCount: 0,
      ),
      watchStatus: null,
      type: itemType == 'Movie'
          ? ItemType.movie
          : itemType == 'OVA'
              ? ItemType.ova
              : itemType == 'ONA'
                  ? ItemType.ona
                  : itemType == 'Special'
                      ? ItemType.special
                      : ItemType.tv,
      status: status == 'Ongoing'
          ? AiringStatus.airing
          : status == 'Completed'
              ? AiringStatus.completed
              : status == 'Upcoming'
                  ? AiringStatus.upcoming
                  : AiringStatus.unknown,
      synopsis: synopsis,
      genres: genres.length != 1 && genres[0].name != '' ? genres : null,
      releaseDate: releaseYear == '0' || releaseYear == ''
          ? null
          : yearStringToDateTime(releaseYear),
      episodes: episodes,
      otherTitles: otherTitles[0] != '' ? otherTitles : null,
      movieId: movieID,
      alias: alias,
      relatedItems: relatedItems,
    );
  }
}
