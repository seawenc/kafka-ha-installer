installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

function check_kafka(){
echo "------------节点状态列表------------------" > ~/tmp.log
for ip in `echo ${!servers[*]} | tr " " "\n" | sort` 
do
  # 先判断是否启动
  LIVE_IND=`ssh -p $ssh_port $ip "docker ps | grep kafka | wc -l"`
  if [[ $LIVE_IND -eq 0 ]]; then 
    echo "$ip kafka启动状态: 未启动" >> ~/tmp.log
    continue
  fi
  
  # 判断启动成功
  SUCCESS_IND=`ssh -p $ssh_port $ip "docker logs kafka 2> /dev/null | grep 'Kafka Server started' | wc -l"`
  if [[ $SUCCESS_IND -eq 1 ]]; then
    echo "$ip kafka启动状态: 启动成功" >> ~/tmp.log
    continue
  fi
  
  # 最后看看有没有错误信息
  kafka_error_msg=`ssh -p $ssh_port $ip "docker exec kafka /bin/bash /check.sh 2>&1"`
  if [[ -n "$kafka_error_msg" ]]; then
    echo -e "$ip kafka启动异常:\n $kafka_error_msg" >> ~/tmp.log
  else
    echo "$ip kafka启动状态: 启动成功" >> ~/tmp.log
  fi
done
echo "------------节点状态列表------------------" >> ~/tmp.log
echo "请等待所有节点成功启动" >> ~/tmp.log
echo "若启动失败，则请登录对应服务器：通过: docker logs -f kafka" >> ~/tmp.log
echo "若启动失败，则请 ctrl+c后,退出安装,手动查找失败原因" >> ~/tmp.log
echo "若启动成功，则请 ctrl+c后,退出本界面，继续安装" >> ~/tmp.log
echo "可自行进入容器通过查询topic列表以验证kafka是否正常" >> ~/tmp.log
echo "docker exec -ti kafka /bin/bash" >> ~/tmp.log
echo "kafka-topics.sh --list --bootstrap-server \$SERVERS  --command-config /client.properties" >> ~/tmp.log

sed -i '/^$/d' ~/tmp.log
cat ~/tmp.log 
}

check_kafka