channel="dev"
echo ">>>>>当前渠道：$channel"

# 步骤1：clean操作
chmod 777 ./clean_work_space/clean.sh
cd ./clean_work_space
clean.sh
cd ..

# 步骤2：资源替换
chmod 777 ./assets_swap/assets_swap.sh
cd ./assets_swap
assets_swap.sh $channel
cd ..

# 步骤3：打包aios
echo ">>>>>开始编译ios"
flutter build ios --release
flutter build ipa --flavor ${channel} --obfuscate --split-debug-info --split-per-abi  --dart-define=UMENG_CHANNEL=${channel}
mv ../build/ios/archive/${channel}.xcarchive ../output_dir/${channel}.xcarchive

# 步骤4：资源回滚
chmod 777 ./assets_swap/rollback_assets.sh
cd ./assets_swap
rollback_assets.sh $channel