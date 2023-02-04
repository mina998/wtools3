#!/bin/bash
http_code=0
url=$1
if [ -z $url ]; then
	echo 'URL is Null'
	exit 0
fi
for i in {1..3}; do
	http_code=$(curl -i -s -m 3 $url |grep HTTP|awk '{print $2}')
	echo "Http Code: $http_code"
	if [ "$http_code" == "400" ]; then
		break
	fi
	sleep 1s
done