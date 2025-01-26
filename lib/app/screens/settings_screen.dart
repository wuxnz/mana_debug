import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mana_debug/app/bloc/cubit/cubits.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  WatchHistoryCubit? _watchHistoryCubitProvider;
  FavoritesCubit? _favoritesCubitProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _watchHistoryCubitProvider = BlocProvider.of<WatchHistoryCubit>(context);
    _favoritesCubitProvider = BlocProvider.of<FavoritesCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10, bottom: 8),
              child: const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(
              thickness: 1,
              color: Theme.of(context).dividerColor,
              height: 24,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: const Text("Clear Watch History"),
                    subtitle: const Text(
                        "Clear your watch history. This cannot be undone."),
                    trailing: const Icon(Icons.delete),
                    onTap: () {
                      var alert = AlertDialog(
                        title: const Text("Clear Watch History"),
                        content: const Text(
                            "Are you sure you want to clear your watch history?"),
                        actions: [
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text("Clear",
                                style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              _watchHistoryCubitProvider?.clearWatchHistory();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    },
                  ),
                  ListTile(
                    title: const Text("Clear Favorites"),
                    subtitle: const Text(
                        "Clear your favorites. This cannot be undone."),
                    trailing: const Icon(Icons.delete),
                    onTap: () {
                      var alert = AlertDialog(
                        title: const Text("Clear Favorites"),
                        content: const Text(
                            "Are you sure you want to clear your favorites?"),
                        actions: [
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text("Clear",
                                style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              _favoritesCubitProvider?.clearFavorites();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
