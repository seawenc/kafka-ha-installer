# 此文件正常应用为 properties文件，但是由于 properties 要乱码，因此使用sh后续
process.roles=broker,controller
broker.id=_nodeId_
node.id=_nodeId_
cluster.id=kafka-ha
controller.quorum.voters=_CLUSTER_SERVERS_
controller.listener.names=CONTROLLER

listeners=CONTROLLER://:9091,INTERNAL://:9093,EXTERNAL://:9092
advertised.listeners=INTERNAL://_ip_:9093,EXTERNAL://_extIp_:9092
listener.security.protocol.map=CONTROLLER:PLAINTEXT,INTERNAL:SASL_PLAINTEXT,EXTERNAL:SASL_PLAINTEXT

inter.broker.listener.name=INTERNAL
sasl.mechanism.inter.broker.protocol=PLAIN
sasl.enabled.mechanisms=PLAIN

controller.listener.security.protocol=PLAINTEXT
sasl.mechanism.controller.protocol=PLAIN

#authorizer.class.name=org.apache.kafka.metadata.authorizer.StandardAuthorizer
authorizer.class.name=org.apache.ranger.authorization.kafka.authorizer.RangerKafkaAuthorizer
listener.name.internal.plain.sasl.server.callback.handler.class=ranger.RangerAuthenticateCallbackHandler
listener.name.external.plain.sasl.server.callback.handler.class=ranger.RangerAuthenticateCallbackHandler

authorizer.standard.enable.acl=false
authorizer.standard.allow.everyone.if.no.acl.found=false
super.users=User:admin

# KRaft config
early.start.listeners=CONTROLLER
metadata.authorizer.acl.exempt.principals=User:admin

num.io.threads=8
num.network.threads=5
background.threads=10

# 数据大小
message.max.bytes=100001200
max.partition.fetch.bytes=10485760
max.request.size=10485760
replica.fetch.max.bytes=10485760
# 日志存储时间
log.retention.hours=_kafka_msg_storage_hours_
log.cleanup.policy=delete
# 数据存储目录
log.dirs=/data

# ====== 集群KRaft 核心超时配置-开始，配置不正确很容易连接超时，无法启动 ======
### 1. 连接建立超时
# 单连接45秒
socket.connection.setup.timeout.ms=45000
# 总连接时间3分钟
socket.connection.setup.timeout.max.ms=180000

### 2. 控制器仲裁超时
# 请求超时90秒
controller.quorum.request.timeout.ms=90000
# 选举超时30秒
controller.quorum.election.timeout.ms=30000
## 拉取超时90秒
controller.quorum.fetch.timeout.ms=90000
# 选举退避10秒
controller.quorum.election.backoff.max.ms=10000
# 追加延迟50ms
controller.quorum.append.linger.ms=50

### 3. 副本同步超时
# 副本socket超时60秒
replica.socket.timeout.ms=60000
# 副本拉取等待1秒                 
replica.fetch.wait.max.ms=1000
# 拉取退避2秒                 
replica.fetch.backoff.ms=2000
# 200MB
replica.fetch.response.max.bytes=209715200

###  4. 会话和心跳超时
# 会话超时45秒
session.timeout.ms=45000
# 心跳间隔3秒         
heartbeat.interval.ms=3000
# ====== 集群KRaft 核心超时配置-结束 ======