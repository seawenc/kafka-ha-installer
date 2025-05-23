installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

print_log warn "#################第二步:安装zookeeper ###############################"
print_log info "#################第二步:1.关停已启动的zookeeper ###############################"
bash $installpath/bin/stop_zk.sh
sleep 3
print_log info "#################第二步:2.安装zookeeper ###############################"
function install_zk(){
# 第一种格式适用于bitnami/zookeeper:3.8,第二种格式适用于zookeeper:3.6.3
ZOO_SERVERS=`cat $installpath/conf/config.sh| grep 'servers\["' | sort | awk -F '"' '{print $2":2888:3888"}'| tr "\n" "," | sed 's/.$//'`
#ZOO_SERVERS=`cat ../conf/config.sh| grep 'servers\["' | awk -F '"' '{print "server."NR"="$2":2888:3888;2181"}'| tr "\n" " " | sed 's/.$//'`


#ZOO_SERVERS="zk1:2888:3888,zk2:2888:3888,zk3:2888:3888"
echo "ZOO_SERVERS=${ZOO_SERVERS};"
FOR_SEQ=1
# 不能直接用数组进行循环，因为zookeeper要求myid，与启动顺序有序，而直接数组无序
for ip in `echo ${!servers[*]} | tr " " "\n" | sort` 
do
  echo "判断packages文件下是否有镜像包，如果有，则自动导入..."
  ssh -p $ssh_port $ip  "mkdir -p $DATA_DIR/zookeeper $BASE_PATH/zookeeper/conf $BASE_PATH/zookeeper/logs"
  ssh -p $ssh_port $ip  "chmod 777 $DATA_DIR/zookeeper"
  [[ -f "$installpath/packages/zk.gz" ]] && scp -P $ssh_port $installpath/packages/zk.gz $ip:$BASE_PATH/zookeeper/
  [[ -f "$installpath/packages/zk.gz" ]] && ssh -p $ssh_port $ip "gunzip -c $BASE_PATH/zookeeper/zk.gz | docker load"
  [[ -f "$installpath/packages/zk.gz" ]] && ssh -p $ssh_port $ip "rm -rf $BASE_PATH/zookeeper/zk.gz"

  print_log warn "2.1.在$ip 节点安装zookeeper"
  ## 写入集群节点信息
  print_log info "开始启动$ip 的zookeeper"
  ssh -p $ssh_port $ip  "rm -rf $BASE_PATH/zookeeper/*"
  ssh -p $ssh_port $ip  "chmod 777 -R $BASE_PATH/zookeeper"
  ssh -p $ssh_port $ip "echo 'docker stop zookeeper' > $BASE_PATH/zookeeper/run.sh"
  ssh -p $ssh_port $ip "echo 'docker rm zookeeper' >> $BASE_PATH/zookeeper/run.sh"
  ssh -p $ssh_port $ip "echo 'docker run --name zookeeper -ti -d \
           --restart=unless-stopped \
           --net=host \
           -v $DATA_DIR/zookeeper:/bitnami/zookeeper \
           -e ZOO_SERVER_ID=${FOR_SEQ} \
           -e ZOO_LISTEN_ALLIPS_ENABLED=yes \
           -e ALLOW_ANONYMOUS_LOGIN=no \
           -e ZOO_ENABLE_AUTH=yes \
           -e ZOO_SERVER_USERS=\"admin\" \
           -e ZOO_SERVER_PASSWORDS=\"${admin_user_pwd}\" \
           -e ZOO_CLIENT_USER=\"admin\" \
           -e ZOO_CLIENT_PASSWORD=${admin_user_pwd} \
           -e JVMFLAGS=\"-Dzookeeper.electionPortBindRetry=50\" \
           -e ZOO_SERVERS=\"${ZOO_SERVERS}\" \
            bitnami/zookeeper:3.6.3' >> $BASE_PATH/zookeeper/run.sh"
  ssh -p $ssh_port $ip "chmod +x $BASE_PATH/zookeeper/run.sh"
  ssh -p $ssh_port $ip "sh $BASE_PATH/zookeeper/run.sh"
  let FOR_SEQ+=1
done
}
install_zk
print_log info "########第二步:3.等待zookeeper启动,每10秒更新一次状态 ##########################"
sleep 10
watch -n 10 -d bash $installpath/bin/check_zk.sh

print_log info "若需要调试zookeeper，执行以下指令安装ui（此ui存在弱密码，调试完成请删除）"
ZK_SVC=`cat $installpath/conf/config.sh| grep 'servers\["' | awk -F '"' '{print $4":2181"}'| tr "\n" "," | sed 's/.$//'`
echo "docker run -d --name zkui -p 9090:9090 -e ZK_SERVER=${ZK_SVC} juris/zkui:latest"
