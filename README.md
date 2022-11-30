# v2.一键安装安装使用指南
## 1.说明
本方案，需要至少三台服务器，每台服务器需要安装kafka与zookeeper，监控工具efak将安装在第一台

相关组件说明:  
**若想修改一些默认参数，请看官方说明**
* 1.zookeeper
docker地址：<https://hub.docker.com/r/bitnami/zookeeper>

* 2.kafka
docker地址：<https://hub.docker.com/r/bitnami/kafka>

* 3.efak
docker地址：<https://hub.docker.com/r/seawenc/efak>

## 2.版本更新记录


**v2.3.0(计划中)**

> * 1.将kafka认证方式修改为Scram方式，以支持动态新增用户

**v2.2.0**.2022-11-30

> 1.添加kafka升级文档
>
> 2.升级efak，支持将监控数据发送到kafka（具体请看6.3章节）

**v2.1.0**.2022-11-10
>
> * 1.监控工具efak新增kafka报警通道

**v2.0.1**.2022-09-29
> 将消息生存周期添加到配置文件中

**v2.0.0**.2022-09-20
> * 1.将安装脚本更改为docker方案安装
> * 2.添加zookeeper认证
> * 3.精简掉5个配置项
> * 4.修复efak不支持双ip配置问题
> * 5.新增kafka jmx监控
> * 6.解决ip最后一段相同时的bug

**v1.4.0**.2022-05-14
> * 1.解决存在的两个安全问题。
> * 2.提取数据目录为可配置变量

**v1.3.0**.2022-04-12
> * 1.添加kafka监控程序efak

## 3.安装准备

### 3.0.安装脚本获取

```shell script
# 在任意一台服务器上下载安装脚本，若不能连网，则请直接手动下载源码
git clone https://github.com/sewenc/kafka-ha-installer.git
#或者：
git clone https://gitee.com/seawenc/kafka-ha-installer.git
```
### 3.1.离线安装准备
**若可安装的服务的主机可连网，则请跳过此部署**
```shell script
# 找一台可连网已安装docker的服务器,执行以下指令：
docker pull bitnami/zookeeper:3.6.3
docker pull bitnami/kafka:2.8.1
docker pull seawenc/efak:3.0.2
docker save bitnami/zookeeper:3.6.3  bitnami/kafka:2.8.1 seawenc/efak:3.0.2 -o ha-kafka.images
# 获得到镜像压缩包hakafka.tar后，上传到，需安装kafka的机器上，并在所有节点上执行：
docker load -i  ha-kafka.images
```

### 3.2.目录文件说明
```
├── bin                         : 所有脚本目录
│   ├── common.sh               : 通用工具脚本，无需显式调用
│   ├── step1_unpwd.sh          : 免密码配置脚本，安装ha集群前需执行此脚本进行初始化
│   ├── step2_install_zk.sh     :一键安装zookeeper
│   ├── step3_install_kafka.sh  :一键安装kafka
│   ├── step4_install_efak.sh   :一键安装efak(监控工具)
│   ├── stop_efak.sh            :一键停止efak(监控工具)
│   ├── stop_kafka.sh           :一键停止所有节点的kafka
│   ├── stop_zk.sh              :一键停止所有节点的zookeeper
│   ├── start_zk.sh             :一键启动所有节点的zookeeper
│   ├── start_kafka.sh          :一键启动所有节点的kafka
│   ├── start_efak.sh           :一键启动efak
│   ├── check_kafka.sh          :一键检查所有节点kafka状态
│   ├── check_zk.sh             :一键检查所有节点zookeeper状态
│   └── clear_data.sh           : 清空所有节点数据（调用请慎重）
├── conf                        : 所有的配置文件
│   ├── config.sh               : 核心配置文件，具体配置项，请看下面介绍
│   ├── efak.properties         : 监控工具efak的配置文件，可不用修改
│   └── jaas.conf               : jaas认证文件，若不用新加kafka用户，则可不用修改
├── docs                        : 项目文档目录
├── debug                        : kafka与zookeeper调试脚本
```

### 3.3.配置文件准备 
* 1.`conf/config.sh`:
```shell script
###############################0.参数配置##########################
# 基本路径，zookeeper与kafka都安装在此目录,请确保此目录有权限
BASE_PATH=/opt/app/hakafka
# 数据存放目录
DATA_DIR=/opt/app/hakafka/data
# kafka地址,格式:  servers[内网地址]="外网地址" （如果没有网外地址，则与内网设置为一致）
declare -A servers=()
servers["192.168.56.11"]="192.168.55.11"
servers["192.168.56.12"]="192.168.55.12"
servers["192.168.56.13"]="192.168.55.13"
# 内网kafka 端口
kafka_port=9092
# 外网kafka 端口
kafka_port_outside=9093
# kafka消息生存时间（单位小时）
kafka_msg_storage_hours=84
# kafka与zookeeper的共用一个账号密码
zkkuser='admin'
zkkpwd='aaBB1122'

# 监控工具efak安装在哪台服务器上,默认是第一台服务器，若想修改，请直接写死
efak_ip=`echo ${!servers[*]} | tr " " "\n" | sort | head -1`
##############################################################
```
* 2.`conf/efak.properties`: 监控工具efak的配置文件，**可不用修改**
* 3.`conf/jaas.conf`: jaas认证文件，若不用新加kafka用户，**则可不用修改**

### 3.4.开始安装
```shell script
# 步骤1：配置服务器之前的免密
sh bin/step1_unpwd.sh
# 步骤2：安装zookeeper
sh bin/step2_install_zk.sh
# 步骤3：安装kafka
sh bin/step3_install_kafka.sh
# 步骤4：安装efak
sh bin/step4_install_efak.sh
```
> 0. 安装过程中，请仔细阅读每一行日志
> 1. `kafka`,`zookeeper`,`efak`在`bin`目录下都有对应的一键关停/启动脚本,请按需调用
> 2. 若安装过程中状态检查未通过，则请按提示查看日志，解决后继续

### 3.5.验证安装结果

获得： step3_install_kafka.sh 此脚本的`运行过程中打印出的`**最后三句脚本**，在已安装kafka的节点上执行  
```
# 请手动在其中两台服务器，执行以下指令进入容器后进行测试可用性
docker exec -ti kafka bash
# 新建topic： test，设置分区数据为3,副本数为2
KAFKA_JMX_OPTS="" JMX_PORT=9955 kafka-topics.sh --create --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092 --topic test --partitions 3 --replication-factor 2 --command-config /opt/bitnami/kafka/config/producer.properties                                                                                                                                                                                                 
# 试消息生产者与消费者
KAFKA_JMX_OPTS="" JMX_PORT=9955 kafka-console-producer.sh --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092 --topic test --producer.config /opt/bitnami/kafka/config/producer.properties
KAFKA_JMX_OPTS="" JMX_PORT=9955  kafka-console-consumer.sh --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092 --topic test --consumer.config /opt/bitnami/kafka/config/consumer.properties
```

**若参接收到，则安装成功**

登录efak，查看kafka状态
http://192.168.56.11:8048/
默认用户名密码：admin/123456 (**请及时修改密码**)

## 4.连接方式

### 4.1.kafkatool工具连接
**此方式只用于查看kafka情况时用**

下载地址=<https://www.kafkatool.com/download2/offsetexplorer_64bit.exe>

#### 连接配置

* properties-> cluster name = `mykafka（任意）`  
* properties-> kafka cluster version = `2.8`  
* security -> type = `SASL Plaintext`  
* Advanced -> Bootstrap servers= `192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092`  
* Advanced -> SASL Mechanism= `PLAIN`  
* JAAS Config-> `org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="aaBB1122";`  

配置完成后，点击`connect`  

#### 查看数据
若需要查看topic中的数据，则点击topic，在`Properties` -> Content Types -> key和value 都设置成 String -> 点击update  

切换到`data`中后可查看数据

### 4.2.java代码连接示例

#### 依赖引入
```groovy
// 以下为gradle方式引入，maven引入请自行转换为xml
compile "org.apache.kafka:kafka-clients:2.2.1"
```

#### 定义公共类-KafkaHelper
```java
import com.alibaba.fastjson.JSON;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;

public class KafkaHelper {
    /**
     * 获得kafka的配置,包含groupId
     * @return Properties
     * @throws Exception 异常
     */
    public static synchronized Properties getKafkaConf() throws Exception {
        Properties properties = new Properties();
        properties.setProperty("bootstrap.servers", "192.168.56.11:9092,192.168.56.12:9092,192.168.56.13:9092");
        properties.setProperty("acks", "all");
        properties.setProperty("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        properties.setProperty("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        properties.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        properties.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");

        properties.setProperty("sasl.jaas.config", "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"admin\" password=\"aaBB1122\";");
//        properties.setProperty("sasl.mechanism", "SCRAM-SHA-256");
        properties.setProperty("sasl.mechanism", "PLAIN");
        properties.setProperty("security.protocol", "SASL_PLAINTEXT");
        LOG.info("......... kafka props: %s", JSON.toJSONString(properties));
        return properties;
    }
}
```

#### 定义消息生产者
```java
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import java.util.Properties;
import java.util.concurrent.Future;
/**
 * kafka消息生产者测试
 */
public class KafkaProducer {
    public static void main(String[] args)throws Exception {
       String topic="test";
        Properties props= KafkaHelper.getKafkaConf();
        org.apache.kafka.clients.producer.KafkaProducer<String, String> producer = new org.apache.kafka.clients.producer.KafkaProducer<>(props);
        Thread.sleep(4000);
        for(int i=0;i<1000;i++){
            Thread.sleep(1000);
            Future<RecordMetadata> future= producer.send(new ProducerRecord<>(topic,"发送消息"+i));
            System.out.println(i+"->topic:" + topic+",partition = "+ future.get().partition());
        }
    }
}
```

#### 定义消息消费者
```java
/**
 * kafka消息消费者测试
 */
public class KafkaConsumer {
    public static void main(String[] args) throws Exception {
        String topics="test";
        String groupId="group1";
        Properties properties = KafkaHelper.getKafkaConf();
        properties.setProperty("group.id",groupId);
        org.apache.kafka.clients.consumer.KafkaConsumer<String, String> consumer = new org.apache.kafka.clients.consumer.KafkaConsumer<>(properties);
        consumer.subscribe(Arrays.asList(topics.split(",")));
        Log.info("topic:" + topics + ",props:" + JSON.toJSONString(properties));
        while (true) {
            ConsumerRecords<String, String> records = consumer.poll(100);
            for (ConsumerRecord<String, String> record : records) {
                String value = record.value();
                Log.info("offset = %d, partition = %s, value = %s%n", record.offset(),record.partition(), value);
            }
            Thread.sleep(1000);
        }
    }
}
```
#### 验证
先启动`KafkaConsumer`,再启动`KafkaProducer`,看是否能收消息

## 5.运维

### 5.1、常用指令

``` shell script
#1.查看topic明细
KAFKA_JMX_OPTS="" JMX_PORT=9955 kafka-topics.sh --describe --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092 --topic test --command-config /opt/bitnami/kafka/config/producer.properties

#2.修改topic：test的消息存储时间为48小时
KAFKA_JMX_OPTS="" JMX_PORT=9955 kafka-configs.sh  --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092 --alter --entity-name test --entity-type topics --add-config retention.ms=172800000 --command-config /opt/bitnami/kafka/config/producer.properties
#3.立刻删除过期数据
KAFKA_JMX_OPTS="" JMX_PORT=9955 kafka-topics.sh --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092 --alter --topic test --config  cleanup.policy=delete --command-config /opt/bitnami/kafka/config/producer.properties

#4.修改分区数为3
KAFKA_JMX_OPTS="" JMX_PORT=9955 kafka-topics.sh --alter --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092  --topic test --partitions 3 --command-config /opt/bitnami/kafka/config/producer.properties
```

### 5.2、kafka离线升级

kafka2.8.1版本有漏洞，需要升级到2.8.2版本，升级方式:



#### 5.2.1、硬升级

但是现在bitnami/kafka还没有2.8.2版本，因此下面的升级脚本不可行，需要等待官方升级才可用此方式



准备镜像（在**可连网的机器上**完成）：

```bash
# 下载镜像
docker pull bitnami/kafka:2.8.2
# 导出镜像
docker save bitnami/kafka:2.8.2 > kafka2.8.2.image
# 将文件上传到服务器
```

在**安装节点**执行：

```bash
# 第一步：停止kafka
sh bin/stop_kafka.sh
# 第二步：修改安装脚本中的kafka的版本号改为2.8.2(此步骤若不重装，无太大意思)
sed -i 's/2.8.1/2.8.2/g' step3_install_kafka.sh
```

在**kafka三台工作节点**上执行：

```bash
# 导入镜像
docker load < kafka2.8.2.image
# 在kafka的三台服务器上执行，修改版本号：,修改完成后，可检查run.sh中版本号是否已修改
sed -i 's/2.8.1/2.8.2/g' {安装路径}/kafka/run.sh
```

在**安装节点**执行：

```bash
# 启动kafka
sh bin/start_kafka.sh
```

完成后查看efak查看kafka是否正常



#### 5.2.2、软升级

若可硬升级，则用硬升级，若不能硬长，再用此法

```
# 在可连网的机器上，下载2.8.2安装包：
wget -c https://archive.apache.org/dist/kafka/2.8.2/kafka_2.12-2.8.2.tgz
# 解压后只需要`libs`目录中的数据，将libs包放到：{安装路径}/kafka/
```

在**安装节点**执行：

```bash
# 第一步：停止kafka
sh bin/stop_kafka.sh
# 等待3分钟，让kafka的停止数据刷新到了zk后，才能执行下一步
```

在**kafka三台工作节点**上执行：

```bash
cd {安装路径}/kafka/
# 将镜像中的libs目录外挂为新版本libs，请替代换变量`{安装路径}`后执行
sed -i 's@bitnami/kafka:2.8@-v {安装路径}/kafka/libs:/opt/bitnami/kafka/libs bitnami/kafka:2.8@g' run.sh
#检查一下脚本中是否新增了挂载：-v {安装路径}/kafka/libs:/opt/bitnami/kafka/libs
cat run.sh
# 检查没问题后，手动执行启动（不能用安装节点的start_kafka.sh）
sh run.sh
```

> 升级完成后，重启kafka可直接用安装节点的`start_kafka.sh`

软升级完成，登录 efak验证kafka可用性



### 5.3、efak升级

当前版本为3.0.3, 若有新版本，请替换版本号

```bash
# 下载镜像
docker pull seawenc/efak:3.0.3
# 导出镜像
docker save seawenc/efak:3.0.3 > efak3.0.3.image
# 将文件上传到服务器
```

在efak节点上执行：

```bash
docker load < efak3.0.3.image
# 修改启动脚本的版本号为3.0.3
vi  {安装路径}/efak/run.sh
# 重启
sh {安装路径}/efak/run.sh
```





## 6.efak监控与报警

efak默认账号信息为:`admin/123456`,第一次登录后记得修改密 码!

本套环境新增kafka报警通道，报警设置只支持group未消费消息报警配置； 

### 1.查看topic group未消费的数据

![topic-lag](images/efak-lag1.png)

![image-20221110142238278](images/efak-lag2.png)



### 2.监控lag参数

`lag`(滞后）是kafka消费队列性能监控的重要指标，lag的值越大，表示kafka的堆积越严重。

2.1.首先配置kafka报警通道

![image-20221110142716435](images/efak-alarm-channel.png)

2.2.配置具体的group lag报警

![image-20221110143039247](images/efak-alarm-conf.png)

配置完成后，就可看到报警的topic:`KAFKA_LAG_ALARM`已经有数据了

消息格式为:
```json
{
    "alarmContent": "{\"cluster\":\"cluster1\",\"current\":94462,\"max\":10,\"topic\":\"test\",\"group\":\"group1\"}", 
    "alarmStatus": "PROBLEM", 
    "alarmCluster": "cluster1", 
    "alarmId": 1, 
    "alarmProject": "Consumer", 
    "alarmTimes": "current(0), max(10)", 
    "alarmLevel": "P1", 
    "title": "kafka通道 alarm!", 
    "type": "kafka", 
    "alarmDate": "2022-11-10 14:09:01"
}
```
其中: `alarmContent -> current:` 为`lag`的值

### 3.监控数据输出

从版本 `seawenc/efak:3.0.3`支持，监控数据输出到kafka

```json
{
    "brokersLeaderSkewed":33,  # 以下三个参数含义：
    "brokersSkewed":0,         # https://blog.csdn.net/L13763338360/article/details/105427584
    "brokersSpread":100,
    "collectTime":"2022-11-30 10:28:00",
    "consumers":[                # 消费者信息
        {
            "consumption1m":1432,         # 1分钟内消息，此消费都消费的消息数量
            "group":"group1",             # group名称，相同的group共同消费一份数据
            "lag":99872,                  # 还剩下多少数据没有被消费
            "node":"192.168.56.12:9092",  # 它连接的是哪个节点
            "offsets":[                   # 每个分区的消费明细
                {
                    "lag":33269,            # 在分区1上，还有多少消息未被消费
                    "logSize":1,            # 没有太大意义，好像永远等于：partition的值
                    "offset":189616,        # 当前offset你部署
                    "owner":"192.168.56.1", # 消费者所在ip
                    "partition":1           # 所在分区，一个分区一条数据，
                },
                ...
            ]
        }
        ...        
    ],
    "partitions":[                # 分区明细
        {
            "isr":"[2,1]",        # 副本所在节点
            "leader":2,           # 主副本你部署
            "logSize":56217,      # 当前的数据条数
            "partitionId":0,          # 分区编号
            "preferredLeader":false,  # 是否是leader
            "replicas":"[1, 2]",      # 与isr一致（重复）
            "underReplicated":false   # 是否副本不足
        },
        ...
    ],
    "rows":168652,              # 现有数据量
    "rows1m":3242,              # 1分钟内产生的数据量，
    "storageSize":13.65,        # 所占空间大小，单位为：storagesizeUnit
    "storagesizeUnit":"MB",     # 所占空间大小的单位
    "topic":"test"              # topic名称
}
```

关于指标`rows1m`：若上一分钟数据发生清理，暂时无法解决，此值将会小于0,应用程序需自行处理此问题

默认以上监控数据会输出到topic:TOPIC_MONITOR,若想修改，则在配置文件中加入配置项,例：efak.monitor.topic=topic_monitor







