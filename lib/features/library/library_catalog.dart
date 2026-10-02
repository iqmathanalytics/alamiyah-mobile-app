import 'package:flutter/material.dart';

import '../../data/models/category.dart';
import '../../data/models/content_item.dart';

class DivineName {
  const DivineName(this.arabic, this.name, this.meaning);

  final String arabic;
  final String name;
  final String meaning;
}

/// The commonly recited ninety-nine names, in the usual order.
const divineNames = <DivineName>[
  DivineName('الرَّحْمَٰن', 'Ar-Rahman', 'The Most Compassionate'),
  DivineName('الرَّحِيم', 'Ar-Rahim', 'The Most Merciful'),
  DivineName('الْمَلِك', 'Al-Malik', 'The King'),
  DivineName('الْقُدُّوس', 'Al-Quddus', 'The Most Holy'),
  DivineName('السَّلَام', 'As-Salam', 'The Source of Peace'),
  DivineName('الْمُؤْمِن', 'Al-Mumin', 'The Granter of Security'),
  DivineName('الْمُهَيْمِن', 'Al-Muhaymin', 'The Guardian'),
  DivineName('الْعَزِيز', 'Al-Aziz', 'The Almighty'),
  DivineName('الْجَبَّار', 'Al-Jabbar', 'The Compeller'),
  DivineName('الْمُتَكَبِّر', 'Al-Mutakabbir', 'The Supreme'),
  DivineName('الْخَالِق', 'Al-Khaliq', 'The Creator'),
  DivineName('الْبَارِئ', 'Al-Bari', 'The Maker'),
  DivineName('الْمُصَوِّر', 'Al-Musawwir', 'The Fashioner'),
  DivineName('الْغَفَّار', 'Al-Ghaffar', 'The Ever-Forgiving'),
  DivineName('الْقَهَّار', 'Al-Qahhar', 'The Subduer'),
  DivineName('الْوَهَّاب', 'Al-Wahhab', 'The Bestower'),
  DivineName('الرَّزَّاق', 'Ar-Razzaq', 'The Provider'),
  DivineName('الْفَتَّاح', 'Al-Fattah', 'The Opener'),
  DivineName('الْعَلِيم', 'Al-Alim', 'The All-Knowing'),
  DivineName('الْقَابِض', 'Al-Qabid', 'The Withholder'),
  DivineName('الْبَاسِط', 'Al-Basit', 'The Expander'),
  DivineName('الْخَافِض', 'Al-Khafid', 'The Abaser'),
  DivineName('الرَّافِع', 'Ar-Rafi', 'The Exalter'),
  DivineName('الْمُعِزّ', 'Al-Muizz', 'The Giver of Honour'),
  DivineName('الْمُذِلّ', 'Al-Mudhill', 'The Humbler'),
  DivineName('السَّمِيع', 'As-Sami', 'The All-Hearing'),
  DivineName('الْبَصِير', 'Al-Basir', 'The All-Seeing'),
  DivineName('الْحَكَم', 'Al-Hakam', 'The Judge'),
  DivineName('الْعَدْل', 'Al-Adl', 'The Just'),
  DivineName('اللَّطِيف', 'Al-Latif', 'The Subtle'),
  DivineName('الْخَبِير', 'Al-Khabir', 'The All-Aware'),
  DivineName('الْحَلِيم', 'Al-Halim', 'The Forbearing'),
  DivineName('الْعَظِيم', 'Al-Azim', 'The Magnificent'),
  DivineName('الْغَفُور', 'Al-Ghafur', 'The Forgiving'),
  DivineName('الشَّكُور', 'Ash-Shakur', 'The Appreciative'),
  DivineName('الْعَلِيّ', 'Al-Ali', 'The Most High'),
  DivineName('الْكَبِير', 'Al-Kabir', 'The Greatest'),
  DivineName('الْحَفِيظ', 'Al-Hafiz', 'The Preserver'),
  DivineName('الْمُقِيت', 'Al-Muqit', 'The Sustainer'),
  DivineName('الْحَسِيب', 'Al-Hasib', 'The Reckoner'),
  DivineName('الْجَلِيل', 'Al-Jalil', 'The Majestic'),
  DivineName('الْكَرِيم', 'Al-Karim', 'The Generous'),
  DivineName('الرَّقِيب', 'Ar-Raqib', 'The Watchful'),
  DivineName('الْمُجِيب', 'Al-Mujib', 'The Answerer'),
  DivineName('الْوَاسِع', 'Al-Wasi', 'The Vast'),
  DivineName('الْحَكِيم', 'Al-Hakim', 'The Wise'),
  DivineName('الْوَدُود', 'Al-Wadud', 'The Loving'),
  DivineName('الْمَجِيد', 'Al-Majeed', 'The Glorious'),
  DivineName('الْبَاعِث', 'Al-Baith', 'The Resurrector'),
  DivineName('الشَّهِيد', 'Ash-Shahid', 'The Witness'),
  DivineName('الْحَقّ', 'Al-Haqq', 'The Truth'),
  DivineName('الْوَكِيل', 'Al-Wakil', 'The Trustee'),
  DivineName('الْقَوِيّ', 'Al-Qawiyy', 'The Strong'),
  DivineName('الْمَتِين', 'Al-Matin', 'The Firm'),
  DivineName('الْوَلِيّ', 'Al-Waliyy', 'The Protecting Friend'),
  DivineName('الْحَمِيد', 'Al-Hamid', 'The Praiseworthy'),
  DivineName('الْمُحْصِي', 'Al-Muhsi', 'The Accounter'),
  DivineName('الْمُبْدِئ', 'Al-Mubdi', 'The Originator'),
  DivineName('الْمُعِيد', 'Al-Muid', 'The Restorer'),
  DivineName('الْمُحْيِي', 'Al-Muhyi', 'The Giver of Life'),
  DivineName('الْمُمِيت', 'Al-Mumit', 'The Bringer of Death'),
  DivineName('الْحَيّ', 'Al-Hayy', 'The Ever-Living'),
  DivineName('الْقَيُّوم', 'Al-Qayyum', 'The Self-Subsisting'),
  DivineName('الْوَاجِد', 'Al-Wajid', 'The Finder'),
  DivineName('الْمَاجِد', 'Al-Majid', 'The Noble'),
  DivineName('الْوَاحِد', 'Al-Wahid', 'The One'),
  DivineName('الْأَحَد', 'Al-Ahad', 'The Unique'),
  DivineName('الصَّمَد', 'As-Samad', 'The Eternal'),
  DivineName('الْقَادِر', 'Al-Qadir', 'The Able'),
  DivineName('الْمُقْتَدِر', 'Al-Muqtadir', 'The Powerful'),
  DivineName('الْمُقَدِّم', 'Al-Muqaddim', 'The Expediter'),
  DivineName('الْمُؤَخِّر', 'Al-Muakhkhir', 'The Delayer'),
  DivineName('الْأَوَّل', 'Al-Awwal', 'The First'),
  DivineName('الْآخِر', 'Al-Akhir', 'The Last'),
  DivineName('الظَّاهِر', 'Az-Zahir', 'The Manifest'),
  DivineName('الْبَاطِن', 'Al-Batin', 'The Hidden'),
  DivineName('الْوَالِي', 'Al-Wali', 'The Governor'),
  DivineName('الْمُتَعَالِي', 'Al-Mutaali', 'The Most Exalted'),
  DivineName('الْبَرّ', 'Al-Barr', 'The Source of Goodness'),
  DivineName('التَّوَّاب', 'At-Tawwab', 'The Acceptor of Repentance'),
  DivineName('الْمُنْتَقِم', 'Al-Muntaqim', 'The Avenger'),
  DivineName('الْعَفُوّ', 'Al-Afuww', 'The Pardoner'),
  DivineName('الرَّءُوف', 'Ar-Rauf', 'The Kind'),
  DivineName('مَالِكُ الْمُلْك', 'Malik-ul-Mulk', 'Owner of Sovereignty'),
  DivineName('ذُو الْجَلَالِ وَالْإِكْرَام', 'Dhul-Jalali wal-Ikram', 'Lord of Majesty and Honour'),
  DivineName('الْمُقْسِط', 'Al-Muqsit', 'The Equitable'),
  DivineName('الْجَامِع', 'Al-Jami', 'The Gatherer'),
  DivineName('الْغَنِيّ', 'Al-Ghani', 'The Self-Sufficient'),
  DivineName('الْمُغْنِي', 'Al-Mughni', 'The Enricher'),
  DivineName('الْمَانِع', 'Al-Mani', 'The Withholder of Harm'),
  DivineName('الضَّارّ', 'Ad-Darr', 'The Distresser'),
  DivineName('النَّافِع', 'An-Nafi', 'The Benefiter'),
  DivineName('النُّور', 'An-Nur', 'The Light'),
  DivineName('الْهَادِي', 'Al-Hadi', 'The Guide'),
  DivineName('الْبَدِيع', 'Al-Badi', 'The Incomparable'),
  DivineName('الْبَاقِي', 'Al-Baqi', 'The Everlasting'),
  DivineName('الْوَارِث', 'Al-Warith', 'The Inheritor'),
  DivineName('الرَّشِيد', 'Ar-Rashid', 'The Guide to the Right Path'),
  DivineName('الصَّبُور', 'As-Sabur', 'The Patient'),
];

class LibraryEntry {
  const LibraryEntry(this.title, this.detail, {this.opens});

  final String title;
  final String detail;

  /// `surahs` opens the 114 surahs. `names` opens Asma ul-Husna.
  final String? opens;
}

class LibraryCollection {
  const LibraryCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.entries = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<LibraryEntry> entries;
}

const libraryCollections = <LibraryCollection>[
  LibraryCollection(
    id: 'quran',
    title: 'Qur’an',
    subtitle: '114 Surahs',
    icon: Icons.menu_book_rounded,
    entries: [
      LibraryEntry(
        '114 Surahs',
        'Every surah, from Al-Fatihah to An-Nas.',
        opens: 'surahs',
      ),
    ],
  ),
  LibraryCollection(
    id: 'invocations',
    title: 'Invocations Morning & Evening',
    subtitle: 'After the prayer, and around each salah',
    icon: Icons.wb_twilight_rounded,
    entries: [
      LibraryEntry(
        'Du’a Asaasi (After Obligatory Prayer)',
        'The essential supplication offered once the obligatory prayer is complete.',
      ),
      LibraryEntry(
        'Pre/Post Fajr Du’a',
        'Remembrance before Fajr, and the morning adhkar after it.',
      ),
      LibraryEntry(
        'Pre/Post Dhuhr Du’a',
        'A short return before Dhuhr, and the adhkar after the prayer.',
      ),
      LibraryEntry(
        'Pre/Post Asr Du’a',
        'Remembrance before Asr, and the turn toward evening after it.',
      ),
      LibraryEntry(
        'Pre/Post Maghrib Du’a',
        'The supplication at sunset, before Maghrib and after the prayer.',
      ),
      LibraryEntry(
        'Pre/Post Isha Du’a',
        'The closing remembrance before Isha, and what follows the night prayer.',
      ),
    ],
  ),
  LibraryCollection(
    id: 'salawat',
    title: 'Salawat',
    subtitle: 'Blessings on the Prophet',
    icon: Icons.favorite_border_rounded,
    entries: [
      LibraryEntry(
        'Salawat Nariyah',
        'A gathered blessing, often recited when a matter feels tight and needs opening.',
      ),
      LibraryEntry(
        'Salawat Azeemiya',
        'A longer salawat built on the greatness of the prophetic rank.',
      ),
      LibraryEntry(
        'Salawat Tunjina',
        'The salawat of relief, asked for at times of fear and distress.',
      ),
    ],
  ),
  LibraryCollection(
    id: 'awrad',
    title: 'Awrad & Litanies',
    subtitle: 'Daily wird and well-known hizbs',
    icon: Icons.auto_stories_rounded,
    entries: [
      LibraryEntry(
        'Sayyidi Awrad',
        'The daily litany of the path, kept at its own time rather than all at once.',
      ),
      LibraryEntry(
        'Dala\'il Al Khayrat',
        'The book of blessings on the Prophet, divided so a portion belongs to each day.',
      ),
      LibraryEntry(
        'Hizb al-Bahr',
        'The Litany of the Sea, a plea for protection associated with Imam al-Shadhili.',
      ),
      LibraryEntry(
        'Hizb al-Nasr',
        'The Litany of Victory, recited when steadfastness is needed.',
      ),
      LibraryEntry(
        'Wird al-Latif',
        'A gentle daily wird of short surahs, praise, and salawat.',
      ),
    ],
  ),
  LibraryCollection(
    id: 'teachings',
    title: 'Teachings',
    subtitle: 'Creed, practice, and the inward path',
    icon: Icons.school_outlined,
    entries: [
      LibraryEntry(
        'Aqidah/Creed',
        'What is believed about Allah, the messengers, and the Last Day, in plain language.',
      ),
      LibraryEntry(
        'Fiqh',
        'How the prayer, fasting, and everyday acts are carried out.',
      ),
      LibraryEntry(
        'Tasawwuf',
        'The inward manners of the path: sincerity, patience, and remembrance.',
      ),
    ],
  ),
  LibraryCollection(
    id: 'names',
    title: 'Divine Names',
    subtitle: 'Asma ul-Husna',
    icon: Icons.brightness_7_outlined,
    entries: [
      LibraryEntry(
        'Asma ul-Husna',
        'The ninety-nine names, recited one after another.',
        opens: 'names',
      ),
    ],
  ),
  LibraryCollection(
    id: 'poems',
    title: 'Poems & Qasa’id',
    subtitle: 'Dhikr Ashiq',
    icon: Icons.music_note_outlined,
    entries: [
      LibraryEntry(
        'Dhikr Ashiq',
        'Poems of longing, meant to be heard slowly rather than skimmed.',
      ),
    ],
  ),
];

LibraryCollection? collectionById(String id) {
  for (final item in libraryCollections) {
    if (item.id == id) return item;
  }
  return null;
}

/// Where a piece of content belongs in the current category list.
class ContentPlacement {
  const ContentPlacement({required this.categoryId, this.section});

  final String categoryId;
  final String? section;
}

String? _entryTitle(String collectionId, int index) {
  final entries = collectionById(collectionId)?.entries;
  if (entries == null || index < 0 || index >= entries.length) return null;
  return entries[index].title;
}

/// Maps stored categories onto the library list.
///
/// Pieces already filed under a current collection stay there. Older ids
/// (morning, evening, situational, and the rest) move into the matching
/// collection and child list.
ContentPlacement placeContent({
  required String category,
  required String title,
  String? section,
}) {
  final current = collectionById(category);
  if (current != null) {
    final onlyList = current.entries.length == 1 ? current.entries.first.title : null;
    if ((section == null || section.isEmpty) && onlyList != null) {
      return ContentPlacement(categoryId: category, section: onlyList);
    }
    return ContentPlacement(categoryId: category, section: section);
  }

  final lower = title.toLowerCase();
  switch (category) {
    case 'morning':
      return ContentPlacement(
        categoryId: 'invocations',
        section: _entryTitle('invocations', 1),
      );
    case 'evening':
      final isha = lower.contains('sleep') || lower.contains('isha');
      return ContentPlacement(
        categoryId: 'invocations',
        section: _entryTitle('invocations', isha ? 5 : 4),
      );
    case 'situational':
      return ContentPlacement(
        categoryId: 'invocations',
        section: _entryTitle('invocations', 0),
      );
    case 'names':
      return ContentPlacement(
        categoryId: 'names',
        section: section ?? _entryTitle('names', 0),
      );
    case 'reflections':
      return ContentPlacement(
        categoryId: 'teachings',
        section: _entryTitle('teachings', 2),
      );
    case 'video':
      if (lower.contains('morning')) {
        return ContentPlacement(
          categoryId: 'invocations',
          section: _entryTitle('invocations', 1),
        );
      }
      return ContentPlacement(
        categoryId: 'poems',
        section: _entryTitle('poems', 0),
      );
    case 'ramadan':
      return ContentPlacement(
        categoryId: 'teachings',
        section: _entryTitle('teachings', 1),
      );
    default:
      return ContentPlacement(categoryId: category, section: section);
  }
}

ContentItem alignContentItem(ContentItem item) {
  final placed = placeContent(
    category: item.category,
    title: item.title,
    section: item.section,
  );
  if (placed.categoryId == item.category && placed.section == item.section) {
    return item;
  }
  return item.copyWith(
    category: placed.categoryId,
    section: placed.section,
    clearSection: placed.section == null,
  );
}

const _categoryColors = <String>[
  '#3D6B5A',
  '#7BA882',
  '#C4A35A',
  '#5A8F7B',
  '#2F5D4A',
  '#8FA894',
  '#B8956A',
];

List<Category> get libraryCategories => [
      for (var i = 0; i < libraryCollections.length; i++)
        Category(
          id: libraryCollections[i].id,
          name: libraryCollections[i].title,
          iconRef: 'library',
          colorHint: _categoryColors[i % _categoryColors.length],
          sortOrder: i + 1,
        ),
    ];
