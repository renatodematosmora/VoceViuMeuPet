import 'package:flutter/material.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final LinearGradient? gradient;
  final IconData? icon;
  final bool outlined;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              child: _child(),
            )
          : gradient != null
              ? _GradientButton(
                  gradient: gradient!,
                  onPressed: isLoading ? null : onPressed,
                  child: _child(),
                )
              : ElevatedButton(
                  onPressed: isLoading ? null : onPressed,
                  child: _child(),
                ),
    );
  }

  Widget _child() => isLoading
      ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        );
}

class _GradientButton extends StatefulWidget {
  final LinearGradient gradient;
  final VoidCallback? onPressed;
  final Widget child;

  const _GradientButton({
    required this.gradient,
    required this.onPressed,
    required this.child,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.onPressed == null
                ? null
                : widget.gradient,
            color: widget.onPressed == null ? Colors.grey.shade300 : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.onPressed != null ? AppTheme.primaryShadow : null,
          ),
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
