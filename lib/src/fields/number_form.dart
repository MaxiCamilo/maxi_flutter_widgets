import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maxi_flutter_widgets/src/architecture/reactive_state.dart';
import 'package:maxi_flutter_widgets/src/fields/controllers/number_form_controller.dart';
import 'package:maxi_flutter_widgets/src/fields/controllers/text_form_controller.dart';
import 'package:maxi_flutter_widgets/src/fields/text_form.dart';
import 'package:maxi_framework/maxi_framework.dart';

class NumberForm extends StatefulWidget {
  final List<String> fieldNames;
  final bool enable;
  final Oration title;
  final Widget? icon;
  final num? minimum;
  final num? maximum;
  final double interval;
  final int decimalDigit;
  final bool isDecimal;
  final bool showButtons;
  final bool expandHorizontally;
  final void Function(NumberFormController cont)? onCreated;
  final void Function(Result<num> value)? onSubmitted;
  final List<Validator> validators;

  const NumberForm({
    super.key,
    required this.title,
    this.enable = true,
    this.icon,
    this.minimum,
    this.maximum,
    this.interval = 1.0,
    this.fieldNames = const [],
    this.decimalDigit = 2,
    this.isDecimal = false,
    this.showButtons = false,
    this.expandHorizontally = true,
    this.onCreated,
    this.onSubmitted,
    this.validators = const [],
  });

  @override
  State<NumberForm> createState() => _NumberFormState();
}

class _NumberFormState extends State<NumberForm> with ReactiveState<NumberForm> {
  int? maxTextLength;

  late num currentValue;
  late TextFormController textFormController;
  late final NumberFormController numberFormController;
  late final List<TextInputFormatter> inputFormatters;
  late final Channel<Result<String>, dynamic> textChannel;
  late final Channel<Result<num>, dynamic> numberChannel;

  bool enableIncrease = false;
  bool enableDecrease = false;

  @override
  void initState() {
    super.initState();

    defineMaxLength();
    inputFormatters = makeInputFormatters();
    currentValue = widget.minimum ?? 0;

    enableIncrease = widget.maximum != null && currentValue < widget.maximum!;
    enableDecrease = widget.minimum != null && currentValue > widget.minimum!;

    numberFormController = heart.joinDisposableObject(
      NumberFormController(
        isDecimal: widget.isDecimal,
        minimum: widget.minimum,
        maximum: widget.maximum,
        decimalDigit: widget.decimalDigit,
        currentValue: currentValue,
        heart: heart,
        fieldNames: widget.fieldNames,
        validators: widget.validators,
      ),
    );

    textChannel = textFormController.buildFieldChannel().exceptionIfFails(detail: 'TextForm building channel failed');
    numberChannel = numberFormController.buildFieldChannel().exceptionIfFails(detail: 'NumberForm building channel failed');

    textChannel.getReceiver().exceptionIfFails(detail: 'NumberForm text channel getting receiver failed').listen(onTextChanged);
    numberChannel.getReceiver().exceptionIfFails(detail: 'NumberForm number channel getting receiver failed').listen(onNumberChanged);
    if (widget.showButtons) {
      numberFormController.validityChange.where((x) => !x).listen((_) {
        enableIncrease = false;
        enableDecrease = false;
        setState(() {});
      });
    }
    if (widget.onCreated != null) {
      widget.onCreated!(numberFormController);
    }
  }

  void onTextChanged(Result<String> event) {
    if (event.itsCorrect) {
      numberFormController.changeFieldValue(event.content);
    } else {
      numberFormController.defineAsInvalid(event.error);
    }
  }

  void onNumberChanged(Result<num> event) {
    if (event.itsFailure) {
      textFormController.defineAsInvalid(event.error);
      return;
    }

    currentValue = event.content;
    final numText = event.content.toString();
    if (numText != textFormController.obtainFieldValue()) {
      textFormController.changeFieldValue(numText);
    }

    enableIncrease = widget.maximum != null && widget.enable && numberFormController.isValid && currentValue < widget.maximum!;
    enableDecrease = widget.minimum != null && widget.enable && numberFormController.isValid && currentValue > widget.minimum!;

    setState(() {});
  }

  void defineMaxLength() {
    if (widget.maximum != null && widget.maximum != double.infinity) {
      if (widget.isDecimal && widget.decimalDigit > 0) {
        maxTextLength = widget.maximum!.toInt().toString().length + 1 + widget.decimalDigit;
      } else {
        maxTextLength = widget.maximum.toString().length;
      }
    }
  }

  List<TextInputFormatter> makeInputFormatters() {
    if (widget.maximum != null && widget.maximum != double.infinity) {
      return [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(maxTextLength)];
    } else {
      return [FilteringTextInputFormatter.digitsOnly];
    }
  }

  void defineTextController(TextFormController cont) {
    textFormController = cont;
  }

  TextForm buildTextForm() {
    return TextForm(
      title: widget.title,
      enable: widget.enable,
      initialText: currentValue.toString(),
      maxCharacter: maxTextLength,
      maxLines: 1,
      icon: widget.icon,
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      inputFormatters: inputFormatters,
      fieldNames: const [],
      onCreated: defineTextController,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showButtons) {
      return buildTextForm();
    }

    return Flex(
      direction: Axis.horizontal,
      mainAxisSize: widget.expandHorizontally ? MainAxisSize.max : MainAxisSize.min,
      children: [widget.expandHorizontally ? Expanded(child: buildTextForm()) : buildTextForm()],
    );
  }
}
