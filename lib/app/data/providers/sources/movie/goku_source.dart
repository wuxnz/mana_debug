import 'dart:convert';
import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;

import '../../../../core/utils/network/cloudflare_client.dart';
import '../../../models/sources/base_model.dart';
import '../../../services/source_service.dart';

class GokuSource {
  static const _baseUrl = 'https://goku.sx';
  static final _cloudFlareClient = CloudFlareClient();

  Future<BaseCategoryModel> scrapeSearch(String query) async {
    var response = await http.get(Uri.parse('$_baseUrl/search?keyword=$query'));
    var soup = BeautifulSoup(response.body);
    var searchResultsRaw = soup.findAll('div.item');
    var searchResults = <BaseItemModel>[];
    for (var item in searchResultsRaw) {
      var id = item
              .find('div > div > div > a')
              ?.attributes['href']
              .toString()
              .trim()
              .split('/')
              .last ??
          '';

      var title = item.find('h3.movie-name')?.text.toString().trim() ?? '';

      var imageUrl =
          item.find('a > img')?.attributes['src'].toString().trim() ?? '';

      List<LanguageType> languages = [];

      EpisodeCount episodeCount = EpisodeCount(
        episodeCount: item
                .findAll('div.info-split > div')[1]
                .text
                .toString()
                .contains('/')
            ? int.parse(item
                        .findAll('div.info-split > div')[1]
                        .text
                        .toString()
                        .split('/')[1]
                        .replaceFirst('EPS', '')
                        .trim() ==
                    ''
                ? '0'
                : item
                    .findAll('div.info-split > div')[1]
                    .text
                    .toString()
                    .split('/')[1]
                    .replaceFirst('EPS', '')
                    .trim())
            : 1,
        altEpisodeCount: 0,
      );

      List<Genre> genres = [];

      double rating = double.parse(
          item.find('div.is-rated')!.text.toString().trim().contains("?")
              ? "0.0"
              : item.find('div.is-rated')!.text.toString().trim());

      searchResults.add(BaseItemModel(
        source: BaseSourceModel(
          id: 'goku',
          type: SourceType.multi,
          sourceName: 'Goku',
          baseUrl: _baseUrl,
        ),
        id: id,
        title: title,
        imageUrl: imageUrl,
        languages: languages,
        episodeCount: episodeCount,
        genres: genres,
        rating: rating,
      ));
    }
    return BaseCategoryModel(
      categoryName: 'Goku',
      items: searchResults,
      source: this,
    );
  }

  Future<BaseCategoryModel> getItemsForSlider() async {
    const List<String> alphaWithoutVowels = [
      "b",
      "c",
      "d",
      "f",
      "g",
      "h",
      "j",
      "k",
      "l",
      "m",
      "n",
      "p",
      "q",
      "r",
      "s",
      "t",
      "v",
      "w",
      "x",
      "y",
      "z"
    ];
    const List<String> vowels = ["a", "e", "i", "o", "u"];
    String randomString = alphaWithoutVowels[Random().nextInt(21)];
    final BaseCategoryModel animeList = await scrapeSearch(randomString);
    if (animeList.items.length < 5) {
      while (animeList.items.length < 5) {
        randomString =
            "${vowels[Random().nextInt(5)]}${alphaWithoutVowels[Random().nextInt(21)]}${vowels[Random().nextInt(5)]}";
        var searchResults = await scrapeSearch(randomString);
        animeList.items.addAll(searchResults.items);
      }
    }
    animeList.items.shuffle();
    return BaseCategoryModel(
        categoryName: "Random", items: animeList.items, source: this);
  }

  Future<BaseCategoryModel> scrapeTopCategory(Bs4Element soup) {
    var categoryName = "Featured";
    var categoryItemsRaw = soup.findAll('div.swiper-slide');
    var categoryItems = <BaseItemModel>[];
    for (var item in categoryItemsRaw) {
      var id = item
              .find('.is-item > .item-poster')
              ?.attributes['href']
              .toString()
              .trim()
              .split('/')
              .last ??
          '';

      var title = item.find('a.movie-name')?.text.toString().trim() ?? '';

      var imageUrl = item
              .find('div.movie-thumbnail > a > img')
              ?.attributes['src']
              .toString()
              .trim() ??
          '';

      List<LanguageType> languages = [];
      var coverImageUrl = item
              .find('div.is-item > a.item-poster > img')
              ?.attributes['src']
              .toString()
              .trim() ??
          '';

      double rating = double.parse(
          item.find('div.is-rated')!.text.toString().trim().contains("?")
              ? "0.0"
              : item.find('div.is-rated')!.text.toString().trim());

      categoryItems.add(BaseItemModel(
        source: BaseSourceModel(
          id: 'goku',
          type: SourceType.multi,
          sourceName: 'Goku',
          baseUrl: _baseUrl,
        ),
        id: id,
        title: title,
        imageUrl: imageUrl,
        coverImageUrl: coverImageUrl,
        languages: languages,
        rating: rating,
      ));
    }
    return Future.value(BaseCategoryModel(
      categoryName: categoryName,
      items: categoryItems,
      source: this,
    ));
  }

  Future<List<BaseCategoryModel>> scrapeTrendingMoviesAndTVSeries(
      Bs4Element soup) async {
    var categoryNames = [
      "Trending Movies",
      "Trending TV Series",
    ];
    var categoriesRaw = soup.findAll(
        '.section-row > .container > .section-area > .tab-content > div');
    var categories = <BaseCategoryModel>[];
    var count = 0;
    for (var category in categoriesRaw) {
      var categoryName = categoryNames[count];
      var categoryItemsRaw = category.findAll('div.item');
      var categoryItems = <BaseItemModel>[];
      for (var item in categoryItemsRaw) {
        var id = item
                .find('div > div > div > a')
                ?.attributes['href']
                .toString()
                .trim()
                .split('/')
                .last ??
            '';

        var title = item.find('h3.movie-name')?.text.toString().trim() ?? '';

        var imageUrl =
            item.find('a > img')?.attributes['src'].toString().trim() ?? '';

        List<LanguageType> languages = [];

        EpisodeCount episodeCount = EpisodeCount(
          episodeCount: item
                  .findAll('div.info-split > div')[1]
                  .text
                  .toString()
                  .contains('/')
              ? int.parse(item
                          .findAll('div.info-split > div')[1]
                          .text
                          .toString()
                          .split('/')[1]
                          .replaceFirst('EPS', '')
                          .trim() ==
                      ''
                  ? '0'
                  : item
                      .findAll('div.info-split > div')[1]
                      .text
                      .toString()
                      .split('/')[1]
                      .replaceFirst('EPS', '')
                      .trim())
              : 1,
          altEpisodeCount: 0,
        );

        List<Genre> genres = [];

        double rating = double.parse(
            item.find('div.is-rated')!.text.toString().trim().contains("?")
                ? "0.0"
                : item.find('div.is-rated')!.text.toString().trim());

        categoryItems.add(BaseItemModel(
          source: BaseSourceModel(
            id: 'goku',
            type: SourceType.multi,
            sourceName: 'Goku',
            baseUrl: _baseUrl,
          ),
          id: id,
          title: title,
          imageUrl: imageUrl,
          languages: languages,
          episodeCount: episodeCount,
          genres: genres,
          rating: rating,
        ));
      }

      categories.add(BaseCategoryModel(
        categoryName: categoryName,
        items: categoryItems,
        source: this,
      ));
      count++;
    }
    return categories;
  }

  Future<BaseCategoryModel> scrapeHomeScreenCategory(Bs4Element soup) async {
    var categoryName = soup
            .find('div.section-header > div.is-title > h2.section-name')
            ?.text
            .toString()
            .trim() ??
        '';
    var categoryItemsRaw = soup.findAll('div.item');
    var categoryItems = <BaseItemModel>[];
    for (var item in categoryItemsRaw) {
      var id = item
              .find('div > div > div > a')
              ?.attributes['href']
              .toString()
              .trim()
              .split('/')
              .last ??
          '';

      var title = item.find('h3.movie-name')?.text.toString().trim() ?? '';

      var imageUrl =
          item.find('a > img')?.attributes['src'].toString().trim() ?? '';

      List<LanguageType> languages = [];

      EpisodeCount episodeCount = EpisodeCount(
        episodeCount: item
                .findAll('div.info-split > div')[1]
                .text
                .toString()
                .contains('/')
            ? int.parse(item
                        .findAll('div.info-split > div')[1]
                        .text
                        .toString()
                        .split('/')[1]
                        .replaceFirst('EPS', '')
                        .trim() ==
                    ''
                ? '0'
                : item
                    .findAll('div.info-split > div')[1]
                    .text
                    .toString()
                    .split('/')[1]
                    .replaceFirst('EPS', '')
                    .trim())
            : 1,
        altEpisodeCount: 0,
      );

      List<Genre> genres = [];

      double rating = double.parse(
          item.find('div.is-rated')!.text.toString().trim().contains("?")
              ? "0.0"
              : item.find('div.is-rated')!.text.toString().trim());

      categoryItems.add(BaseItemModel(
        source: BaseSourceModel(
          id: 'goku',
          type: SourceType.multi,
          sourceName: 'Goku',
          baseUrl: _baseUrl,
        ),
        id: id,
        title: title,
        imageUrl: imageUrl,
        languages: languages,
        episodeCount: episodeCount,
        genres: genres,
        rating: rating,
      ));
    }
    return BaseCategoryModel(
      categoryName: categoryName,
      items: categoryItems,
      source: this,
    );
  }

  List<Future<BaseCategoryModel>> getCategories(
      List<Bs4Element> soup, Bs4Element soup2) {
    return [];
  }

  Future<List<BaseCategoryModel>?> scrapeCategories() async {
    var response = await http.get(Uri.parse("$_baseUrl/home"));

    var soup = BeautifulSoup(response.body);
    var categoriesSoup =
        soup.findAll('.section-row > .container > .section-area');

    var categoriesSoup2 = soup.find('.swiper-wrapper')!;

    var topCategory = await scrapeTopCategory(categoriesSoup2);
    var trendings = await scrapeTrendingMoviesAndTVSeries(categoriesSoup[0]);
    var otherCategories = await Future.wait(
        categoriesSoup.sublist(1).map((e) => scrapeHomeScreenCategory(e)));
    var results = [topCategory, ...trendings, ...otherCategories];

    return results;
  }

  Future<List<RawVideoSourceInfoModel>> getVideoSources(
      String episodeId) async {
    var response = await http
        .get(Uri.parse("$_baseUrl/ajax/movie/episode/servers/$episodeId"));

    var soup = BeautifulSoup(response.body);
    var sourcesRaw = soup.findAll('a.dropdown-item');

    var sources = <RawVideoSourceInfoModel>[];
    for (var source in sourcesRaw) {
      var sourceId = source.text.toString().trim().toLowerCase();

      var sourceName = source.text.toString().trim();
      var sourceDataId = source.attributes['data-id'].toString().trim();
      var sourceDataResponse = await http.get(Uri.parse(
          "$_baseUrl/ajax/movie/episode/server/sources/$sourceDataId"));

      var sourceData = jsonDecode(sourceDataResponse.body);
      var embedUrl = sourceData['data']['link'];

      var baseUrl = Uri.parse(embedUrl).origin;

      var extractor = SourceService().detectExtractor(sourceId);

      sources.add(RawVideoSourceInfoModel(
        sourceId: sourceId,
        sourceName: sourceName,
        baseUrl: baseUrl,
        embedUrl: embedUrl,
        extractor: extractor,
      ));
    }

    return sources;
  }

  Future<BaseDetailedItemModel> scrapeDetails(String id) async {
    var newId = id.startsWith('/') ? id : '/$id';

    var newIdNumber = newId.split('-').last;
    var response = await _cloudFlareClient.get("$_baseUrl/watch-series$newId/",
        finalUrlPattern: RegExp(r'^https://goku.sx/watch-[a-z]+/.*/\d+'));

    var soup = BeautifulSoup(response.data);
    var infoRaw = soup.findAll('div.section-area');
    var title = infoRaw[0].find('h3.movie-name')?.text.toString().trim() ?? '';
    var imageUrl = infoRaw[0]
            .find('div.movie-thumbnail > img')
            ?.attributes['src']
            .toString()
            .trim() ??
        '';
    var languages = <LanguageType>[];
    var coverImageUrl =
        infoRaw[0].find('img.is-cover')?.attributes['src'].toString().trim() ??
            '';
    EpisodeCount episodeCount;
    List<Genre> genres = [];
    var genresRaw = infoRaw[0]
            .find('div.value')
            ?.findAll('a')
            .map((e) => Genre(
                id: e.attributes['href'].toString().trim(),
                name: e.text.toString().trim()))
            .toList() ??
        [];
    genres.addAll(genresRaw);
    var voteInfoResponse =
        await _cloudFlareClient.get("$_baseUrl/ajax/vote/info/$newIdNumber");

    var voteInfoSoup = BeautifulSoup(
        jsonDecode(BeautifulSoup(voteInfoResponse.data).body!.text)['html']);
    var rating = double.parse(
        voteInfoSoup.find('.is-score')!.text.toString().trim().contains("?")
            ? "0.0"
            : voteInfoSoup.find('.is-score')!.text.toString().trim());
    var watchId = infoRaw[0]
            .find('a.button-play')
            ?.attributes['href']
            .toString()
            .trim() ??
        '';
    var type = watchId.contains('/watch-movie/') ? ItemType.movie : ItemType.tv;
    var status = AiringStatus.unknown;
    var synopsis = infoRaw[0]
            .find('div.text-cut')
            ?.text
            .toString()
            .trim()
            .replaceFirst(
                '...',
                infoRaw[0]
                    .findAll('div.dropdown-text')[1]
                    .text
                    .toString()
                    .trim()) ??
        '';
    List<DetailedEpisodeModel> episodes = [];
    var seasonsResponse = await _cloudFlareClient
        .get("$_baseUrl/ajax/movie/seasons/$newIdNumber");

    var seasonsSoup = BeautifulSoup(seasonsResponse.data);
    var seasonsIds = seasonsSoup
        .findAll('div.episodes')
        .map((e) => e.attributes['id'].toString().trim().split('-').last)
        .toList();

    int seasonNumber = 1;
    int episodeNumber = 1;
    int relativeEpisodeNumber = 1;

    if (seasonsIds.isNotEmpty) {
      for (var seasonId in seasonsIds) {
        var episodesResponse = await _cloudFlareClient
            .get("$_baseUrl/ajax/movie/season/episodes/$seasonId");

        var episodesSoup = BeautifulSoup(episodesResponse.data);
        var episodesRaw = episodesSoup.findAll('div.item > a');
        for (var episode in episodesRaw) {
          var episodeId =
              episode.attributes['href'].toString().trim().split('/').last;
          var episodeTitle =
              episode.text.toString().trim().split(':').last.trim();
          var episodeUrl =
              "$_baseUrl${episode.attributes['href'].toString().trim()}";
          episodes.add(DetailedEpisodeModel(
            episodeId: episodeId,
            episodeName: episodeTitle,
            episodeUrl: episodeUrl,
            episodeNumber: episodeNumber.toString(),
            seasonNumber: seasonNumber,
            relativeEpisodeNumber: relativeEpisodeNumber,
          ));
          episodeNumber++;
          relativeEpisodeNumber++;
        }
        seasonNumber++;
        relativeEpisodeNumber = 1;
      }
    } else {
      var movieResponse = await _cloudFlareClient.get("$_baseUrl$watchId");

      var moviePageResponse =
          await _cloudFlareClient.get("$_baseUrl/watch-movie/$newId");
      var moviePageSoup = BeautifulSoup(moviePageResponse.data);

      var movieFinalId = moviePageSoup
          .find('#href-movie')!
          .attributes['value']
          .toString()
          .trim()
          .split('/')
          .last;

      episodes.add(DetailedEpisodeModel(
        episodeId: movieFinalId,
        episodeName: title,
        episodeUrl: "$_baseUrl$watchId",
        episodeNumber: "1",
      ));
    }
    episodeCount = EpisodeCount(
      episodeCount: episodes.length,
      altEpisodeCount: 0,
    );
    var relatedItems = <BaseItemModel>[];
    for (var relatedItem
        in infoRaw.last.findAll('div.section-items > div.item')) {
      var id = relatedItem
              .find('div > div > div > a')
              ?.attributes['href']
              .toString()
              .trim()
              .split('/')
              .last ??
          '';
      var title =
          relatedItem.find('h3.movie-name')?.text.toString().trim() ?? '';

      var imageUrl =
          relatedItem.find('a > img')?.attributes['src'].toString().trim() ??
              '';

      List<LanguageType> languages = [];

      EpisodeCount episodeCount = EpisodeCount(
        episodeCount: relatedItem
                .findAll('div.info-split > div')[1]
                .text
                .toString()
                .contains('/')
            ? int.parse(relatedItem
                        .findAll('div.info-split > div')[1]
                        .text
                        .toString()
                        .split('/')[1]
                        .replaceFirst('EPS', '')
                        .trim() ==
                    ''
                ? '0'
                : relatedItem
                    .findAll('div.info-split > div')[1]
                    .text
                    .toString()
                    .split('/')[1]
                    .replaceFirst('EPS', '')
                    .trim())
            : 1,
        altEpisodeCount: 0,
      );

      List<Genre> genres = [];

      double rating = double.parse(
          relatedItem.find('div.is-rated')!.text.toString().trim().contains("?")
              ? "0.0"
              : relatedItem.find('div.is-rated')!.text.toString().trim());

      relatedItems.add(BaseItemModel(
        source: BaseSourceModel(
          id: 'goku',
          type: SourceType.multi,
          sourceName: 'Goku',
          baseUrl: _baseUrl,
        ),
        id: id,
        title: title,
        imageUrl: imageUrl,
        languages: languages,
        episodeCount: episodeCount,
        genres: genres,
        rating: rating,
      ));
    }
    return BaseDetailedItemModel(
      source: BaseSourceModel(
        id: 'goku',
        type: SourceType.multi,
        sourceName: 'Goku',
        baseUrl: _baseUrl,
      ),
      id: newId,
      title: title,
      imageUrl: imageUrl,
      languages: languages,
      episodeCount: episodeCount,
      genres: genres,
      rating: rating,
      coverImageUrl: coverImageUrl,
      type: type,
      status: status,
      synopsis: synopsis,
      episodes: episodes,
      relatedItems: relatedItems,
    );
  }
}
