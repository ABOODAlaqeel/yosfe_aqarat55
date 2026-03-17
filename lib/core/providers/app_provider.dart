import 'package:flutter/foundation.dart';
import '../../models/building_model.dart';
import '../../models/apartment_model.dart';
import '../../models/tenant_model.dart';
import '../../models/payment_model.dart';
import '../../data/repositories/building_repository.dart';
import '../../data/repositories/apartment_repository.dart';
import '../../data/repositories/tenant_repository.dart';
import '../../data/repositories/payment_repository.dart';

class AppProvider with ChangeNotifier {
  final BuildingRepository _buildingRepo = BuildingRepository();
  final ApartmentRepository _apartmentRepo = ApartmentRepository();
  final TenantRepository _tenantRepo = TenantRepository();
  final PaymentRepository _paymentRepo = PaymentRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Building> _buildings = [];
  List<Apartment> _apartments = [];
  List<Tenant> _tenants = [];
  List<Payment> _payments = [];

  List<Building> get buildings => _buildings;
  List<Apartment> get apartments => _apartments;
  List<Tenant> get tenants => _tenants;
  List<Payment> get payments => _payments;

  AppProvider() {
    loadAllData();
  }

  /// تحميل جميع البيانات من قاعدة البيانات عند فتح التطبيق
  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _buildings = await _buildingRepo.getAllBuildings();
      _tenants = await _tenantRepo.getAllTenants();
      _payments = await _paymentRepo.getAllPayments();

      _apartments.clear();
      for (var building in _buildings) {
        final List<Apartment> bApts =
            await _apartmentRepo.getApartmentsForBuilding(building.id);
        _apartments.addAll(bApts);
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- دوال المساعدة للواجهات (Helper Methods) ---

  List<Apartment> getApartmentsForBuilding(int buildingId) {
    return _apartments.where((apt) => apt.buildingId == buildingId).toList();
  }

  Tenant? getTenantForApartment(int apartmentId) {
    try {
      return _tenants.firstWhere((tenant) => tenant.apartmentId == apartmentId);
    } catch (_) {
      return null;
    }
  }

  List<Payment> getPaymentsForTenant(int tenantId) {
    return _payments.where((payment) => payment.tenantId == tenantId).toList();
  }

  // --- دوال الإضافة (Add Operations) ---

  Future<bool> addBuilding(Building building) async {
    try {
      final id = await _buildingRepo.insertBuilding(building);

      // توليد الشقق التلقائي إذا كان مفعل
      if (building.autoNameApartments) {
        List<Apartment> newApartments = [];
        int aptsPerFloor = building.apartmentsCount ~/ building.floorsCount;
        int remaining = building.apartmentsCount % building.floorsCount;
        int currentApt = 1;

        for (int i = 1; i <= building.floorsCount; i++) {
          int aptsInThisFloor = aptsPerFloor + (i <= remaining ? 1 : 0);
          for (int j = 1; j <= aptsInThisFloor; j++) {
            newApartments.add(
              Apartment(
                id: 0, // SQLite سيضيفه
                buildingId: id,
                nameOrNumber: 'شقة $currentApt',
                floorNumber: i,
                isRented: false,
              ),
            );
            currentApt++;
          }
        }
        await _apartmentRepo.insertApartmentsBatch(newApartments);
      }

      await loadAllData();
      return true;
    } catch (e) {
      debugPrint('Error adding building: $e');
      return false;
    }
  }

  Future<bool> addTenant(Tenant tenant) async {
    try {
      await _tenantRepo.insertTenant(tenant);

      // تحديث حالة الشقة إلى "مؤجرة"
      final currentApt =
          _apartments.firstWhere((a) => a.id == tenant.apartmentId);
      final updatedApt = Apartment(
        id: currentApt.id,
        buildingId: currentApt.buildingId,
        nameOrNumber: currentApt.nameOrNumber,
        floorNumber: currentApt.floorNumber,
        isRented: true,
      );
      await _apartmentRepo.updateApartment(updatedApt);

      await loadAllData();
      return true;
    } catch (e) {
      debugPrint('Error adding tenant: $e');
      return false;
    }
  }

  Future<bool> addPayment(Payment payment) async {
    try {
      await _paymentRepo.insertPayment(payment);
      await loadAllData();
      return true;
    } catch (e) {
      debugPrint('Error adding payment: $e');
      return false;
    }
  }

  Future<bool> checkoutTenant(Tenant tenant) async {
    try {
      // 1. Mark tenant as inactive
      final updatedTenant = Tenant(
        id: tenant.id,
        apartmentId: tenant
            .apartmentId, // We keep the apartment_id for historical reference if needed later
        name: tenant.name,
        phone: tenant.phone,
        rentAmount: tenant.rentAmount,
        contractImagePath: tenant.contractImagePath,
        startDate: tenant.startDate,
        notes: tenant.notes,
        isActive: 0,
      );
      await _tenantRepo.updateTenant(updatedTenant);

      // 2. Mark apartment as empty
      final apt = _apartments.firstWhere((a) => a.id == tenant.apartmentId);
      final updatedApt = Apartment(
        id: apt.id,
        buildingId: apt.buildingId,
        nameOrNumber: apt.nameOrNumber,
        floorNumber: apt.floorNumber,
        isRented: false,
      );
      await _apartmentRepo.updateApartment(updatedApt);

      await loadAllData();
      return true;
    } catch (e) {
      debugPrint('Error checkout tenant: $e');
      return false;
    }
  }
}
