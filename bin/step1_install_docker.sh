installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

print_log warn "#################检查Docker安装情况#################"
sh $installpath/bin/check_docker.sh

# 获取docker镜像包名称
DOCKER_FILE_NAME=`ls $installpath/packages/ | grep docker | grep tgz`
[ -z $DOCKER_FILE_NAME ] && echo -e "\033[31m ERROR： docker离线安装失败，安装包不存在，请动下载放到packages目录 \033[0m 下载地址：https://download.docker.com/linux/static/stable/x86_64/" && exit 1

DOCKER_COMPOSE_NAME=`ls $installpath/packages/ | grep docker-compose`
[ -z $DOCKER_COMPOSE_NAME ] && print_log error "docker-compose离线安装失败，安装包不存在，请动下载docker-compose放到packages目录" && exit 1


print_log info "#################安装与启动docker#################"
function install_docker(){
sed -i "s#@DOCKER_ROOT@#$DATA_DIR/docker#g" $installpath/conf/docker/daemon.json
for ip in `echo ${!servers[*]} | tr " " "\n" | sort`
do
  print_log warn "$ip 节点安装docker"

  ssh -p $ssh_port $ip "systemctl stop docker"
  ssh -p $ssh_port $ip "rm -rf $DATA_DIR/docker /etc/docker /etc/systemd/system/docker.service /usr/bin/containerd/* /usr/bin/docker*"
  ssh -p $ssh_port $ip "mkdir -p $BASE_PATH $DATA_DIR /etc/docker $DATA_DIR/docker"
  scp -P $ssh_port -r $installpath/packages/${DOCKER_FILE_NAME} $ip:$BASE_PATH/
  scp -P $ssh_port -r $installpath/packages/docker-compose $ip:/usr/bin/
  ssh -p $ssh_port $ip "tar -zxf $BASE_PATH/${DOCKER_FILE_NAME} -C $BASE_PATH"
  ssh -p $ssh_port $ip "cp $BASE_PATH/docker/* /usr/bin/"
  scp -P $ssh_port -r $installpath/conf/docker/docker.service $ip:/usr/lib/systemd/system/
  scp -P $ssh_port -r $installpath/conf/docker/daemon.json $ip:/etc/docker/
  ssh -p $ssh_port $ip "rm -rf $BASE_PATH/${DOCKER_FILE_NAME}"
  ssh -p $ssh_port $ip "systemctl daemon-reload"
  ssh -p $ssh_port $ip "systemctl start docker"
  ssh -p $ssh_port $ip "systemctl enable docker"
  print_log info "$ip 验证docker-compose是否安装成功"
  ssh -p $ssh_port $ip "docker-compose --version"
done
}
install_docker
print_log info "#################docker已安装启动#################"
