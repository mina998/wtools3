#!/bin/bash

#################
## 远程数据库版 ##
#################

#crontab -e
#设置用户名和令牌,自动提交不需要手动输入 user为github帐号 pwd为token
#git remote set-url origin https://user:pwd@github.com/mina998/test.git


#设置本地仓库路径(站点路径)
sitecp=/site_path/
#带用户名密码远程仓库地址
repoto=https://username:password@github.com/username/repo.git
#远程分支
branch=master
#数据库名称
dbname=wordpressdb2
#数据库用户名
dbuser=soroy
#数据库密码
dbpass=463888
#数据库主机地址
dbhost=10.0.0.10
#切换工作路径
cd $sitecp
#导出数据文件名
dbfile=$dbname.sql
# 导出远程数据库函数
exportDBfile(){
	# 如果本地存在历史备份就删除
	if [ -e $dbfile ] ; then
		rm $dbfile
	fi
	#判断数据库是否存在
	if [ -z `ssh -tt root@$dbhost "mysql -u$dbuser -p$dbpass -Nse \"show DATABASES like '$dbname'\""` ] ; then
	    echo "数据库不存在"
	    exit 0
	fi
	# 远程导出MySQL数据库
	ssh -tt root@$dbhost "mysqldump -u$dbuser -p$dbpass $dbname > $dbfile"
	# 传回远程文件
	scp root@$dbhost:/root/$dbfile ./
	# 是否传回成功
	if [ ! -e $dbfile ] ; then
		echo "数据库文件传回失败"
		exit 0
	fi
	# 删除远程备份文件
	ssh -tt root@$dbhost "rm $dbfile"
}

# 初始化一个仓库
if [ -z `ls -a | grep '.git'` ] ; then
  	git config --global user.email "you@example.com"
  	git config --global user.name "Your Name"
	git init 
	git checkout -B $branch
	git remote add origin $repoto
fi

exportDBfile
git add .
git commit -m "$(date +%Y-%m-%d\#%H:%M:%S)" > /dev/null
git push origin $branch

rm $dbfile

