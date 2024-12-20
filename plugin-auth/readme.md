# 权限插件

包含两个插件：  
1. `build/libs/plugin-auth-1.0.jar`: kafka-自定义认证插件   
2. `ranger/ranger-kafka-plugin-2.5.0.jar`： ranger- 默认ranger的kafka插件只支持kerberos认证，本包增加了用户名密码方式  
3. `ranger/ranger-2.5.0-kafka-plugin.tar.gz`: 用于kafka安装ranger插件的包，直接从官方代码出的包少了两个jar包(commons-compress-1.26.2.jar,commons-lang3-3.9.jar)，需要放到此压缩包的`install/lib`下  