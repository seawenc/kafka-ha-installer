installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/conf/config.sh
source $installpath/bin/common.sh

sh $installpath/bin/stop_efak.sh
sleep 5
print_log info "#################第四步:1.安装与启动监控工具-efak ###############################"
function install_efak(){
    echo "判断packages文件下是否有镜像包，如果有，则自动导入..."
    ssh -p $ssh_port $efak_ip "mkdir -p $BASE_PATH/efak $DATA_DIR/efak"
    [[ -f "$installpath/packages/efak.gz" ]] && scp -P $ssh_port $installpath/packages/efak.gz $efak_ip:$BASE_PATH/efak/
    [[ -f "$installpath/packages/efak.gz" ]] && ssh -p $ssh_port $efak_ip "gunzip -c $BASE_PATH/efak/efak.gz | docker load"
    zk_ips=`echo ${!servers[*]} |sed 's/ /:2181,/g' | awk '{print $1":2181"}'`
    print_log warn "2.1.在$efak_ip 节点安装efak"
    ssh -p $ssh_port $efak_ip "rm -rf $BASE_PATH/efak*"
    scp -P $ssh_port $installpath/conf/efak.properties $efak_ip:$BASE_PATH/efak/system-config.properties
    ssh -p $ssh_port $efak_ip "sed -i 's#@ZK_CONNECT@#${zk_ips}#g' $BASE_PATH/efak/system-config.properties"
    ssh -p $ssh_port $efak_ip "sed -i 's#@KAFKA_USER@#${zkkuser}#g' $BASE_PATH/efak/system-config.properties"
    ssh -p $ssh_port $efak_ip "sed -i 's#@KAFKA_PWD@#${zkkpwd}#g' $BASE_PATH/efak/system-config.properties"
    ssh -p $ssh_port $efak_ip "echo 'docker stop efak' > $BASE_PATH/efak/run.sh"
    ssh -p $ssh_port $efak_ip "echo 'docker rm -f efak' >> $BASE_PATH/efak/run.sh"
    ssh -p $ssh_port $efak_ip "echo 'docker run --name efak --restart=always -p 8048:8048 -d -m 3G \
                          -v ${DATA_DIR}/efak:/opt/app/efak/db \
                          -v $BASE_PATH/efak/system-config.properties:/opt/app/efak/conf/system-config.properties \
                seawenc/efak:3.0.6' >> $BASE_PATH/efak/run.sh"
    ssh -p $ssh_port $efak_ip "chmod +x $BASE_PATH/efak/run.sh"
    print_log info "开始启动efak"
    ssh -p $ssh_port $efak_ip "sh $BASE_PATH/efak/run.sh"

    print_log warn "若上面日志打印出了：'EFAK Service has started success.' 则说明安装成功"
    print_log info "访问地址http://$efak_ip:8048"
    print_log info "用户名/密码:admin/123456  ,登录成功后请及时修改密码!"
    print_log info "若登录超时，手动查看日志用以下指令：ssh -p $ssh_port $efak_ip 'docker logs -f efak'"
}
install_efak
