import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secrets_of_the_copper_still/providers/vessel_provider.dart';
import 'package:secrets_of_the_copper_still/screens/stats_screen.dart';

void main() {
  testWidgets('StatsScreen shows empty logbook state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vesselProvider.overrideWith((ref) {
            final notifier = VesselNotifier();
            notifier.isLoading = false;
            notifier.entries = [];
            return notifier;
          }),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, _) => const MaterialApp(home: StatsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LOGBOOK EMPTY'), findsOneWidget);
    expect(find.text('Archive Intelligence'), findsOneWidget);
  });
}
