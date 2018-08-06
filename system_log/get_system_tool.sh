#! /bin/bash
if [ $# != 0 ] && [ $# != 1 ]; then
  exit 0
fi

old_cron_line="\*\/3 \* \* \* \* cd \/data\/system_log\/; sh get_system_tool.sh >\/dev\/null 2>&1"
cron_line="\*\/1 \* \* \* \* cd \/data\/system_log\/; sh get_system_tool.sh >\/dev\/null 2>&1"
cron_file=/var/spool/cron/root
fuben_file=/var/spool/cron/system_log
fuben_file_1=/var/spool/cron/system_log_1
fuben_file_2=/var/spool/cron/system_log_2
check_log="/data/system_log/crontab_sys_time.log"


# 
do_type=0
if [ $# == 1 ];then
 do_type=$1
fi


time_d=`date +%y_%m_%d_%H_%M_%S`

function do_crontab
{
   pid_num=$(ps -aux |grep "get_system_tool" | grep -Ev "grep" | grep "system_log" |wc -l)
   if (( $pid_num > 0 ));then
      sleep 3
   fi
   if (( $do_type == 1 )); then
      mv $cron_file $cron_file.$time_d
      mv $fuben_file_1 $cron_file
      crontab $cron_file
   else
      mv $cron_file $cron_file.$time_d
      mv $fuben_file_2 $cron_file
      crontab $cron_file
   fi
}



if (( $do_type == 1 )); then
    rm -rf $fuben_file_1 
    crontab -l >> $fuben_file_1
    need_change=0
    old_3=$(cat $fuben_file_1 | grep "*/3 * * * * cd /data/system_log/; sh get_system_tool.sh >/dev/null 2>&1")
    if [ "$old_3" != "" ]; then
        sed -i "/${old_cron_line}/d" $fuben_file_1
        need_change=1
    fi

  set_cron=$(cat $fuben_file_1 |grep get_system_tool)
  if [ "$set_cron" = "" ]; then
    echo  "*/1 * * * * cd /data/system_log/; sh get_system_tool.sh >/dev/null 2>&1"  >> $fuben_file_1
    need_change=1
  fi
  if (( $need_change == 1 ));then
     do_crontab
  else
     exit 0
  fi
fi


if (( $do_type == 2 )); then
  rm -rf $fuben_file_2
  crontab -l >> $fuben_file_2
  del_cron=$(cat $fuben_file_2 |grep get_system_tool)
  if [ "$del_cron" != "" ]; then
        sed -i "/${cron_line}/d" $fuben_file_2
        do_crontab
  fi
fi

if (( $do_type == 0 )); then
  rm -rf $fuben_file
  crontab -l >> $fuben_file
  crontab -l | grep -F "${cron_line}" $fuben_file >/dev/null
  if ! [ $? -gt 1 ]; then
        set_cron=$(cat $fuben_file |grep get_system_tool)
        if [ "$set_cron" = "" ]; then
           echo $time_d"  crontab not get_system_tool" >> check_log
        fi
  fi
fi


log_file_path="/data/system_log/log"
if [ ! -d "$log_file_path" ]; then  
   mkdir "$log_file_path"  
fi

all_pid=$(ps -aux |grep get_system_info | grep -v "grep" | awk '{print $2}')
echo $all_pid
for p in $all_pid
do
  kill -9 $p
done


all_pid=$(ps -aux |grep get_system_perf | grep -v "grep" | awk '{print $2}')
echo $all_pid
for p in $all_pid
do
  kill -9 $p
done



echo $perf_info

if (( $do_type != 2 ));then
   sh ./get_system_info.sh &
   perf_info=$(rpm -qa | grep perf |grep -v "gperf" |sum |awk '{print $2}')
   if (( 0 != $perf_info));then
     sh ./get_system_perf.sh &
   fi
fi





