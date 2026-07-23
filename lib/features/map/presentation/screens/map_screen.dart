import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/features/feed/presentation/providers/feed_provider.dart';
import 'package:voce_viu_meu_pet/features/pets/domain/entities/pet.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedProvider);
    final pets = state.pets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de animais perdidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(feedProvider.notifier).refresh(),
          ),
        ],
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(-15.7801, -47.9292), // Brasil
          initialZoom: 5.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.voceviumeupet.app',
          ),
          MarkerLayer(
            markers: pets.map((pet) {
              return Marker(
                point: LatLng(pet.lostLat, pet.lostLng),
                width: 48,
                height: 48,
                child: GestureDetector(
                  onTap: () => context.push('/pets/${pet.id}'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.primaryShadow,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: Center(
                      child: Text(
                        pet.species.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
