// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:seagull_tv/app/modules/home/controllers/home_controller.dart';
//
// import '../db/storage.dart';
// import '../http/apis.dart';
// import '../http/http_utils.dart';
// import '../models/config_model.dart';
// import '../routes/app_pages.dart';
// import '../utils/tv_constants.dart';
// import '../widget/skip_down_time_progress.dart';
//
// ///启动页
// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});
//
//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }
//
// class _SplashPageState extends State<SplashPage> {
//   final HomeController controller = Get.put(HomeController());
//   String netImgUrl = '';
//   String tagUrl = '';
//   // String netImgUrlPlaceholder = 'https://hbimg.b0.upaiyun.com/bb7e3b7ba10a607e0efd72b23087fa5415ca3cd040cc-7Ncw9V_fw236';//一个loading的图片
//
//   @override
//   void initState() {
//     super.initState();
//     // getAPPConfig();
//     getCategoryList();
//     //模拟广告图接口请求
//     HttpUtils.get(APIs.startUp, {}, success: (result) {
//       var model = ConfigModel.fromJson(result[DATA_NAME]);
//       netImgUrl = model.ads?.startupAdv?.imgUrl ?? '';
//       tagUrl = model.ads?.startupAdv?.targetUrl ?? '';
//       var resultMap = result[DATA_NAME];
//       var ps = Storage();
//       ps.setStorage(TvConstants.appConfig, resultMap);
//       if (netImgUrl.isNotEmpty) {
//         /**刷新页面使广告图显示**/
//         setState(() {});
//         //无广告页：netImgUrl为空""
//       } else {
//         /**跳转到主页**/
//         Future.delayed(const Duration(microseconds: 10), goIndexPage);
//       }
//     }, fail: (int code, String msg) {});
//     Future.delayed(const Duration(microseconds: 1000), () {
//       //   netImgUrl =
//       //     'https://img2.baidu.com/it/u=1170834292,3580907519&fm=253&fmt=auto&app=138&f=JPG?w=500&h=889';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(children: <Widget>[
//       // //普通写法
//       // Container(
//       //     constraints: const BoxConstraints.expand(),
//       //     color: Colors.white,
//       //     child: netImgUrl.isNotEmpty
//       //         ? Image.network(netImgUrl, fit: BoxFit.fill)
//       //         : Image.asset("assets/images/splash.png",
//       //             fit: BoxFit.fill) //未请求回来之前，用启动页图片作为占位图
//       //     ),
//
//       // 使用 CachedNetworkImage
//       Container(
//           constraints: const BoxConstraints.expand(),
//           color: Colors.white,
//           child: CachedNetworkImage(
//               placeholder: (context, url) => Image.asset(
//                   "assets/images/splash.png",
//                   fit: BoxFit.fill), ////未请求回来之前，用启动页图片作为占位图
//               imageUrl: netImgUrl.isNotEmpty
//                   ? netImgUrl
//                   : 'https://s2.loli.net/2024/09/24/hdEtiwT2WVGl5fo.png', //在netImgUrl请求回来之前占位url，防止CachedNetworkImage加载空url报错
//               fit: BoxFit.cover,
//               errorWidget: (context, url, error) =>
//                   Image.asset("assets/images/splash.png", fit: BoxFit.fill))),
//
//       //倒计时：跳过
//       Visibility(
//         visible: netImgUrl.isNotEmpty,
//         child: Positioned(
//             top: ScreenUtil().statusBarHeight + 20.h,
//             right: 30,
//             child: SkipDownTimeProgress(
//                 color: Colors.red,
//                 radius: 22.0,
//                 duration: const Duration(seconds: 5),
//                 size: const Size(25.0, 25.0),
//                 skipText: "跳过",
//                 onTap: () => goIndexPage(),
//                 onFinishCallBack: (bool value) {
//                   if (value) goIndexPage();
//                 })),
//       )
//     ]);
//   }
//
//   // 跳转主页
//   void goIndexPage() {
//     print('进入了主页......');
//
//     Get.offNamed(Routes.TABS);
//
//     ///   Navigator.of(context).pushReplacementNamed(Routes.TABS);
//   }
//
//   ///获取APP配置
//   // void getAPPConfig() async {
//   //   HttpUtils.get(APIs.startUp, {}, success: (result) {
//   //     //var model = ConfigModel.fromJson(result[DATA_NAME]);
//   //     // AppBox.shared.configInfo = model;
//   //     var resultMap = result[DATA_NAME];
//   //     var ps = Storage();
//   //     ps.setStorage(TvConstants.appConfig, resultMap);
//   //   }, fail: (int code, String msg) {});
//   // }
//
//   ///获取首页分类
//   void getCategoryList() async {
//     HttpUtils.get(APIs.types, {}, success: (result) {
//       var categoryMap = result[DATA_NAME];
//       var list = categoryMap[LIST_NAME];
//       // var ps = Storage();
//       // ps.setStorage(TvConstants.categoryList, list);
//       controller.updateCategory(list);
//     }, fail: (int code, String msg) {});
//   }
// }
