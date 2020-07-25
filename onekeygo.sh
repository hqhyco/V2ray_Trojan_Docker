#!/bin/bash

checkDocker=$(which docker)
checkDockerCompose=$(which docker-compose)
if [ "$checkDocker" == "" ] && [ "$checkDockerCompose" == "" ]; then
	echo "Please install docker and docker-compose!"
	exit
elif [ "$checkDocker" == "" ]; then
	echo "Please install docker!"
	exit
fi
if [ "$checkDockerCompose" == "" ]; then
	echo "Please install docker-compose!"
	exit
fi

rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime



read -p "Please input your server domain name(eg: abc.com): " domainName

if [ "$domainName" = "" ];then 
        echo "bye~"
        exit
else
	echo "Your domain name is: "$domainName
	sed -i "s/abc.com/$domainName/g" ./caddy/Caddyfile
	sed -i "s/abc.com/$domainName/g" ./trojan/config.json
fi

sys=$(uname)
if [ "$sys" == "Linux" ]; then
	uuid=$(cat /proc/sys/kernel/random/uuid)
elif [ "$sys" == "Darwin" ]; then
	uuid=$(echo $(uuidgen) | tr '[A-Z]' '[a-z]')
else
	uuid=$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')
fi

read -p "Please input your trojan password(eg: 123456): " trojan_password
sed -i "s/98bc7998-8e06-4193-84e2-38f2e10ee763/$uuid/g" ./v2ray/config.json
sed -i "s/123456/$trojan_password/g" ./trojan/config.json
sed -i "s/abc.com/$domainName/g" ./docker-compose.yml

echo "-----------------------------------------------"
echo "V2ray Configuration:"
echo "Server:" $domainName
echo "Port: 443"
echo "UUID:" $uuid
echo "AlterId: 64"
echo "WebSocket Host:" $domainName
echo "WebSocket Path: /foxzc"
echo "TLS: True"
echo "TLS Host:" $domainName
echo "-----------------------------------------------"
echo "Trojan Configuration:"
echo "Server:" $domainName
echo "Port: 443"
echo "Password:" $trojan_password
echo "-----------------------------------------------"
echo "Please run 'docker-compose up -d' to build!"
echo "Enjoy it!"

cat <<-EOF >./info.txt
	-----------------------------------------------
	V2ray Configuration:
	Server: $domainName
	Port: 443
	UUID: $uuid
	AlterId: 64
	WebSocket Host: $domainName
	WebSocket Path: /foxzc
	TLS: True
	TLS Host: $domainName
	-----------------------------------------------
	Trojan Configuration:
	Server: $domainName
	Port: 443
	Password: $trojan_password
	-----------------------------------------------
EOF

