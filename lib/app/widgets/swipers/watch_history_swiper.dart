import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mana_debug/app/bloc/cubit/cubits.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';
import 'package:skeletons/skeletons.dart';

import '../../data/services/source_service.dart';

class WatchHistorySwiper extends StatefulWidget {
  const WatchHistorySwiper({
    Key? key,
  }) : super(key: key);

  @override
  State<WatchHistorySwiper> createState() => _WatchHistorySwiperState();
}

class _WatchHistorySwiperState extends State<WatchHistorySwiper>
    with AutomaticKeepAliveClientMixin {
  late WatchHistoryCubit _watchHistoryCubitProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watchHistoryCubitProvider = BlocProvider.of<WatchHistoryCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var watchHistorySorted =
        _watchHistoryCubitProvider.getWatchHistorySortedByDate();
    return BlocBuilder(
      bloc: BlocProvider.of<WatchHistoryCubit>(context),
      builder: (context, List<BaseItemModel> watchHistory) {
        if (watchHistory.isNotEmpty) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Continue Watching',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 230,
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: context
                            .read<WatchHistoryCubit>()
                            .getWatchHistorySortedByDate()
                            .map(
                              (e) => GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/info',
                                    arguments: InfoPageArgumentsModel(
                                      item: e,
                                      source: SourceService()
                                          .detectSource(e.source.id),
                                      playImmediately: true,
                                    ),
                                  );
                                },
                                onLongPressStart: (details) {
                                  Feedback.forLongPress(context);
                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                      details.globalPosition.dx,
                                      details.globalPosition.dy,
                                      details.globalPosition.dx,
                                      details.globalPosition.dy,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    items: [
                                      PopupMenuItem(
                                        child: TextButton(
                                          onPressed: () {
                                            AlertDialog alert = AlertDialog(
                                              title: const Text("Delete"),
                                              content: Text(
                                                  "Are you sure you want to delete ${e.title} from your history?"),
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              actions: [
                                                TextButton(
                                                  child: Text(
                                                    "Cancel",
                                                    style: GoogleFonts.roboto(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(
                                                    "Delete",
                                                    style: GoogleFonts.roboto(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    context
                                                        .read<
                                                            WatchHistoryCubit>()
                                                        .removeItemFromWatchHistory(
                                                            e);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return alert;
                                              },
                                            );
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                                child: SizedBox(
                                  width: 125,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 3 / 4.25,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  e.imageUrl,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      SizedBox(
                                                    child: Skeleton(
                                                      isLoading: true,
                                                      skeleton:
                                                          const SkeletonAvatar(
                                                        style:
                                                            SkeletonAvatarStyle(
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
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
                                              e.watchStatus?.lastWatchedEpisode != null &&
                                                      e
                                                              .watchStatus
                                                              ?.lastWatchedEpisode
                                                              ?.progress !=
                                                          null &&
                                                      e
                                                              .watchStatus
                                                              ?.lastWatchedEpisode
                                                              ?.progress !=
                                                          0 &&
                                                      e
                                                              .watchStatus
                                                              ?.lastWatchedEpisode
                                                              ?.secondsWatched !=
                                                          null &&
                                                      e
                                                              .watchStatus
                                                              ?.lastWatchedEpisode
                                                              ?.secondsWatched !=
                                                          0
                                                  ? Stack(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            gradient:
                                                                LinearGradient(
                                                              begin: Alignment
                                                                  .center,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Colors
                                                                    .transparent,
                                                                Colors.black
                                                                    .withOpacity(
                                                                        0.65),
                                                                Colors.black,
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  "${watchStatusToString(e.watchStatus?.status ?? WatchStatus.notWatched)}:\n${e.watchStatus?.lastWatchedEpisode?.episodeName == "" ? "Episode ${e.watchStatus?.lastWatchedEpisode?.episodeNumber ?? "not watched"}" : e.watchStatus?.lastWatchedEpisode?.episodeName ?? "not watched"}",
                                                                  style:
                                                                      GoogleFonts
                                                                          .roboto(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        7.5),
                                                                LinearProgressIndicator(
                                                                  value: e
                                                                          .watchStatus
                                                                          ?.lastWatchedEpisode
                                                                          ?.progress ??
                                                                      0,
                                                                  backgroundColor:
                                                                      Colors.grey[
                                                                          700],
                                                                  valueColor: AlwaysStoppedAnimation<
                                                                      Color>(Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                      .withAlpha(
                                                                          175)),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : const SizedBox(),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                    width: 55,
                                                    height: 55,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1000),
                                                      border: Border.all(
                                                        color:
                                                            Colors.grey[300]!,
                                                        width: 2.5,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.grey[300],
                                                        size: 40,
                                                      ),
                                                    )),
                                              ),
                                              SizedBox(
                                                height: double.infinity,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(),
                                                      Column(
                                                        children: e.languages
                                                            .map(
                                                                (e) =>
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                              .only(
                                                                          bottom:
                                                                              5),
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              5,
                                                                          vertical:
                                                                              2),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        e.toString().replaceFirst("LanguageType.", "")[0].toUpperCase() +
                                                                            e.toString().replaceFirst("LanguageType.", "").substring(1),
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Colors.white,
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
                                      const SizedBox(height: 7.5),
                                      Center(
                                        child: SizedBox(
                                          width: 115,
                                          child: Text(
                                            e.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
