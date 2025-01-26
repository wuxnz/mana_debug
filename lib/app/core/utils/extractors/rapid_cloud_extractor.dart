import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/values/constants.dart';
import 'package:mana_debug/app/data/models/services/external_helper_services_models/ani_skip.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../helpers/crypto_js_helper.dart';
import '../helpers/m3u8_helpers.dart';

class RapidCloudExtractorOld {
  static const String _keyUrl =
      "https://raw.githubusercontent.com/enimax-anime/key/e6/key.txt";

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var keyResponse = await http.get(Uri.parse(_keyUrl));
    var key = keyResponse.body.trim();
    debugPrint("RapidCloudExtractor Key: $key");
    var embedId = sourceInfo.embedUrl!.split('/').last.split('?').first;
    var beforeId = sourceInfo.embedUrl!.split(embedId).first;
    var newHeaders = {
      'Referer': sourceInfo.embedUrl!,
      "X-Requested-With": "XMLHttpRequest",
      "Accept": "*/*",
      "Accept-Language": "en-US,en;q=0.5",
      "Connection": "keep-alive",
      "TE": "trailers"
    };
    var sourcesResponse = await http.get(
        Uri.parse(
            "${beforeId.replaceFirst('/embed-', "/ajax/embed-")}getSources?id=$embedId"),
        headers: newHeaders);
    debugPrint(
        "RapidCloudExtractor Request: ${beforeId.replaceFirst('/embed-', "/ajax/embed-")}getSources?id=$embedId");
    debugPrint("RapidCloudExtractor Response: ${sourcesResponse.body}");
    var sourcesJson = jsonDecode(sourcesResponse.body);
    var sources = sourcesJson['sources'];
    debugPrint("RapidCloudExtractor Sources: $sources");
    var subtitles = sourcesJson['tracks'];
    var intro = sourcesJson['intro'];
    var outro = sourcesJson['outro'];
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
    debugPrint("RapidCloudExtractor Intro: $intro");
    if (outro != null) {
      edSkipData = AniSkipSkipData(
        startTime: double.parse(outro['start'].toString()),
        endTime: double.parse(outro['end'].toString()),
      );
    }
    debugPrint("RapidCloudExtractor Outro: $outro");
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
    debugPrint("RapidCloudExtractor Subtitles: $subtitles");
    try {
      var decSources = decryptAESCryptoJS(sources, key);
      var decSourcesJson = jsonDecode(decSources);
      debugPrint("RapidCloudExtractor Decrypted Sources: $decSourcesJson");
      for (var source in decSourcesJson) {
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
    } catch (e) {
      for (var source in sources) {
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
    }
    return videoSources;
  }
}
