installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

function start_kafka(){
for ip in `echo ${!servers[*]} | tr " " "\n" | sort`
do
  print_log warn "开始启动$ip 的kafka..."
  ssh -p $ssh_port $ip "$BASE_PATH/kafka/run.sh" 
done
}
start_kafka
print_log info "#################等待kafka启动 ###############################"
watch -d -n 5 bash $installpath/bin/check_kafka.sh
