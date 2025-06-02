# 创建文件夹 与 clean操作

if [ ! -d '../output_dir' ]; then
  mkdir '../output_dir'
fi
rm -rf ../output_dir/*
echo ">>>>>clean已经完成"