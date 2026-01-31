cd "$(dirname "$0")"
sh stop.sh

# 添加依赖监控，当ranger未启动好时，则循环等待ranger启动完成
# while true; do
#   response=$(curl -s -i http://_ranger_host_:6080 | grep login.jsp)
#   if [ -n "$response" ]; then
#     echo "[$(date)] Ranger为就绪状态,开始启动kafka..."
#     break
#   else
#     echo "[$(date)] 等待Ranger启动..."
#     sleep 3
#   fi
# done

docker-compose up -d
echo "启动完成，若要查看日志，使用指令：docker logs -n 100 -f kafka"