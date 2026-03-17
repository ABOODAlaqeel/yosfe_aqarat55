import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/styles.dart';
import '../../models/apartment_model.dart';

class ApartmentGridItem extends StatelessWidget {
  final Apartment apartment;
  final VoidCallback onTap;

  const ApartmentGridItem({
    super.key,
    required this.apartment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRented = apartment.isRented;
    final gradient =
        isRented ? AppColors.errorGradient : AppColors.successGradient;
    final statusText = isRented ? AppStrings.rented : AppStrings.empty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppStyles.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة بتدرج لوني
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isRented ? Icons.lock_rounded : Icons.lock_open_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              apartment.nameOrNumber,
              style: AppStyles.bodyBold.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${AppStrings.floorNumber} ${apartment.floorNumber}',
              style: AppStyles.caption.copyWith(fontSize: 11),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: (isRented ? AppColors.error : AppColors.success)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: AppStyles.caption.copyWith(
                  color: isRented ? AppColors.error : AppColors.success,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
