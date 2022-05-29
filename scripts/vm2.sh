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

# 定义虚拟主机名
read -p "输入主机名:" vmhost
#
err $vmhost
# 判断虚拟主机目录
if [ -d $vmhost ] ; then
    echo '虚拟主机已存在'
    exit 0
fi

# 定义绑定域名
read -p "请输入域名:" domain
# 
err $domain
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

#创建虚拟主机配置目录
mkdir $vmhost

#下载虚拟主机配置文件
wget -O $vmhost/vhconf.conf https://github.com/mina998/wtools/raw/lsws/vhost/vhconf.conf
#修改所有者
chown -R lsadm:nogroup $vmhost

#切换到conf目录
cd ..

# 添加虚拟主机
sed -i '/virtualHost Example{/i virtualhost '$vmhost' {' httpd_config.conf
sed -i '/virtualHost Example{/i \\t vhRoot                  '$vmhost'/' httpd_config.conf
sed -i '/virtualHost Example{/i \\t configFile              \$SERVER_ROOT/conf/vhosts/\$VH_NAME/vhconf.conf' httpd_config.conf
sed -i '/virtualHost Example{/i \\t allowSymbolLink         1' httpd_config.conf
sed -i '/virtualHost Example{/i \\t enableScript            1' httpd_config.conf
sed -i '/virtualHost Example{/i \\t restrained              0' httpd_config.conf
sed -i '/virtualHost Example{/i \\t setUIDMode              2' httpd_config.conf
sed -i '/virtualHost Example{/i\}' httpd_config.conf

# 添加SSL监听器
if grep -i 'address.*\*:443$' httpd_config.conf > /dev/null ; then
    sed -i -r '/address.*\*:443/a \\t map                     '$vmhost' '$domain httpd_config.conf
else
    sed -i '/listener Default/i listener HTTPS {' httpd_config.conf
    sed -i '/listener Default/i \\t address                 *:443' httpd_config.conf
    sed -i '/listener Default/i \\t secure                  1' httpd_config.conf
    sed -i '/listener Default/i \\t map                     '$vmhost' '$domain httpd_config.conf
    sed -i '/listener Default/i\}' httpd_config.conf
fi

# 添加HTTP监听器
if grep -i 'address.*\*:80$' httpd_config.conf > /dev/null ; then
    sed -i -r '/address.*\*:80/a \\t map                     '$vmhost' '$domain httpd_config.conf
else
    sed -i '/listener Default/i listener HTTP {' httpd_config.conf
    sed -i '/listener Default/i \\t address                 *:80' httpd_config.conf
    sed -i '/listener Default/i \\t secure                  0' httpd_config.conf
    sed -i '/listener Default/i \\t map                     '$vmhost' '$domain httpd_config.conf
    sed -i '/listener Default/i\}' httpd_config.conf
fi

# 下载证书文件
if [ ! -e example.crt ] ; then
    wget https://github.com/mina998/wtools/raw/lsws/vhost/example.crt
fi

if [ ! -e example.key ] ; then
    wget https://github.com/mina998/wtools/raw/lsws/vhost/example.key
fi

#切换到lsws目录
cd ..
# 创建虚拟机目录
if [ -d $vmhost/wordpress ] ; then
    rm -rf $vmhost/wordpress
fi
mkdir -p $vmhost/wordpress
# 写入测试文件
echo -e '<?php \n phpinfo();' > $vmhost/wordpress/index.php
# 修改权限
chown -R nobody:nogroup $vmhost/wordpress
# 重新加载服务配置
service lsws force-reload

echo "配置完成"
echo $domain