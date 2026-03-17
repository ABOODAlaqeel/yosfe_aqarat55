import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/pdf_report_service.dart';
import '../../models/tenant_model.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../widgets/tenant_list_item.dart';
import 'tenant_details_screen.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    List<Tenant> filteredTenants = provider.tenants;

    if (_isSearching && _searchController.text.isNotEmpty) {
      filteredTenants = provider.tenants
          .where((t) => t.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- الهيدر ---
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
                            AppStrings.tenantsList,
                            style:
                                AppStyles.heading.copyWith(color: Colors.white),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${provider.tenants.length} مستأجر',
                                  style: AppStyles.caption
                                      .copyWith(color: Colors.white70),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(CupertinoIcons.printer_fill,
                                    color: Colors.white),
                                onPressed: () {
                                  PdfReportService.printTenantsReport(
                                    provider.tenants,
                                    provider.apartments,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filter,
                          style: AppStyles.body.copyWith(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن مستأجر...',
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

          // --- قائمة المستأجرين ---
          filteredTenants.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.person_3,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('لا يوجد مستأجرين',
                            style: AppStyles.body
                                .copyWith(color: AppColors.textLight)),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tenant = filteredTenants[index];
                        final apt = provider.apartments
                            .firstWhere((a) => a.id == tenant.apartmentId);
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
                      childCount: filteredTenants.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
