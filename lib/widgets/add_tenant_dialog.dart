import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/colors.dart';
import '../core/constants/sizes.dart';
import '../core/constants/strings.dart';
import '../core/constants/styles.dart';
import '../core/services/contract_image_service.dart';
import 'package:provider/provider.dart';
import '../core/providers/app_provider.dart';
import '../models/tenant_model.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';
import '../models/building_model.dart';
import '../models/apartment_model.dart';

class AddTenantDialog extends StatefulWidget {
  final Building? preSelectedBuilding;

  const AddTenantDialog({super.key, this.preSelectedBuilding});

  static void show(BuildContext context, {Building? building}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTenantDialog(preSelectedBuilding: building),
    );
  }

  @override
  State<AddTenantDialog> createState() => _AddTenantDialogState();
}

class _AddTenantDialogState extends State<AddTenantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  Building? _selectedBuilding;
  Apartment? _selectedApartment;
  List<Apartment> _availableApartments = [];
  File? _contractImage;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedBuilding != null) {
      _selectedBuilding = widget.preSelectedBuilding;
      _onBuildingChanged(_selectedBuilding);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onBuildingChanged(Building? b) {
    setState(() {
      _selectedBuilding = b;
      _selectedApartment = null;
      _availableApartments = b != null
          ? context
              .read<AppProvider>()
              .getApartmentsForBuilding(b.id)
              .where((a) => !a.isRented)
              .toList()
          : [];
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(CupertinoIcons.camera_fill,
                    color: AppColors.primary),
                title: Text('التقاط صورة', style: AppStyles.bodyBold),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file =
                      await ContractImageService.pickImage(ImageSource.camera);
                  if (file != null) {
                    setState(() => _contractImage = file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.photo_fill,
                    color: AppColors.primary),
                title: Text('اختيار من المعرض', style: AppStyles.bodyBold),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file =
                      await ContractImageService.pickImage(ImageSource.gallery);
                  if (file != null) {
                    setState(() => _contractImage = file);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedApartment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(CupertinoIcons.exclamationmark_circle_fill,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text('اختر العمارة والشقة أولاً',
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

      final appProvider = context.read<AppProvider>();
      String? savedImagePath;
      if (_contractImage != null) {
        savedImagePath =
            await ContractImageService.saveImageLocally(_contractImage!);
      }

      final newTenant = Tenant(
        id: 0,
        apartmentId: _selectedApartment!.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        rentAmount: double.tryParse(_amountController.text) ?? 0,
        notes: _notesController.text.trim(),
        contractImagePath: savedImagePath,
        startDate: DateTime.now().toIso8601String(),
      );

      final success = await appProvider.addTenant(newTenant);

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
                Text('تمت إضافة المستأجر بنجاح',
                    style: AppStyles.caption.copyWith(color: Colors.white)),
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
                            gradient: AppColors.blueGradient,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(CupertinoIcons.person_add_solid,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(AppStrings.addTenant, style: AppStyles.heading),
                    ],
                  ),
                  const SizedBox(height: 28),

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

                  // اختيار الشقة
                  DropdownButtonFormField<Apartment>(
                    decoration: InputDecoration(
                      labelText: 'الشقة الشاغرة',
                      prefixIcon: const Icon(CupertinoIcons.house_fill,
                          color: AppColors.primary),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    value: _selectedApartment,
                    hint: Text(
                        _selectedBuilding == null
                            ? 'يرجى اختيار العمارة أولاً'
                            : 'اختر...',
                        style: AppStyles.caption),
                    items: _availableApartments
                        .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(
                                '${a.nameOrNumber} - دور ${a.floorNumber}',
                                style:
                                    AppStyles.bodyBold.copyWith(fontSize: 14))))
                        .toList(),
                    onChanged: _selectedBuilding == null
                        ? null
                        : (v) => setState(() => _selectedApartment = v),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _nameController,
                    labelText: AppStrings.tenantName,
                    prefixIcon: CupertinoIcons.person_solid,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _phoneController,
                          labelText: AppStrings.tenantPhone,
                          keyboardType: TextInputType.phone,
                          prefixIcon: CupertinoIcons.phone_solid,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomTextField(
                          controller: _amountController,
                          labelText: AppStrings.rentAmount,
                          keyboardType: TextInputType.number,
                          prefixIcon: CupertinoIcons.money_dollar,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'مطلوب' : null,
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
                  const SizedBox(height: 24),

                  // زر إرفاق صورة العقد
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.05),
                            AppColors.primary.withOpacity(0.02)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _contractImage != null
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                                _contractImage != null
                                    ? CupertinoIcons.check_mark_circled_solid
                                    : CupertinoIcons.camera_fill,
                                color: _contractImage != null
                                    ? AppColors.success
                                    : AppColors.primary,
                                size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    _contractImage != null
                                        ? 'تم إرفاق العقد'
                                        : AppStrings.attachContract,
                                    style: AppStyles.bodyBold.copyWith(
                                        fontSize: 14,
                                        color: _contractImage != null
                                            ? AppColors.success
                                            : null)),
                                if (_contractImage == null)
                                  Text('تصوير أو اختيار من المعرض',
                                      style: AppStyles.caption
                                          .copyWith(fontSize: 11)),
                              ],
                            ),
                          ),
                          if (_contractImage == null)
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 14, color: AppColors.textLight)
                          else
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _contractImage = null),
                              child: const Icon(
                                  CupertinoIcons.clear_circled_solid,
                                  color: AppColors.error,
                                  size: 20),
                            )
                        ],
                      ),
                    ),
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
                          text: AppStrings.save,
                          color: AppColors.primary,
                          icon: CupertinoIcons.check_mark,
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
}
