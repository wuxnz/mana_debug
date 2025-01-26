import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

class ActiveSourceCubit extends HydratedCubit<BaseSourceModel> {
  BaseSourceModel get activeSource => state;

  ActiveSourceCubit() : super(BaseSourceModel(
          id: '0',
          type: SourceType.none,
          sourceName: 'None',
          baseUrl: '',
  ));

  void changeSource(BaseSourceModel source) {
    emit(source);
  }

  @override
  BaseSourceModel? fromJson(Map<String, dynamic> json) {
    return BaseSourceModel(
      id: json['id'] as String,
      type: SourceType.values[json['type'] as int],
      sourceName: json['sourceName'] as String,
      baseUrl: json['baseUrl'] as String,
    );
  }

  @override
  Map<String, dynamic>? toJson(BaseSourceModel state) {
    return {
      'id': state.id,
      'type': state.type.index,
      'sourceName': state.sourceName,
      'baseUrl': state.baseUrl,
    };
  }
}
