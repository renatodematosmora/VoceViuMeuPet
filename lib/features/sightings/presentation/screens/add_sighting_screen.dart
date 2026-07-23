import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/core/extensions/extensions.dart';
import 'package:voce_viu_meu_pet/core/widgets/app_button.dart';
import 'package:voce_viu_meu_pet/features/sightings/data/datasources/sighting_datasource.dart';

class AddSightingScreen extends ConsumerStatefulWidget {
  final String petId;
  const AddSightingScreen({super.key, required this.petId});

  @override
  ConsumerState<AddSightingScreen> createState() => _AddSightingScreenState();
}

class _AddSightingScreenState extends ConsumerState<AddSightingScreen> {
  final _descCtrl = TextEditingController();
  final _addressManualCtrl = TextEditingController();
  XFile? _photo;
  double? _lat;
  double? _lng;
  String _address = '';
  bool _loadingLocation = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _addressManualCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final geo = html.window.navigator.geolocation;
      final pos = await geo.getCurrentPosition(
        enableHighAccuracy: true,
        timeout: const Duration(seconds: 15),
      );
      final coords = pos.coords;
      if (coords == null || coords.latitude == null || coords.longitude == null) {
        if (mounted) {
          context.showSnackBar('Localização indisponível', isError: true);
        }
        return;
      }
      final lat = coords.latitude!.toDouble();
      final lng = coords.longitude!.toDouble();

      // Reverse geocode via Nominatim
      String addressStr = 'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}';
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&accept-language=pt-BR',
        );
        final request = await html.HttpRequest.request(
          url.toString(),
          method: 'GET',
          requestHeaders: {'User-Agent': 'VoceViuMeuPet/1.0'},
        );
        if (request.status == 200 && request.responseText != null) {
          final raw = request.responseText!;
          final start = raw.indexOf('"display_name":"');
          if (start != -1) {
            final cut = raw.substring(start + 16);
            final end = cut.indexOf('"');
            if (end != -1) {
              addressStr = cut.substring(0, end)
                  .replaceAll(r'\"', '"')
                  .replaceAll(r'\\', r'\');
            }
          }
        }
      } catch (e) {
        print('[AddSightingScreen] Erro ao fazer reverse geocode: $e');
      }

      if (mounted) {
        setState(() {
          _lat = lat;
          _lng = lng;
          _address = addressStr;
          _addressManualCtrl.text = addressStr;
        });
      }
    } catch (e) {
      print('[AddSightingScreen] Erro ao obter localização: $e');
      // Geolocation failed — user can type manually
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _useManualAddress() {
    final text = _addressManualCtrl.text.trim();
    if (text.isEmpty) {
      context.showSnackBar('Informe um endereco valido', isError: true);
      return;
    }
    setState(() {
      _address = text;
      _lat ??= -15.7801;
      _lng ??= -47.9292;
    });
    context.showSnackBar('Endereco definido!');
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (xfile != null) setState(() => _photo = xfile);
  }

  Future<void> _submit() async {
    if (_photo == null) {
      context.showSnackBar('Adicione uma foto do avistamento', isError: true);
      return;
    }
    if (_lat == null || _lng == null || _address.isEmpty) {
      context.showSnackBar('Localizacao nao disponivel. Informe o endereco manualmente.', isError: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      final ds = ref.read(sightingDataSourceProvider);
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final bytes = await _photo!.readAsBytes();
      final ext = _photo!.name.split('.').last;
      final photoUrl = await ds.uploadPhoto(
          widget.petId, '${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext', bytes);

      await ds.createSighting({
        'pet_id': widget.petId,
        'reporter_id': userId,
        'photo_url': photoUrl,
        'lat': _lat,
        'lng': _lng,
        'address': _address,
        'description': _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        'seen_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        context.showSnackBar('Avistamento registrado! O dono foi notificado.');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Erro ao registrar avistamento: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar avistamento'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto
            Text('Foto do animal *', style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showPhotoOptions(),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: _photo == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded,
                              size: 48, color: AppTheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            'Toque para tirar ou escolher uma foto',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: FutureBuilder<Uint8List>(
                          future: _photo!.readAsBytes(),
                          builder: (_, snap) {
                            if (snap.hasData) {
                              return Image.memory(
                                snap.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 220,
                              );
                            }
                            return const Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Localizacao
            Text('Localizacao *', style: context.textTheme.titleMedium),
            const SizedBox(height: 8),

            // Botao GPS
            OutlinedButton.icon(
              onPressed: _loadingLocation ? null : _getLocation,
              icon: _loadingLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: Text(_loadingLocation
                  ? 'Obtendo localizacao...'
                  : (_lat != null ? 'Atualizar GPS' : 'Usar minha localizacao (GPS)')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            // Mapa quando tem localizacao
            if (_lat != null && _lng != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 160,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(_lat!, _lng!),
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.voceviumeupet.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_lat!, _lng!),
                            width: 44,
                            height: 44,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(Icons.my_location_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 14, color: AppTheme.textSecond),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(_address, style: context.textTheme.bodySmall),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('ou informe o endereco', style: context.textTheme.bodySmall),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 10),

            // Campo endereco manual
            TextField(
              controller: _addressManualCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Endereco do avistamento',
                hintText: 'Ex: Praca da Se, Centro, Sao Paulo',
                prefixIcon: const Icon(Icons.location_on_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _useManualAddress,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Usar este endereco'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _address.isNotEmpty ? Colors.green : AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            if (_address.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_address,
                          style: const TextStyle(fontSize: 12, color: Colors.green),
                          maxLines: 2),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Descricao
            Text('Descricao (opcional)', style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(
                hintText: 'Descreva onde viu o animal, como ele estava...',
              ),
            ),

            const SizedBox(height: 28),

            AppButton(
              label: 'Confirmar avistamento',
              onPressed: _submit,
              isLoading: _submitting,
              gradient: AppTheme.primaryGradient,
              icon: Icons.send_rounded,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
