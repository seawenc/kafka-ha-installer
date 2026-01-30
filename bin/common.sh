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

function check_docker_compose() {
  # 检查 docker-compose 是否已安装
  if ! command -v docker-compose &> /dev/null; then
    print_log error "docker-compose 未安装，请先安装 docker-compose。"
    exit 1
  else
    print_log info "docker-compose 已安装，版本信息如下："
    docker-compose --version
  fi
}

# 公共函数：传输并导入任意 Docker 镜像
function transfer_and_import_image() {
  local target_ip=$1          # 目标服务器IP
  local image_name=$2         # 镜像名称（用于检查是否存在）
  local compressed_file=$3    # 压缩文件名称
  local package_path="$installpath/packages"       # 本地镜像包路径
  
  # 判断本地是否存在压缩文件
  if [[ -f "$package_path/$compressed_file" ]]; then
    print_log debug "检测到本地存在 $compressed_file 镜像包，检查远程服务器是否已存在该镜像..."
    
    # 检查远程服务器是否已有该镜像（通过镜像名称判断）
    local image_exists=$(ssh -p $ssh_port $target_ip "docker images | grep '$image_name' | wc -l")
    if [[ $image_exists -eq 0 ]]; then
      print_log info "远程服务器未找到 $image_name 镜像，开始传输并导入..."
      
      # 传输压缩文件到远程服务器
      scp -P $ssh_port "$package_path/$compressed_file" "$target_ip:/tmp/"
      
      # 解压并加载镜像
      ssh -p $ssh_port $target_ip "gunzip -c /tmp/$compressed_file | docker load"
      
      # 删除远程服务器上的临时文件
      ssh -p $ssh_port $target_ip "rm -rf /tmp/$compressed_file"
    else
      print_log debug "远程服务器已存在 $image_name 镜像，跳过传输和导入步骤。"
    fi
  else
    print_log warn "本地未找到 $package_path/$compressed_file 镜像包，请确认文件路径和名称是否正确。"
  fi
}