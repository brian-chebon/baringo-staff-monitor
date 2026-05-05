import 'package:flutter/material.dart';

/// Manages the active app locale at runtime.
///
/// Defaults to English; the user can flip to Swahili from the About screen.
class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  static const supported = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  void setLocale(Locale newLocale) {
    if (!supported.contains(newLocale) || newLocale == _locale) return;
    _locale = newLocale;
    notifyListeners();
  }
}
