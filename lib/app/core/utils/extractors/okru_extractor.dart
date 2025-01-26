import 'package:http/http.dart' as http;

import '../../../data/models/sources/base_model.dart';
import '../../values/constants.dart';
import '../helpers/m3u8_helpers.dart';

class OkRuExtractor {
  static final RegExp _magEx = RegExp(r"ondemandHls[\\&quot;:]+(.+\.m3u8)");

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var headers = {
      'Connection': 'keep-alive',
      'Referer': Uri.parse(sourceInfo.embedUrl!).origin,
      'User-Agent': okRuUserAgent,
    };
    var response = http.get(Uri.parse(sourceInfo.embedUrl!), headers: headers);
    var masterUrl = _magEx.firstMatch((await response).body)?.group(1);
    List<VideoSourceModel> videoSources = [];
    var m3u8Helper = M3U8HelperTwo();
    List<M3U8pass> videoInfo = await m3u8Helper.m3u8GenerationFileName(
        masterUrl!, VideoResolution.multi, headers);

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
                quality: e.dataQuality == "Auto" ? 0 : int.parse(e.dataQuality),
                headers: {
                  "User-Agent": streamsSBUserAgent,
                })))
        .toList();
    return videoSources;
  }
}
