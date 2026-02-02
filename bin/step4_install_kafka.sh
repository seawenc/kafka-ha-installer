installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

check_docker_compose

print_log warn "#################第三步:安装kafka ###############################"
print_log info "#################第三步:1.关停已启动的kafka ###############################"
bash $installpath/bin/stop_kafka.sh
print_log info "#################第三步:2.安装与启动kafka ###############################"
function install_kafka(){
CLUSTER_SERVERS=`cat ../conf/config.sh| grep 'servers\["' | sort | awk -F '"' '{print NR"@"$2":9091"}'| tr "\n" "," | sed 's/.$//'`
CLIENT_SERVERS=`cat ../conf/config.sh| grep 'servers\["' | sort | awk -F '"' '{print $2":9093"}'| tr "\n" "," | sed 's/.$//'`
echo "CLUSTER_SERVERS=$CLUSTER_SERVERS"
for ip in `echo ${!servers[*]} | tr " " "\n" | sort` 
do
  let FOR_SEQ+=1
  print_log warn "2.1.在$ip 节点安装kafka,当前序号：$FOR_SEQ"
  # 初始化目录
  ssh -p $ssh_port $ip  "rm -rf $BASE_PATH/kafka/* && mkdir -p $DATA_DIR/kafka $BASE_PATH/kafka && chown -R 1000:1000 $DATA_DIR/kafka && chmod -R 777 $DATA_DIR/kafka"

  # 同步镜像
  transfer_and_import_image "$ip" "apache/kafka" "kafka.gz"

  # 在本机 /tmp 目录中创建临时工作目录
  TMP_DIR="/tmp/kafka_config_$ip"
  mkdir -p  $TMP_DIR && rm -rf $TMP_DIR/*
  # 将配置文件复制到本机临时目录
  cp -r $installpath/conf/kafka/* $TMP_DIR/
  # 在本机修改配置文件
  sed -i "s@_DATA_DIR_@${DATA_DIR}@g" $TMP_DIR/docker-compose.yml
  sed -i "s@_servers_@${CLIENT_SERVERS}@g" $TMP_DIR/docker-compose.yml
  sed -i "s@_ranger_host_@${ranger_host}@g" $TMP_DIR/docker-compose.yml
  
  sed -i "s/_KAFKA_PWD_/${admin_user_pwd}/g" $TMP_DIR/conf/jaas.conf
  sed -i "s/_KAFKA_PWD_/${admin_user_pwd}/g" $TMP_DIR/conf/client.properties
  sed -i "s/_servers_/${CLIENT_SERVERS}/g" $TMP_DIR/conf/client.properties
  
  sed -i "s/_nodeId_/${FOR_SEQ}/g" $TMP_DIR/conf/server.sh
  sed -i "s/_ip_/${ip}/g" $TMP_DIR/conf/server.sh
  sed -i "s/_extIp_/${servers[$ip]}/g" $TMP_DIR/conf/server.sh
  sed -i "s/_CLUSTER_SERVERS_/${CLUSTER_SERVERS}/g" $TMP_DIR/conf/server.sh
  sed -i "s/_kafka_msg_storage_hours_/${kafka_msg_storage_hours}/g" $TMP_DIR/conf/server.sh
  sed -i "s/_ranger_host_/${ranger_host}/g" $TMP_DIR/run.sh
  
  # 初始化 ranger 相关组件（在本机完成）
  mkdir -p $TMP_DIR/libs $TMP_DIR/bin
  (
    cd $TMP_DIR/libs
    tar -xzf ranger-2.5.0-kafka-plugin.tar.gz
    mv ranger-2.5.0-kafka-plugin ranger-kafka-plugin
    rm -rf *kafka-plugin.tar.gz
    cp fix/* ranger-kafka-plugin/install/lib/
  )
  sed -i "s@POLICY_MGR_URL=@POLICY_MGR_URL=http://${ranger_host}:6080@g" $TMP_DIR/libs/ranger-kafka-plugin/install.properties
  sed -i "s@REPOSITORY_NAME=@REPOSITORY_NAME=kafka-ha-policy@g" $TMP_DIR/libs/ranger-kafka-plugin/install.properties
  sed -i "s@COMPONENT_INSTALL_DIR_NAME=@COMPONENT_INSTALL_DIR_NAME=/opt/kafka/@g" $TMP_DIR/libs/ranger-kafka-plugin/install.properties
  
  # 将修改后的配置文件 scp 到目标服务器
  scp -q -r -P $ssh_port $TMP_DIR/* $ip:$BASE_PATH/kafka/
  # 清理本机临时目录
  rm -rf $TMP_DIR

  ssh -p $ssh_port $ip "chmod 777 -R $BASE_PATH/kafka"
done
}

install_kafka
print_log info "所有服务初始化已完成，开始启动服务..."
sh start_kafka.sh

print_log warn "若此集群第一次启动失败，可试试执行脚本 bin/start_kafka.sh"
print_log warn "请手动在其中两台服务器，执行以下指令进入容器后进行测试可用性"
print_log info "docker exec -ti kafka bash"
print_log info "新建topic： test，设置分区数据为3,副本数为2"
print_log info 'kafka-topics.sh --create --bootstrap-server $SERVERS --topic test --partitions 3 --replication-factor 2 --command-config /client.properties'
print_log info "测试消息生产者与消费者"
print_log info 'kafka-console-producer.sh --bootstrap-server $SERVERS --topic test --producer.config /client.properties'
print_log info 'kafka-console-consumer.sh --bootstrap-server $SERVERS --topic test --consumer.config /client.properties'
