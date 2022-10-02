#!/bin/bash

# 定义OLS根路径
lsws_root=/usr/local/lsws
# 输出红颜色
echoR(){
	echo -e "\033[38;5;203m$1\033[39m"
}
# 输出绿颜色
echoG(){
    echo -e "\033[38;5;71m$1\033[39m"
}
# 安装OpenLiteSpeed默认面板
install_ols(){
	#
	if [ -e $lsws_root/bin/lswsctrl ] ; then
		echoR "OpenLiteSpeed 已存在"
		exit 0
	fi
	#添加存储库
	wget -O - http://rpms.litespeedtech.com/debian/enable_lst_debian_repo.sh | bash
	#安装面板
	apt install openlitespeed -y
	#安装WordPress 的 PHP 扩展
	if [ -e $lsws_root/lsphp74/bin/lsphp ] ; then
		#wordpress 必须组件 
		apt install lsphp74-imagick lsphp74-curl lsphp74-intl -y
	fi
	#添加监听器
	cat >> $lsws_root/conf/httpd_config.conf <<EOF
listener HTTP {
  address                 *:80
  secure                  0
}

listener HTTPs {
  address                 *:443
  secure                  1
  keyFile                 \$SERVER_ROOT/conf/example.key
  certFile                \$SERVER_ROOT/conf/example.crt
  certChain               1
}
EOF
	#创建密钥文件
	cat > $lsws_root/conf/example.key <<EOF
-----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDY173u3comhUW7
RpetWm7NAolw2PF1uMsbBCNLYaZqyxT3HgEYL+PfzXgR9qGfBJ1CAj6QToPLNsTA
lfshrwboQZRASCO1eGmv4niI5IKqvZ9GCWcQ04Sccym8rKYZEGxeNMgXQW1OptCC
bpr0+wktCcKtHRRBdStsNNL5pTvcga2SXV3s6+y14UwkYNuhP1e0iccTZrH+nA/O
9oo/tnOlejQzvCpLP/L8j4dt0D/XWXwoeTgC2uARC+rc2Da0CrmEzXyOJfVFh/6J
Y4Qnt1JNIj6CefzO7lIlnvWlELCSvO84tEeAcxo+oo2v88sIOkEnClVo+KyPIwSk
I/ot5g73AgMBAAECggEBALT8fP7eB1fXbLg+12JNVKWwNF8H86E6N+u4rGzCeFAy
aLFJTciOUDgAGvODUqqTA16Q2P9BSSdX8yh7Bjy7BZzc/4wXqhZRBoVTFR/M+nLg
Cgw+1NNqeAjM5k0gHRJWbtzCWS9v4HgBK49yGcvXq3T37JDo8Hsh/Lg37s+HZktI
N5fOFn2wX8V1ey/AXOtBWTpHATCkcl07iI74XBnpUHV0Zj+elrvVliwtxGJYgOqX
2PGmV0zEkFP/ntgahTqlGVkZhbX+A4CZnzatdGTzBh9GAdwj38Ka95GoOyg0Ykum
GyleKa9JaiFLlmgTDJBfMJxm+x/kSdrEV7wZGsWilIECgYEA9ffTZLPQ12WqfZWC
ofU6Bif/79ZA7r99MyzXy+/PJ6G/TLjbvMx1neB8XQIqD8D6775hVUi9HHyfPsaD
ZVfiRNK4SuHT0Dv50QkAvzFAtWzqotglsNXCfPU83bcx2T1/RVOYnlWqKHOlAVBG
PXqP1XwsgIAIJB+GL6zCLGzDgQcCgYEA4a/Q6aYZxBib5LeWOVFsM/kAssrHD7YK
rEkoLsqu60YbtU88WiCNCGeElt3bhoEldCol6+KqQTC4cEvArYrpEaet+dUwRc3o
QrqaURw+XNd5Z5NQXbCZPiHNDrKyoX5GHLC0KSam54WC6cCMc9Wb45dv0JJ0Xy5O
U3UQ7/ZZtpECgYEAg6P+ZGAEfrNvusTA5HM9ebwAs1jE6cJcfH4chI41HW3o12P8
XqBCtptFk/Wrk0DiTFtk9mL2q39bLxrJifyuIc1xSspwNXtT6XdbCfiPPEotjbgG
/Ax7iasqxzLbn/vU2MKz5NHOPtYd0oUnApJM1qIdoyxirwqcI3nfdi1DuRMCgYEA
w8LstO8GJImwF8mDPf65m69egrfPyXn/cggXGddnuN7cQ/4R/J+FlgetA+w3cklt
woCY2i6HvfpT0dxzqlT27ACFsVLSB4qe79rK5pZYJdImFci7ijkYA8PwCdLJjblp
eZNxAszrM6Iktzv02Lkt+lGuhL20wab5+/xsj6khknECgYAJw11ETf9YG3Dw0xjB
sdvPPVoEMYJ95vuFZ+YUHIbH/DHn4Cy1eV3EXZDcyB+Ans7dRblpqlvHtiJZ+1dF
Dmq1OFdVx+2zLbK6PP12FxFfXC1fYAvYlsJ7mytfCHP0d5AYXinmBk0pZlMsMj9D
jUymkTMOYhu36bRDxkgfmYCULQ==
-----END PRIVATE KEY-----
EOF
	#创建证书文件
	cat > $lsws_root/conf/example.crt <<EOF
-----BEGIN CERTIFICATE-----
MIIEKzCCAxOgAwIBAgIUUiLPI97ZglU0zg34sf7NQgqIHHgwDQYJKoZIhvcNAQEL
BQAwgcIxDjAMBgNVBAMMBXZ1bHRyMQswCQYDVQQGEwJVUzEQMA4GA1UEBwwHVmly
dHVhbDEbMBkGA1UECgwSTGl0ZVNwZWVkQ29tbXVuaXR5MRAwDgYDVQQLDAdUZXN0
aW5nMRMwEQYDVQQIDApOZXcgSmVyc2V5MRAwDgYJKoZIhvcNAQkBFgEuMRYwFAYD
VQQpDA1vcGVubGl0ZXNwZWVkMQswCQYDVQQrDAJDUDEWMBQGA1UELhMNb3Blbmxp
dGVzcGVlZDAeFw0yMjEwMDEwNTM3MjRaFw0yNDEyMjkwNTM3MjRaMIHCMQ4wDAYD
VQQDDAV2dWx0cjELMAkGA1UEBhMCVVMxEDAOBgNVBAcMB1ZpcnR1YWwxGzAZBgNV
BAoMEkxpdGVTcGVlZENvbW11bml0eTEQMA4GA1UECwwHVGVzdGluZzETMBEGA1UE
CAwKTmV3IEplcnNleTEQMA4GCSqGSIb3DQEJARYBLjEWMBQGA1UEKQwNb3Blbmxp
dGVzcGVlZDELMAkGA1UEKwwCQ1AxFjAUBgNVBC4TDW9wZW5saXRlc3BlZWQwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDY173u3comhUW7RpetWm7NAolw
2PF1uMsbBCNLYaZqyxT3HgEYL+PfzXgR9qGfBJ1CAj6QToPLNsTAlfshrwboQZRA
SCO1eGmv4niI5IKqvZ9GCWcQ04Sccym8rKYZEGxeNMgXQW1OptCCbpr0+wktCcKt
HRRBdStsNNL5pTvcga2SXV3s6+y14UwkYNuhP1e0iccTZrH+nA/O9oo/tnOlejQz
vCpLP/L8j4dt0D/XWXwoeTgC2uARC+rc2Da0CrmEzXyOJfVFh/6JY4Qnt1JNIj6C
efzO7lIlnvWlELCSvO84tEeAcxo+oo2v88sIOkEnClVo+KyPIwSkI/ot5g73AgMB
AAGjFzAVMBMGA1UdJQQMMAoGCCsGAQUFBwMBMA0GCSqGSIb3DQEBCwUAA4IBAQCz
pGTlrIS6jp72sRw233L3S6xpb3PQLsbCFCOKrPSRT/d9hgP0TBwIDdPU2z2rbZp2
ZwOO1ncOBaljSjtR5ad5KJ2k9XDY4sO5Wf+pMizIKCYL0RD2Z2gfG8vLeSXMnL/i
K5ttO3uv8cBL7iHL/xagOfIF57ItEuYNVdwa2CtIShiPROq3ivERiZhlh+QQnCr1
83BQCzUu/CmwiwYqbPqzACSHyko6Z47l0CUyADi3SuaHWQ/cjFhhQEidreF2cKkB
6gC/szDUXknfSs5vx0/NtWcLeEiLqFvp9dMTO/DnjPSJJaZa2ZJckgdC+LMEsZ6F
A5haZyZkvQTsUO/zv4gh
-----END CERTIFICATE-----
EOF
	cd ~
	#重新加载配置
	service lsws force-reload
}

# 安装MariaDB数据库服务
install_maria_db(){
	#判断是否安装过MariaDB
	if [ -e /usr/bin/mariadb ] ; then
		echoR "MariaDB 已存在"
		exit 0
	fi
	#获取系统名称
	os_name=$(cat /etc/os-release | grep ^ID= | cut -d = -f 2)
	#获取系统版本
	os_ver=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d = -f 2)
	#添加密钥
	curl -o /etc/apt/trusted.gpg.d/mariadb_release_signing_key.asc 'https://mariadb.org/mariadb_release_signing_key.asc'
	#选择系统
	sh -c "echo 'deb https://mirrors.gigenet.com/mariadb/repo/10.5/$os_name $os_ver main' >>/etc/apt/sources.list"
	#开始安装
	apt install mariadb-server -y
	# 重启防止出错
	systemctl restart mariadb
}

# 安装WordPress
install_wp(){
	#判断是否安装OLS
	if [ ! -e $lsws_root/bin/lswsctrl ] ; then
		echoR "OpenLiteSpeed 不存在"
		exit 0
	fi
	#接收用户输入
	read -p "请输入域名(eg:www.demo.com):" domain
	if [ -z $domain ]; then
		echoR '域名为空'
		exit 0
	fi
	#检测网站是否存在
	if [ -d $lsws_root/$domain ]; then
		echoR '网站已存在!'
		exit 0
	fi
	#判断域名是否有解析
	if (ping -c 2 $domain &>/dev/null); then
    	#获取本机IP
		local2_ip=$(curl -s http://ip.42.pl/raw -A Mozilla)
		#获取域名解析IP
		domain_ip=$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')
	else 
        echoR '目标地址空或者目标地址访问不通，请检查'
        exit 0
	fi
	#判断是否解析成功
	if [[ $local2_ip = $domain_ip ]] ; then
		echoR "域名dns解析IP: $domain_ip"
	else
		echoR "域名解析失败."
		exit 0
	fi
	#切换工作路径
	cd $lsws_root
	#创建网站根目录和SSL目录
	mkdir -p $domain/ssl && cd $domain
	#下载WP程序
	wget https://wordpress.org/latest.tar.gz
	#解压WP程序 并删除压缩文件
	tar -xf latest.tar.gz && rm latest.tar.gz
	#修改文件目录所有者
	chown -R nobody:nogroup wordpress/
	#目录权限
	find wordpress/ -type d -exec chmod 750 {} \;
	#文件权限
	find wordpress/ -type f -exec chmod 640 {} \;
	#创建网站配置目录
	cd .. && mkdir conf/vhosts/$domain
	#添加网站配置文件
	cat > conf/vhosts/$domain/vhconf.conf <<EOF
docRoot                   \$VH_ROOT/wordpress

index  {
  useServer               0
  indexFiles              index.php
}

context / {
  location                \$DOC_ROOT
  allowBrowse             1
  indexFiles              index.php

  rewrite  {
    enable                1
    inherit               1
    rewriteFile           .htaccess
  }
}

rewrite  {
  enable                  1
  autoLoadHtaccess        1
}

vhssl  {
  keyFile                 \$VH_ROOT/ssl/key.pem
  certFile                \$VH_ROOT/ssl/fullchain.pem
  certChain               1
}
EOF
	#添加OLS主配置文件
	cat >> conf/httpd_config.conf <<EOF
virtualhost $domain {
vhRoot                  $domain
configFile              conf/vhosts/$domain/vhconf.conf
allowSymbolLink         1
enableScript            1
restrained              0
setUIDMode              2
}
EOF
	#添加网站端口
	sed -i "/listener HTTPs {/a\map        $domain $domain" conf/httpd_config.conf
	sed -i "/listener HTTP {/a\map         $domain $domain" conf/httpd_config.conf
	#切换工作目录
	cd conf/vhosts 
	#设置权限
	chown -R lsadm:nogroup $domain
	#重启服务
	service lsws restart
	#切换工作目录
	cd ~
	#设置数据库变量
	db_name="d`random_str`"
	db_user="u`random_str 12`"
	#检测数据库是否存在
	isDBExist $db_name
	#创建数据库和用户
	mysql -Nse "create database $db_name"
	mysql -Nse "grant all privileges on $db_name.* to '$db_user'@'%' identified by '$db_user'"
	mysql -Nse "flush privileges"
	#删除存在的文件
	if [ -e $domain.admin ];then
		rm $domain.admin
	fi
	echo "DB Name: $db_name" >> $domain.admin
	echo "DB User: $db_user" >> $domain.admin
	echo "DB Pass: $db_user" >> $domain.admin
	cat $domain.admin
}

#检测数据库是否存在
isDBExist(){
    #判断数据库是否存在
    if [ ! -z `mysql -Nse "show DATABASES like '$1'"` ] ; then
       echoR "数据库已存在"
       exit 0
    fi
}

# 创建随机字符 最长32位
random_str(){
	if [ -z $1 ]; then
		echo $RANDOM |md5sum |cut -c 1-10
	else 
		echo $RANDOM |md5sum |cut -c 1-$1
	fi
}

# 安装phpMyAdmin
install_php_my_admin(){
	#
	if [ ! -d /usr/local/lsws/Example ]; then
		echoR '目录不存在!'
		exit 0
	fi
	#切换工作目录
	cd /usr/local/lsws/Example
	#下载phpMyAdmin程序
	wget https://files.phpmyadmin.net/phpMyAdmin/4.9.10/phpMyAdmin-4.9.10-all-languages.zip
	#解压文件
	unzip phpMyAdmin-4.9.10-all-languages.zip > /dev/null 2>&1
	#删除文件
	rm phpMyAdmin-4.9.10-all-languages.zip
	#重命名文件夹
	mv phpMyAdmin-4.9.10-all-languages phpMyAdmin
	#切换目录
	cd phpMyAdmin
	#创建临时目录 并 设置权限
	mkdir tmp && chmod 777 tmp
	#创建Cookie密钥
	keybs="`random_str 32``random_str 32`"
	#修改配置文件1
	sed -i "/\$cfg\['blowfish_secret'\]/s/''/'$keybs'/" config.sample.inc.php
	#
	cd libraries
	#修改配置文件2
	sed -i "/\$cfg\['blowfish_secret'\]/s/''/'$keybs'/" config.default.php
	#导入sql文件
	mysql < /usr/local/lsws/Example/phpMyAdmin/sql/create_tables.sql
	#添加访问路径
	cat >> /usr/local/lsws/conf/vhosts/Example/vhconf.conf <<EOF
context /phpMyAdmin {
  location                \$VH_ROOT/phpMyAdmin
  allowBrowse             1
  indexFiles              index.php
  rewrite  {
  }
  addDefaultCharset       off
  phpIniOverride  {
  }
}
EOF
	#重启服务
	service lsws restart
	#
	local2_ip=$(curl -s http://ip.42.pl/raw -A Mozilla)
	#
	echoR "访问地址: http://$local2_ip:8088/phpMyAdmin"
}

# 申请SSl证书
cert_ssl(){
	#获取输入
	read -p "请输入域名(eg:www.demo.com):" domain
	if [ ! -d $lsws_root/$domain ]; then
		echoR '站点不存在!'
		exit 0
	fi
	#下载安装证书签发程序
	if [ ! -f "/root/.acme.sh/acme.sh" ] ; then 
		curl https://get.acme.sh | sh -s email=my@example.com
	fi
	#设置变量
	siteDocRoot=$lsws_root/$domain/wordpress
	siteSSLSave=$lsws_root/$domain/ssl
	#开使申请证书
	~/.acme.sh/acme.sh --issue -d $domain --webroot $siteDocRoot
	#证书签发是否成功
	if [ ! -f "/root/.acme.sh/$domain/fullchain.cer" ] ; then 
		echoR "证书签发失败."
		exit 0
	fi
	#copy/安装 证书
	~/.acme.sh/acme.sh --install-cert -d $domain --cert-file $siteSSLSave/cert.pem --key-file $siteSSLSave/key.pem --fullchain-file $siteSSLSave/fullchain.pem --reloadcmd "service lsws force-reload"
	# 
	echoR "证书文件: $siteSSLSave/cert.pem"
	echoR "私钥文件: $siteSSLSave/key.pem"
	echoR "证书全链: $siteSSLSave/fullchain.pem"
}

# 创建防火墙规则
creat_firewall_rule(){
	#清空原有规则
	iptables -F
	#创建保存新规则
	cat > /etc/iptables.rules <<FIREWALL
*filter
:INPUT DROP
:FORWARD ACCEPT
:OUTPUT ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m multiport --dports 22,80,443 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 7080 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 8088 -j ACCEPT
COMMIT
FIREWALL
	#创建重启自动加载规则
	cat > /etc/rc.local <<rcL
#!/bin/bash
/sbin/iptables-restore < /etc/iptables.rules
exit 0
rcL
	chmod +x /etc/rc.local
	#启动服务
	systemctl start rc-local
}

# 重置面板用户名和密码
reset_ols_user_password(){
	bash /usr/local/lsws/admin/misc/admpass.sh
}

# 安装LSMCD缓存模块
install_lsmcd(){
	echoR "安装LSMCD模块最少需要4G内存"
	mem_total=`free | awk '/Mem/ {print $2}'`
	echoR "当前系统内存大小: $mem_total"
	if [[ $mem_total -lt 4190000 ]]; then
		echoR "无法安装"
		exit 0
	fi
}

menu(){
	echoG "(1)创建防火墙规则"
	echoG "(2)安装OpenLiteSpeed 和 MariaDB"
	echoG "(3)添加WP站点"
	echoG "(4)申请SSL证书"
	echoG "(5)重置面板用户名和密码"
	echoG "(6)安装phpMyAdmin"
	echoG "(7)安装LSMCD缓存模块"

	read -p "请选择:" num
	if [ $num -eq 1 ]; then
		creat_firewall_rule
	elif [ $num -eq 2 ] ; then
		#
		apt update
		#安装所需工具
		apt-get install socat cron iputils-ping apt-transport-https -y
		install_ols
		install_maria_db
	elif [ $num -eq 3 ] ; then
		install_wp
	elif [ $num -eq 4 ] ; then
		cert_ssl
	elif [ $num -eq 5 ] ; then
		reset_ols_user_password
	elif [ $num -eq 6 ] ; then
		install_php_my_admin
	else
		echoR "输入无效"
		exit 0
	fi
}

echoR "该脚本只兼容Debian系列[9, 10, 11] 和 Ubuntu系统[18.04, 20.04] 其他系统未测试"

menu

