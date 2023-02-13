# zookeeper+kafka认证版本

## zookeeper
https://hub.docker.com/r/bitnami/zookeeper
```shell script
docker rm -f zookeeper
# 192.168.56.11
docker run --name zookeeper -ti -d            --restart=unless-stopped            -p 2181:2181 -p 2888:2888 -p 3888:3888            -v /opt/app/zkafka/data/zookeeper:/data            -v /opt/app/zkafka/data/zookeeper/logs:/logs            -e ZOO_SERVER_ID=1            -e ZOO_ENABLE_AUTH=yes            -e ZOO_LISTEN_ALLIPS_ENABLED=yes            -e ALLOW_ANONYMOUS_LOGIN=no            -e ZOO_SERVER_USERS="admin"            -e ZOO_SERVER_PASSWORDS="aaBB@1122"            -e ZOO_CLIENT_USER=admin            -e ZOO_CLIENT_PASSWORD=aaBB@1122            -e JVMFLAGS="-Dzookeeper.electionPortBindRetry=50"            -e ZOO_SERVERS="192.168.56.11:2888:3888,192.168.56.12:2888:3888,192.168.56.13:2888:3888"             bitnami/zookeeper:3.6.3
# 192.168.56.12
docker run --name zookeeper -ti -d            --restart=unless-stopped            -p 2181:2181 -p 2888:2888 -p 3888:3888            -v /opt/app/zkafka/data/zookeeper:/data            -v /opt/app/zkafka/data/zookeeper/logs:/logs            -e ZOO_SERVER_ID=2            -e ZOO_ENABLE_AUTH=yes            -e ZOO_LISTEN_ALLIPS_ENABLED=yes            -e ALLOW_ANONYMOUS_LOGIN=no            -e ZOO_SERVER_USERS="admin"            -e ZOO_SERVER_PASSWORDS="aaBB@1122"            -e ZOO_CLIENT_USER=admin            -e ZOO_CLIENT_PASSWORD=aaBB@1122            -e JVMFLAGS="-Dzookeeper.electionPortBindRetry=50"            -e ZOO_SERVERS="192.168.56.11:2888:3888,192.168.56.12:2888:3888,192.168.56.13:2888:3888"             bitnami/zookeeper:3.6.3
# 192.168.56.13
docker run --name zookeeper -ti -d            --restart=unless-stopped            -p 2181:2181 -p 2888:2888 -p 3888:3888            -v /opt/app/zkafka/data/zookeeper:/data            -v /opt/app/zkafka/data/zookeeper/logs:/logs            -e ZOO_SERVER_ID=3            -e ZOO_ENABLE_AUTH=yes            -e ZOO_LISTEN_ALLIPS_ENABLED=yes            -e ALLOW_ANONYMOUS_LOGIN=no            -e ZOO_SERVER_USERS="admin"            -e ZOO_SERVER_PASSWORDS="aaBB@1122"            -e ZOO_CLIENT_USER=admin            -e ZOO_CLIENT_PASSWORD=aaBB@1122            -e JVMFLAGS="-Dzookeeper.electionPortBindRetry=50"            -e ZOO_SERVERS="192.168.56.11:2888:3888,192.168.56.12:2888:3888,192.168.56.13:2888:3888"             bitnami/zookeeper:3.6.3
```

## kafka
https://hub.docker.com/r/bitnami/kafka
```shell script
docker rm -f kafka
docker run --name kafka -ti -d \
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
-e KAFKA_OPTS="-Djava.security.auth.login.config=/opt/bitnami/kafka/config/kafka_jaas.conf" \
-e KAFKA_CLIENT_USERS=admin \
-e KAFKA_CLIENT_PASSWORDS=aaBB@1122 \
-e KAFKA_INTER_BROKER_USER=admin \
-e KAFKA_INTER_BROKER_PASSWORD=aaBB@1122 \
-e KAFKA_ZOOKEEPER_PROTOCOL=SASL \
-e KAFKA_ZOOKEEPER_USER=admin \
-e KAFKA_ZOOKEEPER_PASSWORD=aaBB@1122 \
 seawenc/bitnami-kafka:3.4.0
docker logs -f kafka


docker rm -f kafka
docker run --name kafka -ti -d \
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
-e KAFKA_OPTS="-Djava.security.auth.login.config=/opt/bitnami/kafka/config/kafka_jaas.conf" \
-e KAFKA_CLIENT_USERS=admin \
-e KAFKA_CLIENT_PASSWORDS=aaBB@1122 \
-e KAFKA_INTER_BROKER_USER=admin \
-e KAFKA_INTER_BROKER_PASSWORD=aaBB@1122 \
-e KAFKA_ZOOKEEPER_PROTOCOL=SASL \
-e KAFKA_ZOOKEEPER_USER=admin \
-e KAFKA_ZOOKEEPER_PASSWORD=aaBB@1122 \
 seawenc/bitnami-kafka:3.4.0
docker logs -f kafka

docker rm -f kafka
docker run --name kafka -ti -d \
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
-e KAFKA_OPTS="-Djava.security.auth.login.config=/opt/bitnami/kafka/config/kafka_jaas.conf" \
-e KAFKA_CLIENT_USERS=admin \
-e KAFKA_CLIENT_PASSWORDS=aaBB@1122 \
-e KAFKA_INTER_BROKER_USER=admin \
-e KAFKA_INTER_BROKER_PASSWORD=aaBB@1122 \
-e KAFKA_ZOOKEEPER_PROTOCOL=SASL \
-e KAFKA_ZOOKEEPER_USER=admin \
-e KAFKA_ZOOKEEPER_PASSWORD=aaBB@1122 \
 seawenc/bitnami-kafka:3.4.0
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
Client {
  org.apache.zookeeper.server.auth.DigestLoginModule required
  username="admin"
  password="aaBB@1122";
};
KafkaClient {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username="admin"
  password="aaBB@1122";
};
```

## 验证

```shell script
# 验证前准备，需要手动修改producer.properties，consumer.properties
ssh $ip "docker exec kafka sh -c \"echo '\nsecurity.protocol=SASL_PLAINTEXT\nsasl.mechanism=PLAIN' >> /opt/bitnami/kafka/config/producer.properties\""
ssh $ip "docker exec kafka sh -c \"echo '\nsecurity.protocol=SASL_PLAINTEXT\nsasl.mechanism=PLAIN' >> /opt/bitnami/kafka/config/consumer.properties\""

#验证
kafka-topics.sh --create --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092 --topic test --partitions 3 --replication-factor 2 --command-config /opt/bitnami/kafka/config/producer.properties
kafka-console-producer.sh --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092 --topic test --producer.config /opt/bitnami/kafka/config/producer.properties
kafka-console-consumer.sh --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092 --topic test --consumer.config /opt/bitnami/kafka/config/consumer.properties
```


sasl.mechanism.inter.broker.protocol=plain
sasl_mechanism_inter_broker_protocol=plain
inter.broker.listener.name=CLIENT