import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/core/extensions/extensions.dart';
import 'package:voce_viu_meu_pet/features/pets/domain/entities/pet.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;

  const PetCard({super.key, required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final daysLost = pet.lostAt.daysAgo;
    final isDark = context.isDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Foto principal ──────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: pet.mainPhoto.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: pet.mainPhoto,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: isDark
                                  ? AppTheme.cardDark
                                  : const Color(0xFFF3F4F6),
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: const Color(0xFFF3F4F6),
                              child: const Center(
                                child: Text('🐾',
                                    style: TextStyle(fontSize: 48)),
                              ),
                            ),
                          )
                        : Container(
                            color: isDark
                                ? AppTheme.cardDark
                                : const Color(0xFFF3F4F6),
                            child: const Center(
                              child: Text('🐾',
                                  style: TextStyle(fontSize: 48)),
                            ),
                          ),
                  ),
                ),

                // Badge de espécie
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${pet.species.emoji} ${pet.species.label}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Dias desaparecido
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: daysLost > 7
                          ? AppTheme.secondary.withOpacity(0.9)
                          : AppTheme.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      daysLost == 0
                          ? 'Hoje'
                          : daysLost == 1
                              ? '1 dia'
                              : '$daysLost dias',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Informações ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          style: context.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (pet.reward != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('💰',
                                  style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 3),
                              Text(
                                'Recompensa',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 14, color: AppTheme.textSecond),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          pet.lostAddress,
                          style: context.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Tag(pet.color),
                      const SizedBox(width: 6),
                      _Tag(pet.size.label.split(' ').first),
                      if (pet.breed != null) ...[
                        const SizedBox(width: 6),
                        _Tag(pet.breed!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 13, color: AppTheme.textSecond),
                      const SizedBox(width: 4),
                      Text(
                        'Desapareceu ${pet.lostAt.formattedDate}',
                        style: context.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppTheme.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
