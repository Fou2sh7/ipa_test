import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mediconsult/core/cache/cache_service.dart';
import 'package:mediconsult/core/constants/api_result.dart';
import 'package:mediconsult/features/support/data/faq_response_model.dart';
import 'package:mediconsult/features/support/presentation/cubit/faq_state.dart';
import 'package:mediconsult/features/support/repository/support_repository.dart';

class FaqCubit extends Cubit<FaqState> {
  final SupportRepository _repository;
  bool _cacheCleared = false;
  
  FaqCubit(this._repository) : super(const FaqState.initial());

  Future<void> load({required String lang, bool forceRefresh = false}) async {
    try {
      // If cache was cleared, always force refresh
      if (_cacheCleared) {
        forceRefresh = true;
        _cacheCleared = false; // Reset flag after using it
      }
      
      if (!forceRefresh) {
        final cached = await CacheService.getCachedFaqsData();
        if (cached != null) {
          emit(FaqState.loaded(FAQResponse.fromJson(cached)));
          unawaited(_fetchAndCache(lang));
          return;
        }
      }
      emit(const FaqState.loading());
      await _fetchAndCache(lang);
    } catch (e) {
      emit(FaqState.failed(e.toString()));
    }
  }

  Future<void> _fetchAndCache(String lang) async {
    final result = await _repository.getFaqs(lang);
    result.when(
      success: (data) async {
        await CacheService.cacheFaqsData(data.toJson());
        emit(FaqState.loaded(data));
      },
      failure: (message) async {
        // Don't use cache if it was cleared
        if (!_cacheCleared) {
          final cached = await CacheService.getCachedFaqsData();
          if (cached != null) {
            emit(FaqState.loaded(FAQResponse.fromJson(cached)));
            return;
          }
        }
        emit(FaqState.failed(message));
      },
    );
  }

  /// Clear FAQ cache and reset state to prevent showing old data
  Future<void> clearCache() async {
    await CacheService.clearFaqsCache();
    _cacheCleared = true; // Mark cache as cleared
    // Reset state to initial to prevent showing old cached data
    emit(const FaqState.initial());
  }
}


