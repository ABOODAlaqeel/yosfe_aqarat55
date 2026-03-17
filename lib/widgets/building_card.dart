import 'package:flutter/material.dart';

import '../core/constants/colors.dart';
import '../core/constants/sizes.dart';
import '../core/constants/strings.dart';
import '../core/constants/styles.dart';
import '../models/building_model.dart';
import 'package:provider/provider.dart';
import '../core/providers/app_provider.dart';

class BuildingCard extends StatelessWidget {
  final Building building;
  final VoidCallback onTap;

  const BuildingCard({
    super.key,
    required this.building,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final apartments = provider.getApartmentsForBuilding(building.id);
    final emptyApts = apartments.where((apt) => !apt.isRented).length;
    final rentedApts = apartments.length - emptyApts;
    final occupancyRate =
        apartments.isEmpty ? 0.0 : rentedApts / apartments.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppStyles.cardShadow,
        ),
        child: Column(
          children: [
            // الجزء العلوي بتدرج A
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.business_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          building.name,
                          style: AppStyles.title.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${building.floorsCount} طابق  •  ${building.apartmentsCount} شقة',
                          style:
                              AppStyles.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),

            // الجزء السفلي بالإحصائيات
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // شريط الإشغال (Progress Bar)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('نسبة الإشغال', style: AppStyles.caption),
                      Text('${(occupancyRate * 100).toInt()}%',
                          style: AppStyles.bodyBold.copyWith(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: occupancyRate,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        occupancyRate > 0.7
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // الإحصائيات
                  Row(
                    children: [
                      _buildChip(
                        label: '${AppStrings.rented} $rentedApts',
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 10),
                      _buildChip(
                        label: '${AppStrings.empty} $emptyApts',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
