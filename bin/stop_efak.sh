installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

ssh -p $ssh_port $kafkaui_ip "docker stop kafkaui && docker rm kafkaui"

print_log info "$kafkaui_ip kafaui已关停"
