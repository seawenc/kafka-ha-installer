# docker单机版本安装方式


```shell
DATA_DIR=/opt/dapp/kafka
mkdir -p $DATA_DIR/data && chmod 777 $DATA_DIR/data

cat > $DATA_DIR/run.sh << EOF
docker rm -f kafka-server
docker run -d --name kafka-server --net=host \
      -e KAFKA_CFG_NODE_ID=0 \
      -e KAFKA_CFG_PROCESS_ROLES=controller,broker \
      -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@{内部ip}:9094 \
      -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9093,CONTROLLER://:9094,EXTERNAL://:9092 \
      -e KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://{内部ip}:9093,EXTERNAL://{外部ip}:9092 \
      -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,EXTERNAL:SASL_PLAINTEXT,PLAINTEXT:SASL_PLAINTEXT \
      -e KAFKA_CFG_SASL_ENABLED_MECHANISMS=PLAIN \
      -e KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN \
      -e KAFKA_CFG_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN \
      -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER \
      -e KAFKA_CLIENT_USERS=admin1,admin2 \
      -e KAFKA_CLIENT_PASSWORDS=aabb@12,aabb@13 \
      -v /opt/dapp/kafka/data:/bitnami/kafka/data \
    bitnami/kafka:latest
docker logs -f kafka-server
EOF
chmod +x $DATA_DIR/run.sh
bash $DATA_DIR/run.sh
```
> 以上变量：DATA_DIR，内部ip，外部ip，请提前修改
> 