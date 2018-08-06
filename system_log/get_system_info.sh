#! /bin/bash
if [ $# != 0 ] && [ $# != 1 ]; then
  echo "./get_system_info.sh interval_time"
  exit 0
fi

log_file_num=7
interval_time=10
log_file="/data/system_log/log/system_log"

if [ $# == 2 ];then
 interval_time=$1
fi


function update_log
{
  file_name=$log_file"_"$log_file_num
  if [ -f $file_name ]; then
     rm -rf $file_name
  fi
  for ((idx = $(($log_file_num - 1)); idx > 0; idx -=1));
  do
    file_name_f=$log_file"_"$idx
	file_name_to=$log_file"_"$(($idx + 1))
    if [ -f $file_name_f ]; then
	 mv $file_name_f $file_name_to
	fi
  done
  
  file_name=$log_file
  if [ -f $file_name ]; then
     mv $file_name $file_name"_1"
  fi
}



let now_day=`date +%-d`
#echo $now_day
if [ -f $log_file ];then
  let file_day=`ls -l $log_file|awk '{print $7}'`
  if [[ $file_day !=  $now_day ]];then
    update_log
    echo "change_next_day $now_day $file_day" >> $log_file
  fi
else
   echo "change_next_day 0 $now_day" >> $log_file  
fi

# get commond
num_index=0
export -a commond_list
commond_file="./system_info_commond.conf"
while read line
do
  #echo $num_index $line
  commond_list[$num_index]=$line
  ((num_index++))
done < $commond_file



while((1))
do
  echo -e "\n\n\n==========================="`date`"===========================">> $log_file 
  echo "=========================== top">> $log_file
  top -n 1 -b|head -15|tail -8 >> $log_file
  echo "=========================== ps">> $log_file
  ps -aux |sort -rn -k +4 |head -5 >> $log_file
   
  for ((idx = 0; idx < num_index; idx +=1));
  do
    if [[ "" != ${commond_list[$idx]} ]]; then 
        echo "=========================== "${commond_list[$idx]} >> $log_file
	${commond_list[$idx]} >> $log_file
    fi
  done
  
  sleep $interval_time

done
