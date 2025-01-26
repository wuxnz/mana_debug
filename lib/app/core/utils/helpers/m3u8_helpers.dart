import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/data/models/sources/base_model.dart';

class M3U8pass {
  final String dataQuality;
  final String dataUrl;

  M3U8pass({required this.dataQuality, required this.dataUrl});
}

class M3U8HelperOne {
  Future<List<M3U8pass>> m3u8video(String m3u8Content) async {
    List<M3U8pass> qualities = [];

    RegExp regExp = RegExp(
      r"#EXT-X-STREAM-INF:(?:.*,RESOLUTION=(\d+x\d+))?,?(.*)\r?\n(.*)",
      caseSensitive: false,
      multiLine: true,
    );

    List<RegExpMatch> matches = regExp.allMatches(m3u8Content).toList();

    debugPrint("--- HLS Matches ----\n${matches.length}\nfinish");

    matches.forEach(
      (RegExpMatch regExpMatch) async {
        String quality = (regExpMatch.group(1)).toString();
        quality = quality.substring(quality.indexOf('x') + 1);
        String sourceURL = regExpMatch.group(3) ?? '';
        final netRegex = RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');
        final netRegex2 = RegExp(r'(.*)\r?\/');
        final isNetwork = netRegex.hasMatch(sourceURL);
        final match = netRegex2.firstMatch(m3u8Content);
        String url;
        if (isNetwork) {
          url = sourceURL;
        } else {
          debugPrint(match.toString());
          final dataURL = match?.group(0) ?? '';
          url = "$dataURL$sourceURL";
          debugPrint("--- hls child url integration ---\nchild url :$url");
        }
        debugPrint('qualityVideo');
        debugPrint(quality);
        debugPrint('sourceURL');
        debugPrint(sourceURL);
        debugPrint('url');
        debugPrint(url);
        qualities.add(M3U8pass(dataQuality: quality, dataUrl: sourceURL));
      },
    );
    return qualities;
  }
}

class M3U8HelperTwo {
  static const QUALITY_REGEX =
      r"#EXT-X-STREAM-INF:(?:(?:.*?(?:RESOLUTION=\d+x(\d+)).*?\s+(.*))|(?:.*?\s+(.*)))";

  String? absoluteExtensionDetermination(String url) {
    var split = url.split("/");
    String gg = split[split.length - 1].split("?")[0];
    if (gg.contains(".")) {
      var split2 = gg.split(".");
      if (split2.isEmpty) {
        return null;
      } else {
        return split2.last;
      }
    } else {
      return null;
    }
  }

  bool isNotCompleteUrl(String url) {
    return !url.contains("http://") && !url.contains("https://");
  }

  Future<List<M3U8pass>> m3u8Generation(
      String streamUrl, VideoResolution qualityIn, Map<String, String>? headers,
      {bool? returnThis = true}) async {
    List<M3U8pass> list = [];

    var m3u8Parent = Uri.parse(streamUrl).origin;
    RegExp portRegex = RegExp(r":\d{4}");
    var response = await http.get(Uri.parse(streamUrl), headers: headers);
    var qualityRegexMatches = RegExp(QUALITY_REGEX).allMatches(response.body);
    for (var match in qualityRegexMatches) {
      var quality = match.group(1);
      var m3u8Link = match.group(2);
      var m3u8Link2 = match.group(3);
      if (m3u8Link!.isEmpty) {
        m3u8Link = m3u8Link2;
      }
      if (absoluteExtensionDetermination(m3u8Link!) == "m3u8") {
        if (isNotCompleteUrl(m3u8Link)) {
          m3u8Link = m3u8Parent + m3u8Link;
        }
        list.addAll(await m3u8Generation(
          m3u8Link,
          quality == "1080"
              ? VideoResolution.p1080
              : quality == "720"
                  ? VideoResolution.p720
                  : quality == "480"
                      ? VideoResolution.p480
                      : quality == "360"
                          ? VideoResolution.p360
                          : VideoResolution.other,
          headers,
          returnThis: false,
        ));
      }
      list.add(M3U8pass(
          dataQuality: quality ?? "Unknown Quality", dataUrl: m3u8Link));
    }
    if (returnThis != false) {
      list.add(M3U8pass(dataQuality: "Auto", dataUrl: streamUrl));
    }

    for (var item in list) {}
    return list;
  }

  Future<List<M3U8pass>> m3u8GenerationFileName(
      String streamUrl, VideoResolution qualityIn, Map<String, String>? headers,
      {bool? returnThis = true}) async {
    List<M3U8pass> list = [];

    var m3u8Parent = streamUrl.substring(0, streamUrl.lastIndexOf("/") + 1);
    var response = http.get(Uri.parse(streamUrl), headers: headers);

    var qualityRegexMatches =
        RegExp(QUALITY_REGEX).allMatches((await response).body);
    for (var match in qualityRegexMatches) {
      var quality = match.group(1);
      var m3u8Link = match.group(2);
      var m3u8Link2 = match.group(3);
      if (m3u8Link!.isEmpty) {
        m3u8Link = m3u8Link2;
      }
      if (absoluteExtensionDetermination(m3u8Link!) == "m3u8") {
        if (isNotCompleteUrl(m3u8Link)) {
          m3u8Link = m3u8Parent + m3u8Link;
        }
        if (quality!.isEmpty) {}
        list.addAll(await m3u8Generation(
          m3u8Link,
          quality == "1080"
              ? VideoResolution.p1080
              : quality == "720"
                  ? VideoResolution.p720
                  : quality == "480"
                      ? VideoResolution.p480
                      : quality == "360"
                          ? VideoResolution.p360
                          : VideoResolution.other,
          headers,
          returnThis: false,
        ));
      }
      list.add(M3U8pass(
          dataQuality: quality ?? "Unknown Quality", dataUrl: m3u8Link));
    }
    if (returnThis != false) {
      list.add(M3U8pass(dataQuality: "Auto", dataUrl: streamUrl));
    }

    for (var item in list) {}
    return list;
  }
}
