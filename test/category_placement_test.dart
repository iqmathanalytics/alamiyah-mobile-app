import 'package:alamiyah/data/models/models.dart';
import 'package:alamiyah/features/library/library_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('older categories move into the current lists', () {
    final morning = alignContentItem(
      ContentItem(
        id: 'm',
        type: ContentType.text,
        title: 'Morning Remembrance',
        category: 'morning',
        tags: const [],
        authorId: 'a',
        authorName: 'Alamiyah',
        status: ContentStatus.published,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
    expect(morning.category, 'invocations');
    expect(
      morning.section,
      collectionById('invocations')!.entries[1].title,
    );

    final names = placeContent(
      category: 'names',
      title: 'Ar-Rahman',
      section: null,
    );
    expect(names.categoryId, 'names');
    expect(names.section, 'Asma ul-Husna');

    final kept = placeContent(
      category: 'salawat',
      title: 'A custom salawat',
      section: 'Salawat Nariyah',
    );
    expect(kept.categoryId, 'salawat');
    expect(kept.section, 'Salawat Nariyah');
  });
}