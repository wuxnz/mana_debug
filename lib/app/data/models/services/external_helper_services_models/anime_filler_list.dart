import '../../sources/base_model.dart';

class AnimeFillerListData {
  final String? episodeNumber;
  final String episodeTitle;
  final FillerStatus fillerStatus;
  final DateTime airDate;

  AnimeFillerListData({
    required this.episodeNumber,
    required this.episodeTitle,
    required this.fillerStatus,
    required this.airDate,
  });
}
