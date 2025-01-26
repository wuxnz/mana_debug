import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/values/constants.dart';

import '../../../data/models/sources/base_model.dart';

class WCOBZExtractor {
  RegExp magEx = RegExp(r'"([a-zA-Z\d\\\/.=\+-]+)"');

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var headers = {
      "Referer": "https://watchcartoononline.bz/",
      "User-Agent": wcobzUserAgent,
    };
    var postId = "132870";
    var embedLinkRes = await http.get(
        Uri.parse(
            "https://watchcartoononline.bz/ajax-get-link-stream/?server=streamango&filmId=$postId"),
        headers: headers);
    var embedLink = embedLinkRes.body.toString().trim();

    var embedBaseUrl = Uri.parse(embedLink).origin;
    var embedRes = await http.get(Uri.parse(embedLink), headers: headers);
    var embedResSoup = BeautifulSoup(embedRes.body);
    var magicString = embedResSoup
        .find("body > script")!
        .text
        .trim()
        .replaceAll("\n", "")
        .replaceAll("\t", "")
        .replaceAll(" ", "");

    var newMagicString =
        magicString.split('"videoUrl":')[1].split(',"videoDisk"')[0];
    var videoData = magEx.allMatches(newMagicString).toList();
    var masterUrl =
        "$embedBaseUrl${videoData[0].group(1).toString().replaceAll("\\", "")}?s=${videoData[2].group(1)}&d=";
    return [
      VideoSourceModel(
          source: VideoSourceInfoModel(
            sourceId: sourceInfo.sourceId,
            sourceName: sourceInfo.sourceName,
            baseUrl: sourceInfo.baseUrl,
          ),
          sourceUrlDescription: "WatchCartoonOnline Mutli",
          videoUrl: masterUrl,
          resolution: VideoResolution.multi,
          quality: 0,
          headers: {
            "Referer": embedLink,
            "User-Agent": wcobzUserAgent,
            "Accept": "*/*",
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "en-US,en;q=0.5",
            "Connection": "keep-alive",
            "TE": "trailers",
          })
    ];
  }
}
