installpath=$(cd `dirname $0`;cd ../;pwd)

#安装包路径
PACKAGE_PATH=$installpath/packages
SHELL_PATH=$installpath

#打包日志方法,接收两个参数 级别  内容
function print_log()
{
  LEVEL=$1
  MSG=$2
  COLOR=""
  if [ $LEVEL = debug ];then
   COLOR="\033[36mDEBUG"
  fi
  if [ $LEVEL = info ];then
   COLOR="\033[32mINFO"
  fi
  if [ $LEVEL = warn ];then
   COLOR="\033[33mWARN"
  fi
  if [ $LEVEL = error ];then
   COLOR="\033[31mERROR"
  fi
  echo -e "$COLOR $MSG\033[0m"
}

ask_result=""
function ask()
{
    input_result=''
    MSG=$1
    print_log warn $MSG
    read TEMP_READ
    ask_result=$(echo $TEMP_READ | tr [a-z] [A-Z])
}