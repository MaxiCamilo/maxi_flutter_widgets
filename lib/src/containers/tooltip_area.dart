import 'package:flutter/material.dart';
import 'package:maxi_flutter_framework/maxi_flutter_framework.dart';
import 'package:maxi_framework/maxi_framework.dart';

class TooltipArea extends StatefulWidget {
  final Oration text;
  final Widget child;

  const TooltipArea({super.key, required this.text, required this.child});

  @override
  State<TooltipArea> createState() => _TooltipAreaState();
}

class _TooltipAreaState extends State<TooltipArea> {
  CacheOration? text;

  @override
  Widget build(BuildContext context) {
    text = text.initFromProvider(context: context, oration: widget.text);

    return Tooltip(message: text.toString(), child: widget.child);
  }
}
