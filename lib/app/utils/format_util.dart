import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';

///数字转万
String countFormat(int count) {
  String countStr = "";
  if (count > 9999) {
    countStr = "${(count / 10000).toStringAsFixed(2)}万";
  } else {
    countStr = count.toString();
  }
  return countStr;
}

///时间转换将秒转换为小时:分钟:秒
///[seconds] 秒
///[isShowHour] 是否显示小时
String durationTransForm(int seconds, bool isShowHour) {
  String hourStr = ''; //小时
  String minuteStr = ''; //分钟
  String secondsStr = ''; //秒
  String payTime = ''; //播放时长
  minuteStr = formatNumberWithLeadingZero(((seconds ~/ 60) % 60));
  secondsStr = formatNumberWithLeadingZero(seconds % 60);
  payTime = '$minuteStr:$secondsStr';
  if (seconds >= 3600 || isShowHour) {
    hourStr = formatNumberWithLeadingZero(seconds ~/ 3600);
    payTime = '$hourStr:$payTime';
  }

  return payTime;
}

///几分钟前
String formatRelativeTime(DateTime date, DateTime nowDate) {
  // final now = DateTime.now();
  final diff = nowDate.difference(date);
  if (diff.inMinutes == 0) {
    return '刚刚';
  } else if (diff.inMinutes <= 60) {
    return '${diff.inMinutes}分钟前';
  } else if (diff.inHours < 24) {
    return '${diff.inHours}小时前';
  } else if (diff.inDays >= 1) {
    return '${DateFormat.Hm().format(date)}}';
  } else {
    return '${DateFormat.yMd().format(date)} : ${DateFormat.Hm().format(date)}'; // 或者其他你希望的格式
  }
}

///小于10则前面补0
String formatNumberWithLeadingZero(int number) {
  return number.toString().padLeft(2, '0');
}

///10位时间戳转换时间字符串
String timestampToDate(int timestamp) {
  DateTime nowDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var formatter = DateFormat('yyyy-MM-dd HH:mm'); //ss
  return formatter.format(nowDate);
}

///播放时间格式化
String formatDuration(Duration position) {
  final ms = position.inMilliseconds;
  return formatDateInt(ms);
}

String formatDateInt(int ms) {
  int seconds = ms ~/ 1000;
  //int seconds = ms;
  final int hours = seconds ~/ 3600;
  seconds = seconds % 3600;
  final minutes = seconds ~/ 60;
  seconds = seconds % 60;

  final hoursString =
      hours >= 10
          ? '$hours'
          : hours == 0
          ? '00'
          : '0$hours';

  final minutesString =
      minutes >= 10
          ? '$minutes'
          : minutes == 0
          ? '00'
          : '0$minutes';

  final secondsString =
      seconds >= 10
          ? '$seconds'
          : seconds == 0
          ? '00'
          : '0$seconds';

  final formattedTime =
      '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';

  return formattedTime;
}

///提取html的标签内的属性内容  标签 tag  属性attrName
String? parserHtml(String html, String tag, String attrName) {
  var document = parse(html);
  var hrefs = document.getElementsByTagName(tag);
  String? value;
  hrefs.forEach((element) {
    value = element.attributes[attrName];
  });
  return value;
}

class Strings {
  ///防止文字自动换行
  static String autoLineString(String str) {
    if (str.isNotEmpty) {
      return str.fixAutoLines();
    }
    return "";
  }
}

/// 防止文字自动换行
/// 当中英文混合，或者中文与数字或者特殊符号，或则英文单词时，文本会被自动换行，
/// 这样会导致，换行时上一行可能会留很大的空白区域
/// 把每个字符插入一个0宽的字符， \u{200B}
extension _FixAutoLines on String {
  String fixAutoLines() {
    return Characters(this).join('\u{200B}');
  }
}
