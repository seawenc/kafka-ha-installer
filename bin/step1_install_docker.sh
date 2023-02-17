installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh



print_log warn "#################检查Docker安装情况#################"
sh $installpath/bin/check_docker.sh

print_log info "#################安装与启动docker#################"
function install_docker(){
sed -i "s#@DOCKER_ROOT@#$DATA_DIR/docker#g" $installpath/conf/docker/daemon.json
for ip in `echo ${!servers[*]} | tr " " "\n" | sort`
do
  print_log warn "$ip 节点安装docker"
  ssh $ip "systemctl stop docker"
  ssh $ip "rm -rf $DATA_DIR/docker /etc/docker /etc/systemd/system/docker.service /usr/bin/containerd/* /usr/bin/docker*"
  scp -r $installpath/packages/docker-${DOCKER_VERSION}.tgz $ip:$BASE_PATH/
  ssh $ip "tar -zxf $BASE_PATH/docker-${DOCKER_VERSION}.tgz -C $BASE_PATH"
  ssh $ip "cp $BASE_PATH/docker/* /usr/bin/"
  scp -r $installpath/conf/docker/docker.service $ip:/usr/lib/systemd/system/
  ssh $ip "mkdir -p /etc/docker $DATA_DIR/docker"
  scp -r $installpath/conf/docker/daemon.json $ip:/etc/docker/
  ssh $ip "rm -rf $BASE_PATH/docker-${DOCKER_VERSION}.tgz"
  ssh $ip "systemctl daemon-reload"
  ssh $ip "systemctl start docker"
  ssh $ip "systemctl enable docker"
done
}

install_docker
print_log info "#################docker已安装启动#################"
