import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';
import 'package:mana_debug/app/widgets/episode_box/episode_box.dart';
import 'package:mana_debug/app/widgets/keep_alive/keep_alive_widget.dart';
import 'package:skeletons/skeletons.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../bloc/cubit/cubits.dart';
import '../core/values/constants.dart';
import '../data/models/services/external_helper_services_models/anime_filler_list.dart';
import '../data/models/services/external_helper_services_models/kitsu.dart';
import '../data/models/services/external_helper_services_models/tmdb.dart';
import '../data/services/external_helper_services/anime_filler_list.dart';
import '../data/services/external_helper_services/jikan.dart';
import '../data/services/external_helper_services/kitsu.dart';
import '../data/services/external_helper_services/tmdb.dart';
import '../widgets/bottom_sheet/info_bottom_sheet.dart';
import '../widgets/watch_status_manager/watch_status_button.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  var currentEpisodePage = 0;
  var currentEpisodeIndex = 0;
  bool fetchedOtherInfo = false;
  TabController? tabController;
  bool updatedWatchHistoryItem = false;
  bool updatedFavoriteItem = false;

  late WatchHistoryCubit watchHistoryCubitProvider;
  late FavoritesCubit favoritesCubitProvider;

  void playButtonOnClicked(
      BaseItemModel? watchHistoryItem,
      List<DetailedEpisodeModel> episodes,
      dynamic source,
      BaseDetailedItemModel item,
      BaseItemModel baseItem,
      int? malId) async {
    if (watchHistoryItem != null) {
      Navigator.of(context).pushNamed(
        "/player",
        arguments: PlayerScreenArgumentsModel(
          episodeData: episodes
              .where((element) =>
                  element.episodeId ==
                  watchHistoryItem.watchStatus?.lastWatchedEpisode?.episodeId)
              .first,
          item: BaseItemModel(
              source: watchHistoryItem.source,
              id: watchHistoryItem.id,
              title: watchHistoryItem.title,
              imageUrl: watchHistoryItem.imageUrl,
              languages: watchHistoryItem.languages,
              episodeCount: item.episodeCount),
          secondsWatched: watchHistoryItem
                  .watchStatus?.lastWatchedEpisode?.secondsWatched ??
              0,
          malId: malId,
          episodes: episodes,
        ),
      );
    } else {
      Navigator.of(context).pushNamed(
        "/player",
        arguments: PlayerScreenArgumentsModel(
          episodeData: episodes[0],
          item: BaseItemModel(
              source: baseItem.source,
              id: baseItem.id,
              title: baseItem.title,
              imageUrl: baseItem.imageUrl,
              languages: baseItem.languages,
              episodeCount: item.episodeCount),
          secondsWatched: null,
          malId: malId,
          episodes: episodes,
        ),
      );
    }
  }

  bool playedImmediately = false;
  PageController relatedVideosPageController = PageController(
    initialPage: 999,
  );

  bool dataLoaded = false;
  BaseDetailedItemModel? item;

  var animeFillerList = AnimeFillerListService();
  List<AnimeFillerListData>? fillerEpisodes;
  var tmdbService = TMDBService();
  Map<String, dynamic>? tmdbInfo;
  String? tmdbId;
  TMDBDetailsResponseModel? tmdbData;
  List<Episode> tmdbSeasonData = [];
  var jikan = JikanService();
  var kitsuService = KitsuService();
  KitsuEpisodeData? kitsuEpisodes;
  Map<String, dynamic>? jikanData;
  var actors = <BaseActorModel>[];
  int? malId;

  var count = 1;
  var relatedVideos = <BaseRelatedVideosModel>[];

  Future<void> getFillerData(BaseDetailedItemModel item) async {
    fillerEpisodes = await animeFillerList.getAnimeFillerListData(
        item.title.replaceFirst('(Sub)', '').replaceFirst("(Dub)", "").trim());
    setState(() {});
  }

  Future<void> getTMDBInfo(BaseDetailedItemModel item) async {
    tmdbInfo = await tmdbService.getItemImdbIdFromName(
        item.title.replaceFirst("(Dub)", "").replaceFirst("(Sub)", "").trim(),
        isAnime: item.source.type == SourceType.anime);
    if (tmdbInfo != null) {
      tmdbId = tmdbInfo!['id'];
    }
    if (tmdbInfo != null) {
      tmdbData =
          await tmdbService.getItemDetails(tmdbInfo!['id'], tmdbInfo!['type']);

      if (tmdbInfo!['seasonNumber'] != null &&
          tmdbInfo!['type'] == MediaType.TV) {
        var seasonData = await tmdbService.getItemSeasonData(
            tmdbInfo!['id'], tmdbInfo!['seasonNumber']);
        if (seasonData != null) {
          tmdbSeasonData.addAll(seasonData.episodes);
        }
      } else if (tmdbInfo!['type'] == MediaType.TV) {
        for (var season in tmdbData?.seasons ?? []) {
          if (season.seasonNumber == 0) {
            continue;
          }
          var seasonData = await tmdbService.getItemSeasonData(
              tmdbInfo!['id'], season.seasonNumber);
          if (seasonData != null) {
            tmdbSeasonData.addAll(seasonData.episodes);
          }
        }
      }
    }
    setState(() {});
  }

  Future<void> getKitsuInfo(BaseDetailedItemModel item) async {
    malId = await jikan.getAnimeMalIdFromSearch(
        item.title.replaceFirst('(Sub)', '').replaceFirst("(Dub)", "").trim(),
        item.otherTitles
                ?.map((e) => e
                    .replaceFirst('(Sub)', '')
                    .replaceFirst("(Dub)", "")
                    .trim())
                .toList() ??
            [],
        item.type ?? ItemType.tv);
    debugPrint('/////////////////////////////// MAL ID: $malId');
    if (malId != null) {
      kitsuEpisodes = await kitsuService.getKitsuEpisodeDataFromMalId(malId!);
    }
    if (malId != null) {
      jikanData = await jikan.getFullInfoFromMalId(malId!);
    } else {
      jikanData = null;
    }
    if (malId != null) {
      var jikanCharacters = await jikan.getAnimeCharactersFromMalId(malId!);
      for (var character in jikanCharacters!['data']) {
        if (character['voice_actors'].length == 0) {
          var actor = BaseActorModel(
            actorName: '',
            sourceId: 'jikan',
            actorImageUrl: null,
            version: null,
            characterName: character['character']['name'],
            characterImageUrl: character['character']['images']['jpg']
                ['image_url'],
            characterDescription: character['role'],
            actorId: null,
            characterId: character['character']['mal_id'].toString(),
          );

          actors.add(actor);
          count += 1;
          if (count == 20) {
            break;
          } else {
            continue;
          }
        }
        var actor = BaseActorModel(
          actorName: character['voice_actors'][0]['person']['name'],
          sourceId: 'jikan',
          actorImageUrl: character['voice_actors'][0]['person']['images']['jpg']
              ['image_url'],
          version: character['voice_actors'][0]['language'],
          characterName: character['character']['name'],
          characterImageUrl: character['character']['images']['jpg']
              ['image_url'],
          characterDescription: character['role'],
          actorId: character['voice_actors'][0]['person']['mal_id'].toString(),
          characterId: character['character']['mal_id'].toString(),
        );

        actors.add(actor);
        count += 1;
        if (count == 20) {
          break;
        }
      }
    }

    if (jikanData != null) {
      if (jikanData!['data']['trailer']['youtube_id'] != null) {
        relatedVideos.add(BaseRelatedVideosModel(
          videoId: jikanData!['data']['trailer']['youtube_id'],
          videoUrl: jikanData!['data']['trailer']['url'],
          videoTitle: jikanData!['data']['title'] + ' Trailer',
          videoThumbnail: jikanData!['data']['trailer']['images']
              ['maximum_image_url'],
        ));
      }
    }
    setState(() {});
  }

  void getOtherData(BaseDetailedItemModel item) {
    Future.microtask(() => getFillerData(item));
    Future.microtask(() => getTMDBInfo(item));
    Future.microtask(() => getKitsuInfo(item));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    watchHistoryCubitProvider = BlocProvider.of<WatchHistoryCubit>(context);
    favoritesCubitProvider = BlocProvider.of<FavoritesCubit>(context);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final args =
        ModalRoute.of(context)!.settings.arguments as InfoPageArgumentsModel;
    debugPrint("${args.item.id}/////////////////////////");
    BaseItemModel? watchHistoryItem;
    if (watchHistoryCubitProvider.matchWatchHistory(args.item)) {
      watchHistoryItem =
          watchHistoryCubitProvider.getWatchHistoryItem(args.item);
    }
    return BlocBuilder(
      bloc: BlocProvider.of<WatchHistoryCubit>(context),
      builder: (context, watchHistory) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: FutureBuilder(
            future: dataLoaded
                ? Future.value(item!)
                : args.source.scrapeDetails(args.item.id),
            builder: (context, AsyncSnapshot<BaseDetailedItemModel> snapshot) {
              if (snapshot.hasError) {
                debugPrint(
                    "${snapshot.error.toString()}/////////////////////////");
              }
              if (snapshot.hasData) {
                dataLoaded = true;
                item = snapshot.data!;
                if (fetchedOtherInfo == false) {
                  fetchedOtherInfo = true;
                  getOtherData(snapshot.data!);
                }
                if (watchHistoryItem != null &&
                    updatedWatchHistoryItem == false) {
                  if (watchHistoryItem.episodeCount != null &&
                      snapshot.data!.episodeCount != null) {
                    watchHistoryCubitProvider
                        .updateWatchHistoryItemEpisodeCount(
                            watchHistoryItem, snapshot.data!.episodeCount!);
                    favoritesCubitProvider.updateFavoriteEpisodeCount(
                        args.item, snapshot.data!.episodeCount!);
                  }
                  updatedWatchHistoryItem = true;
                }
                if (updatedFavoriteItem == false) {
                  favoritesCubitProvider.updateFavoriteEpisodeCount(
                    args.item,
                    snapshot.data!.episodeCount!,
                  );
                  updatedFavoriteItem = true;
                }
                var episodePages = snapshot.data!.episodes.length ~/ 20;
                if (snapshot.data!.episodes.length % 20 != 0) {
                  episodePages++;
                }
                if (args.playImmediately && !playedImmediately) {
                  playedImmediately = true;
                  playButtonOnClicked(watchHistoryItem, snapshot.data!.episodes,
                      args.source, snapshot.data!, args.item, malId);
                }
                if (snapshot.data!.relatedVideos != null) {
                  relatedVideos.addAll(snapshot.data!.relatedVideos!);
                }
                return NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 0),
                    children: <Widget>[
                      relatedVideos.isNotEmpty
                          ? Column(
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).padding.top),
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Stack(
                                    children: [
                                      PageView.builder(
                                        controller: relatedVideosPageController,
                                        itemBuilder: (context, index) {
                                          return YoutubePlayer(
                                            controller: YoutubePlayerController(
                                              initialVideoId: relatedVideos[
                                                      index %
                                                          relatedVideos.length]
                                                  .videoId,
                                              flags: const YoutubePlayerFlags(
                                                autoPlay: false,
                                                mute: false,
                                              ),
                                            ),
                                            showVideoProgressIndicator: true,
                                            progressIndicatorColor:
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                            progressColors: ProgressBarColors(
                                              playedColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              handleColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            bottomActions: [
                                              CurrentPosition(),
                                              const SizedBox(width: 10.0),
                                              ProgressBar(
                                                isExpanded: true,
                                                colors: ProgressBarColors(
                                                  playedColor: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  handleColor: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                              const SizedBox(width: 10.0),
                                              RemainingDuration(),
                                              const PlaybackSpeedButton(),
                                            ],
                                          );
                                        },
                                      ),
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withOpacity(0.7),
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            icon: const Icon(
                                              Icons.arrow_back,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      relatedVideos.length > 1
                                          ? Positioned(
                                              bottom: 35.0,
                                              right: 8.0,
                                              child: Row(
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      relatedVideosPageController
                                                          .previousPage(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              curve:
                                                                  Curves.ease);
                                                    },
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .surface
                                                              .withOpacity(0.7),
                                                        ),
                                                        shape: MaterialStateProperty
                                                            .all<
                                                                RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0),
                                                          ),
                                                        )),
                                                    child: const Text(
                                                      "Previous",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      relatedVideosPageController
                                                          .nextPage(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              curve:
                                                                  Curves.ease);
                                                    },
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color>(
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .surface
                                                              .withOpacity(0.7),
                                                        ),
                                                        shape: MaterialStateProperty
                                                            .all<
                                                                RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0),
                                                          ),
                                                        )),
                                                    child: const Text(
                                                      "Next",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Stack(
                                children: [
                                  Image.network(
                                    args.item.imageUrl,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            SizedBox(
                                      // width: 125,
                                      child: Skeleton(
                                        isLoading: true,
                                        skeleton: SkeletonAvatar(
                                          style: SkeletonAvatarStyle(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.4 -
                                                5,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                          ),
                                        ),
                                        themeMode: ThemeMode.dark,
                                        child: Container(),
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                    height: MediaQuery.of(context).size.height *
                                            0.4 -
                                        5,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.center,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top:
                                        MediaQuery.of(context).padding.top + 10,
                                    left: 10,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withOpacity(0.7),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 0,
                          bottom: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 12,
                                  child: Text(
                                    args.item.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: FavoritesButton(
                                      item: BaseItemModel(
                                    source: args.item.source,
                                    id: args.item.id,
                                    title: args.item.title,
                                    imageUrl: args.item.imageUrl,
                                    languages: args.item.languages,
                                    episodeCount: EpisodeCount(
                                      episodeCount:
                                          snapshot.data!.episodes.length,
                                      altEpisodeCount:
                                          snapshot.data!.altEpisodes?.length ??
                                              0,
                                    ),
                                    watchStatus: WatchStatusModel(
                                      status: WatchStatus.notWatched,
                                      episodeCount: EpisodeCount(
                                        episodeCount:
                                            snapshot.data!.episodes.length,
                                        altEpisodeCount: snapshot
                                                .data!.altEpisodes?.length ??
                                            0,
                                      ),
                                      episodesWatched: 0,
                                      altEpisodesWatched: 0,
                                      lastWatchedDate: null,
                                      lastWatchedEpisode: null,
                                    ),
                                    episodesWatched: null,
                                  )),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    args.item.source.sourceName,
                                    style: GoogleFonts.roboto(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    itemTypeToString(snapshot.data!.type ??
                                        ItemType.unknown),
                                    style: GoogleFonts.roboto(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                snapshot.data!.releaseDate != null
                                    ? Container(
                                        padding:
                                            snapshot.data!.releaseDate != null
                                                ? const EdgeInsets.all(5)
                                                : const EdgeInsets.all(0),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: snapshot.data!.releaseDate !=
                                                null
                                            ? Text(
                                                snapshot.data!.releaseDate!.year
                                                    .toString(),
                                                style: GoogleFonts.roboto(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      )
                                    : const SizedBox.shrink(),
                                snapshot.data!.releaseDate != null
                                    ? const SizedBox(width: 10)
                                    : const SizedBox.shrink(),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    airingStatusToString(
                                        snapshot.data!.status ??
                                            AiringStatus.unknown),
                                    style: GoogleFonts.roboto(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              snapshot.data!.synopsis,
                              style: GoogleFonts.roboto(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            actors.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Actors",
                                        style: GoogleFonts.roboto(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: List.generate(
                                            actors.length,
                                            (index) => Container(
                                              width: 75,
                                              margin: const EdgeInsets.only(
                                                right: 15,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio: 1 / 1,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              37.5),
                                                      child: Stack(
                                                        children: [
                                                          Container(
                                                            height: 75,
                                                            width: 75,
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    NetworkImage(
                                                                  actors[index]
                                                                      .characterImageUrl!,
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            bottom: 5,
                                                            right: 5,
                                                            child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                                child: actors[index]
                                                                            .actorImageUrl !=
                                                                        null
                                                                    ? Container(
                                                                        height:
                                                                            40,
                                                                        width:
                                                                            40,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                NetworkImage(
                                                                              actors[index].actorImageUrl!,
                                                                            ),
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : const SizedBox()),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    actors[index]
                                                        .characterName!,
                                                    style: GoogleFonts.roboto(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  actors[index].actorName != ""
                                                      ? Text(
                                                          actors[index]
                                                              .actorName,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            color: Colors
                                                                .grey[300],
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.center,
                                                        )
                                                      : const SizedBox.shrink(),
                                                  Text(
                                                    actors[index]
                                                        .characterDescription!,
                                                    style: GoogleFonts.roboto(
                                                      color: Colors.grey,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 8.0),
                            snapshot.data!.otherTitles != null &&
                                    snapshot.data!.otherTitles!.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Other Titles",
                                        style: GoogleFonts.roboto(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: snapshot.data!.otherTitles!
                                            .map((e) => Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surface,
                                                    border: Border.all(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .surface,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Text(
                                                    e,
                                                    style: GoogleFonts.roboto(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 8.0),
                            snapshot.data!.genres != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Genres",
                                        style: GoogleFonts.roboto(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: snapshot.data!.genres!
                                            .map((e) => Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surface,
                                                    border: Border.all(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .surface,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Text(
                                                    e.name,
                                                    style: GoogleFonts.roboto(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 8.0),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  playButtonOnClicked(
                                    watchHistoryItem,
                                    snapshot.data!.episodes,
                                    args.source,
                                    snapshot.data!,
                                    args.item,
                                    malId,
                                  );
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: watchHistoryItem == null
                                    ? Text("Play",
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ))
                                    : watchHistoryItem
                                                .watchStatus!.episodesWatched >
                                            0
                                        ? Text(
                                            "Resume Episode ${watchHistoryItem.watchStatus!.lastWatchedEpisode!.episodeNumber}",
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          )
                                        : Text(
                                            "Play",
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            snapshot.data!.relatedItems != null &&
                                    snapshot.data!.relatedItems!.isNotEmpty
                                ? DefaultTabController(
                                    length: 2,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TabBar(
                                          controller: tabController,
                                          indicatorColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          labelColor: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          unselectedLabelColor:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onBackground
                                                  .withOpacity(0.5),
                                          tabs: const [
                                            Tab(
                                              text: "Episodes",
                                            ),
                                            Tab(
                                              text: "Related",
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 12.0,
                                        ),
                                        ShrinkWrappingTabBarView(
                                          tabController: tabController!,
                                          children: [
                                            KeepAliveWidget(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Row(
                                                      children: [
                                                        DropdownButton(
                                                          onChanged: (value) {
                                                            setState(() {
                                                              currentEpisodePage =
                                                                  value as int;
                                                            });
                                                          },
                                                          style: GoogleFonts
                                                              .roboto(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onBackground,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                          value:
                                                              currentEpisodePage,
                                                          items: List.generate(
                                                            episodePages,
                                                            (index) =>
                                                                DropdownMenuItem(
                                                              value: index,
                                                              child: Text(
                                                                "${index * 20 + 1} - ${snapshot.data!.episodes.length < (index + 1) * 20 ? snapshot.data!.episodes.length : (index + 1) * 20}",
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onBackground,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Text(
                                                          "${snapshot.data!.episodes.length} Episodes",
                                                          style: GoogleFonts
                                                              .roboto(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onBackground,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: snapshot
                                                        .data!.episodes
                                                        .sublist(
                                                            currentEpisodePage *
                                                                20,
                                                            snapshot.data!.episodes
                                                                        .length <
                                                                    (currentEpisodePage +
                                                                            1) *
                                                                        20
                                                                ? snapshot
                                                                    .data!
                                                                    .episodes
                                                                    .length
                                                                : (currentEpisodePage +
                                                                        1) *
                                                                    20)
                                                        .map(
                                                          (episodeData) =>
                                                              BlocBuilder(
                                                                  bloc: BlocProvider
                                                                      .of<WatchHistoryCubit>(
                                                                          context),
                                                                  builder:
                                                                      (context,
                                                                          state) {
                                                                    var newEpNum = episodeData
                                                                            .episodeNumber
                                                                            .toLowerCase()
                                                                            .contains(
                                                                                "-")
                                                                        ? double.parse(episodeData.episodeNumber.split("-")[1])
                                                                            .round()
                                                                        : double.parse(episodeData.episodeNumber)
                                                                            .round();
                                                                    if (!snapshot
                                                                        .data!
                                                                        .episodes[
                                                                            0]
                                                                        .episodeNumber
                                                                        .toLowerCase()
                                                                        .contains(
                                                                            "movie")) {
                                                                      if (double.parse(snapshot.data!.episodes[0].episodeNumber).round() -
                                                                              1 !=
                                                                          -1) {
                                                                        currentEpisodeIndex = episodeData.episodeNumber.toLowerCase().contains("movie")
                                                                            ? 0
                                                                            : newEpNum -
                                                                                1;
                                                                      } else {
                                                                        currentEpisodeIndex = episodeData.episodeNumber.toLowerCase().contains("movie")
                                                                            ? 0
                                                                            : newEpNum;
                                                                      }
                                                                    } else {
                                                                      currentEpisodeIndex = episodeData
                                                                              .episodeNumber
                                                                              .toLowerCase()
                                                                              .contains("movie")
                                                                          ? 0
                                                                          : newEpNum;
                                                                    }
                                                                    var match =
                                                                        watchHistoryCubitProvider
                                                                            .matchWatchHistoryEpisode(
                                                                      BaseEpisodeModel(
                                                                        episodeId:
                                                                            episodeData.episodeId,
                                                                        episodeName:
                                                                            episodeData.episodeName ??
                                                                                "",
                                                                        episodeNumber:
                                                                            episodeData.episodeNumber,
                                                                        secondsWatched:
                                                                            episodeData.secondsWatched ??
                                                                                0,
                                                                        episodeDuration:
                                                                            episodeData.episodeDuration ??
                                                                                0,
                                                                        progress:
                                                                            0,
                                                                      ),
                                                                      args.item,
                                                                    );
                                                                    Episode?
                                                                        activeTMDBEpisode;
                                                                    try {
                                                                      activeTMDBEpisode = episodeData.relativeEpisodeNumber !=
                                                                              null
                                                                          ? tmdbSeasonData.firstWhere((element) =>
                                                                              element.episodeNumber == episodeData.relativeEpisodeNumber &&
                                                                              element.seasonNumber == episodeData.seasonNumber)
                                                                          : tmdbSeasonData.firstWhere((element) => element.episodeNumber == currentEpisodeIndex + 1);
                                                                    } catch (e) {
                                                                      activeTMDBEpisode =
                                                                          null;
                                                                    }
                                                                    if (activeTMDBEpisode ==
                                                                        null) {
                                                                      try {
                                                                        activeTMDBEpisode = tmdbSeasonData.firstWhere((element) =>
                                                                            element.episodeNumber ==
                                                                            currentEpisodeIndex +
                                                                                1);
                                                                      } catch (e) {
                                                                        activeTMDBEpisode =
                                                                            null;
                                                                      }
                                                                    }
                                                                    AnimeFillerListData?
                                                                        fillerData;
                                                                    try {
                                                                      fillerData =
                                                                          fillerEpisodes?[
                                                                              currentEpisodeIndex];
                                                                    } catch (e) {
                                                                      fillerData =
                                                                          null;
                                                                    }
                                                                    Node?
                                                                        kitsuEpisodeData;
                                                                    try {
                                                                      kitsuEpisodeData =
                                                                          kitsuEpisodes
                                                                              ?.nodes[currentEpisodeIndex];
                                                                    } catch (e) {
                                                                      kitsuEpisodeData =
                                                                          null;
                                                                    }
                                                                    return match !=
                                                                            null
                                                                        ? EpisodeBox(
                                                                            episodeData:
                                                                                episodeData,
                                                                            args:
                                                                                args,
                                                                            progress:
                                                                                match.progress,
                                                                            secondsWatched:
                                                                                match.secondsWatched,
                                                                            episodeCount:
                                                                                EpisodeCount(
                                                                              episodeCount: snapshot.data?.episodes.length ?? 0,
                                                                              altEpisodeCount: snapshot.data?.altEpisodes?.length ?? 0,
                                                                            ),
                                                                            malId:
                                                                                malId,
                                                                            episodes:
                                                                                snapshot.data!.episodes,
                                                                            fillerStatus:
                                                                                fillerData,
                                                                            tmdbImageBaseUrl:
                                                                                tmdbService.imageBaseUrl,
                                                                            kitsuEpisodeData:
                                                                                kitsuEpisodeData,
                                                                            tmdbEpisodeData:
                                                                                activeTMDBEpisode,
                                                                          )
                                                                        : EpisodeBox(
                                                                            episodeData:
                                                                                episodeData,
                                                                            args:
                                                                                args,
                                                                            progress:
                                                                                0,
                                                                            secondsWatched:
                                                                                null,
                                                                            episodeCount:
                                                                                EpisodeCount(
                                                                              episodeCount: snapshot.data?.episodes.length ?? 0,
                                                                              altEpisodeCount: snapshot.data?.altEpisodes?.length ?? 0,
                                                                            ),
                                                                            malId:
                                                                                malId,
                                                                            episodes:
                                                                                snapshot.data!.episodes,
                                                                            fillerStatus:
                                                                                fillerData,
                                                                            tmdbImageBaseUrl:
                                                                                tmdbService.imageBaseUrl,
                                                                            kitsuEpisodeData:
                                                                                kitsuEpisodeData,
                                                                            tmdbEpisodeData:
                                                                                activeTMDBEpisode,
                                                                          );
                                                                  }),
                                                        )
                                                        .toList(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            //   ],
                                            // ),
                                            KeepAliveWidget(
                                              child: Wrap(
                                                spacing: 10,
                                                runSpacing: 10,
                                                children: [
                                                  ...snapshot
                                                      .data!.relatedItems!
                                                      .map(
                                                        (e) => SizedBox(
                                                          width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width >
                                                                  800
                                                              ? MediaQuery.of(context)
                                                                          .size
                                                                          .width /
                                                                      7 -
                                                                  12.5
                                                              : MediaQuery.of(context)
                                                                          .size
                                                                          .width /
                                                                      3 -
                                                                  15,
                                                          child: SizedBox(
                                                            width:
                                                                double.infinity,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                showModalBottomSheet(
                                                                    context:
                                                                        context,
                                                                    useRootNavigator:
                                                                        true,
                                                                    backgroundColor:
                                                                        bottomSheetColor,
                                                                    shape:
                                                                        const RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              8.0),
                                                                          topRight:
                                                                              Radius.circular(8.0)),
                                                                    ),
                                                                    builder:
                                                                        (context) {
                                                                      return InfoBottomSheet(
                                                                        item: e,
                                                                        source:
                                                                            args.source,
                                                                      );
                                                                    });
                                                              },
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  AspectRatio(
                                                                    aspectRatio:
                                                                        3 / 4.25,
                                                                    child:
                                                                        Container(
                                                                      margin: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              4.0),
                                                                      height: double
                                                                          .infinity,
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            child:
                                                                                Image.network(
                                                                              e.imageUrl,
                                                                              errorBuilder: (context, error, stackTrace) => SizedBox(
                                                                                child: Skeleton(
                                                                                  isLoading: true,
                                                                                  skeleton: const SkeletonAvatar(
                                                                                    style: SkeletonAvatarStyle(
                                                                                      width: double.infinity,
                                                                                      height: double.infinity,
                                                                                    ),
                                                                                  ),
                                                                                  themeMode: ThemeMode.dark,
                                                                                  child: Container(),
                                                                                ),
                                                                              ),
                                                                              fit: BoxFit.cover,
                                                                              height: double.infinity,
                                                                              width: double.infinity,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                double.infinity,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  e.rating != null
                                                                                      ? Column(
                                                                                          children: [
                                                                                            Container(
                                                                                              margin: const EdgeInsets.only(bottom: 5),
                                                                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                                              decoration: BoxDecoration(
                                                                                                color: Theme.of(context).colorScheme.primary,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                              ),
                                                                                              child: Row(
                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                children: [
                                                                                                  const Icon(
                                                                                                    Icons.star,
                                                                                                    color: Colors.white,
                                                                                                    size: 12,
                                                                                                  ),
                                                                                                  const SizedBox(
                                                                                                    width: 2,
                                                                                                  ),
                                                                                                  Text(
                                                                                                    e.rating.toString(),
                                                                                                    style: GoogleFonts.roboto(
                                                                                                      fontSize: 12,
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      color: Colors.white,
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        )
                                                                                      : const SizedBox(),
                                                                                  Column(
                                                                                    children: e.languages
                                                                                        .map((e) => Container(
                                                                                              margin: const EdgeInsets.only(bottom: 5),
                                                                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                                              decoration: BoxDecoration(
                                                                                                color: Theme.of(context).colorScheme.primary,
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                              ),
                                                                                              child: Text(
                                                                                                e.toString().replaceFirst("LanguageType.", "")[0].toUpperCase() + e.toString().replaceFirst("LanguageType.", "").substring(1),
                                                                                                style: GoogleFonts.roboto(
                                                                                                  fontSize: 12,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  color: Colors.white,
                                                                                                ),
                                                                                              ),
                                                                                            ))
                                                                                        .toList(),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          135,
                                                                      child:
                                                                          Text(
                                                                        e.title,
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ))
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: Row(
                                          children: [
                                            DropdownButton(
                                              onChanged: (value) {
                                                setState(() {
                                                  currentEpisodePage =
                                                      value as int;
                                                });
                                              },
                                              style: GoogleFonts.roboto(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              value: currentEpisodePage,
                                              items: List.generate(
                                                episodePages,
                                                (index) => DropdownMenuItem(
                                                  value: index,
                                                  child: Text(
                                                    "${index * 20 + 1} - ${snapshot.data!.episodes.length < (index + 1) * 20 ? snapshot.data!.episodes.length : (index + 1) * 20}",
                                                    style: GoogleFonts.roboto(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "${snapshot.data!.episodes.length} Episodes",
                                              style: GoogleFonts.roboto(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: snapshot.data!.episodes
                                            .sublist(
                                                currentEpisodePage * 20,
                                                snapshot.data!.episodes.length <
                                                        (currentEpisodePage +
                                                                1) *
                                                            20
                                                    ? snapshot
                                                        .data!.episodes.length
                                                    : (currentEpisodePage + 1) *
                                                        20)
                                            .map(
                                              (episodeData) => BlocBuilder(
                                                  bloc: BlocProvider.of<
                                                          WatchHistoryCubit>(
                                                      context),
                                                  builder: (context, state) {
                                                    var newEpNum = episodeData
                                                            .episodeNumber
                                                            .toLowerCase()
                                                            .contains("-")
                                                        ? double.parse(episodeData
                                                                .episodeNumber
                                                                .split("-")[1])
                                                            .round()
                                                        : double.parse(episodeData
                                                                .episodeNumber)
                                                            .round();
                                                    if (!snapshot
                                                        .data!
                                                        .episodes[0]
                                                        .episodeNumber
                                                        .toLowerCase()
                                                        .contains("movie")) {
                                                      if (double.parse(snapshot
                                                                      .data!
                                                                      .episodes[
                                                                          0]
                                                                      .episodeNumber)
                                                                  .round() -
                                                              1 !=
                                                          -1) {
                                                        currentEpisodeIndex =
                                                            episodeData
                                                                    .episodeNumber
                                                                    .toLowerCase()
                                                                    .contains(
                                                                        "movie")
                                                                ? 0
                                                                : newEpNum - 1;
                                                      } else {
                                                        currentEpisodeIndex =
                                                            episodeData
                                                                    .episodeNumber
                                                                    .toLowerCase()
                                                                    .contains(
                                                                        "movie")
                                                                ? 0
                                                                : newEpNum;
                                                      }
                                                    } else {
                                                      currentEpisodeIndex =
                                                          episodeData
                                                                  .episodeNumber
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      "movie")
                                                              ? 0
                                                              : newEpNum;
                                                    }
                                                    var match =
                                                        watchHistoryCubitProvider
                                                            .matchWatchHistoryEpisode(
                                                      BaseEpisodeModel(
                                                        episodeId: episodeData
                                                            .episodeId,
                                                        episodeName: episodeData
                                                                .episodeName ??
                                                            "",
                                                        episodeNumber:
                                                            episodeData
                                                                .episodeNumber,
                                                        secondsWatched: episodeData
                                                                .secondsWatched ??
                                                            0,
                                                        episodeDuration: episodeData
                                                                .episodeDuration ??
                                                            0,
                                                        progress: 0,
                                                      ),
                                                      args.item,
                                                    );
                                                    Episode? activeTMDBEpisode;
                                                    try {
                                                      activeTMDBEpisode = episodeData
                                                                  .relativeEpisodeNumber !=
                                                              null
                                                          ? tmdbSeasonData.firstWhere((element) =>
                                                              element.episodeNumber ==
                                                                  episodeData
                                                                      .relativeEpisodeNumber &&
                                                              element.seasonNumber ==
                                                                  episodeData
                                                                      .seasonNumber)
                                                          : tmdbSeasonData.firstWhere(
                                                              (element) =>
                                                                  element
                                                                      .episodeNumber ==
                                                                  currentEpisodeIndex +
                                                                      1);
                                                    } catch (e) {
                                                      activeTMDBEpisode = null;
                                                    }
                                                    if (activeTMDBEpisode ==
                                                        null) {
                                                      try {
                                                        activeTMDBEpisode = tmdbSeasonData
                                                            .firstWhere((element) =>
                                                                element
                                                                    .episodeNumber ==
                                                                currentEpisodeIndex +
                                                                    1);
                                                      } catch (e) {
                                                        activeTMDBEpisode =
                                                            null;
                                                      }
                                                    }
                                                    AnimeFillerListData?
                                                        fillerData;
                                                    try {
                                                      fillerData = fillerEpisodes?[
                                                          currentEpisodeIndex];
                                                    } catch (e) {
                                                      fillerData = null;
                                                    }
                                                    Node? kitsuEpisodeData;
                                                    try {
                                                      kitsuEpisodeData =
                                                          kitsuEpisodes?.nodes[
                                                              currentEpisodeIndex];
                                                    } catch (e) {
                                                      kitsuEpisodeData = null;
                                                    }
                                                    return match != null
                                                        ? EpisodeBox(
                                                            episodeData:
                                                                episodeData,
                                                            args: args,
                                                            progress:
                                                                match.progress,
                                                            secondsWatched: match
                                                                .secondsWatched,
                                                            episodeCount:
                                                                EpisodeCount(
                                                              episodeCount: snapshot
                                                                      .data
                                                                      ?.episodes
                                                                      .length ??
                                                                  0,
                                                              altEpisodeCount: snapshot
                                                                      .data
                                                                      ?.altEpisodes
                                                                      ?.length ??
                                                                  0,
                                                            ),
                                                            malId: malId,
                                                            episodes: snapshot
                                                                .data!.episodes,
                                                            fillerStatus:
                                                                fillerData,
                                                            tmdbImageBaseUrl:
                                                                tmdbService
                                                                    .imageBaseUrl,
                                                            kitsuEpisodeData:
                                                                kitsuEpisodeData,
                                                            tmdbEpisodeData:
                                                                activeTMDBEpisode,
                                                          )
                                                        : EpisodeBox(
                                                            episodeData:
                                                                episodeData,
                                                            args: args,
                                                            progress: 0,
                                                            secondsWatched:
                                                                null,
                                                            episodeCount:
                                                                EpisodeCount(
                                                              episodeCount: snapshot
                                                                      .data
                                                                      ?.episodes
                                                                      .length ??
                                                                  0,
                                                              altEpisodeCount: snapshot
                                                                      .data
                                                                      ?.altEpisodes
                                                                      ?.length ??
                                                                  0,
                                                            ),
                                                            malId: malId,
                                                            episodes: snapshot
                                                                .data!.episodes,
                                                            fillerStatus:
                                                                fillerData,
                                                            tmdbImageBaseUrl:
                                                                tmdbService
                                                                    .imageBaseUrl,
                                                            kitsuEpisodeData:
                                                                kitsuEpisodeData,
                                                            tmdbEpisodeData:
                                                                activeTMDBEpisode,
                                                          );
                                                  }),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 70),
                    ],
                  ),
                );
              } else {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Skeleton(
                      isLoading: true,
                      skeleton: SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.4,
                        shape: BoxShape.rectangle,
                      )),
                      child: Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 15,
                        bottom: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 12,
                                child: Skeleton(
                                  isLoading: true,
                                  skeleton: const SkeletonAvatar(
                                      style: SkeletonAvatarStyle(
                                    width: double.infinity,
                                    height: 35,
                                    shape: BoxShape.rectangle,
                                  )),
                                  child: Container(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: Skeleton(
                                  isLoading: true,
                                  skeleton: const SkeletonAvatar(
                                      style: SkeletonAvatarStyle(
                                    shape: BoxShape.circle,
                                    width: 25,
                                    height: 35,
                                  )),
                                  child: Container(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.65,
                            child: Skeleton(
                              isLoading: true,
                              skeleton: const SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  width: double.infinity,
                                  height: 30,
                                  shape: BoxShape.rectangle,
                                ),
                              ),
                              child: Container(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Skeleton(
                            isLoading: true,
                            skeleton: SkeletonParagraph(
                              style: const SkeletonParagraphStyle(
                                lines: 4,
                                spacing: 5,
                                lineStyle: SkeletonLineStyle(
                                  width: double.infinity,
                                  height: 16,
                                  padding: EdgeInsets.only(left: 0, right: 0),
                                ),
                              ),
                            ),
                            child: Container(),
                          ),
                          const SizedBox(height: 10),
                          Skeleton(
                            isLoading: true,
                            skeleton: const SkeletonAvatar(
                              style: SkeletonAvatarStyle(
                                width: 75,
                                height: 25,
                                shape: BoxShape.rectangle,
                              ),
                            ),
                            child: Container(),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(
                              5,
                              (index) => Skeleton(
                                isLoading: true,
                                skeleton: const SkeletonAvatar(
                                  style: SkeletonAvatarStyle(
                                    width: 70,
                                    height: 25,
                                    shape: BoxShape.rectangle,
                                  ),
                                ),
                                child: Container(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Skeleton(
                            isLoading: true,
                            skeleton: const SkeletonAvatar(
                              style: SkeletonAvatarStyle(
                                width: double.infinity,
                                height: 40,
                                shape: BoxShape.rectangle,
                              ),
                            ),
                            child: Container(),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Skeleton(
                                    isLoading: true,
                                    skeleton: const SkeletonAvatar(
                                      style: SkeletonAvatarStyle(
                                        width: 75,
                                        height: 30,
                                        shape: BoxShape.rectangle,
                                      ),
                                    ),
                                    child: Container(),
                                  ),
                                  const SizedBox(width: 10),
                                  Skeleton(
                                    isLoading: true,
                                    skeleton: const SkeletonAvatar(
                                      style: SkeletonAvatarStyle(
                                        width: 85,
                                        height: 30,
                                        shape: BoxShape.rectangle,
                                      ),
                                    ),
                                    child: Container(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Column(
                                children: List.generate(
                                  10,
                                  (index) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Skeleton(
                                      isLoading: true,
                                      skeleton: const SkeletonAvatar(
                                        style: SkeletonAvatarStyle(
                                          width: double.infinity,
                                          height: 20,
                                          shape: BoxShape.rectangle,
                                        ),
                                      ),
                                      child: Container(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 70),
                  ],
                );
              }
            },
          ),
          floatingActionButton: WatchStatusButton(
            item: args.item,
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class FavoritesButton extends StatelessWidget {
  final BaseItemModel item;

  const FavoritesButton({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, List<BaseItemModel>>(
      builder: (context, state) {
        if (context.read<FavoritesCubit>().matchFavorite(item)) {
          return IconButton(
            onPressed: () {
              context.read<FavoritesCubit>().removeFavorite(item);
            },
            icon: Icon(Icons.bookmark_outlined,
                color: Theme.of(context).colorScheme.primary),
          );
        } else {
          return IconButton(
            onPressed: () {
              context.read<FavoritesCubit>().addFavorite(item);
            },
            icon: const Icon(Icons.bookmark_border),
          );
        }
      },
    );
  }
}

class ShrinkWrappingTabBarView extends StatelessWidget {
  const ShrinkWrappingTabBarView({
    super.key,
    required this.tabController,
    required this.children,
  });

  final TabController tabController;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.0,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutExpo,
            child: SizedBox(
              width: double.infinity, // always fill horizontally
              child: CurrentTabControllerWidget(
                tabController: tabController,
                children: children,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: TabBarView(
            controller: tabController,
            children: children
                .map(
                  (e) => OverflowBox(
                    alignment: Alignment.topCenter,
                    // avoid shrinkwrapping to animated height
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: e,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class CurrentTabControllerWidget extends StatefulWidget {
  const CurrentTabControllerWidget({
    super.key,
    required this.tabController,
    required this.children,
  });

  final TabController tabController;
  final List<Widget> children;

  @override
  State<CurrentTabControllerWidget> createState() =>
      _CurrentTabControllerWidgetState();
}

class _CurrentTabControllerWidgetState
    extends State<CurrentTabControllerWidget> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_tabUpdated);
    widget.tabController.animation?.addListener(_tabUpdated);
  }

  @override
  void dispose() {
    super.dispose();
    widget.tabController.removeListener(_tabUpdated);
    widget.tabController.animation?.removeListener(_tabUpdated);
  }

  @override
  void didUpdateWidget(covariant CurrentTabControllerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabController != widget.tabController) {
      oldWidget.tabController.removeListener(_tabUpdated);
      widget.tabController.addListener(_tabUpdated);
      oldWidget.tabController.animation?.removeListener(_tabUpdated);
      widget.tabController.animation?.addListener(_tabUpdated);
      setState(() {});
    }
  }

  void _tabUpdated() => setState(() {});

  @override
  Widget build(BuildContext context) =>
      widget.children[widget.tabController.animation?.value.round() ??
          widget.tabController.index];
  // widget.children[widget.tabController.index];
}
