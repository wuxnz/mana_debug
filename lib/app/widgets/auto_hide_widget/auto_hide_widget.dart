import 'package:flutter/material.dart';

class AutoHideWidget extends StatefulWidget {
  final Widget child;

  const AutoHideWidget({super.key, required this.child});

  @override
  State<AutoHideWidget> createState() => _AutoHideWidgetState();
}

DateTime? lastInteraction;

void setLastInteraction(DateTime? time) {
  lastInteraction = time;
}

class _AutoHideWidgetState extends State<AutoHideWidget> {
  // create a widget that will be shown when the screen is tapped but will be hidden after 5 seconds of inactivity
  bool _isVisible = true;

  void _checkIfVisible() {
    while (_isVisible && lastInteraction != null) {
      if (lastInteraction != null &&
          DateTime.now().difference(lastInteraction!) >
              const Duration(seconds: 5)) {
        setState(() {
          _isVisible = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isVisible = true;
          lastInteraction = DateTime.now();
          _checkIfVisible();
        });
      },
      child: // show child if _isVisible is true and if the last interaction was less than 5 seconds ago
          _isVisible &&
                  lastInteraction != null &&
                  DateTime.now().difference(lastInteraction!) <
                      const Duration(seconds: 5)
              ? widget.child
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      _isVisible = true;
                      lastInteraction = DateTime.now();
                      // _checkIfVisible();
                    });
                  },
                ),
    );
  }
}
