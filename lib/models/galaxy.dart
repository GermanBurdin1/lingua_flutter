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
final List<Galaxy> galaxiesData = [
  Galaxy(
    name: 'Galaxie Erudition',
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
    name: 'Galaxie Relations',
    subtopics: [
      Subtopic(name: 'Famille'),
      Subtopic(name: 'Amis'),
      Subtopic(name: 'Travail'),
      Subtopic(name: 'Reseaux sociaux'),
      Subtopic(name: 'Communication'),
    ],
  ),
  Galaxy(
    name: 'Galaxie Carriere',
    subtopics: [
      Subtopic(name: 'Emplois'),
      Subtopic(name: 'Competences'),
      Subtopic(name: 'CV'),
      Subtopic(name: 'Entretien'),
    ],
  ),
  Galaxy(
    name: 'Galaxie Objets',
    subtopics: [
      Subtopic(name: 'Meubles'),
      Subtopic(name: 'Technologie'),
      Subtopic(name: 'Outils'),
      Subtopic(name: 'Vêtements'),
      Subtopic(name: 'Bijoux'),
      Subtopic(name: 'Jouets'),
    ],
  ),
  Galaxy(
    name: 'Galaxie Sante',
    subtopics: [
      Subtopic(name: 'Maladies'),
      Subtopic(name: 'Traitement'),
      Subtopic(name: 'Prevention'),
      Subtopic(name: 'Mode de vie sain'),
      Subtopic(name: 'Pharmacies'),
    ],
  ),
  Galaxy(
    name: 'Galaxie Evenements',
    subtopics: [
      Subtopic(name: 'Fetes'),
      Subtopic(name: 'Catastrophes'),
      Subtopic(name: 'Sport'),
      Subtopic(name: 'Politique'),
    ],
  ),
];

