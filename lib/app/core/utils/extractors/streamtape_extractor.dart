import 'package:http/http.dart' as http;
import 'package:mana_debug/app/data/models/sources/base_model.dart';

class StreamtapeExtractor {
  static const _mainUrl = 'https://streamtape.com';
  static RegExp magEx =
      RegExp(r"robotlink'\)\.innerHTML = '(.+?)'\+ \('(.+?)'\)");

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var response = await http.get(Uri.parse(
        "https://streamadblocker.xyz/e/${sourceInfo.embedUrl!.split('/').last}"));
    var match = magEx.firstMatch(response.body);
    var videoUrl = "https:${match!.group(1)!}${match.group(2)!.substring(3)}";

    return [
      VideoSourceModel(
        source: VideoSourceInfoModel(
          baseUrl: _mainUrl,
          sourceName: sourceInfo.sourceName,
          sourceId: sourceInfo.sourceId,
        ),
        sourceUrlDescription: "Streamtape Auto",
        videoUrl: videoUrl,
        resolution: VideoResolution.multi,
        quality: 0,
      )
    ];
  }
}
