import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import '../db/app_shared_preferences.dart';

// 处理设备号信息
class DeviceUtil {
  static String devicePlatformKey = "devicePlatformKey";
  static String deviceModelKey = "deviceModelKey";
  static String deviceMacKey = "deviceMacKey";
}

Future<void> initDeviceState() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    deviceInfo.iosInfo.then((value) async {
      await AppSharedPreferences.setString(DeviceUtil.devicePlatformKey, "iOS");
      await AppSharedPreferences.setString(
        DeviceUtil.deviceModelKey,
        value.model,
      );
      await AppSharedPreferences.setString(
        DeviceUtil.deviceMacKey,
        value.identifierForVendor ?? '',
      ); // iOS的Vendor标识符
    });
  } else if (Platform.isAndroid) {
    deviceInfo.androidInfo.then((value) async {
      await AppSharedPreferences.setString(
        DeviceUtil.devicePlatformKey,
        "Android",
      );
      await AppSharedPreferences.setString(
        DeviceUtil.deviceModelKey,
        value.model,
      );
      await AppSharedPreferences.setString(
        DeviceUtil.deviceMacKey,
        value.id,
      ); //Android ID（在不重置设备的情况下通常是持久的）
    });
  }
}
