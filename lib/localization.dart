import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/model/available_language.dart';

import 'l10n/messages_all.dart';

class AppLocatization {
  static Locale currentLocale = Locale('en', 'US');

  static Future<AppLocatization> load(Locale locale) {
    currentLocale = locale;
    final String name = locale.countryCode = null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalzedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new AppLocatization();
    })
  }
}
