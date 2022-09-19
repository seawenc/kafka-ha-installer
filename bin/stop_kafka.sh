installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

function stop_kafka(){
for ip in `echo ${!servers[*]} | tr " " "\n" | sort`
do
  print_log warn "开始停止$ip 的kafka..."
  ssh $ip "docker stop kafka "
done
}
stop_kafka
print_log info "kafka已全部关停"
