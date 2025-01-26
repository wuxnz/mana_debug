import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/sources/base_model.dart';
import '../../values/constants.dart';
import '../helpers/m3u8_helpers.dart';

class Mp4UploadExtractor {
  static RegExp magEx = RegExp(r'type:\s+"(.*)",\n\s+src:\s+"(.*)"');

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var headers = {
      "User-Agent": mp4UploadUserAgent,
    };
    var response =
        await http.get(Uri.parse(sourceInfo.embedUrl!), headers: headers);
    var soup = BeautifulSoup(response.body);

    var script = soup
        .findAll('script')
        .firstWhere((element) => magEx.hasMatch(element.text))
        .text;
    var match = magEx.firstMatch(script);
    var masterUrl = match?.group(2);
    List<VideoSourceModel> sources = [];
    if (masterUrl != null) {
      if (masterUrl.contains(".m3u8")) {
        var m3u8Helper = M3U8HelperTwo();
        List<M3U8pass> videoInfo = await m3u8Helper.m3u8Generation(
            masterUrl, VideoResolution.multi, headers);

        videoInfo
            .map((e) => sources.add(VideoSourceModel(
                  source: VideoSourceInfoModel(
                    baseUrl: sourceInfo.baseUrl,
                    sourceName: sourceInfo.sourceName,
                    sourceId: sourceInfo.sourceId,
                  ),
                  sourceUrlDescription: sourceInfo.language == null
                      ? "Mp4Upload ${e.dataQuality}"
                      : "Mp4Upload ${e.dataQuality} (${languageTypeToString(sourceInfo.language!)})",
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
                  // headers: headers
                )))
            .toList();
      } else {
        sources.add(VideoSourceModel(
          source: VideoSourceInfoModel(
            baseUrl: sourceInfo.baseUrl,
            sourceName: sourceInfo.sourceName,
            sourceId: sourceInfo.sourceId,
          ),
          sourceUrlDescription: sourceInfo.language == null
              ? "Mp4Upload Auto"
              : "Mp4Upload Auto (${languageTypeToString(sourceInfo.language!)})",
          videoUrl: masterUrl,
          resolution: VideoResolution.other,
          quality: 0,
          // headers: headers
        ));
      }
    }
    return sources;
  }
}
