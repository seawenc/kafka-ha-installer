# 权限插件

插件主要包含以下三个文件：  
2. `conf/ranger/ranger-kafka-plugin-2.5.0.jar`： ranger- 默认ranger的kafka插件只支持kerberos认证，本包增加了用户名密码方式  
1. `conf/kafka/libs/plugin-auth-1.0.jar`: kafka-自定义认证插件,本项目出的包
3. `conf/kafka/libs/ranger-2.5.0-kafka-plugin.tar.gz`: 用于kafka安装ranger插件的包，此包解决了几个ranger存在的bug，替换了其中的`ranger-kafka-plugin-2.5.0.jar`，`ranger-plugins-common-2.5.0.jar`，
> 源码在`git@github.com:seawenc/ranger.git`中的`release-ranger-2.5.0-cqrd-fix`分支

## 打包：
gradle 7.5执行：
```bash
# 先切换gradle版本为7.4,jdk为17
export PATH="home/chengsheng/.opencode/bin:/opt/apps/miniforge3/envs/py312/bin:/opt/apps/miniforge3/condabin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/sbin:/usr/sbin:/opt/apps/jdk-17.0.11/bin:/opt/apps/apache-maven-3.9.9/bin:/opt/apps/gradle-7.4/bin:/opt/apps/node-v20.18.1-linux-x64/bin:/opt/apps/miniforge3/bin:/opt/app/clojure/bin"
export JAVA_HOME=/opt/apps/jdk-17.0.11
gradle shadowJar
```

scp /data/share/kafka-ha-installer/conf/kafka/libs/plugin-auth-1.0.jar 192.168.56.11:/opt/app/kafka-ha/kafka/libs/
scp /data/share/kafka-ha-installer/conf/kafka/libs/plugin-auth-1.0.jar 192.168.56.12:/opt/app/kafka-ha/kafka/libs/
scp /data/share/kafka-ha-installer/conf/kafka/libs/plugin-auth-1.0.jar 192.168.56.13:/opt/app/kafka-ha/kafka/libs/
