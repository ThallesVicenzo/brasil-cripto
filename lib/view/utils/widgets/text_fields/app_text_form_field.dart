import 'package:brasil_cripto/view/utils/values/finals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.height,
    this.validator,
    this.errorText,
    this.onChanged,
    this.maxLines = 1,
    this.onTap,
    this.canFocus = true,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.initialValue,
    this.sufix,
    this.obscureText,
  });

  final String? label;
  final String? hintText;
  final String? errorText;
  final String? initialValue;
  final double? height;
  final int? maxLines;
  final bool canFocus;
  final bool? obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Widget? sufix;
  final TextStyle? style = const TextStyle(color: Colors.white, fontSize: 14);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: label != null ? true : false,
          child: Row(children: [Text(label ?? '')]),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            TextFormField(
              controller: controller,
              initialValue: initialValue,
              onTap: onTap,
              canRequestFocus: canFocus,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
              style: style,
              expands: maxLines == null ? true : false,
              validator: validator,
              onChanged: onChanged,
              cursorColor: Colors.white,
              obscureText: obscureText ?? false,
              decoration: InputDecoration(
                suffixIcon: sufix,
                border: outlineBorder,
                focusedBorder: outlineBorder,
                enabledBorder: outlineBorder,
                disabledBorder: outlineBorder,
                errorBorder: outlineBorder,
                focusedErrorBorder: outlineBorder,
                suffixIconColor: Colors.white,
                errorText: errorText,
                isCollapsed: maxLines == null ? true : false,
                contentPadding: const EdgeInsets.all(8),
                constraints: BoxConstraints(
                  minHeight: height ?? 48,
                  maxHeight: 96,
                ),
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
