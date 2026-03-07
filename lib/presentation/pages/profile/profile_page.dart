import 'dart:async';

import 'package:flutter/material.dart';
import '../../../gen/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_localization_utils.dart';
import '../../../core/utils/profile_localization_utils.dart';
import '../../../core/utils/profile_value_utils.dart';
import '../../../data/models/user_profile_model.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/profile/profile_cubit.dart';
import '../../utils/ui_action_guard.dart';
import 'edit_profile_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Timer? _connectivityTimer;
  bool _showOfflineState = false;
  final UiActionGuard<_ProfileModalType> _actionGuard =
      UiActionGuard<_ProfileModalType>(debugLabel: 'ProfilePage');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadProfile();
    });
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }

  void _showEditProfileDialog(BuildContext context, UserProfile profile) {
    unawaited(
      _actionGuard.runModal(
        'profile_edit_dialog',
        modalType: _ProfileModalType.editProfile,
        idempotentWhenSameModalOpen: true,
        action: () => showDialog(
          context: context,
          builder: (context) => EditProfileDialog(profile: profile),
        ),
      ),
    );
  }

  void _reloadProfile() {
    if (!mounted) return;
    setState(() => _showOfflineState = false);
    context.read<ProfileCubit>().loadProfile();
    _scheduleOfflineCheck();
  }

  bool _isLoadingState(ProfileState state) {
    return state is ProfileInitial ||
        state is ProfileLoading ||
        state is ProfileUpdating;
  }

  void _scheduleOfflineCheck() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final state = context.read<ProfileCubit>().state;
      if (!_isLoadingState(state)) return;
      final hasInternet = await _hasInternetConnection();
      if (!mounted) return;
      if (!hasInternet) {
        setState(() => _showOfflineState = true);
      }
    });
  }

  Future<void> _checkInternetAndUpdateOfflineState() async {
    final hasInternet = await _hasInternetConnection();
    if (!mounted) return;
    setState(() => _showOfflineState = !hasInternet);
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _handleProfileStateChange(ProfileState state) {
    if (_isLoadingState(state)) {
      _scheduleOfflineCheck();
      return;
    }

    _connectivityTimer?.cancel();

    if (state is ProfileLoaded) {
      if (_showOfflineState) {
        setState(() => _showOfflineState = false);
      }
      return;
    }

    if (state is ProfileError || state is ProfileNotFound) {
      Future<void>.delayed(const Duration(milliseconds: 700), () async {
        if (!mounted) return;
        await _checkInternetAndUpdateOfflineState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profileTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context).settingsTitle,
            onPressed: () => context.push(AppRoutes.settings),
          ),
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      _showEditProfileDialog(context, state.profile),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().signOut();
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) => _handleProfileStateChange(state),
        builder: (context, state) {
          if (_showOfflineState) {
            return _buildOfflineState();
          }

          if (_isLoadingState(state)) {
            return _buildLoadingState();
          }

          if (state is ProfileLoaded) {
            final profile = state.profile;
            final medical = profile.medicalProfile;
            final l10n = AppLocalizations.of(context);
            final localeCode = Localizations.localeOf(context).languageCode;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    profile.email ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle(context, l10n.profilePersonalData),
                  Card(
                    child: Column(
                      children: [
                        _buildProfileItem(
                          Icons.cake,
                          l10n.profileAge,
                          ProfileValueUtils.formatAgeByLocale(
                            medical.age,
                            localeCode,
                          ),
                        ),
                        const Divider(height: 1),
                        _buildProfileItem(
                          Icons.height,
                          l10n.profileHeight,
                          '${medical.height} ${l10n.profileCm}',
                        ),
                        const Divider(height: 1),
                        _buildProfileItem(
                          Icons.monitor_weight,
                          l10n.profileWeight,
                          '${medical.weight} ${l10n.profileKg}',
                        ),
                        const Divider(height: 1),
                        _buildProfileItem(
                          Icons.wc,
                          l10n.profileGender,
                          _localizeGender(medical.gender),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle(context, l10n.profileHealthGoals),
                  Card(
                    child: Column(
                      children: [
                        _buildProfileItem(
                          Icons.directions_run,
                          l10n.profileActivity,
                          ProfileLocalizationUtils.localizeActivity(
                            l10n,
                            medical.activityLevel,
                          ),
                        ),
                        if (profile.goals.isNotEmpty) ...[
                          const Divider(height: 1),
                          _buildProfileItem(
                            Icons.flag,
                            l10n.profileGoal,
                            ProfileLocalizationUtils.localizeGoal(
                              l10n,
                              profile.goals,
                            ),
                          ),
                        ],
                        if (medical.injuries.isNotEmpty) ...[
                          const Divider(height: 1),
                          _buildProfileItem(
                            Icons.healing,
                            l10n.profileRestrictions,
                            medical.injuries
                                .map(
                                  (injury) =>
                                      ProfileLocalizationUtils.localizeInjury(
                                        l10n,
                                        injury,
                                      ),
                                )
                                .join(', '),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AuthCubit>().signOut();
                        context.go(AppRoutes.login);
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(AppLocalizations.of(context).profileSignOut),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileError) {
            return _buildErrorState(
              title: AppLocalizations.of(context).profileLoadError,
              message: ErrorLocalizationUtils.localize(
                context,
                state.errorCode,
                fallbackMessage: state.debugMessage,
              ),
            );
          }

          if (state is ProfileNotFound) {
            return _buildErrorState(
              title: AppLocalizations.of(context).profileNotFound,
              message: AppLocalizations.of(context).profileNotFoundMessage,
            );
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: 12),
          Text(AppLocalizations.of(context).profileLoading),
        ],
      ),
    );
  }

  Widget _buildOfflineState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 44,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).profileOffline,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _reloadProfile,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).profileRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({required String title, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 44, color: AppColors.warning),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _reloadProfile,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).profileRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _localizeGender(String gender) {
    switch (gender.trim().toLowerCase()) {
      case 'male':
        return AppLocalizations.of(context).profileGenderMale;
      case 'female':
        return AppLocalizations.of(context).profileGenderFemale;
      default:
        return AppLocalizations.of(context).profileGenderNotSpecified;
    }
  }
}

enum _ProfileModalType { editProfile }
