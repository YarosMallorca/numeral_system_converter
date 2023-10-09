import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocaleProvider with ChangeNotifier {
  String? clocale;
  Locale? _locale;
  Locale? get locale => _locale;

  LocaleProvider({required String this.clocale}) {
    if (clocale == "auto") {
      clearLocale();
    } else {
      setLocale(Locale(clocale.toString()));
    }
  }

  void setLocale(Locale loc) {
    if (!L10n.support.contains(loc)) return;
    _locale = loc;
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    notifyListeners();
  }
}

class L10n {
  static const List<Locale> support = AppLocalizations.supportedLocales;
}
