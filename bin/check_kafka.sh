installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

function check_kafka(){
echo "" > ~/tmp.log
for ip in `echo ${!servers[*]} | tr " " "\n" | sort` 
do
  SUCCESS_IND=`ssh $ip "docker logs kafka 2> /dev/null | grep 'started (kafka.server.KafkaServer)' | wc -l" `
  LIVE_IND=`ssh $ip "docker ps | grep kafka | wc -l"`
  zk_status="启动中！"
  [[ $SUCCESS_IND -eq 1 ]] && zk_status='启动成功'
  [[ $LIVE_IND -eq 0 ]] && zk_status='未启动'
  echo "$ip kafka启动状态: $zk_status" >> ~/tmp.log
done
echo "请等待所有节点成功启动" >> ~/tmp.log
echo "若服务已启动很久再检查状态结果将不准确，因为启动成功的日志标志已被覆盖"
echo "若启动失败，则请登录对应服务器：通过: docker log -f kafka" >> ~/tmp.log
echo "若启动失败，则请 ctrl+c后,退出安装,手动查找失败原因" >> ~/tmp.log
echo "若启动成功，则请 ctrl+c后,退出本界面，继续安装" >> ~/tmp.log

sed -i '/^$/d' ~/tmp.log
cat ~/tmp.log 
}
check_kafka
