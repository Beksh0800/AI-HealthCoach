import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/profile/profile_cubit.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../core/theme/app_colors.dart';

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
    final p = widget.profile;
    final m = p.medicalProfile;

    _nameController = TextEditingController(text: p.name);
    _ageController = TextEditingController(text: m.age.toString());
    _heightController = TextEditingController(text: m.height.toString());
    _weightController = TextEditingController(text: m.weight.toString());
    _goalsController = TextEditingController(text: p.goals);
    _injuryController = TextEditingController();

    _selectedGender = m.gender;
    _selectedActivity = _normalizeActivity(m.activityLevel);
    _injuries.addAll(m.injuries);
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

  String _normalizeActivity(String value) {
    const valid = ['low', 'moderate', 'high'];
    if (valid.contains(value)) return value;
    if (value.toLowerCase().contains('низкая') || value.toLowerCase().contains('сидячий')) return 'low';
    if (value.toLowerCase().contains('высокая')) return 'high';
    return 'moderate';
  }

  void _addInjury() {
    final text = _injuryController.text.trim();
    if (text.isNotEmpty && !_injuries.contains(text)) {
      setState(() {
        _injuries.add(text);
        _injuryController.clear();
      });
    }
  }

  void _removeInjury(String injury) {
    setState(() {
      _injuries.remove(injury);
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final goals = _goalsController.text.trim();
      final age = int.tryParse(_ageController.text);
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);

      context.read<ProfileCubit>().updateProfileField(
        name: name,
        goals: goals,
        age: age,
        height: height,
        weight: weight,
        gender: _selectedGender,
        activityLevel: _selectedActivity,
        injuries: _injuries,
      );

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                          decoration: const InputDecoration(labelText: 'Имя', border: OutlineInputBorder()),
                          validator: (v) => v?.isEmpty == true ? 'Введите имя' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(labelText: 'Пол', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'male', child: Text('Мужской')),
                            DropdownMenuItem(value: 'female', child: Text('Женский')),
                            DropdownMenuItem(value: 'not_specified', child: Text('Не указан')),
                          ],
                          onChanged: (v) => setState(() => _selectedGender = v!),
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Физические данные'),
                        Row(
                          children: [
                            Expanded(child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Возраст', border: OutlineInputBorder()),
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Рост (см)', border: OutlineInputBorder()),
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Вес (кг)', border: OutlineInputBorder()),
                            )),
                          ],
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Цели и Активность'),
                        DropdownButtonFormField<String>(
                          value: _selectedActivity,
                          decoration: const InputDecoration(labelText: 'Уровень активности', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'low', child: Text('Низкая (сидячий)')),
                            DropdownMenuItem(value: 'moderate', child: Text('Умеренная (1-3 тренировки)')),
                            DropdownMenuItem(value: 'high', child: Text('Высокая (3+ тренировок)')),
                          ],
                          onChanged: (v) => setState(() => _selectedActivity = v!),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _goalsController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Цели', border: OutlineInputBorder()),
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Травмы и ограничения'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _injuries.map((injury) => Chip(
                            label: Text(injury),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => _removeInjury(injury),
                            backgroundColor: AppColors.surface,
                            side: BorderSide(color: AppColors.neutral.shade300),
                          )).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _injuryController,
                                decoration: const InputDecoration(
                                  labelText: 'Добавить травму/ограничение',
                                  border: OutlineInputBorder(),
                                  hintText: 'Например: Боль в колене',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onSubmitted: (_) => _addInjury(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: _addInjury,
                              icon: const Icon(Icons.add),
                              tooltip: 'Добавить',
                            ),
                          ],
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
