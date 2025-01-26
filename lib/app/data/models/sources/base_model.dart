import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../services/external_helper_services_models/ani_skip.dart';

enum SourceType {
  none,
  movie,
  tv,
  anime,
  manga,
  documentary,
  cartoon,
  multi,
}

String sourceTypeToString(SourceType type) {
  switch (type) {
    case SourceType.none:
      return 'None';
    case SourceType.movie:
      return 'Movie';
    case SourceType.tv:
      return 'TV';
    case SourceType.anime:
      return 'Anime';
    case SourceType.manga:
      return 'Manga';
    case SourceType.documentary:
      return 'Documentary';
    case SourceType.multi:
      return 'Multi';
    case SourceType.cartoon:
      return 'Cartoon';
    default:
      return 'None';
  }
}

SourceType sourceTypeFromString(String type) {
  switch (type) {
    case 'None':
      return SourceType.none;
    case 'Movie':
      return SourceType.movie;
    case 'TV':
      return SourceType.tv;
    case 'Anime':
      return SourceType.anime;
    case 'Manga':
      return SourceType.manga;
    case 'Documentary':
      return SourceType.documentary;
    case 'Multi':
      return SourceType.multi;
    case 'Cartoon':
      return SourceType.cartoon;
    default:
      return SourceType.none;
  }
}

class BaseSourceModel {
  final String id;
  final SourceType type;
  final String sourceName;
  final String baseUrl;

  BaseSourceModel({
    required this.id,
    required this.type,
    required this.sourceName,
    required this.baseUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': sourceTypeToString(type),
      'sourceName': sourceName,
      'baseUrl': baseUrl,
    };
  }

  factory BaseSourceModel.fromJson(Map<String, dynamic> json) {
    return BaseSourceModel(
      id: json['id'],
      type: sourceTypeFromString(json['type']),
      sourceName: json['sourceName'],
      baseUrl: json['baseUrl'],
    );
  }
}

class BaseSourceModelList {
  final List<BaseSourceModel> sources;

  BaseSourceModelList({
    required this.sources,
  });
}

enum LanguageType {
  sub,
  dub,
  multi,
  other,
}

String languageTypeToString(LanguageType type) {
  switch (type) {
    case LanguageType.sub:
      return 'Sub';
    case LanguageType.dub:
      return 'Dub';
    case LanguageType.multi:
      return 'Multi';
    case LanguageType.other:
      return 'Other';
    default:
      return 'Other';
  }
}

LanguageType languageTypeFromString(String type) {
  switch (type) {
    case 'Sub':
      return LanguageType.sub;
    case 'Dub':
      return LanguageType.dub;
    case 'Multi':
      return LanguageType.multi;
    case 'Other':
      return LanguageType.other;
    default:
      return LanguageType.other;
  }
}

class EpisodeCount {
  int episodeCount;
  int altEpisodeCount;

  EpisodeCount({
    required this.episodeCount,
    required this.altEpisodeCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'episodeCount': episodeCount,
      'altEpisodeCount': altEpisodeCount,
    };
  }

  factory EpisodeCount.fromJson(Map<String, dynamic> json) {
    return EpisodeCount(
      episodeCount: json['episodeCount'],
      altEpisodeCount: json['altEpisodeCount'],
    );
  }
}

class Genre {
  final String? id;
  final String name;

  Genre({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
    );
  }
}

enum WatchStatus {
  watching,
  completed,
  onHold,
  dropped,
  planToWatch,
  notWatched,
}

String watchStatusToString(WatchStatus status) {
  switch (status) {
    case WatchStatus.watching:
      return 'Watching';
    case WatchStatus.completed:
      return 'Completed';
    case WatchStatus.onHold:
      return 'On Hold';
    case WatchStatus.dropped:
      return 'Dropped';
    case WatchStatus.planToWatch:
      return 'Plan to Watch';
    case WatchStatus.notWatched:
      return 'Not Watched';
    default:
      return 'Not Watched';
  }
}

WatchStatus watchStatusFromString(String status) {
  switch (status) {
    case 'Watching':
      return WatchStatus.watching;
    case 'Completed':
      return WatchStatus.completed;
    case 'On Hold':
      return WatchStatus.onHold;
    case 'Dropped':
      return WatchStatus.dropped;
    case 'Plan to Watch':
      return WatchStatus.planToWatch;
    case 'Not Watched':
      return WatchStatus.notWatched;
    default:
      return WatchStatus.notWatched;
  }
}

String dateToString(DateTime date) {
  return date.toString();
}

DateTime stringToDate(String date) {
  return DateTime.parse(date);
}

class WatchStatusModel {
  final WatchStatus status;
  EpisodeCount? episodeCount;
  int episodesWatched;
  int altEpisodesWatched;
  DateTime? lastWatchedDate;
  BaseEpisodeModel? lastWatchedEpisode;

  WatchStatusModel({
    required this.status,
    this.episodeCount,
    this.episodesWatched = 0,
    this.altEpisodesWatched = 0,
    this.lastWatchedDate,
    this.lastWatchedEpisode,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': watchStatusToString(status),
      'episodeCount': episodeCount,
      'episodesWatched': episodesWatched,
      'altEpisodesWatched': altEpisodesWatched,
      'lastWatchedDate':
          lastWatchedDate != null ? dateToString(lastWatchedDate!) : null,
      'lastWatchedEpisode':
          lastWatchedEpisode != null ? lastWatchedEpisode!.toJson() : null,
    };
  }

  factory WatchStatusModel.fromJson(Map<String, dynamic> json) {
    return WatchStatusModel(
      status: watchStatusFromString(json['status']),
      episodeCount: json['episodeCount'] != null
          ? EpisodeCount.fromJson(json['episodeCount'])
          : null,
      episodesWatched: json['episodesWatched'],
      altEpisodesWatched: json['altEpisodesWatched'],
      lastWatchedDate: json['lastWatchedDate'] != null
          ? stringToDate(json['lastWatchedDate'])
          : null,
      lastWatchedEpisode: json['lastWatchedEpisode'] != null
          ? BaseEpisodeModel.fromJson(json['lastWatchedEpisode'])
          : null,
    );
  }
}

class BaseItemModel {
  final BaseSourceModel source;
  final String id;
  final String title;
  final String imageUrl;
  final List<LanguageType> languages;
  final String? coverImageUrl;
  EpisodeCount? episodeCount;
  final List<Genre>? genres;
  final double? rating;
  WatchStatusModel? watchStatus;
  EpisodesWatchedModel? episodesWatched;

  BaseItemModel({
    required this.source,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.languages,
    this.coverImageUrl,
    this.episodeCount,
    this.genres,
    this.rating,
    this.watchStatus,
    this.episodesWatched,
  });

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'languages': languages.map((e) => languageTypeToString(e)).toList(),
      'coverImageUrl': coverImageUrl,
      'episodeCount': episodeCount,
      'genres': genres,
      'rating': rating,
      'watchStatus': watchStatus,
      'episodesWatched': episodesWatched,
    };
  }

  factory BaseItemModel.fromJson(Map<String, dynamic> json) {
    return BaseItemModel(
      source: BaseSourceModel.fromJson(json['source'] as Map<String, dynamic>),
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      languages: json['languages']
          .map<LanguageType>((e) => languageTypeFromString(e))
          .toList(),
      coverImageUrl: json['coverImageUrl'],
      episodeCount: json['episodeCount'] != null
          ? EpisodeCount.fromJson(json['episodeCount'] as Map<String, dynamic>)
          : null,
      genres: json['genres'] != null
          ? (json['genres'] as List)
              .map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      rating: json['rating'],
      watchStatus: json['watchStatus'] != null
          ? WatchStatusModel.fromJson(
              json['watchStatus'] as Map<String, dynamic>)
          : null,
      episodesWatched: json['episodesWatched'] != null
          ? EpisodesWatchedModel.fromJson(
              json['episodesWatched'] as Map<String, dynamic>)
          : null,
    );
  }
}

class BaseCategoryModel {
  final String categoryName;
  final List<BaseItemModel> items;
  final dynamic source;

  BaseCategoryModel({
    required this.categoryName,
    required this.items,
    required this.source,
  });
}

class VideoSourceInfoModel {
  final String sourceId;
  final String sourceName;
  final String baseUrl;

  VideoSourceInfoModel({
    required this.sourceId,
    required this.sourceName,
    required this.baseUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'sourceId': sourceId,
      'sourceName': sourceName,
      'baseUrl': baseUrl,
    };
  }

  factory VideoSourceInfoModel.fromJson(Map<String, dynamic> json) {
    return VideoSourceInfoModel(
      sourceId: json['sourceId'],
      sourceName: json['sourceName'],
      baseUrl: json['baseUrl'],
    );
  }
}

class RawVideoSourceInfoModel extends VideoSourceInfoModel {
  final String? embedUrl;
  final LanguageType? language;
  final String? magicString;
  final dynamic extractor;
  final AniSkipSkipData? opSkipData;
  final AniSkipSkipData? edSkipData;
  final List<SubtitlesModel>? subtitles;

  RawVideoSourceInfoModel({
    required this.embedUrl,
    required String sourceId,
    required String sourceName,
    required String baseUrl,
    this.extractor,
    this.language,
    this.magicString,
    this.opSkipData,
    this.edSkipData,
    this.subtitles,
  }) : super(
          sourceId: sourceId,
          sourceName: sourceName,
          baseUrl: baseUrl,
        );
}

enum VideoResolution {
  cam,
  p360,
  p480,
  p720,
  p1080,
  multi,
  other,
}

String videoResolutionToString(VideoResolution resolution) {
  switch (resolution) {
    case VideoResolution.cam:
      return 'cam';
    case VideoResolution.p360:
      return '360p';
    case VideoResolution.p480:
      return '480p';
    case VideoResolution.p720:
      return '720p';
    case VideoResolution.p1080:
      return '1080p';
    case VideoResolution.multi:
      return 'multi';
    case VideoResolution.other:
      return 'other';
  }
}

VideoResolution videoResolutionFromString(String resolution) {
  switch (resolution) {
    case 'cam':
      return VideoResolution.cam;
    case '360p':
      return VideoResolution.p360;
    case '480p':
      return VideoResolution.p480;
    case '720p':
      return VideoResolution.p720;
    case '1080p':
      return VideoResolution.p1080;
    case 'multi':
      return VideoResolution.multi;
    case 'other':
      return VideoResolution.other;
    default:
      return VideoResolution.other;
  }
}

class SubtitlesModel {
  final String subtitleUrl;
  final String subtitleName;
  final String subtitleLanguage;

  SubtitlesModel({
    required this.subtitleUrl,
    required this.subtitleName,
    required this.subtitleLanguage,
  });
}

class VideoSourceModel {
  final VideoSourceInfoModel source;
  final String sourceUrlDescription;
  final String videoUrl;
  final VideoResolution resolution;
  final int quality;
  final Map<String, String>? headers;
  final String? title;
  final List<SubtitlesModel>? subtitles;
  final AniSkipSkipData? opSkipData;
  final AniSkipSkipData? edSkipData;

  VideoSourceModel({
    required this.source,
    required this.sourceUrlDescription,
    required this.videoUrl,
    required this.resolution,
    required this.quality,
    this.headers,
    this.title,
    this.subtitles,
    this.opSkipData,
    this.edSkipData,
  });

  Map<String, dynamic> toJson() {
    return {
      'source': source.toJson(),
      'sourceUrlDescription': sourceUrlDescription,
      'videoUrl': videoUrl,
      'resolution': videoResolutionToString(resolution),
      'quality': quality,
      'headers': headers,
      'title': title,
    };
  }

  factory VideoSourceModel.fromJson(Map<String, dynamic> json) {
    return VideoSourceModel(
      source:
          VideoSourceInfoModel.fromJson(json['source'] as Map<String, dynamic>),
      sourceUrlDescription: json['sourceUrlDescription'],
      videoUrl: json['videoUrl'],
      resolution: videoResolutionFromString(json['resolution']),
      quality: json['quality'],
      headers: json['headers'] != null
          ? Map<String, String>.from(json['headers'] as Map)
          : null,
      title: json['title'],
    );
  }
}

class InfoPageArgumentsModel {
  final BaseItemModel item;
  final dynamic source;
  final bool playImmediately;

  InfoPageArgumentsModel({
    required this.item,
    required this.source,
    required this.playImmediately,
  });
}

class DetailedEpisodeModel {
  final String episodeId;
  final String? episodeName;
  final String? episodeUrl;
  final String? episodeThumbnail;
  final LanguageType? languageType;
  final int? seasonNumber;
  final String episodeNumber;
  final WatchStatus? watchStatus;
  final int? episodeDuration;
  final int? secondsWatched;
  final String? episodeDescription;
  final FillerStatus? fillerStatus;
  final DateTime? airDate;
  final int? relativeEpisodeNumber;

  DetailedEpisodeModel({
    required this.episodeId,
    this.episodeUrl,
    required this.episodeNumber,
    this.seasonNumber,
    this.languageType,
    this.episodeName,
    this.episodeThumbnail,
    this.watchStatus = WatchStatus.notWatched,
    this.episodeDuration,
    this.secondsWatched,
    this.episodeDescription,
    this.fillerStatus,
    this.airDate,
    this.relativeEpisodeNumber,
  });
}

class PlayerPageArgumentsModel {
  final BaseItemModel item;
  final DetailedEpisodeModel episodeData;
  final VideoSourceModel videoSource;
  final int? secondsWatched;
  final int? malId;

  PlayerPageArgumentsModel({
    required this.item,
    required this.episodeData,
    required this.videoSource,
    this.secondsWatched,
    this.malId,
  });
}

class PlayerScreenArgumentsModel {
  final BaseItemModel item;
  final DetailedEpisodeModel episodeData;

  final int? secondsWatched;
  final int? malId;
  final List<DetailedEpisodeModel> episodes;

  PlayerScreenArgumentsModel({
    required this.item,
    required this.episodeData,
    this.secondsWatched,
    this.malId,
    required this.episodes,
  });
}

class PlayerControlsArgumentsModel {
  Player player;
  VideoController videoController;
  PlayerScreenArgumentsModel playerScreenArguments;
  AniSkipSkipData? opSkipData;
  bool opSkipButtonVisible;
  AniSkipSkipData? edSkipData;
  bool edSkipButtonVisible;
  List<VideoSourceModel> videoSources;
  int? secondsWatched;
  final List<SubtitlesModel> subtitles;
  final SubtitlesModel? selectedSubtitle;
  Future<void> Function(SubtitlesModel subtitle) changeSubtitles;
  void Function() changeAspectRatio;
  void Function() changeVideoSource;
  int currentEpisodeOffset;
  void Function(int) changeCurrentEpisodeOffset;

  PlayerControlsArgumentsModel({
    required this.player,
    required this.videoController,
    required this.playerScreenArguments,
    this.opSkipData,
    this.opSkipButtonVisible = false,
    this.edSkipData,
    this.edSkipButtonVisible = false,
    required this.videoSources,
    required this.subtitles,
    this.secondsWatched,
    required this.changeSubtitles,
    this.selectedSubtitle,
    required this.changeAspectRatio,
    required this.changeVideoSource,
    required this.currentEpisodeOffset,
    required this.changeCurrentEpisodeOffset,
  });
}

class SearchPageSourceModel {
  final String sourceId;
  final String sourceName;
  final dynamic source;

  SearchPageSourceModel({
    required this.sourceId,
    required this.sourceName,
    required this.source,
  });
}

class BaseEpisodeModel {
  final String episodeId;
  final String episodeName;
  final String episodeNumber;
  final int secondsWatched;
  final int episodeDuration;
  final double progress;

  BaseEpisodeModel({
    required this.episodeId,
    required this.episodeName,
    required this.episodeNumber,
    required this.secondsWatched,
    required this.episodeDuration,
    required this.progress,
  });

  Map<String, dynamic> toJson() {
    return {
      'episodeId': episodeId,
      'episodeName': episodeName,
      'episodeNumber': episodeNumber,
      'secondsWatched': secondsWatched,
      'episodeDuration': episodeDuration,
      'progress': progress,
    };
  }

  factory BaseEpisodeModel.fromJson(Map<String, dynamic> json) {
    return BaseEpisodeModel(
      episodeId: json['episodeId'],
      episodeName: json['episodeName'],
      episodeNumber: json['episodeNumber'],
      secondsWatched: json['secondsWatched'],
      episodeDuration: json['episodeDuration'],
      progress: json['progress'],
    );
  }
}

class EpisodesWatchedModel {
  List<BaseEpisodeModel> episodesWatched;

  EpisodesWatchedModel({
    required this.episodesWatched,
  });

  Map<String, dynamic> toJson() {
    return {
      'episodesWatched': episodesWatched.map((e) => e.toJson()).toList(),
    };
  }

  factory EpisodesWatchedModel.fromJson(Map<String, dynamic> json) {
    return EpisodesWatchedModel(
      episodesWatched: json['episodesWatched']
          .map<BaseEpisodeModel>((e) => BaseEpisodeModel.fromJson(e))
          .toList(),
    );
  }
}

enum AiringStatus {
  airing,
  completed,
  upcoming,
  unknown,
}

String airingStatusToString(AiringStatus status) {
  switch (status) {
    case AiringStatus.airing:
      return 'Airing';
    case AiringStatus.completed:
      return 'Completed';
    case AiringStatus.upcoming:
      return 'Upcoming';
    case AiringStatus.unknown:
      return 'Unknown';
  }
}

AiringStatus airingStatusFromString(String status) {
  switch (status) {
    case 'Airing':
      return AiringStatus.airing;
    case 'Completed':
      return AiringStatus.completed;
    case 'Upcoming':
      return AiringStatus.upcoming;
    case 'Unknown':
      return AiringStatus.unknown;
    default:
      return AiringStatus.unknown;
  }
}

enum ItemType {
  tv,
  movie,
  cartoon,
  ova,
  special,
  ona,
  unknown,
}

String itemTypeToString(ItemType type) {
  switch (type) {
    case ItemType.tv:
      return 'TV';
    case ItemType.movie:
      return 'Movie';
    case ItemType.cartoon:
      return 'Cartoon';
    case ItemType.ova:
      return 'OVA';
    case ItemType.special:
      return 'Special';
    case ItemType.ona:
      return 'ONA';
    case ItemType.unknown:
      return 'Unknown';
  }
}

ItemType itemTypeFromString(String type) {
  switch (type.toLowerCase()) {
    case 'tv':
      return ItemType.tv;
    case 'movie':
      return ItemType.movie;
    case 'cartoon':
      return ItemType.cartoon;
    case 'ova':
      return ItemType.ova;
    case 'special':
      return ItemType.special;
    case 'ona':
      return ItemType.ona;
    case 'unknown':
      return ItemType.unknown;
    default:
      return ItemType.unknown;
  }
}

class BaseActorModel {
  final String actorName;
  final String sourceId;
  final String? actorImageUrl;
  final String? version;
  final String? characterName;
  final String? characterImageUrl;
  final String? characterDescription;
  final String? actorId;
  final String? characterId;

  BaseActorModel({
    required this.actorName,
    required this.sourceId,
    this.actorImageUrl,
    this.version,
    this.characterName,
    this.characterImageUrl,
    this.characterDescription,
    this.actorId,
    this.characterId,
  });
}

class BaseRelatedVideosModel {
  final String videoId;
  final String videoUrl;
  final String? videoTitle;
  final String? videoThumbnail;

  BaseRelatedVideosModel({
    required this.videoId,
    required this.videoUrl,
    this.videoTitle,
    this.videoThumbnail,
  });
}

class BaseSeasonInfoModel {
  BaseSeasonInfoModel({
    this.airDate,
    required this.episodeCount,
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    required this.seasonNumber,
  });

  DateTime? airDate;
  int episodeCount;
  int id;
  String name;
  String overview;
  String? posterPath;
  int seasonNumber;

  factory BaseSeasonInfoModel.fromJson(Map<String, dynamic> json) =>
      BaseSeasonInfoModel(
        airDate:
            json["air_date"] == null ? null : DateTime.parse(json["air_date"]),
        episodeCount: json["episode_count"],
        id: json["id"],
        name: json["name"],
        overview: json["overview"],
        posterPath: json["poster_path"],
        seasonNumber: json["season_number"],
      );

  Map<String, dynamic> toJson() => {
        "air_date":
            "${airDate!.year.toString().padLeft(4, '0')}-${airDate!.month.toString().padLeft(2, '0')}-${airDate!.day.toString().padLeft(2, '0')}",
        "episode_count": episodeCount,
        "id": id,
        "name": name,
        "overview": overview,
        "poster_path": posterPath,
        "season_number": seasonNumber,
      };
}

class BaseDetailedItemModel extends BaseItemModel {
  final ItemType? type;
  final AiringStatus? status;
  final String synopsis;
  final DateTime? releaseDate;
  final DateTime? endDate;
  final List<DetailedEpisodeModel> episodes;
  final List<DetailedEpisodeModel>? altEpisodes;
  final List<String>? otherTitles;
  final String? movieId;
  final String? alias;
  final List<BaseActorModel>? actors;
  final List<BaseRelatedVideosModel>? relatedVideos;
  final int? malId;
  final Map<String, dynamic>? jikanData;
  final List<BaseItemModel>? relatedItems;
  final String? tmdbId;
  final List<BaseSeasonInfoModel>? seasons;

  BaseDetailedItemModel({
    required BaseSourceModel source,
    required String id,
    required String title,
    required String imageUrl,
    required List<LanguageType> languages,
    double? rating,
    String? coverImageUrl,
    required this.synopsis,
    required this.episodes,
    this.type,
    this.status,
    this.releaseDate,
    this.endDate,
    EpisodeCount? episodeCount,
    List<Genre>? genres,
    WatchStatusModel? watchStatus,
    this.movieId,
    this.alias,
    this.altEpisodes,
    this.otherTitles,
    this.actors,
    this.relatedVideos,
    this.malId,
    this.jikanData,
    this.relatedItems,
    this.tmdbId,
    this.seasons,
  }) : super(
          source: source,
          id: id,
          title: title,
          imageUrl: imageUrl,
          languages: languages,
          episodeCount: episodeCount,
          genres: genres,
          watchStatus: watchStatus,
          rating: rating,
          coverImageUrl: coverImageUrl,
        );
}

enum FillerStatus {
  filler,
  canon,
  mixed,
  unknown,
  none,
}

String? fillerStatusToString(FillerStatus status) {
  switch (status) {
    case FillerStatus.filler:
      return 'Filler';
    case FillerStatus.canon:
      return 'Canon';
    case FillerStatus.mixed:
      return 'Mixed';
    case FillerStatus.unknown:
      return 'Unknown';
    case FillerStatus.none:
      return null;
  }
}

FillerStatus? fillerStatusFromString(String status) {
  switch (status) {
    case 'Filler':
      return FillerStatus.filler;
    case 'Canon':
      return FillerStatus.canon;
    case 'Mixed':
      return FillerStatus.mixed;
    case 'Unknown':
      return FillerStatus.unknown;
    case 'None':
      return FillerStatus.none;
    default:
      return null;
  }
}
