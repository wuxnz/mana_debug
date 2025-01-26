import 'dart:convert';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import 'package:mana_debug/app/core/values/constants.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';

import '../helpers/m3u8_helpers.dart';

class GoloadExtractor {
  Future<List<VideoSourceModel>> extractor(
    RawVideoSourceInfoModel sourceInfo,
  ) async {
    var videoServerURL = Uri.parse(sourceInfo.embedUrl!);
    var videoServerResponse = await http.get(videoServerURL, headers: {
      'User-Agent': gogoUserAgent,
    });
    var videoServerSoup = BeautifulSoup(videoServerResponse.body);
    var key = encrypt.Key.fromUtf8("37911490979715163134003223491201");
    var secondKey = encrypt.Key.fromUtf8("54674138327930866480207815084989");
    var iv = encrypt.IV.fromUtf8("3134003223491201");
    var encypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    var encryptedKey =
        encypter.encrypt(videoServerURL.queryParameters['id']!, iv: iv);
    var script = videoServerSoup.find("script",
        attrs: {'data-name': 'episode'})!.attributes['data-value'];
    var token = encypter
        .decrypt(encrypt.Encrypted.fromBase64(script!), iv: iv)
        .toString();
    var params =
        'id=${encryptedKey.base64}&alias=${videoServerURL.queryParameters['id']!}&$token';
    var fetchRes = await http.get(
        Uri.parse('https://${videoServerURL.host}/encrypt-ajax.php?$params'),
        headers: {
          'User-Agent': gogoUserAgent,
          'X-Requested-With': 'XMLHttpRequest',
        });
    var fetchResJson = jsonDecode(fetchRes.body);
    encypter =
        encrypt.Encrypter(encrypt.AES(secondKey, mode: encrypt.AESMode.cbc));
    var decrypted = encypter
        .decrypt(encrypt.Encrypted.fromBase64(fetchResJson['data']), iv: iv);
    var decryptedData = jsonDecode(decrypted);
    var m3u8Helper = M3U8HelperTwo();
    List<M3U8pass> videoInfo = await m3u8Helper.m3u8GenerationFileName(
        decryptedData['source_bk'][0]['file'], VideoResolution.multi, null);

    List<VideoSourceModel> videoSources = [];
    videoInfo
        .map((e) => videoSources.add(VideoSourceModel(
              source: VideoSourceInfoModel(
                sourceId: 'goload',
                sourceName: 'Goload',
                baseUrl:
                    'https://${Uri.parse(decryptedData['source'][0]['file']).host}',
              ),

              sourceUrlDescription: sourceInfo.language == null
                  ? "Gogo ${e.dataQuality}"
                  : "Gogo ${e.dataQuality} (${languageTypeToString(sourceInfo.language!)})",

              videoUrl: e.dataUrl,

              resolution: e.dataQuality == "1080"
                  ? VideoResolution.p1080
                  : e.dataQuality == "720"
                      ? VideoResolution.p720
                      : e.dataQuality == "480"
                          ? VideoResolution.p480
                          : e.dataQuality == "360"
                              ? VideoResolution.p360
                              : VideoResolution.other,
              quality: e.dataQuality == "Auto" ? 0 : int.parse(e.dataQuality),
              // headers: {
              //   'User-Agent': gogoUserAgent,
              // },
            )))
        .toList();
    return videoSources;
  }
}
