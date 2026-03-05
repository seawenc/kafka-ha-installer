# kafka4.x单机模式

**此方案需要提依赖[docker-compose](https://github.com/docker/compose/releases)**, 在此页面进行下载,下载完成后，将其放到`/usr/local/bin/` 下

## 文件准备

## docker-compose.yml
```yaml
services:
  kafka:
    image: apache/kafka:4.1.1
    container_name: kafka
    hostname: kafka
    ports:
      - "9092:9092"
      - "9093:9093"
    volumes:
      - ./conf/server.properties:/opt/kafka/config/kafka.properties
      - ./conf/kafka_server_jaas.conf:/opt/kafka/config/kafka_server_jaas.conf
      - ./bin/start.sh:/opt/kafka/start.sh:ro
      - ./logs:/opt/kafka/logs
      - ./data:/data
    environment:
      KAFKA_OPTS: "-Djava.security.auth.login.config=/opt/kafka/config/kafka_server_jaas.conf"
    command: ["/opt/kafka/start.sh"]
```

### bin/start.sh

```bash
#!/bin/bash

set -e

CONFIG="/opt/kafka/config/kafka.properties"
LOG_DIR="/data"

# 创建必要的客户端配置文件
cat > /tmp/client.conf << EOF
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
    username="admin" \
    password="admin-secret";
EOF

if [ ! -f "$LOG_DIR/meta.properties" ]; then
  echo "[$(date)] Formatting Kafka storage with new cluster ID..."
  CLUSTER_ID=$(/opt/kafka/bin/kafka-storage.sh random-uuid)
  /opt/kafka/bin/kafka-storage.sh format -t "$CLUSTER_ID" -c "$CONFIG"
  echo "[$(date)] Storage formatted with cluster ID: $CLUSTER_ID"
fi

echo "[$(date)] Starting Kafka server..."
exec /opt/kafka/bin/kafka-server-start.sh "$CONFIG"
```

### conf/server.properties
```properties
# === KRaft核心配置（单节点）===
process.roles=broker,controller
node.id=1
controller.quorum.voters=1@localhost:9091
controller.listener.names=CONTROLLER

# === 监听器配置（保留你的双IP）===
listeners=CONTROLLER://0.0.0.0:9091,INTERNAL://0.0.0.0:9093,EXTERNAL://0.0.0.0:9092
advertised.listeners=INTERNAL://{内网IP}:9093,EXTERNAL://{外网IP}:9092
listener.security.protocol.map=CONTROLLER:SASL_PLAINTEXT,INTERNAL:SASL_PLAINTEXT,EXTERNAL:SASL_PLAINTEXT

# === SASL/PLAIN认证 ===
sasl.enabled.mechanisms=PLAIN
sasl.mechanism.inter.broker.protocol=PLAIN
inter.broker.listener.name=INTERNAL

# 控制器SASL配置
controller.listener.security.protocol=SASL_PLAINTEXT
sasl.mechanism.controller.protocol=PLAIN

# === 【简化版】ACL配置 - admin拥有所有权限 ===
authorizer.class.name=org.apache.kafka.metadata.authorizer.StandardAuthorizer
authorizer.standard.enable.acl=true

# 【关键】允许所有用户（实际上所有客户端都使用admin账号）
authorizer.standard.allow.everyone.if.no.acl.found=true

# 超级用户（拥有所有权限）
super.users=User:admin

# KRaft特殊配置：豁免admin的ACL检查
metadata.authorizer.acl.exempt.principals=User:admin

# === 单节点特有配置 ===
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
default.replication.factor=1
num.partitions=3

# 内部主题配置
offsets.topic.num.partitions=50
group.initial.rebalance.delay.ms=0

# === 数据目录 ===
log.dirs=/data

# === 网络配置 ===
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
```
> 请替换`{内网IP}`和`{外网IP}`为实际IP

### conf/kafka_server_jaas.conf
```conf
KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="admin"
    password="{admin密码}"
    user_admin="{admin密码}"
    user_{用户1名}={用户1密码}"
    user_{用户2名}={用户2密码}";
};
Client {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="admin"
    password="{admin密码}";
};
```
> 请替换以上的变量

### run.sh
```bash
if [ ! -d "./data" ]; then
    echo -e "[WARN] data 目录不存在，创建目录,并初始化..."
    mkdir -p ./data && sudo chown -R 1000:1000 ./data && sudo chmod -R 755 ./data
    mkdir -p ./logs && sudo chown -R 1000:1000 ./logs && sudo chmod -R 755 ./logs
fi

docker-compose stop
docker-compose rm -f
docker-compose up -d
sleep 3
docker logs -n 100 kafka
echo "继续查看日志，使用指令：docker logs -n 100 -f kafka"
```


## bin/kafkaui.sh

```bash
docker stop kafkaui
docker rm kafkaui
docker run --name kafkaui --restart=always \
-p 8080:8080 \
-e TZ=Asia/Shanghai \
-e AUTH_TYPE=LOGIN_FORM \
      -e SPRING_SECURITY_USER_NAME=admin \
      -e SPRING_SECURITY_USER_PASSWORD='{kafkaui密码}' \
      -e DYNAMIC_CONFIG_ENABLED=true \
      -e KAFKA_CLUSTERS_0_NAME=kafka-ha \
      --ulimit nofile=65536:65536 \
      -e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS={内网IP}:9093 \
      -e KAFKA_CLUSTERS_0_PROPERTIES_SECURITY_PROTOCOL=SASL_PLAINTEXT \
      -e KAFKA_CLUSTERS_0_PROPERTIES_SASL_MECHANISM=PLAIN \
      -e KAFKA_CLUSTERS_0_PROPERTIES_SASL_JAAS_CONFIG='org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="{kafka密码}";' \
-d provectuslabs/kafka-ui
echo "已提交了启动任务，马上进行日志查看，若启动完成或失败后，请ctrl+c退出"
sleep 2
docker logs -f kafkaui
```



## 启动kafka
```bash
chmod +x run.sh
chmod +x bin/start.sh
chmod +x bin/kafkaui.sh
# 启动
sh run.sh
# 启动kafka ui
sh bin/kafkaui.sh
```
> 启动成功后，可以通过`docker logs kafka`查看启动日志

登录kafkaui查看kafka是否正常： http://{内网IP}:8080





