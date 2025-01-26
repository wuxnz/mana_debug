import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mana_debug/app/data/models/services/external_helper_services_models/ani_skip.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';
import 'package:mana_debug/app/screens/player_screen.dart';
import 'package:mana_debug/app/widgets/auto_hide_widget/auto_hide_widget.dart';
import 'package:media_kit/media_kit.dart';
import 'package:video_cast/chrome_cast_media_type.dart';
import 'package:video_cast/video_cast.dart';

import '../../bloc/cubit/watch_history_cubit/watch_history_cubit.dart';

class BottomControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const BottomControlButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          const SizedBox(width: 12.5),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class PlayerControls extends StatefulWidget {
  final PlayerControlsArgumentsModel arguments;

  const PlayerControls({Key? key, required this.arguments}) : super(key: key);

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  late WatchHistoryCubit _watchHistoryCubitProvider;
  bool isLoading = true;
  bool _sourceListVisible = false;
  bool _controlsVisible = true;
  bool _isPlaying = true;
  Duration _progress = Duration.zero;
  Duration _buffered = Duration.zero;
  bool _loadingNewSource = false;
  bool _shownResumeDialog = false;
  int? _leftOffSeconds;
  bool _subtitleListVisible = false;
  late int _currentEpisodeIndex;
  ChromeCastController? _chromeCastController;
  int previousSourceIndex = 0;
  int previousSubtitleIndex = 0;
  bool controlsLocked = false;
  int numberOfSources = 0;

  void _onSkipButtonPressed(AniSkipSkipData skipData) {
    widget.arguments.player.seek(
      Duration(seconds: skipData.endTime.ceil()),
    );
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
    _watchHistoryCubitProvider = BlocProvider.of<WatchHistoryCubit>(context);
    _currentEpisodeIndex = widget.arguments.playerScreenArguments.episodes
            .indexWhere((element) =>
                element.episodeId ==
                widget.arguments.playerScreenArguments.episodeData.episodeId) +
        currentEpisodeOffset;
  }

  @override
  void initState() {
    super.initState();
    numberOfSources = widget.arguments.videoSources.length;
    widget.arguments.player.play();
    widget.arguments.player.stream.playing.listen((event) {
      setState(() {
        _isPlaying = event;
      });
    });
    widget.arguments.player.stream.position.listen((event) {
      setState(() {
        _progress = event;
      });
      if ((_progress.inSeconds > 0 &&
              numberOfSources != widget.arguments.videoSources.length) ||
          (_progress.inSeconds > 0 && _loadingNewSource == true)) {
        setState(() {
          _loadingNewSource = false;
          widget.arguments.player.seek(Duration(seconds: _leftOffSeconds ?? 0));
          numberOfSources = widget.arguments.videoSources.length;
        });
      }
      // if (_shownResumeDialog == false) {
      // if (widget.arguments.secondsWatched != null &&
      //     widget.arguments.secondsWatched! > 0) {
      if (currentEpisodeOffset == 0 && _shownResumeDialog == false) {
        widget.arguments.player.seek(Duration(
            seconds: widget.arguments.secondsWatched ?? _progress.inSeconds));
        setState(() {
          _shownResumeDialog = true;
        });
      }
      // }

      setState(() {
        _shownResumeDialog = true;
      });
    });
    widget.arguments.player.stream.buffer.listen((event) {
      setState(() {
        _buffered = event;
      });
    });
  }

  @override
  void dispose() {
    var secondsWatched = widget.arguments.player.state.position.inSeconds;
    var episodeDuration = widget.arguments.player.state.duration.inSeconds;
    var progress = secondsWatched / episodeDuration;
    var episodeId = widget.arguments.playerScreenArguments
        .episodes[_currentEpisodeIndex].episodeId;
    var episodeName = widget.arguments.playerScreenArguments
            .episodes[_currentEpisodeIndex].episodeName ??
        "Episode ${_currentEpisodeIndex + 1}";
    var episodeNumber = widget.arguments.playerScreenArguments
        .episodes[_currentEpisodeIndex].episodeNumber;
    debugPrint(
        "-------------------> ${widget.arguments.playerScreenArguments.item.id}");
    if (_watchHistoryCubitProvider
        .matchWatchHistory(widget.arguments.playerScreenArguments.item)) {
      _watchHistoryCubitProvider.updateWatchHistoryItemEpisodeList(
        BaseEpisodeModel(
            episodeId: episodeId,
            episodeName: episodeName,
            episodeNumber: episodeNumber,
            secondsWatched: secondsWatched,
            episodeDuration: episodeDuration,
            progress: progress),
        _watchHistoryCubitProvider.getWatchHistoryItem(
                widget.arguments.playerScreenArguments.item) ??
            widget.arguments.playerScreenArguments.item,
      );
    } else {
      _watchHistoryCubitProvider.addToWatchHistory(
        BaseItemModel(
          episodesWatched: EpisodesWatchedModel(
            episodesWatched: [
              BaseEpisodeModel(
                  episodeId: episodeId,
                  episodeName: episodeName,
                  episodeNumber: episodeNumber,
                  secondsWatched: secondsWatched,
                  episodeDuration: episodeDuration,
                  progress: progress),
            ],
          ),
          source: widget.arguments.playerScreenArguments.item.source,
          id: widget.arguments.playerScreenArguments.item.id,
          title: widget.arguments.playerScreenArguments.item.title,
          imageUrl: widget.arguments.playerScreenArguments.item.imageUrl,
          languages: widget.arguments.playerScreenArguments.item.languages,
          episodeCount:
              widget.arguments.playerScreenArguments.item.episodeCount,
          watchStatus: WatchStatusModel(
              status: WatchStatus.watching,
              episodeCount:
                  widget.arguments.playerScreenArguments.item.episodeCount,
              episodesWatched: 1,
              altEpisodesWatched: 0,
              lastWatchedDate: DateTime.now(),
              lastWatchedEpisode: BaseEpisodeModel(
                episodeId: episodeId,
                episodeName: episodeName,
                episodeNumber: episodeNumber,
                secondsWatched: secondsWatched,
                episodeDuration: episodeDuration,
                progress: progress,
              )),
        ),
      );
    }
    setSelectedVideoSourceIndex(0);
    setSelectedSubtitleIndex(0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controlsLocked
        ? Positioned(
            bottom: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.width * 0.05,
            child: IconButton(
              icon: const Icon(Icons.lock),
              color: Colors.white,
              onPressed: () {
                setLastInteraction(DateTime.now());
                setState(() {
                  controlsLocked = false;
                });
              },
            ),
          )
        : _sourceListVisible
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black,
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            "Video",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Container(
                            color: Theme.of(context).dividerColor,
                            height: 2.5,
                            width: MediaQuery.of(context).size.width * 0.45,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.arguments.videoSources.length,
                              itemBuilder: (context, index) {
                                return Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    title: Text(
                                      widget.arguments.videoSources[index]
                                          .sourceUrlDescription,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    trailing: index == selectedVideoSourceIndex
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                            size: 30.0,
                                          )
                                        : const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                    onTap: () async {
                                      setLastInteraction(DateTime.now());
                                      previousSourceIndex =
                                          selectedVideoSourceIndex;
                                      setSelectedVideoSourceIndex(index);
                                      setState(() {});
                                      // setState(() {
                                      //   _sourceListVisible = false;
                                      // });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            "Subtitles",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Container(
                            color: Theme.of(context).dividerColor,
                            height: 2.5,
                            width: MediaQuery.of(context).size.width * 0.45,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.arguments.subtitles.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    widget.arguments.subtitles[index]
                                        .subtitleName,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  trailing: index == selectedSubtitleIndex
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                          size: 30.0,
                                        )
                                      : null,
                                  onTap: () {
                                    setLastInteraction(DateTime.now());
                                    previousSubtitleIndex =
                                        selectedSubtitleIndex;
                                    setSelectedSubtitleIndex(index);
                                    setState(() {});
                                    // setState(() {
                                    //   _subtitleListVisible = false;
                                    // });
                                  },
                                );
                              },
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  setLastInteraction(DateTime.now());
                                  if (previousSourceIndex !=
                                      selectedVideoSourceIndex) {
                                    setState(() {
                                      _loadingNewSource = true;
                                      _leftOffSeconds = widget.arguments.player
                                          .state.position.inSeconds;
                                    });
                                    await widget.arguments.player.open(Media(
                                      widget
                                          .arguments
                                          .videoSources[
                                              selectedVideoSourceIndex]
                                          .videoUrl,
                                      httpHeaders: widget
                                          .arguments
                                          .videoSources[
                                              selectedVideoSourceIndex]
                                          .headers,
                                    ));
                                    previousSourceIndex =
                                        selectedVideoSourceIndex;
                                  }
                                  if (previousSubtitleIndex !=
                                      selectedSubtitleIndex) {
                                    widget.arguments.changeSubtitles(widget
                                        .arguments
                                        .subtitles[selectedSubtitleIndex]);
                                    previousSubtitleIndex =
                                        selectedSubtitleIndex;
                                  }
                                  setState(() {
                                    _sourceListVisible = false;
                                  });
                                },
                                icon: const Icon(Icons.check),
                                label: const Text("Confirm"),
                              ),
                              const SizedBox(width: 12.0),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setLastInteraction(DateTime.now());
                                  setSelectedVideoSourceIndex(
                                      previousSourceIndex);
                                  setSelectedSubtitleIndex(
                                      previousSubtitleIndex);
                                  setState(() {
                                    _sourceListVisible = false;
                                  });
                                },
                                icon: const Icon(Icons.close),
                                label: const Text("Cancel"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            // : GestureDetector(
            //     onTap: () {
            //       setState(() {
            //         _controlsVisible = !_controlsVisible;
            //       });
            //     },
            : Stack(
                children: [
                  AutoHideWidget(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setLastInteraction(DateTime.now());
                              setState(() {
                                if (_sourceListVisible == true) {
                                  _sourceListVisible = false;
                                } else if (_subtitleListVisible == true) {
                                  _subtitleListVisible = false;
                                } else {
                                  _controlsVisible = !_controlsVisible;
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _controlsVisible
                                    ? Colors.black.withOpacity(0.5)
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: _controlsVisible,
                            child: AnimatedOpacity(
                              opacity: _controlsVisible ? 1.0 : 0.0,
                              duration: const Duration(seconds: 1),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setLastInteraction(DateTime.now());
                                          Navigator.of(context).pop();
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                        ),
                                        iconSize: 25,
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            widget
                                                .arguments
                                                .playerScreenArguments
                                                .item
                                                .title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                          Text(
                                            widget
                                                    .arguments
                                                    .playerScreenArguments
                                                    .episodes[
                                                        _currentEpisodeIndex]
                                                    .episodeName ??
                                                'Episode ${widget.arguments.playerScreenArguments.episodes[_currentEpisodeIndex].episodeNumber}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                        ],
                                      ),
                                      // IconButton(
                                      //   onPressed: () {},
                                      // setLastInteraction(DateTime.now());
                                      //   icon: const Icon(
                                      //     Icons.more_vert,
                                      //     color: Colors.white,
                                      //   ),
                                      //   iconSize: 25,
                                      // ),
                                      Platform.isIOS ||
                                              Platform.isAndroid &&
                                                  widget.arguments.videoSources
                                                          .indexWhere(
                                                              (element) =>
                                                                  element
                                                                      .headers ==
                                                                  null) !=
                                                      -1
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: ChromeCastButton(
                                                onButtonCreated: (controller) {
                                                  setState(() =>
                                                      _chromeCastController =
                                                          controller);
                                                  _chromeCastController
                                                      ?.addSessionListener();
                                                },
                                                onSessionStarted: () => {
                                                  _chromeCastController!
                                                      .loadMedia(
                                                    url: widget.arguments
                                                                .videoSources
                                                                .indexWhere(
                                                                    (element) =>
                                                                        element
                                                                            .headers ==
                                                                        null) ==
                                                            -1
                                                        ? widget
                                                            .arguments
                                                            .videoSources[0]
                                                            .videoUrl
                                                        : widget
                                                            .arguments
                                                            .videoSources[widget
                                                                .arguments
                                                                .videoSources
                                                                .indexWhere(
                                                                    (element) =>
                                                                        element
                                                                            .headers ==
                                                                        null)]
                                                            .videoUrl,
                                                    // title: widget.arguments
                                                    //     .playerScreenArguments.item.title,
                                                    title:
                                                        "${widget.arguments.playerScreenArguments.item.title} ${widget.arguments.playerScreenArguments.episodes[_currentEpisodeIndex].episodeName ?? 'Episode ${widget.arguments.playerScreenArguments.episodes[_currentEpisodeIndex].episodeNumber}'}",
                                                    type: ChromeCastMediaType
                                                        .show,
                                                  )
                                                },
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Icon(
                                                Icons.cast,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        // _subtitleListVisible
                                        //     ? Expanded(
                                        //         child: Container(
                                        //         decoration: BoxDecoration(
                                        //           color: Colors.black.withOpacity(0.275),
                                        //           borderRadius: BorderRadius.circular(10),
                                        //         ),
                                        //         margin: const EdgeInsets.all(10),
                                        //         child: ListView.builder(
                                        //           itemCount:
                                        //               widget.arguments.subtitles.length,
                                        //           itemBuilder: (context, index) {
                                        //             return ListTile(
                                        //               title: Text(
                                        //                 widget.arguments.subtitles[index]
                                        //                     .subtitleName,
                                        //                 style: Theme.of(context)
                                        //                     .textTheme
                                        //                     .titleMedium,
                                        //               ),
                                        //               onTap: () {
                                        //                 widget.arguments.changeSubtitles(
                                        //                     widget
                                        //                         .arguments.subtitles[index]);
                                        //                 setState(() {
                                        //                   _subtitleListVisible = false;
                                        //                 });
                                        //               },
                                        //             );
                                        //           },
                                        //         ),
                                        //       ))
                                        //     : const SizedBox.shrink(),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setLastInteraction(
                                                      DateTime.now());
                                                  if (widget.arguments.player
                                                          .state.position <
                                                      const Duration(
                                                          seconds: 10)) {
                                                    widget.arguments.player
                                                        .seek(
                                                      const Duration(
                                                          seconds: 0),
                                                    );
                                                  } else {
                                                    widget.arguments.player
                                                        .seek(
                                                      widget.arguments.player
                                                              .state.position -
                                                          const Duration(
                                                              seconds: 10),
                                                    );
                                                  }
                                                },
                                                icon: Image.asset(
                                                  "assets/images/replay-10.png",
                                                  width: 40,
                                                  height: 40,
                                                  scale: 1.5,
                                                ),
                                                color: Colors.white,
                                              ),
                                              // iconSize: 40,
                                              // ),
                                              _loadingNewSource ||
                                                      widget.arguments.player
                                                          .state.buffering
                                                  ? CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    )
                                                  : IconButton(
                                                      onPressed: () {
                                                        setLastInteraction(
                                                            DateTime.now());
                                                        widget.arguments.player
                                                            .playOrPause();
                                                        setState(() {
                                                          _isPlaying =
                                                              !_isPlaying;
                                                        });
                                                      },
                                                      icon: Icon(
                                                        _isPlaying
                                                            ? Icons.pause
                                                            : Icons.play_arrow,
                                                        color: Colors.white,
                                                      ),
                                                      iconSize: 60,
                                                    ),
                                              IconButton(
                                                onPressed: () {
                                                  setLastInteraction(
                                                      DateTime.now());
                                                  if (widget.arguments.player
                                                              .state.position +
                                                          const Duration(
                                                              seconds: 10) <
                                                      widget.arguments.player
                                                          .state.duration) {
                                                    widget.arguments.player
                                                        .seek(
                                                      widget.arguments.player
                                                              .state.position +
                                                          const Duration(
                                                              seconds: 10),
                                                    );
                                                  } else {
                                                    widget.arguments.player
                                                        .seek(
                                                      widget.arguments.player
                                                          .state.duration,
                                                    );
                                                  }
                                                },
                                                icon: Image.asset(
                                                  "assets/images/forward-10.png",
                                                  width: 40,
                                                  height: 40,
                                                  scale: 1.5,
                                                ),
                                                iconSize: 40,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // _sourceListVisible
                                        //     ? Expanded(
                                        //         child: Container(
                                        //           decoration: BoxDecoration(
                                        //             color: Colors.black.withOpacity(0.275),
                                        //             borderRadius: BorderRadius.circular(10),
                                        //           ),
                                        //           margin: const EdgeInsets.all(10),
                                        //           child: ListView.builder(
                                        //             itemCount:
                                        //                 widget.arguments.videoSources.length,
                                        //             itemBuilder: (context, index) {
                                        //               return Material(
                                        //                 color: Colors.transparent,
                                        //                 child: ListTile(
                                        //                   title: Text(
                                        //                     widget
                                        //                         .arguments
                                        //                         .videoSources[index]
                                        //                         .sourceUrlDescription,
                                        //                     style: Theme.of(context)
                                        //                         .textTheme
                                        //                         .bodyLarge,
                                        //                   ),
                                        //                   trailing: const Icon(
                                        //                     Icons.play_arrow,
                                        //                     color: Colors.white,
                                        //                   ),
                                        //                   onTap: () async {
                                        //                     setState(() {
                                        //                       _loadingNewSource = true;
                                        //                       _leftOffSeconds = widget
                                        //                           .arguments
                                        //                           .player
                                        //                           .state
                                        //                           .position
                                        //                           .inSeconds;
                                        //                     });
                                        //                     await widget.arguments.player
                                        //                         .open(Media(
                                        //                       widget
                                        //                           .arguments
                                        //                           .videoSources[index]
                                        //                           .videoUrl,
                                        //                       httpHeaders: widget
                                        //                           .arguments
                                        //                           .videoSources[index]
                                        //                           .headers,
                                        //                     ));
                                        //                     setState(() {
                                        //                       _sourceListVisible = false;
                                        //                     });
                                        //                   },
                                        //                 ),
                                        //               );
                                        //             },
                                        //           ),
                                        //         ),
                                        //       )
                                        //     : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.025),
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        child: ProgressBar(
                                          progress: _progress,
                                          buffered: _buffered,
                                          total: widget
                                              .arguments.player.state.duration,
                                          onSeek: (duration) {
                                            setLastInteraction(DateTime.now());
                                            widget.arguments.player
                                                .seek(duration);
                                          },
                                          baseBarColor:
                                              Colors.white.withOpacity(0.25),
                                          progressBarColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.85),
                                          bufferedBarColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.3),
                                          timeLabelLocation:
                                              TimeLabelLocation.sides,
                                          barHeight: 2.5,
                                        ),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          child:
                                              // !widget.arguments.opSkipButtonVisible &&
                                              //         !widget.arguments.edSkipButtonVisible
                                              //     ?
                                              Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _currentEpisodeIndex == 0
                                                  ? const SizedBox.shrink()
                                                  : BottomControlButton(
                                                      icon: Icons.skip_previous,
                                                      label: 'Previous',
                                                      onPressed: () {
                                                        setLastInteraction(
                                                            DateTime.now());
                                                        if (_currentEpisodeIndex ==
                                                            0) {
                                                          return;
                                                        }
                                                        widget.arguments.player
                                                            .pause();
                                                        setEpisodeOffset(
                                                            currentEpisodeOffset -
                                                                1);
                                                        debugPrint(
                                                            'Current episode offset: $currentEpisodeOffset');
                                                        debugPrint(
                                                            'Current episode index: $_currentEpisodeIndex');
                                                        widget.arguments
                                                            .changeVideoSource();
                                                      }),
                                              const SizedBox(width: 20),
                                              BottomControlButton(
                                                icon: Icons.lock_open,
                                                label: 'Lock',
                                                onPressed: () {
                                                  // setLastInteraction(
                                                  //     DateTime.now());
                                                  setState(() {
                                                    controlsLocked = true;
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 20),
                                              BottomControlButton(
                                                icon: Icons.aspect_ratio,
                                                label: 'Resize',
                                                onPressed: () {
                                                  setLastInteraction(
                                                      DateTime.now());
                                                  widget.arguments
                                                      .changeAspectRatio();
                                                },
                                              ),
                                              // const SizedBox(width: 20),
                                              // BottomControlButton(
                                              //   icon: Icons.closed_caption,
                                              //   label: 'Subtitles',
                                              //   onPressed: () {
                                              // setLastInteraction(DateTime.now());
                                              //     setState(() {
                                              //       _subtitleListVisible =
                                              //           !_subtitleListVisible;
                                              //     });
                                              //   },
                                              // ),
                                              const SizedBox(width: 20),
                                              BottomControlButton(
                                                icon: Icons.playlist_play,
                                                label: 'Source',
                                                onPressed: () {
                                                  setLastInteraction(
                                                      DateTime.now());
                                                  setState(() {
                                                    _sourceListVisible =
                                                        !_sourceListVisible;
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 20),
                                              _currentEpisodeIndex ==
                                                      widget
                                                              .arguments
                                                              .playerScreenArguments
                                                              .episodes
                                                              .length -
                                                          1
                                                  ? const SizedBox.shrink()
                                                  : BottomControlButton(
                                                      icon: Icons.skip_next,
                                                      label: 'Next',
                                                      onPressed: () {
                                                        setLastInteraction(
                                                            DateTime.now());
                                                        if (_currentEpisodeIndex ==
                                                            widget
                                                                    .arguments
                                                                    .playerScreenArguments
                                                                    .episodes
                                                                    .length -
                                                                1) {
                                                          return;
                                                        }
                                                        widget.arguments.player
                                                            .pause();
                                                        setEpisodeOffset(
                                                            currentEpisodeOffset +
                                                                1);
                                                        debugPrint(
                                                            'Current Episode Offset: $currentEpisodeOffset');
                                                        debugPrint(
                                                            'Current Episode Index: $_currentEpisodeIndex');
                                                        widget.arguments
                                                            .changeVideoSource();
                                                      }),
                                            ],
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  widget.arguments.opSkipButtonVisible
                      ? Positioned(
                          bottom: 100,
                          right: 0,
                          child: _SkipButton(
                              isOP: true,
                              onPressed: () {
                                setLastInteraction(DateTime.now());
                                _onSkipButtonPressed(
                                    widget.arguments.opSkipData!);
                              }),
                        )
                      : const SizedBox.shrink(),
                  widget.arguments.edSkipButtonVisible
                      ? Positioned(
                          bottom: 100,
                          right: 0,
                          child: _SkipButton(
                              isOP: false,
                              onPressed: () {
                                setLastInteraction(DateTime.now());
                                _onSkipButtonPressed(
                                    widget.arguments.edSkipData!);
                              }),
                        )
                      : const SizedBox.shrink(),
                ],
              );
  }
}

class _SkipButton extends StatelessWidget {
  final bool? isOP;
  final VoidCallback onPressed;

  const _SkipButton({Key? key, required this.onPressed, this.isOP})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.fast_forward),
            label: isOP! ? const Text('Skip OP') : const Text('Skip ED'),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
