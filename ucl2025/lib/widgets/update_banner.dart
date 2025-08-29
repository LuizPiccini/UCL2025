import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../utils/reload_stub.dart'
    if (dart.library.html) '../utils/reload_web.dart';

class UpdateBanner extends StatefulWidget {
  const UpdateBanner({super.key});

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  bool _show = false;
  String? _apkUrl;

  @override
  void initState() {
    super.initState();
    _check();
    Timer.periodic(const Duration(minutes: 5), (_) => _check());
  }

  Future<void> _check() async {
    const versionUrl = String.fromEnvironment('VERSION_URL');
    const appVersion = String.fromEnvironment('APP_VERSION');
    if (versionUrl.isEmpty) return;
    try {
      final res = await http.get(Uri.parse(versionUrl));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final remoteVersion = data['version'] as String?;
      final apk = data['apk'] as String?;
      if (remoteVersion != null && remoteVersion != appVersion) {
        setState(() {
          _show = true;
          _apkUrl = apk;
        });
      }
    } catch (_) {
      // ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    return MaterialBanner(
      content: const Text('A new version is available.'),
      actions: [
        TextButton(onPressed: refreshPage, child: const Text('Refresh')),
        if (_apkUrl != null)
          TextButton(
            onPressed: () => launchUrl(Uri.parse(_apkUrl!)),
            child: const Text('Get APK'),
          ),
      ],
    );
  }
}
