# Elementor 500 error

+ php内存分配不足 (php.ini)
	```Shell
	memory_limit=128 #默认128 改成256 如果安装woocommerce 改成512
	```
+ 插件兼容性问题    

	禁用所有插件(除了elementor以外) 然后一个个启用测试
+ 主题兼容性

	切换WP主题排查
+ 固定链接    
	切换固定链接形式
+ 缓存插件
	修改缓存插件参数, 或者停用缓存插件
+ CDN
	检查CDN设置
+ 数据库修订版本
	数据库文章修订次数过多会占用大量内存,导致服务器没有空闲内存处理和存储当下正在操作的修订和保存。
	Optimize Database 和 WP-Sweep 插件都能用来清理数据库垃圾
+ 调试模式
	如果以上办法都没解决,修改wp-config.php文件
	debug日志把所有错误、通知和警告记录到 wp-content 目录中名为 debug.log 的文件中。
	```Shell
	define( 'WP_DEBUG', true );
	define( 'WP_DEBUG_LOG', true );
	```

