import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../core/constants/colors.dart';
import '../core/constants/sizes.dart';
import '../core/constants/strings.dart';
import '../core/constants/styles.dart';
import 'package:provider/provider.dart';
import '../core/providers/app_provider.dart';
import '../models/building_model.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

class AddBuildingDialog extends StatefulWidget {
  const AddBuildingDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBuildingDialog(),
    );
  }

  @override
  State<AddBuildingDialog> createState() => _AddBuildingDialogState();
}

class _AddBuildingDialogState extends State<AddBuildingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _floorsController = TextEditingController();
  final _apartmentsController = TextEditingController();
  bool _autoNameApartments = true;
  String _rentCycle = 'شهري';

  @override
  void dispose() {
    _nameController.dispose();
    _floorsController.dispose();
    _apartmentsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final buildingName = _nameController.text.trim();
      final floorsCount = int.tryParse(_floorsController.text) ?? 1;
      final apartmentsCount = int.tryParse(_apartmentsController.text) ?? 1;

      final newBuilding = Building(
        id: 0,
        name: buildingName,
        floorsCount: floorsCount,
        apartmentsCount: apartmentsCount,
        rentCycle: _rentCycle,
        autoNameApartments: _autoNameApartments,
        createdAt: DateTime.now().toIso8601String(),
      );

      bool success = await context.read<AppProvider>().addBuilding(newBuilding);

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
                Text('تمت إضافة العمارة بنجاح',
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
        maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(CupertinoIcons.building_2_fill,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Text(AppStrings.addBuilding, style: AppStyles.heading),
                    ],
                  ),
                  const SizedBox(height: 28),

                  CustomTextField(
                    controller: _nameController,
                    labelText: AppStrings.buildingName,
                    prefixIcon: Icons.domain_rounded,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _floorsController,
                          labelText: AppStrings.floorsCount,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.layers_rounded,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomTextField(
                          controller: _apartmentsController,
                          labelText: AppStrings.apartmentsCount,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.apps_rounded,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // نوع الإيجار
                  Text('نظام الإيجار في هذه العمارة',
                      style: AppStyles.bodyBold.copyWith(fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _rentCycle = 'شهري'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _rentCycle == 'شهري'
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.white,
                              border: Border.all(
                                  color: _rentCycle == 'شهري'
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  width: 2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text('شهري',
                                  style: AppStyles.bodyBold.copyWith(
                                      color: _rentCycle == 'شهري'
                                          ? AppColors.primary
                                          : AppColors.textLight)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _rentCycle = 'سنوي'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _rentCycle == 'سنوي'
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.white,
                              border: Border.all(
                                  color: _rentCycle == 'سنوي'
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  width: 2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text('سنوي',
                                  style: AppStyles.bodyBold.copyWith(
                                      color: _rentCycle == 'سنوي'
                                          ? AppColors.primary
                                          : AppColors.textLight)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ترقيم تلقائي للشقق',
                                  style: AppStyles.bodyBold
                                      .copyWith(fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('مثال: طابق 1 - شقة 101',
                                  style:
                                      AppStyles.caption.copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _autoNameApartments,
                          activeColor: AppColors.primary,
                          onChanged: (v) =>
                              setState(() => _autoNameApartments = v),
                        ),
                      ],
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
