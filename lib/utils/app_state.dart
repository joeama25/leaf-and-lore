import 'package:flutter/foundation.dart';

class AppState {
  static final ValueNotifier<int> selectedTab = ValueNotifier<int>(0);
  static final ValueNotifier<String?> pendingGenre =
  ValueNotifier<String?>(null);

  /// Which admin tab is selected (0=Dashboard, 1=Books, 2=Users, 3=Orders).
  static final ValueNotifier<int> adminTab = ValueNotifier<int>(0);
}