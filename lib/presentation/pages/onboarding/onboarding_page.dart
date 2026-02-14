import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../blocs/auth/auth_cubit.dart';

/// Onboarding page - collects user health profile
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSaving = false;

  // Form data
  String _name = '';
  int _age = 25;
  double _weight = 70.0;
  String _activityLevel = AppConstants.activityLevels[0];
  final Set<String> _selectedInjuries = {};
  String _goal = '';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('РћС€РёР±РєР°: РїРѕР»СЊР·РѕРІР°С‚РµР»СЊ РЅРµ Р°РІС‚РѕСЂРёР·РѕРІР°РЅ')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Generate contraindications based on injuries
      final contraindications = MedicalProfile.generateContraindications(
        _selectedInjuries.toList(),
        AppConstants.contraindicationsMap,
      );

      // Create user profile
      final profile = UserProfile(
        uid: authState.uid,
        name: _name.isEmpty ? 'РџРѕР»СЊР·РѕРІР°С‚РµР»СЊ' : _name,
        email: authState.email,
        medicalProfile: MedicalProfile(
          age: _age,
          weight: _weight,
          activityLevel: _activityLevel,
          injuries: _selectedInjuries.toList(),
          contraindications: contraindications,
        ),
        goals: _goal,
      );

      // Save to Firestore
      final userRepository = sl<UserRepository>();
      await userRepository.saveUserProfile(profile);

      // Update auth state
      if (mounted) {
        context.read<AuthCubit>().markOnboardingCompleted();
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('РћС€РёР±РєР° СЃРѕС…СЂР°РЅРµРЅРёСЏ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.primary
                            : AppColors.primaryLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildWelcomePage(),
                  _buildBasicInfoPage(),
                  _buildHealthInfoPage(),
                  _buildGoalsPage(),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : _previousPage,
                        child: const Text('РќР°Р·Р°Рґ'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _nextPage,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_currentPage == 3 ? 'Р—Р°РІРµСЂС€РёС‚СЊ' : 'Р”Р°Р»РµРµ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Добро пожаловать!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Давайте создадим твой персональный профиль здоровья, чтобы тренировки были безопасными и эффективными.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Р Р°СЃСЃРєР°Р¶Рё Рѕ СЃРµР±Рµ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Name
          TextField(
            decoration: const InputDecoration(
              labelText: 'РРјСЏ',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (value) => _name = value,
          ),
          const SizedBox(height: 20),

          // Age
          Text(
            'Р’РѕР·СЂР°СЃС‚: $_age Р»РµС‚',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Slider(
            value: _age.toDouble(),
            min: 16,
            max: 80,
            divisions: 64,
            label: '$_age Р»РµС‚',
            onChanged: (value) {
              setState(() => _age = value.round());
            },
          ),
          const SizedBox(height: 20),

          // Weight
          Text(
            'Р’РµСЃ: ${_weight.toStringAsFixed(1)} РєРі',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Slider(
            value: _weight,
            min: 40,
            max: 150,
            divisions: 110,
            label: '${_weight.toStringAsFixed(1)} РєРі',
            onChanged: (value) {
              setState(() => _weight = value);
            },
          ),
          const SizedBox(height: 20),

          // Activity level
          const Text(
            'РЈСЂРѕРІРµРЅСЊ Р°РєС‚РёРІРЅРѕСЃС‚Рё',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.activityLevels.map((level) {
              final isSelected = _activityLevel == level;
              return ChoiceChip(
                label: Text(level),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _activityLevel = level);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'РџСЂРѕР±Р»РµРјС‹ СЃРѕ Р·РґРѕСЂРѕРІСЊРµРј',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Р’С‹Р±РµСЂРё РІСЃС‘, С‡С‚Рѕ Рє С‚РµР±Рµ РѕС‚РЅРѕСЃРёС‚СЃСЏ. '
            'Р­С‚Рѕ РїРѕРјРѕР¶РµС‚ РёСЃРєР»СЋС‡РёС‚СЊ РѕРїР°СЃРЅС‹Рµ СѓРїСЂР°Р¶РЅРµРЅРёСЏ.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Injuries list
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.commonInjuries.map((injury) {
              final isSelected = _selectedInjuries.contains(injury);
              return FilterChip(
                label: Text(injury),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInjuries.add(injury);
                    } else {
                      _selectedInjuries.remove(injury);
                    }
                  });
                },
                selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Р•СЃР»Рё Сѓ С‚РµР±СЏ РЅРµС‚ РїСЂРѕР±Р»РµРј СЃРѕ Р·РґРѕСЂРѕРІСЊРµРј, РїСЂРѕСЃС‚Рѕ РЅР°Р¶РјРё "Р”Р°Р»РµРµ"',
                    style: TextStyle(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    final goals = [
      'РР·Р±Р°РІРёС‚СЊСЃСЏ РѕС‚ Р±РѕР»РµР№ РІ СЃРїРёРЅРµ',
      'РЈРєСЂРµРїРёС‚СЊ РјС‹С€РµС‡РЅС‹Р№ РєРѕСЂСЃРµС‚',
      'Р’РѕСЃСЃС‚Р°РЅРѕРІРёС‚СЊСЃСЏ РїРѕСЃР»Рµ С‚СЂР°РІРјС‹',
      'РЈР»СѓС‡С€РёС‚СЊ РіРёР±РєРѕСЃС‚СЊ',
      'РџРѕРґРґРµСЂР¶Р°С‚СЊ РѕР±С‰РёР№ С‚РѕРЅСѓСЃ',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'РўРІРѕСЏ С†РµР»СЊ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Р§С‚Рѕ РґР»СЏ С‚РµР±СЏ СЃРµР№С‡Р°СЃ РІР°Р¶РЅРµРµ РІСЃРµРіРѕ?',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Goals list
          ...goals.map((goal) {
            final isSelected = _goal == goal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _goal = goal),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          goal,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
