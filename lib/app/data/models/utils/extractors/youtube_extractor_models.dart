import 'dart:convert';

YoutubeExtractorResponseModel youtubeExtractorResponseModelFromJson(
        String str) =>
    YoutubeExtractorResponseModel.fromJson(json.decode(str));

String youtubeExtractorResponseModelToJson(
        YoutubeExtractorResponseModel data) =>
    json.encode(data.toJson());

class YoutubeExtractorResponseModel {
  YoutubeExtractorResponseModel({
    required this.id,
    required this.cipher,
    required this.meta,
    required this.thumb,
    required this.itags,
    required this.videoQuality,
    required this.url,
    required this.mp3Converter,
    required this.hosting,
    this.sd,
    this.hd,
    required this.timestamp,
  });

  String id;
  bool cipher;
  Meta meta;
  String thumb;
  List<String> itags;
  List<String> videoQuality;
  List<Url> url;
  String mp3Converter;
  String hosting;
  dynamic sd;
  dynamic hd;
  int timestamp;

  factory YoutubeExtractorResponseModel.fromJson(Map<String, dynamic> json) =>
      YoutubeExtractorResponseModel(
        id: json["id"],
        cipher: json["cipher"],
        meta: Meta.fromJson(json["meta"]),
        thumb: json["thumb"],
        itags: List<String>.from(json["itags"].map((x) => x)),
        videoQuality: List<String>.from(json["video_quality"].map((x) => x)),
        url: List<Url>.from(json["url"].map((x) => Url.fromJson(x))),
        mp3Converter: json["mp3Converter"],
        hosting: json["hosting"],
        sd: json["sd"],
        hd: json["hd"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cipher": cipher,
        "meta": meta.toJson(),
        "thumb": thumb,
        "itags": List<dynamic>.from(itags.map((x) => x)),
        "video_quality": List<dynamic>.from(videoQuality.map((x) => x)),
        "url": List<dynamic>.from(url.map((x) => x.toJson())),
        "mp3Converter": mp3Converter,
        "hosting": hosting,
        "sd": sd,
        "hd": hd,
        "timestamp": timestamp,
      };
}

class Meta {
  Meta({
    required this.title,
    required this.source,
    required this.duration,
    required this.tags,
    required this.subtitle,
  });

  String title;
  String source;
  String duration;
  String tags;
  Subtitle subtitle;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        title: json["title"],
        source: json["source"],
        duration: json["duration"],
        tags: json["tags"],
        subtitle: Subtitle.fromJson(json["subtitle"]),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "source": source,
        "duration": duration,
        "tags": tags,
        "subtitle": subtitle.toJson(),
      };
}

class Subtitle {
  Subtitle({
    required this.token,
    required this.language,
  });

  String token;
  List<String> language;

  factory Subtitle.fromJson(Map<String, dynamic> json) => Subtitle(
        token: json["token"],
        language: List<String>.from(json["language"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "language": List<dynamic>.from(language.map((x) => x)),
      };
}

class Url {
  Url({
    required this.url,
    required this.name,
    required this.subname,
    required this.type,
    required this.ext,
    required this.downloadable,
    required this.quality,
    required this.qualityNumber,
    this.contentLength,
    this.videoCodec,
    this.audioCodec,
    required this.audio,
    required this.noAudio,
    required this.itag,
    required this.isBundle,
    required this.isOtf,
    required this.isDrm,
    this.filesize,
    required this.attr,
  });

  String url;
  Name name;
  String subname;
  String type;
  Ext ext;
  bool downloadable;
  String quality;
  int qualityNumber;
  int? contentLength;
  VideoCodec? videoCodec;
  String? audioCodec;
  bool audio;
  bool noAudio;
  String itag;
  bool isBundle;
  bool isOtf;
  bool isDrm;
  int? filesize;
  Attr attr;

  factory Url.fromJson(Map<String, dynamic> json) => Url(
        url: json["url"],
        name: nameValues.map[json["name"]]!,
        subname: json["subname"],
        type: json["type"],
        ext: extValues.map[json["ext"]]!,
        downloadable: json["downloadable"],
        quality: json["quality"],
        qualityNumber: json["qualityNumber"],
        contentLength: json["contentLength"],
        videoCodec: videoCodecValues.map[json["videoCodec"]] ?? VideoCodec.NONE,
        audioCodec: json["audioCodec"],
        audio: json["audio"],
        noAudio: json["no_audio"],
        itag: json["itag"],
        isBundle: json["isBundle"],
        isOtf: json["isOtf"],
        isDrm: json["isDrm"],
        filesize: json["filesize"],
        attr: Attr.fromJson(json["attr"]),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "name": nameValues.reverse[name],
        "subname": subname,
        "type": type,
        "ext": extValues.reverse[ext],
        "downloadable": downloadable,
        "quality": quality,
        "qualityNumber": qualityNumber,
        "contentLength": contentLength,
        "videoCodec": videoCodecValues.reverse[videoCodec],
        "audioCodec": audioCodec,
        "audio": audio,
        "no_audio": noAudio,
        "itag": itag,
        "isBundle": isBundle,
        "isOtf": isOtf,
        "isDrm": isDrm,
        "filesize": filesize,
        "attr": attr.toJson(),
      };
}

class Attr {
  Attr({
    required this.title,
    required this.attrClass,
  });

  String title;
  Class attrClass;

  factory Attr.fromJson(Map<String, dynamic> json) => Attr(
        title: json["title"],
        attrClass: classValues.map[json["class"]]!,
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "class": classValues.reverse[attrClass],
      };
}

enum Class { EMPTY, NO_AUDIO }

final classValues = EnumValues({"": Class.EMPTY, "no-audio": Class.NO_AUDIO});

enum Ext { MP4, M4_A, WEBM, OPUS }

final extValues = EnumValues(
    {"m4a": Ext.M4_A, "mp4": Ext.MP4, "opus": Ext.OPUS, "webm": Ext.WEBM});

enum Name { MP4, AUDIO_M4_A, WEBM, AUDIO_OPUS }

final nameValues = EnumValues({
  "Audio M4A": Name.AUDIO_M4_A,
  "Audio OPUS": Name.AUDIO_OPUS,
  "MP4": Name.MP4,
  "WEBM": Name.WEBM
});

enum VideoCodec { AVC1, VP9, AV01, NONE }

final videoCodecValues = EnumValues(
    {"av01": VideoCodec.AV01, "avc1": VideoCodec.AVC1, "vp9": VideoCodec.VP9});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
