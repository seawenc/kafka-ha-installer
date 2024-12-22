installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

# 判断mysql端口通不通
[ "`nmap $mysql_host -p $mysql_port | grep $mysql_port | awk '{print $2}'`" = "open" ] && echo "mysql已安装" && exit 0 || echo "mysql未安装" || echo 1
