installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

ssh -p $ssh_port $ranger_host "sh $BASE_PATH/ranger/run.sh"
print_log warn "若正打印出了端口号，则说明启动成功"
print_log info "访问地址http://$ranger_host:6080"
