// lib/shared/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool readOnly;
  final int maxLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false,
    this.maxLines = 1,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscure && !_showPassword,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          readOnly: widget.readOnly,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: widget.hint ?? widget.label,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 20.sp) : null,
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20.sp,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  )
                : widget.suffix,
          ),
        ),
      ],
    );
  }
}
