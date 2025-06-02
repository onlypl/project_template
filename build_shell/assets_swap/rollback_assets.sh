# 替换资源完成后，打完包后，执行rollback assets 操作，来确保git记录不会修改，
channel="_$1"
# 遍历渠道下的文件，执行checkout回退指令
function rollback(){
  for file in `ls $1`
    do
      if [ -d "$1/$file" ]
      then
        rollback $1"/"$file
      else
        local path=$1"/"$file
        local delete=$channel"/"
        echo ">>>>>需要回滚的图片：${path//$delete}"
        git checkout ${path//$channel"/"}
      fi
    done
}

rollback "../../assets/${channel}"