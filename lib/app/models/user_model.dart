import 'package:hive/hive.dart';

//part 'UserModel.g.dart';

///用户模型
@HiveType(typeId: 0) // typeId 范围是0-233, 每个模型类的typeId应不同
class UserModel extends HiveObject {
  UserModel({
    this.userId,
    this.groupId,
    this.userName,
    this.userPwd,
    this.userNickName,
    this.userQq,
    this.userEmail,
    this.userPhone,
    this.userStatus,
    this.userPortrait,
    this.userPortraitThumb,
    this.userOpenidQq,
    this.userOpenidWeixin,
    this.userQuestion,
    this.userAnswer,
    this.userPoints,
    this.userPointsFroze,
    this.userRegTime,
    this.userRegIp,
    this.userLoginTime,
    this.userLoginIp,
    this.userLastLoginTime,
    this.userLastLoginIp,
    this.userLoginNum,
    this.userExtend,
    this.userRandom,
    this.userEndTime,
    this.userPid,
    this.userPid_2,
    this.userPid_3,
    this.userPidNum,
    this.userLoginToday,
    this.isAgents,
    this.userGold,
    this.group,
    this.userLevel,
    this.userViewCount,
    this.leavePeoples,
    this.leaveTimes,
  });
  //用户id
  @HiveField(0)
  int? userId;
  @HiveField(1)
  int? groupId;
  //用户吗
  @HiveField(2)
  String? userName;
  @HiveField(3)
  String? userPwd;
  //用户昵称
  @HiveField(4)
  String? userNickName;
  //用户QQ
  @HiveField(5)
  String? userQq;
  //用户邮箱
  @HiveField(6)
  String? userEmail;
  //用户手机号
  @HiveField(7)
  String? userPhone;
  //用户状态
  @HiveField(8)
  int? userStatus;
  //用户头像
  @HiveField(9)
  String? userPortrait;
  @HiveField(10)
  String? userPortraitThumb;
  //用户绑定QQ OpenID
  @HiveField(11)
  String? userOpenidQq;
  //用户绑定微信 OpenID
  @HiveField(12)
  String? userOpenidWeixin;
  //用户提问
  @HiveField(13)
  String? userQuestion;
  //用户回答
  @HiveField(14)
  String? userAnswer;
  @HiveField(15)
  int? userPoints;
  @HiveField(16)
  int? userPointsFroze;
  //注册时间
  @HiveField(17)
  int? userRegTime;
  //注册IP
  @HiveField(18)
  int? userRegIp;
  //登录时间
  @HiveField(19)
  int? userLoginTime;
  //登录IP
  @HiveField(20)
  int? userLoginIp;
  //最后登录时间
  @HiveField(21)
  int? userLastLoginTime;
  //最后登录IP
  @HiveField(22)
  int? userLastLoginIp;
  @HiveField(23)
  int? userLoginNum;
  @HiveField(24)
  int? userExtend;
  @HiveField(25)
  String? userRandom;
  @HiveField(26)
  int? userEndTime;
  @HiveField(27)
  int? userPid;
  @HiveField(28)
  int? userPid_2;
  @HiveField(29)
  int? userPid_3;
  @HiveField(30)
  int? userPidNum;
  @HiveField(31)
  int? userLoginToday;
  @HiveField(32)
  int? isAgents;
  @HiveField(33)
  int? userGold;
  @HiveField(34)
  GroupModel? group;
  //用户等级
  @HiveField(35)
  int? userLevel;
  //用户观看次数
  @HiveField(36)
  int? userViewCount;
  @HiveField(37)
  int? leavePeoples;
  @HiveField(38)
  int? leaveTimes;

  UserModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    groupId = json['group_id'];
    userName = json['user_name'];
    userPwd = json['user_pwd'];
    userNickName = json['user_nick_name'];
    userQq = json['user_qq'];
    userEmail = json['user_email'];
    userPhone = json['user_phone'];
    userStatus = json['user_status'];
    userPortrait = json['user_portrait'];
    userPortraitThumb = json['user_portrait_thumb'];
    userOpenidQq = json['user_openid_qq'];
    userOpenidWeixin = json['user_openid_weixin'];
    userQuestion = json['user_question'];
    userAnswer = json['user_answer'];
    userPoints = json['user_points'];
    userPointsFroze = json['user_points_froze'];
    userRegTime = json['user_reg_time'];
    userRegIp = json['user_reg_ip'];
    userLoginTime = json['user_login_time'];
    userLoginIp = json['user_login_ip'];
    userLastLoginTime = json['user_last_login_time'];
    userLastLoginIp = json['user_last_login_ip'];
    userLoginNum = json['user_login_num'];
    userExtend = json['user_extend'];
    userRandom = json['user_random'];
    userEndTime = json['user_end_time'];
    userPid = json['user_pid'];
    userPid_2 = json['user_pid_2'];
    userPid_3 = json['user_pid_3'];
    userPidNum = json['user_pid_num'];
    userLoginToday = json['user_login_today'];
    isAgents = json['is_agents'];
    userGold = json['user_gold'];
    group = GroupModel.fromJson(json['group']);
    userLevel = json['user_level'];
    userViewCount = json['user_view_count'];
    leavePeoples = json['leave_peoples'];
    leaveTimes = json['leave_times'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['user_id'] = userId;
    data['group_id'] = groupId;
    data['user_name'] = userName;
    data['user_pwd'] = userPwd;
    data['user_nick_name'] = userNickName;
    data['user_qq'] = userQq;
    data['user_email'] = userEmail;
    data['user_phone'] = userPhone;
    data['user_status'] = userStatus;
    data['user_portrait'] = userPortrait;
    data['user_portrait_thumb'] = userPortraitThumb;
    data['user_openid_qq'] = userOpenidQq;
    data['user_openid_weixin'] = userOpenidWeixin;
    data['user_question'] = userQuestion;
    data['user_answer'] = userAnswer;
    data['user_points'] = userPoints;
    data['user_points_froze'] = userPointsFroze;
    data['user_reg_time'] = userRegTime;
    data['user_reg_ip'] = userRegIp;
    data['user_login_time'] = userLoginTime;
    data['user_login_ip'] = userLoginIp;
    data['user_last_login_time'] = userLastLoginTime;
    data['user_last_login_ip'] = userLastLoginIp;
    data['user_login_num'] = userLoginNum;
    data['user_extend'] = userExtend;
    data['user_random'] = userRandom;
    data['user_end_time'] = userEndTime;
    data['user_pid'] = userPid;
    data['user_pid_2'] = userPid_2;
    data['user_pid_3'] = userPid_3;
    data['user_pid_num'] = userPidNum;
    data['user_login_today'] = userLoginToday;
    data['is_agents'] = isAgents;
    data['user_gold'] = userGold;
    data['group'] = group?.toJson();
    data['user_level'] = userLevel;
    data['user_view_count'] = userViewCount;
    data['leave_peoples'] = leavePeoples;
    data['leave_times'] = leaveTimes;
    return data;
  }
}

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      userId: reader.read(),
      groupId: reader.read(),
      userName: reader.read(),
      userPwd: reader.read(),
      userNickName: reader.read(),
      userQq: reader.read(),
      userEmail: reader.read(),
      userPhone: reader.read(),
      userStatus: reader.read(),
      userPortrait: reader.read(),
      userPortraitThumb: reader.read(),
      userOpenidQq: reader.read(),
      userOpenidWeixin: reader.read(),
      userQuestion: reader.read(),
      userAnswer: reader.read(),
      userPoints: reader.read(),
      userPointsFroze: reader.read(),
      userRegTime: reader.read(),
      userRegIp: reader.read(),
      userLoginTime: reader.read(),
      userLoginIp: reader.read(),
      userLastLoginTime: reader.read(),
      userLastLoginIp: reader.read(),
      userLoginNum: reader.read(),
      userExtend: reader.read(),
      userRandom: reader.read(),
      userEndTime: reader.read(),
      userPid: reader.read(),
      userPid_2: reader.read(),
      userPid_3: reader.read(),
      userPidNum: reader.read(),
      userLoginToday: reader.read(),
      isAgents: reader.read(),
      userGold: reader.read(),
      group: reader.read(),
      userLevel: reader.read(),
      userViewCount: reader.read(),
      leavePeoples: reader.read(),
      leaveTimes: reader.read(),
    );
  }

  @override
  final int typeId = 0;

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.write(obj.userId);
    writer.write(obj.groupId);
    writer.write(obj.userName);
    writer.write(obj.userPwd);
    writer.write(obj.userNickName);
    writer.write(obj.userQq);
    writer.write(obj.userEmail);
    writer.write(obj.userPhone);

    writer.write(obj.userStatus);
    writer.write(obj.userPortrait);
    writer.write(obj.userPortraitThumb);
    writer.write(obj.userOpenidQq);
    writer.write(obj.userOpenidWeixin);
    writer.write(obj.userQuestion);
    writer.write(obj.userAnswer);
    writer.write(obj.userPoints);

    writer.write(obj.userPointsFroze);
    writer.write(obj.userRegTime);
    writer.write(obj.userRegIp);
    writer.write(obj.userLoginTime);
    writer.write(obj.userLoginIp);
    writer.write(obj.userLastLoginTime);
    writer.write(obj.userLastLoginIp);
    writer.write(obj.userLoginNum);

    writer.write(obj.userExtend);
    writer.write(obj.userRandom);
    writer.write(obj.userEndTime);
    writer.write(obj.userPid);
    writer.write(obj.userPid_2);
    writer.write(obj.userPid_3);
    writer.write(obj.userPidNum);
    writer.write(obj.userLoginToday);

    writer.write(obj.isAgents);
    writer.write(obj.userGold);
    writer.write(obj.group);
    writer.write(obj.userLevel);
    writer.write(obj.userViewCount);
    writer.write(obj.leavePeoples);
    writer.write(obj.leaveTimes);
  }
}

@HiveType(typeId: 1)
class GroupModel extends HiveObject {
  GroupModel({
    this.groupId,
    this.groupName,
    this.groupStatus,
    this.groupType,
    this.groupPopedom,
    this.groupPointsDay,
    this.groupPointsWeek,
    this.groupPointsMonth,
    this.groupPointsYear,
    this.groupPointsFree,
  });
  @HiveField(0)
  int? groupId;
  @HiveField(1)
  String? groupName;
  @HiveField(2)
  int? groupStatus;
  @HiveField(3)
  String? groupType;
  @HiveField(4)
  GroupPopedomModel? groupPopedom;
  @HiveField(5)
  int? groupPointsDay;
  @HiveField(6)
  int? groupPointsWeek;
  @HiveField(7)
  int? groupPointsMonth;
  @HiveField(8)
  int? groupPointsYear;
  @HiveField(9)
  int? groupPointsFree;

  GroupModel.fromJson(Map<String, dynamic> json) {
    groupId = json['group_id'];
    groupName = json['group_name'];
    groupStatus = json['group_status'];
    groupType = json['group_type'];
    groupPopedom = GroupPopedomModel.fromJson(json['group_popedom']);
    groupPointsDay = json['group_points_day'];
    groupPointsWeek = json['group_points_week'];
    groupPointsMonth = json['group_points_month'];
    groupPointsYear = json['group_points_year'];
    groupPointsFree = json['group_points_free'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['group_id'] = groupId;
    data['group_name'] = groupName;
    data['group_status'] = groupStatus;
    data['group_type'] = groupType;
    data['group_popedom'] = groupPopedom?.toJson();
    data['group_points_day'] = groupPointsDay;
    data['group_points_week'] = groupPointsWeek;
    data['group_points_month'] = groupPointsMonth;
    data['group_points_year'] = groupPointsYear;
    data['group_points_free'] = groupPointsFree;
    return data;
  }
}

class GroupModelAdapter extends TypeAdapter<GroupModel> {
  @override
  final typeId = 1;

  @override
  GroupModel read(BinaryReader reader) {
    return GroupModel(
      groupId: reader.read(),
      groupName: reader.read(),
      groupStatus: reader.read(),
      groupType: reader.read(),
      groupPopedom: reader.read(),
      groupPointsDay: reader.read(),
      groupPointsWeek: reader.read(),
      groupPointsMonth: reader.read(),
      groupPointsYear: reader.read(),
      groupPointsFree: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, GroupModel obj) {
    writer.write(obj.groupId);
    writer.write(obj.groupName);
    writer.write(obj.groupStatus);
    writer.write(obj.groupType);
    writer.write(obj.groupPopedom);
    writer.write(obj.groupPointsDay);
    writer.write(obj.groupPointsDay);
    writer.write(obj.groupPointsWeek);
    writer.write(obj.groupPointsMonth);
    writer.write(obj.groupPointsYear);
    writer.write(obj.groupPointsFree);
  }
}

@HiveType(typeId: 2)
class GroupPopedomModel extends HiveObject {
  GroupPopedomModel({
    this.groupPopedom1,
    this.groupPopedom2,
    this.groupPopedom3,
    this.groupPopedom4,
    this.groupPopedom5,
    this.groupPopedom6,
    this.groupPopedom7,
    this.groupPopedom8,
    this.groupPopedom9,
    this.groupPopedom10,
    this.groupPopedom11,
    this.groupPopedom12,
    this.groupPopedom13,
    this.groupPopedom14,
    this.groupPopedom15,
    this.groupPopedom16,
    this.groupPopedom17,
    this.groupPopedom18,
  });
  @HiveField(0)
  List<String>? groupPopedom1;
  @HiveField(1)
  List<String>? groupPopedom2;
  @HiveField(2)
  List<String>? groupPopedom3;
  @HiveField(3)
  List<String>? groupPopedom4;
  @HiveField(4)
  List<String>? groupPopedom5;
  @HiveField(5)
  List<String>? groupPopedom6;
  @HiveField(6)
  List<String>? groupPopedom7;
  @HiveField(7)
  List<String>? groupPopedom8;
  @HiveField(8)
  List<String>? groupPopedom9;
  @HiveField(9)
  List<String>? groupPopedom10;
  @HiveField(10)
  List<String>? groupPopedom11;
  @HiveField(11)
  List<String>? groupPopedom12;
  @HiveField(12)
  List<String>? groupPopedom13;
  @HiveField(13)
  List<String>? groupPopedom14;
  @HiveField(14)
  List<String>? groupPopedom15;
  @HiveField(15)
  List<String>? groupPopedom16;
  @HiveField(16)
  List<String>? groupPopedom17;
  @HiveField(17)
  List<String>? groupPopedom18;

  GroupPopedomModel.fromJson(Map<String, dynamic> json) {
    groupPopedom1 = List.castFrom<dynamic, String>(json['1']);
    groupPopedom2 = List.castFrom<dynamic, String>(json['2']);
    groupPopedom3 = List.castFrom<dynamic, String>(json['3']);
    groupPopedom4 = List.castFrom<dynamic, String>(json['4']);
    groupPopedom5 = List.castFrom<dynamic, String>(json['5']);
    groupPopedom6 = List.castFrom<dynamic, String>(json['6']);
    groupPopedom7 = List.castFrom<dynamic, String>(json['7']);
    groupPopedom8 = List.castFrom<dynamic, String>(json['8']);
    groupPopedom9 = List.castFrom<dynamic, String>(json['9']);
    groupPopedom10 = List.castFrom<dynamic, String>(json['10']);
    groupPopedom11 = List.castFrom<dynamic, String>(json['11']);
    groupPopedom12 = List.castFrom<dynamic, String>(json['12']);
    groupPopedom13 = List.castFrom<dynamic, String>(json['13']);
    groupPopedom14 = List.castFrom<dynamic, String>(json['14']);
    groupPopedom15 = List.castFrom<dynamic, String>(json['15']);
    groupPopedom16 = List.castFrom<dynamic, String>(json['16']);
    groupPopedom17 = List.castFrom<dynamic, String>(json['17']);
    groupPopedom18 = List.castFrom<dynamic, String>(json['18']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['1'] = groupPopedom1;
    data['2'] = groupPopedom2;
    data['3'] = groupPopedom3;
    data['4'] = groupPopedom4;
    data['5'] = groupPopedom5;
    data['6'] = groupPopedom6;
    data['7'] = groupPopedom7;
    data['8'] = groupPopedom8;
    data['9'] = groupPopedom9;
    data['10'] = groupPopedom10;
    data['11'] = groupPopedom11;
    data['12'] = groupPopedom12;
    data['13'] = groupPopedom13;
    data['14'] = groupPopedom14;
    data['15'] = groupPopedom15;
    data['16'] = groupPopedom16;
    data['17'] = groupPopedom17;
    data['18'] = groupPopedom18;
    return data;
  }
}

class GroupPopedomModelAdapter extends TypeAdapter<GroupPopedomModel> {
  @override
  final typeId = 2;

  @override
  GroupPopedomModel read(BinaryReader reader) {
    return GroupPopedomModel(
      groupPopedom1: reader.read(),
      groupPopedom2: reader.read(),
      groupPopedom3: reader.read(),
      groupPopedom4: reader.read(),
      groupPopedom5: reader.read(),
      groupPopedom6: reader.read(),
      groupPopedom7: reader.read(),
      groupPopedom8: reader.read(),
      groupPopedom9: reader.read(),
      groupPopedom10: reader.read(),
      groupPopedom11: reader.read(),
      groupPopedom12: reader.read(),
      groupPopedom13: reader.read(),
      groupPopedom14: reader.read(),
      groupPopedom15: reader.read(),
      groupPopedom16: reader.read(),
      groupPopedom17: reader.read(),
      groupPopedom18: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, GroupPopedomModel obj) {
    writer.write(obj.groupPopedom1);
    writer.write(obj.groupPopedom2);
    writer.write(obj.groupPopedom3);
    writer.write(obj.groupPopedom4);
    writer.write(obj.groupPopedom5);
    writer.write(obj.groupPopedom6);
    writer.write(obj.groupPopedom7);
    writer.write(obj.groupPopedom8);
    writer.write(obj.groupPopedom9);
    writer.write(obj.groupPopedom10);
    writer.write(obj.groupPopedom11);
    writer.write(obj.groupPopedom12);
    writer.write(obj.groupPopedom13);
    writer.write(obj.groupPopedom14);
    writer.write(obj.groupPopedom15);
    writer.write(obj.groupPopedom16);
    writer.write(obj.groupPopedom17);
    writer.write(obj.groupPopedom18);
  }
}
