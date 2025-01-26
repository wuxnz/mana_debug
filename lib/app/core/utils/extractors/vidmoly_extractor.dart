import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../helpers/m3u8_helpers.dart';

class VidmolyExtractor {
  RegExp magEx = RegExp(r'file:"(.*?)"');

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var headers = {
      "Referer": "https://vidmoly.to/",
    };
    String newEmbedUrl =
        "https://vidmoly.to/${sourceInfo.embedUrl!.split("/").last}";

    var embedLinkRes = await http.get(Uri.parse(newEmbedUrl), headers: headers);

    var embedLinkSoup = BeautifulSoup(embedLinkRes.body);
    var magicString = embedLinkSoup
        .findAll("body > script")
        .firstWhere((element) => magEx.hasMatch(element.text))
        .text
        .trim()
        .replaceAll("\n", "")
        .replaceAll("\t", "")
        .replaceAll(" ", "");

    var videoData = magEx.firstMatch(magicString);

    var masterUrl = videoData?.group(1);
    List<VideoSourceModel> videoSources = [];
    var m3u8Helper = M3U8HelperTwo();
    if (masterUrl != null) {
      List<M3U8pass> videoInfo = await m3u8Helper.m3u8Generation(
          masterUrl, VideoResolution.multi, headers);

      videoInfo
          .map((e) => videoSources.add(VideoSourceModel(
              source: VideoSourceInfoModel(
                baseUrl: sourceInfo.baseUrl,
                sourceName: sourceInfo.sourceName,
                sourceId: sourceInfo.sourceId,
              ),
              sourceUrlDescription: sourceInfo.language == null
                  ? "Vidmoly ${e.dataQuality}"
                  : "Vidmoly ${e.dataQuality} (${languageTypeToString(sourceInfo.language!)})",
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
              headers: headers)))
          .toList();
      return videoSources;
    }
    return [];
  }
}
