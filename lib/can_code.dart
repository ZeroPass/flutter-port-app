import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';

class CanCodeWidget extends StatefulWidget {
  final Function(String)? onVerified;
  final int pinLength;
  final Color? primaryColor;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const CanCodeWidget({
    Key? key,
    this.onVerified,
    this.pinLength = 6,
    this.primaryColor,
    this.controller,
    this.initialValue,
    this.onChanged,
  }) : super(key: key);

  @override
  _CanCodeWidgetState createState() => _CanCodeWidgetState();
}

class _CanCodeWidgetState extends State<CanCodeWidget> {
  late TextEditingController textEditingController;
  StreamController<ErrorAnimationType>? errorController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    textEditingController = widget.controller ?? TextEditingController(text: widget.initialValue);
    errorController = StreamController<ErrorAnimationType>.broadcast();
    super.initState();
  }

  @override
  void didUpdateWidget(CanCodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        textEditingController.dispose();
      }
      textEditingController = widget.controller ?? TextEditingController(text: widget.initialValue);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      textEditingController.dispose();
    }
    errorController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? Color(0xFFa58157);

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        child: PinCodeTextField(
          appContext: context,
          autoDisposeControllers: false,
          pastedTextStyle: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.normal,
          ),
          length: widget.pinLength,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.underline,
            borderRadius: BorderRadius.circular(5),
            activeFillColor: Colors.white70,
            inactiveFillColor: Colors.white54,
            selectedFillColor: Colors.white70,
            activeColor: primaryColor,
            inactiveColor: Colors.grey,
            selectedColor: primaryColor,
          ),
          cursorColor: Colors.black,
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          errorAnimationController: errorController,
          controller: textEditingController,
          keyboardType: TextInputType.number,
          onCompleted: (v) {
            if (widget.onVerified != null) {
              widget.onVerified?.call(v);
            }
          },
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged?.call(value);
            }
          },
        ),
      ),
    );
  }
} 