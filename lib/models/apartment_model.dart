class Apartment {
  final int id;
  final int buildingId;
  final String nameOrNumber;
  final int floorNumber;
  final bool isRented;

  Apartment({
    required this.id,
    required this.buildingId,
    required this.nameOrNumber,
    required this.floorNumber,
    this.isRented = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'building_id': buildingId,
      'name_or_number': nameOrNumber,
      'floor_number': floorNumber,
      'is_rented': isRented ? 1 : 0,
    };
  }

  factory Apartment.fromMap(Map<String, dynamic> map) {
    return Apartment(
      id: map['id'],
      buildingId: map['building_id'],
      nameOrNumber: map['name_or_number'],
      floorNumber: map['floor_number'],
      isRented: map['is_rented'] == 1,
    );
  }
}
