import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/values/constants.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

class DoodStreamExtractor {
  String getRandomString({int length = 10}) {
    var allowedChars = "abcdefghijklmnopqrstuvwxyz0123456789";
    var randomString = "";
    for (var i = 0; i < length; i++) {
      randomString += allowedChars[Random().nextInt(allowedChars.length)];
    }
    return randomString;
  }

  Future<List<VideoSourceModel>> extractor(RawVideoSourceInfoModel sourceInfo,
      {String? referer}) async {
    var response = await http.get(Uri.parse(sourceInfo.embedUrl!), headers: {
      "User-Agent": manaDebugUserAgent,
    });
    var newUrl = response.request!.url.toString();
    debugPrint("DoodStreamExtractor: $newUrl");
    var doodTld = newUrl.substring(newUrl.indexOf("dood.") + 5);
    var baseUrl = Uri.parse(newUrl).origin;
    var content = response.body.toString();
    if (!content.contains("/pass_md5/")) {
      return [];
    }
    var md5 =
        RegExp(r"/pass_md5/[^']*").stringMatch(content)!.replaceAll("'", "");
    var token = md5.substring(md5.lastIndexOf("/") + 1);
    var randomString = getRandomString();
    var expiry = DateTime.now().millisecondsSinceEpoch;
    var videoUrlStart = await http.get(Uri.parse("$baseUrl$md5"), headers: {
      'Referer': newUrl,
      'User-Agent': manaDebugUserAgent,
    }).then((value) => value.body.toString());
    var videoUrl = "$videoUrlStart$randomString?token=$token&expiry=$expiry";
    debugPrint("DoodStreamExtractor: $videoUrl");
    var quality = RegExp(r"\\d{3,4}p").stringMatch(response.body.toString());
    return [
      VideoSourceModel(
        source: VideoSourceInfoModel(
          sourceId: sourceInfo.sourceId,
          sourceName: sourceInfo.sourceName,
          baseUrl: videoUrl,
        ),
        sourceUrlDescription: quality == "" || quality == null
            ? "DoodStream Auto"
            : "DoodStream $quality",
        videoUrl: videoUrl,
        resolution: quality == "1080p"
            ? VideoResolution.p1080
            : quality == "720p"
                ? VideoResolution.p720
                : quality == "480p"
                    ? VideoResolution.p480
                    : VideoResolution.p360,
        quality: int.tryParse(quality?.replaceAll("p", "") ?? "0") ?? 0,
        headers: {
          'Referer': "${Uri.parse(sourceInfo.embedUrl!).origin}/",
        },
      )
    ];
  }
}
