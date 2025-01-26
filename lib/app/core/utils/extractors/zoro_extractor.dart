import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/values/constants.dart';
import 'package:mana_debug/app/data/models/services/external_helper_services_models/ani_skip.dart';

import '../../../data/models/sources/base_model.dart';

class ZoroExtracor {
  static const String _baseUrl = 'https://api.consumet.org/anime/zoro/watch?';
  static Map<String, Map<String, String>?> headers = {
    "Vidstreaming": {
      "Accept": "*/*",
      "Origin": "https://rapid-cloud.co",
      "Referer": "https://rapid-cloud.co/",
      "User-Agent": rabbitStreamUserAgent,
    },
    "Vidcloud": {
      "Accept": "*/*",
      "Origin": "https://rapid-cloud.co",
      "Referer": "https://rapid-cloud.co/",
      "User-Agent": rabbitStreamUserAgent,
    },
    "StreamSB": {
      "UserAgent": streamsSBUserAgent,
    },
    "StreamTape": null
  };

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var episodeIdAndEp = sourceInfo.embedUrl!.split('?ep=');
    var subUrl =
        "${_baseUrl}episodeId=${episodeIdAndEp[0]}\$episode\$${episodeIdAndEp[1]}\$sub?server=${sourceInfo.sourceName.toLowerCase()}";
    var dubUrl =
        "${_baseUrl}episodeId=${episodeIdAndEp[0]}\$episode\$${episodeIdAndEp[1]}\$dub?server=${sourceInfo.sourceName.toLowerCase()}";
    List<http.Response> responses = [];
    List<LanguageType> languages = [];
    if (sourceInfo.language == LanguageType.multi) {
      responses.add(await http.get(Uri.parse(subUrl)));
      languages.add(LanguageType.sub);
      responses.add(await http.get(Uri.parse(dubUrl)));
      languages.add(LanguageType.dub);
    } else if (sourceInfo.language == LanguageType.sub) {
      responses.add(await http.get(Uri.parse(subUrl)));
      languages.add(LanguageType.sub);
    } else if (sourceInfo.language == LanguageType.dub) {
      responses.add(await http.get(Uri.parse(dubUrl)));
      languages.add(LanguageType.dub);
    }
    List<VideoSourceModel> sources = [];
    int index = 0;
    for (var response in responses) {
      var rJson = jsonDecode(response.body);
      var rawSources = rJson["sources"];
      List<SubtitlesModel> subtitles = [];
      var rawSubtitles = rJson["subtitles"];
      for (var rawSubtitle in rawSubtitles) {
        subtitles.add(SubtitlesModel(
          subtitleUrl: rawSubtitle["url"],
          subtitleName: rawSubtitle["lang"],
          subtitleLanguage: rawSubtitle["lang"],
        ));
      }
      AniSkipSkipData? opSkipData;
      if (rJson["intro"] != null) {
        opSkipData = AniSkipSkipData(
          startTime: double.parse(rJson["intro"]["start"].toString()),
          endTime: double.parse(rJson["intro"]["end"].toString()),
        );
      }
      for (var rawSource in rawSources) {
        var source = VideoSourceModel(
          source: VideoSourceInfoModel(
            baseUrl: sourceInfo.baseUrl,
            sourceName: sourceInfo.sourceName,
            sourceId: sourceInfo.sourceId,
          ),
          sourceUrlDescription: sourceInfo.language != LanguageType.multi
              ? "${sourceInfo.sourceName} ${rawSource["quality"]}"
              : "${sourceInfo.sourceName} ${rawSource["quality"]} (${languageTypeToString(languages[index])})",
          videoUrl: rawSource["url"],
          resolution: videoResolutionFromString(rawSource["quality"]),
          quality: rawSource["quality"] == "auto"
              ? 0
              : int.parse(rawSource["quality"].replaceAll("p", "")),
          subtitles: subtitles,
          opSkipData: opSkipData,
        );
        sources.add(source);
      }
      index++;
    }
    return sources;
  }
}
