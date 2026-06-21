import 'package:flutter_test/flutter_test.dart';
import 'package:secrets_of_the_copper_still/utils/ledger_key_generator.dart';
import 'package:secrets_of_the_copper_still/enum/my_enums.dart';

void main() {
  test('ledger key follows SCS-STILL format', () {
    final key = LedgerKeyGenerator.generate(
      apparatus: ApparatusClassification.gooseneckAlembic,
      method: DistillationMethod.steamDistillation,
    );
    expect(key.startsWith('SCS-STILL-'), true);
    expect(key.contains('-ALEMB-'), true);
    expect(key.endsWith('-BOTAN'), true);
  });
}
