###############################0.参数配置##########################
# 需果需要自动安装docker,需要提前下载放到packages目录中,下载地址：https://download.docker.com/linux/static/stable/x86_64/

# 基本路径，zookeeper与kafka都安装在此目录,请确保此目录有权限
BASE_PATH=/opt/app/zkafka
# 数据存放目录
DATA_DIR=/opt/app/zkafka/data
###################### kafka+zookeeper 相关配置
# kafka地址,格式:  servers[内网地址]="外网地址" （如果没有网外地址，则与内网设置为一致）
declare -A servers=()
servers["192.168.56.11"]="192.168.56.11"
servers["192.168.56.12"]="192.168.56.12"
servers["192.168.56.13"]="192.168.56.13"
ssh_port=22
# kafka内网端口号
kafka_port=9093
# kafka外网端口号
kafka_port_outside=9092
# broker节点之前的通信端口
kafka_port_broker=9091
# kafka消息生存时间（单位小时）
kafka_msg_storage_hours=84
# admin账号密码，此密码将使用在zookeeper,及ranger,mysql的默认密码（请修改）
admin_user_pwd=aaBB@1122

###################### mysql 数据库信息
## 是否需要安装，如果已有mysql,则可修改为false,下面mysql的其它参数改为现有的数据库信息，如果需要安装，则为新库信息
mysql_need_install=true
mysql_host=192.168.56.10
mysql_port=3306
# 请修改默认密码
mysql_root_pwd=$admin_user_pwd

###################### ranger 相关信息，必需安装，所需数据库为：mysql_host
ranger_host=192.168.56.10
# 必须包含大小写特殊字符及数字, 否则将无法登录ranger的web-ui,
ranger_admin_pwd=Ranger@1122
# ranger数据库信息，如果mysql_need_install=true，则自动新建，否则需要提前创建
mysql_ranger_dbname=ranger
mysql_ranger_user=ranger
# mysql ranger数据库密码,默认使用统一的管理员密码，请修改
mysql_ranger_pwd=mysql@1122

###################### kafkaui相关信息
# 监控工具kafkaui安装在哪台服务器上,默认是排序后的第一台服务器，若想修改，请直接写死
kafkaui_need_install=true
# kafkaui安装在哪台服务器上，默认与mysql在同一台服务器，请修改
kafkaui_host=$mysql_host
# kafkaui的登录密码,默认使用统一的管理员密码，请修改
kafkaui_pwd=$admin_user_pwd


