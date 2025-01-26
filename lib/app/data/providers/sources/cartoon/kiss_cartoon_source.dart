import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/formatters/time_formatters.dart';
import 'package:mana_debug/app/core/utils/helpers/encode_decode.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../../../services/source_service.dart';

class KissCartoonSource {
  static const _baseUrl = "https://thekisscartoon.com";
  static const _ajaxUrl = "https://thekisscartoon.com/ajax-get-link-stream";
  static final BaseSourceModel _source = BaseSourceModel(
      id: "the-kiss-cartoon",
      type: SourceType.cartoon,
      sourceName: "TheKissCartoon",
      baseUrl: _baseUrl);

  BaseItemModel _parseSearchPageItem(Bs4Element item) {
    var id = item.find(".thumbnail > a")!.attributes["href"]!;
    var title = item.find(".title > a")!.text.trim();
    var imageUrl = item.find(".thumbnail > a > img")!.attributes["src"]!;
    var languages = <LanguageType>[LanguageType.dub];
    var rating = double.tryParse(
        item.find(".rating")?.text.trim().split(" ").last ?? "fail");
    return BaseItemModel(
        source: _source,
        id: id,
        title: title,
        imageUrl: imageUrl,
        languages: languages,
        rating: rating);
  }

  BaseItemModel _parseHomePageTopItem(Bs4Element item) {
    var id = item.find(".image > a")!.attributes["href"]!;
    var title = item.find(".data > .title")!.text.trim();
    var imageUrl = item.find(".image > a > img")!.attributes["data-lazy-src"]!;
    var languages = <LanguageType>[LanguageType.dub];
    return BaseItemModel(
      source: _source,
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
    );
  }

  BaseItemModel _parseHomePageItem(Bs4Element item) {
    var id = item.findAll("a").last.attributes["href"]!;
    if (id.contains("/episode/")) {
      id = id
          .replaceFirst("/episode/", "/tvshows/")
          .split(RegExp(r"-episode-"))
          .first;
    }
    var title = item.find(".data > h3 > a")!.text.trim();
    var imageUrl = item.find(".poster > img")!.attributes["data-lazy-src"]!;
    var languages = <LanguageType>[LanguageType.dub];
    var episodes = int.tryParse(
            item.find(".featu")?.text.trim().split("/").first.trim() ??
                "fail") ??
        1;
    EpisodeCount episodeCount = EpisodeCount(
      episodeCount: episodes,
      altEpisodeCount: 0,
    );
    var rating = double.tryParse(item.find(".rating")?.text.trim() ?? "fail");
    return BaseItemModel(
        source: _source,
        id: id,
        title: title,
        imageUrl: imageUrl,
        languages: languages,
        episodeCount: episodeCount,
        rating: rating);
  }

  Future<BaseCategoryModel> scrapeSearch(String query, {int page = 1}) async {
    var response =
        await http.get(Uri.parse("$_baseUrl/?s=${encodeURIComponent(query)}"));
    var soup = BeautifulSoup(response.body);
    var items = soup.findAll(".result-item");
    var parsedItems = items.map((e) => _parseSearchPageItem(e)).toList();
    return BaseCategoryModel(
        categoryName: "TheKissCartoon", items: parsedItems, source: this);
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

  List<Future<BaseCategoryModel>> getCategories(List<Bs4Element> soup) {
    return [];
  }

  Future<List<BaseCategoryModel>?> scrapeCategories() async {
    var response = await http.get(Uri.parse(_baseUrl));
    var soup = BeautifulSoup(response.body);
    List<BaseCategoryModel> categories = [];
    var categoryOne = soup.find("#slider-tvshows")?.findAll("article") ?? [];
    var categoryOneParsed =
        categoryOne.map((e) => _parseHomePageTopItem(e)).toList();
    categories.add(BaseCategoryModel(
        categoryName: "Top TV Shows", items: categoryOneParsed, source: this));
    var categoryTwo = soup.find("#dt-episodes")?.findAll("article") ?? [];
    var categoryTwoParsed =
        categoryTwo.map((e) => _parseHomePageItem(e)).toList();
    categories.add(BaseCategoryModel(
        categoryName: "New Episodes", items: categoryTwoParsed, source: this));
    var categoryThreeAndFourRaw = soup.findAll("div.items").sublist(1);
    var categoryThree = categoryThreeAndFourRaw.first.findAll("article");
    var categoryThreeParsed =
        categoryThree.map((e) => _parseHomePageItem(e)).toList();
    categories.add(BaseCategoryModel(
        categoryName: "Movies", items: categoryThreeParsed, source: this));
    var categoryFour = categoryThreeAndFourRaw.last.findAll("article");
    var categoryFourParsed =
        categoryFour.map((e) => _parseHomePageItem(e)).toList();
    categories.add(BaseCategoryModel(
        categoryName: "TV Shows", items: categoryFourParsed, source: this));
    return categories;
  }

  Future<List<RawVideoSourceInfoModel>> getVideoSources(
      String episodeId) async {
    var response = await http.get(Uri.parse(episodeId));
    var soup = BeautifulSoup(response.body);
    RegExp filmIdRegex = RegExp(r'var filmId = "(\d+)');
    var filmId = filmIdRegex.firstMatch(response.body)?.group(1);
    var sourcesRaw = soup.findAll("a.player-wrapper");
    var sourceNames =
        sourcesRaw.map((e) => e.className.split(" ").first).toList();

    var sourceNamesCapitalized =
        sourceNames.map((e) => e[0].toUpperCase() + e.substring(1)).toList();
    List<RawVideoSourceInfoModel> sourceInfo = [];
    var index = 0;
    for (var sourceName in sourceNames) {
      var serverString = "$_ajaxUrl/?server=$sourceName&filmId=$filmId";
      var serverResponse = await http.get(Uri.parse(serverString));
      var serverUrl = serverResponse.body;
      sourceInfo.add(RawVideoSourceInfoModel(
        embedUrl: serverUrl,
        sourceId: sourceName,
        sourceName: sourceNamesCapitalized[index],
        baseUrl: _baseUrl,
        extractor: SourceService().detectExtractor(sourceName),
      ));
      index++;
    }
    return sourceInfo;
  }

  Future<BaseDetailedItemModel> scrapeDetails(String id) async {
    var response = await http.get(Uri.parse(id));
    var soup = BeautifulSoup(response.body);

    var title = soup.find(".data > h1")!.text.trim();
    var imageUrl = soup.find(".poster > img")!.attributes["data-lazy-src"]!;
    var languages = <LanguageType>[LanguageType.dub];
    var coverImageUrl =
        soup.find(".g-item > a > img")?.attributes["data-lazy-src"]!;
    var episodesRaw = soup.findAll("ul.episodios > li");
    EpisodeCount episodeCount = EpisodeCount(
      episodeCount: episodesRaw.length,
      altEpisodeCount: 0,
    );
    List<Genre> genres = [];
    for (var genre in soup.findAll(".sgeneros > a")) {
      genres.add(Genre(
        id: genre.attributes["href"]!,
        name: genre.text.trim(),
      ));
    }
    var rating =
        double.tryParse(soup.find("#repimdb > strong")?.text.trim() ?? "fail");
    var type = ItemType.cartoon;
    var statusAndReleaseDate = soup.findAll(".mvici-right > p");
    var status =
        statusAndReleaseDate.first.findAll("a").last.text.trim() == "Completed"
            ? AiringStatus.completed
            : AiringStatus.airing;
    var synopsis = soup.find(".wp-content > p")!.text.trim();
    var releaseDate = yearStringToDateTime(
      statusAndReleaseDate.last.findAll("a").last.text.trim(),
    );
    List<DetailedEpisodeModel> episodes = [];
    if (id.contains("/tvshows/")) {
      for (var episode in episodesRaw) {
        var episodeId = episode.find("a")?.attributes["href"] ?? "";
        var episodeName = episode.find("a")!.text.trim();
        var episodeNumber = episode.find(".numerando")!.text.trim();
        episodes.add(DetailedEpisodeModel(
          episodeId: episodeId,
          episodeName: episodeName,
          episodeUrl: episodeId,
          episodeNumber: episodeNumber,
        ));
      }
    } else {
      var episodeId = id;
      var episodeName = title;
      var episodeNumber = "1";
      episodes.add(DetailedEpisodeModel(
        episodeId: episodeId,
        episodeName: episodeName,
        episodeUrl: episodeId,
        episodeNumber: episodeNumber,
      ));
      type = ItemType.movie;
    }
    var otherTitles = <String>[];
    var otherTitle = soup.find(".custom_fields > span.valor")?.text.trim();
    if (otherTitle != null) {
      otherTitles.add(otherTitle);
    }
    List<BaseItemModel> relatedItems = [];
    for (var relatedItem in soup.findAll("#single_relacionados article")) {
      var relatedItemId = relatedItem.find("a")!.attributes["href"]!;
      var relatedItemTitle = relatedItem.find("img")!.attributes["alt"]!.trim();
      var relatedItemImageUrl =
          relatedItem.find("img")?.attributes["data-lazy-src"] ??
              relatedItem.find("img")!.attributes["src"]!;
      relatedItems.add(BaseItemModel(
        source: _source,
        id: relatedItemId,
        title: relatedItemTitle,
        imageUrl: relatedItemImageUrl,
        languages: [LanguageType.dub],
      ));
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
      status: status,
      synopsis: synopsis,
      releaseDate: releaseDate,
      episodes: episodes,
      otherTitles: otherTitles,
      relatedItems: relatedItems,
    );
  }
}
