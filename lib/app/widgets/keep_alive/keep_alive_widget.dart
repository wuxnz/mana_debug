import 'package:flutter/material.dart';

class KeepAliveWidget extends StatefulWidget {
  final Widget child;

  const KeepAliveWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<KeepAliveWidget> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAliveWidget>
    with AutomaticKeepAliveClientMixin<KeepAliveWidget> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
