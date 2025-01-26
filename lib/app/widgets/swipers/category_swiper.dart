import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';
import 'package:mana_debug/app/widgets/skeletons/category_swiper_skeleton.dart';
import 'package:skeletons/skeletons.dart';

import '../../core/values/constants.dart';
import '../bottom_sheet/info_bottom_sheet.dart';

class CategorySwiper extends StatefulWidget {
  final Future<BaseCategoryModel>? categoryData;
  final BaseCategoryModel? category;

  const CategorySwiper({Key? key, this.categoryData, this.category})
      : super(key: key);

  @override
  State<CategorySwiper> createState() => _CategorySwiperState();
}

class _CategorySwiperState extends State<CategorySwiper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.category == null) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
          future: widget.categoryData,
          builder: (context, AsyncSnapshot<BaseCategoryModel> snapshot) {
            if (snapshot.hasData) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            snapshot.data!.categoryName,
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ),
                    snapshot.data!.items.isEmpty
                        ? const SizedBox()
                        : const SizedBox(height: 8),
                    snapshot.data!.items.isEmpty
                        ? const SizedBox()
                        : SizedBox(
                            height: 225,
                            child: NotificationListener<
                                OverscrollIndicatorNotification>(
                              onNotification: (overscroll) {
                                overscroll.disallowIndicator();
                                return true;
                              },
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.items.length,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: 125,
                                    child: GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                            context: context,
                                            useRootNavigator: true,
                                            backgroundColor: bottomSheetColor,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8.0),
                                                  topRight:
                                                      Radius.circular(8.0)),
                                            ),
                                            builder: (context) {
                                              return InfoBottomSheet(
                                                item:
                                                    snapshot.data!.items[index],
                                                source: snapshot.data!.source,
                                              );
                                            });
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 3 / 4.25,
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              height: double.infinity,
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      snapshot
                                                          .data!
                                                          .items[index]
                                                          .imageUrl,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          SizedBox(
                                                        child: Skeleton(
                                                          isLoading: true,
                                                          skeleton:
                                                              const SkeletonAvatar(
                                                            style:
                                                                SkeletonAvatarStyle(
                                                              width: double
                                                                  .infinity,
                                                              height: double
                                                                  .infinity,
                                                            ),
                                                          ),
                                                          themeMode:
                                                              ThemeMode.dark,
                                                          child: Container(),
                                                        ),
                                                      ),
                                                      fit: BoxFit.cover,
                                                      height: double.infinity,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: double.infinity,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const SizedBox(),
                                                          Column(
                                                            children: snapshot
                                                                .data!
                                                                .items[index]
                                                                .languages
                                                                .map((e) =>
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                              .only(
                                                                          bottom:
                                                                              5),
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              5,
                                                                          vertical:
                                                                              2),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        e.toString().replaceFirst("LanguageType.", "")[0].toUpperCase() +
                                                                            e.toString().replaceFirst("LanguageType.", "").substring(1),
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ))
                                                                .toList(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Center(
                                            child: SizedBox(
                                              width: 115,
                                              child: Text(
                                                snapshot
                                                    .data!.items[index].title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ],
                ),
              );
            } else {
              return const CategorySwiperSkeleton();
            }
          },
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.category!.categoryName,
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(),
                ],
              ),
            ),
            widget.category!.items.isEmpty
                ? const SizedBox()
                : const SizedBox(height: 8),
            widget.category!.items.isEmpty
                ? const SizedBox()
                : SizedBox(
                    height: 230,
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.category!.items.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 125,
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    useRootNavigator: true,
                                    backgroundColor: bottomSheetColor,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8.0),
                                          topRight: Radius.circular(8.0)),
                                    ),
                                    builder: (context) {
                                      return InfoBottomSheet(
                                        item: widget.category!.items[index],
                                        source: widget.category!.source,
                                      );
                                    });
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 3 / 4.25,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      height: double.infinity,
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              widget.category!.items[index]
                                                  .imageUrl,
                                              fit: BoxFit.cover,
                                              height: double.infinity,
                                              width: 125,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  SizedBox(
                                                // width: 125,
                                                child: Skeleton(
                                                  isLoading: true,
                                                  skeleton:
                                                      const SkeletonAvatar(
                                                    style: SkeletonAvatarStyle(
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                    ),
                                                  ),
                                                  themeMode: ThemeMode.dark,
                                                  child: Container(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: double.infinity,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  widget.category!.items[index]
                                                              .rating !=
                                                          null
                                                      ? Column(
                                                          children: [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          5),
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 5,
                                                                  vertical: 2),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 12,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Text(
                                                                    widget
                                                                        .category!
                                                                        .items[
                                                                            index]
                                                                        .rating
                                                                        .toString(),
                                                                    style: GoogleFonts
                                                                        .roboto(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : const SizedBox(),
                                                  Column(
                                                    children:
                                                        widget
                                                            .category!
                                                            .items[index]
                                                            .languages
                                                            .map(
                                                                (e) =>
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                              .only(
                                                                          bottom:
                                                                              5),
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              5,
                                                                          vertical:
                                                                              2),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        e.toString().replaceFirst("LanguageType.", "")[0].toUpperCase() +
                                                                            e.toString().replaceFirst("LanguageType.", "").substring(1),
                                                                        style: GoogleFonts
                                                                            .roboto(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ))
                                                            .toList(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Center(
                                    child: SizedBox(
                                      width: 135,
                                      child: Text(
                                        widget.category!.items[index].title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ],
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
