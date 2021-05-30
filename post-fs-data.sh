MODPATH=${0%/*}
SYSTEMCODE="$MODPATH/system_code"
touch $SYSTEMCODE
LOGFILE="$MODPATH/post-fs-data.log"
touch $LOGFILE

function logHandler() {
  echo -e "$(date +"%m-%d-%Y %H:%M:%S.%3N") - $*" >> $LOGFILE
}

logHandler "Log start"

previous_code=$(cat $SYSTEMCODE)
logHandler "上次备份时系统版本号: $previous_code"

current_code=$(getprop ro.vendor.build.version.incremental)
logHandler "当前系统版本号: $current_code"

if [ "$previous_code" != "$current_code" ]
then
  logHandler "自上次备份后系统已更新. 正在重新备份..."

  echo $current_code > $SYSTEMCODE
  
  file_paths=$(find /system /vendor -name "libnfc-*.conf")

  if [ -n "$file_paths" ]
  then
    # 已找到"libnfc-*.conf"文件，删除旧文件
    rm -rf $MODPATH/system

    for f_path in $file_paths
    do
      temp=${f_path#*/} # 删掉第一个 / 及其左边的字符串
      if [[ ${temp%%/*} = vendor ]] # 删掉第一个 / 及其右边的字符串
      then
        path="/system"$f_path
      else
        path=$f_path
      fi

      temp=${path#*/} # 删掉第一个 / 及其左边的字符串
      if [[ ${temp%%/*} = system ]] # 删掉第一个 / 及其右边的字符串
      then
        logHandler "正在备份文件 $f_path..."
        dir=${path%/*} # 删掉最后一个 / 及其右边的字符串
        mkdir -p $MODPATH$dir # 递归创建目录
        cp -p $f_path $MODPATH$path # 保持文件属性复制
      fi
    done
  fi
else
  logHandler "无需更新"
fi
logHandler "Log end"