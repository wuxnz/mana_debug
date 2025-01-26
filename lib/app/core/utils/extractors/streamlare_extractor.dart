import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mana_debug/app/data/models/sources/base_model.dart';

class StreamlareExtractor {
  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var testReq = await http.get(Uri.parse(sourceInfo.embedUrl!)).timeout(
          const Duration(seconds: 10),
          onTimeout: () => http.Response("[]", 200),
        );
    var result = <VideoSourceModel>[];
    var id = sourceInfo.embedUrl!.split('/').last;
    var response = await http
        .post(Uri.parse("${sourceInfo.baseUrl}/api/video/stream/get"), body: {
      "id": id,
    }, headers: {
      "Referer": "${testReq.request!.url}",
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0",
    }).timeout(
      const Duration(seconds: 10),
      onTimeout: () => http.Response("[]", 200),
    );

    var rJson = jsonDecode(response.body);
    result.add(VideoSourceModel(
        source: VideoSourceInfoModel(
          baseUrl: sourceInfo.baseUrl,
          sourceName: sourceInfo.sourceName,
          sourceId: sourceInfo.sourceId,
        ),
        sourceUrlDescription:
            "Streamlare ${rJson['result']['Original']['label']}",
        videoUrl: rJson['result']['Original']['file'],
        resolution: VideoResolution.other,
        quality: 0,
        headers: {
          'Referer': '${testReq.request!.url}',
          "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0",
        }));
    return result;
  }
}
