import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/helpers/m3u8_helpers.dart';
import 'package:mana_debug/app/core/values/constants.dart';

import '../../../data/models/sources/base_model.dart';

class MCloudExtractor {
  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var embedHeaders = {
      "Referer": Uri.parse(sourceInfo.embedUrl!).host,
    };
    var embedId = sourceInfo.embedUrl!.split("/").last.split("?").first;

    var resolveUrl = "$nineAnimeConsumet?query=$embedId&action=mcloud";

    var embedResponse =
        await http.get(Uri.parse(resolveUrl), headers: embedHeaders);

    var erJson = jsonDecode(embedResponse.body);
    var rawSources = erJson["data"]["media"]["sources"];
    var rawSourcesLinks =
        rawSources.map((e) => e["file"]).toList().cast<String>();

    List<VideoSourceModel> sources = [];
    for (var rawSource in rawSourcesLinks) {
      var sourceHeaders = {
        "Connection": "keep-alive",
        "Host": Uri.parse(rawSource).host,
        "Referer": "${Uri.parse(sourceInfo.embedUrl!).origin}/",
        "User-Agent": vizCloudUserAgent,
      };
      var m3u8Helper = M3U8HelperTwo();
      List<M3U8pass> videoInfo = await m3u8Helper.m3u8GenerationFileName(
          rawSource, VideoResolution.multi, sourceHeaders);

      videoInfo
          .map((e) => sources.add(VideoSourceModel(
                source: VideoSourceInfoModel(
                  baseUrl: sourceInfo.baseUrl,
                  sourceName: sourceInfo.sourceName,
                  sourceId: sourceInfo.sourceId,
                ),
                sourceUrlDescription: sourceInfo.language == null
                    ? "${sourceInfo.sourceName} ${e.dataQuality}"
                    : "${sourceInfo.sourceName} ${e.dataQuality} (${languageTypeToString(sourceInfo.language!)})",
                videoUrl: e.dataUrl,
                resolution: e.dataQuality == "1080"
                    ? VideoResolution.p1080
                    : e.dataQuality == "720"
                        ? VideoResolution.p720
                        : e.dataQuality == "480"
                            ? VideoResolution.p480
                            : e.dataQuality == "360"
                                ? VideoResolution.p360
                                : VideoResolution.other,
                quality: e.dataQuality == "Auto" ? 0 : int.parse(e.dataQuality),
                // headers: {
                //   "User-Agent": streamsSBUserAgent,
                // }
              )))
          .toList();
    }
    return sources;
  }
}
