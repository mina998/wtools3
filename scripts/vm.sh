#!/bin/bash

# 定义工作目录
work=$(pwd)
# 切换到LSWS虚拟机配置目录
cd /usr/local/lsws/conf/vhosts
# 定义错误函数
err(){
	if [ -z $1 ]; then
		echo '域名不能为空'
		exit 0
	fi
}
# 定义绑定域名
read -p "请输入域名:" domain
# 
err $domain
# 定义虚拟主机名
read -p "输入主机名:" vmhost
#
err $vmhost
#
echo '域  名:'$domain
echo '主机名:'$vmhost

# 确认信息是否正确
read -r -p "您确定吗? [Y/n] " input

case $input in
    [yY][eE][sS]|[yY])
        echo "Yes"
        ;;
    [nN][oO]|[nN])
        echo "No"
		exit 1
        ;;
    *)
        echo "无效输入..."
        exit 1
        ;;
esac

# 判断虚拟主机目录
if [ -d $vmhost ] ; then
	echo '虚拟主机已存在'
	exit 0
fi
#创建虚拟主机配置目录
mkdir $vmhost
#下载虚拟主机配置文件
wget -O $vmhost/vhconf.conf https://github.com/mina998/test/raw/master/vhconf.conf

cd ..
#打印服务器配置
wget -qO - https://github.com/mina998/test/raw/master/http | sed -e "s/HOST_NAME/$vmhost/" -e "s/DOMAIN/$domain/"

