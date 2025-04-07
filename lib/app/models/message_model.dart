class MessageModel {
  /*
{
  "type": 1,
  "uid": "2",
  "data": "as此接口由flutterschool.cn提供，当前是get请求d"
}
*/

  String? type;
  String? uid;
  String? data;
  String? nickName;
  String? avatarUrl;
  String? time;

  bool? isMe;
  MessageModel({
    this.type,
    this.uid,
    this.nickName,
    this.avatarUrl,
    this.time,
    this.data,
    this.isMe = false,
  });
  MessageModel.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    uid = json['uid']?.toString();
    nickName = json['nickName']?.toString();
    avatarUrl = json['avatarUrl']?.toString();
    time = json['time']?.toString();
    data = json['data']?.toString();
    isMe = json['isMe'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['uid'] = uid;
    data['nickName'] = nickName;
    data['avatarUrl'] = avatarUrl;
    data['time'] = time;
    data['data'] = this.data;
    data['isMe'] = isMe;
    return data;
  }
}
