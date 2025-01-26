import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/cubit/active_source_cubit/active_source_cubit.dart';
import '../../data/models/sources/base_model.dart';

class SourceListItem extends StatelessWidget {
  final BaseSourceModel source;
  final bool isActive;
  final Function(BaseSourceModel source) changeSource;

  const SourceListItem({
    super.key,
    required this.source,
    required this.isActive,
    required this.changeSource,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        changeSource(source);
        Navigator.pop(context);
      },
      trailing: isActive
          ? const Icon(
              Icons.check,
              color: Colors.green,
            )
          : null,
      title: Text(
        source.sourceName,
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class SourceMenu extends StatefulWidget {
  const SourceMenu({super.key});

  @override
  State<SourceMenu> createState() => _SourceMenuState();
}

class _SourceMenuState extends State<SourceMenu> {
  var animeSources = <BaseSourceModel>[
    BaseSourceModel(
        id: 'gogoanime',
        type: SourceType.anime,
        sourceName: 'Gogoanime',
        baseUrl: 'https://gogoanime.tel'),
    BaseSourceModel(
        id: "zoro",
        type: SourceType.anime,
        sourceName: "Zoro",
        baseUrl: "https://zoro.to"),
    BaseSourceModel(
        id: 'all-anime',
        type: SourceType.anime,
        sourceName: "AllAnime",
        baseUrl: 'https://allanime.to'),
    BaseSourceModel(
        id: 'nine-anime',
        type: SourceType.anime,
        sourceName: "9anime",
        baseUrl: "https://9anime.to"),
    // BaseSourceModel(
    //     id: 'anime-suge',
    //     type: SourceType.anime,
    //     sourceName: "AnimeSuge",
    //     baseUrl: "https://animesuge.to"),
  ];
  var movieSources = <BaseSourceModel>[
    BaseSourceModel(
        id: "goku",
        type: SourceType.multi,
        sourceName: 'Goku',
        baseUrl: 'https://goku.to'),
    BaseSourceModel(
        id: 'all-movies-for-you',
        type: SourceType.multi,
        sourceName: 'AllMoviesForYou',
        baseUrl: 'https://allmoviesforyou.net'),
    BaseSourceModel(
        id: 'soap-today',
        type: SourceType.movie,
        sourceName: 'Soap2Day',
        baseUrl: "https://soap2day.rs"),
    // BaseSourceModel(
    //     id: 'hi-movies',
    //     type: SourceType.movie,
    //     sourceName: 'HiMovies',
    //     baseUrl: "https://www5.himovies.to"),
  ];
  var tvSources = <BaseSourceModel>[
    BaseSourceModel(
        id: "goku",
        type: SourceType.multi,
        sourceName: 'Goku',
        baseUrl: 'https://goku.to'),
    BaseSourceModel(
        id: 'all-movies-for-you',
        type: SourceType.multi,
        sourceName: 'AllMoviesForYou',
        baseUrl: 'https://allmoviesforyou.net'),
    BaseSourceModel(
        id: 'soap-today',
        type: SourceType.movie,
        sourceName: 'Soap2Day',
        baseUrl: "https://soap2day.rs"),
    // BaseSourceModel(
    //     id: 'hi-movies',
    //     type: SourceType.movie,
    //     sourceName: 'HiMovies',
    //     baseUrl: "https://www5.himovies.to"),
  ];
  var docSources = <BaseSourceModel>[
    BaseSourceModel(
        id: "goku",
        type: SourceType.multi,
        sourceName: 'Goku',
        baseUrl: 'https://goku.to'),
    BaseSourceModel(
        id: 'all-movies-for-you',
        type: SourceType.multi,
        sourceName: 'AllMoviesForYou',
        baseUrl: 'https://allmoviesforyou.net'),
    BaseSourceModel(
        id: 'soap-today',
        type: SourceType.movie,
        sourceName: 'Soap2Day',
        baseUrl: "https://soap2day.rs"),
    // BaseSourceModel(
    //     id: 'hi-movies',
    //     type: SourceType.movie,
    //     sourceName: 'HiMovies',
    //     baseUrl: "https://www5.himovies.to"),
  ];
  var asianSources = <BaseSourceModel>[
    BaseSourceModel(
        id: "goku",
        type: SourceType.multi,
        sourceName: 'Goku',
        baseUrl: 'https://goku.to'),
    BaseSourceModel(
        id: 'all-movies-for-you',
        type: SourceType.multi,
        sourceName: 'AllMoviesForYou',
        baseUrl: 'https://allmoviesforyou.net'),
    BaseSourceModel(
        id: 'soap-today',
        type: SourceType.movie,
        sourceName: 'Soap2Day',
        baseUrl: "https://soap2day.rs"),
    // BaseSourceModel(
    //     id: 'hi-movies',
    //     type: SourceType.movie,
    //     sourceName: 'HiMovies',
    //     baseUrl: "https://www5.himovies.to"),
  ];
  var cartoonSources = <BaseSourceModel>[
    BaseSourceModel(
        id: "kim-cartoon",
        type: SourceType.multi,
        sourceName: 'KimCartoon',
        baseUrl: "https://kimcartoon.li"),
    BaseSourceModel(
        id: "the-kiss-cartoon",
        type: SourceType.cartoon,
        sourceName: "TheKissCartoon",
        baseUrl: 'https://thekisscartoon.com')
  ];
  var otherSources = <BaseSourceModel>[];

  var allSources = <BaseSourceModel>[
    BaseSourceModel(
        id: 'gogoanime',
        type: SourceType.anime,
        sourceName: 'Gogoanime',
        baseUrl: 'https://gogoanime.tel'),
    BaseSourceModel(
        id: "zoro",
        type: SourceType.anime,
        sourceName: "Zoro",
        baseUrl: "https://zoro.to"),
    BaseSourceModel(
        id: "goku",
        type: SourceType.multi,
        sourceName: 'Goku',
        baseUrl: 'https://goku.to'),
    BaseSourceModel(
        id: 'all-movies-for-you',
        type: SourceType.multi,
        sourceName: 'AllMoviesForYou',
        baseUrl: "https://allmoviesforyou.net"),
    BaseSourceModel(
        id: "kim-cartoon",
        type: SourceType.multi,
        sourceName: 'KimCartoon',
        baseUrl: "https://kimcartoon.li"),
    BaseSourceModel(
        id: 'soap-today',
        type: SourceType.movie,
        sourceName: 'Soap2Day',
        baseUrl: "https://soap2day.rs"),
    BaseSourceModel(
        id: "the-kiss-cartoon",
        type: SourceType.cartoon,
        sourceName: "TheKissCartoon",
        baseUrl: 'https://thekisscartoon.com'),
    BaseSourceModel(
        id: 'all-anime',
        type: SourceType.anime,
        sourceName: "AllAnime",
        baseUrl: 'https://allanime.to'),
    BaseSourceModel(
        id: 'nine-anime',
        type: SourceType.anime,
        sourceName: "9anime",
        baseUrl: "https://9anime.to"),
    // BaseSourceModel(
    //     id: 'hi-movies',
    //     type: SourceType.movie,
    //     sourceName: 'HiMovies',
    //     baseUrl: "https://www5.himovies.to"),
    // BaseSourceModel(
    //     id: 'anime-suge',
    //     type: SourceType.anime,
    //     sourceName: "AnimeSuge",
    //     baseUrl: "https://animesuge.to"),
  ];

  late ActiveSourceCubit activeSourceCubit;

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

  List<List<BaseSourceModel>> activeSources = [];
  List<BaseSourceModel> sources = [];
  BaseSourceModel? selectedSource;

  void changeSource(BaseSourceModel source) {
    setState(() {
      selectedSource = source;
      activeSourceCubit.changeSource(source);
    });
  }

  List<BaseSourceModel> getSourcesNoDuplicates(
      List<List<BaseSourceModel>> souceLists) {
    var sources = <BaseSourceModel>[];
    bool check = false;
    for (var sourceList in souceLists) {
      for (var source in sourceList) {
        for (var source2 in sources) {
          if (source.id == source2.id) {
            check = true;
          }
        }
        if (!check) {
          sources.add(source);
        }
        check = false;
      }
    }
    debugPrint(sources.toString());
    return sources;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    activeSourceCubit = BlocProvider.of<ActiveSourceCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
            child: sources.isEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: allSources.length,
                    itemBuilder: (context, index) {
                      return SourceListItem(
                        isActive:
                            allSources[index].id == activeSourceCubit.state.id,
                        source: allSources[index],
                        changeSource: changeSource,
                      );
                    })
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: sources.length,
                    itemBuilder: (context, index) {
                      return SourceListItem(
                        isActive:
                            sources[index].id == activeSourceCubit.state.id,
                        source: sources[index],
                        changeSource: changeSource,
                      );
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
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    } else {
                                      activeSources.remove(animeSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    }
                                    break;
                                  case 'Movies':
                                    if (itemStatus[i]) {
                                      activeSources.add(movieSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    } else {
                                      activeSources.remove(movieSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    }
                                    break;
                                  case 'TV Shows':
                                    if (itemStatus[i]) {
                                      activeSources.add(tvSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    } else {
                                      activeSources.remove(tvSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    }
                                    break;
                                  case 'Documentaries':
                                    if (itemStatus[i]) {
                                      activeSources.add(docSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    } else {
                                      activeSources.remove(docSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    }
                                    break;
                                  case 'Asian Dramas':
                                    if (itemStatus[i]) {
                                      activeSources.add(asianSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    } else {
                                      activeSources.remove(asianSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    }
                                    break;
                                  case 'Cartoons':
                                    if (itemStatus[i]) {
                                      activeSources.add(cartoonSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    } else {
                                      activeSources.remove(cartoonSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    }
                                    break;
                                  case 'Other':
                                    if (itemStatus[i]) {
                                      activeSources.add(otherSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    } else {
                                      activeSources.remove(otherSources);
                                      sources =
                                          getSourcesNoDuplicates(activeSources);
                                    }
                                    break;
                                }
                                debugPrint('Active sources: $activeSources');
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
          const SizedBox(height: 12),
        ]));
  }
}
