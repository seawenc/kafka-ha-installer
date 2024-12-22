installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

ssh -p $ssh_port $mysql_host "docker stop mysql && docker rm mysql"

print_log info "mysql 已关停"
