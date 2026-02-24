import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_profile_model.dart';
import '../../blocs/profile/profile_cubit.dart';

class EditProfileDialog extends StatefulWidget {
  final UserProfile profile;

  const EditProfileDialog({super.key, required this.profile});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _goalsController;
  late TextEditingController _injuryController;

  late String _selectedGender;
  late String _selectedActivity;
  final List<String> _injuries = [];

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    final medical = profile.medicalProfile;

    final safeAge = _clampIntValue(
      medical.age,
      AppConstants.minAge,
      AppConstants.maxAge,
    );
    final safeHeight = _clampDoubleValue(
      medical.height,
      AppConstants.minHeightCm,
      AppConstants.maxHeightCm,
    );
    final safeWeight = _clampDoubleValue(
      medical.weight,
      AppConstants.minWeightKg,
      AppConstants.maxWeightKg,
    );

    _nameController = TextEditingController(text: profile.name);
    _ageController = TextEditingController(text: safeAge.toString());
    _heightController = TextEditingController(text: _formatMetric(safeHeight));
    _weightController = TextEditingController(text: _formatMetric(safeWeight));
    _goalsController = TextEditingController(text: profile.goals);
    _injuryController = TextEditingController();

    _selectedGender = _normalizeGender(medical.gender);
    _selectedActivity = _normalizeActivity(medical.activityLevel);
    _injuries.addAll(
      medical.injuries
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .take(AppConstants.maxInjuriesCount),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalsController.dispose();
    _injuryController.dispose();
    super.dispose();
  }

  int _clampIntValue(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  double _clampDoubleValue(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  String _formatMetric(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  String _normalizeActivity(String value) {
    const valid = ['low', 'moderate', 'high'];
    final normalized = value.trim().toLowerCase();
    if (valid.contains(normalized)) {
      return normalized;
    }
    if (normalized.contains('низкая') || normalized.contains('сидячий')) {
      return 'low';
    }
    if (normalized.contains('высокая')) {
      return 'high';
    }
    return 'moderate';
  }

  String _normalizeGender(String value) {
    switch (value.trim().toLowerCase()) {
      case 'male':
      case 'female':
      case 'not_specified':
        return value.trim().toLowerCase();
      default:
        return 'not_specified';
    }
  }

  double? _parseDouble(String input) {
    final normalized = input.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  String? _validateName(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Введите имя';
    if (text.length > AppConstants.maxNameLength) {
      return 'Имя не длиннее ${AppConstants.maxNameLength} символов';
    }
    return null;
  }

  String? _validateAge(String? value) {
    final age = int.tryParse((value ?? '').trim());
    if (age == null) return 'Введите корректный возраст';
    if (age < AppConstants.minAge || age > AppConstants.maxAge) {
      return 'Возраст ${AppConstants.minAge}-${AppConstants.maxAge}';
    }
    return null;
  }

  String? _validateHeight(String? value) {
    final height = _parseDouble(value ?? '');
    if (height == null) return 'Введите корректный рост';
    if (height < AppConstants.minHeightCm ||
        height > AppConstants.maxHeightCm) {
      return 'Рост ${AppConstants.minHeightCm.toInt()}-${AppConstants.maxHeightCm.toInt()} см';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    final weight = _parseDouble(value ?? '');
    if (weight == null) return 'Введите корректный вес';
    if (weight < AppConstants.minWeightKg ||
        weight > AppConstants.maxWeightKg) {
      return 'Вес ${AppConstants.minWeightKg.toInt()}-${AppConstants.maxWeightKg.toInt()} кг';
    }
    return null;
  }

  String? _validateGoals(String? value) {
    final text = (value ?? '').trim();
    if (text.length > AppConstants.maxGoalsLength) {
      return 'Цель не длиннее ${AppConstants.maxGoalsLength} символов';
    }
    return null;
  }

  void _addInjury() {
    final text = _injuryController.text.trim();
    if (text.isEmpty) return;
    if (text.length > AppConstants.maxInjuryLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ограничение не длиннее ${AppConstants.maxInjuryLength} символов',
          ),
        ),
      );
      return;
    }
    if (_injuries.length >= AppConstants.maxInjuriesCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Можно добавить до ${AppConstants.maxInjuriesCount} ограничений',
          ),
        ),
      );
      return;
    }
    if (_injuries.contains(text)) return;

    setState(() {
      _injuries.add(text);
      _injuryController.clear();
    });
  }

  void _removeInjury(String injury) {
    setState(() {
      _injuries.remove(injury);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final age = int.tryParse(_ageController.text.trim());
    final height = _parseDouble(_heightController.text);
    final weight = _parseDouble(_weightController.text);

    context.read<ProfileCubit>().updateProfileField(
      name: _nameController.text.trim(),
      goals: _goalsController.text.trim(),
      age: age,
      height: height,
      weight: weight,
      gender: _selectedGender,
      activityLevel: _selectedActivity,
      injuries: _injuries,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildAgeField() {
    return TextFormField(
      controller: _ageController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      decoration: const InputDecoration(
        labelText: 'Возраст',
        border: OutlineInputBorder(),
        counterText: '',
      ),
      validator: _validateAge,
    );
  }

  Widget _buildHeightField() {
    return TextFormField(
      controller: _heightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: const InputDecoration(
        labelText: 'Рост (см)',
        border: OutlineInputBorder(),
        counterText: '',
      ),
      validator: _validateHeight,
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: const InputDecoration(
        labelText: 'Вес (кг)',
        border: OutlineInputBorder(),
        counterText: '',
      ),
      validator: _validateWeight,
    );
  }

  Widget _buildAddInjuryField() {
    return TextField(
      controller: _injuryController,
      maxLength: AppConstants.maxInjuryLength,
      decoration: const InputDecoration(
        labelText: 'Добавить травму/ограничение',
        border: OutlineInputBorder(),
        hintText: 'Например: боль в колене',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onSubmitted: (_) => _addInjury(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = MediaQuery.of(context).size.height * 0.88;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxDialogHeight),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Редактирование профиля',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Основное'),
                        TextFormField(
                          controller: _nameController,
                          maxLength: AppConstants.maxNameLength,
                          decoration: const InputDecoration(
                            labelText: 'Имя',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateName,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'Пол',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Мужской'),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Женский'),
                            ),
                            DropdownMenuItem(
                              value: 'not_specified',
                              child: Text('Не указан'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedGender = value);
                            }
                          },
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Физические данные'),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxWidth < 440;
                            if (isCompact) {
                              return Column(
                                children: [
                                  _buildAgeField(),
                                  const SizedBox(height: 12),
                                  _buildHeightField(),
                                  const SizedBox(height: 12),
                                  _buildWeightField(),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: _buildAgeField()),
                                const SizedBox(width: 12),
                                Expanded(child: _buildHeightField()),
                                const SizedBox(width: 12),
                                Expanded(child: _buildWeightField()),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Цели и Активность'),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedActivity,
                          decoration: const InputDecoration(
                            labelText: 'Уровень активности',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'low',
                              child: Text('Низкая (сидячий)'),
                            ),
                            DropdownMenuItem(
                              value: 'moderate',
                              child: Text('Умеренная (1-3 тренировки)'),
                            ),
                            DropdownMenuItem(
                              value: 'high',
                              child: Text('Высокая (3+ тренировок)'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedActivity = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _goalsController,
                          maxLength: AppConstants.maxGoalsLength,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Цели',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateGoals,
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Травмы и ограничения'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _injuries
                              .map(
                                (injury) => Chip(
                                  label: Text(injury),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () => _removeInjury(injury),
                                  backgroundColor: AppColors.surface,
                                  side: BorderSide(
                                    color: AppColors.neutral.shade300,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxWidth < 440;
                            if (isCompact) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildAddInjuryField(),
                                  const SizedBox(height: 8),
                                  FilledButton.icon(
                                    onPressed: _addInjury,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Добавить'),
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: _buildAddInjuryField()),
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  onPressed: _addInjury,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Добавить'),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Отмена'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _save,
                              child: const Text('Сохранить'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
