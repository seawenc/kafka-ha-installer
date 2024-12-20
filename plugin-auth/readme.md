# 权限插件

包含两个插件：  
1. `build/libs/plugin-auth-1.0.jar`: kafka-自定义认证插件   
2. `ranger/ranger-kafka-plugin-2.5.0.jar`： ranger- 默认ranger的kafka插件只支持kerberos认证，本包增加了用户名密码方式  
3. `ranger/ranger-2.5.0-kafka-plugin.tar.gz`: 用于kafka安装ranger插件的包，此包有以下改动: 
> * 1、直接从官方代码出的包少了两个jar包(commons-compress-1.26.2.jar,commons-lang3-3.9.jar)，需要放到此压缩包的`install/lib`下
> * 2、解决了几个ranger存在的bug，替换了其中的`ranger-kafka-plugin-2.5.0.jar`，`ranger-plugins-common-2.5.0.jar`，原码在`git@github.com:seawenc/ranger.git`中的`release-ranger-2.5.0-cqrd-fix`分支
> * 3、删除了elasticsearch、solr相关的依赖，若要开启审计，请自行添加此包
