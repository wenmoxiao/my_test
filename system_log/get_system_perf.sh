#! /bin/bash

log_file="/data/system_log/log/system_log_perf"
sampling_m=2
sampling_h=2
log_file_num=$[60/$sampling_m*$sampling_h]
sleep_time=40
m_y=1


if [ -f $log_file ]; then
  old_file_size=$(ls -l  $log_file |awk '{print $5}')
  echo $old_file_size
  let m_y_1=$[$old_file_size/1024]
  let m_y_2=$[$m_y_1/10240]
   m_y=$m_y_2
  if [[ $m_y_2 < 1  ]]; then
     m_y=1
  fi
  if [[ $m_y_2 > 40 ]]; then
     m_y=40
  fi
fi
sleep_time=$[$sleep_time/$m_y]

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
  rm -rf /tmp/perf-vdso.so*
}


alli_pid=$(ps -aux |grep "perf" | grep -Ev "grep|get_system_perf" | awk '{print $2}')
for p in $all_pid
do
  kill -2 $p
done



let now_day=`date +%-M`
do_run=$[$now_day%$sampling_m]
if [[ $do_run == 0 ]];then
  #echo $now_day
  if [ -f $log_file ];then
     let file_day=`ls -l $log_file|awk '{print $8}' | awk -F':' '{print $1}'`
     if [[ $file_day !=  $now_day ]];then
       update_log
     fi
  fi

  perf record -a -e cpu-clock -f -o $log_file -c 10000000 sleep $sleep_time 
#  perf top -a -G -e cpu-clock >> $log_file
fi
 







