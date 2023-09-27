###############################0.参数配置##########################
# docker版本,需要提前下载放到packages目录中,下载地址：https://download.docker.com/linux/static/stable/x86_64/
DOCKER_VERSION=20.10.19
# 基本路径，zookeeper与kafka都安装在此目录,请确保此目录有权限
BASE_PATH=/opt/app/zkafka
# 数据存放目录
DATA_DIR=/opt/app/zkafka/data
# kafka地址,格式:  servers[内网地址]="外网地址" （如果没有网外地址，则与内网设置为一致）
declare -A servers=()
servers["192.168.56.11"]="192.168.55.11"
servers["192.168.56.12"]="192.168.55.12"
servers["192.168.56.13"]="192.168.55.13"
ssh_port=22
kafka_port=9092
kafka_port_outside=9093
# kafka消息生存时间（单位小时）
kafka_msg_storage_hours=84
# kafka与zookeeper的共用一个账号密码(密码请不要包含@符号)
zkkuser='admin'
zkkpwd='aaBB1122'

# 监控工具efak安装在哪台服务器上,默认是排序后的第一台服务器，若想修改，请直接写死
efak_ip=`echo ${!servers[*]} | tr " " "\n" | sort | head -1`

#efak数据库类型,值有：（若直接将efak.properties文件中直接将数据库信息写死，则可不用管以下参数）
#    local:使用本地数据库，不太稳定，可能会偶尔锁库，若使用此种模式，则以下其它配置则无效
#    mysql-auto: efak安装脚本，自动安装一个mysql
#    mysql-ext : 使用外部已有mysql
efak_db_type=local
# 当 efak_db_type=mysql-auto时，mysql安装在哪一台服务器，默认是排序后的第二台，若想修改，请直接写死，其它类型时，此配置无效
efak_db_ip=`echo ${!servers[*]} | tr " " "\n" | sort | head -2 | tail -1`
# 以下三个参数在efak_db_type!=local时生效
efak_db_jdbc=jdbc:mysql://${efak_db_ip}:33306/efak?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
efak_db_user=efak
efak_db_pwd=aaBB1122
##############################################################

