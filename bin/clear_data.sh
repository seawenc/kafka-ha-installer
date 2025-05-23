installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

ask "确认需要清空所有数据！输入yes，执行清空，其它，退出!"
if [ "$ask_result" != 'YES' ];then
  print_log warn "输入的内容为：${ask_result},不等于yes,退出"
  exit 0
fi
clear

print_log warn "1. 停止zk,kafka"

sh $installpath/bin/stop_efak.sh
sh $installpath/bin/stop_kafka.sh
sh $installpath/bin/stop_zk.sh
#sh $installpath/bin/stop_ranger.sh
#sh $installpath/bin/stop_mysql.sh

#ssh -p $ssh_port $mysql_host "rm -rf $DATA_DIR/mysql"

for ip in `echo ${!servers[*]} | tr " " "\n" | sort` 
do
  print_log warn "2.清空 $ip 节点上kafka,zookeeper的数据"
  # 先停止kafka 解决重复启动问题
  ssh -p $ssh_port $ip  "rm -rf $DATA_DIR/kafka $DATA_DIR/efak $DATA_DIR/zookeeper  "
done
