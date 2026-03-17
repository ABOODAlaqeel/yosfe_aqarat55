import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/styles.dart';
import '../../models/building_model.dart';
import '../../models/apartment_model.dart';
import '../../models/tenant_model.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../widgets/apartment_grid_item.dart';
import '../../widgets/tenant_list_item.dart';
import '../../widgets/add_tenant_dialog.dart';
import '../../widgets/payment_dialog.dart';
import '../tenants/tenant_details_screen.dart';

class BuildingDetailsScreen extends StatefulWidget {
  final Building building;

  const BuildingDetailsScreen({super.key, required this.building});

  @override
  State<BuildingDetailsScreen> createState() => _BuildingDetailsScreenState();
}

class _BuildingDetailsScreenState extends State<BuildingDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    if (_isFabOpen) {
      _fabAnimationController.reverse();
    } else {
      _fabAnimationController.forward();
    }
    setState(() {
      _isFabOpen = !_isFabOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final apartments = provider.getApartmentsForBuilding(widget.building.id);
    final tenants = apartments
        .where((a) => a.isRented)
        .map((a) => provider.getTenantForApartment(a.id))
        .whereType<Tenant>()
        .toList();

    final rented = apartments.where((a) => a.isRented).length;
    final empty = apartments.length - rented;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // AppBar مخصص
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    widget.building.name,
                                    style: AppStyles.title
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48), // لتوسيط العنوان
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ملخص الإحصائيات
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              _buildHeaderStat('الشقق', '${apartments.length}',
                                  CupertinoIcons.house_fill),
                              const SizedBox(width: 10),
                              _buildHeaderStat(
                                  'مؤجرة', '$rented', CupertinoIcons.lock_fill),
                              const SizedBox(width: 10),
                              _buildHeaderStat('فارغة', '$empty',
                                  CupertinoIcons.lock_open_fill),
                              const SizedBox(width: 10),
                              _buildHeaderStat(
                                  'طوابق',
                                  '${widget.building.floorsCount}',
                                  CupertinoIcons.layers_fill),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // التبويبات
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white54,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            dividerHeight: 0,
                            labelStyle:
                                AppStyles.bodyBold.copyWith(fontSize: 14),
                            tabs: const [
                              Tab(text: AppStrings.apartmentsList),
                              Tab(text: AppStrings.tenantsList),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildApartmentsTab(apartments),
                _buildTenantsTab(tenants, apartments),
              ],
            ),
          ),

          // خلفية شفافة عند فتح زر الإجراءات السريعة
          if (_isFabOpen)
            GestureDetector(
              onTap: _toggleFab,
              child: Container(
                color: Colors.black.withOpacity(0.4),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildFabOption(
            icon: CupertinoIcons.person_add_solid,
            title: AppStrings.addTenant,
            color: const Color(
                0xFF3B82F6), // AppColors.blue gradient primary color
            onTap: () {
              _toggleFab();
              AddTenantDialog.show(context, building: widget.building);
            },
            heroTag: 'add_tenant',
          ),
          const SizedBox(height: 12),
          _buildFabOption(
            icon: CupertinoIcons.money_dollar_circle_fill,
            title: AppStrings.payRent,
            color: AppColors.success,
            onTap: () {
              _toggleFab();
              PaymentDialog.show(context, building: widget.building);
            },
            heroTag: 'pay_rent',
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'main_fab',
            onPressed: _toggleFab,
            backgroundColor: AppColors.secondary,
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 0.125).animate(_fabAnimation),
              child:
                  const Icon(CupertinoIcons.add, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required String heroTag,
  }) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppStyles.cardShadow,
            ),
            child: Text(title,
                style: AppStyles.bodyBold
                    .copyWith(fontSize: 13, color: AppColors.textPrimary)),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            heroTag: heroTag,
            backgroundColor: color,
            onPressed: onTap,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: AppStyles.bodyBold
                    .copyWith(color: Colors.white, fontSize: 16)),
            Text(label,
                style: AppStyles.caption
                    .copyWith(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildApartmentsTab(List<Apartment> apartments) {
    if (apartments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.house_fill,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('لا توجد شقق',
                style: AppStyles.body.copyWith(color: AppColors.textLight)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: apartments.length,
      itemBuilder: (context, index) {
        return ApartmentGridItem(
          apartment: apartments[index],
          onTap: () {},
        );
      },
    );
  }

  Widget _buildTenantsTab(List<Tenant> tenants, List<Apartment> apartments) {
    if (tenants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.person_3,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('لا يوجد مستأجرين بعد',
                style: AppStyles.body.copyWith(color: AppColors.textLight)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: tenants.length,
      itemBuilder: (context, index) {
        final tenant = tenants[index];
        final apt = apartments.firstWhere((a) => a.id == tenant.apartmentId);
        return TenantListItem(
          tenant: tenant,
          apartmentName: apt.nameOrNumber,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TenantDetailsScreen(
                  tenant: tenant,
                  apartmentName: apt.nameOrNumber,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
