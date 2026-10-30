import '../../domain/entities/pet.dart';

String sizeLabel(PetSize? value) => switch (value) {
  PetSize.small => 'Pequeño',
  PetSize.medium => 'Mediano',
  PetSize.large => 'Grande',
  null => 'Sin especificar',
};

String speciesLabel(PetSpecies? value) => switch (value) {
  PetSpecies.dog => 'Perro',
  PetSpecies.cat => 'Gato',
  PetSpecies.other => 'Otra especie',
  null => 'Sin especificar',
};
String sexLabel(PetSex? value) => switch (value) {
  PetSex.male => 'Macho',
  PetSex.female => 'Hembra',
  null => 'No lo sé',
};
String ageLabel(int? months) =>
    months == null ? 'No lo sé' : '$months ${months == 1 ? 'mes' : 'meses'}';
