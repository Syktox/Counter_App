import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  UrlLauncherService._();

  static const donateUrl =
      'https://buymeacoffee.com/syktox';

  static Future<void> openDonateUrl(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(donateUrl);

    final openedInExternalApp = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (openedInExternalApp) {
      return;
    }

    final openedWithDefaultMode = await launchUrl(uri);
    if (openedWithDefaultMode) {
      return;
    }

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Could not open donate URL.')),
    );
  }
}
