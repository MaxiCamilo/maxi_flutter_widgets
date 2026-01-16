import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maxi_flutter_widgets/src/architecture/reactive_state.dart';
import 'package:maxi_flutter_widgets/src/fields/controllers/text_form_controller.dart';
import 'package:maxi_framework/maxi_framework.dart';
import 'package:maxi_flutter_framework/maxi_flutter_framework.dart';

class TextForm extends StatefulWidget {
  final bool enable;
  final List<String> fieldNames;
  final Oration title;
  final String initialText;
  final int? maxCharacter;
  final int? maxLines;
  final TextInputAction? inputAction;
  final FocusNode? focusNode;
  final Widget? icon;
  final bool obscureText;
  final List<TextInputFormatter> inputFormatters;
  final void Function(TextFormController cont)? onCreated;
  final void Function(Result<String> value)? onSubmitted;
  final List<Validator> validators;
  final TextAlign? textAlign;
  final TextInputType? keyboardType;

  const TextForm({
    required this.title,
    this.initialText = '',
    super.key,
    this.enable = true,
    this.obscureText = false,
    this.maxCharacter,
    this.maxLines,
    this.icon,
    this.inputAction,
    this.focusNode,
    this.inputFormatters = const [],
    this.fieldNames = const [],
    this.onCreated,
    this.onSubmitted,
    this.validators = const [],
    this.textAlign,
    this.keyboardType,
  });

  @override
  State<StatefulWidget> createState() => _TextFormState();
}

class _TextFormState extends State<TextForm> with ReactiveState<TextForm> {
  late final TextFormController _controller;
  late final TextEditingController _textEditingController;

  late final List<TextInputFormatter> formatters;

  CacheOration? lastErrorOration;
  CacheOration? translatedTitle;

  @override
  void initState() {
    super.initState();
    _textEditingController = heart.joinDynamicObject(TextEditingController(text: widget.initialText));

    _controller = heart.joinDisposableObject(
      TextFormController(currentValue: widget.initialText, fieldNames: widget.fieldNames, maxCharacter: widget.maxCharacter, maxLines: widget.maxLines, heart: heart, validators: widget.validators),
    );
    if (widget.onCreated != null) {
      widget.onCreated!(_controller);
    }

    if (widget.maxCharacter != null) {
      formatters = [LengthLimitingTextInputFormatter(widget.maxCharacter!), ...widget.inputFormatters];
    } else {
      formatters = widget.inputFormatters;
    }

    _textEditingController.addListener(() {
      _controller.changeFieldValue(_textEditingController.text).logIfFails(errorName: '[TextForm -> TextEditingController Listener] Could not change field value');
    });

    _controller.validityChange.listen((_) => _updateData());
    _controller.notifyChangeError.listen((_) => _updateData());
    _controller
        .buildFieldChannel()
        .onCorrectLambda((newChannel) {
          newChannel
              .getReceiver()
              .onCorrectLambda((stream) {
                stream.listen((item) => _updateData());
              })
              .logIfFails(errorName: '[TextForm -> initState] Could not get field channel receiver');
        })
        .logIfFails(errorName: '[TextForm -> initState] Could not build field channel');
  }

  void _updateData() {
    final value = _controller.obtainFieldValue();
    if (value != _textEditingController.text) {
      _textEditingController.text = value;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    lastErrorOration = lastErrorOration.initFromProvider(context: context, oration: _controller.lastError.message);
    translatedTitle = translatedTitle.initFromProvider(context: context, oration: widget.title);

    return TextField(
      controller: _textEditingController,
      enabled: widget.enable,
      minLines: 1,
      maxLines: widget.maxLines,
      focusNode: widget.focusNode,
      obscureText: widget.obscureText,
      textInputAction: widget.inputAction,
      textAlign: widget.textAlign ?? TextAlign.start,
      decoration: InputDecoration(border: const OutlineInputBorder(), labelText: translatedTitle.toString(), icon: widget.icon, errorText: _controller.isValid ? null : lastErrorOration.toString()),
      inputFormatters: formatters,
      keyboardType: widget.keyboardType,
      onEditingComplete: () {
        _controller.changeFieldValue(_textEditingController.text);
      },
      onSubmitted: (_) {
        final result = _controller.changeFieldValue(_textEditingController.text);
        if (widget.onSubmitted != null) {
          widget.onSubmitted!(result);
        }
      },
    );
  }
}
