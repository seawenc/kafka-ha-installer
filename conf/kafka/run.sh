cd "$(dirname "$0")"
sh stop.sh
docker-compose up -d
echo "启动完成，若要查看日志，使用指令：docker logs -n 100 -f kafka"