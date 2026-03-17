class Building {
  final int id;
  final String name;
  final int floorsCount;
  final int apartmentsCount;
  final String rentCycle;
  final bool autoNameApartments;
  final String? createdAt;

  Building({
    required this.id,
    required this.name,
    required this.floorsCount,
    required this.apartmentsCount,
    this.rentCycle = 'شهري',
    this.autoNameApartments = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'floors_count': floorsCount,
      'apartments_count': apartmentsCount,
      'rent_cycle': rentCycle,
      'auto_name_apartments': autoNameApartments ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Building.fromMap(Map<String, dynamic> map) {
    return Building(
      id: map['id'],
      name: map['name'],
      floorsCount: map['floors_count'],
      apartmentsCount: map['apartments_count'],
      rentCycle: map['rent_cycle'] ?? 'شهري',
      autoNameApartments: map['auto_name_apartments'] == 1,
      createdAt: map['created_at'],
    );
  }
}
