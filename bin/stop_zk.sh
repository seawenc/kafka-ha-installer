installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

function stop_zookeeper(){
for ip in `echo ${!servers[*]} | tr " " "\n" | sort`
do
  print_log warn "开始停止$ip 的zookeeper..."
  ssh -p $ssh_port $ip "docker stop zookeeper"
done
}
stop_zookeeper
print_log info "zookeeper已全部关停"
