installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

print_log warn "################# 检查kafkaui安装情况 #################"
## 如果 kafkaui已安装，则退出
[ $? -eq 1 ] && exit 0

kafkaui_host=`[ "$kafkaui_need_install" = "true" ] && echo "$kafkaui_host" || echo ''`

# 判断变更$kafkaui_host 是否为空，若为空，则退出
[ -z $kafkaui_host ] && print_log info "kafkaui未启动安装，退出，若需要安装，请设置 kafkaui_host_need_install=true" && exit 0

# 获取docker镜像包名称
KAFKAUI_FILE_NAME=`ls $installpath/packages/ | grep kafkaui | grep gz`
[ -z $KAFKAUI_FILE_NAME ] && print_log warn "kafkaui无离线安装包，将进行在线镜像拉取，请确保能访问外网，若需要离线安装，请参考readme.md,手动下载kafkaui安装包，放到packages目录" && sleep 3

print_log info "################# 安装与启动kafkaui #################"
function install_kafkaui(){
  ssh -p $ssh_port $kafkaui_host  "mkdir -p $DATA_DIR/kafkaui $BASE_PATH/kafkaui"
  [[ -f "$installpath/packages/${KAFKAUI_FILE_NAME}" ]] && scp -P $ssh_port $installpath/packages/${KAFKAUI_FILE_NAME} $kafkaui_host:$BASE_PATH/kafkaui/
  [[ -f "$installpath/packages/${KAFKAUI_FILE_NAME}" ]] && ssh -p $ssh_port $kafkaui_host "gunzip -c $BASE_PATH/kafkaui/${KAFKAUI_FILE_NAME} | docker load"
  [[ -f "$installpath/packages/${KAFKAUI_FILE_NAME}" ]] && ssh -p $ssh_port $kafkaui_host "rm -rf $BASE_PATH/kafkaui/${KAFKAUI_FILE_NAME}"

  broker_list=`echo "${!servers[@]}"| sed "s# #:$kafka_port,#g" | sed "s#\\$#:$kafka_port#g"`
  cat > /tmp/run.sh <<EOF
docker stop kafkaui
docker rm kafkaui
docker run --name kafkaui --restart=always \\
-p 8080:8080 \\
-e TZ=Asia/Shanghai \\
-e AUTH_TYPE=LOGIN_FORM \\
      -e SPRING_SECURITY_USER_NAME=admin \\
      -e SPRING_SECURITY_USER_PASSWORD='$kafkaui_pwd' \\
      -e DYNAMIC_CONFIG_ENABLED=true \\
      -e KAFKA_CLUSTERS_0_NAME=kafka-ha \\
      --ulimit nofile=65536:65536 \\
      -e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=$broker_list \\
      -e KAFKA_CLUSTERS_0_PROPERTIES_SECURITY_PROTOCOL=SASL_PLAINTEXT \\
      -e KAFKA_CLUSTERS_0_PROPERTIES_SASL_MECHANISM=PLAIN \\
      -e KAFKA_CLUSTERS_0_PROPERTIES_SASL_JAAS_CONFIG='org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="${ranger_admin_pwd}";' \\
-d provectuslabs/kafka-ui
echo "已提交了启动任务，马上进行日志查看，若启动完成或失败后，请ctrl+c退出"
sleep 2
docker logs -f kafkaui
EOF
chmod +x /tmp/run.sh
  scp -P $ssh_port /tmp/run.sh $kafkaui_host:$BASE_PATH/kafkaui/
  ssh -p $ssh_port $kafkaui_host  "sh $BASE_PATH/kafkaui/run.sh"
}

install_kafkaui
print_log info "kafkaui已安装启动,访问地址：http://$kafkaui_host:8080, 用户名/密码：admin/$kafkaui_pwd #################"
