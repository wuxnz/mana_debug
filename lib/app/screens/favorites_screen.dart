import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mana_debug/app/bloc/cubit/cubits.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';
import 'package:mana_debug/app/data/services/source_service.dart';
import 'package:skeletons/skeletons.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late WatchHistoryCubit watchHistoryCubitProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    watchHistoryCubitProvider = BlocProvider.of<WatchHistoryCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            labelStyle: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Favorites'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BlocBuilder(
              bloc: BlocProvider.of<FavoritesCubit>(context),
              builder: (context, List<BaseItemModel> favorites) {
                return BlocBuilder(
                  bloc: BlocProvider.of<WatchHistoryCubit>(context),
                  builder: (context, List<BaseItemModel> watchHistory) {
                    if (favorites.isNotEmpty) {
                      return NotificationListener<
                          OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll.disallowIndicator();
                          return true;
                        },
                        child: ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(10.0),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            var watchHistoryItem = watchHistoryCubitProvider
                                .getWatchHistoryItem(favorites[index]);
                            return _FavoritedItem(
                              item: favorites[index],
                              watchHistoryItem: watchHistoryItem,
                            );
                          },
                        ),
                      );
                    }
                    return const Center(child: Text('No favorites'));
                  },
                );
              },
            ),
            BlocBuilder(
              bloc: BlocProvider.of<WatchHistoryCubit>(context),
              builder: (context, List<BaseItemModel> watchHistory) {
                if (watchHistory.isEmpty) {
                  return const Center(child: Text('No history'));
                }
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: ListView(
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ...watchHistoryCubitProvider
                                .getWatchHistorySortedByDate()
                                .map(
                                  (e) => SizedBox(
                                    width: MediaQuery.of(context).size.width >
                                            800
                                        ? MediaQuery.of(context).size.width /
                                                7 -
                                            12.5
                                        : MediaQuery.of(context).size.width /
                                                3 -
                                            15,
                                    child: _WatchHistoryPageItem(
                                      item: e,
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class _FavoritedItem extends StatelessWidget {
  final BaseItemModel item;
  final BaseItemModel? watchHistoryItem;

  const _FavoritedItem({
    Key? key,
    required this.item,
    this.watchHistoryItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/info',
          arguments: InfoPageArgumentsModel(
            item: item,
            source: SourceService().detectSource(item.source.id),
            playImmediately: false,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: MediaQuery.of(context).size.height * 0.2,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surface.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Opacity(
                  opacity: 0.6,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Image.network(
                      item.imageUrl,
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
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.height * 0.2 * 0.675,
                    child: AspectRatio(
                      aspectRatio: 3 / 4.25,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Image.network(
                              item.imageUrl,
                              errorBuilder: (context, error, stackTrace) =>
                                  SizedBox(
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
                            Positioned(
                              top: 5,
                              right: 10,
                              child: Column(
                                children: item.languages
                                    .map((e) => Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 5),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            e
                                                    .toString()
                                                    .replaceFirst(
                                                        "LanguageType.", "")[0]
                                                    .toUpperCase() +
                                                e
                                                    .toString()
                                                    .replaceFirst(
                                                        "LanguageType.", "")
                                                    .substring(1),
                                            style: GoogleFonts.roboto(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3),
                                        width: 2,
                                      ),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      item.source.sourceName,
                                      style: GoogleFonts.roboto(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface
                                          .withOpacity(0.3),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withOpacity(0.3),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      watchStatusToString(watchHistoryItem
                                              ?.watchStatus?.status ??
                                          WatchStatus.notWatched),
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
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LinearProgressIndicator(
                                value: item.watchStatus != null &&
                                        item.watchStatus?.episodeCount
                                                ?.episodeCount !=
                                            0 &&
                                        watchHistoryItem != null
                                    ? (watchHistoryItem?.watchStatus
                                                ?.episodesWatched ??
                                            0) /
                                        (item.watchStatus?.episodeCount
                                                ?.episodeCount ??
                                            1)
                                    : 0,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.remove_red_eye,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        item.watchStatus != null &&
                                                item.watchStatus
                                                        ?.episodeCount !=
                                                    null &&
                                                watchHistoryItem != null
                                            ? '${((watchHistoryItem?.watchStatus?.episodesWatched ?? 0) / (item.watchStatus?.episodeCount?.episodeCount ?? 1) * 100).toStringAsFixed(0)}%'
                                            : '0%',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    item.watchStatus != null
                                        ? '${watchHistoryItem?.watchStatus?.episodesWatched ?? 0}/${item.watchStatus?.episodeCount?.episodeCount ?? 0}'
                                        : '0/0',
                                    style: GoogleFonts.roboto(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      AlertDialog alert = AlertDialog(
                        title: const Text("Delete"),
                        content: Text(
                            "Are you sure you want to delete ${item.title} from your favorites?"),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        actions: [
                          TextButton(
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.roboto(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Delete",
                              style: GoogleFonts.roboto(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              context
                                  .read<FavoritesCubit>()
                                  .removeFavorite(item);
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchHistoryPageItem extends StatefulWidget {
  final BaseItemModel item;

  const _WatchHistoryPageItem({Key? key, required this.item}) : super(key: key);

  @override
  State<_WatchHistoryPageItem> createState() => _WatchHistoryPageItemState();
}

class _WatchHistoryPageItemState extends State<_WatchHistoryPageItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/info',
          arguments: InfoPageArgumentsModel(
            item: widget.item,
            source: SourceService().detectSource(widget.item.source.id),
            playImmediately: false,
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
                        "Are you sure you want to delete ${widget.item.title} from your history?"),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    actions: [
                      TextButton(
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.roboto(
                            color: Theme.of(context).colorScheme.primary,
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
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context
                              .read<WatchHistoryCubit>()
                              .removeItemFromWatchHistory(widget.item);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4.25,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.item.imageUrl,
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
                widget.item.watchStatus?.lastWatchedEpisode != null &&
                        widget.item.watchStatus?.lastWatchedEpisode?.progress !=
                            null &&
                        widget.item.watchStatus?.lastWatchedEpisode?.progress !=
                            0 &&
                        widget.item.watchStatus?.lastWatchedEpisode
                                ?.secondsWatched !=
                            null &&
                        widget.item.watchStatus?.lastWatchedEpisode
                                ?.secondsWatched !=
                            0
                    ? Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.65),
                                  Colors.black,
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Text(
                                      "${watchStatusToString(widget.item.watchStatus?.status ?? WatchStatus.notWatched)}:\n${widget.item.watchStatus?.lastWatchedEpisode?.episodeName == "" ? "Episode ${widget.item.watchStatus?.lastWatchedEpisode?.episodeNumber ?? "not watched"}" : widget.item.watchStatus?.lastWatchedEpisode?.episodeName ?? "not watched"}",
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 7.5),
                                  LinearProgressIndicator(
                                    value: widget.item.watchStatus
                                            ?.lastWatchedEpisode?.progress ??
                                        0,
                                    backgroundColor: Colors.grey[700],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withAlpha(175)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
                SizedBox(
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(),
                        Column(
                          children: widget.item.languages
                              .map((e) => Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      e
                                              .toString()
                                              .replaceFirst(
                                                  "LanguageType.", "")[0]
                                              .toUpperCase() +
                                          e
                                              .toString()
                                              .replaceFirst("LanguageType.", "")
                                              .substring(1),
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
          const SizedBox(height: 7.5),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: Text(
                widget.item.title,
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
    );
  }
}
