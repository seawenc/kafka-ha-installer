# zookeeper未认证，kafka认证版本

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
-e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CLIENT:SASL_PLAINTEXT,EXTERNAL:SASL_PLAINTEXT \
-e KAFKA_CFG_SASL_ENABLED_MECHANISMS=PLAIN \
-e KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN \
-e KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN \
-e KAFKA_INTER_BROKER_LISTENER_NAME=CLIENT \
-v /opt/app/zkafka/kafka/jaas.conf:/opt/bitnami/kafka/config/kafka_jaas.conf \
-e KAFKA_OPTS="-Djava.security.auth.login.config=/opt/bitnami/kafka/config/kafka_server_jaas.conf" \
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
-e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CLIENT:SASL_PLAINTEXT,EXTERNAL:SASL_PLAINTEXT \
-e KAFKA_CFG_SASL_ENABLED_MECHANISMS=PLAIN \
-e KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN \
-e KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN \
-e KAFKA_INTER_BROKER_LISTENER_NAME=CLIENT \
-v /opt/app/zkafka/kafka/jaas.conf:/opt/bitnami/kafka/config/kafka_jaas.conf \
-e KAFKA_OPTS="-Djava.security.auth.login.config=/opt/bitnami/kafka/config/kafka_server_jaas.conf" \
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
-e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CLIENT:SASL_PLAINTEXT,EXTERNAL:SASL_PLAINTEXT \
-e KAFKA_CFG_SASL_ENABLED_MECHANISMS=PLAIN \
-e KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN \
-e KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN \
-e KAFKA_INTER_BROKER_LISTENER_NAME=CLIENT \
-v /opt/app/zkafka/kafka/jaas.conf:/opt/bitnami/kafka/config/kafka_jaas.conf \
-e KAFKA_OPTS="-Djava.security.auth.login.config=/opt/bitnami/kafka/config/kafka_server_jaas.conf" \
 bitnami/kafka:2.8.1
docker logs -f kafka
```

## jaas.conf

```json
KafkaServer {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username="admin"
  password="aaBB@1122"
  user_admin="aaBB@1122";
};
KafkaClient {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username="admin"
  password="aaBB@1122";
};
```

ADVERTISED_HOST_NAME
