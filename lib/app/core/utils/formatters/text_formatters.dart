String stringToInitialsCapitalized(String string) {
  final words = string.split(' ');
  final initials = words.map((e) => e[0].toUpperCase()).join();
  return initials;
}

String reverseString(String string) {
  return string.split('').reversed.join();
}
