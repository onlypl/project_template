#执行 ./build_shell/build_ios.sh baidu
DIR="$(cd "$(dirname "$0")" && pwd)"
echo "脚本所在路径：$DIR"
cd "$DIR"
channel="$1"
#channel="baidu"
if [ -z "$channel" ]; then
  echo "❌ 请传入渠道名，例如：./build_shell/build_ios.sh filgame"
  exit 1
fi
echo ">>>>>当前渠道：$channel"

# 步骤1：clean操作
echo ">>>>>当前路径：$(pwd)"
chmod 777 ./clean_work_space/clean.sh
 ./clean_work_space/clean.sh
# 步骤2：资源替换
chmod 777 ./assets_swap/assets_swap.sh
 ./assets_swap/assets_swap.sh $channel

# 步骤3：打包aios
echo ">>>>>开始编译ios"
cd ../ios
echo ">>>>>当前ios根路径：$(pwd)"
pod install --repo-update
cd ..
echo ">>>>>ios 返回项目根目录：$(pwd)"
flutter build ios --release --flavor ${channel} --dart-define=BRAND=${channel}
#--split-per-abi
flutter build ipa --flavor ${channel} --obfuscate --split-debug-info=build/debug-info --dart-define=BRAND=${channel} --dart-define=UM_CHANNEL=${channel}
mv ../build/ios/archive/${channel}.xcarchive ../output_dir/${channel}.xcarchive
cd "$DIR"
# 步骤4：资源回滚
cho ">>>>>ios 资源回滚当前路径：$(pwd)"
chmod 777 ./assets_swap/rollback_assets.sh
./assets_swap/rollback_assets.sh $channel