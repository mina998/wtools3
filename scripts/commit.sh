#!/bin/bash

#crontab -e
#设置用户名和令牌,自动提交不需要手动输入 user为github帐号 pwd为token
#git remote set-url origin https://user:pwd@github.com/mina998/test.git

#设置本地仓库路径(站点路径)
sitecp=/site_path/
#带用户名密码远程仓库地址
repoto=https://username:password@github.com/username/repo.git
#分支名称
branch=master
#数据库名称
dbname=wordpressdb2
#数据库用户名
dbuser=soroy
#数据库密码
dbpass=463888
#切换工作路径
cd $sitecp
#导出数据文件名
dbfile=$dbname.sql.gz
# 导出远程数据库函数
exportDBfile(){
	# 如果本地存在历史备份就删除
	if [ -e $dbfile ] ; then
		rm $dbfile
	fi
	#判断数据库是否存在
	if [ -z `mysql -u$dbuser -p$dbpass -Nse "show DATABASES like '$dbname'"` ] ; then
	    echo "数据库不存在"
	    exit 0
	fi
	# 导出MySQL数据库
	mysqldump -u$dbuser -p$dbpass $dbname | gzip -9 - > $dbfile
}

# 初始化一个仓库
if [ -z `ls -a | grep '.git'` ] ; then
  	git config --global user.email "iosss@qq.com"
  	git config --global user.name "soroy"
	git init 
	git checkout -B $branch
	git remote add origin $repoto
fi

exportDBfile

git add .
git commit -m "$(date +%Y-%m-%d\#%H:%M:%S)" > /dev/null
git push origin $branch

rm $dbfile

