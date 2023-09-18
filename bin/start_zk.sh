installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

print_log info "################# 1.启动zookeeper ###############################"
function start_zk(){
for ip in `echo ${!servers[*]} | tr " " "\n" | sort`
do
  print_log info "开始启动$ip 的zookeeper"
  ssh -p $ssh_port $ip "docker start zookeeper"
done
}

start_zk
print_log info "######## 2.等待zookeeper启动 ##########################"
watch -n 6 -d bash $installpath/bin/check_zk.sh
