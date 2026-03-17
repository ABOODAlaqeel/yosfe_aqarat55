import '../models/building_model.dart';
import '../models/apartment_model.dart';
import '../models/tenant_model.dart';
import '../models/payment_model.dart';

class DummyData {
  static List<Building> buildings = [
    Building(
        id: 1,
        name: 'برج السلام',
        floorsCount: 4,
        apartmentsCount: 8,
        createdAt: '2026-01-10'),
    Building(
        id: 2,
        name: 'عمارة الياسمين',
        floorsCount: 3,
        apartmentsCount: 6,
        createdAt: '2026-02-15'),
  ];

  static List<Apartment> apartments = [
    Apartment(
        id: 1,
        buildingId: 1,
        nameOrNumber: 'شقة 101',
        floorNumber: 1,
        isRented: true),
    Apartment(
        id: 2,
        buildingId: 1,
        nameOrNumber: 'شقة 102',
        floorNumber: 1,
        isRented: false),
    Apartment(
        id: 3,
        buildingId: 1,
        nameOrNumber: 'شقة 201',
        floorNumber: 2,
        isRented: true),
    Apartment(
        id: 4,
        buildingId: 1,
        nameOrNumber: 'شقة 202',
        floorNumber: 2,
        isRented: false),

    // عمارة 2
    Apartment(
        id: 5,
        buildingId: 2,
        nameOrNumber: 'الدور الأرضي يمين',
        floorNumber: 1,
        isRented: true),
    Apartment(
        id: 6,
        buildingId: 2,
        nameOrNumber: 'الدور الأرضي يسار',
        floorNumber: 1,
        isRented: true),
  ];

  static List<Tenant> tenants = [
    Tenant(
        id: 1,
        apartmentId: 1,
        name: 'أحمد محمود',
        phone: '777123456',
        rentAmount: 50000,
        startDate: '2026-01-01'),
    Tenant(
        id: 2,
        apartmentId: 3,
        name: 'خالد عبدالله',
        phone: '711987654',
        rentAmount: 55000,
        startDate: '2025-11-01'),
    Tenant(
        id: 3,
        apartmentId: 5,
        name: 'سعيد علي',
        phone: '733445566',
        rentAmount: 40000,
        startDate: '2026-02-01'),
    Tenant(
        id: 4,
        apartmentId: 6,
        name: 'عمر اليمني',
        phone: '770001122',
        rentAmount: 40000,
        startDate: '2026-03-01'),
  ];

  static List<Payment> payments = [
    Payment(
        id: 1,
        tenantId: 1,
        amount: 50000,
        paymentDate: '2026-01-02',
        rentMonth: 'يناير 2026',
        notes: 'نقداً'),
    Payment(
        id: 2,
        tenantId: 1,
        amount: 50000,
        paymentDate: '2026-02-05',
        rentMonth: 'فبراير 2026',
        notes: 'تحويل بنكي'),
    Payment(
        id: 3,
        tenantId: 2,
        amount: 55000,
        paymentDate: '2026-01-01',
        rentMonth: 'يناير 2026',
        notes: ''),
  ];

  // Helper Methods for UI
  static List<Apartment> getApartmentsForBuilding(int buildingId) {
    return apartments.where((apt) => apt.buildingId == buildingId).toList();
  }

  static Tenant? getTenantForApartment(int apartmentId) {
    try {
      return tenants.firstWhere((tenant) => tenant.apartmentId == apartmentId);
    } catch (_) {
      return null;
    }
  }

  static List<Payment> getPaymentsForTenant(int tenantId) {
    return payments.where((payment) => payment.tenantId == tenantId).toList();
  }
}
