import 'package:dio/dio.dart';
import 'package:mana_debug/app/core/utils/network/bypasses/cloud_flare_bypass.dart';

import 'clients.dart';

class CloudFlareClient extends NetworkClient {
  final Dio _dio = Dio();

  @override
  Future<Response> get(String url,
      {Map<String, String>? headers,
      int sleepSeconds = 0,
      RegExp? finalUrlPattern}) async {
    CloudFlareBypass cloudFlareBypass = CloudFlareBypass();
    var responseString = await cloudFlareBypass.getCookies(url,
        sleepSeconds: sleepSeconds,
        headers: headers,
        finalUrlPattern: finalUrlPattern);
    return Response(
        data: responseString, requestOptions: RequestOptions(path: url));
  }

  @override
  Future<Response> post(String url,
      {Map<String, String>? headers, dynamic body}) async {
    return _dio.post(url, data: body, options: Options(headers: headers));
  }

  @override
  Future<Response> put(String url,
      {Map<String, String>? headers, dynamic body}) async {
    return _dio.put(url, data: body, options: Options(headers: headers));
  }

  @override
  Future<Response> delete(String url, {Map<String, String>? headers}) async {
    return _dio.delete(url, options: Options(headers: headers));
  }
}
