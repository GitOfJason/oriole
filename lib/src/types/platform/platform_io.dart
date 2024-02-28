import 'dart:io';

class OriolePlatform {
  static const bool isWeb = false;
  static final bool isIOS = Platform.isIOS || Platform.isMacOS;
}
