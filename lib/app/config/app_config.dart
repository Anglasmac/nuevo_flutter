// lib/app/config/app_config.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AppConfig {
  static String get apiBaseUrl {
    const String backendHost = "localhost";
    const String backendPort = "3000";

    if (kIsWeb) {
      return 'http://$backendHost:$backendPort';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$backendPort';
    }

    return 'http://$backendHost:$backendPort';
  }
}
