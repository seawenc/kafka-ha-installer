installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

print_log warn "#################第三步:安装kafka ###############################"
print_log info "#################第三步:1.关停已启动的kafka ###############################"
bash $installpath/bin/stop_kafka.sh
print_log info "暂停10秒，等待kafka stop状态刷新到zookeeper中"
sleep 10
print_log info "#################第三步:2.安装与启动kafka ###############################"
function install_kafka(){
ZOO_SERVERS=`cat $installpath/conf/config.sh| grep 'servers\["' | sort | awk -F '"' '{print $2":2181"}'| tr "\n" "," | sed 's/.$//'`
FOR_SEQ=1
for ip in `echo ${!servers[*]} | tr " " "\n" | sort` 
do
  print_log warn "2.1.在$ip 节点安装kafka"
  # 初始化目录
  ssh -p $ssh_port $ip  "rm -rf $BASE_PATH/kafka/* && mkdir -p $DATA_DIR/kafka $BASE_PATH/kafka && chmod 777 $DATA_DIR/kafka"
  ssh -p $ssh_port $ip  "ls $BASE_PATH/kafka/"

  echo "判断packages文件下是否有镜像包，如果有，则自动导入..."
  [[ -f "$installpath/packages/kafka.gz" ]] && scp -P $ssh_port $installpath/packages/kafka.gz $ip:$BASE_PATH/kafka/
  [[ -f "$installpath/packages/kafka.gz" ]] && ssh -p $ssh_port $ip "gunzip -c $BASE_PATH/kafka/kafka.gz | docker load"
  [[ -f "$installpath/packages/kafka.gz" ]] && ssh -p $ssh_port $ip "rm -rf $BASE_PATH/kafka/kafka.gz"

  # 初始化jaas.conf
  scp -P $ssh_port $installpath/conf/jaas.conf $ip:$BASE_PATH/kafka/
  ssh -p $ssh_port $ip "sed -i 's/@ZKKPWD@/${admin_user_pwd}/g' $BASE_PATH/kafka/jaas.conf"

  # 初始化ranger相关组件
  ssh -p $ssh_port $ip  "mkdir -p $BASE_PATH/kafka/libs $BASE_PATH/kafka/bin"
  scp -P $ssh_port $installpath/plugin-auth/build/libs/plugin-auth-1.0.jar $ip:$BASE_PATH/kafka/libs/
  scp -P $ssh_port $installpath/plugin-auth/ranger/ranger-2.5.0-kafka-plugin.tar.gz $ip:$BASE_PATH/kafka/libs/
  ssh -p $ssh_port $ip "cd $BASE_PATH/kafka/libs && tar -xzf ranger-2.5.0-kafka-plugin.tar.gz && mv ranger-2.5.0-kafka-plugin ranger-kafka-plugin && rm -rf *kafka-plugin.tar.gz"
  ssh -p $ssh_port $ip "sed 's@POLICY_MGR_URL=@POLICY_MGR_URL=http://${ranger_host}:6080@g' -i $BASE_PATH/kafka/libs/ranger-kafka-plugin/install.properties"
  ssh -p $ssh_port $ip "sed 's@REPOSITORY_NAME=@REPOSITORY_NAME=kafka-ha-policy@g' -i $BASE_PATH/kafka/libs/ranger-kafka-plugin/install.properties"
  ssh -p $ssh_port $ip "sed 's@COMPONENT_INSTALL_DIR_NAME=@COMPONENT_INSTALL_DIR_NAME=/opt/bitnami/kafka/@g' -i $BASE_PATH/kafka/libs/ranger-kafka-plugin/install.properties"

  #此entrypoint.sh加入了插件安装脚本
  # jmx配置
  scp -r -P $ssh_port $installpath/bin/kafka-internal/ $ip:$BASE_PATH/kafka/bin/
  ssh -p $ssh_port $ip "sed 's@--IP--@$ip@g' -i $BASE_PATH/kafka/bin/kafka-internal/jmx/management.properties"

  ## 启动kafka 
  print_log info "开始启动$ip 的kafka"
  cat > /tmp/run.sh <<EOF
docker stop kafka
docker rm kafka
docker run --name kafka -d --restart=unless-stopped \\
           -e ALLOW_PLAINTEXT_LISTENER=yes \\
           -e KAFKA_BROKER_ID=${FOR_SEQ} \\
           -e KAFKA_MESSAGE_MAX_BYTES=100001200 \\
           --net=host \\
           -e KAFKA_CFG_ALLOW_EVERYONE_IF_NO_ACL_FOUND=false \\
           -e KAFKA_CFG_SUPER_USERS=User:admin \\
           -e KAFKA_CFG_AUTHORIZER_CLASS_NAME=org.apache.ranger.authorization.kafka.authorizer.RangerKafkaAuthorizer \\
           -e KAFKA_CFG_ZOOKEEPER_CONNECT=${ZOO_SERVERS} \\
           -e KAFKA_CFG_ADVERTISED_LISTENERS=BROKER://${ip}:${kafka_port_broker},CLIENT://${ip}:${kafka_port},EXTERNAL://${servers[$ip]}:${kafka_port_outside} \\
           -e KAFKA_CFG_LISTENERS=BROKER://0.0.0.0:${kafka_port_broker},CLIENT://0.0.0.0:${kafka_port},EXTERNAL://0.0.0.0:${kafka_port_outside} \\
           -e KAFKA_CFG_INTER_BROKER_LISTENER_NAME=BROKER \\
           -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=BROKER:SASL_PLAINTEXT,CLIENT:SASL_PLAINTEXT,EXTERNAL:SASL_PLAINTEXT \\
           -e KAFKA_CFG_SASL_ENABLED_MECHANISMS=PLAIN \\
           -e JMX_PORT="9999" \\
           -e KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN \\
           -e KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN \\
           -e KAFKA_CFG_MAX_PARTITION_FETCH_BYTES=10485760 \\
           -e KAFKA_CFG_MAX_REQUEST_SIZE=10485760 \\
           -e KAFKA_INTER_BROKER_LISTENER_NAME=BROKER \\
           -e KAFKA_ZOOKEEPER_PROTOCOL=SASL \\
           -e KAFKA_ZOOKEEPER_USER=admin \\
           -e KAFKA_ZOOKEEPER_PASSWORD=${admin_user_pwd} \\
           -v ${BASE_PATH}/kafka/jaas.conf:/opt/bitnami/kafka/config/kafka_jaas.conf \\
           -e KAFKA_OPTS="-Djava.security.auth.login.config=/opt/bitnami/kafka/config/kafka_jaas.conf" \\
              -e KAFKA_CFG_AUTHZ_RANGER_HOST=${ranger_host} \\
              -v $BASE_PATH/kafka/libs/plugin-auth-1.0.jar:/opt/bitnami/kafka/libs/plugin-auth-1.0.jar \\
              -e KAFKA_CFG_LISTENER_NAME_EXTERNAL_PLAIN_SASL_SERVER_CALLBACK_HANDLER_CLASS=ranger.RangerAuthenticateCallbackHandler \\
              -e KAFKA_CFG_LISTENER_NAME_CLIENT_PLAIN_SASL_SERVER_CALLBACK_HANDLER_CLASS=ranger.RangerAuthenticateCallbackHandler \\
              -e KAFKA_CFG_LISTENER_NAME_EXTERNAL_PLAIN_SASL_JAAS_CONFIG='org.apache.kafka.common.security.plain.PlainLoginModule required ;' \\
              -e KAFKA_CFG_LISTENER_NAME_CLIENT_PLAIN_SASL_JAAS_CONFIG='org.apache.kafka.common.security.plain.PlainLoginModule required ;' \\
           -e KAFKA_CFG_ADVERTISED_HOST_NAME=${ip} \\
           -e KAFKA_CFG_LOG_RETENTION_HOURS=${kafka_msg_storage_hours} \\
           -e KAFKA_CFG_LOG_CLEANUP_POLICY=delete \\
           -e RANGER_CONF_PATH=/opt/bitnami/kafka/config/ \\
           -v ${DATA_DIR}/kafka:/bitnami/kafka \\
           -v ${BASE_PATH}/kafka/libs/ranger-kafka-plugin:/opt/ranger-kafka-plugin \\
           -u root \\
           -v ${BASE_PATH}/kafka/bin/kafka-internal/entrypoint.sh:/opt/bitnami/scripts/kafka/entrypoint.sh \\
           -v ${BASE_PATH}/kafka/bin/kafka-internal/jmx:/opt/bitnami/kafka/bin/kafka-internal/jmx \\
            bitnami/kafka:3.9.0
            # 调试时用：  -e KAFKA_DEBUG=TRUE -e JAVA_DEBUG_PORT=0.0.0.0:5555 \\
            # 开启jmx: -e KAFKA_JMX_OPTS="-Dcom.sun.management.config.file=/opt/bitnami/kafka/bin/kafka-internal/jmx/management.properties" \\
            # java.rmi.ConnectException: Connection refused to host: 127.0.2.1; nested exception
EOF
  chmod +x /tmp/run.sh
  scp -P $ssh_port /tmp/run.sh $ip:$BASE_PATH/kafka/

  ssh -p $ssh_port $ip "sh $BASE_PATH/kafka/run.sh"
  sleep 3
  # 将用户名与密码，写到文件，不然指令无法使用
  ssh -p $ssh_port $ip "docker exec kafka sh -c \"sed 's/username=\\\"user\\\" password=\\\"bitnami\\\"/username=\\\"admin\\\" password=\\\"${ranger_admin_pwd}\\\"/g' -i /opt/bitnami/kafka/config/producer.properties\""
  ssh -p $ssh_port $ip "docker exec kafka sh -c \"sed 's/username=\\\"user\\\" password=\\\"bitnami\\\"/username=\\\"admin\\\" password=\\\"${ranger_admin_pwd}\\\"/g' -i /opt/bitnami/kafka/config/consumer.properties\""
  #ssh -p $ssh_port $ip "cat $BASE_PATH/kafka/run.sh"
  let FOR_SEQ+=1 
  print_log info "查看日志："
  print_log info "ssh -p $ssh_port $ip 'docker logs -f kafka'"
done
}
           #-v ${BASE_PATH}/kafka/jaas.conf:/opt/bitnami/kafka/config/kafka_jaas.conf \
           #-e KAFKA_OPTS=\"-Djava.security.auth.login.config=/opt/bitnami/kafka/config/kafka_jaas.conf\" \

install_kafka
print_log info "#################第三步:等待kafka启动 ###############################"
watch -d -n 5 bash $installpath/bin/check_kafka.sh

broker_list=`echo "${!servers[@]}"| sed "s# #:$kafka_port,#g" | sed "s#\\$#:$kafka_port#g"`
print_log warn "请手动在其中两台服务器，执行以下指令进入容器后进行测试可用性"
print_log info "docker exec -ti kafka bash"
print_log info "新建topic： test，设置分区数据为3,副本数为2"
print_log info "KAFKA_JMX_OPTS="" JMX_PORT=9955 kafka-topics.sh --create --bootstrap-server $broker_list --topic test --partitions 3 --replication-factor 2 --command-config /opt/bitnami/kafka/config/producer.properties"
print_log info "测试消息生产者与消费者"
print_log info "KAFKA_JMX_OPTS="" JMX_PORT=9955 kafka-console-producer.sh --bootstrap-server $broker_list --topic test --producer.config /opt/bitnami/kafka/config/producer.properties"
print_log info "KAFKA_JMX_OPTS="" JMX_PORT=9955 kafka-console-consumer.sh --bootstrap-server $broker_list --topic test --consumer.config /opt/bitnami/kafka/config/consumer.properties"
