class APIs {
  /// url
  static const String baseUrl = 'https://tv.myhunan.cn';
  static const String wsUrl = 'ws://pet.myhunan.cn:9502';

  /// 刷新token
  static const String refreshToken =
      '/mock/refreshToken'; //'$baseUrl/mock/refreshToken';

  /// 登录接口
  // static const String login = '/mock/login';

  ///初始化配置所需数据
  static const String startUp = '/icciu_api.php/v1.main/startup';

  ///播放器开始播放广告 （后台播放广告可以是视频或者SDk插屏 网页广告三种） 首页播放记录是否开启 ad_select html video home_history
  static const String getAdconfig = "/icciu_api.php/v1.Vodad";

  ///分类 电影/综艺/电视剧/动漫
  static const String types = '/icciu_api.php/v1.vod/types';

  ///首页推荐列表
  static const String getRecommendList = "/icciu_api.php/v1.vod/vodPhbAll";

  ///视频相关接口 apikey keytime
  ///?ids=42144,21727 根据ID搜索 h 24小时内更新数据信息
  ///wd搜索关键词
  ///type 类别ID
  ///轮播图9 其它类型8 int type, int level
  ///request_type  limit page
  ///type request_type limit page   request_type= top_month top_day
  ///type class limit page
  ///type actor limit page
  ///type class lang  area year by limit page
  ///wd limit page
  static const String getVodList = '/icciu_api.php/v1.vod';

  ///视频详情  apikey keytime
  ///vod_id rel_limit
  static const String getVodDetail = "/icciu_api.php/v1.vod/detail";

  ///专题列表
  static const String topicList = '/icciu_api.php/v1.topic/topicList';

  ///专题详情 topic_id
  static const String topicDetail = '/icciu_api.php/v1.topic/topicDetail';

  ///游戏
  static const String gameList = '/icciu_api.php/v1.youxi/index';

  ///添加视频播放记录+1 vod_id  nid source percent urlIndex curProgress playSourceIndex
  static const String addPlayLog = "/icciu_api.php/v1.user/addViewLog";

  ///上报观影时长+1 view_seconds （Int）
  static const String watchTimeLong = "/icciu_api.php/v1.user/viewSeconds";

  ///获取视频播放记录/购买记录 page limit {type 默认播放}
  static const String getPlayLogList = "/icciu_api.php/v1.user/viewLog";

  ///PUST推送 page limit type=3
  static const String getPushList = "/icciu_api.php/v1.vod/push";

  ///获取视频播放进度 vod_id nid source
  static const String getVideoProgress = "/icciu_api.php/v1.vod/videoProgress";

  ///删除播放记录+1 id
  static const String deletePlayLogList = "/icciu_api.php/v1.user/delVlog";

  ///直播列表
  static const String getLiveList = "/icciu_api.php/v1.zhibo";

  ///弹幕列表 vod_id limit start at_time
  static const String getDanMuList = "/icciu_api.php/v1.danmu/index";

  ///need_vod {bool} true 乐美兔后台的首页分类模块
  static const String getCardList = "/icciu_api.php/v1.main/category";

  ///type_id {int} 电影 电视剧等分类首页
  static const String getCardListByType = "/icciu_api.php/v1.vod/type";

  ///评论
  ///获取评论列表 rid mid page limit
  ///评论POST 内容comment_content 我的id(1) comment_mid (视频ID)comment_rid
  ///回复评论POST  内容comment_content 我的id(1)comment_mid (视频ID)comment_rid 评论ID comment_id comment_pid
  static const String comment = "/icciu_api.php/v1.comment";

  //ac=phone&code=755554&user_pwd=12345678&user_pwd2=12345678&type=2&to=15682522328"
  ///找回密码短信发送 to ac phone
  static const String findpasssms = "/icciu_api.php/v1.auth/findpasssms";

  ///找回密码 to user_pwd user_pwd2 code ac phone  type=2
  static const String findpass = "/icciu_api.php/v1.auth/findpass";

  ///登录 user_name user_pwd
  static const String login = "/icciu_api.php/v1.auth/login";

  //登出
  static const String logout = "/icciu_api.php/v1.auth/logout";

  ///注册 user_name user_pwd user_pwd2 uid
  ////验证码注册 to user_pwd code ac=phone uid
  static const String register = "/icciu_api.php/v1.auth/register";

  ///发送注册验证码 to ac=phone
  static const String verifyCode =
      "/icciu_api.php/v1.auth/registerSms"; //发送注册验证码

  ///是否打开手机号注册
  static const String openRegister = "/icciu_api.php/v1.user/phoneReg";

  ///签到
  static const String sign = "/icciu_api.php/v1.sign";

  static const String groupChat = "/icciu_api.php/v1.groupchat";

  ///购买VIP 卡密 card_pwd
  static const String cardBuy = "/icciu_api.php/v1.user/buy";

  ///POST long group_id
  static const String upgradeGroup = "/icciu_api.php/v1.user/group";

  ///
  static const String scoreList = "/icciu_api.php/v1.user/groups";

  ///
  static const String changeAgents = "/icciu_api.php/v1.user/changeAgents";

  ///
  static const String agentsScore = "/icciu_api.php/v1.user/agentsScore";

  ///用户信息
  static const String userInfo = "/icciu_api.php/v1.user/detail";

  ///修改昵称 user_nick_name
  static const String changeNickName = "/icciu_api.php/v1.user";

  ///修改头像 上传data body
  static const String changeAvator = "/icciu_api.php/v1.upload/user";

  ///提现
  ///申请提现 num type account
  ///获取提现记录 page limit
  static const String goldWithdraw = "/icciu_api.php/v1.user/goldWithdrawApply";

  ///
  static const String payTip = "/icciu_api.php/v1.user/payTip";

  ///
  static const String goldTip = "/icciu_api.php/v1.user/goldTip";

  ///反馈
  ///获取反馈列表 page limit
  ///反馈 gbook_content
  static const String feedBack = "/icciu_api.php/v1.gbook";

  ///收藏列表 page limit ulog_type
  static const String collectionList = "/icciu_api.php/v1.user/favs";

  ///1 vodId 2    收藏
  /// mid id type
  ///vodId 2    取消收藏
  /// ids type
  static const String collection = "/icciu_api.php/v1.user/ulog";

  ///
  static const String shareScore = "/icciu_api.php/v1.user/shareScore";

  ///
  static const String taskList = "/icciu_api.php/v1.user/task";

  ///
  static const String msgList = "/icciu_api.php/v1.message/index";

  /// id
  static const String msgDetail = "/icciu_api.php/v1.message/detail";

  ///
  static const String expandCenter = "/icciu_api.php/v1.user/userLevelConfig";

  ///
  static const String myExpand = "/icciu_api.php/v1.user/subUsers";

  ///发送弹幕 content vod_id +集数下标  播放位置at_time  color
  static const String sendDanmu = "/icciu_api.php/v1.danmu";

  /// id  score
  static const String score = "/icciu_api.php/v1.vod/score";

  ///购买视频 type id sid nid mid pay_type
  static const String buyVideo = "/icciu_api.php/v1.user/buypopedom";

  ///version  os
  static const String checkVersion = "/icciu_api.php/v1.main/version";

  ///"${ApiConfig.MOGAI_BASE_URL + ApiConfig.PAY}?payment=${payment}&order_code=${data.order_code}"
  static const String pay = "/icciu_api.php/v1.user/pay";

  ///order_code
  static const String order = "/icciu_api.php/v1.user/order";

  ///type
  static const String appConfig = "/icciu_api.php/v1.user/appConfig";

  ///
  static const String shareInfo = "/icciu_api.php/v1.user/shareInfo";

  ///rid nid
  static const String videoCount = "/icciu_api.php/v1.vod/videoViewRecode";

  ///
  static const String tabFourInfo = "/icciu_api.php/v1.youxi/index";

  ///获取底部tabbar if (!data.getData().contains("|")) { //不允许对接开源后台
  static const String tabThreeName = "/icciu_api.php/v1.zhibo/thirdUiName";

  ///排行榜 order_by type page limit
  ///type 1电影 2.电视剧 3.综艺 4.动漫
  ///order_by 默认总榜
  ///case 2:
  //     return "vod_hits_month desc"; 月
  // case 3:
  //     return "vod_hits_week desc"; 周
  // case 4:
  //     return "vod_hits_day desc"; 天
  // default:
  //     return "vod_hits desc"; 总榜
  static const String getRankList = "/icciu_api.php/v1.vod/vodphb";
}

//https://miapp.itying.com/api/focus
