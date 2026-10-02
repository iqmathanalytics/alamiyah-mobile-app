import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/alamiyah_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../library/category_contents.dart';
import '../../library/library_catalog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AlamiyahAppBar(title: context.s.categories),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          for (final item in libraryCollections) ...[
            _CollectionTile(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
              selected: _selectedId == item.id,
              onTap: () => setState(() {
                _selectedId = _selectedId == item.id ? null : item.id;
              }),
            ),
            if (_selectedId == item.id) ...[
              const SizedBox(height: 10),
              CategoryContents(collection: item),
            ],
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.alamiyahColors;
    return Material(
      color: selected ? colors.chipBackground : colors.cardBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.chipBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colors.brandPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.brandPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: colors.brandSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: 20,
                color: colors.brandSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
