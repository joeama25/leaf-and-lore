import 'package:flutter/foundation.dart';

/// Global app state shared across screens.
class AppState {
  /// Which bottom-nav tab is currently selected (0=Home .. 4=Profile).
  static final ValueNotifier<int> selectedTab = ValueNotifier<int>(0);
}