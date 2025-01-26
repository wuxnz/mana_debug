import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/utils/helpers/m3u8_helpers.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../../values/constants.dart';

class StreamangoExtractor {
  
  static const _referer = "https://thekisscartoon.com/";

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var serverId = sourceInfo.embedUrl!.split("/").last;
    
    var baseUrl = Uri.parse(sourceInfo.embedUrl!).origin;
    var sourceUrl = "$baseUrl/player/index.php?data=$serverId&do=getVideo";
    var sourceRawResponse = await http.post(Uri.parse(sourceUrl), headers: {
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
      "X-Requested-With": "XMLHttpRequest",
      "User-Agent": tkcUserAgent,
    }, body: {
      "hash": serverId,
      "r": _referer,
    });
    var rJson = jsonDecode(sourceRawResponse.body);
    
    var masterUrl = rJson["securedLink"];
    
    List<VideoSourceModel> videoSources = [];
    var m3u8Helper = M3U8HelperTwo();
    if (rJson["hls"] != null) {
      if (rJson["hls"] == true) {
        List<M3U8pass> videoInfo = await m3u8Helper.m3u8Generation(
            masterUrl, VideoResolution.multi, null);
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
                  
                  
                )))
            .toList();
      }
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
        
        videoUrl: masterUrl,
        
        resolution: VideoResolution.p1080,
        quality: 0,
        
        
      ));
    }
    return videoSources;
  }
}
