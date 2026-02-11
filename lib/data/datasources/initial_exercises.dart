import '../models/exercise_model.dart';

/// Полная база упражнений с противопоказаниями и целевыми мышцами
final List<Exercise> initialExercises = [
  // ===== ЛФК (Лечебная физкультура) - 12 упражнений =====
  
  const Exercise(
    id: 'lfk_cat_cow',
    title: 'Кошка-Корова',
    description: 'Встаньте на четвереньки. На вдохе прогните спину вниз, поднимая голову. На выдохе округлите спину, опуская голову.',
    difficulty: 'beginner',
    type: 'lfk',
    targetMuscles: [TargetMuscles.back, TargetMuscles.core],
    contraindications: [Contraindications.wristInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'lfk_glute_bridge',
    title: 'Ягодичный мостик',
    description: 'Лягте на спину, ноги согнуты в коленях. Поднимайте таз вверх, напрягая ягодицы, задержитесь на секунду и опуститесь.',
    difficulty: 'beginner',
    type: 'lfk',
    targetMuscles: [TargetMuscles.glutes, TargetMuscles.lowerBack, TargetMuscles.hamstrings],
    contraindications: [], // Безопасно для большинства
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'lfk_neck_turns',
    title: 'Повороты шеи',
    description: 'Плавно поворачивайте голову влево и вправо, стараясь подбородком коснуться плеча. Без резких движений.',
    difficulty: 'beginner',
    type: 'lfk',
    targetMuscles: [TargetMuscles.neck],
    contraindications: [Contraindications.cervicalHernia],
    equipment: Equipment.none,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'lfk_bird_dog',
    title: 'Птица-Собака',
    description: 'На четвереньках одновременно вытяните правую руку вперед и левую ногу назад. Держите равновесие. Смените сторону.',
    difficulty: 'intermediate',
    type: 'lfk',
    targetMuscles: [TargetMuscles.core, TargetMuscles.lowerBack, TargetMuscles.glutes],
    contraindications: [Contraindications.wristInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'lfk_pelvic_tilt',
    title: 'Наклон таза лёжа',
    description: 'Лягте на спину, колени согнуты. Напрягите пресс и прижмите поясницу к полу, затем расслабьте.',
    difficulty: 'beginner',
    type: 'lfk',
    targetMuscles: [TargetMuscles.core, TargetMuscles.lowerBack],
    contraindications: [],
    equipment: Equipment.mat,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'lfk_knee_to_chest',
    title: 'Колено к груди',
    description: 'Лягте на спину. Подтяните одно колено к груди, обхватив его руками. Задержитесь на 20 секунд, смените ногу.',
    difficulty: 'beginner',
    type: 'lfk',
    targetMuscles: [TargetMuscles.lowerBack, TargetMuscles.glutes],
    contraindications: [Contraindications.hipInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'lfk_dead_bug',
    title: 'Мёртвый жук',
    description: 'Лягте на спину, поднимите согнутые ноги и руки вверх. Одновременно опустите противоположные руку и ногу к полу, не касаясь его.',
    difficulty: 'intermediate',
    type: 'lfk',
    targetMuscles: [TargetMuscles.core, TargetMuscles.abs],
    contraindications: [],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'lfk_supine_twist',
    title: 'Скручивание лёжа',
    description: 'Лягте на спину, руки в стороны. Согнутые колени опустите вправо, голову поверните влево. Задержитесь, смените сторону.',
    difficulty: 'beginner',
    type: 'lfk',
    targetMuscles: [TargetMuscles.lowerBack, TargetMuscles.obliques],
    contraindications: [Contraindications.lumbarHernia, Contraindications.thoracicHernia],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'lfk_wall_angels',
    title: 'Ангел у стены',
    description: 'Встаньте спиной к стене, прижмите поясницу. Поднимите руки вдоль стены, как при создании снежного ангела.',
    difficulty: 'beginner',
    type: 'lfk',
    targetMuscles: [TargetMuscles.shoulders, TargetMuscles.upperBack],
    contraindications: [Contraindications.shoulderInjury],
    equipment: Equipment.wall,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'lfk_chin_tuck',
    title: 'Втягивание подбородка',
    description: 'Сидя или стоя, втяните подбородок назад, создавая "двойной подбородок". Задержитесь на 5 секунд.',
    difficulty: 'beginner',
    type: 'lfk',
    targetMuscles: [TargetMuscles.neck],
    contraindications: [],
    equipment: Equipment.none,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'lfk_shoulder_blade_squeeze',
    title: 'Сведение лопаток',
    description: 'Сидя или стоя, сведите лопатки вместе, как будто зажимаете карандаш между ними. Задержитесь на 5 секунд.',
    difficulty: 'beginner',
    type: 'lfk',
    targetMuscles: [TargetMuscles.upperBack, TargetMuscles.shoulders],
    contraindications: [],
    equipment: Equipment.none,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'lfk_thoracic_rotation',
    title: 'Ротация грудного отдела',
    description: 'На четвереньках положите руку за голову. Поворачивайте грудь и локоть вверх к потолку, затем вниз.',
    difficulty: 'intermediate',
    type: 'lfk',
    targetMuscles: [TargetMuscles.upperBack, TargetMuscles.core],
    contraindications: [Contraindications.thoracicHernia, Contraindications.wristInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),

  // ===== РАСТЯЖКА (Stretching) - 12 упражнений =====
  
  const Exercise(
    id: 'stretch_child_pose',
    title: 'Поза Ребенка',
    description: 'Сядьте на пятки, колени врозь. Наклонитесь вперед, вытянув руки перед собой, опустите лоб на пол.',
    difficulty: 'beginner',
    type: 'stretching',
    targetMuscles: [TargetMuscles.back, TargetMuscles.shoulders],
    contraindications: [Contraindications.kneeInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'stretch_forward_fold',
    title: 'Наклон вперед сидя',
    description: 'Сидя на полу с прямыми ногами, тянитесь руками к стопам. Держите спину прямой, насколько возможно.',
    difficulty: 'beginner',
    type: 'stretching',
    targetMuscles: [TargetMuscles.hamstrings, TargetMuscles.lowerBack],
    contraindications: [Contraindications.lumbarHernia],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'stretch_neck_side',
    title: 'Растяжка шеи вбок',
    description: 'Аккуратно наклоните голову к плечу, помогая рукой для легкого вытяжения боковой поверхности шеи.',
    difficulty: 'beginner',
    type: 'stretching',
    targetMuscles: [TargetMuscles.neck],
    contraindications: [Contraindications.cervicalHernia],
    equipment: Equipment.none,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'stretch_chest_door',
    title: 'Растяжка груди в проеме',
    description: 'Встаньте в дверном проеме, упритесь предплечьями в косяки и подайтесь корпусом вперед.',
    difficulty: 'beginner',
    type: 'stretching',
    targetMuscles: [TargetMuscles.chest, TargetMuscles.shoulders],
    contraindications: [Contraindications.shoulderInjury],
    equipment: Equipment.none,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'stretch_hip_flexor',
    title: 'Растяжка сгибателей бедра',
    description: 'Встаньте в выпад, заднее колено на полу. Подайте таз вперед, почувствуйте растяжение передней части бедра.',
    difficulty: 'beginner',
    type: 'stretching',
    targetMuscles: [TargetMuscles.hipFlexors, TargetMuscles.quadriceps],
    contraindications: [Contraindications.kneeInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'stretch_pigeon',
    title: 'Поза Голубя',
    description: 'Из положения на четвереньках согните правую ногу перед собой, вытяните левую назад. Опуститесь на предплечья.',
    difficulty: 'intermediate',
    type: 'stretching',
    targetMuscles: [TargetMuscles.glutes, TargetMuscles.hipFlexors],
    contraindications: [Contraindications.kneeInjury, Contraindications.hipInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 90,
  ),
  
  const Exercise(
    id: 'stretch_figure_four',
    title: 'Растяжка "Четверка"',
    description: 'Лягте на спину. Положите лодыжку правой ноги на левое колено. Подтяните левое бедро к себе.',
    difficulty: 'beginner',
    type: 'stretching',
    targetMuscles: [TargetMuscles.glutes, TargetMuscles.hipFlexors],
    contraindications: [],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'stretch_quad_standing',
    title: 'Растяжка квадрицепса стоя',
    description: 'Стоя на одной ноге, согните другую и возьмите стопу рукой, подтягивая пятку к ягодице.',
    difficulty: 'beginner',
    type: 'stretching',
    targetMuscles: [TargetMuscles.quadriceps],
    contraindications: [Contraindications.kneeInjury],
    equipment: Equipment.none,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'stretch_calf_wall',
    title: 'Растяжка икр у стены',
    description: 'Упритесь руками в стену, одну ногу отведите назад, пятка на полу. Наклоняйтесь к стене.',
    difficulty: 'beginner',
    type: 'stretching',
    targetMuscles: [TargetMuscles.calves],
    contraindications: [Contraindications.ankleInjury],
    equipment: Equipment.wall,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'stretch_tricep',
    title: 'Растяжка трицепса',
    description: 'Поднимите руку вверх, согните в локте за головой. Другой рукой мягко надавите на локоть.',
    difficulty: 'beginner',
    type: 'stretching',
    targetMuscles: [TargetMuscles.triceps],
    contraindications: [Contraindications.shoulderInjury],
    equipment: Equipment.none,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'stretch_cat_stretch',
    title: 'Кошачья растяжка',
    description: 'На четвереньках сядьте ягодицами на пятки, вытянув руки вперед по полу. Тянитесь руками вдаль.',
    difficulty: 'beginner',
    type: 'stretching',
    targetMuscles: [TargetMuscles.lowerBack, TargetMuscles.shoulders],
    contraindications: [Contraindications.kneeInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'stretch_butterfly',
    title: 'Бабочка',
    description: 'Сидя, соедините стопы, колени опустите в стороны. Мягко надавливайте локтями на колени.',
    difficulty: 'beginner',
    type: 'stretching',
    targetMuscles: [TargetMuscles.hipFlexors, TargetMuscles.glutes],
    contraindications: [Contraindications.hipInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),

  // ===== СИЛОВЫЕ (Strength) - 12 упражнений =====
  
  const Exercise(
    id: 'strength_squats',
    title: 'Приседания',
    description: 'Ноги на ширине плеч. Опускайте таз назад и вниз, как будто садитесь на стул. Спина прямая.',
    difficulty: 'beginner',
    type: 'strength',
    targetMuscles: [TargetMuscles.quadriceps, TargetMuscles.glutes, TargetMuscles.hamstrings],
    contraindications: [Contraindications.kneeInjury, Contraindications.lumbarHernia],
    equipment: Equipment.none,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'strength_pushups_knees',
    title: 'Отжимания с колен',
    description: 'Упор лежа на коленях. Сгибайте руки в локтях, опуская грудь к полу. Тело — прямая линия.',
    difficulty: 'beginner',
    type: 'strength',
    targetMuscles: [TargetMuscles.chest, TargetMuscles.triceps, TargetMuscles.shoulders],
    contraindications: [Contraindications.wristInjury, Contraindications.shoulderInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'strength_plank',
    title: 'Планка',
    description: 'Упор лежа на предплечьях. Тело прямое как струна, пресс напряжен. Держите позицию.',
    difficulty: 'intermediate',
    type: 'strength',
    targetMuscles: [TargetMuscles.core, TargetMuscles.shoulders, TargetMuscles.glutes],
    contraindications: [Contraindications.wristInjury, Contraindications.shoulderInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'strength_glute_kickback',
    title: 'Махи ногой назад',
    description: 'Стоя на четвереньках, поднимайте согнутую ногу вверх пяткой к потолку. Напрягайте ягодицу.',
    difficulty: 'beginner',
    type: 'strength',
    targetMuscles: [TargetMuscles.glutes, TargetMuscles.hamstrings],
    contraindications: [Contraindications.wristInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'strength_wall_sit',
    title: 'Стульчик у стены',
    description: 'Прислонитесь спиной к стене и опуститесь, как будто сидите на стуле. Угол в коленях 90°.',
    difficulty: 'intermediate',
    type: 'strength',
    targetMuscles: [TargetMuscles.quadriceps, TargetMuscles.glutes],
    contraindications: [Contraindications.kneeInjury],
    equipment: Equipment.wall,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'strength_superman',
    title: 'Супермен',
    description: 'Лягте на живот, руки вытянуты вперед. Одновременно поднимите руки и ноги от пола.',
    difficulty: 'intermediate',
    type: 'strength',
    targetMuscles: [TargetMuscles.lowerBack, TargetMuscles.glutes],
    contraindications: [Contraindications.lumbarHernia],
    equipment: Equipment.mat,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'strength_lunges',
    title: 'Выпады на месте',
    description: 'Шаг вперед, опуститесь до угла 90° в обоих коленях. Вернитесь в исходное положение.',
    difficulty: 'beginner',
    type: 'strength',
    targetMuscles: [TargetMuscles.quadriceps, TargetMuscles.glutes, TargetMuscles.hamstrings],
    contraindications: [Contraindications.kneeInjury, Contraindications.ankleInjury],
    equipment: Equipment.none,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'strength_crunches',
    title: 'Скручивания',
    description: 'Лягте на спину, ноги согнуты. Поднимайте верхнюю часть спины, направляя плечи к бедрам.',
    difficulty: 'beginner',
    type: 'strength',
    targetMuscles: [TargetMuscles.abs],
    contraindications: [Contraindications.cervicalHernia],
    equipment: Equipment.mat,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'strength_reverse_lunges',
    title: 'Обратные выпады',
    description: 'Шаг назад, опуститесь до угла 90° в обоих коленях. Вернитесь в исходное положение.',
    difficulty: 'beginner',
    type: 'strength',
    targetMuscles: [TargetMuscles.quadriceps, TargetMuscles.glutes],
    contraindications: [Contraindications.kneeInjury],
    equipment: Equipment.none,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'strength_tricep_dips',
    title: 'Отжимания от стула',
    description: 'Упор руками на край стула, ноги вытянуты. Сгибайте руки, опуская тело вниз.',
    difficulty: 'intermediate',
    type: 'strength',
    targetMuscles: [TargetMuscles.triceps, TargetMuscles.shoulders],
    contraindications: [Contraindications.shoulderInjury, Contraindications.wristInjury],
    equipment: Equipment.chair,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'strength_side_plank',
    title: 'Боковая планка',
    description: 'Лягте на бок, упор на предплечье. Поднимите бедра, тело — прямая линия.',
    difficulty: 'intermediate',
    type: 'strength',
    targetMuscles: [TargetMuscles.obliques, TargetMuscles.core],
    contraindications: [Contraindications.shoulderInjury, Contraindications.wristInjury],
    equipment: Equipment.mat,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'strength_calf_raises',
    title: 'Подъём на носки',
    description: 'Стоя, поднимайтесь на носки, максимально напрягая икры. Медленно опуститесь.',
    difficulty: 'beginner',
    type: 'strength',
    targetMuscles: [TargetMuscles.calves],
    contraindications: [Contraindications.ankleInjury],
    equipment: Equipment.none,
    estimatedSeconds: 45,
  ),

  // ===== КАРДИО (Cardio) - 8 упражнений =====
  
  const Exercise(
    id: 'cardio_marching',
    title: 'Марш на месте',
    description: 'Маршируйте на месте, высоко поднимая колени. Активно работайте руками.',
    difficulty: 'beginner',
    type: 'cardio',
    targetMuscles: [TargetMuscles.fullBody, TargetMuscles.quadriceps],
    contraindications: [],
    equipment: Equipment.none,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'cardio_step_touch',
    title: 'Шаг в сторону',
    description: 'Шагайте из стороны в сторону, касаясь стопой пола. Добавьте движения руками.',
    difficulty: 'beginner',
    type: 'cardio',
    targetMuscles: [TargetMuscles.quadriceps, TargetMuscles.glutes],
    contraindications: [],
    equipment: Equipment.none,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'cardio_low_impact_jacks',
    title: 'Джампинг джек без прыжка',
    description: 'Вместо прыжков поочередно отводите ноги в стороны, поднимая руки вверх.',
    difficulty: 'beginner',
    type: 'cardio',
    targetMuscles: [TargetMuscles.fullBody],
    contraindications: [Contraindications.shoulderInjury],
    equipment: Equipment.none,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'cardio_boxer_shuffle',
    title: 'Боксёрская стойка',
    description: 'Легкие перебежки с ноги на ногу в стойке боксера. Держите руки у лица.',
    difficulty: 'intermediate',
    type: 'cardio',
    targetMuscles: [TargetMuscles.calves, TargetMuscles.quadriceps],
    contraindications: [Contraindications.ankleInjury, Contraindications.kneeInjury],
    equipment: Equipment.none,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'cardio_knee_lifts',
    title: 'Подъём коленей',
    description: 'Стоя, поднимайте колени поочередно, касаясь их противоположной рукой.',
    difficulty: 'beginner',
    type: 'cardio',
    targetMuscles: [TargetMuscles.core, TargetMuscles.quadriceps],
    contraindications: [Contraindications.hipInjury],
    equipment: Equipment.none,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'cardio_arm_circles',
    title: 'Круги руками',
    description: 'Выполняйте круговые движения прямыми руками вперед и назад. Увеличивайте амплитуду.',
    difficulty: 'beginner',
    type: 'cardio',
    targetMuscles: [TargetMuscles.shoulders, TargetMuscles.arms],
    contraindications: [Contraindications.shoulderInjury],
    equipment: Equipment.none,
    estimatedSeconds: 45,
  ),
  
  const Exercise(
    id: 'cardio_standing_bicycle',
    title: 'Велосипед стоя',
    description: 'Стоя, поднимите колено и коснитесь его противоположным локтем. Чередуйте стороны.',
    difficulty: 'intermediate',
    type: 'cardio',
    targetMuscles: [TargetMuscles.core, TargetMuscles.obliques],
    contraindications: [],
    equipment: Equipment.none,
    estimatedSeconds: 60,
  ),
  
  const Exercise(
    id: 'cardio_heel_taps',
    title: 'Касание пяток',
    description: 'Маршируйте на месте, касаясь пяткой пола перед собой поочередно.',
    difficulty: 'beginner',
    type: 'cardio',
    targetMuscles: [TargetMuscles.quadriceps, TargetMuscles.calves],
    contraindications: [],
    equipment: Equipment.none,
    estimatedSeconds: 60,
  ),
];

/// Получить все упражнения, безопасные для пользователя
List<Exercise> getSafeExercises(List<String> userContraindications) {
  return initialExercises
      .where((exercise) => exercise.isSafeFor(userContraindications))
      .toList();
}

/// Получить упражнения по типу, безопасные для пользователя
List<Exercise> getSafeExercisesByType(String type, List<String> userContraindications) {
  return initialExercises
      .where((exercise) => exercise.type == type && exercise.isSafeFor(userContraindications))
      .toList();
}
