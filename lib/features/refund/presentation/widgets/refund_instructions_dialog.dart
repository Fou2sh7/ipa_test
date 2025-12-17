import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';

class RefundInstructionsDialog extends StatelessWidget {
  const RefundInstructionsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const RefundInstructionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.whiteClr,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'common.instructions'.tr(),
                  style: AppTextStyles.font20BlackSemiBold(context),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24.sp),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Instructions List
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInstructionItem(
                      context,
                      '1',
                      'tutorial.family_members.select'.tr(),
                    ),
                    SizedBox(height: 16.h),
                    _buildInstructionItem(
                      context,
                      '2',
                      'tutorial.refund_type.select'.tr(),
                    ),
                    SizedBox(height: 16.h),
                    _buildInstructionItem(
                      context,
                      '3',
                      'tutorial.provider.select'.tr(),
                    ),
                    SizedBox(height: 16.h),
                    _buildInstructionItem(
                      context,
                      '4',
                      'tutorial.reason.select'.tr(),
                    ),
                    SizedBox(height: 16.h),
                    _buildInstructionItem(
                      context,
                      '5',
                      'tutorial.amount.enter'.tr(),
                    ),
                    SizedBox(height: 16.h),
                    _buildInstructionItem(
                      context,
                      '6',
                      'tutorial.date.select'.tr(),
                    ),
                    SizedBox(height: 16.h),
                    _buildInstructionItem(
                      context,
                      '7',
                      'tutorial.note.hint'.tr(),
                    ),
                    SizedBox(height: 16.h),
                    _buildInstructionItem(
                      context,
                      '8',
                      'tutorial.attachments.hint'.tr(),
                    ),
                    SizedBox(height: 16.h),
                    _buildInstructionItem(
                      context,
                      '9',
                      'tutorial.submit.tap'.tr(),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryClr,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                ),
                child: Text(
                  'dialog.got_it'.tr(),
                  style: AppTextStyles.font16WhiteMedium(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context,
    String number,
    String text,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: AppColors.primaryClr.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.font14BlackMedium(context).copyWith(
                color: AppColors.primaryClr,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.font14GreyRegular(context),
          ),
        ),
      ],
    );
  }
}

