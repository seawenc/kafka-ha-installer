installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

print_log warn "################# 检查mysql安装情况 #################"
sh $installpath/bin/check_mysql.sh
## 如果 mysql已安装，则退出
[ $? -eq 1 ] && exit 0

MYSQL_HOST=`[ "$mysql_need_install" = "true" ] && echo "$mysql_host" || echo ''`

# 判断变更$MYSQL_HOST 是否为空，若为空，则退出
[ -z $MYSQL_HOST ] && print_log info "mysql未启动安装，退出，若需要安装，请设置 mysql_need_install=true" && exit 0

# 获取docker镜像包名称
MYSQL_FILE_NAME=`ls $installpath/packages/ | grep mysql | grep gz`
[ -z $MYSQL_FILE_NAME ] && print_log warn "mysql无离线安装包，将进行在线镜像拉取，请确保能访问外网，若需要离线安装，请参考readme.md,手动下载mysql安装包，放到packages目录" && sleep 3

print_log info "################# 安装与启动mysql #################"
function install_mysql(){
  ssh -p $ssh_port $MYSQL_HOST  "mkdir -p $DATA_DIR/mysql $BASE_PATH/mysql"
  [[ -f "$installpath/packages/${MYSQL_FILE_NAME}" ]] && scp -P $ssh_port $installpath/packages/${MYSQL_FILE_NAME} $MYSQL_HOST:$BASE_PATH/mysql/
  [[ -f "$installpath/packages/${MYSQL_FILE_NAME}" ]] && ssh -p $ssh_port $MYSQL_HOST "gunzip -c $BASE_PATH/mysql/${MYSQL_FILE_NAME} | docker load"
  [[ -f "$installpath/packages/${MYSQL_FILE_NAME}" ]] && ssh -p $ssh_port $MYSQL_HOST "rm -rf $BASE_PATH/mysql/${MYSQL_FILE_NAME}"

  cat > /tmp/run.sh <<EOF
docker stop mysql
docker rm mysql
docker run --name mysql --restart=always \\
-p ${mysql_port}:3306 \\
-e MYSQL_ROOT_PASSWORD=${mysql_root_pwd} \\
-e TZ=Asia/Shanghai \\
-e MYSQL_DATABASE=$mysql_ranger_dbname \\
-e MYSQL_USER=$mysql_ranger_user \\
-e MYSQL_PASSWORD=$mysql_ranger_pwd \\
-v $DATA_DIR/mysql:/var/lib/mysql \\
-d mysql \\
--character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
EOF
chmod +x /tmp/run.sh
  scp -P $ssh_port /tmp/run.sh $MYSQL_HOST:$BASE_PATH/mysql/
  ssh -p $ssh_port $MYSQL_HOST  "sh $BASE_PATH/mysql/run.sh"
}

install_mysql
print_log info "################# mysql已安装启动,并已新建好ranger数据库 #################"
