installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

ssh -p $ssh_port $ranger_host "docker stop ranger && docker rm ranger"

print_log info "ranger 已关停"
