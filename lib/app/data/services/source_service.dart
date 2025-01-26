import 'package:mana_debug/app/core/utils/extractors/dood_extractor.dart';
import 'package:mana_debug/app/core/utils/extractors/filemoon_extractor.dart';
import 'package:mana_debug/app/core/utils/extractors/mcloud_extractor.dart';
import 'package:mana_debug/app/core/utils/extractors/okru_extractor.dart';
import 'package:mana_debug/app/core/utils/extractors/streamango_extractor.dart';
import 'package:mana_debug/app/core/utils/extractors/streamtape_extractor.dart';
import 'package:mana_debug/app/core/utils/extractors/wcobz_extractor.dart';
import 'package:mana_debug/app/core/utils/extractors/xstreamcdn_extractor.dart';
import 'package:mana_debug/app/core/utils/extractors/youtube_extractor.dart';
import 'package:mana_debug/app/core/utils/extractors/zoro_extractor.dart';
import 'package:mana_debug/app/data/providers/sources/anime/all_anime_source.dart';
import 'package:mana_debug/app/data/providers/sources/movie/fmovies_source.dart';
import 'package:mana_debug/app/data/providers/sources/movie/hi_movies_source.dart';

import '../../core/utils/extractors/all_anime_extractor.dart';
import '../../core/utils/extractors/goload_extractor.dart';
import '../../core/utils/extractors/mp4upload_extractor.dart';
import '../../core/utils/extractors/rabbit_stream_extractor.dart';
import '../../core/utils/extractors/streamhub_extractor.dart';
import '../../core/utils/extractors/streamlare_extractor.dart';
import '../../core/utils/extractors/streamsb_extractor.dart';
import '../../core/utils/extractors/vidmoly_extractor.dart';
import '../../core/utils/extractors/vizcloud_extractor.dart';
import '../providers/sources/anime/anime_suge_source.dart';
import '../providers/sources/anime/gogoanime_source.dart';
import '../providers/sources/anime/nine_anime_source.dart';
import '../providers/sources/anime/zoro_source.dart';
import '../providers/sources/cartoon/kim_cartoon_source.dart';
import '../providers/sources/cartoon/kiss_cartoon_source.dart';
import '../providers/sources/movie/all_movies_for_you.dart';
import '../providers/sources/movie/goku_source.dart';
import '../providers/sources/movie/soap_today_source.dart';

class SourceService {
  dynamic detectSource(String sourceId) {
    switch (sourceId) {
      case 'gogoanime':
        return GogoAnimeSource();
      case 'zoro':
        return ZoroSource();
      case 'kim-cartoon':
        return KimCartoonSource();
      case 'goku':
        return GokuSource();
      case 'all-movies-for-you':
        return AllMoviesForYouSource();
      case 'anime-suge':
        return AnimeSugeSource();
      case 'soap-today':
        return SoapTodaySource();
      case 'the-kiss-cartoon':
        return KissCartoonSource();
      case 'nine-anime':
        return NineAnimeSource();
      case 'fmovies':
        return FMoviesSource();
      case 'hi-movies':
        return HiMoviesSource();
      case 'all-anime':
        return AllAnimeSource();
      default:
        return null;
    }
  }

  dynamic detectExtractor(String extractorId) {
    switch (extractorId) {
      case 'goload':
        return GoloadExtractor();
      case 'doodstream':
        return DoodStreamExtractor();
      case 'streamsb':
        return StreamSBExtractor();
      case 'xstreamcdn':
        return XstreamCdnExtractor();
      case 'fembed':
        return XstreamCdnExtractor();
      case 'streamlare':
        return StreamlareExtractor();
      case 'vidcloud':
        return RabbitStreamExtractor();
      case 'upcloud':
        return RabbitStreamExtractor();
      case 'streamhub':
        return StreamhubExtractor();
      case 'wcobz':
        return WCOBZExtractor();
      case 'vidmoly':
        return VidmolyExtractor();
      case 'youtube':
        return YoutubeExtractor();
      case 'streamtape':
        return StreamtapeExtractor();
      case 'streamango':
        return StreamangoExtractor();
      case 'mp4upload':
        return Mp4UploadExtractor();
      case 'vizcloud':
        return VizCloudExtractor();
      case 'mycloud':
        return MCloudExtractor();
      case 'filemoon':
        return FilemoonExtractor();
      case 'zoro':
        return ZoroExtracor();
      case 'rapid-cloud':
        return RabbitStreamExtractor();
      case 'all-anime-extractor':
        return AllAnimeExtractor();
      case 'megacloud':
        return RabbitStreamExtractor();
      case 'okru':
        return OkRuExtractor();
      default:
        return null;
    }
  }
}
