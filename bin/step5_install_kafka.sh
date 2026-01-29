installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

# 公共函数：传输并导入 Kafka 镜像
function transfer_and_import_kafka_image() {
  local target_ip=$1
  local package_path=$2

  # 判断本地是否存在 kafka.gz 镜像包
  if [[ -f "$package_path" ]]; then
    echo "检测到本地存在 kafka.gz 镜像包，检查远程服务器是否已存在该镜像..."
    # 检查远程服务器是否已有该镜像（通过镜像名称或标签判断）
    local image_exists=$(ssh -p $ssh_port $target_ip "docker images | grep 'apache/kafka' | wc -l")
    if [[ $image_exists -eq 0 ]]; then
      echo "远程服务器未找到 kafka 镜像，开始传输并导入..."
      scp -P $ssh_port $package_path $target_ip:/tmp/
      ssh -p $ssh_port $target_ip "gunzip -c /tmp/kafka.gz | docker load"
      ssh -p $ssh_port $target_ip "rm -rf /tmp/kafka.gz"
    else
      echo "远程服务器已存在 kafka 镜像，跳过传输和导入步骤。"
    fi
  else
    echo "本地未找到 kafka.gz 镜像包，请确认文件路径和名称是否正确。"
  fi
}

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
  transfer_and_import_kafka_image "$ip" "$installpath/packages/kafka.gz"

  # 设置配置文件中的变量
  scp -r -P $ssh_port $installpath/conf/kafka/* $ip:$BASE_PATH/kafka/
  ssh -p $ssh_port $ip "sed -i 's/_KAFKA_PWD_/${admin_user_pwd}/g' $BASE_PATH/kafka/conf/jaas.conf"
  
  ssh -p $ssh_port $ip "sed -i 's@_DATA_DIR_@${DATA_DIR}@g' $BASE_PATH/kafka/docker-compose.yml"
  ssh -p $ssh_port $ip "sed -i 's@_servers_@${CLIENT_SERVERS}@g' $BASE_PATH/kafka/docker-compose.yml"
  
  ssh -p $ssh_port $ip "sed -i 's/_KAFKA_PWD_/${admin_user_pwd}/g' $BASE_PATH/kafka/conf/client.properties"
  ssh -p $ssh_port $ip "sed -i 's/_servers_/${CLIENT_SERVERS}/g' $BASE_PATH/kafka/conf/client.properties"
  
  ssh -p $ssh_port $ip "sed -i 's/_nodeId_/${FOR_SEQ}/g' $BASE_PATH/kafka/conf/server.properties"
  ssh -p $ssh_port $ip "sed -i 's/_ip_/${ip}/g' $BASE_PATH/kafka/conf/server.properties"
  ssh -p $ssh_port $ip "sed -i 's/_extIp_/${servers[$ip]}/g' $BASE_PATH/kafka/conf/server.properties"
  ssh -p $ssh_port $ip "sed -i 's/_CLUSTER_SERVERS_/${CLUSTER_SERVERS}/g' $BASE_PATH/kafka/conf/server.properties"

  # 初始化ranger相关组件
#   ssh -p $ssh_port $ip  "mkdir -p $BASE_PATH/kafka/libs $BASE_PATH/kafka/bin"
#   scp -P $ssh_port $installpath/plugin-auth/build/libs/plugin-auth-1.0.jar $ip:$BASE_PATH/kafka/libs/
#   scp -P $ssh_port $installpath/plugin-auth/ranger/ranger-2.5.0-kafka-plugin.tar.gz $ip:$BASE_PATH/kafka/libs/
#   ssh -p $ssh_port $ip "cd $BASE_PATH/kafka/libs && tar -xzf ranger-2.5.0-kafka-plugin.tar.gz && mv ranger-2.5.0-kafka-plugin ranger-kafka-plugin && rm -rf *kafka-plugin.tar.gz"
#   ssh -p $ssh_port $ip "sed 's@POLICY_MGR_URL=@POLICY_MGR_URL=http://${ranger_host}:6080@g' -i $BASE_PATH/kafka/libs/ranger-kafka-plugin/install.properties"
#   ssh -p $ssh_port $ip "sed 's@REPOSITORY_NAME=@REPOSITORY_NAME=kafka-ha-policy@g' -i $BASE_PATH/kafka/libs/ranger-kafka-plugin/install.properties"
#   ssh -p $ssh_port $ip "sed 's@COMPONENT_INSTALL_DIR_NAME=@COMPONENT_INSTALL_DIR_NAME=/opt/bitnami/kafka/@g' -i $BASE_PATH/kafka/libs/ranger-kafka-plugin/install.properties"
#   ssh -p $ssh_port $ip "chmod 777 -R $BASE_PATH/kafka"

  #此entrypoint.sh加入了插件安装脚本
  # jmx配置
  #scp -r -P $ssh_port $installpath/bin/kafka-internal/ $ip:$BASE_PATH/kafka/bin/

  #ssh -p $ssh_port $ip "sed 's@--IP--@$ip@g' -i $BASE_PATH/kafka/bin/jmx/management.properties"
  
  echo "文件配置完成，开始启动"
  # --------
  ssh -p $ssh_port $ip "sh $BASE_PATH/kafka/run.sh"
  print_log info "等待节点启动(10s)..."

  print_log info "查看日志："
  print_log info "ssh -p $ssh_port $ip 'docker logs -f kafka'"
done
}

install_kafka
print_log info "#################第三步:等待kafka启动（10s刷新一次） ###############################"
watch -d -n 10 bash $installpath/bin/check_kafka.sh

print_log warn "若此集群第一次启动失败，可试试执行脚本 bin/start_kafka.sh"
print_log warn "请手动在其中两台服务器，执行以下指令进入容器后进行测试可用性"
print_log info "docker exec -ti kafka bash"
print_log info "新建topic： test，设置分区数据为3,副本数为2"
print_log info 'kafka-topics.sh --create --bootstrap-server $SERVERS --topic test --partitions 3 --replication-factor 2 --command-config /client.properties'
print_log info "测试消息生产者与消费者"
print_log info 'kafka-console-producer.sh --bootstrap-server $SERVERS --topic test --producer.config /client.properties'
print_log info 'kafka-console-consumer.sh --bootstrap-server $SERVERS --topic test --consumer.config /client.properties'
