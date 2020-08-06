import 'package:asf_app/model/setting_item.dart';
import 'package:flutter/material.dart';


enum AuthMethod { PIN, BIOMETRICS}

class AuthenticationMethod extends SettingSelectionItem {
  AuthMethod method;

  AuthenticationMethod(this.method);

  String getDisplayName(BuildContext context) {
    switch (method) {
      case AuthMethod.BIOMETRICS:
        return AppLoca
    }
  }
}
