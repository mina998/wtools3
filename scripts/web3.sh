#!/bin/bash

###################
## BACKUP GITHUB ##
###################

#设置本地仓库路径(站点根路径) 后缀不加/
sitecp=/site_path
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
#导出数据文件名
dbfile=$dbname.sql.gz

#检测数据库是否存在
isDBExist(){
	#判断数据库是否存在
	if [ -z `mysql -u$dbuser -p$dbpass -Nse "show DATABASES like '$dbname'"` ] ; then
	    echo "数据库不存在"
	    exit 0
	fi
}

# 导出远程数据库函数
exportDBfile(){
	# 如果本地存在历史备份就删除
	if [ -e $dbfile ] ; then
		rm $dbfile
	fi
	#
	isDBExist
	# 导出MySQL数据库
	mysqldump -u$dbuser -p$dbpass $dbname | gzip -9 - > $dbfile
}

# 删除数据库所有表
dropDBTables(){
	isDBExist
    	conn="mysql -D$dbname -u$dbuser -p$dbpass -s -e"
    	drop=$($conn "SELECT concat('DROP TABLE IF EXISTS ', table_name, ';') FROM information_schema.tables WHERE table_schema = '${db_name}'")
    	$($conn "${drop}")
}

# 上传到GITHUB
toGithubPush(){
	#切换工作路径
	cd $sitecp
	# 初始化一个仓库
	if [ -z `ls -a | grep '.git'` ] ; then
	  	git config --global user.email "iosss@qq.com"
	  	git config --global user.name "iosss"
		git init 
		git config --global --add safe.directory $sitecp
		git checkout -B $branch
		git remote add origin $repoto
	fi

	exportDBfile
	git add .
	git commit -m "$(date +%Y-%m-%d\#%H:%M:%S)" > /dev/null
	git push origin $branch

	rm -rf .git/ $dbfile
}


huifuFormGithub(){

	#切换创建工作路径
	if [ ! -d $sitecp ] ; then
		mkdir -p $sitecp
		cd $sitecp
	else
		# .[^.]* 为隐藏文件
		cd $sitecp && rm -rf * .[^.]*
	fi

	#获取指定提交ID
	read -p "请输入要拉取指定提交ID(例:2ef3fb1), 如果留空将拉取最新代码:" rcid
	if [ -z "${rcid}" ];then
		#拉取最新代码
		git clone -b $branch --depth=1 $repoto temp
		if [ ! -d temp ];then
			echo "拉取代码失败,退出"
			exit 0
		fi
		#切换目录 移动文件
		cd temp && mv * .[^.]* ../
		#切换目录 删除目录
		cd .. && rm -rf temp
	else
		#拉取指定 提交id 或 分支 代码
		git init
		git config --global --add safe.directory $sitecp
		git remote add origin $repoto
		git fetch --all
		git reset --hard $rcid
	fi

	rm -rf .git
	#设置文件目录所有者
	chown -R nobody:nogroup wordpress/	
	#目录权限 
	find wordpress/ -type d -exec chmod 750 {} \; 
	#文件权限
	find wordpress/ -type f -exec chmod 640 {} \; 

	#检查数据库文件是否存在
	if [ ! -e $dbfile ] ; then
		echo "${dbfile}文件不存在";
		exit 0
	fi
	#
	dropDBTables
	#解压Sql文件
	gzip -d $dbfile
	#把数据导入到指定数据库
	mysql -u$dbuser -p$dbpass $dbname < $sitecp/$dbname.sql
	#
	rm $dbname.sql
	# 重新加载服务配置
	service lsws force-reload
}


menu(){
    echo "上传到GITHUB(1)  从GITHUB还原(2)"
    read -p "请选择:" num
    if [ $num -eq 1 ]; then
        toGithubPush
    else
        huifuFormGithub
    fi
}
menu