import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../../../../core/utils/formatters/time_formatters.dart';
import '../../../../core/utils/network/cloudflare_client.dart';
import '../../../../core/utils/network/interceptor_client.dart';

class AllAnimeSource {
  static const String _baseUrl = 'https://allanime.to';
  static const String _apiHost = 'https://api.allanime.day/api?';
  static final BaseSourceModel _source = BaseSourceModel(
    id: 'all-anime',
    type: SourceType.anime,
    sourceName: 'AllAnime',
    baseUrl: _baseUrl,
  );
  static final _cloudflareClient = CloudFlareClient();
  static final _interceptor = InterceptorClient();
  static const String idHash =
      "9d7439c90f203e534ca778c4901f9aa2d3ad42c06243ab2c5e6b79612af32028";
  static const String episodeInfoHash =
      "c8f3ac51f598e630a1d09d7f7fb6924cff23277f354a23e473b962a367880f7d";
  static const String searchHash =
      "06327bc10dd682e1ee7e07b6db9c16e9ad2fd56c1b769e47513128cd5c9fc77a";
  static const String videoServerHash =
      "5f1a64b73793cc2234a389cf3a8f93ad82de7043017dd551f38f65b89daa65e0";
  static final _apiHeaders = {
    "Referer": "$_baseUrl/",
  };
  static const String imageUrlBase =
      "https://wp.youtube-anime.com/aln.youtube-anime.com/";

  List<BaseItemModel> _parseResultsFromJson(List resultsRaw) {
    var results = <BaseItemModel>[];
    for (var item in resultsRaw) {
      var languages = <LanguageType>[];
      EpisodeCount? episodeCount;
      if (item['availableEpisodes'] != null) {
        if (item['availableEpisodes']['sub'] != null) {
          languages.add(LanguageType.sub);
        }
        if (item['availableEpisodes']['dub'] != null) {
          languages.add(LanguageType.dub);
        }
        episodeCount = EpisodeCount(
          episodeCount: item['availableEpisodes']['sub'] ??
              (item['availableEpisodes']['dub'] ?? 0),
          altEpisodeCount: item['availableEpisodes']['sub'] != null
              ? item['availableEpisodes']['dub']
              : 0,
        );
      }
      results.add(BaseItemModel(
          source: _source,
          id: item["_id"],
          title: item["englishName"] ?? item["name"],
          imageUrl: item["thumbnail"] != null
              ? item["thumbnail"]?.startsWith("images3")
                  ? imageUrlBase + item["thumbnail"]
                  : item["thumbnail"].contains("cdn.myanimelist.net") ||
                          item["thumbnail"].contains("i.ibb.co")
                      ? item['thumbnail'].replaceFirst(
                          "https://", "https://wp.youtube-anime.com/")
                      : item['thumbnail']
              : "",
          languages: languages,
          episodeCount: episodeCount));
    }
    return results;
  }

  Future<BaseCategoryModel> scrapeSearch(String query) async {
    var url =
        '${_apiHost}variables={%22search%22:{%22query%22:%22$query%22},%22limit%22:26,%22page%22:1,%22countryOrigin%22:%22ALL%22}&extensions={%22persistedQuery%22:{%22version%22:1,%22sha256Hash%22:%22$searchHash%22}}';
    var response = await http.get(Uri.parse(url), headers: _apiHeaders);
    var rJson = jsonDecode(response.body);
    var resultsRaw = rJson['data']['shows']['edges'] as List;
    var results = _parseResultsFromJson(resultsRaw);
    return BaseCategoryModel(
      categoryName: 'AllAnime',
      items: results,
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

  Future<BaseCategoryModel> _parseCategory(
      String url, String categoryName, List<String> ids) async {
    var response = await http.get(Uri.parse(url), headers: _apiHeaders);
    var rJson = jsonDecode(response.body);
    var resultsRaw = [];
    if (ids.length == 2) {
      resultsRaw = rJson['data'][ids[0]][ids[1]][0]['anyCard'] != null
          ? (rJson['data'][ids[0]][ids[1]] as List)
              .map((e) => e['anyCard'])
              .toList()
          : rJson['data'][ids[0]][ids[1]] as List;
    } else {
      resultsRaw = rJson['data'][ids[0]][0]['anyCard'] != null
          ? (rJson['data'][ids[0]] as List).map((e) => e['anyCard']).toList()
          : rJson['data'][ids[0]] as List;
    }
    var results = _parseResultsFromJson(resultsRaw);
    return BaseCategoryModel(
      categoryName: categoryName,
      items: results,
      source: this,
    );
  }

  List<Future<BaseCategoryModel>> getCategories() {
    return [
      _parseCategory(
          "${_apiHost}variables={%22search%22:{%22sortBy%22:%22Recent%22},%22limit%22:26,%22page%22:1,%22translationType%22:%22sub%22,%22countryOrigin%22:%22ALL%22}&extensions={%22persistedQuery%22:{%22version%22:1,%22sha256Hash%22:%2206327bc10dd682e1ee7e07b6db9c16e9ad2fd56c1b769e47513128cd5c9fc77a%22}}",
          "Latest Updates",
          ["shows", "edges"]),
      _parseCategory(
          "${_apiHost}variables={%22type%22:%22anime%22,%22size%22:20,%22dateRange%22:1,%22page%22:1,%22allowAdult%22:false,%22allowUnknown%22:false}&extensions={%22persistedQuery%22:{%22version%22:1,%22sha256Hash%22:%221fc9651b0d4c3b9dfd2fa6e1d50b8f4d11ce37f988c23b8ee20f82159f7c1147%22}}",
          "Popular",
          ["queryPopular", "recommendations"]),
      _parseCategory(
          "${_apiHost}variables={%22format%22:%22anime%22,%22allowAdult%22:false}&extensions={%22persistedQuery%22:{%22version%22:1,%22sha256Hash%22:%22c3fd993b7ec3ce68c08afc650f42f57c67bcb91c0e6548c9491066ce56262eae%22}}",
          "Random",
          ["queryRandomRecommendation"]),
      _parseCategory(
          "${_apiHost}variables={%22search%22:{%22slug%22:%22movie-anime%22,%22format%22:%22anime%22,%22tagType%22:%22upcoming%22,%22name%22:%22Trending%20Movies%22}}&extensions={%22persistedQuery%22:{%22version%22:1,%22sha256Hash%22:%22c8364522deb477026ee46fd926d0dc107919c5858704d5f79dd949a4c058665f%22}}",
          "Trending Movies",
          ["queryListForTag", "edges"]),
    ];
  }

  Future<List<BaseCategoryModel>?> scrapeCategories() async {
    return await Future.wait(getCategories());
  }

  Future<List<RawVideoSourceInfoModel>> getVideoSources(
      String episodeId) async {
    debugPrint("episodeId: $episodeId");
    bool both = false;
    String url = "";
    if (episodeId.startsWith(";;")) {
      both = true;
      url = episodeId.substring(2);
    }
    debugPrint("both: $both");
    debugPrint("url: $url");
    var sources = <RawVideoSourceInfoModel>[];
    if (both == true) {
      var subUrl = url.replaceFirst("{LANGUAGE}", "sub");
      var dubUrl = url.replaceFirst("{LANGUAGE}", "dub");
      var subResponse = await http.get(Uri.parse(subUrl), headers: _apiHeaders);
      var dubResponse = await http.get(Uri.parse(dubUrl), headers: _apiHeaders);
      var subJson = jsonDecode(subResponse.body);
      var dubJson = jsonDecode(dubResponse.body);
      for (var item in subJson['data']['episode']['sourceUrls']) {
        if (!item['sourceUrl'].toString().startsWith("http")) {
          if (item['sourceName'] == "Yt-HD" &&
              item['mobile'] != null &&
              item['mobile']['downloadUrl'] != null) {
            sources.add(RawVideoSourceInfoModel(
              embedUrl: item['mobile']['downloadUrl'],
              sourceId: 'all-anime-extractor',
              sourceName: item['sourceName'],
              baseUrl: Uri.parse(item['mobile']['downloadUrl']).origin,
              language: LanguageType.sub,
            ));
          } else if (item['sourceName'] == "S-mp4" &&
              item['downloads']['downloadUrl'] != null) {
            sources.add(RawVideoSourceInfoModel(
              embedUrl: item['downloads']['downloadUrl'],
              sourceId: 'all-anime-extractor',
              sourceName: item['sourceName'],
              baseUrl: Uri.parse(item['downloads']['downloadUrl']).origin,
              language: LanguageType.sub,
            ));
          }
        } else {
          String? sourceId;
          String? sourceName;
          Uri uri = Uri.parse(item['sourceUrl']);
          debugPrint("uri: $uri");
          if (uri.path.contains("apivtwo")) {
            sourceId = "all-anime";
            sourceName = "AllAnime";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("taku")) {
            sourceId = "goload";
            sourceName = "Gogo";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("sb")) {
            sourceId = "streamsb";
            sourceName = "StreamSB";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("fplayer")) {
            sourceId = "fplayer";
            sourceName = "FPlayer";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("dood")) {
            sourceId = "doodstream";
            sourceName = "DoodStream";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("mp4")) {
            sourceId = "mp4upload";
            sourceName = "MP4Upload";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("lare")) {
            sourceId = "streamlare";
            sourceName = "Streamlare";
          } else if (uri.toString().contains("//ok.")) {
            sourceId = "okru";
            sourceName = "OK";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("filemoon")) {
            sourceId = "filemoon";
            sourceName = "FileMoon";
          }
          sources.add(RawVideoSourceInfoModel(
            embedUrl: item['sourceUrl'],
            sourceId: sourceId ?? "",
            sourceName: sourceName ?? "",
            baseUrl: Uri.parse(item['sourceUrl']).origin,
            language: LanguageType.sub,
          ));
        }
      }
      for (var item in dubJson['data']['episode']['sourceUrls']) {
        if (!item['sourceUrl'].toString().startsWith("http")) {
          if (item['sourceName'] == "Yt-HD" &&
              item['mobile'] != null &&
              item['mobile']['downloadUrl'] != null) {
            sources.add(RawVideoSourceInfoModel(
              embedUrl: item['mobile']['downloadUrl'],
              sourceId: 'all-anime-extractor',
              sourceName: item['sourceName'],
              baseUrl: Uri.parse(item['mobile']['downloadUrl']).origin,
              language: LanguageType.dub,
            ));
          } else if (item['sourceName'] == "S-mp4" &&
              item['downloads']['downloadUrl'] != null) {
            sources.add(RawVideoSourceInfoModel(
              embedUrl: item['downloads']['downloadUrl'],
              sourceId: 'all-anime-extractor',
              sourceName: item['sourceName'],
              baseUrl: Uri.parse(item['downloads']['downloadUrl']).origin,
              language: LanguageType.dub,
            ));
          }
        } else {
          String? sourceId;
          String? sourceName;
          Uri uri = Uri.parse(item['sourceUrl']);
          debugPrint("uri: $uri");
          if (uri.path.contains("apivtwo")) {
            sourceId = "all-anime";
            sourceName = "AllAnime";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("taku")) {
            sourceId = "goload";
            sourceName = "Gogo";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("sb")) {
            sourceId = "streamsb";
            sourceName = "StreamSB";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("fplayer")) {
            sourceId = "fplayer";
            sourceName = "FPlayer";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("dood")) {
            sourceId = "doodstream";
            sourceName = "DoodStream";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("mp4")) {
            sourceId = "mp4upload";
            sourceName = "MP4Upload";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("lare")) {
            sourceId = "streamlare";
            sourceName = "Streamlare";
          } else if (uri.toString().contains("//ok.")) {
            sourceId = "okru";
            sourceName = "OK";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("filemoon")) {
            sourceId = "filemoon";
            sourceName = "FileMoon";
          }
          sources.add(RawVideoSourceInfoModel(
            embedUrl: item['sourceUrl'],
            sourceId: sourceId ?? "",
            sourceName: sourceName ?? "",
            baseUrl: Uri.parse(item['sourceUrl']).origin,
            language: LanguageType.dub,
          ));
        }
      }
    } else {
      var language =
          episodeId.contains("%22sub%22") ? LanguageType.sub : LanguageType.dub;
      var response = await http.get(Uri.parse(episodeId), headers: _apiHeaders);
      var rJson = jsonDecode(response.body);
      for (var item in rJson['data']['episode']['sourceUrls']) {
        if (!item['sourceUrl'].toString().startsWith("http")) {
          if (item['sourceName'] == "Yt-HD" &&
              item['mobile'] != null &&
              item['mobile']['downloadUrl'] != null) {
            sources.add(RawVideoSourceInfoModel(
              embedUrl: item['mobile']['downloadUrl'],
              sourceId: 'all-anime-extractor',
              sourceName: item['sourceName'],
              baseUrl: Uri.parse(item['mobile']['downloadUrl']).origin,
              language: language,
            ));
          } else if (item['sourceName'] == "S-mp4" &&
              item['downloads'] != null &&
              item['downloads']['downloadUrl'] != null) {
            sources.add(RawVideoSourceInfoModel(
              embedUrl: item['downloads']['downloadUrl'],
              sourceId: 'all-anime-extractor',
              sourceName: item['sourceName'],
              baseUrl: Uri.parse(item['downloads']['downloadUrl']).origin,
              language: language,
            ));
          }
        } else {
          String? sourceId;
          String? sourceName;
          Uri uri = Uri.parse(item['sourceUrl']);
          debugPrint("uri: $uri");
          if (uri.path.contains("apivtwo")) {
            sourceId = "all-anime";
            sourceName = "AllAnime";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("taku")) {
            sourceId = "goload";
            sourceName = "Gogo";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("sb")) {
            sourceId = "streamsb";
            sourceName = "StreamSB";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("fplayer")) {
            sourceId = "fplayer";
            sourceName = "FPlayer";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("dood")) {
            sourceId = "doodstream";
            sourceName = "DoodStream";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("mp4")) {
            sourceId = "mp4upload";
            sourceName = "MP4Upload";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("lare")) {
            sourceId = "streamlare";
            sourceName = "Streamlare";
          } else if (uri.toString().contains("//ok.")) {
            sourceId = "okru";
            sourceName = "OK";
          } else if (uri.host
              .split(".")[uri.host.split(".").length - 2]
              .contains("filemoon")) {
            sourceId = "filemoon";
            sourceName = "FileMoon";
          }
          sources.add(RawVideoSourceInfoModel(
            embedUrl: item['sourceUrl'],
            sourceId: sourceId ?? "",
            sourceName: sourceName ?? "",
            baseUrl: Uri.parse(item['sourceUrl']).origin,
            language: language,
          ));
        }
      }
    }
    return sources;
  }

  Future<BaseDetailedItemModel> scrapeDetails(String id) async {
    var url =
        '${_apiHost}variables={%22_id%22:%22$id%22}&extensions={%22persistedQuery%22:{%22version%22:1,%22sha256Hash%22:%229d7439c90f203e534ca778c4901f9aa2d3ad42c06243ab2c5e6b79612af32028%22}}';
    var response = await http.get(Uri.parse(url), headers: _apiHeaders);
    var rJson = jsonDecode(response.body);
    var itemData = rJson['data']['show'];
    var title = itemData['englishName'] ?? itemData['name'];
    debugPrint("Title: $title");
    var imageUrl = itemData['thumbnail'].contains("cdn.myanimelist.net") ||
            itemData['thumbnail'].contains("i.ibb.co")
        ? itemData['thumbnail']
            .replaceFirst("https://", "https://wp.youtube-anime.com/")
        : itemData['thumbnail'];
    debugPrint("Image URL: $imageUrl");
    var languages = <LanguageType>[];
    EpisodeCount? episodeCount;
    if (itemData['availableEpisodesDetail'] != null) {
      var availableEpisodesDetail = itemData['availableEpisodesDetail'];
      if (availableEpisodesDetail['sub'] != null) {
        languages.add(LanguageType.sub);
      }
      if (availableEpisodesDetail['dub'] != null) {
        languages.add(LanguageType.dub);
      }
    }
    debugPrint("Languages: $languages");
    var coverImageUrl = itemData['banner'];
    debugPrint("Cover Image URL: $coverImageUrl");
    var genres = <Genre>[];
    if (itemData['tags'] != null) {
      for (var genre in itemData['tags']) {
        genres.add(Genre(name: genre));
      }
    }
    genres = genres.sublist(0, min(genres.length, 6));
    debugPrint("Genres: $genres");
    double? rating = itemData['score'];
    debugPrint("Rating: $rating");
    var type = itemTypeFromString(itemData['type'] ?? "");
    debugPrint("Type: $type");
    var status = itemData["status"] == "Finished"
        ? AiringStatus.completed
        : AiringStatus.airing;
    debugPrint("Status: $status");
    String synopsis = "";
    if (itemData['description'] != null) {
      synopsis = itemData['description']
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'&[^;]*;'), '')
          .replaceAll(RegExp(r'\n'), '')
          .replaceAll(RegExp(r'\t'), '');
    }
    debugPrint("Synopsis: $synopsis");
    var releaseDate = yearStringToDateTime(
        itemData['airedStart']['year']?.toString() ?? "0000");
    debugPrint("Release Date: $releaseDate");
    var endDate = yearStringToDateTime(
        itemData['airedEnd']['year']?.toString() ?? "0000");
    debugPrint("End Date: $endDate");
    List<DetailedEpisodeModel> episodes = [];
    var subEpsWithoutFirst = itemData['availableEpisodesDetail']['sub'] !=
                null &&
            itemData['availableEpisodesDetail']['sub'].last == "0"
        ? (itemData['availableEpisodesDetail']['sub'] as List)
            .sublist(0, itemData['availableEpisodesDetail']['sub'].length - 1)
        : itemData['availableEpisodesDetail']['sub'] ?? [];
    var dubEpsWithoutFirst = itemData['availableEpisodesDetail']['dub'] !=
                null &&
            itemData['availableEpisodesDetail']['dub'].last == "0"
        ? (itemData['availableEpisodesDetail']['dub'] as List)
            .sublist(0, itemData['availableEpisodesDetail']['dub'].length - 1)
        : itemData['availableEpisodesDetail']['dub'] ?? [];
    if (languages.length == 2) {
      for (var episode in subEpsWithoutFirst) {
        String episodeNumber;
        if (episode.contains(RegExp(r"\.\d+"))) {
          episodeNumber = (double.parse(episode) + 1).toString();
        } else {
          episodeNumber = (int.parse(episode) + 1).toString();
        }
        bool hasDub = (itemData['availableEpisodesDetail']['dub'] as List)
            .contains(episode);
        var episodeData = DetailedEpisodeModel(
          episodeId: hasDub
              ? ";;${_apiHost}variables={%22showId%22:%22$id%22,%22translationType%22:%22{LANGUAGE}%22,%22episodeString%22:%22$episode%22}&extensions={%22persistedQuery%22:{%22version%22:1,%22sha256Hash%22:%225f1a64b73793cc2234a389cf3a8f93ad82de7043017dd551f38f65b89daa65e0%22}}"
              : "${_apiHost}variables={%22showId%22:%22$id%22,%22translationType%22:%22sub%22,%22episodeString%22:%22$episode%22}&extensions={%22persistedQuery%22:{%22version%22:1,%22sha256Hash%22:%225f1a64b73793cc2234a389cf3a8f93ad82de7043017dd551f38f65b89daa65e0%22}}",
          episodeNumber: episode,
        );
        episodes.add(episodeData);
      }
    } else if (languages.length == 1) {
      if (languages[0] == LanguageType.sub) {
        for (var episode in subEpsWithoutFirst) {
          String episodeNumber;
          if (episode.contains(RegExp(r"\.\d+"))) {
            episodeNumber = (double.parse(episode) + 1).toString();
          } else {
            episodeNumber = (int.parse(episode) + 1).toString();
          }
          var episodeData = DetailedEpisodeModel(
            episodeId:
                "${_apiHost}variables={%22showId%22:%22$id%22,%22translationType%22:%22dub%22,%22episodeString%22:%22$episode%22}&extensions={%22persistedQuery%22:{%22version%22:1,%22sha256Hash%22:%225f1a64b73793cc2234a389cf3a8f93ad82de7043017dd551f38f65b89daa65e0%22}}",
            episodeNumber: episode,
          );
          episodes.add(episodeData);
        }
      } else {
        for (var episode in dubEpsWithoutFirst) {
          String episodeNumber;
          if (episode.contains(RegExp(r"\.\d+"))) {
            episodeNumber = (double.parse(episode) + 1).toString();
          } else {
            episodeNumber = (int.parse(episode) + 1).toString();
          }
          var episodeData = DetailedEpisodeModel(
            episodeId:
                "${_apiHost}variables={%22showId%22:%22$id%22,%22translationType%22:%22sub%22,%22episodeString%22:%22$episode%22}&extensions={%22persistedQuery%22:{%22version%22:1,%22sha256Hash%22:%225f1a64b73793cc2234a389cf3a8f93ad82de7043017dd551f38f65b89daa65e0%22}}",
            episodeNumber: episode,
          );
          episodes.add(episodeData);
        }
      }
    }
    // episodes = episodes.reversed.toList();
    debugPrint("Episodes: $episodes");
    episodes = episodes.reversed.toList();
    episodeCount = EpisodeCount(
      episodeCount: episodes.length,
      altEpisodeCount: 0,
    );
    debugPrint("Episode Count: $episodeCount");
    List<String>? otherTitles;
    for (var otherTitle in itemData['altNames']) {
      otherTitles ??= [];
      otherTitles.add(otherTitle);
    }
    debugPrint("Other Titles: $otherTitles");
    List<BaseActorModel> actors = [];
    if (itemData['characters'] != null) {
      for (var character in itemData['characters']) {
        actors.add(BaseActorModel(
          actorName: character['name']['full'],
          sourceId: 'all-anime',
          characterImageUrl: character['image']['large'],
          characterDescription: character['role'],
        ));
      }
    }
    debugPrint("Actors: $actors");
    List<BaseRelatedVideosModel> relatedVideos = [];
    for (var video in itemData['prevideos']) {
      relatedVideos.add(BaseRelatedVideosModel(
        videoId: video,
        videoUrl: "https://www.youtube.com/watch?v=$video",
      ));
    }
    debugPrint("Related Videos: $relatedVideos");
    return BaseDetailedItemModel(
      source: _source,
      id: id,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
      episodeCount: episodeCount,
      coverImageUrl: coverImageUrl,
      genres: genres,
      rating: rating,
      type: type,
      status: status,
      synopsis: synopsis,
      releaseDate: releaseDate,
      endDate: endDate,
      episodes: episodes,
      otherTitles: otherTitles,
      actors: actors,
      relatedVideos: relatedVideos,
    );
  }
}
