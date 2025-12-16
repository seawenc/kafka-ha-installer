# zookeeper升级

2025年12月，发现bitnami/zookeeper已被官方删除，连老版本都被删除，更别说新版本了，但是当前版本有安全漏洞，需要升级

因此只能基于本地已有镜像进行升级(原镜像为：3.6.3)

## 镜像制作
在当前目录执行
```bash
# 由于源镜像中没有curl指令，因此需要在外面下载，dockerfile中直接copy
curl -O http://172.26.1.7/apache-zookeeper-3.9.4-bin.tar.gz
curl -O https://dlcdn.apache.org/zookeeper/zookeeper-3.9.4/apache-zookeeper-3.9.4-bin.tar.gz
tar -xzf apache-zookeeper-3.9.4-bin.tar.gz
mv apache-zookeeper-3.9.4-bin/lib 3.9.4.lib

# 镜像制作
docker build -t dockeropen.x/bitnami/zookeeper:3.9.4 .
```