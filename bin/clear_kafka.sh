installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

ask "确认需要kafka中的数据！输入yes，执行清空，其它，退出!"
if [ "$ask_result" != 'YES' ];then
  print_log warn "输入的内容为：${ask_result},不等于yes,退出"
  exit 0
fi
clear

print_log warn "1. kafka"

sh $installpath/bin/stop_kafka.sh

for ip in `echo ${!servers[*]} | tr " " "\n" | sort` 
do
  print_log warn "2.清空 $ip 节点上kafka的数据"
  ssh -p $ssh_port $ip  "rm -rf $DATA_DIR/kafka"
done
