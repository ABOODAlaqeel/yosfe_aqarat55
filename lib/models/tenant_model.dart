class Tenant {
  final int id;
  final int apartmentId;
  final String name;
  final String? phone;
  final double rentAmount;
  final String? contractImagePath;
  final String? startDate;
  final String? notes;
  final int isActive; // 1 for active, 0 for inactive/evicted

  Tenant({
    required this.id,
    required this.apartmentId,
    required this.name,
    this.phone,
    required this.rentAmount,
    this.contractImagePath,
    this.startDate,
    this.notes,
    this.isActive = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'apartment_id': apartmentId,
      'name': name,
      'phone': phone,
      'rent_amount': rentAmount,
      'contract_image_path': contractImagePath,
      'start_date': startDate,
      'notes': notes,
      'is_active': isActive,
    };
  }

  factory Tenant.fromMap(Map<String, dynamic> map) {
    return Tenant(
      id: map['id'],
      apartmentId: map['apartment_id'],
      name: map['name'],
      phone: map['phone'],
      rentAmount: map['rent_amount'],
      contractImagePath: map['contract_image_path'],
      startDate: map['start_date'],
      notes: map['notes'],
      isActive: map['is_active'] ?? 1,
    );
  }
}
