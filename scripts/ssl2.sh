#!/bin/bash

#申请SSL证书
certSSL(){
	# 
	if [ ! -x /usr/bin/socat ] ; then 
		apt install socat -y
	fi
	# 安装curl
	if [ ! `command -v curl` ] ; then 
		apt install curl -y
	fi
	# 判断是否安装定时任务工具
	if [ ! `command -v crontab` ] ; then
	    apt-get install cron -y
	    service cron restart
	fi
	# 下载安装证书签发程序
	if [ ! -f "/root/.acme.sh/acme.sh" ] ; then 
		curl https://get.acme.sh | sh -s email=my@example.com
	fi
	# 获取网站根目录
	read -p "请输入网站文档根目录(eg:/usr/local/lsws/wordpress/html):" siteDocRoot
	if [ ! -d $siteDocRoot ] ; then
		echo '目录不存在!'
		exit 0
	fi
	# 获取证书保存目录
	read -p "请输入证书保存目录(eg:/usr/local/lsws/wordpress/ssl):" sslSaveRoot
	if [ ! -d $sslSaveRoot ] ; then
		mkdir -P $sslSaveRoot
	fi
	# 获取域名
	read -p "请输入域名不要带3W(eg:demo.com):" domain
	if [ -z $domain ] ; then
		echo '域名不能为空!'
		exit 0
	fi
	# 获取本机IP
	local2_ip=$(curl https://api-ipv4.ip.sb/ip)
	# 获取域名解析IP
	domain_ip=$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')
	# 判断是否解析成功
	if [ "$localh_ip" = "$domain_ip" ];then
		echo "域名dns解析IP: $domain_ip"
	else
		echo "域名解析失败."
		exit 2
	fi

	# 开使申请证书
	~/.acme.sh/acme.sh --issue -d $domain -d www.$domain --webroot $siteDocRoot
	# 证书签发是否成功
	if [ ! -f "/root/.acme.sh/$domain/fullchain.cer" ] ; then 
		echo "证书签发失败."
		exit 0
	fi
	# copy/安装 证书
	~/.acme.sh/acme.sh --install-cert -d $domain --cert-file $sslSaveRoot/cert.pem --key-file $sslSaveRoot/key.pem --fullchain-file $sslSaveRoot/fullchain.pem --reloadcmd "service lsws force-reload"
	# 
	echo "证书文件: $sslSaveRoot/cert.pem"
	echo "私钥文件: $sslSaveRoot/key.pem"
	echo "证书全链: $sslSaveRoot/fullchain.pem"
}

certSSL