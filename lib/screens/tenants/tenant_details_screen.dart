import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/tenant_model.dart';
import '../../models/payment_model.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../widgets/payment_dialog.dart';

class TenantDetailsScreen extends StatefulWidget {
  final Tenant tenant;
  final String apartmentName;

  const TenantDetailsScreen({
    super.key,
    required this.tenant,
    required this.apartmentName,
  });

  @override
  State<TenantDetailsScreen> createState() => _TenantDetailsScreenState();
}

class _TenantDetailsScreenState extends State<TenantDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final payments = provider.getPaymentsForTenant(widget.tenant.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
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
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                AppStrings.tenantDetails,
                                style: AppStyles.title
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // صورة المستأجر الرمزية
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.tenant.name.isNotEmpty
                              ? widget.tenant.name[0]
                              : '?',
                          style: AppStyles.display
                              .copyWith(color: Colors.white, fontSize: 34),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.tenant.name,
                      style: AppStyles.heading.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.house_fill,
                            size: 14, color: Colors.white54),
                        const SizedBox(width: 6),
                        Text(
                          widget.apartmentName,
                          style: AppStyles.body.copyWith(color: Colors.white60),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // إحصائيات
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildMiniStat(
                            'الإيجار',
                            AppFormatters.formatCurrency(
                                widget.tenant.rentAmount),
                            CupertinoIcons.money_dollar_circle_fill,
                          ),
                          const SizedBox(width: 10),
                          _buildMiniStat(
                            'المدفوعات',
                            '${payments.length}',
                            CupertinoIcons.checkmark_seal_fill,
                          ),
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
                        labelStyle: AppStyles.bodyBold.copyWith(fontSize: 14),
                        tabs: const [
                          Tab(text: 'البيانات'),
                          Tab(text: AppStrings.paymentHistory),
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
            _buildProfileTab(),
            _buildPaymentHistoryTab(payments),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => PaymentDialog.show(context, tenant: widget.tenant),
        backgroundColor: AppColors.success,
        icon: const Icon(CupertinoIcons.money_dollar_circle_fill),
        label: Text(AppStrings.payRent, style: AppStyles.buttonText),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondaryLight, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppStyles.caption
                          .copyWith(color: Colors.white54, fontSize: 11)),
                  Text(
                    value,
                    style: AppStyles.bodyBold
                        .copyWith(color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('معلومات المستأجر', style: AppStyles.title),
          const SizedBox(height: 16),

          _buildInfoCard(children: [
            _buildInfoRow(CupertinoIcons.person_fill, AppStrings.tenantName,
                widget.tenant.name),
            _divider(),
            _buildInfoRow(CupertinoIcons.phone_fill, AppStrings.tenantPhone,
                widget.tenant.phone ?? 'لم يُحدد'),
            _divider(),
            _buildInfoRow(
                CupertinoIcons.money_dollar_circle_fill,
                AppStrings.rentAmount,
                AppFormatters.formatCurrency(widget.tenant.rentAmount),
                valueColor: AppColors.primary),
            _divider(),
            _buildInfoRow(CupertinoIcons.calendar, AppStrings.startDate,
                widget.tenant.startDate ?? 'غير مسجل'),
          ]),

          const SizedBox(height: 24),
          Text(AppStrings.attachContract, style: AppStyles.title),
          const SizedBox(height: 16),

          // مكان الصورة
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppStyles.cardShadow,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: widget.tenant.contractImagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const Center(child: Text('صورة العقد ستظهر هنا')),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(CupertinoIcons.doc_text_viewfinder,
                            size: 40, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 12),
                      Text('لا توجد صورة للعقد',
                          style: AppStyles.body
                              .copyWith(color: AppColors.textLight)),
                    ],
                  ),
          ),

          const SizedBox(height: 32),
          Text('منطقة الخطر',
              style: AppStyles.title.copyWith(color: AppColors.error)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => _confirmCheckout(context),
              icon: const Icon(CupertinoIcons.square_arrow_right,
                  color: Colors.white),
              label: Text('إخلاء المستأجر وإنهاء العقد',
                  style: AppStyles.buttonText.copyWith(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCheckout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title:
            const Text('إخلاء المستأجر', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text(
            'هل أنت متأكد من إنهاء عقد هذا المستأجر؟ سيتم تغيير حالة الشقة إلى "فارغة". ولن تتمكن من التراجع.',
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          CupertinoDialogAction(
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('نعم، تأكيد الإخلاء',
                style: TextStyle(fontFamily: 'Cairo')),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context
                  .read<AppProvider>()
                  .checkoutTenant(widget.tenant);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('تم إخلاء المستأجر بنجاح',
                          style: TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: AppColors.success),
                );
                Navigator.pop(context); // العودة للصفحة السابقة
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppStyles.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Text(label, style: AppStyles.body.copyWith(fontSize: 14)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: AppStyles.bodyBold.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 14,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, indent: 70, color: Colors.grey.shade100);
  }

  Widget _buildPaymentHistoryTab(List<Payment> payments) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(CupertinoIcons.doc_chart,
                  size: 60, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.noPaymentsYet,
                style: AppStyles.body.copyWith(color: AppColors.textLight)),
          ],
        ),
      );
    }

    // حساب الإجمالي
    double total = 0;
    for (var p in payments) {
      total += p.amount;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // لوح إجمالي المدفوعات
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.successGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(CupertinoIcons.checkmark_seal_fill,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إجمالي المدفوعات',
                        style:
                            AppStyles.caption.copyWith(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.formatCurrency(total),
                      style: AppStyles.heading
                          .copyWith(color: Colors.white, fontSize: 22),
                    ),
                  ],
                ),
              ),
              Text(
                '${payments.length} دفعة',
                style: AppStyles.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // سجل الدفعات
        ...List.generate(payments.length, (index) {
          final payment = payments[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                  child: const Icon(CupertinoIcons.checkmark_circle_fill,
                      color: AppColors.success, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(payment.rentMonth,
                          style: AppStyles.bodyBold.copyWith(fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(CupertinoIcons.calendar,
                              size: 12, color: AppColors.textLight),
                          const SizedBox(width: 4),
                          Text(payment.paymentDate,
                              style: AppStyles.caption.copyWith(fontSize: 11)),
                          if (payment.notes != null &&
                              payment.notes!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text('• ${payment.notes}',
                                style:
                                    AppStyles.caption.copyWith(fontSize: 11)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  AppFormatters.formatCurrency(payment.amount),
                  style: AppStyles.bodyBold
                      .copyWith(color: AppColors.success, fontSize: 14),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
