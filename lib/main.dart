import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get/get.dart';
import 'package:project_template/app/config/theme/app_theme.dart';
import 'package:project_template/app/config/translations/localization_service.dart';
import 'package:project_template/app/db/app_hive.dart';
import 'package:project_template/app/db/app_shared_preferences.dart';

import 'app/models/user_model.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/awesome_notifications_helper.dart';

Future initHiveAndRegisterAdapter() async {
  // 初始化Hive
  await MyHive.init(
    registerAdapters: (hive) {
      hive.registerAdapter(UserModelAdapter());
      //myHive.registerAdapter(OtherAdapter());
    },
  );
}

//late GlobalWebSocketVM socketVM;
void main() async {
  //如果你在 main() 中使用异步方法需要添加这个
  WidgetsFlutterBinding.ensureInitialized();
  // socketVM = GlobalWebSocketVM();
  String udid = await FlutterUdid.udid;
  // 初始化Hive
  await initHiveAndRegisterAdapter();

  //init shared preference
  await AppSharedPreferences.init();

  ///Firebase Cloud Messaging  firebase推送
  // inti fcm services
  // await FcmHelper.initFcm();

  // initialize local notifications service 初始化本地通知服务
  await AwesomeNotificationsHelper.init();

  //配置透明的状态栏
  SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        bool themeIsLight = AppSharedPreferences.getThemeIsLight();
        final botToastBuilder = BotToastInit(); //1.提示初始化
        return GetMaterialApp(
          debugShowCheckedModeBanner: false, //去掉deBug横幅
          // useInheritedMediaQuery:
          //    true, //键盘出现在 android 中时，屏幕不会向上滚动，主要是当文本字段获得焦点时
          locale: AppSharedPreferences.getCurrentLocal(), //设置APP国际化语言
          translations: LocalizationService.getInstance(), //所有国际化词
          fallbackLocale: LocalizationService.defaultLanguage, //在配置错误的情况下 显示的语言
          theme: AppTheme.getThemeData(isLight: true), //明亮模式主题
          darkTheme: AppTheme.getThemeData(isLight: false), //暗黑模式主题
          themeMode: themeIsLight ? ThemeMode.light : ThemeMode.dark, //设置当前主题
          builder: BotToastInit(),
          // builder: (context, child) {
          //   child = MultiProvider(
          //     providers: [
          //       // 在这里为每个页面添加GlobalWebsocketVM绑定
          //       ChangeNotifierProvider<GlobalWebSocketVM>(
          //         create: (_) => socketVM,
          //       ),
          //     ],
          //     builder: (context, child) => child ?? const SizedBox.shrink(),
          //   );
          //   //   child = botToastBuilder(context, child);
          //   return child;
          //   /*return ChangeNotifierProvider<UserVM>(
          //   create: (_) => userVM,
          //   builder: (context, child) =>
          //   child ?? const SizedBox.shrink(),
          // );*/
          // },
          initialRoute: AppPages.INITIAL,
          // home: const SplashPage(),
          getPages: AppPages.routes,
        );
      },
    ),
  );
}
