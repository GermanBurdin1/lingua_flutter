class Galaxy {
  final String name;
  final String icon;
  final List<Subtopic> subtopics;

  Galaxy({
    required this.name,
    required this.icon,
    required this.subtopics,
  });
}

class Subtopic {
  final String name;
  final String icon;

  Subtopic({
    required this.name,
    this.icon = '📌', // Default icon
  });
}

// Données des galaxies (traduites en français)
// Используем названия БЕЗ пробелов для совместимости с URL
final List<Galaxy> galaxiesData = [
  Galaxy(
    name: 'Erudition',
    icon: '🎓',
    subtopics: [
      Subtopic(name: 'Histoire', icon: '📜'),
      Subtopic(name: 'Science', icon: '🔬'),
      Subtopic(name: 'Art', icon: '🎨'),
      Subtopic(name: 'Philosophie', icon: '💭'),
      Subtopic(name: 'Technologies', icon: '💻'),
      Subtopic(name: 'Culture', icon: '🎭'),
    ],
  ),
  Galaxy(
    name: 'Relations',
    icon: '👥',
    subtopics: [
      Subtopic(name: 'Famille', icon: '👨‍👩‍👧‍👦'),
      Subtopic(name: 'Amis', icon: '🤝'),
      Subtopic(name: 'Travail', icon: '💼'),
      Subtopic(name: 'Reseaux-sociaux', icon: '📱'),
      Subtopic(name: 'Communication', icon: '💬'),
    ],
  ),
  Galaxy(
    name: 'Carriere',
    icon: '💼',
    subtopics: [
      Subtopic(name: 'Emplois', icon: '👔'),
      Subtopic(name: 'Competences', icon: '🎯'),
      Subtopic(name: 'CV', icon: '📄'),
      Subtopic(name: 'Entretien', icon: '🗣️'),
    ],
  ),
  Galaxy(
    name: 'Objets',
    icon: '🏠',
    subtopics: [
      Subtopic(name: 'Meubles', icon: '🛋️'),
      Subtopic(name: 'Technologie', icon: '📱'),
      Subtopic(name: 'Outils', icon: '🔧'),
      Subtopic(name: 'Vetements', icon: '👕'),
      Subtopic(name: 'Bijoux', icon: '💎'),
      Subtopic(name: 'Jouets', icon: '🧸'),
    ],
  ),
  Galaxy(
    name: 'Sante',
    icon: '🏥',
    subtopics: [
      Subtopic(name: 'Maladies', icon: '🤒'),
      Subtopic(name: 'Traitement', icon: '💊'),
      Subtopic(name: 'Prevention', icon: '🛡️'),
      Subtopic(name: 'Mode-de-vie-sain', icon: '🏃'),
      Subtopic(name: 'Pharmacies', icon: '💉'),
    ],
  ),
  Galaxy(
    name: 'Evenements',
    icon: '🎉',
    subtopics: [
      Subtopic(name: 'Fetes', icon: '🎊'),
      Subtopic(name: 'Catastrophes', icon: '⚠️'),
      Subtopic(name: 'Sport', icon: '⚽'),
      Subtopic(name: 'Politique', icon: '🏛️'),
    ],
  ),
];

