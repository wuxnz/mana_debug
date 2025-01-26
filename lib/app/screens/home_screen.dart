import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mana_debug/app/bloc/cubit/cubits.dart';
import 'package:mana_debug/app/data/services/source_service.dart';
import 'package:mana_debug/app/widgets/active_source_manager/source_button.dart';
import 'package:mana_debug/app/widgets/skeletons/category_swiper_skeleton.dart';
import 'package:mana_debug/app/widgets/swipers/category_swiper.dart';
import 'package:mana_debug/app/widgets/swipers/watch_history_swiper.dart';

import '../data/models/sources/base_model.dart';
import '../widgets/swipers/jumbo_swiper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    // var rabbitStreamExtractor = RabbitStreamExtractor();
    // rabbitStreamExtractor
    //     .extractor(RawVideoSourceInfoModel(
    //         embedUrl:
    //             "https://megacloud.tv/embed-2/e-1/DPpW7Y5FU6MI?k=1&autoPlay=1&oa=0&asi=1",
    //         sourceId: "rapid-cloud",
    //         sourceName: "Rapid-Cloud",
    //         baseUrl: "https://megacloud.tv"))
    //     .then((value) => debugPrint("RabbitStreamExtractor: $value"));
  }

  late WatchHistoryCubit _watchHistoryCubitProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watchHistoryCubitProvider = BlocProvider.of<WatchHistoryCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const SourceButton(),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: BlocBuilder(
          bloc: BlocProvider.of<ActiveSourceCubit>(context),
          builder: (context, BaseSourceModel activeSource) {
            dynamic activeSourceItem =
                SourceService().detectSource(activeSource.id);
            if (activeSourceItem == null) {
              return BlocBuilder(
                bloc: BlocProvider.of<WatchHistoryCubit>(context),
                builder: (context, List<BaseItemModel> watchHistory) {
                  if (watchHistory.isEmpty) {
                    return const Center(
                      child: Text('No source selected'),
                    );
                  } else {
                    return NotificationListener<
                        OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: ListView(
                        physics: const ClampingScrollPhysics(),
                        children: const <Widget>[
                          WatchHistorySwiper(),
                          SizedBox(height: 10),
                        ],
                      ),
                    );
                  }
                },
              );
            } else {
              List<Future<BaseCategoryModel>> categories;
              bool isCategoriesLoading = false;
              try {
                categories = activeSourceItem.getCategories();
                if (categories.isEmpty) {
                  isCategoriesLoading = true;
                }
              } catch (e) {
                categories = [];
                isCategoriesLoading = true;
              }
              debugPrint("Categories: $categories");
              Future<List<BaseCategoryModel>?> homeCats =
                  activeSourceItem.scrapeCategories();
              debugPrint("Home Categories: $homeCats");

              return NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    JumboSwiper(
                        categoryData: activeSourceItem.getItemsForSlider()),
                    const WatchHistorySwiper(),
                    FutureBuilder(
                      future: homeCats,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          debugPrint(
                              "Home Categories: ${snapshot.data.toString()}");
                          return Column(
                            children: snapshot.data
                                .map<Widget>((category) =>
                                    CategorySwiper(category: category))
                                .toList(),
                          );
                        } else {
                          return !isCategoriesLoading
                              ? Column(
                                  children: categories
                                      .map<Widget>((category) => CategorySwiper(
                                          categoryData: category))
                                      .toList(),
                                )
                              : Center(
                                  child: Column(
                                    children: List.generate(
                                      categories.isNotEmpty
                                          ? categories.length
                                          : 4,
                                      (index) => const CategorySwiperSkeleton(),
                                    ),
                                  ),
                                );
                        }
                      },
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
