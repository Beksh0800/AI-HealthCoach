import 'package:flutter/material.dart';
import '../../../gen/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/router/tab_branch_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/notification_service.dart';
import '../../blocs/locale/locale_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/ui_action_guard.dart';

/// Settings page for configuring workout reminders.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _notificationService = sl<NotificationService>();
  final UiActionGuard<_SettingsModalType> _actionGuard =
      UiActionGuard<_SettingsModalType>(debugLabel: 'SettingsPage');

  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  List<int> _selectedDays = [1, 2, 3, 4, 5]; // Mon-Fri

  bool _loading = true;

  String _getDayLabel(BuildContext context, int day) {
    final l10n = AppLocalizations.of(context);
    switch (day) {
      case 1:
        return l10n.settingsDayMon;
      case 2:
        return l10n.settingsDayTue;
      case 3:
        return l10n.settingsDayWed;
      case 4:
        return l10n.settingsDayThu;
      case 5:
        return l10n.settingsDayFri;
      case 6:
        return l10n.settingsDaySat;
      case 7:
        return l10n.settingsDaySun;
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _notificationService.isEnabled;
    final hour = await _notificationService.hour;
    final minute = await _notificationService.minute;
    final days = await _notificationService.days;

    if (mounted) {
      setState(() {
        _reminderEnabled = enabled;
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
        _selectedDays = days;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.goToTabBranch(AppTabBranch.profile);
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLanguageSection(),
                  const SizedBox(height: 24),
                  _buildReminderSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildLanguageSection() {
    final currentCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);
    final currentLabel = switch (currentCode) {
      'kk' => l10n.languageKk,
      'ru' => l10n.languageRu,
      _ => l10n.languageEn,
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.language, color: AppColors.primary),
        title: Text(
          l10n.settingsLanguage,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(l10n.settingsLanguageHint),
        trailing: Text(
          currentLabel,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        onTap: _showLanguagePicker,
      ),
    );
  }

  Future<void> _showLanguagePicker() async {
    final l10n = AppLocalizations.of(context);
    final currentCode = Localizations.localeOf(context).languageCode;

    String? selected;
    await _actionGuard.runModal(
      'settings_language_picker',
      modalType: _SettingsModalType.languagePicker,
      idempotentWhenSameModalOpen: true,
      action: () async {
        selected = await showModalBottomSheet<String>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.check),
                  title: Text(l10n.languageKk),
                  selected: currentCode == 'kk',
                  onTap: () => Navigator.of(context).pop('kk'),
                ),
                ListTile(
                  leading: const Icon(Icons.check),
                  title: Text(l10n.languageRu),
                  selected: currentCode == 'ru',
                  onTap: () => Navigator.of(context).pop('ru'),
                ),
                ListTile(
                  leading: const Icon(Icons.check),
                  title: Text(l10n.languageEn),
                  selected: currentCode == 'en',
                  onTap: () => Navigator.of(context).pop('en'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;
    await context.read<LocaleCubit>().changeLocale(selected!);
  }

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primaryLight.withValues(alpha: 0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).settingsWorkoutReminders,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context).settingsConfigureReminders,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Enable toggle
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SwitchListTile(
            title: Text(
              AppLocalizations.of(context).settingsEnableReminders,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _reminderEnabled
                  ? AppLocalizations.of(context).settingsRemindersActive
                  : AppLocalizations.of(context).settingsRemindersOff,
              style: const TextStyle(fontSize: 13),
            ),
            value: _reminderEnabled,
            activeTrackColor: AppColors.primary,
            onChanged: (value) async {
              setState(() => _reminderEnabled = value);
              final success = await _notificationService.setEnabled(value);
              if (!success && mounted) {
                setState(() => _reminderEnabled = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).settingsPermissionDenied,
                    ),
                  ),
                );
              }
            },
            secondary: Icon(
              _reminderEnabled ? Icons.alarm_on : Icons.alarm_off,
              color: _reminderEnabled ? AppColors.primary : AppColors.textHint,
            ),
          ),
        ),

        // Time & Days (only when enabled)
        if (_reminderEnabled) ...[
          const SizedBox(height: 12),

          // Time picker card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.access_time, color: AppColors.primary),
              title: Text(
                AppLocalizations.of(context).settingsReminderTime,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _reminderTime.format(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              onTap: _pickTime,
            ),
          ),

          const SizedBox(height: 12),

          // Day selector card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context).settingsDaysOfWeek,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      final selected = _selectedDays.contains(day);
                      return GestureDetector(
                        onTap: () => _toggleDay(day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textHint.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getDayLabel(context, day),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick presets
          Row(
            children: [
              _buildPresetChip(AppLocalizations.of(context).settingsWeekdays, [
                1,
                2,
                3,
                4,
                5,
              ]),
              const SizedBox(width: 8),
              _buildPresetChip(AppLocalizations.of(context).settingsEveryDay, [
                1,
                2,
                3,
                4,
                5,
                6,
                7,
              ]),
              const SizedBox(width: 8),
              _buildPresetChip(
                AppLocalizations.of(context).settingsEveryOtherDay,
                [1, 3, 5, 7],
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPresetChip(String label, List<int> days) {
    final isActive = _listEquals(_selectedDays, days);
    return GestureDetector(
      onTap: () async {
        setState(() => _selectedDays = List.from(days));
        await _notificationService.setDays(days);
      },
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
        backgroundColor: isActive ? AppColors.primary : AppColors.background,
        side: BorderSide(
          color: isActive
              ? AppColors.primary
              : AppColors.textHint.withValues(alpha: 0.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    final sa = List<int>.from(a)..sort();
    final sb = List<int>.from(b)..sort();
    for (int i = 0; i < sa.length; i++) {
      if (sa[i] != sb[i]) return false;
    }
    return true;
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked;
    await _actionGuard.runModal(
      'settings_time_picker',
      modalType: _SettingsModalType.timePicker,
      idempotentWhenSameModalOpen: true,
      action: () async {
        picked = await showTimePicker(
          context: context,
          initialTime: _reminderTime,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _reminderTime = picked!);
      await _notificationService.setTime(picked!.hour, picked!.minute);
    }
  }

  void _toggleDay(int day) async {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(day);
        }
      } else {
        _selectedDays.add(day);
      }
    });
    await _notificationService.setDays(_selectedDays);
  }
}

enum _SettingsModalType { languagePicker, timePicker }
