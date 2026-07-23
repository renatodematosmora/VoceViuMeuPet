import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';

class FeedShimmer extends StatelessWidget {
  const FeedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppTheme.cardDark : const Color(0xFFE5E7EB);
    final highlight = isDark ? AppTheme.surfaceDark : Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: List.generate(
          3,
          (_) => Shimmer.fromColors(
            baseColor: base,
            highlightColor: highlight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              height: 280,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
