import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/core/extensions/extensions.dart';
import 'package:voce_viu_meu_pet/core/widgets/app_button.dart';
import 'package:voce_viu_meu_pet/core/widgets/app_text_field.dart';
import 'package:voce_viu_meu_pet/features/auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentProfileProvider);
    _nameCtrl.text = profile?.fullName ?? '';
    _cityCtrl.text = profile?.city ?? '';
    _phoneCtrl.text = profile?.phone ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await ref.read(authProvider.notifier).updateProfile({
      'full_name': _nameCtrl.text.trim(),
      'city': _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    });
    if (!mounted) return;
    if (error != null) {
      context.showSnackBar(error, isError: true);
    } else {
      context.showSnackBar('Perfil atualizado com sucesso!');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Nome completo',
                  prefixIcon: Icons.person_rounded,
                  validator: (v) => (v?.trim().length ?? 0) >= 3
                      ? null
                      : 'Informe seu nome',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _cityCtrl,
                  label: 'Cidade',
                  hint: 'Ex: São Paulo - SP',
                  prefixIcon: Icons.location_city_rounded,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneCtrl,
                  label: 'Telefone (opcional)',
                  hint: '(11) 99999-9999',
                  prefixIcon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Salvar alterações',
                  onPressed: _save,
                  isLoading: isLoading,
                  gradient: AppTheme.primaryGradient,
                  icon: Icons.check_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
