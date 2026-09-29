import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:alamiyah/core/constants/app_constants.dart';
import 'package:alamiyah/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('alamiyah_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(AppConstants.prefsBox);
    await Hive.openBox(AppConstants.bookmarksBox);
    await Hive.openBox(AppConstants.adminDraftsBox);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('Alamiyah first launch shows onboarding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AlamiyahApp()));
    await tester.pump();
    expect(find.text('Alamiyah'), findsWidgets);
    expect(find.text('Skip'), findsOneWidget);
    // Drain brand-intro assemble + hold + fade controllers.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
  });
}
