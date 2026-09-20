import 'dart:math';

import '../models/quest.dart';
import '../models/quest_type.dart';

/// Static mock content pools used to generate quests without a backend.
class QuestBank {
  QuestBank._();

  static final Random _random = Random();

  static const List<Quest> _adoptQuests = [
    Quest(
      id: 'adopt_snake_plant',
      type: QuestType.adopt,
      title: 'Adopt: Snake Plant',
      description: 'Low light, low water. Perfect for a busy jungle keeper.',
      coinReward: 10,
    ),
    Quest(
      id: 'adopt_pothos',
      type: QuestType.adopt,
      title: 'Adopt: Golden Pothos',
      description: 'A fast-trailing vine that forgives missed waterings.',
      coinReward: 10,
    ),
    Quest(
      id: 'adopt_zz',
      type: QuestType.adopt,
      title: 'Adopt: ZZ Plant',
      description: 'Thrives on neglect. A great starter for dim corners.',
      coinReward: 10,
    ),
    Quest(
      id: 'adopt_calathea',
      type: QuestType.adopt,
      title: 'Adopt: Calathea',
      description: 'A drama queen that rewards humidity and attention.',
      coinReward: 15,
    ),
    Quest(
      id: 'adopt_succulent',
      type: QuestType.adopt,
      title: 'Adopt: Echeveria Succulent',
      description: 'Loves bright light and being left alone between waters.',
      coinReward: 10,
    ),
  ];

  static const List<Quest> _careQuests = [
    Quest(
      id: 'care_rotate',
      type: QuestType.care,
      title: 'Rotate Your Pot',
      description: 'Give your plant a quarter-turn so every side reaches the sun.',
      coinReward: 5,
    ),
    Quest(
      id: 'care_dust',
      type: QuestType.care,
      title: 'Dust the Leaves',
      description: 'Wipe leaves gently with a damp cloth to boost photosynthesis.',
      coinReward: 8,
    ),
    Quest(
      id: 'care_soil_check',
      type: QuestType.care,
      title: 'Check the Soil',
      description: 'Stick a finger 2 inches deep. Only water if it feels dry.',
      coinReward: 5,
    ),
    Quest(
      id: 'care_mist',
      type: QuestType.care,
      title: 'Mist the Foliage',
      description: 'A light mist raises humidity for tropical leaves.',
      coinReward: 6,
    ),
    Quest(
      id: 'care_drainage',
      type: QuestType.care,
      title: 'Check the Drainage Tray',
      description: 'Empty any standing water so roots never sit soaked.',
      coinReward: 5,
    ),
  ];

  static const List<Quest> _missionQuests = [
    Quest(
      id: 'mission_propagate',
      type: QuestType.mission,
      title: 'Propagate a Cutting',
      description: 'Snip a healthy stem below a node and root it in water.',
      coinReward: 20,
    ),
    Quest(
      id: 'mission_prune',
      type: QuestType.mission,
      title: 'Prune Dead Growth',
      description: 'Remove yellowed or dead leaves at the base to redirect energy.',
      coinReward: 15,
    ),
    Quest(
      id: 'mission_refresh_soil',
      type: QuestType.mission,
      title: 'Refresh the Soil',
      description: 'Top-dress with an inch of fresh potting mix and light fertilizer.',
      coinReward: 18,
    ),
    Quest(
      id: 'mission_repot',
      type: QuestType.mission,
      title: 'Repot Up a Size',
      description: 'Move to a pot 2 inches wider once roots start circling the base.',
      coinReward: 25,
    ),
  ];

  static const List<String> _diagnoses = [
    'Monstera tips dry: Mist leaves and move 2ft toward an east window.',
    'Yellowing lower leaves: Cut back watering by one day and check drainage holes.',
    'Leggy stems reaching for light: Rotate weekly and relocate closer to a bright window.',
    'Brown crispy edges: Raise humidity with a pebble tray or a nearby humidifier.',
    'Curling leaves: Check for spider mites on the underside and wipe with neem solution.',
    'Faint musty smell from soil: Repot into a fresh, well-draining mix immediately.',
  ];

  static const List<String> botanicalFacts = [
    'Wiping dust off leaves increases photosynthesis efficiency by up to 30%!',
    'Most houseplants originated in forest understories, so indirect light mimics home best.',
    "A plant's roots need oxygen too - overwatering suffocates them, not just floods them.",
    'Talking to your plants can help, because the CO2 you exhale feeds photosynthesis.',
    'Yellow leaves are often plants asking for less water, not more.',
    'New leaves often unfurl fastest at night when the plant redirects stored energy.',
  ];

  static Quest random(QuestType type) {
    final pool = switch (type) {
      QuestType.adopt => _adoptQuests,
      QuestType.care => _careQuests,
      QuestType.mission => _missionQuests,
      QuestType.doctor =>
        throw UnsupportedError('Doctor quests are generated dynamically from a scan.'),
    };
    return pool[_random.nextInt(pool.length)];
  }

  static String randomDiagnosis() => _diagnoses[_random.nextInt(_diagnoses.length)];

  static String randomBotanicalFact() => botanicalFacts[_random.nextInt(botanicalFacts.length)];

  static Quest buildDoctorQuest(String diagnosis) {
    return Quest(
      id: 'doctor_${DateTime.now().microsecondsSinceEpoch}',
      type: QuestType.doctor,
      title: 'Custom Diagnosis Quest',
      description: diagnosis,
      coinReward: 20,
    );
  }
}
