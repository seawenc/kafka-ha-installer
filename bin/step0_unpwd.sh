installpath=$(cd `dirname $0`;cd ../;pwd)
echo "installpath=$installpath"
source $installpath/conf/config.sh
source $installpath/bin/common.sh

print_log info "#################第0步:开始进行免密登录###################################"
print_log info "####1.开始生成免密文件"
rm -rf ~/.sshbak && mv ~/.ssh ~/.sshbak && mkdir ~/.ssh && cd ~/.ssh
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa > /dev/null
cat id_rsa.pub > authorized_keys
cat > ~/.ssh/config << EOF
Host *
  StrictHostKeyChecking no
EOF
chmod 600 authorized_keys
chmod 600 config
chmod 700 ../.ssh
#echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config

## 如果ranger,mysql,efak,nginx需要安装，则找出对应组件的ip
RANGER_HOST=$ranger_host
MYSQL_HOST=`[ "$mysql_need_install" = "true" ] && echo "\n$mysql_host" || echo ''`
EFAK_HOST=`[ "$efak_need_install" = "true" ] && echo "\n$efak_host" || echo ''`
NGINX_HOST=`[ "$nginx_need_install" = "true" ] && echo "\n$nginx_host" || echo ''`

function scp_ssh(){
for ip in `echo -e "${!servers[*]}${MYSQL_HOST}${RANGER_HOST}${EFAK_HOST}" | tr " " "\n" | sort | uniq`
do
  print_log warn "2.1.请输入节点:$ip 的密码,进行免密配置:"
  scp -P $ssh_port -r ~/.ssh $ip:~/
  ssh -p $ssh_port $ip "mkdir -p $BASE_PATH $DATA_DIR"
  #ssh -p $ssh_port $ip "rm -rf $BASE_PATH/kafka*"
  #ssh -p $ssh_port $ip "rm -rf $BASE_PATH/zookeeper*"
done
}

print_log info "####2.开始将免密码文件同步到各节点"
scp_ssh
print_log info "########第一步:免密码登录配置完成#########################################"

