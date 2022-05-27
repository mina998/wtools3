# OpenLiteSpeed 设置


+ ### OpenLiteSpeed

    ##### 添加存储库
    ```Shell
    wget -O - http://rpms.litespeedtech.com/debian/enable_lst_debian_repo.sh | bash
    ```

    ##### 安装指定版本
    如果需要安装最新版,去掉后面版本号: openlitespeed
    ```Shell
    apt install openlitespeed-1.7.15
    ```

    ##### 安装PHP[可选]
    如果默认版本不符合要求,可以安装指定版本PHP和扩展, 以下命令中的74代表PHP版本号
    ```Shell
    apt install lsphp74 lsphp74-common lsphp74-mysql lsphp74-opcache lsphp74-imap
    #wordpress 必须组件 
    apt install lsphp74-imagick lsphp74-curl lsphp74-intl -y

    ln -sf /usr/local/lsws/lsphp73/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5
    ```

    ##### 启动服务
    ```
    systemctl start lsws
    ```

    ##### 防火墙设置 [可选]
    ```Shell
    #如果服务器有防火墙需要设置放行端口 
    iptables -I INPUT -p tcp --dport 80 -j ACCEPT #单端口
    iptables -I INPUT -p tcp -m multiport --dports 22,80,443,7080,8088 -j ACCEPT #多端口
    #保存规则
    iptables-save > /etc/iptables.rules  
    ````

    ````Shell
    #重启自动加载 编辑(创建) /etc/rc.local 文件  添加以下代码

    #!/bin/sh -e
    /sbin/iptables-restore < /etc/iptables.rules
    exit 0
    ````    
    ```Shell
    #添加执行权限
    chmod +x /etc/rc.local
    systemctl enable re-local #报错参考 https://blog.csdn.net/qq_17802895/article/details/114289172
    systemctl start re-local
    ```

    ##### 访问面板
    ```Shell
    https://[address]:7080/
    ```


+ ### MariaDB

    ##### 安装依赖和密钥
    ```Shell
    apt-get install software-properties-common dirmngr apt-transport-https
    apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
    ```

    ##### 添加存储库
```Shell
#ubuntu 18.04
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mirrors.gigenet.com/mariadb/repo/10.5/ubuntu bionic main'

#ubuntu 20.04
add-apt-repository 'deb [arch=amd64,arm64,ppc64el,s390x] https://mirrors.gigenet.com/mariadb/repo/10.5/ubuntu focal main'

#debian 9
add-apt-repository 'deb [arch=amd64,i386,ppc64el,arm64] https://mirrors.gigenet.com/mariadb/repo/10.5/debian stretch main'

#debian 10
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mirrors.gigenet.com/mariadb/repo/10.5/debian buster main'

#debian 11
add-apt-repository 'deb [arch=amd64,i386,arm64,ppc64el] https://mirrors.gigenet.com/mariadb/repo/10.5/debian bullseye main'
```

    ##### 安装
    ```Shell
    apt update
    apt install mariadb-server
    ```

    ##### 安全配置向导
    ```Shell
    systemctl restart mariadb
    mysql_secure_installation
    ```

    ##### 向导说明
    ```Shell
    Enter current password for root (enter for none):   #提示你输入root密码, 没有密码, 直接回车
    Switch to unix_socket authentication [Y/n] n        #是否切换到unix套接字身份验证[Y/n]
    Change the root password? [Y/n]                     #是否为 root 用户设置密码,输入n, 用户默认使用auth_socket进行鉴权
    Remove anonymous users? [Y/n] Y                     #删除匿名用户
    Disallow root login remotely? [Y/n] Y               #禁止root用户远程登陆
    Remove test database and access to it? [Y/n] Y      #删除测试数据库
    Reload privilege tables now? [Y/n] Y                #重新加载权限表
    ```


+ ### MySQL常用命令

    ##### MySQL数据库操作
    ```Shell
    show databases;         #查看所有数据库
    create database dbname; #新建数据库
    drop database dbname;   #删除数据库

    #导入MySQL数据1
    mysql > use db_name 
    mysql > source /path/aaaa.sql

    #导入MySQL数据2
    mysql -uroot -p dbname < /path/aaaa.sql

    #导出MySQL数据 指定用户密码
    mysqldump -uusername -ppassword dbname | gzip -9 - > dbname.sql.gz

    #导出MySQL数据 无密码不压缩
    mysqldump dbname > dbname.sql

    #解压SQL文件
    gzip -d  aaaa.sql.gz 

    ```

    ##### MySQL用户操作
    ```Shell
    mysql
    #添加一个管理员并设置密码
    GRANT ALL PRIVILEGES ON *.* TO 'admini'@'localhost' IDENTIFIED BY '设置的密码' WITH GRANT OPTION; 

    #添加用户
    mysql > insert into mysql.user(Host,User,Password) values("localhost","test",password("1234"));

    #更新密码
    mysql > update mysql.user set password=password('新密码') where User="test" and Host="localhost";

    #删除用户1
    mysql  >Delete FROM user Where User='test' and Host='localhost';

    #删除用户2
    drop user 'username'@'host'; 

    #授权test用户有testDB数据库的所有权限
    grant all privileges on testDB.* to 'test'@'%' identified by 'test123';

    #刷新权限
    mysql > flush privileges;

    ```

    ##### 设置远程访问
    ```Shell
    mysql
    update user set host='%' where user='admini';  #修改数据库用户主机
    flush privileges;  #刷新权限

    #修改/etc/mysql/mariadb.conf.d/50-server.cnf  28行左右 
    bind-address            = 0.0.0.0
    ```


+ ### 网站操作

    ##### 压缩解压数据,tar这里用--exclude排除文件及无用的目录
    ```Shell
    # 打包1
    tar -cvfz xxx.tar.gz  source_file
    # 打包2
    tar -C /path/webroot -zcf website.tar.gz ./

    #解压文件
    tar -zvxf web.tar.gz
    #解压到指定目录
    tar -xvfz xxx.tar.gz -C path (tar -xvfz xxx.tar.gz -C 目标路径)
    ```

    ##### 权限设置
    ```Shell
    chown -R nobody:nogroup wordpress/  #修改文件目录所有者
    find wordpress/ -type d -exec chmod 750 {} \; #目录权限
    find wordpress/ -type f -exec chmod 640 {} \; #文件权限
    ```

    ##### 使用模板添加虚拟主机
    ```Shell
    wget https://github.com/mina998/wtools/raw/lsws/scripts/vm.sh
    bash vm.sh

    #必须重启LSWS服务 并设置好文件所有者和权限
    systemctl restart lsws
    /usr/local/lsws/bin/lswsctrl restart
    ```

    ##### PHP设置
    在虚拟主机-常规-php.ini 覆盖 中添加以下代码
    ```Shell
    #限制通过POST方法可以接受的信息最大量
    php_value post_max_size = 300M
    #限制PHP处理上传文件的最大值,此值必须小于post_max_size值
    php_value upload_max_filesize = 300M
    #设置脚本可以分配的最大内存量，防止失控的脚本独占服务器内存
    php_value memory_limit = 256M #安装WooCommerce 推荐512
    ```

    ##### 手动备份恢复网站
    ```Shell
    wget https://github.com/mina998/wtools/raw/lsws/scripts/web.sh
    bash web.sh
    ```
    