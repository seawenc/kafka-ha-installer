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
# kafka消息生存时间（单位小时）
kafka_msg_storage_hours=84

# ldap相关信息(zookeeper也使用这个用户名密码)
ldap_user=admin
# 密码请 不要包含@和#号, 不要包含@和#号, 不要包含@和#号
ldap_pwd=aaBB@1122
ldap_host=172.26.15.144
ldap_port=389
ldap_base_dn='ou=app,dc=travelsky,dc=com'
ldap_name_format='cn=%s,ou=app,dc=travelsky,dc=com'

###################### mysql 数据库信息
## 是否需要安装，如果已有mysql,则可修改为false,下面mysql的其它参数改为现有的数据库信息，如果需要安装，则为新库信息
mysql_need_install=true
mysql_host=192.168.56.10
mysql_port=3306
mysql_root_pwd=root@1122

###################### ranger 相关信息，必需安装，所需数据库为：mysql_host
ranger_host=192.168.56.10
ranger_admin_pwd=aaBB@1122 # ranger管理员登录密码
# ranger数据库信息，如果mysql_need_install=true，则自动新建，否则需要提前创建
mysql_ranger_dbname=ranger
mysql_ranger_user=ranger
mysql_ranger_pwd=ranger@1122

###################### efak相关信息
# 监控工具efak安装在哪台服务器上,默认是排序后的第一台服务器，若想修改，请直接写死
efak_need_install=true
efak_host=$mysql_host # efak安装在哪台服务器上，默认与mysql在同一台服务器
# efak数据库信息，如果mysql_need_install=true，则自动新建，否则需要提前创建
mysql_efak_dbname=efak
mysql_efak_user=efak
mysql_efak_pwd=aaBB@1122

###################### nginx相关信息
# 监控工具efak安装在哪台服务器上,默认是排序后的第一台服务器，若想修改，请直接写死
nginx_need_install=true
nginx_domain="ada.com" # 基础域名，若使用默认配置,则ranger的域名为：ranger.ada.com, efak域名为：efak.ada.com
nginx_port=80

#efak数据库类型,值有：（若直接将efak.properties文件中直接将数据库信息写死，则可不用管以下参数）
#    local:使用本地数据库，不太稳定，可能会偶尔锁库，若使用此种模式，则以下其它配置则无效
#    mysql-auto: efak安装脚本，自动安装一个mysql
#    mysql-ext : 使用外部已有mysql
#efak_db_type=local
# 当 efak_db_type=mysql-auto时，mysql安装在哪一台服务器，默认是排序后的第二台，若想修改，请直接写死，其它类型时，此配置无效
#efak_db_ip=`echo ${!servers[*]} | tr " " "\n" | sort | head -2 | tail -1`
# 以下三个参数在efak_db_type!=local时生效
#efak_db_jdbc=jdbc:mysql://${efak_db_ip}:33306/efak?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
#efak_db_user=efak
#efak_db_pwd=aaBB1122
##############################################################

