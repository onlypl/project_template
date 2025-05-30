#flutter路径
export PATH="$PATH:/Users/luke/Documents/flutter/bin"
# 创建文件夹 与 clean操作
if [ ! -d '../output_dir' ]; then
  mkdir '../output_dir'
fi
rm -rf ../output_dir/*

# 接收渠道参数
channel=$1
# 接收平台参数，默认android + ios  可以指定android 或者 ios
platform=$2
channel_low=`echo $channel | tr 'A-Z' 'a-z'}`
echo "[channel]：${channel}"
echo "[platform]：${platform}"

# 打包操作
if [ ! -n "$platform" ]; then
  echo 'all'
  flutter build apk --flavor ${channel} --dart-define=CHANNEL=${channel}
  mv ./build/app/outputs/flutter-apk/app-${channel_low}-release.apk ./output_dir/app-${channel}-release.apk
  flutter build ios --release
  flutter build ipa --flavor ${channel} --dart-define=CHANNEL=${channel}
  mv ./build/ios/archive/${channel}.xcarchive ./output_dir/${channel}.xcarchive
else
  if [ $platform == 'android' ]; then
    flutter build apk --flavor ${channel} --dart-define=CHANNEL=${channel}
    mv ./build/app/outputs/flutter-apk/app-${channel_low}-release.apk ./output_dir/app-${channel}-release.apk
  elif [ $platform == 'ios' ]; then
    flutter build ios --release
    flutter build ipa --flavor ${channel} --dart-define=CHANNEL=${channel}
    mv ./build/ios/archive/${channel}.xcarchive ./output_dir/${channel}.xcarchive
  else
    echo 'all'
    flutter build apk --flavor ${channel} --dart-define=CHANNEL=${channel}
    mv ./build/app/outputs/flutter-apk/app-${channel_low}-release.apk ./output_dir/app-${channel}-release.apk
    flutter build ios --release
    flutter build ipa --flavor ${channel} --dart-define=CHANNEL=${channel}
    mv ./build/ios/archive/${channel}.xcarchive ./output_dir/${channel}.xcarchive
  fi
fi

# 上传output_dir里的打包文件到cstore,钉钉,企业微信等....
# 下载链接为： https://jenkins域名/job/工作空间/ws/生成apk的上级目录/apk名称
# 如本案例为：http://localhost:8080/job/channel_demo/ws/output_dir/app-channelA-release.apk
# 一般会发送到钉钉,企业微信等....
# 企业微信Api入口：https://developer.work.weixin.qq.com/document/path/91770
# 钉钉Api入口：https://open.dingtalk.com/document/robots/custom-robot-access
#如： curl -s -X POST -d "本次构建的下载链接为：$downUrl" "https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=${token}"