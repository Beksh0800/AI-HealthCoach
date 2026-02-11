import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_profile_model.dart';
import '../../blocs/auth/auth_cubit.dart';
import '../../blocs/profile/profile_cubit.dart';
import 'edit_profile_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _showEditProfileDialog(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Настройки',
            onPressed: () => context.go(AppRoutes.settings),
          ),
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditProfileDialog(context, state.profile),
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
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ProfileLoaded) {
             final profile = state.profile;
             final medical = profile.medicalProfile;
             
             return SingleChildScrollView(
               padding: const EdgeInsets.all(24),
               child: Column(
                 children: [
                   const CircleAvatar(
                     radius: 50,
                     backgroundColor: AppColors.primaryLight,
                     child: Icon(Icons.person, size: 50, color: AppColors.primary),
                   ),
                   const SizedBox(height: 16),
                   Text(
                     profile.name, 
                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                       fontWeight: FontWeight.bold,
                     )
                   ),
                   Text(
                     profile.email ?? '', 
                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                       color: AppColors.textSecondary,
                     )
                   ),
                   const SizedBox(height: 32),
                   
                   _buildSectionTitle(context, 'Личные данные'),
                   Card(
                     child: Column(
                       children: [
                         _buildProfileItem(Icons.cake, 'Возраст', '${medical.age} лет'),
                         const Divider(height: 1),
                         _buildProfileItem(Icons.height, 'Рост', '${medical.height} см'),
                         const Divider(height: 1),
                         _buildProfileItem(Icons.monitor_weight, 'Вес', '${medical.weight} кг'),
                         const Divider(height: 1),
                         _buildProfileItem(Icons.female, 'Пол', medical.gender == 'male' ? 'Мужской' : 'Женский'),
                       ],
                     ),
                   ),
                   
                   const SizedBox(height: 24),
                   _buildSectionTitle(context, 'Здоровье и Цели'),
                   Card(
                     child: Column(
                       children: [
                          _buildProfileItem(Icons.directions_run, 'Активность', _localizeActivityLevel(medical.activityLevel)),
                         if (profile.goals.isNotEmpty) ...[
                           const Divider(height: 1),
                           _buildProfileItem(Icons.flag, 'Цель', profile.goals),
                         ],
                         if (medical.injuries.isNotEmpty) ...[
                           const Divider(height: 1),
                           _buildProfileItem(Icons.healing, 'Ограничения', medical.injuries.join(', ')),
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
                       label: const Text('Выйти из аккаунта'),
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
          
          return const Center(child: Text('Не удалось загрузить профиль'));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
              break;
            case 1:
              context.go(AppRoutes.workout);
              break;
            case 2:
              context.go(AppRoutes.history);
              break;
            case 3:
              // Already on profile
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Тренировка',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'История',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
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
              style: TextStyle(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  String _localizeActivityLevel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return 'Низкая';
      case 'moderate':
        return 'Умеренная';
      case 'high':
        return 'Высокая';
      default:
        return level;
    }
  }
}
