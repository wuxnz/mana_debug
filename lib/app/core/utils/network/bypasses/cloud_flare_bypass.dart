import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide Cookie;
import 'package:mana_debug/app/data/models/utils/network/network_utils_models.dart';

class CloudFlareBypass {
  static const cfTag = 'cf_clearance';
  Future<String> getCookies(
    String url, {
    String? userAgent,
    int sleepSeconds = 0,
    Map<String, String>? headers,
    RegExp? finalUrlPattern,
  }) async {
    CookieManager cookieManager = CookieManager.instance();
    String? response;
    var headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(url), headers: headers),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          userAgent: userAgent ?? '',
          useShouldOverrideUrlLoading: true,
        ),
      ),
      onLoadStop: (controller, url) async {
        if (finalUrlPattern != null) {
          if (finalUrlPattern.hasMatch(url.toString())) {
            response = await controller.evaluateJavascript(
                source: 'document.documentElement.outerHTML');
            debugPrint('Final URL: $url');
          }
        } else {
          response = await controller.evaluateJavascript(
              source: 'document.documentElement.outerHTML');
        }
      },
    );
    await headlessWebView.run();
    await Future.delayed(Duration(seconds: sleepSeconds));
    List<Cookie> cookiesList = [];
    var cookies = await cookieManager.getCookies(url: Uri.parse(url));

    for (var cookie in cookies) {
      cookiesList.add(Cookie(cookie.name, cookie.value));
    }
    while (response == null || response!.length < 100) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await headlessWebView.dispose();
    return response!;
  }

  Future<InterceptedUrl?> getCookiesAndMatches(
      String url, List<RegExp> patterns,
      {String? userAgent}) async {
    List<String> matches = [];
    CookieManager cookieManager = CookieManager.instance();
    var headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(url)),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          userAgent: userAgent ?? '',
          useShouldInterceptAjaxRequest: true,
        ),
      ),
      shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
        return ajaxRequest;
      },
    );
    await headlessWebView.run();
    List<Cookie> cookiesList = [];
    var cookies = await cookieManager.getCookies(url: Uri.parse(url));

    for (var cookie in cookies) {
      cookiesList.add(Cookie(cookie.name, cookie.value));
    }
    await headlessWebView.dispose();
    return InterceptedUrl(
        url: url,
        cookies: cookiesList,
        matchedUrls: matches.isNotEmpty ? matches : null);
  }
}
