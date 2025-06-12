#执行 ./build_shell/build_android.sh baidu
DIR="$(cd "$(dirname "$0")" && pwd)"
echo "脚本所在路径：$DIR"
cd "$DIR"
channel="$1"
#channel="baidu"
if [ -z "$channel" ]; then
  echo "❌ 请传入渠道名，例如：./build_shell/build_android.sh filgame"
  exit 1
fi
echo ">>>>>当前渠道：$channel"
#--dart-define=BRAND=filbet--dart-define=FLAVOR=filbet--dart-define=API_BASE_URL=https://xxxx.com
# 步骤1：clean操作
echo ">>>>>当前路径：$(pwd)"
chmod 777 ./clean_work_space/clean.sh
 ./clean_work_space/clean.sh
# 步骤2：资源替换
chmod 777 ./assets_swap/assets_swap.sh
./assets_swap/assets_swap.sh $channel
# 步骤3：打包apk/ios
echo ">>>>>开始编译apk"
# --obfuscate --split-debug-info=debugInfo 混淆
# --split-per-abi 是分别打包armv7和arm64 x86
#只移动app-armeabi-v7a
#mv ./build/app/outputs/flutter-apk/app-armeabi-v7a-${channel}-release.apk ../output_dir/${channel}.apk
flutter build apk --flavor ${channel} --obfuscate --split-debug-info=debugInfo --dart-define=BRAND=${channel} --dart-define=UM_CHANNEL=${channel}
mv ./build/app/outputs/flutter-apk/app-${channel}-release.apk ../output_dir/${channel}.apk

# 步骤4：资源回滚
chmod 777 ./assets_swap/rollback_assets.sh
./assets_swap/rollback_assets.sh $channel