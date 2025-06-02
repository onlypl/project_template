# 多渠道替换flutter静态资源，用des替换至src
channel="_$1"
echo ">>>>>正在替换渠道资源"
if [ ! -d "../../assets/${channel}" ]; then
  echo ">>>>>替换失败，请检查../../assets/${channel}，目录是否存在"
else
  cp -rf ../../assets/${channel}/ ../../assets/
  echo ">>>>>成功替换资源，当前渠道资源：${channel}"
fi