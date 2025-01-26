import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import '../../data/models/services/external_helper_services_models/anime_filler_list.dart';
import '../../data/models/services/external_helper_services_models/kitsu.dart';
import '../../data/models/services/external_helper_services_models/tmdb.dart';
import '../../data/models/sources/base_model.dart';

class EpisodeBox extends StatelessWidget {
  final DetailedEpisodeModel episodeData;
  final InfoPageArgumentsModel args;
  final double? progress;
  final int? secondsWatched;
  final EpisodeCount episodeCount;
  final int? malId;
  final List<DetailedEpisodeModel> episodes;
  final AnimeFillerListData? fillerStatus;
  final String tmdbImageBaseUrl;
  final Node? kitsuEpisodeData;
  final Episode? tmdbEpisodeData;

  const EpisodeBox(
      {super.key,
      required this.episodeData,
      required this.args,
      this.progress,
      this.secondsWatched,
      required this.episodeCount,
      this.malId,
      required this.episodes,
      this.fillerStatus,
      required this.tmdbImageBaseUrl,
      this.kitsuEpisodeData,
      this.tmdbEpisodeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            Navigator.of(context).pushNamed(
              "/player",
              arguments: PlayerScreenArgumentsModel(
                episodeData: episodeData,
                item: BaseItemModel(
                  source: args.item.source,
                  id: args.item.id,
                  title: args.item.title,
                  imageUrl: args.item.imageUrl,
                  languages: args.item.languages,
                  episodeCount: episodeCount,
                ),
                secondsWatched: secondsWatched ?? 0,
                malId: malId,
                episodes: episodes,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.network(
                      tmdbEpisodeData?.stillPath != null ||
                              kitsuEpisodeData?.thumbnail != null
                          ? tmdbEpisodeData?.stillPath != null
                              ? tmdbImageBaseUrl + tmdbEpisodeData!.stillPath!
                              : kitsuEpisodeData!.thumbnail!.original.url
                          : args.item.imageUrl,
                      errorBuilder: (context, error, stackTrace) => SizedBox(
                        child: Skeleton(
                          isLoading: true,
                          skeleton: const SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                              width: 110,
                              height: 60,
                            ),
                          ),
                          themeMode: ThemeMode.dark,
                          child: Container(),
                        ),
                      ),
                      width: 110,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${episodeData.episodeNumber}. ${tmdbEpisodeData != null || kitsuEpisodeData != null ? tmdbEpisodeData?.name ?? kitsuEpisodeData!.titles.canonical : episodeData.episodeName ?? "Episode ${episodeData.episodeNumber}"}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            tmdbEpisodeData?.runtime != null
                                ? Text(
                                    '${tmdbEpisodeData!.runtime!} min',
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey.shade500),
                                  )
                                : const SizedBox.shrink(),
                            tmdbEpisodeData?.runtime != null
                                ? const SizedBox(
                                    width: 8.0,
                                  )
                                : const SizedBox.shrink(),
                            fillerStatus != null
                                ? Text(
                                    "(${fillerStatusToString(fillerStatus!.fillerStatus)})",
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        )
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.play_arrow))
                ],
              ),
              SizedBox(
                height: (tmdbEpisodeData?.overview != null &&
                            tmdbEpisodeData?.overview != "") ||
                        (kitsuEpisodeData?.description.en != null &&
                            kitsuEpisodeData?.description.en != "")
                    ? 8.0
                    : 0.0,
              ),
              (tmdbEpisodeData?.overview != null &&
                          tmdbEpisodeData?.overview != "") ||
                      (kitsuEpisodeData?.description.en != null &&
                          kitsuEpisodeData?.description.en != "")
                  ? Text(
                      tmdbEpisodeData?.overview ??
                          kitsuEpisodeData?.description.en ??
                          '',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                height: (tmdbEpisodeData?.overview != null &&
                            tmdbEpisodeData?.overview != "") ||
                        (kitsuEpisodeData?.description.en != null &&
                            kitsuEpisodeData?.description.en != "") ||
                        (progress != null && progress! > 0)
                    ? 5.0
                    : 0.0,
              ),
              progress != null && progress! > 0
                  ? LinearProgressIndicator(
                      value: progress,
                      minHeight: 2.5,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
