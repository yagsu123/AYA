import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Phone / messaging / contact-card actions used across the app.
class ContactActions {
  ContactActions._();

  static Future<void> _launch(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Target app not available on this device — ignore silently.
    }
  }

  static Future<void> call(String mobile) => _launch('tel:$mobile');

  static Future<void> sms(String mobile) => _launch('sms:$mobile');

  static Future<void> whatsapp(String mobile, {String? message}) {
    final text = message == null ? '' : '?text=${Uri.encodeComponent(message)}';
    return _launch('https://wa.me/91$mobile$text');
  }

  static Future<void> email(String address) => _launch('mailto:$address');

  /// Shares a vCard (.vcf) — opening it with Contacts saves the person.
  static Future<void> saveContact({required String name, required String mobile}) async {
    final vcf = 'BEGIN:VCARD\nVERSION:3.0\nFN:$name\nTEL;TYPE=CELL:+91$mobile\nEND:VCARD\n';
    final dir = await getTemporaryDirectory();
    final safeName = name.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '').trim();
    final file = File('${dir.path}/$safeName.vcf');
    await file.writeAsString(vcf);
    await Share.shareXFiles([XFile(file.path, mimeType: 'text/vcard')],
        text: 'Contact: $name');
  }
}
