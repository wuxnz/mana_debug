import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mana_debug/app/core/utils/misc/misc_utils.dart';

class InterceptorClient {
  Future<List<String>> get(String url, List<RegExp> patterns,
      {Map<String, String>? headers,
      Uint8List? body,
      String? userAgent}) async {
    CookieManager cookieManager = CookieManager.instance();
    List<String> matchedUrls = [];
    var webView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(url)),
      initialUserScripts: UnmodifiableListView<UserScript>([
        UserScript(source: """
          
          var requests = performance.getEntriesByType('resource');
          var urls = [];
          for (var i = 0; i < requests.length; i++) {
            urls.push(requests[i].name);
          }
        """, injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END),
      ]),
      initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(
            domStorageEnabled: true,
            databaseEnabled: true,
            clearSessionCache: false,
          ),
          crossPlatform: InAppWebViewOptions(
            userAgent: userAgent ?? '',
            javaScriptCanOpenWindowsAutomatically: true,
            preferredContentMode: UserPreferredContentMode.DESKTOP,
            useShouldInterceptAjaxRequest: true,
            useShouldInterceptFetchRequest: true,
          )),
      onWebViewCreated: (InAppWebViewController controller) {},
      onLoadStart: (controller, url) async {
        debugPrint("URL Load Start: ${url.toString()}");
        var result = await controller.evaluateJavascript(source: """
          
          var requests = performance.getEntriesByType('resource');
          var urls = [];
          for (var i = 0; i < requests.length; i++) {
            urls.push(requests[i].name);
          }
          urls;
        """);
        debugPrint("Result: ${result.runtimeType} $result");
        if (result is List) {
          if (result.isNotEmpty) {
            debugPrint("Result Length: ${result.length}");
            List<String> resultStrings =
                result.map((e) => e.toString()).toList();
            matchedUrls.addAll(resultStrings.where((element) {
              return patterns.any((pattern) => pattern.hasMatch(element));
            }));
          }
        }
      },
      onLoadStop: (controller, url) async {
        List<Cookie> cookies = await cookieManager.getCookies(url: url!);
        for (var cookie in cookies) {
          debugPrint("${cookie.name} ${cookie.value}");
        }
        var result = await controller.evaluateJavascript(source: """
          
          var requests = performance.getEntriesByType('resource');
          var urls = [];
          for (var i = 0; i < requests.length; i++) {
            urls.push(requests[i].name);
          }
          urls;
        """);
        debugPrint("Result: ${result.runtimeType} $result");
        if (result is List) {
          if (result.isNotEmpty) {
            debugPrint("Result Length: ${result.length}");
            List<String> resultStrings =
                result.map((e) => e.toString()).toList();
            matchedUrls.addAll(resultStrings.where((element) {
              return patterns.any((pattern) => pattern.hasMatch(element));
            }));
          }
        }
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) async {
        debugPrint("URL Update Visited History: ${url.toString()}");
        var result = await controller.evaluateJavascript(source: """
          
          var requests = performance.getEntriesByType('resource');
          var urls = [];
          for (var i = 0; i < requests.length; i++) {
            urls.push(requests[i].name);
          }
          urls;
        """);
        debugPrint("Result: ${result.runtimeType} $result");
        if (result is List) {
          if (result.isNotEmpty) {
            debugPrint("Result Length: ${result.length}");
            List<String> resultStrings =
                result.map((e) => e.toString()).toList();
            matchedUrls.addAll(resultStrings.where((element) {
              return patterns.any((pattern) => pattern.hasMatch(element));
            }));
          }
        }
      },
      onProgressChanged: (controller, progress) async {
        if (progress == 100) {
          var result = await controller.evaluateJavascript(source: """
          
          var requests = performance.getEntriesByType('resource');
          var urls = [];
          for (var i = 0; i < requests.length; i++) {
            urls.push(requests[i].name);
          }
          urls;
        """);
          debugPrint("Result: ${result.runtimeType} $result");
          if (result is List) {
            if (result.isNotEmpty) {
              debugPrint("Result Length: ${result.length}");
              List<String> resultStrings =
                  result.map((e) => e.toString()).toList();
              matchedUrls.addAll(resultStrings.where((element) {
                return patterns.any((pattern) => pattern.hasMatch(element));
              }));
            }
          }
        }
      },
      onAjaxReadyStateChange: (controller, ajaxRequest) async {
        debugPrint("Ajax ready state change: ${ajaxRequest.url}");
        var result = await controller.evaluateJavascript(source: """
          
          var requests = performance.getEntriesByType('resource');
          var urls = [];
          for (var i = 0; i < requests.length; i++) {
            urls.push(requests[i].name);
          }
          urls;
        """);
        debugPrint("Result: ${result.runtimeType} $result");
        if (result is List) {
          if (result.isNotEmpty) {
            debugPrint("Result Length: ${result.length}");
            List<String> resultStrings =
                result.map((e) => e.toString()).toList();
            matchedUrls.addAll(resultStrings.where((element) {
              return patterns.any((pattern) => pattern.hasMatch(element));
            }));
          }
        }
        if (patterns.any((pattern) =>
            pattern.hasMatch(ajaxRequest.url.toString()) &&
            ajaxRequest.url.toString().startsWith("http"))) {
          matchedUrls.add(ajaxRequest.url.toString());
          if (removeDuplicates(matchedUrls).length == patterns.length) {
            controller.stopLoading();
          }
        }
        return AjaxRequestAction.PROCEED;
      },
      onAjaxProgress: (controller, ajaxRequest) async {
        debugPrint("Ajax progress: ${ajaxRequest.url}");
        var result = await controller.evaluateJavascript(source: """
          
          var requests = performance.getEntriesByType('resource');
          var urls = [];
          for (var i = 0; i < requests.length; i++) {
            urls.push(requests[i].name);
          }
          urls;
        """);
        debugPrint("Result: ${result.runtimeType} $result");
        if (result is List) {
          if (result.isNotEmpty) {
            debugPrint("Result Length: ${result.length}");
            List<String> resultStrings =
                result.map((e) => e.toString()).toList();
            matchedUrls.addAll(resultStrings.where((element) {
              return patterns.any((pattern) => pattern.hasMatch(element));
            }));
          }
        }
        if (patterns.any((pattern) =>
            pattern.hasMatch(ajaxRequest.url.toString()) &&
            ajaxRequest.url.toString().startsWith("http"))) {
          matchedUrls.add(ajaxRequest.url.toString());
          if (removeDuplicates(matchedUrls).length == patterns.length) {
            controller.stopLoading();
          }
        }
        return AjaxRequestAction.PROCEED;
      },
      shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
        debugPrint("Ajax request: ${ajaxRequest.url}");
        var result = await controller.evaluateJavascript(source: """
          
          var requests = performance.getEntriesByType('resource');
          var urls = [];
          for (var i = 0; i < requests.length; i++) {
            urls.push(requests[i].name);
          }
          urls;
        """);
        debugPrint("Result: ${result.runtimeType} $result");
        if (result is List) {
          if (result.isNotEmpty) {
            debugPrint("Result Length: ${result.length}");
            List<String> resultStrings =
                result.map((e) => e.toString()).toList();
            matchedUrls.addAll(resultStrings.where((element) {
              return patterns.any((pattern) => pattern.hasMatch(element));
            }));
          }
        }
        if (patterns.any((pattern) =>
            pattern.hasMatch(ajaxRequest.url.toString()) &&
            ajaxRequest.url.toString().startsWith("http"))) {
          matchedUrls.add(ajaxRequest.url.toString());
          if (removeDuplicates(matchedUrls).length == patterns.length) {
            controller.stopLoading();
          }
        }
        return ajaxRequest;
      },
      shouldInterceptFetchRequest: (controller, fetchRequest) async {
        debugPrint("Fetch request: ${fetchRequest.url}");
        var result = await controller.evaluateJavascript(source: """
          
          var requests = performance.getEntriesByType('resource');
          var urls = [];
          for (var i = 0; i < requests.length; i++) {
            urls.push(requests[i].name);
          }
          urls;
        """);
        debugPrint("Result: ${result.runtimeType} $result");
        if (result is List) {
          if (result.isNotEmpty) {
            debugPrint("Result Length: ${result.length}");
            List<String> resultStrings =
                result.map((e) => e.toString()).toList();
            matchedUrls.addAll(resultStrings.where((element) {
              return patterns.any((pattern) => pattern.hasMatch(element));
            }));
          }
        }
        if (patterns.any((pattern) =>
            pattern.hasMatch(fetchRequest.url.toString()) &&
            fetchRequest.url.toString().startsWith("http"))) {
          matchedUrls.add(fetchRequest.url.toString());
          if (removeDuplicates(matchedUrls).length == patterns.length) {
            controller.stopLoading();
          }
        }
        return fetchRequest;
      },
      shouldOverrideUrlLoading:
          (controller, shouldOverrideUrlLoadingRequest) async {
        debugPrint(
            "URL Override Url Loading: ${shouldOverrideUrlLoadingRequest.request.url}");

        if (patterns.any((pattern) =>
            pattern.hasMatch(
                shouldOverrideUrlLoadingRequest.request.url.toString()) &&
            shouldOverrideUrlLoadingRequest.request.url
                .toString()
                .startsWith("http"))) {
          matchedUrls
              .add(shouldOverrideUrlLoadingRequest.request.url.toString());
          if (removeDuplicates(matchedUrls).length == patterns.length) {
            controller.stopLoading();
          }
        }
        return NavigationActionPolicy.ALLOW;
      },
    );

    await webView.run();

    while (removeDuplicates(matchedUrls).length < patterns.length) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    await webView.dispose();

    matchedUrls = removeDuplicates(matchedUrls);

    debugPrint("Matched URLs: ${matchedUrls.length}");
    debugPrint("Matched URLs: $matchedUrls");
    return matchedUrls;
  }
}
