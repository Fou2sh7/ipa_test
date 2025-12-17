import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mediconsult/core/services/home_refresh_service.dart';
import 'package:mediconsult/core/theming/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:mediconsult/core/theming/app_text_styles.dart';
import 'package:mediconsult/core/error/app_error_handler.dart';
import 'package:mediconsult/features/home/presentation/cubit/cubit/home_cubit.dart';
import 'package:mediconsult/features/home/presentation/cubit/cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:mediconsult/features/home/presentation/widgets/home_header_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/user_plan_card_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/quick_access_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mediconsult/features/home/presentation/widgets/khusm_promotion_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/ongoing_request_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/health_tips_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/explore_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/bottom_navigation_bar_widget.dart';
import 'package:mediconsult/features/home/presentation/widgets/home_loading_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediconsult/core/utils/language_helper.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  StreamSubscription<void>? _refreshSubscription;
  final ScrollController _scrollController = ScrollController();
  bool _canRefresh = true; // Flag to control refresh

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    // Listen to refresh notifications to update data when approval request is created
    _refreshSubscription = HomeRefreshService().refreshStream.listen((_) {
      if (mounted && _hasLoadedOnce) {
        // Refresh home data when approval request is created
        final lang = LanguageHelper.getLanguageCode(context);
        context.read<HomeCubit>().refreshHomeInfo(lang);
      }
    });
    // call home info when the screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAndLoadData();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Update refresh flag: only allow refresh if scroll is at the top
    _canRefresh = position.pixels <= 0;
  }
  
  bool _onNotification(ScrollNotification notification) {
    // Allow refresh when user intentionally pulls down from the top
    // Only prevent refresh when overscrolling from status bar (when not at top)
    if (notification is ScrollStartNotification) {
      // Check if scroll is starting from top (pixels should be 0 or negative)
      if (_scrollController.hasClients) {
        final pixels = _scrollController.position.pixels;
        _canRefresh = pixels <= 0;
      }
    } else if (notification is OverscrollNotification) {
      // Only prevent refresh if we're NOT at the top and overscrolling
      // This prevents refresh when pulling status bar
      if (_scrollController.hasClients) {
        final pixels = _scrollController.position.pixels;
        // Allow refresh only if at top (pixels <= 0) and overscrolling downward
        if (pixels > 0) {
          // Not at top, prevent refresh (likely status bar pull)
          _canRefresh = false;
        } else {
          // At top, allow refresh if overscrolling downward
          _canRefresh = notification.overscroll > 0;
        }
      }
    } else if (notification is ScrollUpdateNotification) {
      // Update refresh flag during scroll - allow if at top
      if (_scrollController.hasClients) {
        final pixels = _scrollController.position.pixels;
        _canRefresh = pixels <= 0;
      }
    }
    return false; // Allow notification to continue
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  bool _hasLoadedOnce = false;
  AppLifecycleState? _previousLifecycleState;
  DateTime? _lastPausedTime;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Don't auto-refresh on lifecycle changes - only manual pull to refresh
    // Track when app goes to background (for future use if needed)
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _lastPausedTime = DateTime.now();
    }
    
    // Disabled auto-refresh on resume - user must manually pull to refresh
    // if (state == AppLifecycleState.resumed && _hasLoadedOnce && _lastPausedTime != null) {
    //   final wasInBackground = _previousLifecycleState == AppLifecycleState.paused || 
    //                           _previousLifecycleState == AppLifecycleState.inactive;
    //   
    //   if (wasInBackground) {
    //     final timeInBackground = DateTime.now().difference(_lastPausedTime!);
    //     if (timeInBackground.inMilliseconds > 3000) {
    //       _refreshIfNeeded();
    //     }
    //     _lastPausedTime = null;
    //   }
    // }
    
    _previousLifecycleState = state;
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Don't auto-refresh on dependency changes - only manual pull to refresh
    // if (_hasLoadedOnce) {
    //   Future.delayed(const Duration(milliseconds: 300), () {
    //     if (mounted) {
    //       _refreshIfNeeded();
    //     }
    //   });
    // }
  }

  // This method will be called when the screen becomes visible again
  // It's triggered by the widget lifecycle when navigating back
  @override
  void activate() {
    super.activate();
    // Don't auto-refresh when screen becomes active - only manual pull to refresh
    // if (_hasLoadedOnce) {
    //   Future.delayed(const Duration(milliseconds: 300), () {
    //     if (mounted) {
    //       _refreshIfNeeded();
    //     }
    //   });
    // }
  }

  void _refreshIfNeeded() {
    // Always refresh when called - don't check time threshold
    // This ensures data is always fresh when returning to home screen
    if (_hasLoadedOnce && mounted) {
      final cubit = context.read<HomeCubit>();
      final state = cubit.state;
      // Only refresh if we have loaded data (not initial/loading state)
      state.when(
        initial: () {},
        loading: () {},
        loaded: (_) {
          // Refresh data when returning to home screen to show newly created approval requests
          cubit.refreshHomeInfo(LanguageHelper.getLanguageCode(context));
        },
        failed: (_) {},
      );
    }
  }
  
  Future<void> _checkPermissionsAndLoadData() async {
    try {
      // Load home data regardless of permissions
      context.read<HomeCubit>().getHomeInfo(LanguageHelper.getLanguageCode(context));
    } catch (e) {
      // If there's an error, still try to load home data
      context.read<HomeCubit>().getHomeInfo(LanguageHelper.getLanguageCode(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildHomeContent(context);
  }

  Widget _buildHomeContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyClr,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeCubitState>(
          builder: (context, state) {
            return state.when(
              initial: () => const HomeLoadingWidget(),
              loading: () => const HomeLoadingWidget(),

              /// when the data is loaded, show the page with the real data
              loaded: (model) {
                // Mark that we've loaded data at least once
                if (!_hasLoadedOnce) {
                  _hasLoadedOnce = true;
                }
                final data = model.data;
                return NotificationListener<ScrollNotification>(
                  onNotification: _onNotification,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Always allow refresh when user pulls down from top
                      // The _canRefresh flag is mainly for preventing status bar pulls
                      await context.read<HomeCubit>().refreshHomeInfo(LanguageHelper.getLanguageCode(context));
                    },
                    // Prevent refresh when pulling from status bar
                    displacement: 40.0,
                    edgeOffset: 0.0,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      child: Column(
                      children: [
                        // Wrap header in RepaintBoundary for better performance
                        RepaintBoundary(
                          child: HomeHeaderWidget(data: data!),
                        ),
                        RepaintBoundary(
                          child: Stack(
                          clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 130.h,
                                color: AppColors.primaryClr,
                              ),
                              Positioned(
                                bottom: -70.h,
                                left: 16.w,
                                right: 16.w,
                                child: UserPlanCardWidget(data: data),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 80.h),
                        Container(
                          color: AppColors.lightGreyClr,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RepaintBoundary(
                                child: const QuickAccessWidget(),
                              ),
                              SizedBox(height: 24.h),
                              RepaintBoundary(
                                child: const KhusmPromotionWidget(),
                              ),
                              SizedBox(height: 24.h),
                              if (data.approvals.any((approval) => approval.status.toLowerCase() == 'reviewing')) ...[
                                RepaintBoundary(
                                  child: OngoingRequestWidget(data: data),
                                ),
                                SizedBox(height: 24.h),
                              ],
                              RepaintBoundary(
                                child: const HealthTipsWidget(),
                              ),
                              SizedBox(height: 24.h),
                              RepaintBoundary(
                                child: const ExploreWidget(),
                              ),
                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),);
              },

              /// in case of error
              failed: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.w,
                      color: AppColors.errorClr,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'home.error_loading'.tr(),
                      style: AppTextStyles.font16BlackMedium(context),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Text(
                        AppErrorHandler.getUserFriendlyMessage(message),
                        style: AppTextStyles.font14GreyRegular(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<HomeCubit>().retry(LanguageHelper.getLanguageCode(context));
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text('common.retry'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryClr,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = 0;
          });
          if (index == 1) {
            context.push('/network');
          } else if (index == 2) {
            context.push('/approval-request');
          } else if (index == 3) {
            context.push('/profile');
          }
        },
      ),
    );
  }
}