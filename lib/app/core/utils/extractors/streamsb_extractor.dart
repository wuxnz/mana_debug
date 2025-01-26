import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../../values/constants.dart';
import '../helpers/m3u8_helpers.dart';

class StreamSBExtractor {
  static const _hexChars = '0123456789abcdef';
  static const _endpointUrl =
      "https://raw.githubusercontent.com/Claudemirovsky/streamsb-endpoint/master/endpoint.txt";
  late String _endpoint;

  Future init() async {
    var response = await http.get(Uri.parse(_endpointUrl));
    _endpoint = response.body;
  }

  static String _bytesToHex(List<int> bytes) {
    final result = StringBuffer();
    for (final byte in bytes) {
      result.write(_hexChars[byte >> 4]);
      result.write(_hexChars[byte & 0x0f]);
    }
    return result.toString();
  }

  static String _payload(String id) {
    return _bytesToHex(utf8.encode("||$id||||streamsb"));
  }

  String _fixUrl(String url, bool common) {
    var id = url
        .substring(url.indexOf('/e/') + 3)
        .split("?")[0]
        .replaceFirst(".html", "");
    var baseUrl = Uri.parse(url).origin;
    debugPrint("$baseUrl/$_endpoint/${_payload(id)}");
    return "$baseUrl/$_endpoint/${_payload(id)}/";
  }

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var headers = {
      'Referer': Uri.parse(sourceInfo.embedUrl!).origin,
      "User-Agent": streamsSBUserAgent,
      'watchsb': 'sbstream',
    };
    var fixedUrl = _fixUrl(sourceInfo.embedUrl!, true);
    var response =
        await http.get(Uri.parse(fixedUrl), headers: headers).timeout(
              const Duration(seconds: 10),
              onTimeout: () => http.Response("[]", 200),
            );

    var rJson = json.decode(response.body);

    var masterUrl = rJson['stream_data']['file'];

    List<VideoSourceModel> videoSources = [];
    var m3u8Helper = M3U8HelperTwo();
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
                    ? "StreamSB ${e.dataQuality}"
                    : "StreamSB ${e.dataQuality} (${languageTypeToString(sourceInfo.language!)})",
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
                  "User-Agent": streamsSBUserAgent,
                })))
        .toList();
    return videoSources;
  }
}
