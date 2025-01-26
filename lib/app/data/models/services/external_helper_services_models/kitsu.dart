import 'dart:convert';

BaseKitsuResponse welcomeFromJson(String str) =>
    BaseKitsuResponse.fromJson(json.decode(str));

String welcomeToJson(BaseKitsuResponse data) => json.encode(data.toJson());

class BaseKitsuResponse {
  BaseKitsuResponse({
    required this.id,
    required this.titles,
  });

  String id;
  Titles titles;

  factory BaseKitsuResponse.fromJson(Map<String, dynamic> json) =>
      BaseKitsuResponse(
        id: json["id"],
        titles: Titles.fromJson(json["titles"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "titles": titles.toJson(),
      };
}

class Titles {
  Titles({
    required this.alternatives,
    required this.original,
    required this.localized,
    required this.canonical,
    required this.romanized,
    required this.translated,
  });

  List<String?> alternatives;
  String? original;
  Localized? localized;
  String? canonical;
  String? romanized;
  String? translated;

  factory Titles.fromJson(Map<String, dynamic> json) => Titles(
        alternatives:
            List<String>.from(json["alternatives"].map((x) => x ?? '')),
        original: json["original"],
        localized: Localized.fromJson(json["localized"]),
        canonical: json["canonical"],
        romanized: json["romanized"],
        translated: json["translated"],
      );

  Map<String, dynamic> toJson() => {
        "alternatives": List<dynamic>.from(alternatives.map((x) => x ?? '')),
        "original": original,
        "localized": localized?.toJson(),
        "canonical": canonical,
        "romanized": romanized,
        "translated": translated,
      };
}

class Localized {
  Localized({
    required this.en,
    required this.enJp,
    required this.enUs,
    required this.jaJp,
  });

  String? en;
  String? enJp;
  String? enUs;
  String? jaJp;

  factory Localized.fromJson(Map<String, dynamic> json) => Localized(
        en: json["en"],
        enJp: json["en_jp"],
        enUs: json["en_us"],
        jaJp: json["ja_jp"],
      );

  Map<String, dynamic> toJson() => {
        "en": en,
        "en_jp": enJp,
        "en_us": enUs,
        "ja_jp": jaJp,
      };
}

KitsuEpisodeData kitsuEpisodeDataFromJson(String str) =>
    KitsuEpisodeData.fromJson(json.decode(str));

String kitsuEpisodeDataToJson(KitsuEpisodeData data) =>
    json.encode(data.toJson());

class KitsuEpisodeData {
  KitsuEpisodeData({
    required this.nodes,
  });

  List<Node?> nodes;

  factory KitsuEpisodeData.fromJson(Map<String, dynamic> json) =>
      KitsuEpisodeData(
        nodes: List<Node?>.from(
            json["nodes"].map((x) => x == null ? null : Node.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nodes": List<dynamic>.from(nodes.map((x) => x?.toJson())),
      };
}

class Node {
  Node({
    required this.number,
    required this.titles,
    required this.description,
    this.thumbnail,
  });

  int number;
  EpisodeTitles titles;
  Description description;
  Thumbnail? thumbnail;

  factory Node.fromJson(Map<String, dynamic> json) => Node(
        number: json["number"],
        titles: EpisodeTitles.fromJson(json["titles"]),
        description: Description.fromJson(json["description"]),
        thumbnail: json["thumbnail"] == null
            ? null
            : Thumbnail.fromJson(json["thumbnail"]),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "titles": titles.toJson(),
        "description": description.toJson(),
        "thumbnail": thumbnail?.toJson(),
      };
}

class Description {
  Description({
    this.en,
  });

  String? en;

  factory Description.fromJson(Map<String, dynamic> json) => Description(
        en: json["en"],
      );

  Map<String, dynamic> toJson() => {
        "en": en,
      };
}

class Thumbnail {
  Thumbnail({
    required this.original,
  });

  Original original;

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
        original: Original.fromJson(json["original"]),
      );

  Map<String, dynamic> toJson() => {
        "original": original.toJson(),
      };
}

class Original {
  Original({
    required this.url,
  });

  String url;

  factory Original.fromJson(Map<String, dynamic> json) => Original(
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
      };
}

class EpisodeTitles {
  EpisodeTitles({
    required this.canonical,
  });

  String canonical;

  factory EpisodeTitles.fromJson(Map<String, dynamic> json) => EpisodeTitles(
        canonical: json["canonical"],
      );

  Map<String, dynamic> toJson() => {
        "canonical": canonical,
      };
}
