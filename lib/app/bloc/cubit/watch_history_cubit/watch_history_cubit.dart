import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

class WatchHistoryCubit extends HydratedCubit<List<BaseItemModel>> {
  List<BaseItemModel> get watchHistory => state;

  WatchHistoryCubit() : super(<BaseItemModel>[]);

  bool matchWatchHistory(BaseItemModel item) {
    final index = state.indexWhere((element) =>
        element.id == item.id && element.source.id == item.source.id);
    return index != -1;
  }

  BaseEpisodeModel? matchWatchHistoryEpisode(
      BaseEpisodeModel episode, BaseItemModel item) {
    final index = state.indexWhere((element) =>
        element.id == item.id && element.source.id == item.source.id);
    if (index != -1) {
      final episodeIndex = state[index]
              .episodesWatched
              ?.episodesWatched
              .indexWhere(
                  (element) => element.episodeId == episode.episodeId) ??
          -1;
      if (episodeIndex != -1) {
        return state[index].episodesWatched?.episodesWatched[episodeIndex];
      }
    }
    return null;
  }

  BaseItemModel? getWatchHistoryItem(BaseItemModel item) {
    final index = state.indexWhere((element) =>
        element.id == item.id && element.source.id == item.source.id);
    if (index != -1) {
      return state[index];
    }
    return null;
  }

  void addToWatchHistory(BaseItemModel item) {
    emit([...state, item]);
  }

  void removeItemFromWatchHistory(BaseItemModel item) {
    var match = getWatchHistoryItem(item);
    if (match != null) {
      emit(state.where((element) => element != match).toList());
    } else {}
  }

  void updateWatchHistoryItemBase(BaseItemModel item) {
    final index = state.indexWhere((element) =>
        element.id == item.id && element.source.id == item.source.id);
    if (index != -1) {
      state[index] = BaseItemModel(
        episodesWatched: state[index].episodesWatched,
        source: item.source,
        id: item.id,
        title: item.title,
        imageUrl: item.imageUrl,
        languages: item.languages,
        episodeCount: item.episodeCount,
        watchStatus: item.watchStatus,
      );
      emit([...state]);
    }
  }

  void updateWatchHistoryItemEpisodeList(
      BaseEpisodeModel episode, BaseItemModel item) {
    final index = state.indexWhere((element) =>
        element.id == item.id && element.source.id == item.source.id);
    if (index == -1) {
      var newItem = BaseItemModel(
        episodesWatched: EpisodesWatchedModel(
          episodesWatched: [episode],
        ),
        source: item.source,
        id: item.id,
        title: item.title,
        imageUrl: item.imageUrl,
        languages: item.languages,
        episodeCount: item.episodeCount,
        watchStatus: WatchStatusModel(
          status: WatchStatus.watching,
          episodeCount: item.episodeCount,
          episodesWatched: 1,
          altEpisodesWatched: 0,
          lastWatchedDate: DateTime.now(),
          lastWatchedEpisode: BaseEpisodeModel(
            episodeId: episode.episodeId,
            episodeName: episode.episodeName,
            episodeNumber: episode.episodeNumber,
            secondsWatched: episode.secondsWatched,
            episodeDuration: episode.episodeDuration,
            progress: episode.progress,
          ),
        ),
      );
      state.add(newItem);
      emit([...state]);
    } else {
      if (matchWatchHistoryEpisode(episode, item) != null) {
        state[index]
            .episodesWatched
            ?.episodesWatched
            .removeWhere((element) => element.episodeId == episode.episodeId);
        state[index].episodesWatched?.episodesWatched.add(episode);

        state[index].watchStatus?.lastWatchedDate = DateTime.now();

        state[index].watchStatus?.lastWatchedEpisode = BaseEpisodeModel(
          episodeId: episode.episodeId,
          episodeName: episode.episodeName,
          episodeNumber: episode.episodeNumber,
          secondsWatched: episode.secondsWatched,
          episodeDuration: episode.episodeDuration,
          progress: episode.progress,
        );
      } else {
        state[index].episodesWatched = EpisodesWatchedModel(
          episodesWatched: [
            ...state[index].episodesWatched?.episodesWatched ?? [],
            episode,
          ],
        );

        state[index].watchStatus?.episodesWatched =
            state[index].episodesWatched?.episodesWatched.length ?? 1;

        state[index].watchStatus?.lastWatchedDate = DateTime.now();

        state[index].watchStatus?.lastWatchedEpisode = BaseEpisodeModel(
          episodeId: episode.episodeId,
          episodeName: episode.episodeName,
          episodeNumber: episode.episodeNumber,
          secondsWatched: episode.secondsWatched,
          episodeDuration: episode.episodeDuration,
          progress: episode.progress,
        );
      }
      emit([...state]);
    }
  }

  void updateWatchHistoryItemWatchStatus(
      BaseItemModel item, WatchStatus watchStatus) {
    final index = state.indexWhere((element) =>
        element.id == item.id && element.source.id == item.source.id);
    if (index != -1) {
      if (watchStatus != WatchStatus.notWatched) {
        state[index].watchStatus = WatchStatusModel(
          status: watchStatus,
          episodeCount: item.episodeCount,
          episodesWatched: item.watchStatus?.episodesWatched ?? 0,
          altEpisodesWatched: item.watchStatus?.altEpisodesWatched ?? 0,
          lastWatchedDate: DateTime.now(),
          lastWatchedEpisode: item.watchStatus?.lastWatchedEpisode,
        );
        emit([...state]);
      } else {
        emit(state.where((element) => element != item).toList());
      }
    } else {
      if (watchStatus != WatchStatus.notWatched) {
        emit([
          ...state,
          BaseItemModel(
            source: item.source,
            id: item.id,
            title: item.title,
            imageUrl: item.imageUrl,
            languages: item.languages,
            episodeCount: item.episodeCount,
            watchStatus: WatchStatusModel(
              status: watchStatus,
              episodeCount: item.episodeCount,
              episodesWatched: item.watchStatus?.episodesWatched ?? 0,
              altEpisodesWatched: item.watchStatus?.altEpisodesWatched ?? 0,
              lastWatchedDate: DateTime.now(),
              lastWatchedEpisode: item.watchStatus?.lastWatchedEpisode,
            ),
          )
        ]);
      }
    }
  }

  void updateWatchHistoryItemEpisodeCount(
      BaseItemModel item, EpisodeCount episodeCount) {
    try {
      final index = state.indexWhere((element) =>
          element.id == item.id && element.source.id == item.source.id);
      if (index != -1) {
        state[index].episodeCount = episodeCount;
        emit([...state]);
      }
    } catch (e) {
      debugPrint("Error updating episode count: $e");
    }
  }

  List<BaseItemModel> getWatchHistorySortedByDate() {
    return state
        .where(
            (element) => element.watchStatus?.status != WatchStatus.notWatched)
        .toList()
      ..sort((a, b) =>
          b.watchStatus?.lastWatchedDate
              ?.compareTo(a.watchStatus?.lastWatchedDate ?? DateTime.now())
              .toInt() ??
          0);
  }

  void clearWatchHistory() {
    emit(<BaseItemModel>[]);
  }

  @override
  List<BaseItemModel> fromJson(Map<String, dynamic> json) {
    try {} catch (e) {}
    return (json['watchHistory'] as List<dynamic>)
        .map((e) => BaseItemModel.fromJson(e))
        .toList();
  }

  @override
  Map<String, dynamic> toJson(List<BaseItemModel> state) {
    return {
      'watchHistory': state.map((e) => e.toJson()).toList(),
    };
  }
}
