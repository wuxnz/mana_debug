import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../data/models/sources/base_model.dart';
import '../helpers/m3u8_helpers.dart';

class AllAnimeExtractor {
  static const String _apiUrl =
      "https://embed.ssbcontent.site/apivtwo/clock.json?id=";
  static final _videoHeaders = {
    "Referer": "https://allanime.to/",
    "Connection": "keep-alive",
  };

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    List<VideoSourceModel> videoSources = [];
    if (sourceInfo.sourceName == "Yt-HD") {
      videoSources.add(VideoSourceModel(
        source: VideoSourceInfoModel(
          baseUrl: sourceInfo.baseUrl,
          sourceName: sourceInfo.sourceName,
          sourceId: sourceInfo.sourceId,
        ),
        sourceUrlDescription: sourceInfo.language == null
            ? "AllAnime ${sourceInfo.sourceName} Auto"
            : "AllAnime ${sourceInfo.sourceName} Auto (${languageTypeToString(sourceInfo.language!)})",
        videoUrl: sourceInfo.embedUrl!,
        resolution: VideoResolution.other,
        quality: 0,
        headers: _videoHeaders,
      ));
    } else if (sourceInfo.sourceName == "S-mp4") {
      var id = sourceInfo.embedUrl!.split("id=")[1];
      var response = await http.get(Uri.parse("$_apiUrl$id"));
      var rJson = jsonDecode(response.body);
      var links = rJson["links"] as List;
      for (var link in links) {
        bool isM3u8 = link["hls"] != null;
        if (isM3u8) {
          var m3u8Helper = M3U8HelperTwo();
          List<M3U8pass> videoInfo = await m3u8Helper.m3u8Generation(
              link["link"], VideoResolution.multi, _videoHeaders);

          videoInfo
              .map((e) => videoSources.add(VideoSourceModel(
                    source: VideoSourceInfoModel(
                      baseUrl: sourceInfo.baseUrl,
                      sourceName: sourceInfo.sourceName,
                      sourceId: sourceInfo.sourceId,
                    ),
                    sourceUrlDescription: sourceInfo.language == null
                        ? "AllAnime ${sourceInfo.sourceName} ${e.dataQuality}"
                        : "AllAnime ${sourceInfo.sourceName} ${e.dataQuality} (${languageTypeToString(sourceInfo.language!)})",
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
                    headers: _videoHeaders,
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
                ? "AllAnime ${sourceInfo.sourceName} Auto"
                : "AllAnime ${sourceInfo.sourceName} Auto (${languageTypeToString(sourceInfo.language!)})",
            videoUrl: link["link"],
            resolution: VideoResolution.other,
            quality: 0,
            headers: _videoHeaders,
          ));
        }
      }
    }
    return videoSources;
  }
}
