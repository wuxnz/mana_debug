import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

class FavoritesCubit extends HydratedCubit<List<BaseItemModel>> {
  List<BaseItemModel> get favorites => state;

  FavoritesCubit() : super(<BaseItemModel>[]);

  bool matchFavorite(BaseItemModel item) {
    final index = state.indexWhere((element) =>
        element.id == item.id && element.source.id == item.source.id);
    return index != -1;
  }

  void addFavorite(BaseItemModel item) {
    emit([...state, item]);
  }

  void removeFavorite(BaseItemModel item) {
    emit(state.where((element) => element.id != item.id).toList());
  }

  void updateFavorite(BaseItemModel item) {
    final index = state.indexWhere((element) =>
        element.id == item.id && element.source.id == item.source.id);
    if (index != -1) {
      state[index] = item;
      emit([...state]);
    }
  }

  void updateFavoriteEpisodeCount(
      BaseItemModel item, EpisodeCount episodeCount) {
    final index = state.indexWhere((element) =>
        element.id == item.id && element.source.id == item.source.id);
    if (index != -1) {
      state[index].episodeCount = episodeCount;
      state[index].watchStatus?.episodeCount = episodeCount;
      emit([...state]);
    }
  }

  void clearFavorites() {
    emit(<BaseItemModel>[]);
  }

  @override
  List<BaseItemModel>? fromJson(Map<String, dynamic> json) {
    return (json['favorites'] as List<dynamic>)
        .map((e) => BaseItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Map<String, dynamic>? toJson(List<BaseItemModel> state) {
    return {
      'favorites': state.map((e) => e.toJson()).toList(),
    };
  }
}
