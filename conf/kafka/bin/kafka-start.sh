#!/bin/bash

set -e

CONFIG="/opt/kafka/config/kafka.properties"
LOG_DIR="/data"

# # 创建必要的客户端配置文件
# cat > /tmp/client.conf << EOF
# security.protocol=SASL_PLAINTEXT
# sasl.mechanism=PLAIN
# sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
#     username="admin" \
#     password="admin-secret";
# EOF

if [ ! -f "$LOG_DIR/meta.properties" ]; then
  echo "[$(date)] Formatting Kafka storage with new cluster ID..."
  CLUSTER_ID='kafka-ha'
  /opt/kafka/bin/kafka-storage.sh format -t "$CLUSTER_ID" -c "$CONFIG"
  echo "[$(date)] Storage formatted with cluster ID: $CLUSTER_ID"
fi

echo "[$(date)] Starting Kafka server..."


exec /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kafka.properties