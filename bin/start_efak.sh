installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

ssh -p $ssh_port $efak_ip "sh $BASE_PATH/efak/run.sh"
print_log warn "若上面日志打印出了：'EFAK Service has started success.' 则说明安装成功"
print_log info "访问地址http://$efak_ip:8048 (启动后第一次访问很慢，请耐心等待)"
