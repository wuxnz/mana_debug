import 'dart:convert';
import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/formatters/time_formatters.dart';
import 'package:mana_debug/app/core/utils/network/cloudflare_client.dart';
import 'package:mana_debug/app/core/utils/network/interceptor_client.dart';
import 'package:mana_debug/app/core/values/regex_patterns.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

class HiMoviesSource {
  static const String _baseUrl = 'https://himovies.sx';
  static final BaseSourceModel _source = BaseSourceModel(
    id: 'hi-movies',
    type: SourceType.movie,
    sourceName: 'HiMovies',
    baseUrl: _baseUrl,
  );
  static final _cloudFlareClient = CloudFlareClient();
  static final _interceptor = InterceptorClient();

  BaseItemModel parseRegularItem(Bs4Element item) {
    var id = item.find('.film-name > a')!.attributes['href']!;
    var title = item.find('.film-name > a')!.text.trim();
    var imageUrl = item.find('div.film-poster > img')?.attributes['data-src'] ??
        item.find('div.film-poster > img')!.attributes['data-src']!;
    List<LanguageType> languages = [];
    var type = item.find('span.fdi-type')!.text.trim();
    EpisodeCount? episodeCount;
    if (type == "TV") {
      try {
        episodeCount = EpisodeCount(
          episodeCount: int.parse(item
              .findAll('span.fdi-item')[1]
              .text
              .trim()
              .split('EPS')[1]
              .trim()),
          altEpisodeCount: 0,
        );
      } catch (e) {
        episodeCount = null;
      }
    } else {
      episodeCount = EpisodeCount(
        episodeCount: 1,
        altEpisodeCount: 0,
      );
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

  Future<BaseCategoryModel> scrapeSearch(String query) async {
    var response = await http
        .get(Uri.parse('$_baseUrl/search/${query.replaceAll(" ", "-")}'));
    var soup = BeautifulSoup(response.body);
    var results = soup.findAll('div.flw-item');
    var animeList = <BaseItemModel>[];
    for (var result in results) {
      animeList.add(parseRegularItem(result));
    }
    return BaseCategoryModel(
      categoryName: 'HiMovies',
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
    String randomString = alphaWithoutVowels[Random().nextInt(21)];
    final BaseCategoryModel animeList = await scrapeSearch(randomString);
    if (animeList.items.length < 5) {
      while (animeList.items.length < 5) {
        randomString = alphaWithoutVowels[Random().nextInt(21)];
        var searchResults = await scrapeSearch(randomString);
        animeList.items.addAll(searchResults.items);
      }
    }
    animeList.items.shuffle();
    return BaseCategoryModel(
        categoryName: "Random", items: animeList.items, source: this);
  }

  Future<BaseCategoryModel> scrapeCategoryPage(String route) async {
    var response = await http.get(Uri.parse('$_baseUrl/$route'));
    var soup = BeautifulSoup(response.body);
    var categoryName = soup.find('.cat-heading')!.text.trim();
    var results = soup.findAll('div.flw-item');
    var animeList = <BaseItemModel>[];
    for (var result in results) {
      animeList.add(parseRegularItem(result));
    }
    return BaseCategoryModel(
      categoryName: categoryName,
      items: animeList,
      source: this,
    );
  }

  List<Future<BaseCategoryModel>> getCategories() {
    try {
      return [
        scrapeCategoryPage('movie'),
        scrapeCategoryPage('tv-show'),
        scrapeCategoryPage('top-imdb'),
        scrapeCategoryPage('genre/action'),
      ];
    } catch (e) {
      return [];
    }
  }

  Future<List<BaseCategoryModel>?> scrapeCategories() async {
    return Future.value(null);
  }

  Future<List<RawVideoSourceInfoModel>> getVideoSources(
    String episodeId,
  ) async {
    try {
      var response = await http.get(Uri.parse('$_baseUrl$episodeId'));
      var soup = BeautifulSoup(response.body);
      var sources = <RawVideoSourceInfoModel>[];
      var sourcesRaw = soup.findAll('li > a');
      for (var sourceRaw in sourcesRaw) {
        var sourceId = sourceRaw.attributes['data-id'] ??
            sourceRaw.attributes['data-linkid']!;
        var sourceName = sourceRaw.find('span')!.text.trim();
        var sourceResponse = await http
            .get(Uri.parse('$_baseUrl/ajax/episode/sources/$sourceId'));
        var sourceJson = jsonDecode(sourceResponse.body);
        sources.add(RawVideoSourceInfoModel(
          sourceId: sourceName.toLowerCase(),
          sourceName: sourceName,
          embedUrl: sourceJson['link'],
          baseUrl: Uri.parse(sourceJson['link']).origin,
        ));
      }
      return sources;
    } catch (e) {
      return [];
    }
  }

  Future<BaseDetailedItemModel> scrapeDetails(String id) async {
    var apiId = id.split('-').last;
    var response = await http.get(Uri.parse('$_baseUrl$id'));
    var soup = BeautifulSoup(response.body);
    var title = soup.find('.heading-name > a')!.text.trim();
    var imageUrl = soup.find('img.film-poster-img')!.attributes['src']!;
    var languages = <LanguageType>[];
    var coverImageUrl = bgImageUrlRegExp
        .firstMatch(soup.find(".cover_follow")?.attributes["style"] ?? "")
        ?.group(1);
    EpisodeCount? episodeCount;
    List<Genre> genres = [];
    for (var genre in soup.findAll(".row-line")[1].findAll("a")) {
      genres.add(Genre(
        id: genre.attributes["href"]!,
        name: genre.text.trim(),
      ));
    }
    double? rating;
    try {
      rating = double.parse(
          soup.find(".btn-warning")!.text.split("IMDB: ")[1].trim());
    } catch (e) {
      rating = null;
    }
    ItemType type = id.contains("/tv/") ? ItemType.tv : ItemType.movie;
    var synopsis = soup.find(".description")!.text.trim();
    DateTime? releaseDate;
    try {
      releaseDate = yearStringToDateTime(soup
          .find(".row-line")!
          .text
          .replaceFirst("Released:", '')
          .trim()
          .split("-")
          .first
          .trim());
    } catch (e) {
      releaseDate = null;
    }
    List<DetailedEpisodeModel> episodes = [];
    if (type == ItemType.tv) {
      var response =
          await http.get(Uri.parse('$_baseUrl/ajax/season/list/$apiId'));
      var seasonsSoup = BeautifulSoup(response.body);
      var seasonIds = seasonsSoup
          .findAll("a.dropdown-item")
          .map((e) => e.attributes["data-id"])
          .toList();
      var seasonNumber = 1;
      for (var seasonId in seasonIds) {
        var response = await http
            .get(Uri.parse('$_baseUrl/ajax/season/episodes/$seasonId'));
        var episodeSoup = BeautifulSoup(response.body);
        var episodeItems = episodeSoup.findAll("a.eps-item");
        var relativeEpisodeNumber = 1;
        for (var episode in episodeItems) {
          var episodeId = episode.attributes["data-id"]!;
          var episodeNumber =
              RegExp(r"Eps (\d+)").firstMatch(episode.text.trim())!.group(1)!;
          var episodeName = episode.text.trim();
          episodes.add(DetailedEpisodeModel(
            episodeId: "/ajax/episode/servers/$episodeId",
            episodeUrl: "$_baseUrl/ajax/episode/servers/$episodeId",
            episodeNumber: episodeNumber,
            seasonNumber: seasonNumber,
            relativeEpisodeNumber: relativeEpisodeNumber,
            episodeName: episodeName,
          ));
          relativeEpisodeNumber++;
        }
        seasonNumber++;
      }
    } else {
      episodes.add(DetailedEpisodeModel(
        episodeId: "/ajax/movie/episodes/$apiId",
        episodeUrl: "$_baseUrl/ajax/movie/episodes/$apiId",
        episodeNumber: "1",
        seasonNumber: 1,
        relativeEpisodeNumber: 1,
        episodeName: title,
      ));
    }
    episodeCount = EpisodeCount(
      episodeCount: episodes.length,
      altEpisodeCount: episodes.length,
    );
    List<BaseItemModel> relatedItems = [];
    for (var relatedItem in soup.findAll("div.film_list-wrap > div.flw-item")) {
      relatedItems.add(parseRegularItem(relatedItem));
    }
    return BaseDetailedItemModel(
      source: _source,
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
      coverImageUrl: coverImageUrl,
      synopsis: synopsis,
      rating: rating,
      releaseDate: releaseDate,
      episodeCount: episodeCount,
      type: type,
      genres: genres,
      episodes: episodes,
      relatedItems: relatedItems,
    );
  }
}
