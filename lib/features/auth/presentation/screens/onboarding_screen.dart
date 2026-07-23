import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:voce_viu_meu_pet/core/router/app_router.dart';
import 'package:voce_viu_meu_pet/core/theme/app_theme.dart';
import 'package:voce_viu_meu_pet/core/extensions/extensions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  bool _isLastPage = false;

  final _pages = [
    _OnboardingPage(
      emoji: '🐶',
      title: 'Perdeu seu amigo?',
      description: 'Cadastre seu pet com fotos, características e localização onde foi visto por último.',
    ),
    _OnboardingPage(
      emoji: '📍',
      title: 'Busca por Proximidade',
      description: 'A comunidade ajuda a encontrar! Veja os pets perdidos próximos a você e reporte avistamentos.',
    ),
    _OnboardingPage(
      emoji: '🎉',
      title: 'Reencontros Felizes',
      description: 'Juntos, aumentamos as chances de trazer cada pet de volta para casa são e salvo.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _isLastPage = index == _pages.length - 1);
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(page.emoji, style: const TextStyle(fontSize: 80)),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecond,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppTheme.primary,
                  dotColor: AppTheme.primary.withOpacity(0.2),
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: _isLastPage
                ? ElevatedButton(
                    onPressed: _finishOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Começar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: const Text('Pular'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Próximo'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.description,
  });
}
