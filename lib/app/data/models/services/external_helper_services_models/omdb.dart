import 'dart:convert';

OMDBBaseInfoResponse OMDBBaseInfoResponseFromJson(String str) =>
    OMDBBaseInfoResponse.fromJson(json.decode(str));

String OMDBBaseInfoResponseToJson(OMDBBaseInfoResponse data) =>
    json.encode(data.toJson());

class OMDBBaseInfoResponse {
  String title;
  String year;
  String rated;
  String released;
  String runtime;
  String genre;
  String director;
  String writer;
  String actors;
  String plot;
  String language;
  String country;
  String awards;
  String poster;
  List<Rating> ratings;
  String metascore;
  String imdbRating;
  String imdbVotes;
  String imdbId;
  String type;
  String? totalSeasons;
  String response;

  OMDBBaseInfoResponse({
    required this.title,
    required this.year,
    required this.rated,
    required this.released,
    required this.runtime,
    required this.genre,
    required this.director,
    required this.writer,
    required this.actors,
    required this.plot,
    required this.language,
    required this.country,
    required this.awards,
    required this.poster,
    required this.ratings,
    required this.metascore,
    required this.imdbRating,
    required this.imdbVotes,
    required this.imdbId,
    required this.type,
    this.totalSeasons,
    required this.response,
  });

  factory OMDBBaseInfoResponse.fromJson(Map<String, dynamic> json) =>
      OMDBBaseInfoResponse(
        title: json["Title"],
        year: json["Year"],
        rated: json["Rated"],
        released: json["Released"],
        runtime: json["Runtime"],
        genre: json["Genre"],
        director: json["Director"],
        writer: json["Writer"],
        actors: json["Actors"],
        plot: json["Plot"],
        language: json["Language"],
        country: json["Country"],
        awards: json["Awards"],
        poster: json["Poster"],
        ratings:
            List<Rating>.from(json["Ratings"].map((x) => Rating.fromJson(x))),
        metascore: json["Metascore"],
        imdbRating: json["imdbRating"],
        imdbVotes: json["imdbVotes"],
        imdbId: json["imdbID"],
        type: json["Type"],
        totalSeasons: json["totalSeasons"],
        response: json["Response"],
      );

  Map<String, dynamic> toJson() => {
        "Title": title,
        "Year": year,
        "Rated": rated,
        "Released": released,
        "Runtime": runtime,
        "Genre": genre,
        "Director": director,
        "Writer": writer,
        "Actors": actors,
        "Plot": plot,
        "Language": language,
        "Country": country,
        "Awards": awards,
        "Poster": poster,
        "Ratings": List<dynamic>.from(ratings.map((x) => x.toJson())),
        "Metascore": metascore,
        "imdbRating": imdbRating,
        "imdbVotes": imdbVotes,
        "imdbID": imdbId,
        "Type": type,
        "totalSeasons": totalSeasons,
        "Response": response,
      };
}

class Rating {
  String source;
  String value;

  Rating({
    required this.source,
    required this.value,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        source: json["Source"],
        value: json["Value"],
      );

  Map<String, dynamic> toJson() => {
        "Source": source,
        "Value": value,
      };
}

List<OMDBSubtitleSearchResponse> OMDBSubtitleSearchResponseFromJson(
        String str) =>
    List<OMDBSubtitleSearchResponse>.from(
        json.decode(str).map((x) => OMDBSubtitleSearchResponse.fromJson(x)));

String OMDBSubtitleSearchResponseToJson(
        List<OMDBSubtitleSearchResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OMDBSubtitleSearchResponse {
  MatchedBy matchedBy;
  String idSubMovieFile;
  String movieHash;
  String movieByteSize;
  String movieTimeMs;
  String idSubtitleFile;
  String subFileName;
  String subActualCd;
  String subSize;
  String subHash;
  String subLastTs;
  String? subTsGroup;
  String infoReleaseGroup;
  InfoFormat infoFormat;
  InfoOther infoOther;
  String idSubtitle;
  String userId;
  String subLanguageId;
  SubFormat subFormat;
  String subSumCd;
  String subAuthorComment;
  DateTime subAddDate;
  String subBad;
  String subRating;
  String subSumVotes;
  String subDownloadsCnt;
  String movieReleaseName;
  String movieFps;
  String idMovie;
  String idMovieImdb;
  String movieName;
  String? movieNameEng;
  String movieYear;
  String movieImdbRating;
  String subFeatured;
  String? userNickName;
  SubTranslator subTranslator;
  String iso639;
  String languageName;
  String subComments;
  String subHearingImpaired;
  UserRank? userRank;
  String seriesSeason;
  String seriesEpisode;
  MovieKind movieKind;
  String subHd;
  String seriesImdbParent;
  String subEncoding;
  String subAutoTranslation;
  String subForeignPartsOnly;
  String subFromTrusted;
  int? queryCached;
  String? subTsGroupHash;
  String subDownloadLink;
  String zipDownloadLink;
  String subtitlesLink;
  String queryNumber;
  QueryParameters queryParameters;
  double score;

  OMDBSubtitleSearchResponse({
    required this.matchedBy,
    required this.idSubMovieFile,
    required this.movieHash,
    required this.movieByteSize,
    required this.movieTimeMs,
    required this.idSubtitleFile,
    required this.subFileName,
    required this.subActualCd,
    required this.subSize,
    required this.subHash,
    required this.subLastTs,
    this.subTsGroup,
    required this.infoReleaseGroup,
    required this.infoFormat,
    required this.infoOther,
    required this.idSubtitle,
    required this.userId,
    required this.subLanguageId,
    required this.subFormat,
    required this.subSumCd,
    required this.subAuthorComment,
    required this.subAddDate,
    required this.subBad,
    required this.subRating,
    required this.subSumVotes,
    required this.subDownloadsCnt,
    required this.movieReleaseName,
    required this.movieFps,
    required this.idMovie,
    required this.idMovieImdb,
    required this.movieName,
    this.movieNameEng,
    required this.movieYear,
    required this.movieImdbRating,
    required this.subFeatured,
    this.userNickName,
    required this.subTranslator,
    required this.iso639,
    required this.languageName,
    required this.subComments,
    required this.subHearingImpaired,
    this.userRank,
    required this.seriesSeason,
    required this.seriesEpisode,
    required this.movieKind,
    required this.subHd,
    required this.seriesImdbParent,
    required this.subEncoding,
    required this.subAutoTranslation,
    required this.subForeignPartsOnly,
    required this.subFromTrusted,
    this.queryCached,
    this.subTsGroupHash,
    required this.subDownloadLink,
    required this.zipDownloadLink,
    required this.subtitlesLink,
    required this.queryNumber,
    required this.queryParameters,
    required this.score,
  });

  factory OMDBSubtitleSearchResponse.fromJson(Map<String, dynamic> json) =>
      OMDBSubtitleSearchResponse(
        matchedBy: matchedByValues.map[json["MatchedBy"]] ?? MatchedBy.EMPTY,
        idSubMovieFile: json["IDSubMovieFile"],
        movieHash: json["MovieHash"],
        movieByteSize: json["MovieByteSize"],
        movieTimeMs: json["MovieTimeMS"],
        idSubtitleFile: json["IDSubtitleFile"],
        subFileName: json["SubFileName"],
        subActualCd: json["SubActualCD"],
        subSize: json["SubSize"],
        subHash: json["SubHash"],
        subLastTs: json["SubLastTS"],
        subTsGroup: json["SubTSGroup"],
        infoReleaseGroup: json["InfoReleaseGroup"],
        infoFormat:
            infoFormatValues.map[json["InfoFormat"]] ?? InfoFormat.EMPTY,
        infoOther: infoOtherValues.map[json["InfoOther"]] ?? InfoOther.EMPTY,
        idSubtitle: json["IDSubtitle"],
        userId: json["UserID"],
        subLanguageId: json["SubLanguageID"],
        subFormat: subFormatValues.map[json["SubFormat"]] ?? SubFormat.EMPTY,
        subSumCd: json["SubSumCD"],
        subAuthorComment: json["SubAuthorComment"],
        subAddDate: DateTime.parse(json["SubAddDate"]),
        subBad: json["SubBad"],
        subRating: json["SubRating"],
        subSumVotes: json["SubSumVotes"],
        subDownloadsCnt: json["SubDownloadsCnt"],
        movieReleaseName: json["MovieReleaseName"],
        movieFps: json["MovieFPS"],
        idMovie: json["IDMovie"],
        idMovieImdb: json["IDMovieImdb"],
        movieName: json["MovieName"],
        movieNameEng: json["MovieNameEng"],
        movieYear: json["MovieYear"],
        movieImdbRating: json["MovieImdbRating"],
        subFeatured: json["SubFeatured"],
        userNickName: json["UserNickName"],
        subTranslator: subTranslatorValues.map[json["SubTranslator"]] ??
            SubTranslator.EMPTY,
        iso639: json["ISO639"],
        languageName: json["LanguageName"],
        subComments: json["SubComments"],
        subHearingImpaired: json["SubHearingImpaired"],
        userRank: userRankValues.map[json["UserRank"]] ?? UserRank.EMPTY,
        seriesSeason: json["SeriesSeason"],
        seriesEpisode: json["SeriesEpisode"],
        movieKind: movieKindValues.map[json["MovieKind"]] ?? MovieKind.EMPTY,
        subHd: json["SubHD"],
        seriesImdbParent: json["SeriesIMDBParent"],
        subEncoding: json["SubEncoding"],
        subAutoTranslation: json["SubAutoTranslation"],
        subForeignPartsOnly: json["SubForeignPartsOnly"],
        subFromTrusted: json["SubFromTrusted"],
        queryCached: json["QueryCached"],
        subTsGroupHash: json["SubTSGroupHash"],
        subDownloadLink: json["SubDownloadLink"],
        zipDownloadLink: json["ZipDownloadLink"],
        subtitlesLink: json["SubtitlesLink"],
        queryNumber: json["QueryNumber"],
        queryParameters: QueryParameters.fromJson(json["QueryParameters"]),
        score: json["Score"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "MatchedBy": matchedByValues.reverse[matchedBy],
        "IDSubMovieFile": idSubMovieFile,
        "MovieHash": movieHash,
        "MovieByteSize": movieByteSize,
        "MovieTimeMS": movieTimeMs,
        "IDSubtitleFile": idSubtitleFile,
        "SubFileName": subFileName,
        "SubActualCD": subActualCd,
        "SubSize": subSize,
        "SubHash": subHash,
        "SubLastTS": subLastTs,
        "SubTSGroup": subTsGroup,
        "InfoReleaseGroup": infoReleaseGroup,
        "InfoFormat": infoFormatValues.reverse[infoFormat],
        "InfoOther": infoOtherValues.reverse[infoOther],
        "IDSubtitle": idSubtitle,
        "UserID": userId,
        "SubLanguageID": subLanguageId,
        "SubFormat": subFormatValues.reverse[subFormat],
        "SubSumCD": subSumCd,
        "SubAuthorComment": subAuthorComment,
        "SubAddDate": subAddDate.toIso8601String(),
        "SubBad": subBad,
        "SubRating": subRating,
        "SubSumVotes": subSumVotes,
        "SubDownloadsCnt": subDownloadsCnt,
        "MovieReleaseName": movieReleaseName,
        "MovieFPS": movieFps,
        "IDMovie": idMovie,
        "IDMovieImdb": idMovieImdb,
        "MovieName": movieNameValues.reverse[movieName],
        "MovieNameEng": movieNameEng,
        "MovieYear": movieYear,
        "MovieImdbRating": movieImdbRating,
        "SubFeatured": subFeatured,
        "UserNickName": userNickName,
        "SubTranslator": subTranslatorValues.reverse[subTranslator],
        "ISO639": iso639,
        "LanguageName": languageName,
        "SubComments": subComments,
        "SubHearingImpaired": subHearingImpaired,
        "UserRank": userRankValues.reverse[userRank],
        "SeriesSeason": seriesSeason,
        "SeriesEpisode": seriesEpisode,
        "MovieKind": movieKindValues.reverse[movieKind],
        "SubHD": subHd,
        "SeriesIMDBParent": seriesImdbParent,
        "SubEncoding": subEncoding,
        "SubAutoTranslation": subAutoTranslation,
        "SubForeignPartsOnly": subForeignPartsOnly,
        "SubFromTrusted": subFromTrusted,
        "QueryCached": queryCached,
        "SubTSGroupHash": subTsGroupHash,
        "SubDownloadLink": subDownloadLink,
        "ZipDownloadLink": zipDownloadLink,
        "SubtitlesLink": subtitlesLink,
        "QueryNumber": queryNumber,
        "QueryParameters": queryParameters.toJson(),
        "Score": score,
      };
}

enum InfoFormat { WEB_RIP, EMPTY, DVD, HDTV }

final infoFormatValues = EnumValues({
  "DVD": InfoFormat.DVD,
  "": InfoFormat.EMPTY,
  "HDTV": InfoFormat.HDTV,
  "WEBRip": InfoFormat.WEB_RIP
});

enum InfoOther { NETFLIX, EMPTY, WIDE_SCREEN, FANSUB }

final infoOtherValues = EnumValues({
  "": InfoOther.EMPTY,
  "Fansub": InfoOther.FANSUB,
  "Netflix": InfoOther.NETFLIX,
  "WideScreen": InfoOther.WIDE_SCREEN
});

enum MatchedBy { IMDBID, EMPTY }

final matchedByValues = EnumValues({"imdbid": MatchedBy.IMDBID});

enum MovieKind { EPISODE, EMPTY }

final movieKindValues = EnumValues({"episode": MovieKind.EPISODE});

enum MovieName { NARUTO_HE_APPEARS_NARUTO_UZUMAKI }

final movieNameValues = EnumValues({
  "\"Naruto\" He Appears! Naruto Uzumaki":
      MovieName.NARUTO_HE_APPEARS_NARUTO_UZUMAKI
});

class QueryParameters {
  int? episode;
  int? season;
  String imdbid;

  QueryParameters({
    this.episode,
    this.season,
    required this.imdbid,
  });

  factory QueryParameters.fromJson(Map<String, dynamic> json) =>
      QueryParameters(
        episode: json["episode"],
        season: json["season"],
        imdbid: json["imdbid"],
      );

  Map<String, dynamic> toJson() => {
        "episode": episode,
        "season": season,
        "imdbid": imdbid,
      };
}

enum SubFormat { SRT, SSA, SUB, EMPTY }

final subFormatValues = EnumValues(
    {"srt": SubFormat.SRT, "ssa": SubFormat.SSA, "sub": SubFormat.SUB});

enum SubTranslator {
  EMPTY,
  CRUNCHYROLL,
  SUB_TRANSLATOR,
  SUBPACK,
  NOSTALGICZNY,
  ALEX_JULIA
}

final subTranslatorValues = EnumValues({
  "[Alex & Julia]": SubTranslator.ALEX_JULIA,
  "Crunchyroll": SubTranslator.CRUNCHYROLL,
  "": SubTranslator.EMPTY,
  "Nostalgiczny": SubTranslator.NOSTALGICZNY,
  "Subpack": SubTranslator.SUBPACK,
  "احمد الفيفي": SubTranslator.SUB_TRANSLATOR
});

enum UserRank { ADMINISTRATOR, PLATINUM_MEMBER, BRONZE_MEMBER, EMPTY }

final userRankValues = EnumValues({
  "administrator": UserRank.ADMINISTRATOR,
  "bronze member": UserRank.BRONZE_MEMBER,
  "": UserRank.EMPTY,
  "platinum member": UserRank.PLATINUM_MEMBER
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
