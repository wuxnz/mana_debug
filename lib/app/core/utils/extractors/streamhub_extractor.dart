import 'package:mana_debug/app/core/values/constants.dart';

import '../../../data/models/sources/base_model.dart';
import '../helpers/m3u8_helpers.dart';

class StreamhubExtractor {
  static RegExp preLinkRegex =
      RegExp(r"(streamhub).*\|width\|(.*)\|(.*)\|to\|");
  static RegExp linkRegex = RegExp(r"[A-Za-z\d]+");

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var videoUrlBeginning = preLinkRegex.firstMatch(sourceInfo.magicString!);
    var videoUrlBeginningStr =
        "${videoUrlBeginning!.group(3)}.${videoUrlBeginning.group(1)}.${videoUrlBeginning.group(2)}";
    var videoUrlBase =
        sourceInfo.baseUrl.replaceFirst("//", "//$videoUrlBeginning.");
    var videLinkParts = sourceInfo.magicString!
        .split("|application|type|")
        .last
        .split("|sources'.split")
        .first
        .split("|")
        .reversed
        .toList();
    var numNum = videLinkParts.length - 3;
    var index = 1;
    String middle = "";
    while (index <= numNum) {
      if (index == 1) {
        middle += videLinkParts[index];
      } else if (index != numNum) {
        middle += ",${videLinkParts[index]}";
      } else {
        middle += ",.${videLinkParts[index]}";
      }
      index++;
    }
    var videoUrl =
        "https://$videoUrlBeginningStr/${videLinkParts.first}/$middle/${videLinkParts[numNum + 1]}.${videLinkParts.last}";
    List<VideoSourceModel> videoSources = [];
    var m3u8Helper = M3U8HelperTwo();
    List<M3U8pass> videoInfo =
        await m3u8Helper.m3u8Generation(videoUrl, VideoResolution.multi, {
      'Referer': "${sourceInfo.baseUrl}/",
      'User-Agent': streamhubUserAgent,
    });

    videoInfo
        .map((e) => videoSources.add(VideoSourceModel(
                source: VideoSourceInfoModel(
                  baseUrl: sourceInfo.baseUrl,
                  sourceName: sourceInfo.sourceName,
                  sourceId: sourceInfo.sourceId,
                ),
                sourceUrlDescription: sourceInfo.language == null
                    ? "Streamhub ${e.dataQuality}"
                    : "Streamhub ${e.dataQuality} (${languageTypeToString(sourceInfo.language!)})",
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
                headers: {
                  'Referer': "${sourceInfo.baseUrl}/",
                  'User-Agent': streamhubUserAgent,
                })))
        .toList();
    return videoSources;
  }
}
