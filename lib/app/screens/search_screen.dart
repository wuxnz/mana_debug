import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';
import 'package:mana_debug/app/data/providers/sources/anime/all_anime_source.dart';
import 'package:mana_debug/app/data/providers/sources/anime/gogoanime_source.dart';
import 'package:mana_debug/app/data/providers/sources/anime/zoro_source.dart';
import 'package:mana_debug/app/data/providers/sources/cartoon/kim_cartoon_source.dart';
import 'package:mana_debug/app/data/providers/sources/cartoon/kiss_cartoon_source.dart';
import 'package:mana_debug/app/data/providers/sources/movie/all_movies_for_you.dart';
import 'package:mana_debug/app/widgets/swipers/category_swiper.dart';

import '../data/providers/sources/anime/nine_anime_source.dart';
import '../data/providers/sources/movie/goku_source.dart';
import '../data/providers/sources/movie/soap_today_source.dart';
import '../data/services/source_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<BaseCategoryModel> results = [];

  final TextEditingController _searchController = TextEditingController();

  var animeSources = <SearchPageSourceModel>[
    SearchPageSourceModel(
      sourceId: 'gogoanime',
      sourceName: 'Gogoanime',
      source: GogoAnimeSource,
    ),
    SearchPageSourceModel(
      sourceId: "zoro",
      sourceName: "Zoro",
      source: ZoroSource,
    ),
    SearchPageSourceModel(
      sourceId: "goku",
      sourceName: 'Goku',
      source: GokuSource,
    ),
    SearchPageSourceModel(
        sourceId: 'all-movies-for-you',
        sourceName: 'AllMoviesForYou',
        source: AllMoviesForYouSource),
    SearchPageSourceModel(
        sourceId: 'all-movies-for-you',
        sourceName: 'AllMoviesForYou',
        source: AllMoviesForYouSource),
    SearchPageSourceModel(
      sourceId: 'soap-today',
      sourceName: 'Soap2Day',
      source: SoapTodaySource,
    ),
    SearchPageSourceModel(
      sourceId: "nine-anime",
      sourceName: "9Anime",
      source: NineAnimeSource,
    ),
    // SearchPageSourceModel(
    //   sourceId: "hi-movies",
    //   sourceName: "HiMovies",
    //   source: HiMoviesSource,
    // ),
    SearchPageSourceModel(
      sourceId: "all-anime",
      sourceName: "AllAnime",
      source: AllAnimeSource,
    ),
    // SearchPageSourceModel(
    //   sourceId: "anime-suge",
    //   sourceName: "AnimeSuge",
    //   source: AnimeSugeSource,
    // ),
  ];
  var movieSources = <SearchPageSourceModel>[
    SearchPageSourceModel(
      sourceId: "goku",
      sourceName: 'Goku',
      source: GokuSource,
    ),
    SearchPageSourceModel(
        sourceId: 'all-movies-for-you',
        sourceName: 'AllMoviesForYou',
        source: AllMoviesForYouSource),
    SearchPageSourceModel(
      sourceId: 'soap-today',
      sourceName: 'Soap2Day',
      source: SoapTodaySource,
    ),
    // SearchPageSourceModel(
    //   sourceId: "hi-movies",
    //   sourceName: "HiMovies",
    //   source: HiMoviesSource,
    // ),
  ];
  var tvSources = <SearchPageSourceModel>[
    SearchPageSourceModel(
      sourceId: "goku",
      sourceName: 'Goku',
      source: GokuSource,
    ),
    SearchPageSourceModel(
        sourceId: 'all-movies-for-you',
        sourceName: 'AllMoviesForYou',
        source: AllMoviesForYouSource),
    SearchPageSourceModel(
      sourceId: 'soap-today',
      sourceName: 'Soap2Day',
      source: SoapTodaySource,
    ),
    // SearchPageSourceModel(
    //   sourceId: "hi-movies",
    //   sourceName: "HiMovies",
    //   source: HiMoviesSource,
    // ),
  ];
  var docSources = <SearchPageSourceModel>[
    SearchPageSourceModel(
      sourceId: "goku",
      sourceName: 'Goku',
      source: GokuSource,
    ),
    SearchPageSourceModel(
        sourceId: 'all-movies-for-you',
        sourceName: 'AllMoviesForYou',
        source: AllMoviesForYouSource),
    SearchPageSourceModel(
      sourceId: 'soap-today',
      sourceName: 'Soap2Day',
      source: SoapTodaySource,
    ),
    // SearchPageSourceModel(
    //   sourceId: "hi-movies",
    //   sourceName: "HiMovies",
    //   source: HiMoviesSource,
    // ),
  ];
  var asianSources = <SearchPageSourceModel>[
    SearchPageSourceModel(
      sourceId: "goku",
      sourceName: 'Goku',
      source: GokuSource,
    ),
    SearchPageSourceModel(
        sourceId: 'all-movies-for-you',
        sourceName: 'AllMoviesForYou',
        source: AllMoviesForYouSource),
    SearchPageSourceModel(
      sourceId: 'soap-today',
      sourceName: 'Soap2Day',
      source: SoapTodaySource,
    ),
    // SearchPageSourceModel(
    //   sourceId: "hi-movies",
    //   sourceName: "HiMovies",
    //   source: HiMoviesSource,
    // ),
  ];
  var cartoonSources = <SearchPageSourceModel>[
    SearchPageSourceModel(
      sourceId: "kim-cartoon",
      sourceName: 'KimCartoon',
      source: KimCartoonSource,
    ),
    SearchPageSourceModel(
      sourceId: "goku",
      sourceName: 'Goku',
      source: GokuSource,
    ),
    SearchPageSourceModel(
        sourceId: 'all-movies-for-you',
        sourceName: 'AllMoviesForYou',
        source: AllMoviesForYouSource),
    SearchPageSourceModel(
      sourceId: 'soap-today',
      sourceName: 'Soap2Day',
      source: SoapTodaySource,
    ),
    SearchPageSourceModel(
      sourceId: "the-kiss-cartoon",
      sourceName: "TheKissCartoon",
      source: KissCartoonSource,
    ),
    //   source: FMoviesSource,
    // ),
    // SearchPageSourceModel(
    //   sourceId: "hi-movies",
    //   sourceName: "HiMovies",
    //   source: HiMoviesSource,
    // ),
  ];
  var otherSources = <SearchPageSourceModel>[];

  var allSources = <SearchPageSourceModel>[
    SearchPageSourceModel(
      sourceId: 'gogoanime',
      sourceName: 'Gogoanime',
      source: GogoAnimeSource,
    ),
    SearchPageSourceModel(
      sourceId: "zoro",
      sourceName: "Zoro",
      source: ZoroSource,
    ),
    SearchPageSourceModel(
      sourceId: "goku",
      sourceName: 'Goku',
      source: GokuSource,
    ),
    SearchPageSourceModel(
        sourceId: 'all-movies-for-you',
        sourceName: 'AllMoviesForYou',
        source: AllMoviesForYouSource),
    SearchPageSourceModel(
      sourceId: "kim-cartoon",
      sourceName: 'KimCartoon',
      source: KimCartoonSource,
    ),
    SearchPageSourceModel(
      sourceId: 'soap-today',
      sourceName: 'Soap2Day',
      source: SoapTodaySource,
    ),
    SearchPageSourceModel(
      sourceId: "the-kiss-cartoon",
      sourceName: "TheKissCartoon",
      source: KissCartoonSource,
    ),
    // SearchPageSourceModel(
    //   sourceId: "anime-suge",
    //   sourceName: "AnimeSuge",
    //   source: AnimeSugeSource,
    // ),
    SearchPageSourceModel(
      sourceId: "nine-anime",
      sourceName: "9Anime",
      source: NineAnimeSource,
    ),
    // SearchPageSourceModel(
    //   sourceId: "fmovies",
    //   sourceName: "FMovies",
    //   source: FMoviesSource,
    // ),
    // SearchPageSourceModel(
    //   sourceId: "hi-movies",
    //   sourceName: "HiMovies",
    //   source: HiMoviesSource,
    // ),
    SearchPageSourceModel(
      sourceId: "all-anime",
      sourceName: "AllAnime",
      source: AllAnimeSource,
    ),
  ];

  var sourceCategories = [
    'Anime',
    'Movies',
    'TV Shows',
    'Documentaries',
    'Asian Dramas',
    'Cartoons',
    'Other',
  ];
  var itemStatus = <bool>[
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  var activeSources = <List<SearchPageSourceModel>>[];

  Future<void> runMyIsolate(List<dynamic> args) async {
    var query = args[0];
    var sourceId = args[1];
    BaseCategoryModel? result;
    try {
      result = await (SourceService().detectSource(sourceId).scrapeSearch(query)
          as Future<BaseCategoryModel>);
      //     .timeout(
      //   const Duration(seconds: 20),
      //   onTimeout: () {
      //     return BaseCategoryModel(
      //       categoryName: sourceId,
      //       items: [],
      //       source: null,
      //     );
      //   },
      // );
    } catch (e) {
      result = BaseCategoryModel(
        categoryName: sourceId,
        items: [],
        source: null,
      );
    }
    results.add(result);
    results.sort((a, b) {
      if (a.items.isEmpty && b.items.isNotEmpty) {
        return 1;
      } else if (a.items.isNotEmpty && b.items.isEmpty) {
        return -1;
      } else {
        return 0;
      }
    });
    setState(() {
      results = results;
    });
  }

  Future<void> scrapeActiveSources(String query) async {
    results = [];
    var alreadyAdded = <String>[];
    if (activeSources.isEmpty) {
      for (var element in allSources) {
        Future.microtask(() {
          runMyIsolate([query, element.sourceId]);
        });
      }
    } else {
      for (var i = 0; i < activeSources.length; i++) {
        for (var j = 0; j < activeSources[i].length; j++) {
          var sourceId = activeSources[i][j].sourceId;
          if (alreadyAdded.contains(sourceId)) {
            continue;
          }

          Future.microtask(() {
            runMyIsolate([query, sourceId]);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).padding.top),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            height: MediaQuery.of(context).padding.top,
          )),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 45,
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(Radius.circular(22.5)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(Radius.circular(22.5)),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.background,
                      contentPadding: const EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                        bottom: 22.5,
                      ),
                    ),
                    style: GoogleFonts.roboto(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    onSubmitted: (value) async {
                      await scrapeActiveSources(value);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List<Widget>.generate(
                      sourceCategories.length,
                      (index) => Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Material(
                              color: itemStatus[index]
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surface,
                              child: InkWell(
                                onTap: () {
                                  for (var i = 0; i < 7; i++) {
                                    if (i == index) {
                                      setState(() {
                                        itemStatus[index] = !itemStatus[index];
                                      });
                                      switch (sourceCategories[i]) {
                                        case 'Anime':
                                          if (itemStatus[i]) {
                                            activeSources.add(animeSources);
                                          } else {
                                            activeSources.remove(animeSources);
                                          }
                                          break;
                                        case 'Movies':
                                          if (itemStatus[i]) {
                                            activeSources.add(movieSources);
                                          } else {
                                            activeSources.remove(movieSources);
                                          }
                                          break;
                                        case 'TV Shows':
                                          if (itemStatus[i]) {
                                            activeSources.add(tvSources);
                                          } else {
                                            activeSources.remove(tvSources);
                                          }
                                          break;
                                        case 'Documentaries':
                                          if (itemStatus[i]) {
                                            activeSources.add(docSources);
                                          } else {
                                            activeSources.remove(docSources);
                                          }
                                          break;
                                        case 'Asian Dramas':
                                          if (itemStatus[i]) {
                                            activeSources.add(asianSources);
                                          } else {
                                            activeSources.remove(asianSources);
                                          }
                                          break;
                                        case 'Cartoons':
                                          if (itemStatus[i]) {
                                            activeSources.add(cartoonSources);
                                          } else {
                                            activeSources
                                                .remove(cartoonSources);
                                          }
                                          break;
                                        case 'Other':
                                          if (itemStatus[i]) {
                                            activeSources.add(otherSources);
                                          } else {
                                            activeSources.remove(otherSources);
                                          }
                                          break;
                                      }
                                      debugPrint(
                                          'Active sources: $activeSources');
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: itemStatus[index]
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        itemStatus[index]
                                            ? const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : const SizedBox.shrink(),
                                        Text(
                                          sourceCategories[index],
                                          style: GoogleFonts.roboto(
                                            color: itemStatus[index]
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              children: List<Widget>.generate(
                results.length,
                (index) => CategorySwiper(
                  category: results[index],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
