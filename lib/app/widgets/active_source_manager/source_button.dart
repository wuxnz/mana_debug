import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mana_debug/app/bloc/cubit/active_source_cubit/active_source_cubit.dart';
import 'package:mana_debug/app/data/models/sources/base_model.dart';
import 'package:mana_debug/app/widgets/active_source_manager/source_menu.dart';

import '../../core/values/constants.dart';

class SourceButton extends StatefulWidget {
  const SourceButton({super.key});

  @override
  State<SourceButton> createState() => _SourceButtonState();
}

class _SourceButtonState extends State<SourceButton> {
  late ActiveSourceCubit activeSourceCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    activeSourceCubit = BlocProvider.of<ActiveSourceCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<ActiveSourceCubit>(context),
      builder: (context, BaseSourceModel activeSource) {
        return FloatingActionButton.extended(
          onPressed: () {
            //       baseUrl: 'https://thekisscartoon.com'));
            // } else if (activeSource.sourceName == 'TheKissCartoon') {
            //   activeSourceCubit.changeSource(BaseSourceModel(
            //     id: '0',
            //     type: SourceType.none,
            //     sourceName: 'None',
            //     baseUrl: '',
            //   ));
            // }
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
                  return const SourceMenu();
                });
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          tooltip: 'Change Source',
          icon: const Icon(Icons.filter_list),
          label: Text(
            activeSource.sourceName,
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
