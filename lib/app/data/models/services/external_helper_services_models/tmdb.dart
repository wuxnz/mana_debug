import 'dart:convert';

TMDBSearchResponseModel tmdbSearchResponseModelFromJson(String str) =>
    TMDBSearchResponseModel.fromJson(json.decode(str));

String tmdbSearchResponseModelToJson(TMDBSearchResponseModel data) =>
    json.encode(data.toJson());

class TMDBSearchResponseModel {
  TMDBSearchResponseModel({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  int page;
  List<Result> results;
  int totalPages;
  int totalResults;

  factory TMDBSearchResponseModel.fromJson(Map<String, dynamic> json) =>
      TMDBSearchResponseModel(
        page: json["page"],
        results:
            List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "total_pages": totalPages,
        "total_results": totalResults,
      };
}

class Result {
  Result({
    required this.adult,
    this.backdropPath,
    required this.id,
    this.title,
    this.originalLanguage,
    this.originalTitle,
    this.overview,
    this.posterPath,
    required this.mediaType,
    this.genreIds,
    required this.popularity,
    this.releaseDate,
    this.video,
    this.voteAverage,
    this.voteCount,
    this.name,
    this.originalName,
    this.gender,
    this.knownForDepartment,
    this.profilePath,
    this.knownFor,
    this.firstAirDate,
    this.originCountry,
  });

  bool adult;
  String? backdropPath;
  int id;
  String? title;
  String? originalLanguage;
  String? originalTitle;
  String? overview;
  String? posterPath;
  MediaType mediaType;
  List<int>? genreIds;
  double popularity;
  String? releaseDate;
  bool? video;
  double? voteAverage;
  int? voteCount;
  String? name;
  String? originalName;
  int? gender;
  String? knownForDepartment;
  dynamic profilePath;
  List<KnownFor>? knownFor;
  String? firstAirDate;
  List<String>? originCountry;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        adult: json["adult"],
        backdropPath: json["backdrop_path"],
        id: json["id"],
        title: json["title"],
        originalLanguage: json["original_language"],
        originalTitle: json["original_title"],
        overview: json["overview"],
        posterPath: json["poster_path"],
        mediaType: mediaTypeValues.map[json["media_type"]]!,
        genreIds: json["genre_ids"] == null
            ? []
            : List<int>.from(json["genre_ids"]!.map((x) => x)),
        popularity: json["popularity"]?.toDouble(),
        releaseDate: json["release_date"],
        video: json["video"],
        voteAverage: json["vote_average"]?.toDouble(),
        voteCount: json["vote_count"],
        name: json["name"],
        originalName: json["original_name"],
        gender: json["gender"],
        knownForDepartment: json["known_for_department"],
        profilePath: json["profile_path"],
        knownFor: json["known_for"] == null
            ? []
            : List<KnownFor>.from(
                json["known_for"]!.map((x) => KnownFor.fromJson(x))),
        firstAirDate: json["first_air_date"],
        originCountry: json["origin_country"] == null
            ? []
            : List<String>.from(json["origin_country"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "id": id,
        "title": title,
        "original_language": originalLanguage,
        "original_title": originalTitle,
        "overview": overview,
        "poster_path": posterPath,
        "media_type": mediaTypeValues.reverse[mediaType],
        "genre_ids":
            genreIds == null ? [] : List<dynamic>.from(genreIds!.map((x) => x)),
        "popularity": popularity,
        "release_date": releaseDate,
        "video": video,
        "vote_average": voteAverage,
        "vote_count": voteCount,
        "name": name,
        "original_name": originalName,
        "gender": gender,
        "known_for_department": knownForDepartment,
        "profile_path": profilePath,
        "known_for": knownFor == null
            ? []
            : List<dynamic>.from(knownFor!.map((x) => x.toJson())),
        "first_air_date": firstAirDate,
        "origin_country": originCountry == null
            ? []
            : List<dynamic>.from(originCountry!.map((x) => x)),
      };
}

class KnownFor {
  KnownFor({
    required this.adult,
    this.backdropPath,
    required this.id,
    required this.title,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.mediaType,
    required this.genreIds,
    required this.popularity,
    required this.releaseDate,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  bool adult;
  dynamic backdropPath;
  int id;
  String title;
  String originalLanguage;
  String originalTitle;
  String overview;
  String posterPath;
  MediaType mediaType;
  List<int> genreIds;
  double popularity;
  DateTime releaseDate;
  bool video;
  double voteAverage;
  int voteCount;

  factory KnownFor.fromJson(Map<String, dynamic> json) => KnownFor(
        adult: json["adult"],
        backdropPath: json["backdrop_path"],
        id: json["id"],
        title: json["title"],
        originalLanguage: json["original_language"],
        originalTitle: json["original_title"],
        overview: json["overview"],
        posterPath: json["poster_path"],
        mediaType: mediaTypeValues.map[json["media_type"]]!,
        genreIds: List<int>.from(json["genre_ids"].map((x) => x)),
        popularity: json["popularity"]?.toDouble(),
        releaseDate: DateTime.parse(json["release_date"]),
        video: json["video"],
        voteAverage: json["vote_average"],
        voteCount: json["vote_count"],
      );

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "id": id,
        "title": title,
        "original_language": originalLanguage,
        "original_title": originalTitle,
        "overview": overview,
        "poster_path": posterPath,
        "media_type": mediaTypeValues.reverse[mediaType],
        "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
        "popularity": popularity,
        "release_date":
            "${releaseDate.year.toString().padLeft(4, '0')}-${releaseDate.month.toString().padLeft(2, '0')}-${releaseDate.day.toString().padLeft(2, '0')}",
        "video": video,
        "vote_average": voteAverage,
        "vote_count": voteCount,
      };
}

enum MediaType { MOVIE, PERSON, TV }

final mediaTypeValues = EnumValues(
    {"movie": MediaType.MOVIE, "person": MediaType.PERSON, "tv": MediaType.TV});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

TMDBDetailsResponseModel tmdbDetailsResponseModelFromJson(String str) =>
    TMDBDetailsResponseModel.fromJson(json.decode(str));

String tmdbDetailsResponseModelToJson(TMDBDetailsResponseModel data) =>
    json.encode(data.toJson());

class TMDBDetailsResponseModel {
  TMDBDetailsResponseModel({
    required this.adult,
    required this.backdropPath,
    required this.createdBy,
    required this.episodeRunTime,
    required this.firstAirDate,
    required this.genres,
    required this.homepage,
    required this.id,
    required this.inProduction,
    required this.languages,
    this.lastAirDate,
    this.lastEpisodeToAir,
    required this.name,
    this.nextEpisodeToAir,
    required this.networks,
    required this.numberOfEpisodes,
    required this.numberOfSeasons,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalName,
    required this.overview,
    required this.popularity,
    this.posterPath,
    required this.productionCompanies,
    required this.productionCountries,
    required this.seasons,
    required this.spokenLanguages,
    required this.status,
    required this.tagline,
    required this.type,
    required this.voteAverage,
    required this.voteCount,
  });

  bool adult;
  String backdropPath;
  List<CreatedBy>? createdBy;
  List<int> episodeRunTime;
  DateTime firstAirDate;
  List<Genre> genres;
  String homepage;
  int id;
  bool inProduction;
  List<String> languages;
  DateTime? lastAirDate;
  TEpisodeToAir? lastEpisodeToAir;
  String name;
  TEpisodeToAir? nextEpisodeToAir;
  List<Network> networks;
  int numberOfEpisodes;
  int numberOfSeasons;
  List<String> originCountry;
  String originalLanguage;
  String originalName;
  String overview;
  double popularity;
  String? posterPath;
  List<Network> productionCompanies;
  List<ProductionCountry> productionCountries;
  List<Season> seasons;
  List<SpokenLanguage> spokenLanguages;
  String status;
  String tagline;
  String type;
  double voteAverage;
  int voteCount;

  factory TMDBDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      TMDBDetailsResponseModel(
        adult: json["adult"],
        backdropPath: json["backdrop_path"],
        createdBy: json["created_by"] == null
            ? null
            : List<CreatedBy>.from(
                json["created_by"].map((x) => CreatedBy.fromJson(x))),
        episodeRunTime: List<int>.from(json["episode_run_time"].map((x) => x)),
        firstAirDate: json["first_air_date"] == ""
            ? DateTime.now()
            : DateTime.parse(json["first_air_date"]),
        genres: List<Genre>.from(json["genres"].map((x) => Genre.fromJson(x))),
        homepage: json["homepage"],
        id: json["id"],
        inProduction: json["in_production"],
        languages: List<String>.from(json["languages"].map((x) => x)),
        lastAirDate: json["last_air_date"] == ""
            ? DateTime.now()
            : DateTime.parse(json["last_air_date"]),
        lastEpisodeToAir: json["last_episode_to_air"] == null
            ? null
            : TEpisodeToAir.fromJson(json["last_episode_to_air"]),
        name: json["name"],
        nextEpisodeToAir: json["next_episode_to_air"] == null
            ? null
            : TEpisodeToAir.fromJson(json["next_episode_to_air"]),
        networks: List<Network>.from(
            json["networks"].map((x) => Network.fromJson(x))),
        numberOfEpisodes: json["number_of_episodes"],
        numberOfSeasons: json["number_of_seasons"],
        originCountry: List<String>.from(json["origin_country"].map((x) => x)),
        originalLanguage: json["original_language"],
        originalName: json["original_name"],
        overview: json["overview"],
        popularity: json["popularity"]?.toDouble(),
        posterPath: json["poster_path"],
        productionCompanies: List<Network>.from(
            json["production_companies"].map((x) => Network.fromJson(x))),
        productionCountries: List<ProductionCountry>.from(
            json["production_countries"]
                .map((x) => ProductionCountry.fromJson(x))),
        seasons:
            List<Season>.from(json["seasons"].map((x) => Season.fromJson(x))),
        spokenLanguages: List<SpokenLanguage>.from(
            json["spoken_languages"].map((x) => SpokenLanguage.fromJson(x))),
        status: json["status"],
        tagline: json["tagline"],
        type: json["type"],
        voteAverage: json["vote_average"]?.toDouble(),
        voteCount: json["vote_count"],
      );

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "created_by": createdBy == null
            ? null
            : List<dynamic>.from(createdBy!.map((x) => x.toJson())),
        "episode_run_time": List<dynamic>.from(episodeRunTime.map((x) => x)),
        "first_air_date":
            "${firstAirDate.year.toString().padLeft(4, '0')}-${firstAirDate.month.toString().padLeft(2, '0')}-${firstAirDate.day.toString().padLeft(2, '0')}",
        "genres": List<dynamic>.from(genres.map((x) => x.toJson())),
        "homepage": homepage,
        "id": id,
        "in_production": inProduction,
        "languages": List<dynamic>.from(languages.map((x) => x)),
        "last_air_date": lastAirDate == null
            ? null
            : "${lastAirDate!.year.toString().padLeft(4, '0')}-${lastAirDate!.month.toString().padLeft(2, '0')}-${lastAirDate!.day.toString().padLeft(2, '0')}",
        "last_episode_to_air": lastEpisodeToAir?.toJson(),
        "name": name,
        "next_episode_to_air": nextEpisodeToAir?.toJson(),
        "networks": List<dynamic>.from(networks.map((x) => x.toJson())),
        "number_of_episodes": numberOfEpisodes,
        "number_of_seasons": numberOfSeasons,
        "origin_country": List<dynamic>.from(originCountry.map((x) => x)),
        "original_language": originalLanguage,
        "original_name": originalName,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "production_companies":
            List<dynamic>.from(productionCompanies.map((x) => x.toJson())),
        "production_countries":
            List<dynamic>.from(productionCountries.map((x) => x.toJson())),
        "seasons": List<dynamic>.from(seasons.map((x) => x.toJson())),
        "spoken_languages":
            List<dynamic>.from(spokenLanguages.map((x) => x.toJson())),
        "status": status,
        "tagline": tagline,
        "type": type,
        "vote_average": voteAverage,
        "vote_count": voteCount,
      };
}

class CreatedBy {
  CreatedBy({
    required this.id,
    required this.creditId,
    required this.name,
    required this.gender,
    this.profilePath,
  });

  int id;
  String creditId;
  String name;
  int gender;
  String? profilePath;

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: json["id"],
        creditId: json["credit_id"],
        name: json["name"],
        gender: json["gender"],
        profilePath: json["profile_path"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "credit_id": creditId,
        "name": name,
        "gender": gender,
        "profile_path": profilePath,
      };
}

class Genre {
  Genre({
    required this.id,
    required this.name,
  });

  int id;
  String name;

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class TEpisodeToAir {
  TEpisodeToAir({
    required this.id,
    required this.name,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.airDate,
    required this.episodeNumber,
    required this.productionCode,
    this.runtime,
    required this.seasonNumber,
    required this.showId,
    this.stillPath,
  });

  int id;
  String name;
  String overview;
  double voteAverage;
  int voteCount;
  DateTime? airDate;
  int episodeNumber;
  String productionCode;
  dynamic runtime;
  int seasonNumber;
  int showId;
  String? stillPath;

  factory TEpisodeToAir.fromJson(Map<String, dynamic> json) => TEpisodeToAir(
        id: json["id"],
        name: json["name"],
        overview: json["overview"],
        voteAverage: json["vote_average"],
        voteCount: json["vote_count"],
        airDate: DateTime.parse(json["air_date"]),
        episodeNumber: json["episode_number"],
        productionCode: json["production_code"],
        runtime: json["runtime"],
        seasonNumber: json["season_number"],
        showId: json["show_id"],
        stillPath: json["still_path"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "overview": overview,
        "vote_average": voteAverage,
        "vote_count": voteCount,
        "air_date": airDate == null
            ? null
            : "${airDate?.year.toString().padLeft(4, '0') ?? '0000'}-${airDate?.month.toString().padLeft(2, '0') ?? '00'}-${airDate?.day.toString().padLeft(2, '0') ?? '00'}",
        "episode_number": episodeNumber,
        "production_code": productionCode,
        "runtime": runtime,
        "season_number": seasonNumber,
        "show_id": showId,
        "still_path": stillPath,
      };
}

class Network {
  Network({
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
  });

  int id;
  String? logoPath;
  String name;
  String originCountry;

  factory Network.fromJson(Map<String, dynamic> json) => Network(
        id: json["id"],
        logoPath: json["logo_path"],
        name: json["name"],
        originCountry: json["origin_country"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "logo_path": logoPath,
        "name": name,
        "origin_country": originCountry,
      };
}

class ProductionCountry {
  ProductionCountry({
    required this.iso31661,
    required this.name,
  });

  String iso31661;
  String name;

  factory ProductionCountry.fromJson(Map<String, dynamic> json) =>
      ProductionCountry(
        iso31661: json["iso_3166_1"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "iso_3166_1": iso31661,
        "name": name,
      };
}

class Season {
  Season({
    this.airDate,
    required this.episodeCount,
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    required this.seasonNumber,
  });

  DateTime? airDate;
  int episodeCount;
  int id;
  String name;
  String overview;
  String? posterPath;
  int seasonNumber;

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        airDate:
            json["air_date"] == null ? null : DateTime.parse(json["air_date"]),
        episodeCount: json["episode_count"],
        id: json["id"],
        name: json["name"],
        overview: json["overview"],
        posterPath: json["poster_path"],
        seasonNumber: json["season_number"],
      );

  Map<String, dynamic> toJson() => {
        "air_date": airDate == null
            ? null
            : "${airDate?.year.toString().padLeft(4, '0') ?? ''}-${airDate?.month.toString().padLeft(2, '0') ?? ''}-${airDate?.day.toString().padLeft(2, '0') ?? ''}",
        "episode_count": episodeCount,
        "id": id,
        "name": name,
        "overview": overview,
        "poster_path": posterPath,
        "season_number": seasonNumber,
      };
}

class SpokenLanguage {
  SpokenLanguage({
    required this.englishName,
    required this.iso6391,
    required this.name,
  });

  String englishName;
  String iso6391;
  String name;

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) => SpokenLanguage(
        englishName: json["english_name"],
        iso6391: json["iso_639_1"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "english_name": englishName,
        "iso_639_1": iso6391,
        "name": name,
      };
}

TMDBSeasonResponseModel tmdbSeasonResponseModelFromJson(String str) =>
    TMDBSeasonResponseModel.fromJson(json.decode(str));

String tmdbSeasonResponseModelToJson(TMDBSeasonResponseModel data) =>
    json.encode(data.toJson());

class TMDBSeasonResponseModel {
  String id;
  DateTime? airDate;
  List<Episode> episodes;
  String name;
  String overview;
  int welcomeId;
  String posterPath;
  int seasonNumber;

  TMDBSeasonResponseModel({
    required this.id,
    this.airDate,
    required this.episodes,
    required this.name,
    required this.overview,
    required this.welcomeId,
    required this.posterPath,
    required this.seasonNumber,
  });

  factory TMDBSeasonResponseModel.fromJson(Map<String, dynamic> json) =>
      TMDBSeasonResponseModel(
        id: json["_id"],
        airDate:
            json["air_date"] == null ? null : DateTime.parse(json["air_date"]),
        episodes: List<Episode>.from(
            json["episodes"].map((x) => Episode.fromJson(x))),
        name: json["name"],
        overview: json["overview"],
        welcomeId: json["id"],
        posterPath: json["poster_path"],
        seasonNumber: json["season_number"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "air_date": airDate == null
            ? null
            : "${airDate!.year.toString().padLeft(4, '0')}-${airDate!.month.toString().padLeft(2, '0')}-${airDate!.day.toString().padLeft(2, '0')}",
        "episodes": List<dynamic>.from(episodes.map((x) => x.toJson())),
        "name": name,
        "overview": overview,
        "id": welcomeId,
        "poster_path": posterPath,
        "season_number": seasonNumber,
      };
}

class Episode {
  DateTime? airDate;
  int episodeNumber;
  int id;
  String name;
  String overview;
  String productionCode;
  int? runtime;
  int seasonNumber;
  int showId;
  String? stillPath;
  double voteAverage;
  int voteCount;
  List<Crew> crew;
  List<Crew> guestStars;

  Episode({
    this.airDate,
    required this.episodeNumber,
    required this.id,
    required this.name,
    required this.overview,
    required this.productionCode,
    this.runtime,
    required this.seasonNumber,
    required this.showId,
    this.stillPath,
    required this.voteAverage,
    required this.voteCount,
    required this.crew,
    required this.guestStars,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        airDate:
            json["air_date"] == null ? null : DateTime.parse(json["air_date"]),
        episodeNumber: json["episode_number"],
        id: json["id"],
        name: json["name"],
        overview: json["overview"],
        productionCode: json["production_code"],
        runtime: json["runtime"],
        seasonNumber: json["season_number"],
        showId: json["show_id"],
        stillPath: json["still_path"],
        voteAverage: json["vote_average"]?.toDouble(),
        voteCount: json["vote_count"],
        crew: List<Crew>.from(json["crew"].map((x) => Crew.fromJson(x))),
        guestStars:
            List<Crew>.from(json["guest_stars"].map((x) => Crew.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "air_date": airDate == null
            ? null
            : "${airDate!.year.toString().padLeft(4, '0')}-${airDate!.month.toString().padLeft(2, '0')}-${airDate!.day.toString().padLeft(2, '0')}",
        "episode_number": episodeNumber,
        "id": id,
        "name": name,
        "overview": overview,
        "production_code": productionCode,
        "runtime": runtime,
        "season_number": seasonNumber,
        "show_id": showId,
        "still_path": stillPath,
        "vote_average": voteAverage,
        "vote_count": voteCount,
        "crew": List<dynamic>.from(crew.map((x) => x.toJson())),
        "guest_stars": List<dynamic>.from(guestStars.map((x) => x.toJson())),
      };
}

class Crew {
  Job? job;
  Department? department;
  String creditId;
  bool adult;
  int gender;
  int id;
  Department knownForDepartment;
  String name;
  String originalName;
  double popularity;
  String? profilePath;
  String? character;
  int? order;

  Crew({
    this.job,
    this.department,
    required this.creditId,
    required this.adult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    this.profilePath,
    this.character,
    this.order,
  });

  factory Crew.fromJson(Map<String, dynamic> json) => Crew(
        job: jobValues.map[json["job"]] ?? Job.ANIMATION_DIRECTOR,
        department:
            departmentValues.map[json["department"]] ?? Department.ACTING,
        creditId: json["credit_id"],
        adult: json["adult"],
        gender: json["gender"],
        id: json["id"],
        knownForDepartment:
            departmentValues.map[json["known_for_department"]] ??
                Department.ACTING,
        name: json["name"],
        originalName: json["original_name"],
        popularity: json["popularity"]?.toDouble(),
        profilePath: json["profile_path"],
        character: json["character"],
        order: json["order"],
      );

  Map<String, dynamic> toJson() => {
        "job": jobValues.reverse[job],
        "department": departmentValues.reverse[department],
        "credit_id": creditId,
        "adult": adult,
        "gender": gender,
        "id": id,
        "known_for_department": departmentValues.reverse[knownForDepartment],
        "name": name,
        "original_name": originalName,
        "popularity": popularity,
        "profile_path": profilePath,
        "character": character,
        "order": order,
      };
}

enum Department { DIRECTING, VISUAL_EFFECTS, WRITING, ART, ACTING }

final departmentValues = SeasonEnumValues({
  "Acting": Department.ACTING,
  "Art": Department.ART,
  "Directing": Department.DIRECTING,
  "Visual Effects": Department.VISUAL_EFFECTS,
  "Writing": Department.WRITING
});

enum Job {
  DIRECTOR,
  KEY_ANIMATION,
  WRITER,
  ANIMATION_DIRECTOR,
  STORYBOARD_ARTIST
}

final jobValues = SeasonEnumValues({
  "Animation Director": Job.ANIMATION_DIRECTOR,
  "Director": Job.DIRECTOR,
  "Key Animation": Job.KEY_ANIMATION,
  "Storyboard Artist": Job.STORYBOARD_ARTIST,
  "Writer": Job.WRITER
});

class SeasonEnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  SeasonEnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
