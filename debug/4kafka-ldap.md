broker.id=1
listeners=CLIENT://0.0.0.0:9093,EXTERNAL://0.0.0.0:9092
advertised.listeners=CLIENT://192.168.56.11:9093,EXTERNAL://192.168.56.11:9092
listener.security.protocol.map=CLIENT:SASL_PLAINTEXT,EXTERNAL:SASL_PLAINTEXT
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/bitnami/kafka/data
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=84
log.retention.check.interval.ms=300000
zookeeper.connect=192.168.56.11:2181,192.168.56.12:2181,192.168.56.13:2181
advertised.host.name=192.168.56.11
allow.everyone.if.no.acl.found=false
authorizer.class.name=kafka.security.authorizer.AclAuthorizer
authz.ldap.base.dn=ou=app,dc=travelsky,dc=com
authz.ldap.host=172.26.15.144
authz.ldap.port=389
authz.ldap.username.to.dn.format=cn=%s,ou=app,dc=travelsky,dc=com
inter.broker.listener.name=CLIENT
listener.name.external.plain.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required ;
listener.name.external.plain.sasl.server.callback.handler.class=ldap.LdapAuthenticateCallbackHandler
listener.name.plaintext.plain.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required ;
listener.name.plaintext.plain.sasl.server.callback.handler.class=ldap.LdapAuthenticateCallbackHandler
log.cleanup.policy=delete
max.partition.fetch.bytes=10485760
max.request.size=10485760
message.max.bytes=100001200
sasl.enabled.mechanisms=PLAIN
sasl.mechanism.inter.broker.protocol=PLAIN
super.users=User:admin
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="aaBB@1122";



## ranger-kafka

```bash
curl 'http://192.168.56.10:6080/service/plugins/services' \
  -H 'Accept: application/json, text/plain, */*' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/json' \
  -H 'Cookie: RANGERADMINSESSIONID=92C0BC752CA7337BF87BA73A6A2F5CF3' \
  -H 'Origin: http://192.168.56.10:6080' \
  -H 'Referer: http://192.168.56.10:6080/index.html' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H 'X-XSRF-HEADER: AgFjTiMExaMjpBUrFoGU' \
  --data-raw $'{"name":"kafka-ha-policy","type":"kafka","tagService":"","isEnabled":true,"configs":{"username":"admin","password":"aaBB@1122","zookeeper.connect":"192.168.56.11:2181,192.168.56.12:2181,192.168.56.13:2181","ranger.plugin.audit.filters":"[{\'accessResult\':\'DENIED\',\'isAudited\':true},{\'resources\':{\'topic\':{\'values\':[\'ATLAS_ENTITIES\',\'ATLAS_HOOK\',\'ATLAS_SPARK_HOOK\'],\'isExcludes\':true}},\'users\':[\'atlas\'],\'actions\':[\'describe\',\'publish\',\'consume\'],\'isAudited\':false},{\'resources\':{\'topic\':{\'values\':[\'ATLAS_HOOK\'],\'isExcludes\':true}},\'users\':[\'hive\',\'hbase\',\'impala\',\'nifi\'],\'actions\':[\'publish\',\'describe\'],\'isAudited\':false},{\'resources\':{\'topic\':{\'values\':[\'ATLAS_ENTITIES\'],\'isExcludes\':true}},\'users\':[\'rangertagsync\'],\'actions\':[\'consume\',\'describe\'],\'isAudited\':false},{\'resources\':{\'consumergroup\':{\'values\':[\'*\'],\'isExcludes\':true}},\'users\':[\'atlas\',\'rangertagsync\'],\'actions\':[\'consume\'],\'isAudited\':false},{\'users\':[\'kafka\'],\'isAudited\':false},{\'resources\':{\'topic\':{\'values\':[\'__CruiseControlMetrics\'],\'isExcludes\':true}},\'users\':[\'cc_metric_reporter\'],\'actions\':[\'describe\',\'publish\',\'consume\'],\'isAudited\':false}]"}}' \
  --insecure
```