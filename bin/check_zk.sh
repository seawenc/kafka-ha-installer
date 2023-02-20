installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

function check_zookeeper(){
echo "" > ~/tmp.log
for ip in `echo ${!servers[*]} | tr " " "\n" | sort`
do
  ROLE_INFO=`ssh -p $ssh_port $ip "docker exec zookeeper zkServer.sh status 2>/dev/null | grep Mode" `
  LIVE_IND=`ssh -p $ssh_port $ip "docker ps | grep zookeeper | wc -l"`
  zk_status="启动失败！"
  [[ "{$ROLE_INFO}" =~ "Mode"  ]] && zk_status='启动成功'
  [[ $LIVE_IND -eq 0 ]] && zk_status='未启动'
  echo "$ip zookeeper$zk_status,$ROLE_INFO"  >> ~/tmp.log
done
echo "请等待所有节点成功启动" >> ~/tmp.log
echo "若启动失败，则请登录对应服务器：通过: docker logs -f zookeeper 查看错误信息" >> ~/tmp.log
echo "若启动失败，则请 ctrl+c后,退出安装,手动查找失败原因" >> ~/tmp.log
echo "若启动成功，则请 ctrl+c后,退出本界面，继续安装" >> ~/tmp.log

sed -i '/^$/d' ~/tmp.log
cat ~/tmp.log 
}
check_zookeeper
