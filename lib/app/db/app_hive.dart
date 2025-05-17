import 'package:hive_flutter/hive_flutter.dart';
//import 'package:project_template/app/models/user_model.dart';

//不支持跨平台
//hive 是一个高性能的 NoSQL 数据库，支持存储各种类型的数据，
// 包括基本数据类型、自定义对象、List、Map 等。它比 shared_preferences 更灵活，但也更复杂。
//性能高，支持存储大量数据
// 灵活，可以存储各种类型的数据
// 支持事务和查询
///用户模型
//const userModelName = 'userModelName';
// 对象存储盒子的名称
///公用参数
const appBoxName = 'appBoxName';

class AppHive {
  static final AppHive shared = AppHive();

  /// 声明盒子
  final _box = Hive.box(appBoxName);

  // ///全局配置
  // ConfigModel get configInfo => _box.get('configInfo');
  // set configInfo(ConfigModel model) => _box.put('configInfo', model);

  ///用户信息
  // UserModel get userInfo => _box.get('userInfo');
  // set userInfo(UserModel model) => _box.put('userInfo', model);

  //用户名
  String get userName => _box.get('userName');
  set userName(String value) => _box.put('userName', value);

  ///密码
  String get password => _box.get('password');
  set password(String value) => _box.put('password', value);

  /// 是否登录
  bool get isLogin => _box.get('isLogin') ?? false;
  set isLogin(bool value) => _box.put('isLogin', value);
  //
  // /// 语言
  // int get language => _box.get('language') ?? 0;
  //
  // set language(int value) => _box.put('language', value);
  //
  // /// 主题
  // int get theme => _box.get('theme') ?? 0;
  // set theme(int value) => _box.put('theme', value);
}

class MyHive {
  // prevent making instance
  MyHive._();

  // hive box to store user data
  // static late Box<UserModel> _userBox;
  // box name its like table name
  static const String _userBoxName = 'user';
  // store current user as (key => value)
  static const String _currentUserKey = 'local_user';

  /// initialize local db (HIVE)
  /// pass testPath only if you are testing hive
  static Future<void> init({
    Function(HiveInterface)? registerAdapters,
    String? testPath,
  }) async {
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }
    await registerAdapters?.call(Hive);
    // await initUserBox();
  }

  /// initialize user box
  // static Future<void> initUserBox() async {
  //   _userBox = await Hive.openBox(_userBoxName);
  // }
  //
  // /// save user to database
  // static Future<bool> saveUserToHive(UserModel user) async {
  //   try {
  //     await _userBox.put(_currentUserKey, user);
  //     return true;
  //   } catch (error) {
  //     return false;
  //   }
  // }
  //
  // /// get current logged user
  // static UserModel? getCurrentUser() {
  //   try {
  //     return _userBox.get(_currentUserKey);
  //   } catch (error) {
  //     return null;
  //   }
  // }
  //
  // /// delete the current user
  // static Future<bool> deleteCurrentUser() async {
  //   try {
  //     await _userBox.delete(_currentUserKey);
  //     return true;
  //   } catch (error) {
  //     return false;
  //   }
  // }
  //
  // // setter for _userBox (only using it for testing)
  // set userBox(Box<UserModel> box) {
  //   _userBox = box;
  // }
}
