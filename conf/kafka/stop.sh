cd "$(dirname "$0")"
docker-compose stop
docker-compose rm -f
docker rm -f kafka
echo "已停止..."