import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/profile_localization_utils.dart';
import '../../../core/utils/profile_value_utils.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../gen/app_localizations.dart';
import '../../blocs/profile/profile_cubit.dart';

class EditProfileDialog extends StatefulWidget {
  final UserProfile profile;

  const EditProfileDialog({super.key, required this.profile});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _didLocalizeInitialGoal = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLocalizeInitialGoal) return;
    _didLocalizeInitialGoal = true;

    final localizedGoal = ProfileLocalizationUtils.localizeGoal(
      AppLocalizations.of(context),
      widget.profile.goals,
    );

    if (localizedGoal.trim().isNotEmpty) {
      _goalsController.text = localizedGoal;
    }
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
    return ProfileValueUtils.normalizeActivityCode(value);
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
    final l = AppLocalizations.of(context);
    final text = (value ?? '').trim();
    if (text.isEmpty) return l.editProfileValidateName;
    if (text.length > AppConstants.maxNameLength) {
      return l.editProfileValidateNameLength(AppConstants.maxNameLength);
    }
    return null;
  }

  String? _validateAge(String? value) {
    final l = AppLocalizations.of(context);
    final age = int.tryParse((value ?? '').trim());
    if (age == null) return l.editProfileValidateAge;
    if (age < AppConstants.minAge || age > AppConstants.maxAge) {
      return l.editProfileValidateAgeRange(
        AppConstants.minAge,
        AppConstants.maxAge,
      );
    }
    return null;
  }

  String? _validateHeight(String? value) {
    final l = AppLocalizations.of(context);
    final height = _parseDouble(value ?? '');
    if (height == null) return l.editProfileValidateHeight;
    if (height < AppConstants.minHeightCm ||
        height > AppConstants.maxHeightCm) {
      return l.editProfileValidateHeightRange(
        AppConstants.minHeightCm.toInt(),
        AppConstants.maxHeightCm.toInt(),
      );
    }
    return null;
  }

  String? _validateWeight(String? value) {
    final l = AppLocalizations.of(context);
    final weight = _parseDouble(value ?? '');
    if (weight == null) return l.editProfileValidateWeight;
    if (weight < AppConstants.minWeightKg ||
        weight > AppConstants.maxWeightKg) {
      return l.editProfileValidateWeightRange(
        AppConstants.minWeightKg.toInt(),
        AppConstants.maxWeightKg.toInt(),
      );
    }
    return null;
  }

  String? _validateGoals(String? value) {
    final l = AppLocalizations.of(context);
    final text = (value ?? '').trim();
    if (text.length > AppConstants.maxGoalsLength) {
      return l.editProfileValidateGoalsLength(AppConstants.maxGoalsLength);
    }
    return null;
  }

  void _addInjury() {
    final l = AppLocalizations.of(context);
    final text = _injuryController.text.trim();
    if (text.isEmpty) return;
    if (text.length > AppConstants.maxInjuryLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.editProfileInjuryTooLong(AppConstants.maxInjuryLength),
          ),
        ),
      );
      return;
    }
    if (_injuries.length >= AppConstants.maxInjuriesCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.editProfileMaxInjuries(AppConstants.maxInjuriesCount),
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
      goals: ProfileValueUtils.normalizeGoalValue(_goalsController.text.trim()),
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
    final l = AppLocalizations.of(context);
    return TextFormField(
      controller: _ageController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      decoration: InputDecoration(
        labelText: l.editProfileAgeLabel,
        border: const OutlineInputBorder(),
        counterText: '',
      ),
      validator: _validateAge,
    );
  }

  Widget _buildHeightField() {
    final l = AppLocalizations.of(context);
    return TextFormField(
      controller: _heightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: InputDecoration(
        labelText: l.editProfileHeightLabel,
        border: const OutlineInputBorder(),
        counterText: '',
      ),
      validator: _validateHeight,
    );
  }

  Widget _buildWeightField() {
    final l = AppLocalizations.of(context);
    return TextFormField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: InputDecoration(
        labelText: l.editProfileWeightLabel,
        border: const OutlineInputBorder(),
        counterText: '',
      ),
      validator: _validateWeight,
    );
  }

  Widget _buildAddInjuryField() {
    final l = AppLocalizations.of(context);
    return TextField(
      controller: _injuryController,
      maxLength: AppConstants.maxInjuryLength,
      decoration: InputDecoration(
        labelText: l.editProfileAddInjuryLabel,
        border: const OutlineInputBorder(),
        hintText: l.editProfileAddInjuryHint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onSubmitted: (_) => _addInjury(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                l.editProfileTitle,
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
                        _buildSectionHeader(l.editProfileSectionBasic),
                        TextFormField(
                          controller: _nameController,
                          maxLength: AppConstants.maxNameLength,
                          decoration: InputDecoration(
                            labelText: l.editProfileNameLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: _validateName,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          decoration: InputDecoration(
                            labelText: l.editProfileGenderLabel,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'male',
                              child: Text(l.editProfileGenderMale),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text(l.editProfileGenderFemale),
                            ),
                            DropdownMenuItem(
                              value: 'not_specified',
                              child: Text(l.editProfileGenderNotSpecified),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedGender = value);
                            }
                          },
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader(l.editProfileSectionPhysical),
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
                        _buildSectionHeader(l.editProfileSectionGoals),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedActivity,
                          decoration: InputDecoration(
                            labelText: l.editProfileActivityLabel,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'low',
                              child: Text(l.editProfileActivityLow),
                            ),
                            DropdownMenuItem(
                              value: 'moderate',
                              child: Text(l.editProfileActivityModerate),
                            ),
                            DropdownMenuItem(
                              value: 'high',
                              child: Text(l.editProfileActivityHigh),
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
                          decoration: InputDecoration(
                            labelText: l.editProfileGoalsLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: _validateGoals,
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader(l.editProfileSectionInjuries),
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
                                    label: Text(l.editProfileAddButton),
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
                                  label: Text(l.editProfileAddButton),
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
                              child: Text(l.editProfileCancel),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _save,
                              child: Text(l.editProfileSave),
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
