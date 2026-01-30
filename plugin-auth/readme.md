# 权限插件

插件主要包含以下三个文件：  
2. `conf/ranger/ranger-kafka-plugin-2.5.0.jar`： ranger- 默认ranger的kafka插件只支持kerberos认证，本包增加了用户名密码方式  
1. `conf/kafka/libs/plugin-auth-1.0.jar`: kafka-自定义认证插件,本项目出的包
3. `conf/kafka/libs/ranger-2.5.0-kafka-plugin.tar.gz`: 用于kafka安装ranger插件的包，此包解决了几个ranger存在的bug，替换了其中的`ranger-kafka-plugin-2.5.0.jar`，`ranger-plugins-common-2.5.0.jar`，
> 源码在`git@github.com:seawenc/ranger.git`中的`release-ranger-2.5.0-cqrd-fix`分支

## 打包：
gradle 7.5执行：gradle shadowJar