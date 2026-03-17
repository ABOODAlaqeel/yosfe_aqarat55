import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../core/constants/colors.dart';
import '../core/constants/sizes.dart';
import '../core/constants/strings.dart';
import '../core/constants/styles.dart';
import 'package:provider/provider.dart';
import '../core/providers/app_provider.dart';
import '../models/payment_model.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';
import '../models/building_model.dart';
import '../models/tenant_model.dart';
import '../models/apartment_model.dart';

class PaymentDialog extends StatefulWidget {
  final Building? preSelectedBuilding;
  final Tenant? preSelectedTenant;

  const PaymentDialog(
      {super.key, this.preSelectedBuilding, this.preSelectedTenant});

  static void show(BuildContext context, {Building? building, Tenant? tenant}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentDialog(
          preSelectedBuilding: building, preSelectedTenant: tenant),
    );
  }

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  Building? _selectedBuilding;
  Tenant? _selectedTenant;
  bool _showAllTenants = false;
  List<Tenant> _filteredTenants = [];

  bool _isMultipleMonths = false;
  DateTime _selectedDate = DateTime.now();
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 30));

  String _paymentMethod = 'نقدي';
  final List<String> _paymentMethods = ['نقدي', 'تحويل بنكي', 'شيك'];

  @override
  void initState() {
    super.initState();

    if (widget.preSelectedTenant != null) {
      _selectedTenant = widget.preSelectedTenant;
    } else if (widget.preSelectedBuilding != null) {
      _selectedBuilding = widget.preSelectedBuilding;
      _updateTenantsList();
    }
    _recalculateAmount();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'ar').format(date);
  }

  void _onBuildingChanged(Building? b) {
    setState(() {
      _selectedBuilding = b;
      _updateTenantsList();
    });
  }

  void _updateTenantsList() {
    if (_selectedBuilding == null) {
      _filteredTenants = [];
      _selectedTenant = null;
      return;
    }

    final provider = context.read<AppProvider>();
    final apartments = provider.getApartmentsForBuilding(_selectedBuilding!.id);
    final apartmentIds = apartments.map((a) => a.id).toList();

    List<Tenant> allTenantsInBuilding = provider.tenants
        .where((t) => apartmentIds.contains(t.apartmentId))
        .toList();

    if (_showAllTenants) {
      _filteredTenants = allTenantsInBuilding;
    } else {
      String currentMonth = _formatMonthYear(_selectedDate);
      _filteredTenants = allTenantsInBuilding.where((t) {
        bool hasPaid = provider.payments
            .any((p) => p.tenantId == t.id && p.rentMonth == currentMonth);
        return !hasPaid;
      }).toList();
    }

    if (!_filteredTenants.contains(_selectedTenant)) {
      _selectedTenant = null;
    }
  }

  void _onTenantChanged(Tenant? t) {
    setState(() {
      _selectedTenant = t;
      _recalculateAmount();
    });
  }

  void _recalculateAmount() {
    if (_selectedTenant == null) return;
    double baseRent = _selectedTenant!.rentAmount;
    if (_isMultipleMonths) {
      int monthsCount = (_toDate.year - _fromDate.year) * 12 +
          _toDate.month -
          _fromDate.month +
          1;
      if (monthsCount < 1) monthsCount = 1;
      _amountController.text = (baseRent * monthsCount).toStringAsFixed(0);
    } else {
      _amountController.text = baseRent.toStringAsFixed(0);
    }
  }

  Future<void> _pickDate(BuildContext context,
      {required bool isFrom, bool isSingle = false}) async {
    final initialDate =
        isSingle ? _selectedDate : (isFrom ? _fromDate : _toDate);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isSingle) {
          _selectedDate = picked;
          _updateTenantsList();
        } else {
          if (isFrom) {
            _fromDate = picked;
            if (_toDate.isBefore(_fromDate)) {
              _toDate = _fromDate;
            }
          } else {
            _toDate = picked;
            if (_toDate.isBefore(_fromDate)) {
              _fromDate = _toDate;
            }
          }
        }
        _recalculateAmount();
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTenant == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(CupertinoIcons.exclamationmark_circle_fill,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text('اختر المستأجر',
                    style: AppStyles.caption.copyWith(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(20),
          ),
        );
        return;
      }
      Navigator.pop(context);

      String monthText = _isMultipleMonths
          ? 'من ${_formatMonthYear(_fromDate)} إلى ${_formatMonthYear(_toDate)}'
          : _formatMonthYear(_selectedDate);

      final newPayment = Payment(
        id: 0,
        tenantId: _selectedTenant!.id,
        amount: double.tryParse(_amountController.text) ?? 0,
        paymentDate: DateTime.now().toIso8601String(),
        rentMonth: monthText,
        paymentMethod: _paymentMethod,
        notes: _notesController.text.trim(),
      );

      final success = await context.read<AppProvider>().addPayment(newPayment);

      if (!mounted) return;
      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(CupertinoIcons.check_mark_circled_solid,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      'تم تسجيل دفعة بقيمة ${_amountController.text}\nللشهر: $monthText',
                      style: AppStyles.caption.copyWith(color: Colors.white)),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            gradient: AppColors.successGradient,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(
                            CupertinoIcons.money_dollar_circle_fill,
                            color: Colors.white,
                            size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(AppStrings.payRent, style: AppStyles.heading),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // إذا كان المستأجر محدد مسبقاً لا نظهر قوائم العمارة والمستأجرين، بل نظهر اسمه مباشرة
                  if (widget.preSelectedTenant != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(CupertinoIcons.person_solid,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('المستأجر', style: AppStyles.caption),
                                Text(widget.preSelectedTenant!.name,
                                    style: AppStyles.bodyBold
                                        .copyWith(fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    // اختيار العمارة
                    if (widget.preSelectedBuilding == null) ...[
                      DropdownButtonFormField<Building>(
                        decoration: InputDecoration(
                          labelText: 'اختر العمارة',
                          prefixIcon: const Icon(CupertinoIcons.building_2_fill,
                              color: AppColors.primary),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        value: _selectedBuilding,
                        items: context
                            .read<AppProvider>()
                            .buildings
                            .map((b) => DropdownMenuItem(
                                value: b,
                                child: Text(b.name,
                                    style: AppStyles.bodyBold
                                        .copyWith(fontSize: 14))))
                            .toList(),
                        onChanged: _onBuildingChanged,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // خيار عرض الكل
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('المستأجرين',
                            style: AppStyles.bodyBold.copyWith(fontSize: 14)),
                        Row(
                          children: [
                            Text('عرض الكل', style: AppStyles.caption),
                            Checkbox(
                              value: _showAllTenants,
                              activeColor: AppColors.primary,
                              onChanged: (v) {
                                setState(() {
                                  _showAllTenants = v ?? false;
                                  _updateTenantsList();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // اختيار المستأجر
                    DropdownButtonFormField<Tenant>(
                      decoration: InputDecoration(
                        labelText: _showAllTenants
                            ? 'اختر المستأجر'
                            : 'مستأجرين لم يدفعوا (${_formatMonthYear(_selectedDate)})',
                        prefixIcon: const Icon(CupertinoIcons.person_fill,
                            color: AppColors.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      value: _selectedTenant,
                      hint: Text(
                          _selectedBuilding == null
                              ? 'يرجى اختيار العمارة أولاً'
                              : 'اختر...',
                          style: AppStyles.caption),
                      items: _filteredTenants.map((t) {
                        Apartment apt = context
                            .read<AppProvider>()
                            .apartments
                            .firstWhere((a) => a.id == t.apartmentId,
                                orElse: () => context
                                    .read<AppProvider>()
                                    .apartments
                                    .first);
                        return DropdownMenuItem(
                          value: t,
                          child: Text('${t.name} - ${apt.nameOrNumber}',
                              style: AppStyles.bodyBold.copyWith(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged:
                          _selectedBuilding == null ? null : _onTenantChanged,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // خيار دفع أكثر من شهر
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('دفع إيجار لعدة أشهر متصلة',
                            style: AppStyles.bodyBold.copyWith(fontSize: 14)),
                        Switch.adaptive(
                          value: _isMultipleMonths,
                          activeColor: AppColors.success,
                          onChanged: (v) {
                            setState(() {
                              _isMultipleMonths = v;
                              _recalculateAmount();
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  if (_isMultipleMonths) ...[
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(context, isFrom: true),
                            child: _buildDateSelector(
                                'من شهر', _formatMonthYear(_fromDate)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(context, isFrom: false),
                            child: _buildDateSelector(
                                'إلى شهر', _formatMonthYear(_toDate)),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: () =>
                          _pickDate(context, isFrom: false, isSingle: true),
                      child: _buildDateSelector(
                          'شهر الإيجار', _formatMonthYear(_selectedDate)),
                    ),
                  ],
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 1, // غيرنا التقسيم ليتناسب
                        child: CustomTextField(
                          controller: _amountController,
                          labelText: AppStrings.paymentAmount,
                          keyboardType: TextInputType.number,
                          prefixIcon: CupertinoIcons.money_dollar_circle_fill,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 1, // غيرنا التقسيم ليتناسب
                        child: DropdownButtonFormField<String>(
                          isExpanded: true, // مهم لمنع الخطأ في الشاشات الصغيرة
                          decoration: InputDecoration(
                            labelText: 'طريقة الدفع',
                            prefixIcon: const Icon(CupertinoIcons.creditcard,
                                color: AppColors.primary),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 14),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          value: _paymentMethod,
                          items: _paymentMethods
                              .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m,
                                      style: AppStyles.bodyBold
                                          .copyWith(fontSize: 13),
                                      overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (v) => setState(() => _paymentMethod = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _notesController,
                    labelText: 'ملاحظات (اختياري)',
                    prefixIcon: CupertinoIcons.doc_text,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.cancel,
                          isOutline: true,
                          textColor: AppColors.textSecondary,
                          color: Colors.grey.shade300,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomButton(
                          text: 'تأكيد الدفع',
                          color: AppColors.success,
                          icon: CupertinoIcons.check_mark_circled_solid,
                          onPressed: _save,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppStyles.caption.copyWith(fontSize: 11)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(CupertinoIcons.calendar,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(value,
                      style: AppStyles.bodyBold.copyWith(
                          fontSize: 14, overflow: TextOverflow.ellipsis))),
            ],
          ),
        ],
      ),
    );
  }
}
