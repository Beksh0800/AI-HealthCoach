import 'package:flutter/material.dart';
import '../../../gen/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/router/tab_branch_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/profile_value_utils.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/errors/error_mapper.dart';
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
  String _selectedGender = 'not_specified';
  int _age = 25;
  double _weight = 70.0;
  String _activityLevel = ProfileValueUtils.activityLow;
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
        SnackBar(
          content: Text(AppLocalizations.of(context).onboardingErrorAuth),
        ),
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
        name: _name.isEmpty
            ? AppLocalizations.of(context).onboardingDefaultName
            : _name,
        email: authState.email,
        medicalProfile: MedicalProfile(
          age: _age,
          weight: _weight,
          gender: _selectedGender,
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
        context.goToTabBranch(AppTabBranch.home);
      }
    } catch (e) {
      if (mounted) {
        final message = ErrorMapper.toMessage(
          e,
          fallbackMessage: AppLocalizations.of(context).onboardingErrorSave,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            action: ErrorMapper.isRetryable(e)
                ? SnackBarAction(
                    label: AppLocalizations.of(context).onboardingRetry,
                    onPressed: _completeOnboarding,
                  )
                : null,
          ),
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
                        child: Text(
                          AppLocalizations.of(context).onboardingBtnBack,
                        ),
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
                          : Text(
                              _currentPage == 3
                                  ? AppLocalizations.of(
                                      context,
                                    ).onboardingBtnFinish
                                  : AppLocalizations.of(
                                      context,
                                    ).onboardingBtnNext,
                            ),
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
                Text(
                  AppLocalizations.of(context).onboardingWelcomeTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).onboardingWelcomeText,
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
    String getActivityLevelText(BuildContext context, String level) {
      final l10n = AppLocalizations.of(context);
      switch (ProfileValueUtils.normalizeActivityCode(level)) {
        case ProfileValueUtils.activityLow:
          return l10n.activityLevelSedentary;
        case ProfileValueUtils.activityHigh:
          return l10n.activityLevelHigh;
        default:
          return l10n.activityLevelModerate;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).onboardingBasicTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Name
          TextField(
            maxLength: AppConstants.maxNameLength,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).onboardingNameField,
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (value) => _name = value.trim(),
          ),
          const SizedBox(height: 8),

          // Gender
          Text(
            AppLocalizations.of(context).onboardingGenderTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(AppLocalizations.of(context).onboardingGenderMale),
                selected: _selectedGender == 'male',
                onSelected: (_) => setState(() => _selectedGender = 'male'),
              ),
              ChoiceChip(
                label: Text(
                  AppLocalizations.of(context).onboardingGenderFemale,
                ),
                selected: _selectedGender == 'female',
                onSelected: (_) => setState(() => _selectedGender = 'female'),
              ),
              ChoiceChip(
                label: Text(
                  AppLocalizations.of(context).onboardingGenderNotSpecified,
                ),
                selected: _selectedGender == 'not_specified',
                onSelected: (_) =>
                    setState(() => _selectedGender = 'not_specified'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Age
          Text(
            AppLocalizations.of(context).onboardingAgeText(_age),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Slider(
            value: _age.toDouble(),
            min: 16,
            max: 80,
            divisions: 64,
            label: '$_age',
            onChanged: (value) {
              setState(() => _age = value.round());
            },
          ),
          const SizedBox(height: 20),

          // Weight
          Text(
            AppLocalizations.of(
              context,
            ).onboardingWeightText(_weight.toStringAsFixed(1)),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Slider(
            value: _weight,
            min: 40,
            max: 150,
            divisions: 110,
            label: _weight.toStringAsFixed(1),
            onChanged: (value) {
              setState(() => _weight = value);
            },
          ),
          const SizedBox(height: 20),

          // Activity level
          Text(
            AppLocalizations.of(context).onboardingActivityLevelTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ProfileValueUtils.activityCodes.map((level) {
              final isSelected = _activityLevel == level;
              return ChoiceChip(
                label: Text(getActivityLevelText(context, level)),
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
    String getInjuryText(BuildContext context, String injury) {
      final l10n = AppLocalizations.of(context);
      switch (injury) {
        case 'Грыжа поясничного отдела (L4-L5, L5-S1)':
          return l10n.injuryHernia;
        case 'Протрузия межпозвонковых дисков':
          return l10n.injuryProtrusion;
        case 'Сколиоз':
          return l10n.injuryScoliosis;
        case 'Остеохондроз':
          return l10n.injuryOsteochondrosis;
        case 'Травма мениска':
          return l10n.injuryMeniscus;
        case 'Артроз коленного сустава':
          return l10n.injuryKneeArthrosis;
        case 'Артроз тазобедренного сустава':
          return l10n.injuryHipArthrosis;
        case 'Проблемы с плечевым суставом':
          return l10n.injuryShoulder;
        case 'Травма запястья':
          return l10n.injuryWrist;
        case 'Боли в шейном отделе':
          return l10n.injuryNeckPain;
        default:
          return injury;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).onboardingHealthTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).onboardingHealthText,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Injuries list
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.commonInjuries.map((injury) {
              final isSelected = _selectedInjuries.contains(injury);
              return FilterChip(
                label: Text(getInjuryText(context, injury)),
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
                    AppLocalizations.of(context).onboardingHealthInfo,
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
    final l10n = AppLocalizations.of(context);
    final goals = [
      (ProfileValueUtils.goalRelieveBackPain, l10n.goalRelieveBackPain),
      (ProfileValueUtils.goalStrengthenCore, l10n.goalStrengthenCore),
      (ProfileValueUtils.goalRecoverFromInjury, l10n.goalRecoverFromInjury),
      (ProfileValueUtils.goalImproveFlexibility, l10n.goalImproveFlexibility),
      (ProfileValueUtils.goalMaintainGeneralTone, l10n.goalMaintainGeneralTone),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingGoalsTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingGoalsText,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Goals list
          ...goals.map((goal) {
            final goalCode = goal.$1;
            final goalLabel = goal.$2;
            final isSelected = _goal == goalCode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _goal = goalCode),
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
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          goalLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
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
