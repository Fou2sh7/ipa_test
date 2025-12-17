import 'dart:async';

/// Service to notify HomeScreen to refresh its data
/// This is used when data changes in other screens (e.g., approval request submission)
class HomeRefreshService {
  static final HomeRefreshService _instance = HomeRefreshService._internal();
  factory HomeRefreshService() => _instance;
  HomeRefreshService._internal();

  final _refreshController = StreamController<void>.broadcast();

  /// Stream that emits when home screen should refresh
  Stream<void> get refreshStream => _refreshController.stream;

  /// Notify that home screen should refresh
  void notifyRefresh() {
    _refreshController.add(null);
  }

  void dispose() {
    _refreshController.close();
  }
}

