import '../../../data/models/sources/base_model.dart';

List<String> removeDuplicates(List<String> list) {
  var newList = <String>[];
  for (var item in list) {
    if (!newList.contains(item)) {
      newList.add(item);
    }
  }
  return newList;
}

List<SubtitlesModel> removeDuplicateSubtitles(List<SubtitlesModel> list) {
  var newList = <SubtitlesModel>[];
  bool check = false;
  for (var item in list) {
    for (var item2 in newList) {
      if (item.subtitleLanguage == item2.subtitleLanguage) {
        check = true;
        break;
      }
    }
    if (!check) {
      newList.add(item);
    }
    check = false;
  }
  return newList;
}
