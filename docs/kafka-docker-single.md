# docker单机版本安装方式

## 普通认证
```shell
DATA_DIR=/opt/dapp/kafka
mkdir -p $DATA_DIR/data && chmod 777 $DATA_DIR/data

cat > run.sh << EOF
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
    bitnami/kafka:3.9.0
docker logs -f kafka-server

EOF
chmod +x run.sh
bash $DATA_DIR/run.sh
```
> 以上变量：DATA_DIR，内部ip，外部ip，请提前修改

## LDAP认证

```bash
```shell
DATA_DIR=/opt/dapp/kafka
mkdir -p $DATA_DIR/data && chmod 777 $DATA_DIR/data

cat > run.sh << EOF
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
       -e KAFKA_CFG_AUTHZ_LDAP_HOST=172.26.15.144 \
       -e KAFKA_CFG_AUTHZ_LDAP_PORT=389 \
       -e KAFKA_CFG_AUTHZ_LDAP_BASE_DN=ou=app,dc=travelsky,dc=com \
       -e KAFKA_CFG_AUTHZ_LDAP_USERNAME_TO_DN_FORMAT=cn=%s,ou=app,dc=travelsky,dc=com \
       -e KAFKA_CFG_LISTENER_NAME_EXTERNAL_PLAIN_SASL_JAAS_CONFIG='org.apache.kafka.common.security.plain.PlainLoginModule required ;' \
       -e KAFKA_CFG_LISTENER_NAME_PLAINTEXT_PLAIN_SASL_JAAS_CONFIG='org.apache.kafka.common.security.plain.PlainLoginModule required ;' \
       -e KAFKA_CFG_LISTENER_NAME_EXTERNAL_PLAIN_SASL_SERVER_CALLBACK_HANDLER_CLASS=LdapAuthenticateCallbackHandler \
       -e KAFKA_CFG_LISTENER_NAME_PLAINTEXT_PLAIN_SASL_SERVER_CALLBACK_HANDLER_CLASS=LdapAuthenticateCallbackHandler \
      -v /opt/app/kafka/lib/ldap-auth-1.0.jar:/opt/bitnami/kafka/libs/ldap-auth-1.0.jar \
      -v /opt/app/kafka/data:/bitnami/kafka/data \
    bitnami/kafka:3.9.0
docker logs -f kafka-server
EOF
chmod +x run.sh
bash $DATA_DIR/run.sh
```

> 以上变量：DATA_DIR，内部ip，外部ip，以及ldap地址 请提前修改
