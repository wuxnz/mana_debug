import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/formatters/text_formatters.dart';
import 'package:mana_debug/app/core/utils/formatters/time_formatters.dart';

import '../../../../core/utils/extractors/dood_extractor.dart';
import '../../../../core/utils/extractors/streamhub_extractor.dart';
import '../../../models/sources/base_model.dart';

class AllMoviesForYouSource {
  static const _baseUrl = "https://allmovies.gg";
  static RegExp movieImageRegex =
      RegExp(r"controlBar\|([a-z]+)\|(\d+)\|(\d+)\|poster");
  static RegExp preLinkRegex = RegExp(r"\|doPlay\|([a-zA-Z\d]+)\|");
  static RegExp linkRegex = RegExp(
      r"\|application\|type\|([a-zA-Z\d]+)\|([a-zA-Z\d]+)\|([a-zA-Z\d]+)\|([a-zA-Z\d]+)\|([a-zA-Z\d]+)\|([a-zA-Z\d]+)\|([a-zA-Z\d]+)\|sources");

  String formatUrl(String url) {
    if (url.startsWith("http")) {
      return url;
    } else if (url.startsWith("//")) {
      return "https:$url";
    } else {
      return "$_baseUrl$url";
    }
  }

  BaseItemModel parseCategoryItemSoup(Bs4Element soup) {
    var id = soup.find("a")!.attributes["href"]!.replaceFirst(_baseUrl, "");
    // debugPrint("id: $id");
    var title = soup.find("a > h2.Title")!.text.trim();
    // debugPrint("title: $title");
    var imageUrl = formatUrl(
        soup.find("a > div.Image > figure > img")!.attributes["data-src"]!);
    // debugPrint("imageUrl: $imageUrl");
    var languages = <LanguageType>[];
    try {
      languages = soup.find("span.Lng")!.text.trim() == "English"
          ? [LanguageType.dub]
          : [LanguageType.sub];
    } catch (e) {
      languages = [LanguageType.dub];
    }
    // debugPrint("languages: $languages");
    var genres = <Genre>[];
    for (var genre in soup.findAll("p.Genre > a")) {
      genres.add(Genre(
        id: genre.attributes["href"]!.replaceFirst(_baseUrl, ""),
        name: genre.text.trim(),
      ));
    }
    // debugPrint("genres: $genres");
    var item = BaseItemModel(
      source: BaseSourceModel(
        id: "all-movies-for-you",
        type: SourceType.multi,
        sourceName: "AllMoviesForYou",
        baseUrl: _baseUrl,
      ),
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
      genres: genres,
    );
    return item;
  }

  Future<BaseCategoryModel> scrapeSearch(String query) async {
    var response = await http.get(Uri.parse("$_baseUrl/?s=$query"));
    var soup = BeautifulSoup(response.body);
    var searchResultsRaw = soup.findAll("article.TPost");
    var searchResults = <BaseItemModel>[];
    for (var result in searchResultsRaw) {
      // try {
      var item = parseCategoryItemSoup(result);
      searchResults.add(item);
      // } catch (e) {
      //   debugPrint(e.toString());
      // }
    }
    return BaseCategoryModel(
      categoryName: "AllMoviesForYou",
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

  Future<BaseCategoryModel> scrapeHomeScreenCategory(
      String categoryName, List<Bs4Element> categoryItems) async {
    var items = <BaseItemModel>[];
    for (var item in categoryItems) {
      var anime = parseCategoryItemSoup(item);
      items.add(anime);
    }
    return BaseCategoryModel(
      categoryName: categoryName,
      items: items,
      source: this,
    );
  }

  List<Future<BaseCategoryModel>> getCategories(
      List<List<Bs4Element>> categoriesData, List<String> categoriesNames) {
    var categories = <Future<BaseCategoryModel>>[];
    for (var i = 0; i < categoriesData.length; i++) {
      categories
          .add(scrapeHomeScreenCategory(categoriesNames[i], categoriesData[i]));
    }
    return categories;
  }

  Future<List<BaseCategoryModel>> scrapeCategories() async {
    var homeResponse = await http.get(Uri.parse(_baseUrl));
    var disneyResponse =
        await http.get(Uri.parse("$_baseUrl/category/disney/"));
    var netflixResponse =
        await http.get(Uri.parse("$_baseUrl/category/netflix/"));
    var homeSoup = BeautifulSoup(homeResponse.body);
    var disneySoup = BeautifulSoup(disneyResponse.body);
    var netflixSoup = BeautifulSoup(netflixResponse.body);
    var categoriesData = <List<Bs4Element>>[];
    var categoriesNames = <String>[];
    var categories = <Future<BaseCategoryModel>>[];
    var homeCategories = homeSoup.findAll("main > section");
    for (var category in homeCategories) {
      var categoryName = category.find("div.Top > h2.Title")!.text.trim();
      var categoryItems = category.findAll("article.TPost");
      categoriesData.add(categoryItems);
      categoriesNames.add(categoryName);
    }
    var disneyCategory = disneySoup.findAll("main > section");
    for (var category in disneyCategory) {
      var categoryName = category.find("div.Top > h2.Title")!.text.trim();
      var categoryItems = category.findAll("article.TPost");
      try {
        categoriesData.add(categoryItems);
      } catch (e) {
        debugPrint(e.toString());
      }
      categoriesNames.add(categoryName);
    }
    var netflixCategory = netflixSoup.findAll("main > section");
    for (var category in netflixCategory) {
      var categoryName = category.find("div.Top > h2.Title")!.text.trim();
      var categoryItems = category.findAll("article.TPost");
      categoriesData.add(categoryItems);
      categoriesNames.add(categoryName);
    }
    categories.addAll(getCategories(categoriesData, categoriesNames));

    return Future.wait(categories);
  }

  Future<List<RawVideoSourceInfoModel>> getVideoSources(
      String episodeId) async {
    var sources = <RawVideoSourceInfoModel>[];
    var response = await http.get(Uri.parse("$_baseUrl$episodeId"));
    var soup = BeautifulSoup(response.body);
    var siteResUrl = soup.find(".Video > iframe")!.attributes["src"]!.trim();
    var siteRes = await http.get(Uri.parse(siteResUrl));
    var resSoup = BeautifulSoup(siteRes.body);
    var embedUrl = resSoup.find("iframe")!.attributes["src"]!.trim();
    if (embedUrl.contains("streamhub")) {
      var embedId = embedUrl.split("/").last;

      var embedBaseUrl = Uri.parse(embedUrl).origin;
      siteRes = await http.get(Uri.parse(embedUrl));
      resSoup = BeautifulSoup(siteRes.body);
      var magicString = resSoup
          .findAll("div > script")
          .firstWhere((element) => RegExp(r"eval\(function\(p,a,c,k,e,d\).*")
              .hasMatch(element.text.trim()))
          .text
          .trim();
      sources.add(RawVideoSourceInfoModel(
          embedUrl: embedUrl,
          sourceId: 'streamhub',
          sourceName: "Streamhub",
          baseUrl: embedBaseUrl,
          extractor: StreamhubExtractor(),
          magicString: magicString));
    } else if (embedUrl.contains("dood")) {
      var newEmbedUrlId = embedUrl.split("/").last;

      var newEmbedUrl = "https://dood.yt/e/$newEmbedUrlId";
      sources.add(RawVideoSourceInfoModel(
          embedUrl: newEmbedUrl,
          sourceId: 'doodstream',
          sourceName: "Doodstream",
          baseUrl: "https://dood.yt",
          extractor: DoodStreamExtractor()));
    }

    return sources;
  }

  Future<BaseDetailedItemModel> scrapeDetails(String id) async {
    var infoUrl = id.startsWith('http') ? id : "$_baseUrl$id";
    var response = await http.get(Uri.parse(infoUrl));
    var soup = BeautifulSoup(response.body);
    if (id.contains("/movies/")) {
      var title = soup.find("h1")!.text.trim();

      var imageUrl = "";

      var languages = [LanguageType.dub];

      var coverImageUrl =
          soup.find("img.TPostBg")?.attributes["src"]?.trim() ?? "";
      if (coverImageUrl != "") {
        coverImageUrl = formatUrl(coverImageUrl);
      }

      var episodeCount = EpisodeCount(episodeCount: 1, altEpisodeCount: 0);
      var genres = <Genre>[];
      for (var genre in soup.findAll(".Genre > a")) {
        genres.add(Genre(
          id: genre.attributes["href"]!.trim().replaceFirst(_baseUrl, ""),
          name: genre.text.trim(),
        ));
      }

      var rating = double.parse(
          double.parse(soup.find(".post-ratings > span")!.text.trim())
              .toStringAsFixed(1));

      var type = ItemType.movie;
      var airingStatus = AiringStatus.completed;
      var synopsis = soup
          .find(".Description > p")!
          .text
          .trim()
          .replaceAll('\n', " ")
          .replaceAll("\t", " ");

      var releaseDate = yearStringToDateTime(soup.find(".Date")!.text.trim());

      var episodes = <DetailedEpisodeModel>[];
      var siteResUrl = soup.find(".Video > iframe")!.attributes["src"]!.trim();
      var siteRes = await http.get(Uri.parse(siteResUrl));
      var resSoup = BeautifulSoup(siteRes.body);
      var embedUrl = resSoup.find("iframe")?.attributes["src"]?.trim();
      if (embedUrl != null) {
        var embedBaseUrl = Uri.parse(embedUrl).origin;
        if (embedBaseUrl.contains("streamhub")) {
          try {
            siteRes = await http.get(Uri.parse(embedUrl));
            resSoup = BeautifulSoup(siteRes.body);
            episodes.add(
              DetailedEpisodeModel(
                  episodeId: id,
                  episodeName: title,
                  episodeUrl: "$_baseUrl$id",
                  languageType: languages[0],
                  episodeNumber: "1",
                  episodeDescription: synopsis,
                  airDate: releaseDate),
            );
          } catch (e) {
            debugPrint(e.toString());
          }
        } else if (embedBaseUrl.contains("dood")) {
          episodes.add(
            DetailedEpisodeModel(
                episodeId: id,
                episodeName: title,
                episodeUrl: "$_baseUrl$id",
                episodeThumbnail: coverImageUrl,
                languageType: languages[0],
                episodeNumber: "1",
                episodeDescription: synopsis,
                airDate: releaseDate),
          );
        }
      }
      var relatedVideos = <BaseRelatedVideosModel>[];
      try {
        var trailerId = soup
            .find("#funciones_public_sol-js-extra")
            ?.text
            .trim()
            .split("\\/embed\\/")[1]
            .split("\\")[0];
        if (trailerId != null) {
          relatedVideos.add(BaseRelatedVideosModel(
            videoId: trailerId,
            videoUrl: 'https://www.youtube.com/watch?v=$trailerId',
            videoTitle: '$title Trailer',
            videoThumbnail: null,
          ));
        }
      } catch (e) {
        debugPrint(e.toString());
      }
      var relatedItems = <BaseItemModel>[];
      for (var item
          in soup.find(".Main > section")?.findAll("div.TPost") ?? []) {
        var id = item
            .find("a")!
            .attributes["href"]!
            .trim()
            .replaceFirst(_baseUrl, "");
        var title = item.find("h2.Title")!.text.trim();
        var imageUrl = formatUrl(
            item.find("figure > img")!.attributes["data-src"]!.trim());
        var languages = <LanguageType>[];
        relatedItems.add(
          BaseItemModel(
            source: BaseSourceModel(
              id: "all-movies-for-you",
              type: SourceType.multi,
              sourceName: "AllMoviesForYou",
              baseUrl: _baseUrl,
            ),
            id: id,
            title: title,
            imageUrl: imageUrl,
            languages: languages,
          ),
        );
      }
      return BaseDetailedItemModel(
        source: BaseSourceModel(
          id: "all-movies-for-you",
          type: SourceType.multi,
          sourceName: "AllMoviesForYou",
          baseUrl: _baseUrl,
        ),
        id: id,
        title: title,
        imageUrl: imageUrl,
        languages: languages,
        coverImageUrl: coverImageUrl,
        episodeCount: episodeCount,
        genres: genres,
        rating: rating,
        type: type,
        status: airingStatus,
        synopsis: synopsis,
        releaseDate: releaseDate,
        episodes: episodes,
        relatedVideos: relatedVideos,
        relatedItems: relatedItems,
      );
    } else {
      var title = soup.find("h1")!.text.trim();
      debugPrint("title: $title");
      var imageUrl = "";
      debugPrint("imageUrl: $imageUrl");
      var languages = [LanguageType.dub];
      debugPrint("languages: $languages");
      var coverImageUrl =
          soup.find("img.TPostBg")?.attributes["src"]?.trim() ?? "";
      if (coverImageUrl != "") {
        coverImageUrl = formatUrl(coverImageUrl);
      }
      debugPrint("coverImageUrl: $coverImageUrl");
      var episodeCount = EpisodeCount(episodeCount: 1, altEpisodeCount: 0);
      var genres = <Genre>[];
      for (var genre in soup.findAll(".Genre > a")) {
        genres.add(Genre(
          id: genre.attributes["href"]!.trim().replaceFirst(_baseUrl, ""),
          name: genre.text.trim(),
        ));
      }
      debugPrint("genres: $genres");
      var rating = double.parse(
          double.parse(soup.find(".post-ratings > span")!.text.trim())
              .toStringAsFixed(1));
      debugPrint("rating: $rating");
      var type = ItemType.movie;
      var airingStatus = AiringStatus.completed;
      var synopsis = soup
          .find(".Description > p")!
          .text
          .trim()
          .replaceAll('\n', " ")
          .replaceAll("\t", " ");
      debugPrint("synopsis: $synopsis");
      var releaseDate = yearStringToDateTime(soup.find(".Date")!.text.trim());
      debugPrint("releaseDate: $releaseDate");
      List<List<DetailedEpisodeModel>> episodes = [];
      var seasons = soup.findAll("section.SeasonBx > div > div > a");
      debugPrint("seasons length: ${seasons.length}");
      int offset = 0;
      List<http.Response> seasonEpResponses = [];
      // List<Future> futures = [];
      for (var season in seasons) {
        var seasonId = season.attributes["href"]!.trim();
        var seasonNumber = season.find("span")!.text.trim();
        var seasonEpResponse = await http.get(Uri.parse(seasonId));
        seasonEpResponses.add(seasonEpResponse);
      }
      debugPrint("seasonEpResponses length: ${seasonEpResponses.length}");
      // await Future.wait(futures);
      var seasonsIndex = 0;
      int index = 0;
      for (var seasonEpResponse in seasonEpResponses) {
        var seasonEpSoup = BeautifulSoup(seasonEpResponse.body);
        var seasonTitle = seasonEpSoup
            .find("h1.Title")!
            .text
            .trim()
            .replaceFirst("$title ", "");
        debugPrint("seasonTitle: $seasonTitle");
        var seasonEpisodes = seasonEpSoup.findAll("tr.Viewed");
        debugPrint("seasonEpisodes length: ${seasonEpisodes.length}");
        int relativeEpisodeNumber = 1;
        List<DetailedEpisodeModel> episodeList = [];
        for (var seasonEpisode in seasonEpisodes) {
          var episodeId = seasonEpisode
              .find(".MvTbTtl > a")!
              .attributes["href"]!
              .trim()
              .split("/")[4];
          debugPrint("episodeId: $episodeId");
          var episodeName = seasonEpisode.find(".MvTbTtl > a")!.text.trim();
          debugPrint("episodeName: $episodeName");
          var episodeUrl =
              seasonEpisode.find(".MvTbTtl > a")!.attributes["href"]!.trim();
          debugPrint("episodeUrl: $episodeUrl");
          var episodeThumbnail = formatUrl(
              seasonEpisode.find("a.MvTbImg > img")!.attributes["src"]!.trim());
          debugPrint("episodeThumbnail: $episodeThumbnail");
          var seasonNumber = seasonEpSoup
              .find(".AAIco-playlist_play > div > span")!
              .text
              .trim();
          debugPrint("seasonNumber: $seasonNumber");
          var episodeNumber = seasonEpisode.find("span.Num")!.text.trim();
          debugPrint("episodeNumber: $episodeNumber");
          var airDateRaw = seasonEpisode.find(".MvTbTtl > span")?.text.trim();
          debugPrint("airDateRaw: $airDateRaw");
          var airDate = airDateRaw != null && airDateRaw != ""
              ? DateTime.parse("${reverseString(airDateRaw)} 00:00:00.000")
              : DateTime.now();
          debugPrint("airDate: $airDate");
          episodeList.add(
            DetailedEpisodeModel(
              episodeId: "/episode/$episodeId/",
              episodeName: episodeName,
              seasonNumber: int.parse(seasonNumber),
              episodeNumber: (int.parse(episodeNumber) + offset).toString(),
              episodeUrl: episodeUrl,
              episodeThumbnail: episodeThumbnail,
              airDate: airDate,
              relativeEpisodeNumber: double.parse(episodeNumber).round(),
            ),
          );
          index++;
          relativeEpisodeNumber++;
        }
        episodes.add(episodeList);
        offset += index;
        seasonsIndex++;
        relativeEpisodeNumber = 1;
        index = 0;
      }
      var finalEpisodes = <DetailedEpisodeModel>[];
      episodes.sort((a, b) => double.parse(
              (a.any((element) => element.seasonNumber != null)
                      ? a[0].seasonNumber!
                      : 1)
                  .toString())
          .compareTo(double.parse(
              (b.any((element) => element.seasonNumber != null)
                      ? b[0].seasonNumber!
                      : 1)
                  .toString())));
      for (var episodeList in episodes) {
        episodeList.sort((a, b) => double.parse(a.episodeNumber)
            .compareTo(double.parse(b.episodeNumber)));
      }
      for (var episodeList in episodes) {
        finalEpisodes.addAll(episodeList);
      }
      var relatedVideos = <BaseRelatedVideosModel>[];
      try {
        var trailerId = soup
            .find("#funciones_public_sol-js-extra")
            ?.text
            .trim()
            .split("\\/embed\\/")[1]
            .split("\\")[0];
        if (trailerId != null) {
          relatedVideos.add(BaseRelatedVideosModel(
            videoId: trailerId,
            videoUrl: 'https://www.youtube.com/watch?v=$trailerId',
            videoTitle: '$title Trailer',
            videoThumbnail: null,
          ));
        }
      } catch (e) {
        debugPrint(e.toString());
      }
      var relatedItems = <BaseItemModel>[];
      for (var item
          in soup.find(".Main > section")?.findAll("div.TPost") ?? []) {
        var id = item
            .find("a")!
            .attributes["href"]!
            .trim()
            .replaceFirst(_baseUrl, "");
        var title = item.find("h2.Title")!.text.trim();
        var imageUrl = formatUrl(
            item.find("figure > img")!.attributes["data-src"]!.trim());
        var languages = <LanguageType>[];
        relatedItems.add(
          BaseItemModel(
            source: BaseSourceModel(
              id: "all-movies-for-you",
              type: SourceType.multi,
              sourceName: "AllMoviesForYou",
              baseUrl: _baseUrl,
            ),
            id: id,
            title: title,
            imageUrl: imageUrl,
            languages: languages,
          ),
        );
      }

      return BaseDetailedItemModel(
        source: BaseSourceModel(
          id: "all-movies-for-you",
          type: SourceType.multi,
          sourceName: "AllMoviesForYou",
          baseUrl: _baseUrl,
        ),
        id: id,
        title: title,
        imageUrl: imageUrl,
        languages: languages,
        coverImageUrl: coverImageUrl,
        episodeCount: episodeCount,
        genres: genres,
        rating: rating,
        type: type,
        status: airingStatus,
        synopsis: synopsis,
        releaseDate: releaseDate,
        episodes: finalEpisodes,
        relatedVideos: relatedVideos,
        relatedItems: relatedItems,
      );
    }
  }
}
