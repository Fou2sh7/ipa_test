import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/shared/widgets/page_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediconsult/features/support/presentation/cubit/faq_cubit.dart';
import 'package:mediconsult/features/support/presentation/cubit/faq_state.dart';
import 'package:mediconsult/core/utils/language_helper.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  String? _lastLanguageCode;

  @override
  void initState() {
    super.initState();
    // Don't use context here - it's not ready yet
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get current language - context is ready here
    final currentLang = LanguageHelper.getLanguageCode(context);
    
    // First time initialization or language changed
    if (_lastLanguageCode == null || _lastLanguageCode != currentLang) {
      final isLanguageChange = _lastLanguageCode != null && _lastLanguageCode != currentLang;
      _lastLanguageCode = currentLang;
      
      if (isLanguageChange) {
        // Clear cache and reset state immediately to prevent showing old data
        context.read<FaqCubit>().clearCache();
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          // Wait a bit to ensure cache is cleared before loading
          if (isLanguageChange) {
            await Future.delayed(const Duration(milliseconds: 50));
          }
          if (mounted) {
            context.read<FaqCubit>().load(
              lang: currentLang,
              forceRefresh: true, // Always force refresh to prevent cache issues
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyClr,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(title: 'profile.faq.title'.tr(), backPath: '/profile'),
            Expanded(
              child: Transform.translate(
                offset: Offset(0, -20.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteClr,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greyClr.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // FAQ list
                          SizedBox(height: 16.h),

                          BlocBuilder<FaqCubit, FaqState>(
                            builder: (context, state) {
                              return state.when(
                                initial: () => Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 24.h),
                                    child: const CircularProgressIndicator(),
                                  ),
                                ),
                                loading: () => Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 24.h),
                                    child: const CircularProgressIndicator(),
                                  ),
                                ),
                                failed: (message) => Padding(
                                  padding: EdgeInsets.only(top: 24.h),
                                  child: Text(
                                    message,
                                    style: AppTextStyles.font12GreyRegular(context),
                                  ),
                                ),
                                loaded: (faqResponse) {
                                  final data = faqResponse.data.faqs;
                                  return Column(
                                    children: data.map((faq) {
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 12.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteClr,
                                          borderRadius: BorderRadius.circular(12.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.greyClr.withValues(alpha: 0.14),
                                              blurRadius: 30,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            dividerColor: Colors.transparent,
                                          ),
                                          child: ExpansionTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                              side: const BorderSide(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            collapsedShape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.r),
                                              side: const BorderSide(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            title: Text(
                                              faq.question,
                                              style: AppTextStyles.font14BlackMedium(context),
                                            ),
                                            childrenPadding: EdgeInsets.all(12.w),
                                            children: [
                                              Text(
                                                faq.answer,
                                                style: AppTextStyles
                                                    .font14GreyRegular(context)
                                                    .copyWith(
                                                  height: 1.6,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
