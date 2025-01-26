import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mana_debug/app/bloc/cubit/cubits.dart';
import 'package:mana_debug/app/core/values/constants.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class WatchStatusButton extends StatefulWidget {
  final BaseItemModel item;

  const WatchStatusButton({Key? key, required this.item}) : super(key: key);

  @override
  State<WatchStatusButton> createState() => _WatchStatusButtonState();
}

class _WatchStatusButtonState extends State<WatchStatusButton> {
  late WatchHistoryCubit watchHistoryCubitProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    watchHistoryCubitProvider = BlocProvider.of<WatchHistoryCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<WatchHistoryCubit>(context),
      builder: (context, List<BaseItemModel> watchHistory) {
        BaseItemModel? watchHistoryItem;
        if (watchHistoryCubitProvider.matchWatchHistory(widget.item)) {
          watchHistoryItem =
              watchHistoryCubitProvider.getWatchHistoryItem(widget.item);
        }
        debugPrint(
            'Watch History Item Status: ${watchHistoryItem?.watchStatus?.status ?? "null status"}');
        return FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                backgroundColor: bottomSheetColor,
                builder: (context) {
                  return ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            bottom: 10,
                            left: 10,
                            right: 10,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Set Watch Status',
                                style: GoogleFonts.roboto(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        controller: ModalScrollController.of(context),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: WatchStatus.values.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              child: ListTile(
                                onTap: () {
                                  watchHistoryCubitProvider
                                      .updateWatchHistoryItemWatchStatus(
                                    watchHistoryItem ?? widget.item,
                                    WatchStatus.values[index],
                                  );
                                  Navigator.pop(context);
                                },
                                title: Text(
                                  watchStatusToString(
                                      WatchStatus.values[index]),
                                  style: GoogleFonts.roboto(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  );
                });
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          tooltip: 'Set Watch Status',
          icon: const Icon(Icons.filter_list),
          label: Text(
            watchStatusToString(context
                    .read<WatchHistoryCubit>()
                    .getWatchHistoryItem(widget.item)
                    ?.watchStatus
                    ?.status ??
                WatchStatus.notWatched),
            style: GoogleFonts.roboto(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}
