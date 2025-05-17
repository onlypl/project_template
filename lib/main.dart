import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:project_template/app/config/theme/app_theme.dart';
import 'package:project_template/app/config/translations/localization_service.dart';
import 'package:project_template/app/db/app_hive.dart';
import 'package:project_template/app/db/app_shared_preferences.dart';

import 'app/routes/app_pages.dart';
import 'app/widgets/splash_screen.dart';

Future initHiveAndRegisterAdapter() async {
  // 初始化Hive
  await MyHive.init(
    registerAdapters: (hive) {
      //  hive.registerAdapter(UserModelAdapter());
      //myHive.registerAdapter(OtherAdapter());
    },
  );
}

//late GlobalWebSocketVM socketVM;
void main() async {
  //如果你在 main() 中使用异步方法需要添加这个
  WidgetsFlutterBinding.ensureInitialized();
  // socketVM = GlobalWebSocketVM();
  // 初始化Hive
  await initHiveAndRegisterAdapter();

  //init shared preference
  await AppSharedPreferences.init();

  ///Firebase Cloud Messaging  firebase推送
  // inti fcm services
  // await FcmHelper.initFcm();

  //配置透明的状态栏
  SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

  // ///停留操作
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // ///移除操作
  // //FlutterNativeSplash.remove();
  runApp(
    // MultiProvider(
    //   providers: [
    //         // 在这里为每个页面添加GlobalWebsocketVM绑定
    //         ChangeNotifierProvider<GlobalWebSocketVM>(create: (_) => GlobalWebSocketVM()),
    //       ],
    //   builder:(context, child) {
    //       return Container();
    // },);
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        bool themeIsLight = AppSharedPreferences.getThemeIsLight();

        final botToastBuilder = BotToastInit(); //1.提示初始化
        final easyLoadingtBuilder = EasyLoading.init();
        return GetMaterialApp(
          //   initialBinding: , //全局
          debugShowCheckedModeBanner: false, //去掉deBug横幅
          // useInheritedMediaQuery:
          //    true, //键盘出现在 android 中时，屏幕不会向上滚动，主要是当文本字段获得焦点时
          locale: AppSharedPreferences.getCurrentLocal(), //设置APP国际化语言
          translations: LocalizationService.getInstance(), //所有国际化词
          fallbackLocale: LocalizationService.defaultLanguage, //在配置错误的情况下 显示的语言
          theme: AppTheme.getThemeData(isLight: true), //明亮模式主题
          darkTheme: AppTheme.getThemeData(isLight: false), //暗黑模式主题
          themeMode: themeIsLight ? ThemeMode.light : ThemeMode.dark, //设置当前主题
          builder: (context, child) {
            //  child  = othersBuilder(context, child); //其它构造器
            child = easyLoadingtBuilder(context, child);
            child = botToastBuilder(context, child);
            return child;
          },
          //initialRoute: AppPages.INITIAL,
          home: const SplashPage(),
          getPages: AppPages.routes,
        );
      },
    ),
  );
}
