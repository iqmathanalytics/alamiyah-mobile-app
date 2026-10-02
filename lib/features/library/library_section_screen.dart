import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/alamiyah_colors.dart';
import '../../core/theme/app_theme.dart';
import 'library_catalog.dart';
import 'surah_catalog.dart';

class LibrarySectionScreen extends StatelessWidget {
  const LibrarySectionScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context) {
    final collection = collectionById(collectionId);
    final colors = context.alamiyahColors;
    if (collection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Library')),
        body: const Center(child: Text('This collection is not available.')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: colors.brandPrimary,
        title: Text(
          collection.title,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: colors.brandPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            collection.subtitle,
            style: GoogleFonts.dmSans(color: colors.brandSecondary),
          ),
          const SizedBox(height: 16),
          ...collection.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LibraryEntryCard(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryEntryCard extends StatelessWidget {
  const LibraryEntryCard({super.key, required this.entry});

  final LibraryEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Material(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          final opens = entry.opens;
          if (opens == 'surahs') {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SurahIndexScreen(),
              ),
            );
            return;
          }
          if (opens == 'names') {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DivineNamesScreen(),
              ),
            );
          }
        },
        child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.brandPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              entry.detail,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                height: 1.45,
                color: colors.brandSecondary,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class DivineNamesScreen extends StatelessWidget {
  const DivineNamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: colors.brandPrimary,
        title: Text(
          'Asma ul-Husna',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: colors.brandPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          for (final name in divineNames) _NameRow(name: name),
        ],
      ),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({required this.name});

  final DivineName name;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.name,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      color: colors.brandPrimary,
                    ),
                  ),
                  Text(
                    name.meaning,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: colors.brandSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              name.arabic,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabicStyle(context, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class SurahIndexScreen extends StatefulWidget {
  const SurahIndexScreen({super.key});

  @override
  State<SurahIndexScreen> createState() => _SurahIndexScreenState();
}

class _SurahIndexScreenState extends State<SurahIndexScreen> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    final query = _query.trim().toLowerCase();
    final surahs = surahCatalog.where((surah) {
      if (query.isEmpty) return true;
      return surah.name.toLowerCase().contains(query) ||
          surah.meaning.toLowerCase().contains(query) ||
          '${surah.number}' == query;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: colors.brandPrimary,
        title: Text(
          'Qur’an',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: colors.brandPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search a surah',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: colors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              itemCount: surahs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final surah = surahs[index];
                return Material(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: colors.surfaceElevated,
                      showDragHandle: true,
                      builder: (context) => _SurahSheet(surah: surah),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.chipBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${surah.number}',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w700,
                                color: colors.brandPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surah.name,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w700,
                                    color: colors.brandPrimary,
                                  ),
                                ),
                                Text(
                                  '${surah.meaning} · ${surah.ayahs} ayat',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: colors.brandSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            surah.arabic,
                            textDirection: TextDirection.rtl,
                            style: AppTheme.arabicStyle(context, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahSheet extends StatelessWidget {
  const _SurahSheet({required this.surah});

  final SurahInfo surah;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            surah.arabic,
            textDirection: TextDirection.rtl,
            style: AppTheme.arabicStyle(context, fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            surah.name,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.brandPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${surah.meaning} · Surah ${surah.number} · ${surah.place} · ${surah.ayahs} ayat',
            style: GoogleFonts.dmSans(
              color: colors.brandSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
