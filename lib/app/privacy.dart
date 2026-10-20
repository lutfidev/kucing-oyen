import 'package:url_launcher/url_launcher.dart';

/// Kebijakan privasi (`docs/store/privacy/`), dihosting di situs pengembang.
const privacyPolicyUrl = 'https://yoluvy.my.id/ginger-logic/privacy/';

/// Membuka kebijakan privasi di browser; false kalau gagal dibuka.
Future<bool> openPrivacyPolicy() async {
  try {
    return await launchUrl(
      Uri.parse(privacyPolicyUrl),
      mode: LaunchMode.externalApplication,
    );
  } on Object {
    return false;
  }
}
