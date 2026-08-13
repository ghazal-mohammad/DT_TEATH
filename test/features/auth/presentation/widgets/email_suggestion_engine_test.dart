import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/email_suggestion_engine.dart';

void main() {
  const engine = EmailSuggestionEngine();

  test('empty text yields no suggestions', () {
    expect(engine.suggestionsFor(''), isEmpty);
  });

  test('local part without @ suggests full addresses for each domain', () {
    expect(
      engine.suggestionsFor('ali'),
      ['ali@clinic.com', 'ali@dtteeth.com'],
    );
  });

  test('invalid local part characters yield no suggestions', () {
    expect(engine.suggestionsFor('ali!!'), isEmpty);
  });

  test('trailing @ with empty domain suggests all domains', () {
    expect(
      engine.suggestionsFor('ali@'),
      ['ali@clinic.com', 'ali@dtteeth.com'],
    );
  });

  test('partial domain filters to matching domains only', () {
    expect(engine.suggestionsFor('ali@cl'), ['ali@clinic.com']);
  });

  test('empty local part before @ yields no suggestions', () {
    expect(engine.suggestionsFor('@clinic'), isEmpty);
  });

  test('non-matching domain yields no suggestions', () {
    expect(engine.suggestionsFor('ali@zzz'), isEmpty);
  });

  test('custom domain list overrides default', () {
    const custom = EmailSuggestionEngine(domains: ['example.com']);
    expect(custom.suggestionsFor('bob'), ['bob@example.com']);
  });
}
