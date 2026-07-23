import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/features/feed/presentation/providers/feed_provider.dart';
import 'package:voce_viu_meu_pet/features/pets/domain/entities/pet.dart';

class SpeciesFilterBar extends ConsumerWidget {
  const SpeciesFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(feedProvider).speciesFilter;
    final filters = [
      (null, '🐾 Todos'),
      (PetSpecies.dog.value, '🐶 Cães'),
      (PetSpecies.cat.value, '🐱 Gatos'),
      (PetSpecies.bird.value, '🐦 Aves'),
      (PetSpecies.rabbit.value, '🐰 Coelhos'),
      (PetSpecies.other.value, '🐾 Outros'),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (value, label) = filters[i];
          final isSelected = selected == value;
          return GestureDetector(
            onTap: () =>
                ref.read(feedProvider.notifier).setSpeciesFilter(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppTheme.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
