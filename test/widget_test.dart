import 'package:flutter_test/flutter_test.dart';

import 'package:akmmc_edu_bd/main.dart';

void main() {
  test('opens the official AKMMC website', () {
    expect(akmmcWebsiteUrl, 'https://akmmc.edu.bd/');
  });
}
