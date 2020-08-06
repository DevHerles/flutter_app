import 'package:flutter/material.dart';
import 'package:asf_app/model/setting_item.dart';

enum AvailableLanguage { DEFAULT, ENGLISH, SPANISH }

class LanguageSetting extends SettingSelectionItem {
  AvailableLanguage language;

  String getDisplayName(BuildContext context) {
    switch (language) {
      case AvailableLanguage.ENGLISH:
        return "English (en)";
      case AvailableLanguage.SPANISH:
        return "Español (es)";
      default:
        return "Español (es)";
    }
  }

  String getLocateString() {
    switch (language) {
      case AvailableLanguage.ENGLISH:
        return "en";
      case AvailableLanguage.SPANISH:
        return "es";
      default:
        return "DEFAULT";
    }
  }

  Locale getLocale() {
    String localeString = getLocateString();
    if (localeString == "DEFAULT") {
      return Locale("en");
    }
    return Locale(localeString);
  }

  int getIndex() {
    return language.index;
  }
}
