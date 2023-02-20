installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

ssh -p $ssh_port $efak_ip "docker stop efak && docker rm efak"

print_log info "$efak_ip kefa已关停"
