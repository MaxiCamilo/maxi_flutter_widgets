import 'package:flutter/material.dart';
import 'package:maxi_flutter_widgets/maxi_flutter_widgets.dart';
import 'package:maxi_framework/maxi_framework.dart';

class FormalContractVertial extends StatefulWidget {
  final Widget child;
  final bool contracted;
  final Duration duration;
  final Curve curve;
  final bool destroy;
  final Oration title;
  final void Function(ContractVerticallyController)? onCreated;

  const FormalContractVertial({
    super.key,
    required this.child,
    this.contracted = false,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.linear,
    this.destroy = false,
    this.onCreated,
    this.title = emptyOration,
  });

  @override
  State<FormalContractVertial> createState() => _FormalContractVertialState();
}

class _FormalContractVertialState extends State<FormalContractVertial> {
  late final ContractVerticallyController controller;

  @override
  Widget build(BuildContext context) {
    return ContractVertically(contracted: widget.contracted, duration: widget.duration, curve: widget.curve, destroy: widget.destroy, onCreated: onCreatedController, child: widget.child);
  }

  void onCreatedController(ContractVerticallyController controller) {
    this.controller = controller;

    if (widget.onCreated != null) {
      widget.onCreated!(controller);
    }
  }
}
