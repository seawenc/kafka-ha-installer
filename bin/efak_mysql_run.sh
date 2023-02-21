# efak所需mysql的启动脚本(未完成)
docker rm -f mysql
docker run --name mysql \
-p 3306:3306 \
-e MYSQL_ROOT_PASSWORD=travel#efak \
-e TZ=Asia/Shanghai \
-e MYSQL_DATABASE=efak \
-e MYSQL_USER=efak \
-e MYSQL_PASSWORD=travel#efak \
-v /opt/app/dgp/mysql/dbdata:/var/lib/mysql \
-d mysql:5.7 \
--character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci