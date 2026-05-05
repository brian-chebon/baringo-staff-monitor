import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../constants/baringo_data.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/locale_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _flagSwatches = <String, Color>{
    'Green': AppColors.flagGreen,
    'Golden Yellow': AppColors.flagGold,
    'Golden Brown': AppColors.flagBrown,
    'White': Colors.white,
    'Lake Blue': AppColors.lakeBlue,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.about)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Header(),
          const SizedBox(height: 16),
          _Card(
            title: l.motto,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.deliverAsOne,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.flagGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l.fromVisionToImpact,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          _Card(
            title: l.leadership,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.account_balance,
                color: AppColors.flagGreen,
              ),
              title: Text(l.governor),
              subtitle: const Text(BaringoData.governor),
            ),
          ),
          _Card(
            title: l.cabinet,
            child: Column(
              children: BaringoData.cabinet.entries
                  .map((e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const Icon(
                          Icons.person,
                          color: AppColors.flagGreen,
                          size: 20,
                        ),
                        title: Text(
                          e.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          e.value,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ))
                  .toList(),
            ),
          ),
          _Card(
            title: l.contact,
            child: Column(
              children: BaringoData.contact.entries
                  .map((e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: Icon(
                          _iconFor(e.key),
                          color: AppColors.flagGreen,
                        ),
                        title: Text(e.key),
                        subtitle: Text(e.value),
                      ))
                  .toList(),
            ),
          ),
          _Card(
            title: l.countyFlag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SvgPicture.asset(
                        'assets/images/baringo_flag.svg',
                        width: 220,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l.countyFlagDescription,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                ..._flagSwatches.entries.map((entry) {
                  final meaning = BaringoData.flagSymbolism[entry.key] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: entry.value,
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (meaning.isNotEmpty)
                                Text(
                                  meaning,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          _Card(
            title: l.language,
            child: const _LanguageSwitch(),
          ),
          _Card(
            title: l.aboutThisApp,
            child: Text(
              l.aboutThisAppBody,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String label) {
    switch (label) {
      case 'Toll-free':
        return Icons.call;
      case 'Email':
        return Icons.email;
      case 'Website':
        return Icons.public;
      case 'Postal address':
        return Icons.markunread_mailbox;
      default:
        return Icons.info_outline;
    }
  }
}

class _LanguageSwitch extends StatelessWidget {
  const _LanguageSwitch();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final code = localeProvider.locale.languageCode;
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'en', label: Text(l.english)),
        ButtonSegment(value: 'sw', label: Text(l.swahili)),
      ],
      selected: {code},
      onSelectionChanged: (s) =>
          context.read<LocaleProvider>().setLocale(Locale(s.first)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.flagGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/baringo_flag.svg',
              width: 80,
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'County Government of Baringo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.flagGreen,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Headquarters: Kabarnet',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.flagGreen,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
