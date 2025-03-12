///常量类
class AppConstants {
  // API constants
  static const String baseUrl = 'http://msmart.loowp.com/api';
  static const String settings = '$baseUrl/master';
  static const String userInfoKey = "userInfo";
  static const String authTokenK = "auth-token";
  static const String authTokenV = "ZmEtMjAyMS0wNC0xMiAyMToyMjoyMC1mYQ==fa";
  static const String courseFlagK = "course-flag";
  static const String courseFlagV = "fa";
  static const String theme = "sm_theme";
  static const String appConfig = "appConfig";
  static const String categoryList = "categoryList";
  static const int videoLimit = 21;
  static const int pageLimit = 20;
  static headers() {
    ///设置请求头校验 注意留意：Console的输出:flutter: received:
    Map<String, dynamic> header = {
      authTokenK: authTokenV,
      courseFlagK: courseFlagV,
    };
    //登录令牌
    // header[DioAdapter.BOAROING_PASS] = DioAdapter.getBoardingPass();
    return header;
  }
}
