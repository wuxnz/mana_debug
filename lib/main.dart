import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mana_debug/app/screens/navigation/bottom_nav_bar.dart';
import 'package:mana_debug/app/screens/player_screen.dart';
import 'package:mana_debug/app/theme/app_theme.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app/bloc/cubit/cubits.dart';
import 'app/data/models/sources/base_model.dart';
import 'app/screens/info_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..userAgent = null;
  }
}

List<String> testDeviceIds = [
  "6684921B91B6F76A408415A434272375",
  // "e5a30288b3da89ef",
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  MobileAds.instance.initialize();

  RequestConfiguration configuration = RequestConfiguration(
    testDeviceIds: testDeviceIds,
  );
  MobileAds.instance.updateRequestConfiguration(configuration);

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    windowManager.ensureInitialized();
  }

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: !kIsWeb
        ? await getApplicationDocumentsDirectory()
        : HydratedStorage.webStorageDirectory,
  );
  HttpOverrides.global = MyHttpOverrides();

  runApp(MultiBlocProvider(providers: [
    BlocProvider(
      create: (context) => ActiveSourceCubit(),
    ),
    BlocProvider(
      create: (context) => FavoritesCubit(),
    ),
    BlocProvider(
      create: (context) => WatchHistoryCubit(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<ActiveSourceCubit>(context),
      builder: (context, BaseSourceModel activeSource) {
        return BlocBuilder(
          bloc: BlocProvider.of<FavoritesCubit>(context),
          builder: (context, List<BaseItemModel> favorites) {
            return BlocBuilder(
              bloc: BlocProvider.of<WatchHistoryCubit>(context),
              builder: (context, List<BaseItemModel> watchHistory) {
                debugPrint(
                    "Number of items in watch history: ${watchHistory.length}");
                return MaterialApp(
                  title: 'Mana (Debug)',
                  theme: appTheme,
                  debugShowCheckedModeBanner: false,
                  routes: {
                    "/": (context) => const BottomNavBar(),
                    "/info": (context) => const InfoScreen(),
                  },
                  onGenerateRoute: (settings) {
                    if (settings.name == "/player") {
                      final args =
                          settings.arguments as PlayerScreenArgumentsModel;
                      return MaterialPageRoute(
                        builder: (context) => PlayerScreen(
                          args: args,
                        ),
                      );
                    }
                    return null;
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
