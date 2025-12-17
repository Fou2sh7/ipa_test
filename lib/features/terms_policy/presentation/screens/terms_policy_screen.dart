import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/features/terms_policy/presentation/widgets/tab_navigation.dart';
import 'package:mediconsult/shared/widgets/page_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediconsult/features/terms_policy/presentation/cubit/terms_cubit.dart';
import 'package:mediconsult/features/terms_policy/presentation/cubit/terms_state.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mediconsult/core/utils/language_helper.dart';

class TermsPolicyScreen extends StatefulWidget {
  const TermsPolicyScreen({super.key});

  @override
  State<TermsPolicyScreen> createState() => _TermsPolicyScreenState();
}

class _TermsPolicyScreenState extends State<TermsPolicyScreen> {
  bool _isTermsSelected = true;
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
        context.read<TermsCubit>().clearCache();
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          // Wait a bit to ensure cache is cleared before loading
          if (isLanguageChange) {
            await Future.delayed(const Duration(milliseconds: 50));
          }
          if (mounted) {
            final cubit = context.read<TermsCubit>();
            if (_isTermsSelected) {
              cubit.loadTerms(currentLang, forceRefresh: true); // Always force refresh
            } else {
              cubit.loadPrivacy(currentLang, forceRefresh: true); // Always force refresh
            }
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
          children: [
            PageHeader(title: 'terms_policy.title'.tr(), backPath: '/profile'),
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
                    child: Column(
                      children: [
                        // Tab Navigation
                        TabNavigation(
                          isTermsSelected: _isTermsSelected,
                          onTabChanged: (isTerms) {
                            setState(() {
                              _isTermsSelected = isTerms;
                            });
                            final lang = LanguageHelper.getLanguageCode(context);
                            final cubit = context.read<TermsCubit>();
                            // Always use forceRefresh when switching tabs to ensure correct language
                            if (isTerms) {
                              cubit.loadTerms(lang, forceRefresh: true);
                            } else {
                              cubit.loadPrivacy(lang, forceRefresh: true);
                            }
                          },
                        ),

                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(16.w),
                            child: BlocBuilder<TermsCubit, TermsState>(
                              builder: (context, state) {
                                return state.when(
                                  initial: () {
                                    final lang = context.locale.languageCode;
                                    if (_isTermsSelected) {
                                      context.read<TermsCubit>().loadTerms(
                                        lang,
                                        forceRefresh: true,
                                      );
                                    } else {
                                      context.read<TermsCubit>().loadPrivacy(
                                        lang,
                                        forceRefresh: true,
                                      );
                                    }
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  failed: (message) => Text(
                                    message,
                                    style: AppTextStyles.font12GreyRegular(
                                      context,
                                    ),
                                  ),
                                  loaded: (resp) {
                                    final html = resp.data.description;

                                    // Show header with icon for Privacy Policy only
                                    if (!_isTermsSelected) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Header with policy icon
                                          Center(
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 80.w,
                                                  height: 80.w,
                                                  child: Image.asset(
                                                    AppAssets.shieldIcon,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                SizedBox(height: 16.h),
                                                Text(
                                                  'terms_policy.privacy_policy'
                                                      .tr(),
                                                  style:
                                                      AppTextStyles.font18BlackSemiBold(
                                                        context,
                                                      ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  'terms_policy.medical_insurance_app'
                                                      .tr(),
                                                  style:
                                                      AppTextStyles.font12GreyRegular(
                                                        context,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 24.h),
                                          // HTML content with custom styling
                                          Html(
                                            data: html,
                                            style: {
                                              "h1": Style(
                                                color: const Color(0xFF083D91),
                                                fontSize: FontSize(18.sp),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              "h2": Style(
                                                color: const Color(0xFF083D91),
                                                fontSize: FontSize(16.sp),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              "h3": Style(
                                                color: const Color(0xFF083D91),
                                                fontSize: FontSize(14.sp),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              "p": Style(
                                                fontSize: FontSize(12.sp),
                                                color: AppColors.blackClr,
                                              ),
                                            },
                                          ),
                                        ],
                                      );
                                    } else {
                                      // Terms content with custom styling
                                      return Html(
                                        data: html,
                                        style: {
                                          "h1": Style(
                                            color: const Color(0xFF083D91),
                                            fontSize: FontSize(18.sp),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          "h2": Style(
                                            color: const Color(0xFF083D91),
                                            fontSize: FontSize(16.sp),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          "h3": Style(
                                            color: const Color(0xFF083D91),
                                            fontSize: FontSize(14.sp),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          "p": Style(
                                            fontSize: FontSize(12.sp),
                                            color: AppColors.blackClr,
                                          ),
                                        },
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
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
