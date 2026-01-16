import 'package:flutter/material.dart';
import 'package:maxi_flutter_framework/maxi_flutter_framework.dart';
import 'package:maxi_framework/maxi_framework.dart';

class VisualOration extends StatefulWidget {
  final Oration text;
  final double? size;
  final bool bold;
  final Color? color;
  final TextAlign? aling;
  final bool italic;
  final TextDecoration? decoration;
  final bool selectable;
  final TextOverflow? overflow;

  const VisualOration({required this.text, super.key, this.size, this.bold = false, this.color, this.aling, this.italic = false, this.decoration, this.selectable = false, this.overflow});

  @override
  State<StatefulWidget> createState() => _VisualOrationState();
}

class _VisualOrationState extends State<VisualOration> {
  Oration? _originalText;
  String? _text;

  @override
  void didUpdateWidget(covariant VisualOration oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.text != oldWidget.text) {
      _originalText = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_originalText == null) {
      _originalText = widget.text;
      _text = widget.text.translateFromProvider(context: context, original: null).toString();
    }

    if (widget.selectable) {
      return SelectableText(
        _text ?? '',
        textAlign: widget.aling,
        style: TextStyle(
          decoration: widget.decoration,
          color: widget.color,
          fontWeight: widget.bold ? FontWeight.bold : FontWeight.normal,
          fontSize: widget.size,
          fontStyle: widget.italic ? FontStyle.italic : FontStyle.normal,
        ),
      );
    } else {
      return Text(
        _text ?? '',
        textAlign: widget.aling,
        overflow: widget.overflow,
        style: TextStyle(
          decoration: widget.decoration,
          color: widget.color,
          fontWeight: widget.bold ? FontWeight.bold : FontWeight.normal,
          fontSize: widget.size,
          fontStyle: widget.italic ? FontStyle.italic : FontStyle.normal,
        ),
      );
    }
  }
}
