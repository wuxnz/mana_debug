import 'package:dio/dio.dart';
import 'package:mana_debug/app/data/models/utils/network/network_utils_models.dart';

abstract class NetworkClient {
  Future<Response> get(String url,
      {Map<String, String> headers,
      int sleepSeconds = 0,
      RegExp? finalUrlPattern});
  Future<Response> post(String url,
      {Map<String, String> headers, dynamic body});
  Future<Response> put(String url, {Map<String, String> headers, dynamic body});
  Future<Response> delete(String url, {Map<String, String> headers});
}

abstract class InterceptingNetworkClient {
  Future<InterceptedDataResponse> get(String url, List<RegExp> patterns,
      {Map<String, String> headers});
  Future<InterceptedDataResponse> post(String url, List<RegExp> patterns,
      {Map<String, String> headers, dynamic body});
  Future<InterceptedDataResponse> put(String url, List<RegExp> patterns,
      {Map<String, String> headers, dynamic body});
  Future<InterceptedDataResponse> delete(String url, List<RegExp> patterns,
      {Map<String, String> headers});
}
