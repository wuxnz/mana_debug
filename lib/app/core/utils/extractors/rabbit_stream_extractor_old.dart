import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/helpers/m3u8_helpers.dart';
import 'package:mana_debug/app/core/values/constants.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';
import 'package:pointycastle/export.dart';

import '../../../data/models/services/external_helper_services_models/ani_skip.dart';

class RabbitStreamExtractorOld {
  static Uint8List _strToByte(String str) {
    var bytes = utf8.encode(str);
    return Uint8List.fromList(bytes);
  }

  List<Uint8List>? _generateKeyAndIV(Uint8List password, Uint8List salt,
      {int keyLength = 32,
      ivLength = 16,
      int iterations = 1}) {
    var md = MD5Digest();
    var digestLength = md.digestSize;
    var targetKeySize = keyLength + ivLength;
    var requiredLength =
        (targetKeySize + digestLength - 1) / digestLength * digestLength;
    var generatedData = Uint8List(requiredLength.toInt());
    var generatedLength = 0;

    try {
      md.reset();

      while (generatedLength < targetKeySize) {
        if (generatedLength > 0) {
          md.update(
              generatedData, generatedLength - digestLength, digestLength);
        }

        md.update(password, 0, password.length);
        md.update(salt, 0, 8);
        md.doFinal(generatedData, generatedLength);

        for (var i = 1; i < iterations; i++) {
          md.update(generatedData, generatedLength, digestLength);
          md.doFinal(generatedData, generatedLength);
        }

        generatedLength += digestLength;
      }
      var result = [
        generatedData.sublist(0, keyLength),
        generatedData.sublist(keyLength, targetKeySize as int?)
      ];
      return result;
    } catch (e) {
      return null;
    }
  }

  String? decrypt(String encodedData, String remoteKey) {
    var saltedData = base64.decode(encodedData);

    var salt = saltedData.sublist(8, 16);
    var cipherText = saltedData.sublist(16);
    var password = _strToByte(remoteKey);
    var keyAndIv = _generateKeyAndIV(password, salt);
    if (keyAndIv == null) {
      return null;
    }
    var keySpec = KeyParameter(keyAndIv[0]);
    var ivSpec = keyAndIv[1];
    var cipher = PaddedBlockCipher("AES/CBC/PKCS7");
    var params = PaddedBlockCipherParameters(
        ParametersWithIV<KeyParameter>(keySpec, ivSpec), null);
    cipher.init(false, params);
    var decrypted = cipher.process(cipherText);

    return utf8.decode(decrypted);
  }

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var id = sourceInfo.embedUrl!.split('/').last.split('?').first;
    var embed = sourceInfo.embedUrl!.split('/').reversed.toList()[1];

    var newHeaders = {
      'Referer': sourceInfo.embedUrl!,
      "X-Requested-With": "XMLHttpRequest",
      "Accept": "*/*",
      "Accept-Language": "en-US,en;q=0.5",
      "Connection": "keep-alive",
      "TE": "trailers"
    };

    var baseUrl = Uri.parse(sourceInfo.embedUrl!).origin;

    var jsonBody = await http.get(
        Uri.parse('$baseUrl/ajax/$embed/getSources?id=$id'),
        headers: newHeaders);
    debugPrint(jsonBody.body);
    var parsed = jsonDecode(jsonBody.body);
    var key = await http
        .get(Uri.parse(
            'https://raw.githubusercontent.com/enimax-anime/key/e4/key.txt'))
        .then((value) => value.body.toString().trim());

    var sourcesRaw = [];
    var subtitles = parsed['tracks'];
    var intro = parsed['intro'];
    var outro = parsed['outro'];
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
      List<dynamic> unEncryptedSources = [];
      if (parsed['sources'] is String) {
        unEncryptedSources.add(parsed['sources']);
      } else {
        unEncryptedSources.addAll(parsed['sources'].map((e) {
          return e;
        }).toList());
      }

      for (var unEncSource in unEncryptedSources) {
        if (unEncSource['type'] == 'hls') {
          var masterUrl = unEncSource['file'];
          var m3u8Helper = M3U8HelperTwo();
          List<M3U8pass> videoInfo = await m3u8Helper.m3u8Generation(
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
            sourceUrlDescription: "${sourceInfo.sourceName} Auto",
            videoUrl: unEncSource["file"],
            resolution: VideoResolution.multi,
            quality: 0,
            headers: videoHeaders,
            opSkipData: opSkipData,
            edSkipData: edSkipData,
            subtitles: subtitleModels,
          ));
        }
      }
    } catch (e) {
      if (parsed['sources'] is String) {
        sourcesRaw.add(parsed['sources']);
      } else {
        sourcesRaw.addAll(parsed['sources']);
      }
      var sourcesJsonList =
          sourcesRaw.map((e) => decrypt(parsed['sources'], key)).toList();

      for (var i = 0; i < sourcesJsonList.length; i++) {
        if (sourcesJsonList[i] == null) {
          continue;
        }
        var sourceJson = sourcesJsonList[i];
        var source = jsonDecode(sourceJson!);
        source = source[0];

        if (source['type'] == 'hls') {
          var masterUrl = source['file'];
          var m3u8Helper = M3U8HelperTwo();
          List<M3U8pass> videoInfo = await m3u8Helper.m3u8Generation(
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
                  )))
              .toList();
        } else {
          videoSources.add(VideoSourceModel(
            source: VideoSourceInfoModel(
              baseUrl: sourceInfo.baseUrl,
              sourceName: sourceInfo.sourceName,
              sourceId: sourceInfo.sourceId,
            ),
            sourceUrlDescription: "${sourceInfo.sourceName} Auto",
            videoUrl: source["file"],
            resolution: VideoResolution.multi,
            quality: 0,
            headers: videoHeaders,
          ));
        }
      }

      return videoSources;
    }
    return videoSources;
  }
}
