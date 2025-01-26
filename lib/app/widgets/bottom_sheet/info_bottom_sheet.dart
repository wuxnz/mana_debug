import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletons/skeletons.dart';

import '../../core/values/constants.dart';
import '../../data/models/sources/base_model.dart';

class InfoBottomSheet extends StatelessWidget {
  final BaseItemModel item;
  final dynamic source;

  const InfoBottomSheet({
    Key? key,
    required this.item,
    required this.source,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.network(
                      item.imageUrl,
                      errorBuilder: (context, error, stackTrace) => SizedBox(
                        child: Skeleton(
                          isLoading: true,
                          skeleton: const SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                              width: 90,
                              height: 120,
                            ),
                          ),
                          themeMode: ThemeMode.dark,
                          child: Container(),
                        ),
                      ),
                      fit: BoxFit.cover,
                      width: 90.0,
                      height: 120.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 8.0,
              ),
              Expanded(
                child: Column(
                  textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Column(
                            textDirection: TextDirection.ltr,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
                              ),
                              const SizedBox(
                                height: 8.0,
                              ),
                              SizedBox(
                                height: 30.0,
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            item.source.sourceName,
                                            style: GoogleFonts.roboto(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8.0,
                                        ),
                                        item.languages.isNotEmpty
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surface,
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surface,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  item.languages
                                                      .map((e) =>
                                                          languageTypeToString(
                                                              e))
                                                      .toList()
                                                      .join(', '),
                                                  style: GoogleFonts.roboto(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ))
                                            : const SizedBox.shrink(),
                                        item.languages.isNotEmpty
                                            ? const SizedBox(
                                                width: 8.0,
                                              )
                                            : const SizedBox.shrink(),
                                        item.rating != null
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surface,
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surface,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      size: 12,
                                                    ),
                                                    const SizedBox(
                                                      width: 4.0,
                                                    ),
                                                    Text(
                                                      item.rating.toString(),
                                                      style: GoogleFonts.roboto(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                        item.rating != null
                                            ? const SizedBox(
                                                width: 8.0,
                                              )
                                            : const SizedBox.shrink(),
                                        item.episodeCount != null
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surface,
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surface,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  '${item.episodeCount?.episodeCount} Episodes',
                                                  style: GoogleFonts.roboto(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(100.0),
                          radius: 32.0,
                          child: Container(
                            decoration: BoxDecoration(
                                color: bottomSheetIconColor,
                                borderRadius: BorderRadius.circular(100.0)),
                            child: const Icon(
                              Icons.close,
                              size: 28.0,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                  ],
                ),
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/info',
                  arguments: InfoPageArgumentsModel(
                    item: item,
                    source: source,
                    playImmediately: true,
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play'),
            ),
          ),
          const Divider(),
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: () {
                Navigator.pop(context);

                Navigator.pushNamed(
                  context,
                  '/info',
                  arguments: InfoPageArgumentsModel(
                    item: item,
                    source: source,
                    playImmediately: false,
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text("More Info"),
                    ],
                  ),
                  Icon(Icons.chevron_right)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
