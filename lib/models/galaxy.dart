class Galaxy {
  final String name;
  final List<Subtopic> subtopics;

  Galaxy({
    required this.name,
    required this.subtopics,
  });
}

class Subtopic {
  final String name;

  Subtopic({required this.name});
}

// Données des galaxies (traduites en français)
// Используем названия БЕЗ пробелов для совместимости с URL
final List<Galaxy> galaxiesData = [
  Galaxy(
    name: 'Erudition',
    subtopics: [
      Subtopic(name: 'Histoire'),
      Subtopic(name: 'Science'),
      Subtopic(name: 'Art'),
      Subtopic(name: 'Philosophie'),
      Subtopic(name: 'Technologies'),
      Subtopic(name: 'Culture'),
    ],
  ),
  Galaxy(
    name: 'Relations',
    subtopics: [
      Subtopic(name: 'Famille'),
      Subtopic(name: 'Amis'),
      Subtopic(name: 'Travail'),
      Subtopic(name: 'Reseaux-sociaux'),
      Subtopic(name: 'Communication'),
    ],
  ),
  Galaxy(
    name: 'Carriere',
    subtopics: [
      Subtopic(name: 'Emplois'),
      Subtopic(name: 'Competences'),
      Subtopic(name: 'CV'),
      Subtopic(name: 'Entretien'),
    ],
  ),
  Galaxy(
    name: 'Objets',
    subtopics: [
      Subtopic(name: 'Meubles'),
      Subtopic(name: 'Technologie'),
      Subtopic(name: 'Outils'),
      Subtopic(name: 'Vetements'),
      Subtopic(name: 'Bijoux'),
      Subtopic(name: 'Jouets'),
    ],
  ),
  Galaxy(
    name: 'Sante',
    subtopics: [
      Subtopic(name: 'Maladies'),
      Subtopic(name: 'Traitement'),
      Subtopic(name: 'Prevention'),
      Subtopic(name: 'Mode-de-vie-sain'),
      Subtopic(name: 'Pharmacies'),
    ],
  ),
  Galaxy(
    name: 'Evenements',
    subtopics: [
      Subtopic(name: 'Fetes'),
      Subtopic(name: 'Catastrophes'),
      Subtopic(name: 'Sport'),
      Subtopic(name: 'Politique'),
    ],
  ),
];

