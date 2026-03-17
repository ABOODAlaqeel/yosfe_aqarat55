import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/styles.dart';
import '../../core/utils/formatters.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../widgets/add_building_dialog.dart';
import '../../widgets/add_tenant_dialog.dart';
import '../../widgets/payment_dialog.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CupertinoActivityIndicator(radius: 20)),
      );
    }

    final totalBuildings = provider.buildings.length;
    final totalApartments = provider.apartments.length;
    final rented = provider.apartments.where((a) => a.isRented).length;
    final empty = totalApartments - rented;
    final totalTenants = provider.tenants.length;
    double totalRevenue = 0;
    for (var p in provider.payments) {
      totalRevenue += p.amount;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- الهيدر العلوي بتدرج أنيق ---
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
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مرحباً بك 👋',
                                style: AppStyles.body
                                    .copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.appName,
                                style: AppStyles.heading
                                    .copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                          // أيقونة
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(CupertinoIcons.bell,
                                color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // --- بطاقة الإيرادات الرئيسية ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.collectedRevenue,
                              style: AppStyles.body
                                  .copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppFormatters.formatCurrency(totalRevenue),
                              style: AppStyles.display.copyWith(
                                  color: AppColors.secondaryLight,
                                  fontSize: 28),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildMiniStat('عمارات', '$totalBuildings',
                                    CupertinoIcons.building_2_fill),
                                const SizedBox(width: 16),
                                _buildMiniStat('شقق', '$totalApartments',
                                    CupertinoIcons.house_fill),
                                const SizedBox(width: 16),
                                _buildMiniStat('مستأجرين', '$totalTenants',
                                    CupertinoIcons.person_2_fill),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- بطاقات الإحصائيات ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Expanded(
                      child: _buildStatCard(
                    title: AppStrings.rentedApartments,
                    value: '$rented',
                    icon: CupertinoIcons.lock_fill,
                    gradient: AppColors.errorGradient,
                  )),
                  const SizedBox(width: 14),
                  Expanded(
                      child: _buildStatCard(
                    title: AppStrings.emptyApartments,
                    value: '$empty',
                    icon: CupertinoIcons.lock_open_fill,
                    gradient: AppColors.successGradient,
                  )),
                ],
              ),
            ),
          ),

          // --- الإجراءات السريعة ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.quickActions, style: AppStyles.title),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          title: 'عمارة جديدة',
                          icon: CupertinoIcons.add_circled_solid,
                          gradient: AppColors.primaryGradient,
                          onTap: () => AddBuildingDialog.show(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          title: 'مستأجر جديد',
                          icon: CupertinoIcons.person_add_solid,
                          gradient: AppColors.blueGradient,
                          onTap: () => AddTenantDialog.show(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          title: 'دفع إيجار',
                          icon: CupertinoIcons.money_dollar_circle_fill,
                          gradient: AppColors.successGradient,
                          onTap: () => PaymentDialog.show(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- آخر النشاطات ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.recentActivities, style: AppStyles.title),
                  const SizedBox(height: 16),
                  if (provider.payments.isEmpty)
                    Center(
                        child: Text('لا توجد مدفوعات حالياً',
                            style: AppStyles.caption))
                  else
                    ...provider.payments.take(3).map((payment) {
                      final tenant = provider.tenants.firstWhere(
                        (t) => t.id == payment.tenantId,
                        orElse: () => provider.tenants.first,
                      );
                      return _buildActivityItem(
                        name: tenant.name,
                        detail:
                            'دفع ${AppFormatters.formatCurrency(payment.amount)} - ${payment.rentMonth}',
                        date: payment.paymentDate,
                      );
                    }),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: AppStyles.bodyBold
                    .copyWith(color: Colors.white, fontSize: 18)),
            Text(label,
                style: AppStyles.caption
                    .copyWith(color: Colors.white60, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 16),
          Text(value, style: AppStyles.heading.copyWith(fontSize: 28)),
          const SizedBox(height: 4),
          Text(title, style: AppStyles.caption),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String name,
    required String detail,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(CupertinoIcons.checkmark_alt_circle_fill,
                color: AppColors.success, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppStyles.bodyBold.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(detail, style: AppStyles.caption.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Text(date, style: AppStyles.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
