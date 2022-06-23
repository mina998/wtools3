#!/bin/bash

# 保存 KEYS 的文件
keys_file=/root/keys
# vsftp 日志文件  里面有上传文件的信息
log_image=/root/vsftpd.log
# 图片扩展名
image_type='png|jpg|jpeg|gif|bmp|webp'
# 日志中的图片路径前缀带 /
# 所在结尾不要加 /
image_root_path=/home/soroy


################## KEYs 格式 ##########################
# SNYm5Sj33xDsNR0hx0mCK0R2kZTqTZcL#224#0
# hvCjpNNR9PgJg5fRcJ3mvBWTh6VHLtBY#500#0
################# 以下不要修改 #########################

# 从文件中获取一条可用
function keyGet(){
	# 删除空行
	sed -i -r '/^$/d' $keys_file
	# 去除不符合标准的换行符
	sed -i 's/\r$//' $keys_file
	# 获取KEY的总数
	let key_count=$(sed -n '$=' $keys_file)+1
	# 循环获取
	for (( i = 1; i < $key_count; i++ )); do
		# 请取一行KEY
		array=($(sed -n "${i}p" $keys_file | tr '#' ' '))
		# 判断KEY是否有效 如果有效就赋值
		if [ ${array[1]} -gt ${array[2]} ]; then
			key=${array[0]}
			max=${array[1]}
			use=${array[2]}
			break
		else
			key=''
		fi
	done
}

# 从日志中 查找 文件 并删除没有文件的行
function imageGet(){

	while true ; do
		# 判断文件是否读取完成
		local count=$(awk 'END{print NR}' $log_image)
		if [ $count -eq 0 ]; then
			image_to_compressed=''
			break
		fi
		# 从日志第一行中查找图片
		image_to_compressed=$(sed -n '1p' $log_image | grep -oP "\/202\d\/.*?\.($image_type)")
		# 如果找到就退出循环
		if [ ! -z "$image_to_compressed" ] && [ -f "$image_root_path$image_to_compressed" ]  ; then
			image_to_compressed=$image_root_path$image_to_compressed
			break
		else
			image_to_compressed=''
		# 找不到就删除第一行
			sed -i '1d' $log_image
		fi
	done
}


k=0
#  
while true; do
	((k++))
	#1 获取KEY 和 图片
	keyGet
	imageGet
	echo '1.获取参数# image:'$image_to_compressed' key:'$key' use:'$use' max:'$max' -'
	#2 判断 KEY 和 图片 是否获取成功 不存功表示没有可用KEY 或者没有 图片 等待 一小时
	if [ -z "$image_to_compressed" ] || [ -z "$key" ]; then
		echo '没有可用KEY 或者 未找到文件 等待1小时'
		sleep 1h
		continue
	fi
	echo '2.上传图片'
	result=($(curl -s --user api:"$key" --data-binary @"$image_to_compressed" -i https://api.tinify.com/shrink | sed -n -r '/location|compression/p' | sed 's/\r$//'))
	echo '3.获取返回信息: '${result[@]}

	if [ ${#result[@]} -eq 4 ]; then
	# KEY正常
		image_download_url=${result[1]}
		compression_count=${result[3]}
	elif [ ${#result[@]} -eq 2 ]; then
	# KEY 失效
		image_download_url=''
		compression_count=${result[1]}
	else
	# 其他失败信息 保存
		echo $image_to_compressed >> .tinify_fail_images
	# 删除数据
		echo '获取压缩次数失败 等侍1分钟'
		sleep 1m
		sed -i '1d' $log_image
	# 跳过
		continue
	fi
	echo '4.保存KEY使用次数'
	# 修改KEY文件使用次数
	sed -i "s/$key#$max#$use/$key#$max#$compression_count/" $keys_file
	# 如果压缩失败 等待10秒
	if [ -z "$image_download_url" ]; then
		echo '压缩失败 等待10秒'
		sleep 10s
		continue
	else
	# 下载压缩图片
		image_download_url=${image_download_url::-1} # 结尾中的特殊隐藏字符 想不到更好的删除方法
		echo '5.下载压缩图片:'$image_download_url
		curl -s "$image_download_url" --user api:"$key" --output "$image_to_compressed"
	# 删除日志文件中的图片地址
		sed -i '1d' $log_image
	fi
	echo '6.ok'
	sleep 3s
done
