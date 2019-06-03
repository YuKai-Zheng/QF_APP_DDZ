#!/bin/bash
log_split="=========================================================================="
log_file="./资源比较报告.log"

##用户输入##
read -p "请输入旧版资源路径:  " res_old
read -p "请输入新版资源路径:  " res_new

##文件比较##
if [ ! -d $res_old ]; then
  echo ${version}"找不到"${res_old}
  exit 0
fi
if [ ! -d $res_new ]; then
  echo ${version}"找不到"${res_old}
  exit 0
fi

echo "开始比较资源..."
fold_new=$(echo $res_new | sed 's|\(^[^/]*\).*|\1|')
fold_old=$(echo $res_old | sed 's|\(^[^/]*\).*|\1|')

##备份文件
fold_bk="res_backup/"
if [ -d $fold_bk ]; then
  rm -rf $fold_bk
fi
mkdir $fold_bk
backup_res()
{
  local bk_file=$1
  local fname=${short_name##*/}
  local dname=${short_name%/*}
  local dst_path=${fold_bk}${dname}$"/"
  local src_path=${fold_new}"/"${bk_file}
  if [ -d $bk_dir ]; then
    mkdir -p $dst_path
    cp -rf $src_path $dst_path
  fi 
}

##比较获得新增和变大的文件
echo "正在检测新增文件和被增大的文件..."
total_add=0
total_grow=0
array_grow_index=0
array_add_index=0
compare_grow()
{
    for file in $1/*
    do
        if [ -d $file ]; then
            compare_grow $file
        elif [ -f $file ]; then
            if [ ! -L $file ]
            then
                filesize=`wc -c < $file`
                file2=$(echo $file | sed "s|^.[^/]*\(.*\)|$fold_old\1|")
                short_name=${file#*/}
                if [ ! -f "$file2" ]; then
                  grow=`expr $filesize - 0`
                  str="新增文件\t"${grow}"\t\t"${short_name}
                  array_add[array_add_index]=$str
                  array_add_index=`expr $array_add_index + 1`
                  total_add=`expr $total_add + $filesize`
                  echo -en "\r"${str}"                                  \b"
                  backup_res $short_name
                else
                  filesize2=`wc -c < $file2`
                  if [ $filesize -gt $filesize2 ]; then
                    grow=`expr $filesize - $filesize2`
                    str="文件增大\t"${grow}"\t\t"${short_name}
                    array_grow[array_grow_index]=$str
                    array_grow_index=`expr $array_grow_index + 1`
                    total_grow=`expr $total_grow + $grow`
                    echo -en "\r"${str}"                                  \b"
                    backup_res $short_name
                  fi 
                fi
            fi
        fi
    done
}
compare_grow $fold_new

##比较获得删除或减小的文件
echo -en "\r正在检测删除文件和被减小的文件...                               \b"
echo ""
total_reduce=0
total_delete=0
array_reduce_index=0
array_delete_index=0
compare_reduce()
{
    for file in $1/*
    do
        if [ -d $file ]; then
            compare_reduce $file
        elif [ -f $file ]; then
            if [ ! -L $file ]
            then
                filesize=`wc -c < $file`
                file2=$(echo $file | sed "s|^.[^/]*\(.*\)|$fold_new\1|")
                short_name=${file#*/}
                if [ ! -f "$file2" ]; then
                  grow=`expr $filesize - 0`
                  str="删除文件\t"${grow}"\t\t"${short_name}
                  array_delete[array_delete_index]=$str
                  array_delete_index=`expr $array_delete_index + 1`
                  total_delete=`expr $total_delete + $filesize`
                  echo -en "\r"$str"                                  \b"
                else
                  filesize2=`wc -c < $file2`
                  if [ $filesize -gt $filesize2 ]; then
                    grow=`expr $filesize - $filesize2`
                    str="文件减小\t"${grow}"\t\t"${short_name}
                    array_reduce[array_reduce_index]=$str
                    array_reduce_index=`expr $array_reduce_index + 1`
                    total_reduce=`expr $total_reduce + $grow`
                    echo -en "\r"$str"                                  \b"
                  fi
                fi
            fi
        fi
    done
}
compare_reduce $fold_old

##排序并输出到日志文件
getValue()
{
  local text=$1
  local part=${text%"\t\t"*}
  local n=${part#*"\t"}
  echo $n
}

sortAndOutput()
{
  local arr=($1)
  for (( i=0 ; i<${#arr[@]} ; i++ ))
  do
    for (( j=${#arr[@]} - 1 ; j>i ; j-- ))
    do
      local m=`getValue ${arr[j]}`
      local n=`getValue ${arr[j-1]}`
      if  [[ $m -gt $n ]]
      then
         t=${arr[j]}
         arr[j]=${arr[j-1]}
         arr[j-1]=$t
      fi
    done
  done
  for (( i=0 ; i<${#arr[@]} ; i++ ))
  do
    echo -en ${arr[i]}"\n" | tee -a $log_file
  done
}
if [ -f $log_file ]; then
  rm $log_file
fi

echo -en "\r文件检索完毕，开始统计...                                               \b"
echo ""
echo -en "\n**以下是新增的文件:\n" | tee -a $log_file
sortAndOutput "${array_add[*]}"
echo "(共计: "${total_add}" 字节)" | tee -a $log_file
echo $log_split | tee -a $log_file
echo -en "\n**以下是增大的文件:\n" | tee -a $log_file
sortAndOutput "${array_grow[*]}"
echo "(共计: "${total_grow}" 字节)" | tee -a $log_file
echo $log_split | tee -a $log_file
echo -en "\n**以下是删除的文件:\n" | tee -a $log_file
sortAndOutput "${array_delete[*]}"
echo "(共计: "${total_delete}" 字节)" | tee -a $log_file
echo $log_split | tee -a $log_file
echo -en "\n**以下是减小的文件:\n" | tee -a $log_file
sortAndOutput "${array_reduce[*]}"
echo "(共计: "${total_reduce}" 字节)" | tee -a $log_file
echo $log_split | tee -a $log_file

total_grow=`expr $total_grow + $total_add`
total_reduce=`expr $total_reduce + $total_delete`
if [ $total_grow -gt $total_reduce ]; then
  grow_size=`expr $total_grow - $total_reduce`
  echo "与"${version}"版本相比, 当前版本共增加"${grow_size}"字节" | tee -a $log_file
elif [ $total_grow -lt $total_reduce ]; then
  reduce_size=`expr $total_reduce - $total_grow`
  echo "与"${version}"版本相比, 当前版本共减少"${reduce_size}"字节" | tee -a $log_file
else
  echo "与"${version}"版本相比, 资源总大小未变" | tee -a $log_file
fi

echo -en "\n\n资源比较完毕,统计结果已保存至"${log_file}"\n\n"

