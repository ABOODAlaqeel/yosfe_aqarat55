import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/styles.dart';
import '../../core/services/pdf_report_service.dart';
import '../../models/building_model.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../widgets/building_card.dart';
import '../../widgets/add_building_dialog.dart';
import 'building_details_screen.dart';

class BuildingsScreen extends StatefulWidget {
  const BuildingsScreen({super.key});

  @override
  State<BuildingsScreen> createState() => _BuildingsScreenState();
}

class _BuildingsScreenState extends State<BuildingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBuildings(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    List<Building> filteredBuildings = provider.buildings;

    if (_isSearching && _searchController.text.isNotEmpty) {
      filteredBuildings = provider.buildings
          .where((b) => b.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- الهيدر العلوي ---
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.buildingsList,
                            style:
                                AppStyles.heading.copyWith(color: Colors.white),
                          ),
                          Row(
                            children: [
                              Text(
                                '${provider.buildings.length} عمارة',
                                style: AppStyles.body
                                    .copyWith(color: Colors.white60),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(CupertinoIcons.printer_fill,
                                    color: Colors.white),
                                onPressed: () {
                                  PdfReportService.printBuildingsReport(
                                      provider.buildings);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // حقل البحث
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterBuildings,
                          style: AppStyles.body.copyWith(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن عمارة...',
                            hintStyle:
                                AppStyles.body.copyWith(color: Colors.white54),
                            prefixIcon: const Icon(CupertinoIcons.search,
                                color: Colors.white54, size: 20),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- قائمة العمارات ---
          filteredBuildings.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.building_2_fill,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد عمارات مطابقة',
                          style: AppStyles.body
                              .copyWith(color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final building = filteredBuildings[index];
                        return BuildingCard(
                          building: building,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BuildingDetailsScreen(building: building),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredBuildings.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddBuildingDialog.show(context),
        child: const Icon(CupertinoIcons.add, size: 28),
      ),
    );
  }
}
