import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';

class BookmarkController extends Notifier<Set<String>> {
  Box<dynamic> get _box => Hive.box(AppConstants.bookmarksBox);

  @override
  Set<String> build() {
    final stored = _box.get('ids');
    if (stored is List) {
      return stored.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  Future<void> toggle(String id) async {
    final next = {...state};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    await _box.put('ids', next.toList());
  }

  bool isBookmarked(String id) => state.contains(id);
}

final bookmarkControllerProvider =
    NotifierProvider<BookmarkController, Set<String>>(BookmarkController.new);
