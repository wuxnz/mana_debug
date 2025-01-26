import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mana_debug/app/core/values/constants.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:skeletons/skeletons.dart';

import '../../bloc/cubit/cubits.dart';
import '../../core/utils/formatters/text_formatters.dart';

class JumboSwiper extends StatefulWidget {
  final Future<BaseCategoryModel> categoryData;

  const JumboSwiper({Key? key, required this.categoryData}) : super(key: key);

  @override
  State<JumboSwiper> createState() => _JumboSwiperState();
}

class _JumboSwiperState extends State<JumboSwiper>
    with AutomaticKeepAliveClientMixin {
  int _currentPage = 999;
  final PageController _pageController = PageController(
    initialPage: 999,
  );

  late WatchHistoryCubit watchHistoryCubitProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    watchHistoryCubitProvider = BlocProvider.of<WatchHistoryCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: widget.categoryData,
      builder: (context, AsyncSnapshot<BaseCategoryModel> snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Stack(
              children: [
                PageView.builder(
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Image.network(
                          snapshot
                              .data!
                              .items[index % snapshot.data!.items.length]
                              .imageUrl,
                          errorBuilder: (context, error, stackTrace) =>
                              SizedBox(
                            child: Skeleton(
                              isLoading: true,
                              skeleton: const SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              themeMode: ThemeMode.dark,
                              child: Container(),
                            ),
                          ),
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height * 0.55 - 5,
                          width: MediaQuery.of(context).size.width,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 70,
                          left: MediaQuery.of(context).size.width * 0.1,
                          right: MediaQuery.of(context).size.width * 0.1,
                          child: Text(
                            snapshot
                                .data!
                                .items[
                                    _currentPage % snapshot.data!.items.length]
                                .title,
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01,
                        ),
                      ],
                    );
                  },
                ),
                BlocBuilder(
                  bloc: BlocProvider.of<WatchHistoryCubit>(context),
                  builder: (context, List<BaseItemModel> watchHistory) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Feedback.forTap(context);
                                        showModalBottomSheet(
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(15),
                                            ),
                                          ),
                                          backgroundColor: bottomSheetColor,
                                          builder: (context) {
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 20,
                                                      bottom: 10,
                                                      left: 10,
                                                      right: 10,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Set Watch Status',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurface,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SingleChildScrollView(
                                                  controller:
                                                      ModalScrollController.of(
                                                          context),
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: WatchStatus
                                                        .values.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 10,
                                                          right: 10,
                                                        ),
                                                        child: ListTile(
                                                          onTap: () {
                                                            watchHistoryCubitProvider
                                                                .updateWatchHistoryItemWatchStatus(
                                                              context.read<WatchHistoryCubit>().getWatchHistoryItem(snapshot
                                                                          .data!
                                                                          .items[
                                                                      _currentPage %
                                                                          snapshot
                                                                              .data!
                                                                              .items
                                                                              .length]) ??
                                                                  snapshot.data!
                                                                          .items[
                                                                      _currentPage %
                                                                          snapshot
                                                                              .data!
                                                                              .items
                                                                              .length],
                                                              WatchStatus
                                                                      .values[
                                                                  index],
                                                            );
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          title: Text(
                                                            watchStatusToString(
                                                                WatchStatus
                                                                        .values[
                                                                    index]),
                                                            style: GoogleFonts
                                                                .roboto(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      splashColor:
                                          Colors.white.withOpacity(0.5),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 50,
                                          minWidth: 50,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.add),
                                            Text(
                                              stringToInitialsCapitalized(
                                                watchStatusToString(
                                                  watchHistoryCubitProvider
                                                          .getWatchHistoryItem(
                                                              snapshot.data!
                                                                      .items[
                                                                  _currentPage %
                                                                      snapshot
                                                                          .data!
                                                                          .items
                                                                          .length])
                                                          ?.watchStatus
                                                          ?.status ??
                                                      WatchStatus.notWatched,
                                                ),
                                              ),
                                              style: GoogleFonts.roboto(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.55,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/info",
                                      arguments: InfoPageArgumentsModel(
                                        item: snapshot.data!.items[
                                            _currentPage %
                                                snapshot.data!.items.length],
                                        source: snapshot.data!.source,
                                        playImmediately: true,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.play_arrow),
                                  label: Text("Play",
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      )),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Feedback.forTap(context);
                                        Navigator.pushNamed(
                                          context,
                                          "/info",
                                          arguments: InfoPageArgumentsModel(
                                            item: snapshot.data!.items[
                                                _currentPage %
                                                    snapshot
                                                        .data!.items.length],
                                            source: snapshot.data!.source,
                                            playImmediately: false,
                                          ),
                                        );
                                      },
                                      splashColor:
                                          Colors.white.withOpacity(0.5),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 2.5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.info_outline),
                                            Text(
                                              "Info",
                                              style: GoogleFonts.roboto(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.55,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return Skeleton(
              isLoading: true,
              skeleton: SkeletonAvatar(
                style: SkeletonAvatarStyle(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.55,
                  shape: BoxShape.rectangle,
                ),
              ),
              themeMode: ThemeMode.dark,
              child: Container());
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
