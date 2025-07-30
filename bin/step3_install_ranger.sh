installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

print_log info "################# 安装与启动ranger #################"
function install_ranger(){
  ssh -p $ssh_port $ranger_host  "rm -rf $BASE_PATH/ranger/*"
  # 准备镜像
  # 获取docker镜像包名称
  RANGER_FILE_NAME=`ls $installpath/packages/ | grep ranger | grep gz`
  [ -z $RANGER_FILE_NAME ] && print_log warn "ranger无离线安装包，将进行在线镜像拉取，请确保能访问外网，若需要离线安装，请参考readme.md,手动下载ranger安装包，放到packages目录" && sleep 1

  ssh -p $ssh_port $ranger_host  "mkdir -p $DATA_DIR/ranger $BASE_PATH/ranger"
  [[ -f "$installpath/packages/${RANGER_FILE_NAME}" ]] && scp -P $ssh_port $installpath/packages/${RANGER_FILE_NAME} $ranger_host:$BASE_PATH/ranger/
  [[ -f "$installpath/packages/${RANGER_FILE_NAME}" ]] && print_log info "镜像加载中,请等待..." && ssh -p $ssh_port $ranger_host "gunzip -c $BASE_PATH/ranger/${RANGER_FILE_NAME} | docker load"
  [[ -f "$installpath/packages/${RANGER_FILE_NAME}" ]] && ssh -p $ssh_port $ranger_host "rm -rf $BASE_PATH/ranger/${RANGER_FILE_NAME}"

  # 准备配置文件
  cat $installpath/conf/ranger-install.properties > /tmp/install.properties
  sed -i "s/--MYSQL_HOST--/$mysql_host/g" /tmp/install.properties
  sed -i "s/--MYSQL_PORT--/$mysql_port/g" /tmp/install.properties
  sed -i "s/--RANGER_ADMIN_PWD--/$ranger_admin_pwd/g" /tmp/install.properties
  sed -i "s/--RANGER_DBNAME--/$mysql_ranger_dbname/g" /tmp/install.properties
  sed -i "s/--RANGER_DBUSER--/$mysql_ranger_user/g" /tmp/install.properties
  sed -i "s/--RANGER_DBPWD--/$mysql_ranger_pwd/g" /tmp/install.properties
  scp -P $ssh_port /tmp/install.properties $ranger_host:$BASE_PATH/ranger/
  # 原ranger-kafka插件只支持kerberos认证，以下为修复后的包
  scp -P $ssh_port $installpath/plugin-auth/ranger/ranger-kafka-plugin-2.5.0.jar $ranger_host:$BASE_PATH/ranger/

  scp -P $ssh_port /tmp/install.properties $ranger_host:$BASE_PATH/ranger/

  #准备启动脚本
  cat > /tmp/run.sh <<EOF
  docker stop ranger && docker rm -f ranger
  docker run -d --name=ranger --restart=always \\
       --net=host --hostname=ranger \\
      -v $BASE_PATH/ranger/install.properties:/opt/app/ranger-admin/install.properties \\
      -v $BASE_PATH/ranger/ranger-kafka-plugin-2.5.0.jar:/opt/app/ranger-admin/ews/webapp/WEB-INF/classes/ranger-plugins/kafka/ranger-kafka-plugin-2.5.0.jar \\
      --ulimit nofile=65536:65536 \\
      dockeropen.x/bigdata/ranger:2.5.0.2
  docker logs -f ranger
EOF
  chmod +x /tmp/run.sh
  scp -P $ssh_port /tmp/run.sh $ranger_host:$BASE_PATH/ranger/
  # 启动ranger查看日志
  print_log info '马上进行日志查看，若出现错误，或者打印出:Starting ProtocolHandler ["http-nio-6080"],则可退ctrl+c出安装' && sleep 2
  ssh -p $ssh_port $ranger_host  "sh $BASE_PATH/ranger/run.sh"
  print_log info "若未报错，请在浏览器上登录 http://$ranger_host:6080/ 输入账号密码：admin/$ranger_admin_pwd"
}

install_ranger
print_log info "################# ranger已安装,并在启动中, 请查看安装日志： ssh -p $ssh_port $ranger_host  'docker logs -f ranger'  #################"
