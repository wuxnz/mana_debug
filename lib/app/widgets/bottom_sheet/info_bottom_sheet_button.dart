import 'package:flutter/material.dart';
import 'package:mana_debug/app/core/values/constants.dart';

class InfoBottomSheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool light;
  final EdgeInsets? padding;
  final double? size;

  const InfoBottomSheetButton({
    Key? key,
    required this.icon,
    required this.label,
    this.light = false,
    this.padding,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100.0),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                color: light ? Colors.white : bottomSheetIconColor,
              ),
              padding: padding ??
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Icon(
                icon,
                size: size ?? 24.0,
                color: light ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(label)
          ],
        ),
      ),
    );
  }
}
