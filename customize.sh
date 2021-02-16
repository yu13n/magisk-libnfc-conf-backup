file_paths=$(find /system /vendor -name "libnfc-*.conf")

if [ -n "$file_paths"]
then
  abort "Failed! No libnfc-*.conf found!"
fi

for f_path in $file_paths
do
  temp=${f_path#*/}
  if [[ ${temp%%/*} = vendor ]]
  then
    path="/system"$f_path
  else
    path=$f_path
  fi

  temp=${path#*/}
  if [[ ${temp%%/*} = system ]]
  then
    path=${path%/*}
    ui_print "   Copying File $f_path"
    mkdir -p $MODPATH$path
    cp -p $f_path $MODPATH$path
  fi
done
