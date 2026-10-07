import 'package:flutter/foundation.dart';

class AppState {
  /// Which bottom-nav tab is currently selected (0=Home .. 4=Profile).
  static final ValueNotifier<int> selectedTab = ValueNotifier<int>(0);

  /// When set, BrowseScreen will apply this genre filter on its next load.
  /// Browse clears it back to null after consuming it.
  static final ValueNotifier<String?> pendingGenre =
  ValueNotifier<String?>(null);
}