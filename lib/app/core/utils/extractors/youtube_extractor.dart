import 'package:http/http.dart' as http;
import 'package:mana_debug/app/data/models/sources/base_model.dart';
import 'package:mana_debug/app/data/models/utils/extractors/youtube_extractor_models.dart';

class YoutubeExtractor {
  static const _mainUrl = "https://ssyoutube.com/api/convert";

  Future<List<VideoSourceModel>> extractor(
      RawVideoSourceInfoModel sourceInfo) async {
    String newUrl;
    if (sourceInfo.embedUrl!.startsWith("http")) {
      newUrl = sourceInfo.embedUrl!;
    } else {
      newUrl = "https://www.youtube.com/watch?v=${sourceInfo.embedUrl}";
    }
    var response = await http.post(Uri.parse(_mainUrl), body: {
      "url": newUrl,
    });
    YoutubeExtractorResponseModel rawData =
        youtubeExtractorResponseModelFromJson(response.body);
    String videoTitle = rawData.meta.title;
    List<VideoSourceModel> videoSources = [];
    List<Url> filteredUrls = rawData.url
        .where((element) => element.type == "mp4" && element.noAudio == false)
        .toList()
      ..sort((a, b) => b.qualityNumber.compareTo(a.qualityNumber));
    for (var element in filteredUrls) {
      videoSources.add(VideoSourceModel(
        source: VideoSourceInfoModel(
          baseUrl: "https://www.youtube.com",
          sourceName: "Youtube",
          sourceId: "youtube",
        ),
        sourceUrlDescription: "Youtube ${element.quality}",
        videoUrl: element.url,
        resolution: element.quality == "1080p"
            ? VideoResolution.p1080
            : element.quality == "720p"
                ? VideoResolution.p720
                : element.quality == "480p"
                    ? VideoResolution.p480
                    : element.quality == "360p"
                        ? VideoResolution.p360
                        : VideoResolution.other,
        quality: int.parse(element.quality.replaceAll("p", "")),
        title: videoTitle,
      ));
    }

    for (var element in videoSources) {}
    return videoSources;
  }
}
