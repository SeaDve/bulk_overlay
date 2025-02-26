import 'package:bulk_overlay/data/image_repository.dart';
import 'package:flutter_test/flutter_test.dart';

int sum(int a, int b) {
  return a + b;
}

void main() {
  test('should properly handle removing and adding', () {
    final repo = ImageRepository();
    expect(repo.length, 0);

    repo.add(['a', 'b', 'c']);
    expect(repo.length, 3);

    repo.remove('b');
    expect(repo.length, 2);

    repo.removeAll();
    expect(repo.length, 0);
  });

  test('should handle proper getting at index', () {
    final repo = ImageRepository();
    repo.add(['a', 'b', 'c']);
    expect(repo.getAt(1), 'b');
  });
}
