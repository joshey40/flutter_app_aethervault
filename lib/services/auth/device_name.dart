import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<String> loadDeviceName() async {
  const fallback = 'Unknown device';
  final deviceInfo = DeviceInfoPlugin();

  try {
    final name = switch (Platform.operatingSystem) {
      'android' => await _androidName(deviceInfo),
      'ios' => (await deviceInfo.iosInfo).name,
      'macos' => (await deviceInfo.macOsInfo).computerName,
      'windows' => (await deviceInfo.windowsInfo).computerName,
      'linux' => (await deviceInfo.linuxInfo).prettyName,
      _ => fallback,
    };
    return name.trim().isEmpty ? fallback : name.trim();
  } catch (_) {
    return fallback;
  }
}

Future<String> _androidName(DeviceInfoPlugin deviceInfo) async {
  final info = await deviceInfo.androidInfo;
  final manufacturer = info.manufacturer.isEmpty
      ? ''
      : '${info.manufacturer[0].toUpperCase()}${info.manufacturer.substring(1)} ';

  // Some vendors already put the manufacturer into the model name.
  if (info.model.toLowerCase().startsWith(info.manufacturer.toLowerCase())) {
    return info.model;
  }
  return '$manufacturer${info.model}';
}
