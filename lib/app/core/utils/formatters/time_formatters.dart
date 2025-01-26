DateTime yearStringToDateTime(String year) {
  return DateTime.parse('$year-01-01 00:00:00.000');
}

String secondsToDurationString(int secondsIn) {
  final duration = Duration(seconds: secondsIn);
  final hours = duration.inHours;
  final minutes = duration.inMinutes - hours * 60;
  final seconds = duration.inSeconds - hours * 3600 - minutes * 60;
  final hoursString = hours.toString().padLeft(2, '0');
  final minutesString = minutes.toString().padLeft(2, '0');
  final secondsString = seconds.toString().padLeft(2, '0');
  return '$hoursString:$minutesString:$secondsString';
}