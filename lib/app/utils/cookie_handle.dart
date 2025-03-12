import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

//cookie处理
class CookieHandle {
  //改为使用 PersistCookieJar，在文档中有介绍，PersistCookieJar将 cookie保留在文件中，因此，如果应用程序退出，则cookie始终存在，除             非显式调用delete
  static PersistCookieJar? _cookieJar;

  /// cookie保存，url 为要储存cookie的某个url
  static Future<void> saveCookie(String url) async {
    Uri uri = Uri.parse(url);

    //获取cookies
    Future<List<Cookie>> cookies = (await CookieHandle.cookieJar)
        .loadForRequest(uri);
    cookies.then((value) async {
      /// cookie的储存时存在沙盒路径下
      (await CookieHandle.cookieJar).saveFromResponse(uri, value);
    });
  }

  /// cookie获取
  static Future<PersistCookieJar> get cookieJar async {
    if (_cookieJar == null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      _cookieJar = PersistCookieJar(storage: FileStorage(appDocDir.path));
    }
    return _cookieJar!;
  }

  /// cookie删除
  static Future<void> delete() async {
    (await CookieHandle.cookieJar).deleteAll();
  }
}
