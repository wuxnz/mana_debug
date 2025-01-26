import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/sources/base_model.dart';
import '../helpers/m3u8_helpers.dart';

class FilemoonExtractor {
  static RegExp singleMagEx = RegExp(r'&\d+=(\d\d+)&');
  static RegExp multiMagExOne = RegExp(r'data\|(.*)\|video_ad\|');
  static RegExp multiMagExTwo = RegExp(r'\|image\|(.*)\|sources\|');

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var response = await http.get(Uri.parse(sourceInfo.embedUrl!));
    var soup = BeautifulSoup(response.body);
    var script = soup
        .findAll('script')
        .firstWhere((element) => element.text.contains("eval("))
        .text;
    var srvMatch = singleMagEx.firstMatch(script);
    var srv = srvMatch?.group(1);
    var sAndFMatch = multiMagExOne.firstMatch(script);
    var s = sAndFMatch?.group(1)?.split("|").first;
    var f = sAndFMatch?.group(1)?.split("|")[1];
    var allOthers = multiMagExTwo.firstMatch(script)?.group(1);
    var others = allOthers!
        .toString()
        .replaceAll("||", "|")
        .split("|")
        .reversed
        .toList();
    debugPrint("FilemoonExtractor others: $others");
    var masterUrl =
        "https://${others[0]}.${others[1]}.${others[2]}.${others[3]}.com/${others[4]}/${others[5]}/${others[6]}/${others[7]}/${others[8]}.${others[9]}?t=${others[10]}-${others[11]}&s=$s&e=${others[12]}&f=$f&srv=$srv&asn=${others[15]}&sp=${others[17]}";
    debugPrint("FilemoonExtractor masterUrl: $masterUrl");
    List<VideoSourceModel> sources = [];
    if (masterUrl.contains(".m3u8")) {
      var m3u8Helper = M3U8HelperTwo();
      List<M3U8pass> videoInfo = await m3u8Helper.m3u8Generation(
          masterUrl, VideoResolution.multi, null);

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
              )))
          .toList();
    } else {
      sources.add(VideoSourceModel(
        source: VideoSourceInfoModel(
          baseUrl: sourceInfo.baseUrl,
          sourceName: sourceInfo.sourceName,
          sourceId: sourceInfo.sourceId,
        ),
        sourceUrlDescription: sourceInfo.language == null
            ? "${sourceInfo.sourceName} Auto"
            : "${sourceInfo.sourceName} Auto (${languageTypeToString(sourceInfo.language!)})",
        videoUrl: masterUrl,
        resolution: VideoResolution.p1080,
        quality: 1080,
      ));
    }
    return sources;
  }
}
