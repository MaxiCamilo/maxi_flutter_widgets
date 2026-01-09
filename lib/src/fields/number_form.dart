import 'package:flutter/material.dart';
import 'package:maxi_flutter_widgets/src/architecture/reactive_state.dart';
import 'package:maxi_flutter_widgets/src/fields/controllers/number_form_controller.dart';
import 'package:maxi_framework/maxi_framework.dart';

class NumberForm extends StatefulWidget {
  final bool enable;
  final Oration title;
  final Widget? icon;
  final num? minimum;
  final num? maximum;
  final double interval;
  final int maxDecimalDigit;
  final bool isDecimal;
  final bool showButtons;
  final bool expandHorizontally;
  final void Function(NumberFormController cont)? onCreated;
  final void Function(Result<num> value)? onSubmitted;
  

 

  @override
   State<NumberForm> createState() => _NumberFormState();
}

class _NumberFormState extends State<NumberForm> with ReactiveState<NumberForm> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
