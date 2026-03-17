import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/styles.dart';
import '../../models/tenant_model.dart';

class TenantListItem extends StatelessWidget {
  final Tenant tenant;
  final String apartmentName;
  final VoidCallback onTap;

  const TenantListItem({
    super.key,
    required this.tenant,
    required this.apartmentName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppStyles.cardShadow,
        ),
        child: Row(
          children: [
            // أيقونة المستأجر بدائرة ذهبية
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  tenant.name.isNotEmpty ? tenant.name[0] : '?',
                  style: AppStyles.title.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenant.name,
                    style: AppStyles.bodyBold.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.home_outlined,
                          size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        apartmentName,
                        style: AppStyles.caption.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // سهم
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
