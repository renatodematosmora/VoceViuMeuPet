import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/core/extensions/extensions.dart';
import 'package:voce_viu_meu_pet/features/sightings/domain/entities/sighting.dart';

class PetDetailSightingsSection extends StatelessWidget {
  final List<Sighting> sightings;

  const PetDetailSightingsSection({required this.sightings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        const Divider(),
        const SizedBox(height: 16),

        // ── Avistamentos ────────────────────────────
        Text('Avistamentos recentes (${sightings.length})',
            style: context.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (sightings.isEmpty)
          Text('Nenhum avistamento registrado ainda.',
              style: context.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecond))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sightings.length,
            itemBuilder: (context, i) {
              final sighting = sightings[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: sighting.photoUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sighting.seenAt.timeAgo,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.secondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sighting.address,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (sighting.description != null && sighting.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                sighting.description!,
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
