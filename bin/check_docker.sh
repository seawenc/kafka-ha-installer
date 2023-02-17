installpath=$(cd `dirname $0`;cd ../;pwd)
source $installpath/config/config.sh
source $installpath/bin/common.sh

function check_docker(){
echo "" > ~/tmp.log
for ip in `echo ${!servers[*]} | tr " " "\n" | sort`
do
  result=`ssh $ip "docker -v"`
  if [[ "${result:0:14}" = 'Docker version' ]]; then
	echo "$ip Docker状态: 已安装！" >> ~/tmp.log
  else
    echo "$ip Docker状态: 未安装！" >> ~/tmp.log
  fi	
done
sed -i '/^$/d' ~/tmp.log
cat ~/tmp.log 
}

check_docker