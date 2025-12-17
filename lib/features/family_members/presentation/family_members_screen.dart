import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/constants/app_assets.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/core/widgets/image_shimmer.dart';
import 'package:mediconsult/shared/widgets/page_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediconsult/features/family_members/presentation/cubit/family_members_cubit.dart';
import 'package:mediconsult/features/family_members/presentation/cubit/family_members_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mediconsult/core/utils/language_helper.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
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
        // Clear cache and reload with new language
        context.read<FamilyMembersCubit>().clearCache();
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Always force refresh to ensure data matches current language
          context.read<FamilyMembersCubit>().getFamilyMembers(
            currentLang,
            forceRefresh: true,
          );
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
            PageHeader(title: 'family_members.title'.tr(), backPath: '/home'),
            Expanded(
              child: Transform.translate(
                offset: Offset(0, -20.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    width: double.infinity,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text(
                            'family_members.members'.tr(),
                            style: (AppTextStyles.font14BlackMedium(context)),
                          ),
                        ),
                        Expanded(
                          child:
                              BlocBuilder<
                                FamilyMembersCubit,
                                FamilyMembersState
                              >(
                                builder: (context, state) {
                                  return state.when(
                                    initial: () => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    loading: () => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    failed: (msg) => Center(
                                      child: Text(
                                        msg.isNotEmpty ? msg : 'common.error'.tr(),
                                        style: AppTextStyles.font14GreyRegular(context),
                                      ),
                                    ),
                                    loaded: (model) {
                                      final members = model.data.familyMembers;
                                      if (members.isEmpty) {
                                        return Center(
                                          child: Text(
                                            'family_members.no_members'.tr(),
                                          ),
                                        );
                                      }
                                      return RefreshIndicator(
                                        onRefresh: () => context
                                            .read<FamilyMembersCubit>()
                                            .refreshFamilyMembers(
                                              LanguageHelper.getLanguageCode(
                                                context,
                                              ),
                                            ),
                                        child: ListView.separated(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                          ),
                                          itemCount: members.length,
                                          separatorBuilder: (_, __) => Column(
                                            children: [
                                              SizedBox(height: 12.h),
                                              Divider(
                                                color: AppColors.greyClr
                                                    .withValues(alpha: 0.2),
                                                thickness: 1,
                                                height: 1,
                                                indent: 16.w,
                                                endIndent: 16.w,
                                              ),
                                              SizedBox(height: 12.h),
                                            ],
                                          ),

                                          itemBuilder: (context, index) {
                                            final member = members[index];
                                            return _buildMemberCard(member);
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
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
      // floatingActionButton: FloatingActionButton(
      //   shape: const CircleBorder(),
      //   backgroundColor: AppColors.primaryClr,
      //   onPressed: () {
      //     context.go('/add-member');
      //   },
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  /// Translate level value from API to localized string
  String _translateLevel(String level, bool isHeadOfFamily) {
    final levelLower = level.trim().toLowerCase();
    
    // If it's head of family, show "Head of Family"
    if (isHeadOfFamily) {
      return 'family_members.level.head_of_family'.tr();
    }
    
    // Map common level values
    switch (levelLower) {
      case 'member':
        // For non-head members, we might need to show relationship if available
        // But since API returns "Member", we'll use a generic translation
        return 'family_members.level.member'.tr();
      case 'spouse':
        return 'family_members.relationships.spouse'.tr();
      case 'son':
        return 'family_members.relationships.son'.tr();
      case 'daughter':
        return 'family_members.relationships.daughter'.tr();
      case 'parent':
        return 'family_members.relationships.parent'.tr();
      default:
        // Fallback to original value if no match
        return level;
    }
  }

  /// Translate member status from API to localized string
  String _translateMemberStatus(String status) {
    final statusLower = status.trim().toLowerCase();
    
    switch (statusLower) {
      case 'activated':
        return 'family_members.activated_member'.tr();
      case 'inactive':
      case 'deactivated':
        return 'family_members.inactive_member'.tr();
      default:
        // Fallback to original value if no match
        return status;
    }
  }

  /// Translate program name from API to localized string
  String _translateProgramName(String programName) {
    final programLower = programName.trim().toLowerCase();
    
    // Map common program names
    switch (programLower) {
      case 'gold plan':
      case 'gold':
        return 'family_members.gold_plan'.tr();
      case 'platinum-vip':
      case 'platinum vip':
      case 'platinum':
        return 'family_members.platinum_vip'.tr();
      default:
        // Fallback to original value if no match
        return programName;
    }
  }

  Widget _buildMemberCard(member) {
    // Translate member status
    final String displayStatus =
        (member.memberStatus != null && member.memberStatus.isNotEmpty)
        ? _translateMemberStatus(member.memberStatus)
        : 'family_members.activated_member'.tr();

    // Translate level (pass isHeadOfFamily to determine if it's head of family)
    final String translatedLevel = _translateLevel(member.level, member.isHeadOfFamily);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 32.r,
          backgroundColor: AppColors.lightGreyClr,
          child: (member.memberImage != null && member.memberImage!.isNotEmpty)
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: member.memberImage!,
                    fit: BoxFit.cover,
                    width: 64.w,
                    height: 64.h,
                    placeholder: (context, url) => ImageShimmer.circle(),
                    errorWidget: (context, url, error) => Image.asset(
                      AppAssets.logo,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.cover,
                ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.memberName,
                style: AppTextStyles.font12BlackMedium(context),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Image.asset(
                    AppAssets.user,
                    width: member.isHeadOfFamily ? 16.w : 12.w,
                    height: member.isHeadOfFamily ? 16.h : 12.h,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    translatedLevel,
                    style: AppTextStyles.font12GreyRegular(context),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12.sp,
                    color: member.isActive ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    displayStatus,
                    style: AppTextStyles.font12GreyRegular(context).copyWith(
                      color: member.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              // Only show plan if programName is available
              if (member.programName != null && member.programName!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryClr,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                      bottomRight: Radius.circular(8.r),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppAssets.goldPlan,
                        width: 12.sp,
                        height: 12.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _translateProgramName(member.programName!),
                        style: AppTextStyles.font12BlackMedium(
                          context,
                        ).copyWith(
                          fontSize: 10.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
