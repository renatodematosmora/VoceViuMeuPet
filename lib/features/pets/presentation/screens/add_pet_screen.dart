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
import 'package:voce_viu_meu_pet/core/widgets/app_text_field.dart';
import 'package:voce_viu_meu_pet/features/pets/data/datasources/pet_datasource.dart';
import 'package:voce_viu_meu_pet/features/pets/domain/entities/pet.dart';

class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _pageCtrl = PageController();
  int _step = 0;

  // Dados do formulário
  final List<XFile> _photos = [];
  final _nameCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _rewardCtrl = TextEditingController();
  final _addressManualCtrl = TextEditingController();
  PetSpecies _species = PetSpecies.dog;
  PetSize _size = PetSize.medium;
  DateTime _lostAt = DateTime.now();
  double? _lat;
  double? _lng;
  String _address = '';
  bool _gettingLocation = false;
  bool _submitting = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _colorCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _descCtrl.dispose();
    _rewardCtrl.dispose();
    _addressManualCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _gettingLocation = true);
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

      // Reverse geocode via Nominatim (gratuito, sem API key)
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
          // Parse manual sem JSON nativo (usa dart:convert)
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
        print('[AddPetScreen] Erro ao fazer reverse geocode: $e');
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
      if (mounted) {
        context.showSnackBar(
          'Nao foi possivel obter a localizacao automatica. Informe o endereco manualmente abaixo.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  void _useManualAddress() {
    final text = _addressManualCtrl.text.trim();
    if (text.isEmpty) {
      context.showSnackBar('Informe um endereco valido', isError: true);
      return;
    }
    // Coordenadas aproximadas do Brasil para quando o usuario digita o endereço manualmente
    // (sem lat/lng real, usaremos 0,0 como placeholder até termos geocoding)
    setState(() {
      _address = text;
      // Se ainda nao tiver lat/lng, usar centro do Brasil como fallback
      _lat ??= -15.7801;
      _lng ??= -47.9292;
    });
    context.showSnackBar('Endereco definido!');
  }

  void _nextStep() {
    if (_step == 0 && _photos.isEmpty) {
      context.showSnackBar('Adicione ao menos uma foto', isError: true);
      return;
    }
    if (_step == 1) {
      if (_nameCtrl.text.trim().isEmpty) {
        context.showSnackBar('Informe o nome do animal', isError: true);
        return;
      }
      if (_colorCtrl.text.trim().isEmpty) {
        context.showSnackBar('Informe a cor do animal', isError: true);
        return;
      }
    }
    if (_step < 2) {
      setState(() => _step++);
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    if (_lat == null || _lng == null || _address.isEmpty) {
      context.showSnackBar('Localizacao necessaria', isError: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      final ds = ref.read(petDataSourceProvider);
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // Upload fotos
      final photoUrls = <String>[];
      for (int i = 0; i < _photos.length; i++) {
        final bytes = await _photos[i].readAsBytes();
        final ext = _photos[i].name.split('.').last;
        final url = await ds.uploadPhoto(
          'temp',
          '${userId}_${DateTime.now().millisecondsSinceEpoch}_$i.$ext',
          bytes,
        );
        photoUrls.add(url);
      }

      await ds.createPet({
        'owner_id': userId,
        'name': _nameCtrl.text.trim(),
        'species': _species.value,
        'breed': _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
        'color': _colorCtrl.text.trim(),
        'size': _size.value,
        'age_approx': _ageCtrl.text.trim().isEmpty ? null : _ageCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'reward': _rewardCtrl.text.trim().isEmpty ? null : _rewardCtrl.text.trim(),
        'lost_at': _lostAt.toIso8601String(),
        'lost_lat': _lat,
        'lost_lng': _lng,
        'lost_address': _address,
        'photos': photoUrls,
      });

      if (mounted) {
        context.showSnackBar('Publicado! A comunidade vai ajudar!');
        context.pop();
      }
    } catch (e) {
      print('[AddPetScreen] Erro completo ao cadastrar: $e');
      if (mounted) {
        context.showSnackBar('Erro ao cadastrar animal. Tente novamente.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar animal perdido'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Barra de progresso
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? AppTheme.primary
                          : AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Passo ${_step + 1} de 3 — ${[
                    'Fotos',
                    'Dados',
                    'Localizacao'
                  ][_step]}',
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Paginas
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _PhotoStep(
                  photos: _photos,
                  onAdd: (f) => setState(() => _photos.add(f)),
                  onRemove: (i) => setState(() => _photos.removeAt(i)),
                ),
                _DataStep(
                  nameCtrl: _nameCtrl,
                  colorCtrl: _colorCtrl,
                  breedCtrl: _breedCtrl,
                  ageCtrl: _ageCtrl,
                  descCtrl: _descCtrl,
                  rewardCtrl: _rewardCtrl,
                  species: _species,
                  size: _size,
                  onSpecies: (v) => setState(() => _species = v),
                  onSize: (v) => setState(() => _size = v),
                ),
                _LocationStep(
                  lat: _lat,
                  lng: _lng,
                  address: _address,
                  lostAt: _lostAt,
                  gettingLocation: _gettingLocation,
                  addressManualCtrl: _addressManualCtrl,
                  onDateChange: (d) => setState(() => _lostAt = d),
                  onGetLocation: _getLocation,
                  onUseManual: _useManualAddress,
                ),
              ],
            ),
          ),

          // Botao proximo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: AppButton(
              label: _step < 2 ? 'Proximo' : 'Publicar',
              onPressed: _nextStep,
              isLoading: _submitting,
              gradient: AppTheme.primaryGradient,
              icon: _step < 2 ? Icons.arrow_forward_rounded : Icons.check_rounded,
            ),
          ),
          SafeArea(
            top: false,
            child: const SizedBox(height: 8),
          ),
        ],
      ),
    );
  }
}

// Passo 1: Fotos
class _PhotoStep extends StatelessWidget {
  final List<XFile> photos;
  final void Function(XFile) onAdd;
  final void Function(int) onRemove;

  const _PhotoStep({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null) onAdd(pickedFile);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adicione fotos do seu animal',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Adicione ate 5 fotos (obrigatorio). Fotos claras ajudam no reconhecimento.',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photos.length < 5 ? photos.length + 1 : photos.length,
            itemBuilder: (context, i) {
              if (i == photos.length && photos.length < 5) {
                return GestureDetector(
                  onTap: () => _pick(context, ImageSource.camera),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded, color: AppTheme.primary),
                        SizedBox(height: 4),
                        Text(
                          'Adicionar',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FutureBuilder<Uint8List>(
                      future: photos[i].readAsBytes(),
                      builder: (_, snap) => snap.hasData
                          ? Image.memory(snap.data!, fit: BoxFit.cover)
                          : Container(color: AppTheme.divider),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Passo 2: Dados
class _DataStep extends StatelessWidget {
  final TextEditingController nameCtrl, colorCtrl, breedCtrl, ageCtrl,
      descCtrl, rewardCtrl;
  final PetSpecies species;
  final PetSize size;
  final void Function(PetSpecies) onSpecies;
  final void Function(PetSize) onSize;

  const _DataStep({
    required this.nameCtrl,
    required this.colorCtrl,
    required this.breedCtrl,
    required this.ageCtrl,
    required this.descCtrl,
    required this.rewardCtrl,
    required this.species,
    required this.size,
    required this.onSpecies,
    required this.onSize,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dados do animal', style: context.textTheme.headlineSmall),
          const SizedBox(height: 20),

          AppTextField(controller: nameCtrl, label: 'Nome *', hint: 'Ex: Rex, Bolinha...', prefixIcon: Icons.pets_rounded),
          const SizedBox(height: 14),

          Text('Especie *', style: context.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: PetSpecies.values.map((s) {
              final sel = s == species;
              return ChoiceChip(
                label: Text('${s.emoji} ${s.label}'),
                selected: sel,
                onSelected: (_) => onSpecies(s),
                selectedColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: sel ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: AppTextField(controller: colorCtrl, label: 'Cor *', hint: 'Ex: Caramelo', prefixIcon: Icons.palette_rounded)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(controller: breedCtrl, label: 'Raca', hint: 'Opcional')),
            ],
          ),
          const SizedBox(height: 14),

          Text('Porte *', style: context.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: PetSize.values.map((s) {
              final sel = s == size;
              return ChoiceChip(
                label: Text(s.label.split(' ').first),
                selected: sel,
                onSelected: (_) => onSize(s),
                selectedColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: sel ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          AppTextField(controller: ageCtrl, label: 'Idade aproximada', hint: 'Ex: 2 anos, Filhote', prefixIcon: Icons.cake_rounded),
          const SizedBox(height: 14),
          AppTextField(controller: descCtrl, label: 'Descricao *', hint: 'Descreva caracteristicas especiais, coleira, microchip...', maxLines: 3),
          const SizedBox(height: 14),
          AppTextField(controller: rewardCtrl, label: 'Recompensa (opcional)', hint: 'Ex: R\$ 200,00', prefixIcon: Icons.monetization_on_rounded),
        ],
      ),
    );
  }
}

// Passo 3: Localizacao
class _LocationStep extends StatelessWidget {
  final double? lat;
  final double? lng;
  final String address;
  final DateTime lostAt;
  final bool gettingLocation;
  final TextEditingController addressManualCtrl;
  final void Function(DateTime) onDateChange;
  final VoidCallback onGetLocation;
  final VoidCallback onUseManual;

  const _LocationStep({
    required this.lat,
    required this.lng,
    required this.address,
    required this.lostAt,
    required this.gettingLocation,
    required this.addressManualCtrl,
    required this.onDateChange,
    required this.onGetLocation,
    required this.onUseManual,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Onde e quando sumiu?', style: context.textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Informe o local aproximado do desaparecimento.',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Data
          Text('Data do desaparecimento *', style: context.textTheme.titleSmall),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: lostAt,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (selectedDate != null) onDateChange(selectedDate);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: AppTheme.textSecond, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '${lostAt.day.toString().padLeft(2, '0')}/${lostAt.month.toString().padLeft(2, '0')}/${lostAt.year}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text('Localizacao *', style: context.textTheme.titleSmall),
          const SizedBox(height: 8),

          // Botao GPS
          OutlinedButton.icon(
            onPressed: gettingLocation ? null : onGetLocation,
            icon: gettingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            label: Text(gettingLocation
                ? 'Obtendo localizacao...'
                : (lat != null ? 'Atualizar localizacao GPS' : 'Usar localizacao atual (GPS)')),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 12),

          // Mapa quando tem localizacao
          if (lat != null && lng != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 180,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(lat!, lng!),
                    initialZoom: 15,
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
                          point: LatLng(lat!, lng!),
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: const Icon(Icons.pets_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Divisor
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
          const SizedBox(height: 12),

          // Campo de endereco manual
          AppTextField(
            controller: addressManualCtrl,
            label: 'Endereco do desaparecimento',
            hint: 'Ex: Rua das Flores, 123, Bairro, Cidade - Estado',
            prefixIcon: Icons.location_on_rounded,
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onUseManual,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Usar este endereco'),
              style: ElevatedButton.styleFrom(
                backgroundColor: address.isNotEmpty ? Colors.green : AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (address.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
