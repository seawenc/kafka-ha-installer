需要先准备安装包放到此目录：
docker下载地址: https://download.docker.com/linux/static/stable/x86_64/

各镜像导出后放到此目录,如：
```shell script
# 找一台可连网已安装docker的服务器,执行以下指令：
docker save apache/kafka:4.1.1 | gzip > kafka.gz
```
