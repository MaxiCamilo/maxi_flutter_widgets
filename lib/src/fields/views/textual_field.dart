import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maxi_flutter_widgets/maxi_flutter_widgets.dart';
import 'package:maxi_framework/maxi_framework.dart';

class TextualField extends StatefulWidget with FieldTemplateWidget<String> {
  final bool enable;
  final Oration title;
  @override
  final String? propertyName;
  @override
  final String defaultValue;

  final TextInputAction? inputAction;
  final FocusNode? focusNode;
  final Widget? icon;
  final bool obscure;
  final List<TextInputFormatter> inputFormatters;
  @override
  final FieldController<String> Function()? controllerGetter;
  @override
  final void Function(FieldController<String> controller)? onControllerCreated;

  final void Function(TextEditingController)? onEditorCreated;

  final void Function(Result<String>)? onSubmitted;

  const TextualField({
    super.key,
    this.enable = true,
    this.title = emptyOration,
    this.propertyName,
    this.inputAction,
    this.focusNode,
    this.icon,
    this.controllerGetter,
    this.onControllerCreated,
    this.onEditorCreated,
    this.defaultValue = '',
    this.obscure = false,
    this.inputFormatters = const [],
    this.onSubmitted,
  });

  @override
  State<StatefulWidget> createState() => _TextualFieldState();
}

class _TextualFieldState extends FieldTemplateState<String, TextualField> {
  final textFormatters = <TextInputFormatter>[];

  late TextEditingController controllerEditor;

  late int maxLength;
  late int minLength;
  late int maxLines;
  late int minLines;

  Oration? originalTitle;
  String? title;

  @override
  FieldController<String> buildDefaultController() => FieldTextualController.oneName(name: widget.propertyName ?? '', initialValue: widget.defaultValue, validators: [], aceptInvalidValues: true);

  @override
  void performanInitState() {
    controllerEditor = heart.joinManualDisposableObject(TextEditingController(text: lastValue), onDisponse: (x) => x.dispose());
    if (widget.onEditorCreated != null) {
      widget.onEditorCreated!(controllerEditor);
    }

    if (controller is FieldTextualController) {
      final controllerAsTextual = controller as FieldTextualController;
      maxLength = controllerAsTextual.maxLength;
      minLength = controllerAsTextual.minLength;
      maxLines = controllerAsTextual.maxLines;
      minLines = controllerAsTextual.minLines;
    } else {
      maxLength = 99999999;
      minLength = 0;
      maxLines = 99999999;
      minLines = 1;
    }

    textFormatters.add(LengthLimitingTextInputFormatter(maxLength));
    textFormatters.addAll(widget.inputFormatters);
  }

  @override
  void didUpdateWidget(covariant TextualField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.title != oldWidget.title) {
      originalTitle = null;
    }
  }

  @override
  Widget performanceBuild(BuildContext context) {
    if (originalTitle == null) {
      originalTitle = widget.title;
      title = widget.title.translateText();
    }

    return TextField(
      controller: controllerEditor,
      enabled: widget.enable,
      minLines: minLines,
      maxLines: maxLines,
      focusNode: widget.focusNode,
      obscureText: widget.obscure,
      textInputAction: widget.inputAction,
      decoration: InputDecoration(border: const OutlineInputBorder(), labelText: title, icon: widget.icon, errorText: isLastValueValid ? null : lastTranslateError),
      inputFormatters: textFormatters,

      onEditingComplete: () {
        textEditorChanged(value: controllerEditor.text);
      },
      onSubmitted: (_) {
        textEditorChanged(value: controllerEditor.text);
        if (widget.onSubmitted != null) {
          if (isLastValueValid) {
            widget.onSubmitted!(ResultValue(content: lastValue));
          } else {
            widget.onSubmitted!(NegativePartialResult(error: lastError.error, partialContent: lastValue));
          }
        }
      },
    );
  }

  void textEditorChanged({required String value}) {
    final wasValid = isLastValueValid;

    if (controllerEditor.selection.start >= 0) {
      final lastErrorText = lastTranslateError;
      final position = controllerEditor.selection.start;

      final changeResult = controller.changeFieldValue(value);

      if (wasValid != changeResult.itsCorrect || lastErrorText != lastTranslateError) {
        scheduleMicrotask(() {
          try {
            controllerEditor.value = TextEditingValue(
              text: controllerEditor.text,
              selection: TextSelection.collapsed(offset: controllerEditor.selection.end),
            );
            controllerEditor.selection = TextSelection.collapsed(offset: position);
          } catch (ex) {
            log('[FormText] fail select: $ex');
            controllerEditor.selection = const TextSelection.collapsed(offset: 0);
          }
        });
      }
    } else {
      controller.changeFieldValue(value);
    }
  }

  @override
  bool onControllerValueChanged({required String oldValue, required String newValue}) {
    if (mounted && newValue != controllerEditor.text) {
      controllerEditor.text = newValue;
      setState(() {});
    }

    return true;
  }

  @override
  void onChangeToValid() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void onChangeToInvalid({required NegativeResult<dynamic> error, required String translateError}) {
    if (mounted) {
      setState(() {});
    }
  }
}
