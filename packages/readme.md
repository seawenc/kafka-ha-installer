需要先准备安装包放到此目录：
docker下载地址: https://download.docker.com/linux/static/stable/x86_64/

各镜像导出后放到此目录：
```shell script
# 找一台可连网已安装docker的服务器,执行以下指令：
docker pull bitnami/zookeeper:3.6.3
# 此鏡像制作參考：dockerfile/Dockerfile.kafka
docker pull bitnami/kafka:3.9.0
# 此鏡像制作參考：
docker pull seawenc/efak:3.0.6
docker save bitnami/zookeeper:3.6.3 | gzip > zk.gz
docker save bitnami/kafka:3.9.0 | gzip > kafka.gz
docker save seawenc/efak:3.0.6 | gzip > efak.gz
```
