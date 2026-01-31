#!/bin/bash

CONFIG="/opt/kafka/config/server.properties"
LOG_DIR="/data"

set -e

if [ ! -f "$LOG_DIR/meta.properties" ]; then
  echo "[$(date)] Formatting Kafka storage with new cluster ID..."
  CLUSTER_ID='kafka-ha'
  /opt/kafka/bin/kafka-storage.sh format -t "$CLUSTER_ID" -c "$CONFIG"
  echo "[$(date)] Storage formatted with cluster ID: $CLUSTER_ID"
fi

echo "[$(date)] Starting Kafka server..."

exec /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties