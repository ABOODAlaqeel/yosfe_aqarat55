class Payment {
  final int id;
  final int tenantId;
  final double amount;
  final String paymentDate;
  final String rentMonth;
  final String paymentMethod;
  final String? notes;

  Payment({
    required this.id,
    required this.tenantId,
    required this.amount,
    required this.paymentDate,
    required this.rentMonth,
    this.paymentMethod = 'نقدي',
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'amount': amount,
      'payment_date': paymentDate,
      'rent_month': rentMonth,
      'payment_method': paymentMethod,
      'notes': notes,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      tenantId: map['tenant_id'],
      amount: map['amount'],
      paymentDate: map['payment_date'],
      rentMonth: map['rent_month'],
      paymentMethod: map['payment_method'] ?? 'نقدي',
      notes: map['notes'],
    );
  }
}
