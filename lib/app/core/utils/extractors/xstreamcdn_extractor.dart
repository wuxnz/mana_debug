import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/values/constants.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

class XstreamCdnExtractor {
  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    var headers = {
      'Referer': sourceInfo.embedUrl!,
      'User-Agent': xstreamCdnUserAgent,
    };
    var id = sourceInfo.embedUrl!.split('/').last;
    var baseUrl = Uri.parse(sourceInfo.embedUrl!).origin;
    var newUrl = '$baseUrl/api/source/$id';
    var response = await http.post(Uri.parse(newUrl), headers: headers).timeout(
          const Duration(seconds: 10),
          onTimeout: () => http.Response("[]", 200),
        );
    var rJson = json.decode(response.body);
    var result = <VideoSourceModel>[];
    if (rJson['success'] == true) {
      var data = rJson['data'] as List;
      for (var item in data) {
        result.add(VideoSourceModel(
          source: VideoSourceInfoModel(
            baseUrl: baseUrl,
            sourceName: sourceInfo.sourceName,
            sourceId: sourceInfo.sourceId,
          ),
          sourceUrlDescription:
              "XstreamCDN ${item['label'].replaceAll('p', '')}",
          videoUrl: item['file'],
          resolution: item['label'] == "1080p"
              ? VideoResolution.p1080
              : item['label'] == "720p"
                  ? VideoResolution.p720
                  : item['label'] == "480p"
                      ? VideoResolution.p480
                      : item['label'] == "360p"
                          ? VideoResolution.p360
                          : VideoResolution.other,
          quality: int.parse(item['label'].replaceAll('p', '')),
          headers: headers,
        ));
      }
    }
    return result;
  }
}
