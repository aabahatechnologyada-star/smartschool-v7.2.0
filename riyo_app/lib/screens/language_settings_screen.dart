import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riyo_app/riyo_theme.dart';
import 'package:riyo_app/state_widgets.dart';
import 'package:riyo_app/l10n/generated/app_localizations.dart';

/// Language settings screen with English and Somali support
class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguageCode = 'en';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? 'en';
    if (mounted) {
      setState(() {
        _selectedLanguageCode = code;
        _loading = false;
      });
    }
  }

  Future<void> _saveLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    if (mounted) {
      setState(() => _selectedLanguageCode = code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return Scaffold(
        backgroundColor: RiyoTheme.black,
        appBar: AppBar(
          title: Text(l10n.language),
          backgroundColor: RiyoTheme.black,
        ),
        body: const Center(child: LoadingView(message: 'Loading...')),
      );
    }

    return Scaffold(
      backgroundColor: RiyoTheme.black,
      appBar: AppBar(
        title: Text(l10n.language),
        backgroundColor: RiyoTheme.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(RiyoTheme.space4),
        children: [
          // Language options
          _LanguageOption(
            code: 'en',
            name: l10n.english,
            nativeName: 'English',
            selected: _selectedLanguageCode == 'en',
            onTap: () => _changeLanguage('en'),
          ),
          const SizedBox(height: RiyoTheme.space3),
          _LanguageOption(
            code: 'so',
            name: l10n.somali,
            nativeName: 'Af-Soomaali',
            selected: _selectedLanguageCode == 'so',
            onTap: () => _changeLanguage('so'),
          ),
          const SizedBox(height: RiyoTheme.space6),
          // Info text
          Container(
            padding: const EdgeInsets.all(RiyoTheme.space4),
            decoration: BoxDecoration(
              color: RiyoTheme.gray900,
              borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
              border: Border.all(color: RiyoTheme.gray700, width: 0.5),
            ),
            child: Text(
              _selectedLanguageCode == 'en'
                  ? 'App will restart to apply language change.'
                  : 'Barnaamijku wuxuu dib u noqon doonaa in lagu bedelo luqadda.',
              style: RiyoTheme.bodyMedium.copyWith(color: RiyoTheme.gray400),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _changeLanguage(String code) async {
    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: RiyoTheme.gray900,
        title: Text(l10n.selectLanguage),
        content: Text(
          code == 'en' ? 'Change language to English? The app will restart.' : 'Luqadda beddel Soomaali? Barnaamijku wuxuu dib u noqon doonaa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.more, style: TextStyle(color: RiyoTheme.gray400)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: RiyoTheme.white),
            child: Text(
              l10n.language,
              style: TextStyle(color: RiyoTheme.black),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _saveLanguage(code);
      // Force app locale change
      if (context.mounted) {
        // The locale will be picked up by the localeResolutionCallback
        // We need to trigger a rebuild of the MaterialApp
        final locale = Locale(code, '');
        // This is a workaround - in a real app you'd use a state management solution
        Navigator.pop(context);
        // Show a snackbar to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              code == 'en'
                  ? 'Language changed to English. Please restart the app.'
                  : 'Luqaddu waxaa loo beddelay Soomaali. Fadlan dib u billow barnaamijka.',
            ),
            backgroundColor: RiyoTheme.gray900,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

class _LanguageOption extends StatelessWidget {
  final String code;
  final String name;
  final String nativeName;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(RiyoTheme.space4),
        decoration: BoxDecoration(
          color: RiyoTheme.gray900,
          borderRadius: BorderRadius.circular(RiyoTheme.radiusLg),
          border: Border.all(
            color: selected ? RiyoTheme.white : RiyoTheme.gray700,
            width: selected ? 2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? RiyoTheme.white : RiyoTheme.gray800,
                borderRadius: BorderRadius.circular(RiyoTheme.radiusMd),
              ),
              child: Center(
                child: Text(
                  code.toUpperCase(),
                  style: RiyoTheme.titleMedium.copyWith(
                    color: selected ? RiyoTheme.black : RiyoTheme.gray400,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: RiyoTheme.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: RiyoTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    nativeName,
                    style: RiyoTheme.labelMedium.copyWith(
                      color: RiyoTheme.gray400,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: RiyoTheme.white,
                size: 28,
              )
            else
              const Icon(
                Icons.radio_button_unchecked_rounded,
                color: RiyoTheme.gray500,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
