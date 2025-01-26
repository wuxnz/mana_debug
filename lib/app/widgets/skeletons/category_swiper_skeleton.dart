import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

class CategorySwiperSkeleton extends StatelessWidget {
  const CategorySwiperSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 240,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton(
                  isLoading: true,
                  skeleton: const SkeletonLine(
                    style: SkeletonLineStyle(
                      width: 155,
                      height: 25,
                    ),
                  ),
                  themeMode: ThemeMode.dark,
                  child: Container(),
                ),
                Skeleton(
                  isLoading: true,
                  skeleton: const SkeletonLine(
                    style: SkeletonLineStyle(
                      width: 75,
                      height: 25,
                    ),
                  ),
                  themeMode: ThemeMode.dark,
                  child: Container(),
                ),
              ],
            ),
            SizedBox(
              height: 200,
              child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    for (int i = 0; i < 20; i++)
                      SizedBox(
                        width: 125,
                        child: AspectRatio(
                          aspectRatio: 3 / 4.2,
                          child: Skeleton(
                            isLoading: true,
                            skeleton: SkeletonAvatar(
                              style: SkeletonAvatarStyle(
                                width: MediaQuery.of(context).size.width * 0.33,
                                height: double.infinity,
                                padding: const EdgeInsets.only(right: 7.5),
                              ),
                            ),
                            themeMode: ThemeMode.dark,
                            child: Container(),
                          ),
                        ),
                      ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
