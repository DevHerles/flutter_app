import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtil {
  static const String aranda_lock_timeout = 'aranda_lock_timeout';
  static const String first_launch_key = 'aranda_first_launch';
  static const String app_uuid_key = 'aranda_app_uuid';
  static const String auth_method = 'aranda_auth_method';
  static const String cur_language = 'aranda_language_pref';
  static const String cur_theme = 'aranda_theme_pref';
  static const String notification_enabled = 'aranda_notification_on';
  static const String lock_aranda = 'aranda_lock_dev';
  static const String aranda_lock_timeout = 'aranda_lock_timeout';
  // If user has seen the root/jailbreak warning yet
  static const String has_shown_root_warning = 'aranda_root_warn';
  // For maximum pin attempts
  static const String pin_attempts = 'aranda_pin_attempts';
  static const String pin_lock_until = 'aranda_lock_duraton';
  // For certain keystore incompatible androids
  static const String use_legacy_storage = 'aranda_legacy_storage';
  // Caching odoo API response
  static const String odoo_api_cache = 'aranda_odoo_api_cache';

  Future<void> set(String key, value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (value is bool) {
      sharedPreferences.setBool(key, value);
    } else if (value is String) {
      SharedPreferences.setString(key, value);
    } else if (value is double) {
      sharedPreferences.setDouble(key, value);
    } else if (value is int) {
      sharedPreferences.setInt(key, value);
    }
  }

  Future<dynamic> get(String key, {dynamic defaultValue}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.get(key) ?? defaultValue;
  }

  Future<void> setHasSeenRootWarning() async {
    return await set(has_shown_root_warning, true);
  }

  Future<bool> getHasSeenRootWarning() async {
    return await get(has_shown_root_warning, defaultValue: false);
  }

  Future<void> setFirstLaunch() async {
    return await set(first_launch_key, false);
  }

  Future<bool> getFirstLaunch() async {
    return await get(first_launch_key, defaultValue: true);
  }

  Future<void> setFirstContactAdded(bool value) async {
    return await set(firstcontact_added, value);
  }

  Future<bool> getFirstContactAdded() async {
    return await get(firstcontact_added, defaultValue: false);
  }

  Future<void> setUuid(String uuid) async {
    return await setEncrypted(app_uuid_key, uuid);
  }

  Future<String> getUuid() async {
    return await getEncrypted(app_uuid_key);
  }

  Future<void> setAuthMethod(AuthenticationMethod method) async {
    return await set(auth_method, method.getIndex());
  }

  Future<AuthenticationMethod> getAuthMethod() async {
    return AuthenticationMethod(AuthMethod.values[
        await get(auth_method, defaultValue: AuthMethod.BIOMETRICS.index)]);
  }

  Future<void> setCurrency(AvailableCurrency currency) async {
    return await set(cur_currency, currency.getIndex());
  }

  Future<void> setLanguage(LanguageSetting language) async {
    return await set(cur_language, language.getIndex());
  }

  Future<LanguageSetting> getLanguage() async {
    return LanguageSetting(AvailableLanguage.values[await get(cur_language,
        defaultValue: AvailableLanguage.DEFAULT.index)]);
  }

  Future<LanguageSetting> getLanguage() async {
    return LanguageSetting(AvailableLanguage.values[await get(cur_language,
        defaultValue: AvailableLanguage.DEFAULT.index)]);
  }

  Future<void> setTheme(ThemeSetting theme) async {
    return await set(cur_theme, theme.getIndex());
  }

  Future<ThemeSetting> getTheme() async {
    return ThemeSetting(ThemeOptions.values[
        await get(cur_theme, defaultValue: ThemeOptions.NATRIUM.index)]);
  }

  Future<void> setNotificationsOn(bool value) async {
    return await set(notification_enabled, value);
  }

  Future<bool> getNotificationsOn() async {
    // Notifications off by default on iOS,
    bool defaultValue = Platform.isIOS ? false : true;
    return await get(notification_enabled, defaultValue: defaultValue);
  }

  /// If notifications have been set by user/app
  Future<bool> getNotificationsSet() async {
    return await get(notification_enabled, defaultValue: null) == null
        ? false
        : true;
  }

  Future<void> setLock(bool value) async {
    return await set(lock_aranda, value);
  }

  Future<bool> getLock() async {
    return await get(lock_aranda, defaultValue: false);
  }

  Future<void> setLockTimeout(LockTimeoutSetting setting) async {
    return await set(aranda_lock_timeout, setting.getIndex());
  }

  Future<LockTimeoutSetting> getLockTimeout() async {
    return LockTimeoutSetting(LockTimeoutOption.values[await get(
        aranda_lock_timeout,
        defaultValue: LockTimeoutOption.ONE.index)]);
  }

  // Locking out when max pin attempts exceeded
  Future<int> getLockAttempts() async {
    return await get(pin_attempts, defaultValue: 0);
  }

  Future<void> incrementLockAttempts() async {
    await set(pin_attempts, await getLockAttempts() + 1);
  }

  Future<void> resetLockAttempts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(pin_attempts);
    await prefs.remove(pin_lock_until);
  }

  Future<bool> shouldLock() async {
    if (await get(pin_lock_until) != null || await getLockAttempts() >= 5) {
      return true;
    }
    return false;
  }

  Future<void> updateLockDate() async {
    int attempts = await getLockAttempts();
    if (attempts >= 20) {
      // 4+ failed attempts
      await set(
          pin_lock_until,
          DateFormat.yMd()
              .add_jms()
              .format(DateTime.now().toUtc().add(Duration(hours: 24))));
    } else if (attempts >= 15) {
      // 3 failed attempts
      await set(
          pin_lock_until,
          DateFormat.yMd()
              .add_jms()
              .format(DateTime.now().toUtc().add(Duration(minutes: 15))));
    } else if (attempts >= 10) {
      // 2 failed attempts
      await set(
          pin_lock_until,
          DateFormat.yMd()
              .add_jms()
              .format(DateTime.now().toUtc().add(Duration(minutes: 5))));
    } else if (attempts >= 5) {
      await set(
          pin_lock_until,
          DateFormat.yMd()
              .add_jms()
              .format(DateTime.now().toUtc().add(Duration(minutes: 1))));
    }
  }

  Future<DateTime> getLockDate() async {
    String lockDateStr = await get(pin_lock_until);
    if (lockDateStr == null) {
      return null;
    }
    return DateFormat.yMd().add_jms().parseUtc(lockDateStr);
  }

  Future<bool> useLegacyStorage() async {
    return await get(use_legacy_storage, defaultValue: false);
  }

  Future<void> setUseLegacyStorage() async {
    await set(use_legacy_storage, true);
  }

  Future<String> getNinjaAPICache() async {
    return await get(odoo_api_cache, defaultValue: null);
  }

  Future<void> setNinjaAPICache(String data) async {
    await set(odoo_api_cache, data);
  }

  Future<void> deleteAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(aranda_lock_timeout);
    await prefs.remove(seed_backed_up_key);
    await prefs.remove(app_uuid_key);
    await prefs.remove(auth_method);
    await prefs.remove(notification_enabled);
    await prefs.remove(lock_aranda);
    await prefs.remove(pin_attempts);
    await prefs.remove(pin_lock_until);
    await prefs.remove(has_shown_root_warning);
  }
}
