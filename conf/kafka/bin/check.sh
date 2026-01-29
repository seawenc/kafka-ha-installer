# 用于安装时，检查集群状态是否成功
kafka-topics.sh --list --bootstrap-server $SERVERS  --command-config /client.properties  2>&1 | grep -E ' WARN | ERROR ' > /tmp/check.log
ERROR_LOG_NUM=`cat /tmp/check.log | wc -l`
if [ $ERROR_LOG_NUM -gt 0 ];then
  cat /tmp/check.log
  exit 1
fi