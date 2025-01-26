import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/helpers/crypto_js_helper.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../../../data/models/services/external_helper_services_models/ani_skip.dart';
import '../../values/constants.dart';
import '../helpers/m3u8_helpers.dart';

class RabbitStreamExtractor {
  static RegExp baseUrlEmbedServerAndIdRegExp =
      RegExp(r"https://(.+)/(embed-(\d+).*)/([^?]+)");
  static const String _sixKeyUrl =
      "https://raw.githubusercontent.com/enimax-anime/key/e6/key.txt";
  static const String _fourKeyUrl =
      "https://raw.githubusercontent.com/enimax-anime/key/e4/key.txt";
  static const String _zeroKeyUrl =
      "https://raw.githubusercontent.com/enimax-anime/key/e0/key.txt";

  String parseKey(String encryptedUrl, dynamic key) {
    // debugPrint("Type: ${key.runtimeType}");
    var keyBackup = key;
    key = jsonDecode(key);
    if (key.runtimeType == String) {
      // debugPrint("Key: $key from String");
      return decryptAESCryptoJS(encryptedUrl, key);
    } else {
      List<List<int>> wooKey = [];
      for (var i in key) {
        wooKey.add(List<int>.from(i));
      }
      // debugPrint("WooKey: $wooKey");
      List<String> encryptedUrlTemp = encryptedUrl.split("");
      // debugPrint("EncryptedUrlTemp: $encryptedUrlTemp");
      // debugPrint("length: ${encryptedUrlTemp.length}");
      var newKey = "";
      for (List<int> index in wooKey) {
        for (int i = index[0]; i < index[1]; i++) {
          // debugPrint("$i: ${encryptedUrlTemp[i]}");
          newKey += encryptedUrlTemp[i]!;
          // debugPrint("NewKey: $newKey");
          encryptedUrlTemp[i] = "";
          // debugPrint("EncryptedUrlTemp: $encryptedUrlTemp");
        }
      }
      // debugPrint("Outside Loop");
      key = newKey;
      // debugPrint("Key: $key");
      // debugPrint("length: ${encryptedUrlTemp.length}");
      encryptedUrl = encryptedUrlTemp.join("");
      // debugPrint("EncryptedUrl: $encryptedUrl");
      // debugPrint("RabbitStream $encryptedUrl $key");
      // sourceJSON.sources = JSON.parse(CryptoJS.AES.decrypt(encryptedUrl, key).toString(CryptoJS.enc.Utf8));
      return decryptAESCryptoJS(encryptedUrl, key);
    }
  }

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    // debugPrint("embedUrl: ${sourceInfo.embedUrl}");
    var matches =
        baseUrlEmbedServerAndIdRegExp.firstMatch(sourceInfo.embedUrl!);
    // debugPrint("matches: $matches");
    var baseUrl = matches!.group(1);
    var embedServer = matches.group(2)!;
    var serverNumber = matches.group(3);
    var id = matches.group(4)!;
    var headers = {
      "Referer": sourceInfo.embedUrl!,
      "X-Requested-With": "XMLHttpRequest",
    };
    http.Response response;
    if (embedServer.contains("/")) {
      debugPrint(
          "https://$baseUrl/${embedServer.replaceFirst("/", "/ajax/")}/${id.replaceFirst(id.split("/").last, "getSources?id=${id.split("/").last}")}");
      response = await http.get(
          Uri.parse(
              "https://$baseUrl/${embedServer.replaceFirst("/", "/ajax/")}/${id.replaceFirst(id.split("/").last, "getSources?id=${id.split("/").last}")}"),
          headers: headers);
      serverNumber = "6";
    } else {
      debugPrint("https://$baseUrl/ajax/$embedServer/getSources?id=$id");
      response = await http.get(
          Uri.parse("https://$baseUrl/ajax/$embedServer/getSources?id=$id"),
          headers: headers);
    }
    var sourcesJson = jsonDecode(response.body);
    var encrypted = sourcesJson["encrypted"];
    var sourcesEncoded = sourcesJson["sources"];
    var subtitles = sourcesJson["tracks"];
    var intro = sourcesJson["intro"];
    var outro = sourcesJson["outro"];
    var videoSources = <VideoSourceModel>[];
    var videoHeaders = {
      "User-Agent": rapidCloudUserAgent,
      "Accept": "*/*",
      "Origin": Uri.parse(sourceInfo.embedUrl!).origin,
      "Connection": "keep-alive",
      "Referer": "${Uri.parse(sourceInfo.embedUrl!).origin}/",
    };
    AniSkipSkipData? opSkipData;
    AniSkipSkipData? edSkipData;
    if (intro != null) {
      opSkipData = AniSkipSkipData(
        startTime: double.parse(intro['start'].toString()),
        endTime: double.parse(intro['end'].toString()),
      );
    }
    if (outro != null) {
      edSkipData = AniSkipSkipData(
        startTime: double.parse(outro['start'].toString()),
        endTime: double.parse(outro['end'].toString()),
      );
    }
    List<SubtitlesModel>? subtitleModels;
    for (var subtitle in subtitles) {
      if (subtitle['kind'] == 'captions') {
        subtitleModels ??= [];
        subtitleModels.add(SubtitlesModel(
          subtitleUrl: subtitle['file'],
          subtitleName: subtitle['label'],
          subtitleLanguage: subtitle['label'],
        ));
      }
    }
    String? decodedSource;
    // try {
    //   if (serverNumber == "4") {
    //     var keyResponse = await http.get(Uri.parse(_fourKeyUrl));
    //     var key = keyResponse.body.trim();
    //     decodedSource = decryptAESCryptoJS(sourcesEncoded, key);
    //   } else if (serverNumber == "6") {
    //     var keyResponse = await http.get(Uri.parse(_sixKeyUrl));
    //     var key = keyResponse.body.trim();
    //     decodedSource = decryptAESCryptoJS(sourcesEncoded, key);
    //   } else {
    //     return videoSources;
    //   }
    // } catch (e) {
    //   decodedSource = sourcesEncoded;
    // }
    int count = 4;
    while (decodedSource == null) {
      try {
        if (count == 4) {
          var keyResponse = await http.get(Uri.parse(_sixKeyUrl));
          var key = keyResponse.body.trim();
          // key = parseKey(sourcesEncoded, key);
          decodedSource = parseKey(sourcesEncoded, key);
          // debugPrint("decodedSource: $decodedSource");
          break;
        } else if (count == 3) {
          var keyResponse = await http.get(Uri.parse(_fourKeyUrl));
          var key = keyResponse.body.trim();
          // key = parseKey(sourcesEncoded, key);
          decodedSource = parseKey(sourcesEncoded, key);
          // debugPrint("decodedSource: $decodedSource");
          break;
        } else if (count == 2) {
          var keyResponse = await http.get(Uri.parse(_zeroKeyUrl));
          var key = keyResponse.body.trim();
          // key = parseKey(sourcesEncoded, key);
          decodedSource = parseKey(sourcesEncoded, key);
          // debugPrint("decodedSource: $decodedSource");
          break;
        } else {
          decodedSource = sourcesEncoded;
        }
      } catch (e) {
        count--;
        // debugPrint("Error: $e");
        // rethrow;
      }
    }
    // debugPrint(decodedSource);
    var decodedSources = jsonDecode(decodedSource!);
    for (var source in decodedSources) {
      if (source['type'] == 'hls') {
        var masterUrl = source['file'];
        var m3u8Helper = M3U8HelperTwo();
        List<M3U8pass> videoInfo = await m3u8Helper.m3u8GenerationFileName(
            masterUrl, VideoResolution.multi, videoHeaders);
        videoInfo
            .map((e) => videoSources.add(VideoSourceModel(
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
                  quality:
                      e.dataQuality == "Auto" ? 0 : int.parse(e.dataQuality),
                  headers: videoHeaders,
                  opSkipData: opSkipData,
                  edSkipData: edSkipData,
                  subtitles: subtitleModels,
                )))
            .toList();
      } else {
        videoSources.add(VideoSourceModel(
          source: VideoSourceInfoModel(
            baseUrl: sourceInfo.baseUrl,
            sourceName: sourceInfo.sourceName,
            sourceId: sourceInfo.sourceId,
          ),
          sourceUrlDescription: sourceInfo.language == null
              ? "${sourceInfo.sourceName} Auto"
              : "${sourceInfo.sourceName} Auto (${languageTypeToString(sourceInfo.language!)})",
          videoUrl: source['file'],
          resolution: VideoResolution.other,
          quality: 0,
          headers: videoHeaders,
          opSkipData: opSkipData,
          edSkipData: edSkipData,
          subtitles: subtitleModels,
        ));
      }
    }
    return videoSources;
  }
}
