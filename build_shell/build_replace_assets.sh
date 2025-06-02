#flutter路径
export PATH="$PATH:/Users/luke/Documents/flutter/bin"

# 接收渠道参数
channel=$1
# 接收平台参数，默认android + ios  可以指定android 或者 ios
platform=$2
echo ">>>>>当前渠道[channel]：${channel}"
echo ">>>>>当前平台[platform]：${platform}"

# 步骤1：clean操作
chmod 777 ./clean_work_space/clean.sh
cd ./clean_work_space
./clean.sh
cd ..

# 步骤2：资源替换
chmod 777 ./assets_swap/assets_swap.sh
cd ./assets_swap
./assets_swap.sh $channel
cd ..


# 步骤3： 打包操作
if [ ! -n "$platform" ]; then
  echo 'all'
      echo ">>>>>开始编译apk"
      flutter build apk --flavor ${channel} --dart-define=CHANNEL=${channel}
      mv ../build/app/outputs/flutter-apk/app-${channel}-release.apk ../output_dir/app-${channel}-release.apk
      echo ">>>>>开始编译ios"
      flutter build ios --release
      flutter build ipa --flavor ${channel} --dart-define=CHANNEL=${channel}
      mv ../build/ios/archive/${channel}.xcarchive ../output_dir/${channel}.xcarchive
else
   if [ $platform == 'android' ]; then
      echo ">>>>>开始编译apk"
      flutter build apk --flavor ${channel} --dart-define=CHANNEL=${channel}
      mv ../build/app/outputs/flutter-apk/app-${channel}-release.apk ../output_dir/app-${channel}-release.apk
    elif [ $platform == 'ios' ]; then
      echo ">>>>>开始编译ios"
      flutter build ios --release
      flutter build ipa --flavor ${channel} --obfuscate --split-debug-info --split-per-abi  --dart-define=UMENG_CHANNEL=${channel}
      mv ../build/ios/archive/${channel}.xcarchive ../output_dir/${channel}.xcarchive
    else
        echo 'all'
        echo ">>>>>开始编译apk"
        flutter build apk --flavor ${channel} --dart-define=CHANNEL=${channel}
        mv ../build/app/outputs/flutter-apk/app-${channel}-release.apk ../output_dir/app-${channel}-release.apk
        echo ">>>>>开始编译ios"
        flutter build ios --release
        flutter build ipa --flavor ${channel} --dart-define=CHANNEL=${channel}
        mv ../build/ios/archive/${channel}.xcarchive ../output_dir/${channel}.xcarchive
    fi
  fi

  # 步骤4：资源回滚
  chmod 777 ./assets_swap/rollback_assets.sh
  cd ./assets_swap
  rollback_assets.sh $channel