import 'dart:io';

import 'package:dio/dio.dart';

class ResolvedUrl {
  final String url;
  final List<Cookie> cookies;

  ResolvedUrl({required this.url, required this.cookies});
}

class InterceptedUrl {
  final String url;
  final List<Cookie> cookies;
  final List<String>? matchedUrls;

  InterceptedUrl({required this.url, required this.cookies, this.matchedUrls});
}

class InterceptedDataResponse {
  final List<String>? matchedUrls;
  final Response response;

  InterceptedDataResponse({this.matchedUrls, required this.response});
}
