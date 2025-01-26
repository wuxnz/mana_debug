import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_subtitle/flutter_subtitle.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/data/models/services/external_helper_services_models/omdb.dart';
import 'package:mana_debug/app/data/services/source_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock/wakelock.dart';
import 'package:window_manager/window_manager.dart';

import '../bloc/cubit/watch_history_cubit/watch_history_cubit.dart';
import '../core/utils/misc/misc_utils.dart';
import '../data/models/services/external_helper_services_models/ani_skip.dart';
import '../data/models/sources/base_model.dart';
import '../data/services/external_helper_services/ani_skip.dart';
import '../data/services/external_helper_services/omdb.dart';
import '../widgets/player_controls/player_controls.dart';

int currentEpisodeOffset = 0;

void setEpisodeOffset(int offset) {
  currentEpisodeOffset = offset;
}

int selectedVideoSourceIndex = 0;

void setSelectedVideoSourceIndex(int index) {
  selectedVideoSourceIndex = index;
}

int selectedSubtitleIndex = 0;

void setSelectedSubtitleIndex(int index) {
  selectedSubtitleIndex = index;
}

class PlayerScreen extends StatefulWidget {
  final PlayerScreenArgumentsModel args;

  const PlayerScreen({Key? key, required this.args}) : super(key: key);

  @override
  State<PlayerScreen> createState() => PlayerScreenState();
}

class PlayerScreenState extends State<PlayerScreen> {
  late WatchHistoryCubit _watchHistoryCubitProvider;
  Duration _currentPosition = Duration.zero;
  AniSkipSkipData? _openingSkipData;
  AniSkipSkipData? _vidOpeningSkipData;
  AniSkipSkipData? _endingSkipData;
  AniSkipSkipData? _vidEndingSkipData;
  bool _skipOpeningButtonVisible = false;
  bool _skipEndingButtonVisible = false;
  bool _skipLoadingButtonVisible = false;
  bool _skipLoadingButtonPressed = false;
  bool _noSourcesFound = false;
  final Player player = Player();
  bool _isLoading = true;
  VideoController? controller;
  final List<SubtitlesModel> _vidSubtitles = [];
  SubtitlesModel? _selectedSubtitle;
  late SubtitleController _subtitleController;
  String _subtitleText = '';
  bool _useCustomAspectRatio = false;
  final List<double> _aspectRatios = [
    WidgetsBinding
                .instance.platformDispatcher.views.first.physicalSize.height >
            WidgetsBinding
                .instance.platformDispatcher.views.first.physicalSize.width
        ? WidgetsBinding
                .instance.platformDispatcher.views.first.physicalSize.height /
            WidgetsBinding
                .instance.platformDispatcher.views.first.physicalSize.width
        : WidgetsBinding
                .instance.platformDispatcher.views.first.physicalSize.width /
            WidgetsBinding
                .instance.platformDispatcher.views.first.physicalSize.height,
    16 / 9,
    4 / 3,
    3 / 2,
    1 / 1
  ];
  final List<String> _aspectRatioNames = [
    'Device Screen Ratio',
    '16:9',
    '4:3',
    '3:2',
    '1:1'
  ];
  int _aspectRatioIndex = 0;
  late bool _isMaximized;

  List<OMDBSubtitleSearchResponse>? _subtitles;
  final List<VideoSourceModel> _videoSources = [];

  void changeAspectRatio() {
    if (!_useCustomAspectRatio) {
      setState(() {
        _useCustomAspectRatio = true;
        _aspectRatioIndex = 0;
      });
      AlertDialog alert = AlertDialog(
        title: const Text('Aspect Ratio Changed'),
        content: Text(
            'Aspect ratio changed to ${_aspectRatioNames[_aspectRatioIndex]}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      return;
    }
    if (_aspectRatioIndex < _aspectRatios.length - 1) {
      setState(() {
        _aspectRatioIndex++;
      });
    } else {
      setState(() {
        _aspectRatioIndex = 0;
      });
    }
    AlertDialog alert = AlertDialog(
      title: const Text('Aspect Ratio Changed'),
      content: Text(
          'Aspect ratio changed to ${_aspectRatioNames[_aspectRatioIndex]}'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    debugPrint('Aspect ratio changed to ${_aspectRatios[_aspectRatioIndex]}');
  }

  Future<void> getOpeningAndEndingSkipData(
      int? malId, String episodeNumber) async {
    if (malId != null) {
      try {
        var aniSkipService = AniSkipService();
        _openingSkipData = await aniSkipService.getAnimeEpisodeOpeningSkipData(
          malId,
          episodeNumber,
        );
        _endingSkipData = await aniSkipService.getAnimeEpisodeEndingSkipData(
          malId,
          episodeNumber,
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  void getSubtitles() {
    _subtitleController =
        SubtitleController.string('', format: SubtitleFormat.webvtt);
  }

  Future<void> changeSubtitle(SubtitlesModel subtitle) async {
    if (subtitle.subtitleUrl == '') {
      _subtitleController =
          SubtitleController.string('', format: SubtitleFormat.webvtt);
      setState(() {
        _subtitleText = '';
      });
      return;
    }
    _selectedSubtitle = subtitle;
    var body = utf8
        .decode((await http.get(Uri.parse(subtitle.subtitleUrl))).bodyBytes);
    _subtitleController = SubtitleController.string(body,
        format: subtitle.subtitleUrl.endsWith('vtt')
            ? SubtitleFormat.webvtt
            : SubtitleFormat.srt);
    setState(() {
      _subtitleText = '';
    });
  }

  Future<void> getVideoSources(String episodeId) async {
    setState(() {
      _videoSources.clear();
      _vidSubtitles.clear();
    });
    debugPrint('Getting video sources for $episodeId');
    var activeSource = SourceService().detectSource(widget.args.item.source.id);
    List<RawVideoSourceInfoModel> rawVideoSources =
        await activeSource.getVideoSources(episodeId);
    // List<VideoSourceModel> videoSources = [];
    for (var rawVideoSource in rawVideoSources) {
      if (_skipLoadingButtonPressed) {
        break;
      }
      List<VideoSourceModel>? tempVideoSources;
      try {
        var extractor =
            SourceService().detectExtractor(rawVideoSource.sourceId);
        try {
          await extractor.init();
        } catch (e) {
          debugPrint(e.toString());
        }
        tempVideoSources = await extractor?.extractor(rawVideoSource);
      } catch (e) {
        debugPrint(e.toString());
      }
      if (tempVideoSources == null) {
        continue;
      }

      _vidSubtitles.add(SubtitlesModel(
          subtitleUrl: "", subtitleName: "None", subtitleLanguage: "None"));

      for (var videoSource in tempVideoSources) {
        if (videoSource.opSkipData != null) {
          _vidOpeningSkipData = videoSource.opSkipData;
        }
        if (videoSource.edSkipData != null) {
          _vidEndingSkipData = videoSource.edSkipData;
        }
        if (videoSource.subtitles != null) {
          _vidSubtitles.addAll(videoSource.subtitles!);
        }
      }
      _videoSources.addAll(tempVideoSources);
      if (_videoSources.isNotEmpty && _skipLoadingButtonVisible == false) {
        _videoSources.sort((a, b) => b.quality.compareTo(a.quality));
        setState(() {
          _skipLoadingButtonVisible = true;
        });
      }
    }
    debugPrint('out of while loop');
    // _videoSources = videoSources;
    if (_videoSources.isEmpty) {
      setState(() {
        _noSourcesFound = true;
      });
      return;
    }
    _videoSources.sort((a, b) => b.quality.compareTo(a.quality));

    setState(() {
      _skipLoadingButtonVisible = false;
    });
    await player.open(Media(
      _videoSources[0].videoUrl,
      httpHeaders: _videoSources[0].headers,
    ));
    // Media(
    //     "https://vd305.mycdn.me/expires/1691026435249/clientType/0/srcIp/35.150.40.66/type/2/mid/6455233284754/id/5064748173970/ms/185.226.53.14/zs/43/srcAg/GECKO/urls/45.136.21.68/oq/0/ct/28/sig/ZOhKlGd0JF0/ondemand/hls2_5064748173970.CJKVjM_vuwFAkrHM_fQQUAoz3AUpnmji7A==.m3u8",
    //     httpHeaders: {
    //   "User-Agent": streamsSBUserAgent,
    // }));
  }

  Future<void> _loadSources() async {
    DetailedEpisodeModel episode = widget.args.episodes[(widget.args.episodes
            .indexWhere((element) =>
                element.episodeId == widget.args.episodeData.episodeId)) +
        currentEpisodeOffset];

    debugPrint('Loading sources for episode ${episode.episodeNumber}');

    setState(() {
      _isLoading = true;
    });
    if (widget.args.malId != null) {
      await getOpeningAndEndingSkipData(
          widget.args.malId, episode.episodeNumber);
    }
    getSubtitles();
    final RegExp seasonRegex = RegExp(r'(Season (\d*))');
    final RegExp seasonRegex2 = RegExp(r'((\d*)(st|nd|rd|th) Season)');
    var modTitle = widget.args.item.title.replaceFirst("(Dub)", "");
    modTitle = modTitle.replaceFirst("(Sub)", "");
    modTitle = modTitle.replaceFirst("(Uncensored)", "");
    modTitle = modTitle.replaceFirst(seasonRegex, "");
    modTitle = modTitle.replaceFirst(seasonRegex2, "");
    modTitle = modTitle.trim();
    modTitle = modTitle.toLowerCase();

    var omdbService = OMDBService();

    await omdbService
        .getSubtitles(modTitle,
            season: episode.seasonNumber,
            episode: double.parse(episode.episodeNumber))
        .then((value) {
      setState(() {
        _subtitles = value;
      });
    });
    await getVideoSources(episode.episodeId);
    setState(() {
      _isLoading = false;
      _skipLoadingButtonPressed = false;
      _skipLoadingButtonVisible = false;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  RewardedAd? _rewardedAd;

  // TODO: replace this test ad unit with your own ad unit.
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-6476045373908726/2515441256'
      : 'ca-app-pub-3940256099942544/1712485313';

  // final adUnitId = Platform.isAndroid
  //     ? 'ca-app-pub-3940256099942544/5224354917'
  //     : 'ca-app-pub-3940256099942544/1712485313';

  /// Loads a rewarded ad.
  void loadAd() {
    RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            setState(() {
              _rewardedAd = ad;
            });
            // _rewardedAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
            _loadSources();
          },
        ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watchHistoryCubitProvider = BlocProvider.of<WatchHistoryCubit>(context);
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      windowManager.isMaximized().then((value) {
        _isMaximized = value;
        debugPrint('isMaximized: $_isMaximized');
      });
      windowManager.setFullScreen(true);
    }

    if (Platform.isAndroid || Platform.isIOS) {
      loadAd();
    } else {
      _loadSources();
    }

    Future.microtask(() async {
      controller = VideoController(player);

      player.stream.duration.listen((event) {
        if (player.state.duration != Duration.zero) {
          _isLoading = false;
        }
        setState(() {});
      });
      player.stream.position.listen((event) {
        _currentPosition = event;
        if (_openingSkipData != null) {
          if (_currentPosition.inSeconds > _openingSkipData!.startTime &&
              _currentPosition.inSeconds < _openingSkipData!.endTime) {
            if (_skipOpeningButtonVisible == false) {
              setState(() {
                _skipOpeningButtonVisible = true;
              });
            }
          } else {
            if (_skipOpeningButtonVisible == true) {
              setState(() {
                _skipOpeningButtonVisible = false;
              });
            }
          }
        } else if (_vidOpeningSkipData != null) {
          if (_currentPosition.inSeconds > _vidOpeningSkipData!.startTime &&
              _currentPosition.inSeconds < _vidOpeningSkipData!.endTime) {
            if (_skipOpeningButtonVisible == false) {
              setState(() {
                _skipOpeningButtonVisible = true;
              });
            }
          } else {
            if (_skipOpeningButtonVisible == true) {
              setState(() {
                _skipOpeningButtonVisible = false;
              });
            }
          }
        }
        if (_endingSkipData != null) {
          if (_currentPosition.inSeconds > _endingSkipData!.startTime &&
              _currentPosition.inSeconds < _endingSkipData!.endTime) {
            if (_skipEndingButtonVisible == false) {
              setState(() {
                _skipEndingButtonVisible = true;
              });
            }
          } else {
            if (_skipEndingButtonVisible == true) {
              setState(() {
                _skipEndingButtonVisible = false;
              });
            }
          }
        } else if (_vidEndingSkipData != null) {
          if (_currentPosition.inSeconds > _vidEndingSkipData!.startTime &&
              _currentPosition.inSeconds < _vidEndingSkipData!.endTime) {
            if (_skipEndingButtonVisible == false) {
              setState(() {
                _skipEndingButtonVisible = true;
              });
            }
          } else {
            if (_skipEndingButtonVisible == true) {
              setState(() {
                _skipEndingButtonVisible = false;
              });
            }
          }
        }
        setState(() {
          _subtitleText = _subtitleController.textFromMilliseconds(
              player.state.position.inMilliseconds,
              _subtitleController.subtitles);
        });
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    Wakelock.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      windowManager.setFullScreen(false);
      if (_isMaximized) {
        windowManager.maximize().then((value) => debugPrint('maximized'));
      }
    }

    setEpisodeOffset(0);
    setSelectedSubtitleIndex(0);
    setSelectedVideoSourceIndex(0);

    Future.microtask(() async {
      await player.dispose();
    });
    super.dispose();
  }

  bool _shownAd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _rewardedAd != null && _shownAd == false
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Watch an ad to support the developer',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _rewardedAd?.show(onUserEarnedReward: (ad, reward) {
                        setState(() {
                          _shownAd = true;
                        });
                        _loadSources();
                      });
                    },
                    child: const Text('Watch Ad'),
                  ),
                ],
              ),
            )
          : _noSourcesFound == false
              ? controller == null || _isLoading
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _skipLoadingButtonPressed
                                  ? 'Skipping'
                                  : 'Loading',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            _skipLoadingButtonVisible &&
                                    !_skipLoadingButtonPressed
                                ? TextButton.icon(
                                    onPressed: () async {
                                      await player.open(
                                        Media(
                                          _videoSources[0].videoUrl,
                                          httpHeaders: _videoSources[0].headers,
                                        ),
                                      );
                                      setState(() {
                                        _skipLoadingButtonVisible = false;
                                        _skipLoadingButtonPressed = true;
                                      });
                                    },
                                    icon: const Icon(Icons.skip_next),
                                    label: Text('Skip Loading',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    )
                  : Stack(
                      children: [
                        Video(
                          controller: controller!,
                          aspectRatio: _useCustomAspectRatio
                              ? _aspectRatios[_aspectRatioIndex]
                              : null,
                          controls: NoVideoControls,
                        ),
                        IgnorePointer(
                            child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SubtitleView(
                              text: _subtitleText,
                              backgroundColor: Colors.black.withOpacity(0),
                              subtitleStyle: const SubtitleStyle(
                                bordered: true,
                                borderStyle: SubtitleBorderStyle(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                                fontSize: 20,
                                textColor: Colors.white,
                              )),
                        )),
                        PlayerControls(
                            arguments: PlayerControlsArgumentsModel(
                          player: player,
                          videoController: controller!,
                          playerScreenArguments: widget.args,
                          opSkipData: _openingSkipData ?? _vidOpeningSkipData,
                          opSkipButtonVisible: _skipOpeningButtonVisible,
                          edSkipData: _endingSkipData ?? _vidEndingSkipData,
                          edSkipButtonVisible: _skipEndingButtonVisible,
                          videoSources: _videoSources,
                          secondsWatched: widget.args.secondsWatched,
                          subtitles: removeDuplicateSubtitles(_vidSubtitles),
                          selectedSubtitle: _selectedSubtitle,
                          changeSubtitles: changeSubtitle,
                          changeAspectRatio: changeAspectRatio,
                          changeVideoSource: _loadSources,
                          currentEpisodeOffset: currentEpisodeOffset,
                          changeCurrentEpisodeOffset: setEpisodeOffset,
                        ))
                      ],
                    )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No sources found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: Text('Go Back',
                            style: Theme.of(context).textTheme.titleSmall),
                      )
                    ],
                  ),
                ),
    );
  }
}
