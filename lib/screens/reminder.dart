class Reminder {
  String name;
  DateTime dateTime;
  String place;
  String description;

  Reminder({
    required this.name,
    required this.dateTime,
    required this.place,
    required this.description,
  });

  // Convierte un Recordatorio en un mapa para guardarlo
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateTime': dateTime.toIso8601String(), // Guardamos la fecha como ISO8601
      'place': place,
      'description': description,
    };
  }

  // Convierte un mapa en un Recordatorio
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      name: map['name'],
      dateTime: DateTime.parse(map['dateTime']), // Parseamos correctamente la fecha
      place: map['place'],
      description: map['description'],
    );
  }
}
