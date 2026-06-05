import 'package:openinstall_flutter_plugin/openinstall_flutter_plugin.dart';
import 'package:project_template/app/utils/log.dart';

/// OpenInstall 渠道统计 / 携带参数安装 / 一键拉起。
///
/// 请在 [OpenInstall 控制台](https://www.openinstall.io/) 创建应用后，
/// 将 appKey、scheme、关联域名填入原生配置（Android build.gradle / iOS Info.plist）。
class OpenInstallService {
  OpenInstallService._();

  static final OpeninstallFlutterPlugin _plugin = OpeninstallFlutterPlugin();

  static Map<String, dynamic>? installData;
  static Map<String, dynamic>? wakeupData;

  static Future<void> init() async {
    _plugin.init((data) async {
      wakeupData = _normalize(data);
      Log().info('OpenInstall wakeup: $wakeupData');
    });

    _plugin.install((data) async {
      installData = _normalize(data);
      Log().info('OpenInstall install: $installData');
    });
  }

  static Map<String, dynamic> get activeParams {
    final data = wakeupData ?? installData;
    if (data == null) return {};
    return Map<String, dynamic>.from(data);
  }

  static String? get channelCode => activeParams['channelCode']?.toString();

  static String? get bindData => activeParams['bindData']?.toString();

  /// 将 OpenInstall 参数拼到 H5 初始 URL（H5 可从 query 读取）。
  static String appendParamsToUrl(String url) {
    final params = <String, String>{};
    final channel = channelCode;
    final bind = bindData;
    if (channel != null && channel.isNotEmpty) {
      params['channelCode'] = channel;
    }
    if (bind != null && bind.isNotEmpty) {
      params['bindData'] = bind;
    }
    if (params.isEmpty) return url;

    final uri = Uri.parse(url);
    return uri.replace(queryParameters: {...uri.queryParameters, ...params}).toString();
  }

  /// 注入 H5 的 JS 对象，页面可通过 window.__OPENINSTALL__ 读取。
  static String get injectScript {
    final channel = channelCode ?? '';
    final bind = bindData ?? '';
    return '''
      window.__OPENINSTALL__ = {
        channelCode: '$channel',
        bindData: '$bind'
      };
    ''';
  }

  static void reportRegister() => _plugin.reportRegister();

  static void reportEffectPoint(String pointId, int pointValue) {
    _plugin.reportEffectPoint(pointId, pointValue);
  }

  static Map<String, dynamic> _normalize(Map<dynamic, dynamic> data) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }
}
