import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/notification_service.dart';

/// Settings page for configuring workout reminders.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _notificationService = sl<NotificationService>();

  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  List<int> _selectedDays = [1, 2, 3, 4, 5]; // Mon-Fri

  bool _loading = true;

  static const _dayLabels = {
    1: 'Пн',
    2: 'Вт',
    3: 'Ср',
    4: 'Чт',
    5: 'Пт',
    6: 'Сб',
    7: 'Вс',
  };

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
        title: const Text('Настройки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.profile),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReminderSection(),
                ],
              ),
            ),
    );
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
              child: const Icon(Icons.notifications_active, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Напоминания о тренировках',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Настройте время и дни для напоминаний',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Enable toggle
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SwitchListTile(
            title: const Text('Включить напоминания', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              _reminderEnabled ? 'Напоминания активны' : 'Напоминания отключены',
              style: const TextStyle(fontSize: 13),
            ),
            value: _reminderEnabled,
            activeTrackColor: AppColors.primary,
            onChanged: (value) async {
              setState(() => _reminderEnabled = value);
              await _notificationService.setEnabled(value);
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.access_time, color: AppColors.primary),
              title: const Text('Время напоминания', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                      SizedBox(width: 12),
                      Text('Дни недели', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                            color: selected ? AppColors.primary : AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? AppColors.primary : AppColors.textHint.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _dayLabels[day]!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : AppColors.textSecondary,
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
              _buildPresetChip('Будни', [1, 2, 3, 4, 5]),
              const SizedBox(width: 8),
              _buildPresetChip('Каждый день', [1, 2, 3, 4, 5, 6, 7]),
              const SizedBox(width: 8),
              _buildPresetChip('Через день', [1, 3, 5, 7]),
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
          color: isActive ? AppColors.primary : AppColors.textHint.withValues(alpha: 0.3),
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
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _reminderTime = picked);
      await _notificationService.setTime(picked.hour, picked.minute);
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
