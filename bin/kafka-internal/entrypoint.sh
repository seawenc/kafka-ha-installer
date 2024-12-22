#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/libbitnami.sh
. /opt/bitnami/scripts/libkafka.sh

# Load Kafka environment variables
. /opt/bitnami/scripts/kafka-env.sh

print_welcome_page

if [[ "$*" = *"/opt/bitnami/scripts/kafka/run.sh"* || "$*" = *"/run.sh"* ]]; then
    info "** Starting Kafka setup **"
    /opt/bitnami/scripts/kafka/setup.sh
    info "** Kafka setup finished! **"
fi

# 需要初始化ranger插件
echo "kafka初始化完成，马上进行ranger插件初始化..."
bash /opt/ranger-kafka-plugin/enable-kafka-plugin.sh
echo "ranger插件初始化完成，马上进行ranger插件初始化..."
# 设置jmx权限
#chown kafka /opt/bitnami/kafka/bin/kafka-internal/jmx/jmxremote.password
#chown kafka /opt/bitnami/kafka/bin/kafka-internal/jmx/jmxremote.access
# 解决老是报错问题，虽然不影响功能
useradd admin

exec "$@"
