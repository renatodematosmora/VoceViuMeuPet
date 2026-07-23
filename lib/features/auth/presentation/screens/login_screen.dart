import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voce_viu_meu_pet/core/router/app_router.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/core/extensions/extensions.dart';
import 'package:voce_viu_meu_pet/features/auth/presentation/providers/auth_provider.dart';
import 'package:voce_viu_meu_pet/features/auth/presentation/widgets/social_button.dart';
import 'package:voce_viu_meu_pet/core/widgets/app_button.dart';
import 'package:voce_viu_meu_pet/core/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await ref.read(authProvider.notifier).signIn(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
    if (!mounted) return;
    if (error != null) {
      context.showSnackBar(error, isError: true);
    } else {
      context.go(AppRoutes.feed);
    }
  }

  Future<void> _loginWithGoogle() async {
    final error = await ref.read(authProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    if (error != null) context.showSnackBar(error, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // ── Header ─────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppTheme.heroGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.primaryShadow,
                      ),
                      child: const Center(
                        child: Text('🐾', style: TextStyle(fontSize: 42)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bem-vindo de volta!',
                      style: context.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Entre para ajudar a encontrar animais perdidos',
                      style: context.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── Formulário ─────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _emailCtrl,
                      label: 'E-mail',
                      hint: 'seu@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_rounded,
                      validator: (v) => (v?.isValidEmail ?? false)
                          ? null
                          : 'E-mail inválido',
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _passCtrl,
                      label: 'Senha',
                      hint: '••••••••',
                      obscureText: _obscure,
                      prefixIcon: Icons.lock_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: AppTheme.textSecond,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) => (v?.isValidPassword ?? false)
                          ? null
                          : 'Senha deve ter ao menos 8 caracteres',
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Esqueci minha senha'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      label: 'Entrar',
                      onPressed: _login,
                      isLoading: isLoading,
                      gradient: AppTheme.primaryGradient,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Divisor ────────────────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ou', style: context.textTheme.bodySmall),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              // ── Social Login ───────────────────────────────────
              SocialButton(
                label: 'Continuar com Google',
                iconAsset: 'assets/icons/google.svg',
                onPressed: isLoading ? null : _loginWithGoogle,
              ),

              const SizedBox(height: 36),

              // ── Cadastro ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Não tem conta? ', style: context.textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.register),
                    child: Text(
                      'Cadastre-se',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
