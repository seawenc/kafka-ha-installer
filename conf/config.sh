###############################0.参数配置##########################
# 基本路径，zookeeper与kafka都安装在此目录,请确保此目录有权限
BASE_PATH=/opt/app/zkafka
# 数据存放目录
DATA_DIR=/opt/app/zkafka/data
# kafka地址,格式:  servers[内网地址]="外网地址" （如果没有网外地址，则与内网设置为一致）
declare -A servers=()
servers["192.168.56.11"]="192.168.55.11"
servers["192.168.56.12"]="192.168.55.12"
servers["192.168.56.13"]="192.168.55.13"
kafka_port=9092
kafka_port_outside=9093
# kafka消息生存时间（单位小时）
kafka_msg_storage_hours=84
# kafka与zookeeper的共用一个账号密码
zkkuser='admin'
zkkpwd='aaBB1122'

# 监控工具efak安装在哪台服务器上,默认是第一台服务器，若想修改，请直接写死
efak_ip=`echo ${!servers[*]} | tr " " "\n" | sort | head -1`
##############################################################

