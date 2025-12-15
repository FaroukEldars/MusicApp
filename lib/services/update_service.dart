import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const String VERSION_CHECK_URL =
      'https://raw.githubusercontent.com/FaroukEldars/music-json/main/app_version.json';

  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      PackageInfo info = await PackageInfo.fromPlatform();
      String current = info.version;

      final response = await http.get(Uri.parse(VERSION_CHECK_URL));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latest = data['version'];

        if (_isUpdateAvailable(current, latest)) {
          return data;
        }
      }
      return null;
    } catch (e) {
      print("Update check error: $e");
      return null;
    }
  }

  bool _isUpdateAvailable(String current, String latest) {
    try {
      List<int> c = current.split('.').map(int.parse).toList();
      List<int> l = latest.split('.').map(int.parse).toList();

      // التأكد من طول النسختين متساوي
      int maxLength = c.length > l.length ? c.length : l.length;

      // إضافة أصفار للنسخة الأقصر
      while (c.length < maxLength) c.add(0);
      while (l.length < maxLength) l.add(0);

      for (int i = 0; i < maxLength; i++) {
        if (l[i] > c[i]) return true;
        if (l[i] < c[i]) return false;
      }
      return false;
    } catch (e) {
      print("Version comparison error: $e");
      return false;
    }
  }

  Future<bool> openDownloadLink(String url) async {
    try {
      // تحويل رابط Google Drive للصيغة الصحيحة
      String finalUrl = url;
      if (url.contains('drive.google.com')) {
        finalUrl = _convertGoogleDriveUrl(url);
      }

      print("Attempting to open URL: $finalUrl");

      final uri = Uri.parse(finalUrl);

      // جرب أكتر من وضع
      if (await canLaunchUrl(uri)) {
        bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          print("URL launched successfully");
          return true;
        }
      }

      // لو الطريقة الأولى فشلت، جرب platformDefault
      print("Trying platformDefault mode...");
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (launched) {
        print("URL launched with platformDefault");
        return true;
      }

      print("Failed to launch URL: $finalUrl");
      return false;
    } catch (e) {
      print("Error opening download link: $e");
      return false;
    }
  }

  /// تحويل رابط Google Drive للصيغة المناسبة للتحميل المباشر
  String _convertGoogleDriveUrl(String url) {
    // لو الرابط بالفعل بصيغة export=download
    if (url.contains('export=download')) {
      return url;
    }

    // استخراج الـ file ID من أي نوع رابط Google Drive
    RegExp regExp = RegExp(r'[-\w]{25,}');
    var match = regExp.firstMatch(url);

    if (match != null) {
      String fileId = match.group(0)!;
      // استخدام رابط التحميل المباشر
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }

    return url;
  }
}