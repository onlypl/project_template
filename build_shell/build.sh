##执行 ./build_shell/build.sh baidu
#flutter路径
#export PATH="$PATH:/Users/luke/Documents/flutter/bin"'

## 参数1 = 接收渠道参数
## 参数2 = 接收平台参数，默认android + ios  可以指定android 或者 ios
#执行 ./build_shell/build.sh baidu android
DIR="$(cd "$(dirname "$0")" && pwd)"
echo "脚本所在路径：$DIR"
cd "$DIR"

# 接收渠道参数
channel=$1
# 接收平台参数，默认android + ios  可以指定android 或者 ios
platform=$2
channel_low=$(echo "$channel" | tr 'A-Z' 'a-z')
echo "[channel]：${channel}"
echo "[platform]：${platform}"

# 步骤1：clean操作
echo ">>>>>当前路径：$(pwd)"
chmod 777 ./clean_work_space/clean.sh
 ./clean_work_space/clean.sh
# 步骤2：资源替换
chmod 777 ./assets_swap/assets_swap.sh
 ./assets_swap/assets_swap.sh $channel

# 步骤3：打包操作
if [ ! -n "$platform" ]; then
  echo "all"
  flutter build apk --flavor ${channel} --dart-define=CHANNEL=${channel} --dart-define=BRAND=${channel}
  mv ../build/app/outputs/flutter-apk/app-${channel_low}-release.apk ../output_dir/app-${channel}-release.apk
  cd ../ios
  echo ">>>>>当前ios根路径：$(pwd)"
  pod install --repo-update
  cd ..
  flutter build ios --release --flavor ${channel}
  #flutter build ipa --flavor ${channel} --dart-define=CHANNEL=${channel} --dart-define=BRAND=${channel}
    flutter build ipa --flavor ${channel} --obfuscate --split-debug-info=build/debug-info --dart-define=BRAND=${channel} --dart-define=UM_CHANNEL=${channel}
  mv ../build/ios/archive/${channel}.xcarchive ../output_dir/${channel}.xcarchive
  cd "$DIR"
  #步骤4： 资源回滚
  cho ">>>>>ios 资源回滚当前路径：$(pwd)"
  chmod 777 ./assets_swap/rollback_assets.sh
   ./assets_swap/rollback_assets.sh $channel

else
  if [ "$platform" = "android" ]; then
    flutter build apk --flavor ${channel} --dart-define=CHANNEL=${channel} --dart-define=BRAND=${channel}
    mv ../build/app/outputs/flutter-apk/app-${channel_low}-release.apk ../output_dir/app-${channel}-release.apk
  elif [ "$platform" = "ios" ]; then
    cd ../ios
    echo ">>>>>当前ios根路径：$(pwd)"
    pod install --repo-update
    cd ..
    flutter build ios --release --flavor ${channel} --dart-define=BRAND=${channel}
   # flutter build ipa --flavor ${channel} --dart-define=CHANNEL=${channel} --dart-define=BRAND=${channel}
    flutter build ipa --flavor ${channel} --obfuscate --split-debug-info=build/debug-info --dart-define=BRAND=${channel} --dart-define=UM_CHANNEL=${channel}
    mv ../build/ios/archive/${channel}.xcarchive ../output_dir/${channel}.xcarchive
    cd "$DIR"
    #步骤4： 资源回滚
    cho ">>>>>ios 资源回滚当前路径：$(pwd)"
    chmod 777 ./assets_swap/rollback_assets.sh
      ./assets_swap/rollback_assets.sh $channel
  else
    echo "all"
    flutter build apk --flavor ${channel} --dart-define=CHANNEL=${channel} --dart-define=BRAND=${channel}
    mv ../build/app/outputs/flutter-apk/app-${channel_low}-release.apk ../output_dir/app-${channel}-release.apk
    cd ../ios
    echo ">>>>>当前ios根路径：$(pwd)"
    pod install --repo-update
    cd ..
    flutter build ios --release  --flavor ${channel} --dart-define=BRAND=${channel}
    #flutter build ipa --flavor ${channel} --dart-define=CHANNEL=${channel} --dart-define=BRAND=${channel}
      flutter build ipa --flavor ${channel} --obfuscate --split-debug-info=build/debug-info --dart-define=BRAND=${channel} --dart-define=UM_CHANNEL=${channel}
    mv ../build/ios/archive/${channel}.xcarchive ../output_dir/${channel}.xcarchive
    cd "$DIR"
    #步骤4： 资源回滚
    cho ">>>>>ios 资源回滚当前路径：$(pwd)"
    chmod 777 ./assets_swap/rollback_assets.sh
    ./assets_swap/rollback_assets.sh $channel
  fi
fi