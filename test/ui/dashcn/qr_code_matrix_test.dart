import 'package:flutter_test/flutter_test.dart';
import 'package:ud_sass_app/ui/dashcn/src/components/qr_code/qr_code_matrix.dart';

void main() {
  group('QrMatrix.encode', () {
    test('returns a blank version-one matrix for empty data', () {
      final QrMatrix matrix = QrMatrix.encode('');

      expect(matrix.moduleCount, 21);
      expect(matrix.typeNumber, 1);
      expect(
        List<bool>.generate(
          matrix.moduleCount * matrix.moduleCount,
          (int index) => matrix.isDark(
            index ~/ matrix.moduleCount,
            index % matrix.moduleCount,
          ),
        ),
        everyElement(isFalse),
      );
    });

    test('encodes finder patterns into a row-major matrix', () {
      final QrMatrix matrix = QrMatrix.encode('HELLO WORLD');

      expect(matrix.moduleCount, 21);
      expect(matrix.typeNumber, 1);
      expect(matrix.isDark(0, 0), isTrue);
      expect(matrix.isDark(0, 1), isTrue);
      expect(matrix.isDark(1, 1), isFalse);
      expect(matrix.isDark(3, 3), isTrue);
      expect(matrix.isDark(0, 20), isTrue);
      expect(matrix.isDark(20, 0), isTrue);
    });

    test('higher error correction can select a larger matrix', () {
      const String payload =
          'A QR matrix should adapt its version for both payload size and '
          'the requested error correction level.';

      final QrMatrix medium = QrMatrix.encode(
        payload,
        level: QrErrorCorrectionLevel.medium,
      );
      final QrMatrix high = QrMatrix.encode(
        payload,
        level: QrErrorCorrectionLevel.high,
      );

      expect(medium.typeNumber, greaterThanOrEqualTo(1));
      expect(high.typeNumber, greaterThanOrEqualTo(medium.typeNumber));
      expect(high.moduleCount, 17 + 4 * high.typeNumber);
    });

    test('equality compares module contents as well as matrix size', () {
      final QrMatrix first = QrMatrix.encode('same payload');
      final QrMatrix same = QrMatrix.encode('same payload');
      final QrMatrix different = QrMatrix.encode('different payload');

      expect(first, same);
      expect(first.hashCode, same.hashCode);
      expect(first, isNot(different));
    });

    test('out-of-range cells are light', () {
      final QrMatrix matrix = QrMatrix.encode('payload');

      expect(matrix.isDark(-1, 0), isFalse);
      expect(matrix.isDark(0, -1), isFalse);
      expect(matrix.isDark(matrix.moduleCount, 0), isFalse);
      expect(matrix.isDark(0, matrix.moduleCount), isFalse);
    });
  });
}
