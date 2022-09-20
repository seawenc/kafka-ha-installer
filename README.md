# v2.kafka-ha-docker一键安装安装使用指南
## 1.说明
本方案，需要至少三台服务器，每台服务器需要安装kafka与zookeeper，监控工具efak将安装在第一台
### 相关组件说明
**若想修改一些默认参数，请看官方说明**
* 1.zookeeper
docker地址：<https://hub.docker.com/r/bitnami/zookeeper>

* 2.kafka
docker地址：<https://hub.docker.com/r/bitnami/kafka>

* 3.efak
docker地址：<https://hub.docker.com/r/seawenc/efak>

## 2.版本更新记录

**v2.0.0**
> * 1.将安装脚本更改为docker方案安装
> * 2.添加zookeeper认证
> * 3.精简掉5个配置项
> * 4.修复efak不支持又ip配置问题
> * 5.新增kafka jmx监控
> * 6.解决ip最后一段相同时的bug

**v1.4.0**
> * 1.解决存在的两个安全问题。
> * 2.提取数据目录为可配置变量

**v1.3.0**
> * 1.添加kafka监控程序efak

## 3.安装

### 3.0.安装脚本获取
```shell script
git clone git@github.com:sewenc/kafka-ha-installer.git
```
### 3.1.目录文件说明
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
```

### 3.2.配置文件准备 
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
# kafka与zookeeper的共用一个账号密码
zkkuser='admin'
zkkpwd='aaBB1122'

# 监控工具efak安装在哪台服务器上,默认是第一台服务器，若想修改，请直接写死
efak_ip=`echo ${!servers[*]} | tr " " "\n" | sort | head -1`
##############################################################
```
* 2.`conf/efak.properties`: 监控工具efak的配置文件，**可不用修改**
* 3.`conf/jaas.conf`: jaas认证文件，若不用新加kafka用户，**则可不用修改**

### 3.3.开始安装
```shell script
# 步骤1：配置服务器之前的免密
sh bin/step1_unpwd.sh
# 步骤2：安装zookeeper
sh bin/step2_install_zk.sh
# 步骤3：安装kafka
sh bin/step3_install_kafka.sh
# 步骤4：安装efak
sh bin/step3_install_efak.sh
```
> 0. 安装过程中，请仔细阅读每一行日志
> 1. `kafka`,`zookeeper`,`efak`在`bin`目录下都有对应的一键关停/启动脚本,请按需调用
> 2. 若安装过程中状态检查未通过，则请按提示查看日志，解决后继续

### 3.4.验证安装结果

获得： step3_install_kafka.sh 此脚本的`运行过程中打印出的`**最后三句脚本**，在已安装kafka的节点上执行  
```
# 请手动在其中两台服务器，执行以下指令进入容器后进行测试可用性
docker exec -ti kafka bash
# 新建topic： test，设置分区数据为3,副本数为2
JMX_PORT=9000 kafka-topics.sh --create --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092 --topic test --partitions 3 --replication-factor 2 --command-config /opt/bitnami/kafka/config/producer.properties                                                                                                                                                                                                 
# 试消息生产者与消费者
JMX_PORT=9000 kafka-console-producer.sh --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092 --topic test --producer.config /opt/bitnami/kafka/config/producer.properties
JMX_PORT=9000 kafka-console-consumer.sh --bootstrap-server 192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092 --topic test --consumer.config /opt/bitnami/kafka/config/consumer.properties
```

**若参接收到，则安装成功**

登录efak，查看kafka状态
http://192.168.56.11:8048/
默认用户名密码：admin/123456 (**请及时修改密码**)

### 3.5.连接方式

#### 3.5.1.kafkatool工具连接
**此方式只用于查看kafka情况时用**

下载地址=<https://www.kafkatool.com/download2/offsetexplorer_64bit.exe>

##### 1.2.1.2.连接配置：
* properties-> cluster name = `mykafka（任意）`  
* properties-> kafka cluster version = `2.8`  
* security -> type = `SASL Plaintext`  
* Advanced -> Bootstrap servers= `192.168.56.11:9092,192.168.56.13:9092,192.168.56.12:9092`  
* Advanced -> SASL Mechanism= `PLAIN`  
* JAAS Config-> `org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="aaBB1122";`  

配置完成后，点击`connect`  

##### 1.2.1.3.查看数据
若需要查看topic中的数据，则点击topic，在`Properties` -> Content Types -> key和value 都设置成 String -> 点击update  

切换到`data`中后可查看数据

#### 1.2.2.java代码连接示例

##### 1.2.2.1.依赖引入
```groovy
// 以下为gradle方式引入，maven引入请自行转换为xml
compile "org.apache.kafka:kafka-clients:2.2.1"
```

##### 1.2.2.2.定义公共类-KafkaHelper
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

##### 1.2.2.3.定义消息生产者
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

##### 1.2.2.3.定义消息消费者
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
**验证：** 先启动`KafkaConsumer`,再启动`KafkaProducer`,看是否能收消息

