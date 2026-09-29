import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';

class OnboardingController extends Notifier<bool> {
  Box<dynamic> get _box => Hive.box(AppConstants.prefsBox);

  @override
  bool build() {
    return _box.get(AppConstants.onboardingCompleteKey) == true;
  }

  Future<void> complete() async {
    await _box.put(AppConstants.onboardingCompleteKey, true);
    state = true;
  }
}

final onboardingCompleteProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);
