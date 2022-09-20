# 未授权方案

## docker-daemon
> 几台服务器docker配置不统一，造成无法访问，
```json
{
  "bip": "192.168.255.1/24",
  "data-root": "/opt/app/docker",
  "registry-mirrors":["https://docker.mirrors.ustc.edu.cn"]
}
```

## zookeeper
```shell script
docker rm -f zookeeper
# 192.168.56.11
docker run --name zookeeper -ti -d            --restart=unless-stopped            -p 2181:2181 -p 2888:2888 -p 3888:3888            -e ZOO_CFG_EXTRA="quorumListenOnAllIPs=true"            -e JVMFLAGS="-Dzookeeper.electionPortBindRetry=50"            -v /opt/app/zkafka/data/zookeeper:/data            -v /opt/app/zkafka/data/zookeeper/logs:/logs            -e ZOO_MY_ID=1            -e ZOO_SERVERS="server.1=192.168.56.11:2888:3888;2181 server.2=192.168.56.12:2888:3888;2181 server.3=192.168.56.13:2888:3888;2181"             zookeeper:3.6.3
# 192.168.56.12
docker run --name zookeeper -ti -d            --restart=unless-stopped            -p 2181:2181 -p 2888:2888 -p 3888:3888            -e ZOO_CFG_EXTRA="quorumListenOnAllIPs=true"            -e JVMFLAGS="-Dzookeeper.electionPortBindRetry=50"            -v /opt/app/zkafka/data/zookeeper:/data            -v /opt/app/zkafka/data/zookeeper/logs:/logs            -e ZOO_MY_ID=2            -e ZOO_SERVERS="server.1=192.168.56.11:2888:3888;2181 server.2=192.168.56.12:2888:3888;2181 server.3=192.168.56.13:2888:3888;2181"             zookeeper:3.6.3
# 192.168.56.13
docker run --name zookeeper -ti -d            --restart=unless-stopped            -p 2181:2181 -p 2888:2888 -p 3888:3888            -e ZOO_CFG_EXTRA="quorumListenOnAllIPs=true"            -e JVMFLAGS="-Dzookeeper.electionPortBindRetry=50"            -v /opt/app/zkafka/data/zookeeper:/data            -v /opt/app/zkafka/data/zookeeper/logs:/logs            -e ZOO_MY_ID=3            -e ZOO_SERVERS="server.1=192.168.56.11:2888:3888;2181 server.2=192.168.56.12:2888:3888;2181 server.3=192.168.56.13:2888:3888;2181"             zookeeper:3.6.3
```

## kafka

```shell script
docker rm -f kafka
docker run --name kafka -ti -d \
-e KAFKA_ZOOKEEPER_PROTOCOL=PLAINTEXT \
-e ALLOW_PLAINTEXT_LISTENER=yes \
-e KAFKA_BROKER_ID=1 \
-e KAFKA_MESSAGE_MAX_BYTES=100001200 -p 9092:9092 -p 9093:9093 \
-e KAFKA_CFG_ZOOKEEPER_CONNECT=192.168.56.11:2181,192.168.56.12:2181,192.168.56.13:2181 \
-e KAFKA_CFG_ADVERTISED_LISTENERS=CLIENT://192.168.56.11:9092,EXTERNAL://192.168.56.11:9093 \
-e KAFKA_CFG_LISTENERS=CLIENT://:9092,EXTERNAL://:9093 \
-e KAFKA_CFG_INTER_BROKER_LISTENER_NAME=CLIENT \
-e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CLIENT:PLAINTEXT,EXTERNAL:PLAINTEXT \
-e KAFKA_CFG_SASL_ENABLED_MECHANISMS=PLAIN \
-e KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAINTEXT \
-e KAFKA_CLIENT_USERS=admin \
-e KAFKA_CLIENT_PASSWORDS=aaBB@1122 \
-e KAFKA_INTER_BROKER_USER=admin \
-e KAFKA_INTER_BROKER_PASSWORD=aaBB@1122 \
 bitnami/kafka:2.8.1
docker logs -f kafka



docker rm -f kafka
docker run --name kafka -ti -d \
-e KAFKA_ZOOKEEPER_PROTOCOL=PLAINTEXT \
-e ALLOW_PLAINTEXT_LISTENER=yes \
-e KAFKA_BROKER_ID=2 \
-e KAFKA_MESSAGE_MAX_BYTES=100001200 -p 9092:9092 -p 9093:9093 \
-e KAFKA_CFG_ZOOKEEPER_CONNECT=192.168.56.11:2181,192.168.56.12:2181,192.168.56.13:2181 \
-e KAFKA_CFG_ADVERTISED_LISTENERS=CLIENT://192.168.56.12:9092,EXTERNAL://192.168.56.12:9093 \
-e KAFKA_CFG_LISTENERS=CLIENT://:9092,EXTERNAL://:9093 \
-e KAFKA_CFG_INTER_BROKER_LISTENER_NAME=CLIENT \
-e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CLIENT:PLAINTEXT,EXTERNAL:PLAINTEXT \
-e KAFKA_CFG_SASL_ENABLED_MECHANISMS=PLAIN \
-e KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAINTEXT \
-e KAFKA_CLIENT_USERS=admin \
-e KAFKA_CLIENT_PASSWORDS=aaBB@1122 \
-e KAFKA_INTER_BROKER_USER=admin \
-e KAFKA_INTER_BROKER_PASSWORD=aaBB@1122 \
 bitnami/kafka:2.8.1
docker logs -f kafka



docker rm -f kafka
docker run --name kafka -ti -d \
-e KAFKA_ZOOKEEPER_PROTOCOL=PLAINTEXT \
-e ALLOW_PLAINTEXT_LISTENER=yes \
-e KAFKA_BROKER_ID=3 \
-e KAFKA_MESSAGE_MAX_BYTES=100001200 -p 9092:9092 -p 9093:9093 \
-e KAFKA_CFG_ZOOKEEPER_CONNECT=192.168.56.11:2181,192.168.56.12:2181,192.168.56.13:2181 \
-e KAFKA_CFG_ADVERTISED_LISTENERS=CLIENT://192.168.56.13:9092,EXTERNAL://192.168.56.13:9093 \
-e KAFKA_CFG_LISTENERS=CLIENT://:9092,EXTERNAL://:9093 \
-e KAFKA_CFG_INTER_BROKER_LISTENER_NAME=CLIENT \
-e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CLIENT:PLAINTEXT,EXTERNAL:PLAINTEXT \
-e KAFKA_CFG_SASL_ENABLED_MECHANISMS=PLAIN \
-e KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAINTEXT \
-e KAFKA_CLIENT_USERS=admin \
-e KAFKA_CLIENT_PASSWORDS=aaBB@1122 \
-e KAFKA_INTER_BROKER_USER=admin \
-e KAFKA_INTER_BROKER_PASSWORD=aaBB@1122 \
 bitnami/kafka:2.8.1
docker logs -f kafka
```