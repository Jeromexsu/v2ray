writeNginxConf() {
    echo "input domain"
    read domain
    while read line
    do 
    if [[ "$line" == "server_name" ]]
    then 
    echo "$line $domain;" >> /etc/nginx/nginx.conf
    else echo $line >> /etc/nginx/nginx.conf
    fi
    done < ./v2ray/nginxTmp.conf
}
writeVRayConf() {
    id=$(v2ray uuid)
    while read line 
    do
    if [[ "$line" == "id" ]]
    then 
    echo "\"id\": \"$id\"," >> /usr/local/etc/v2ray/config.json
    else echo $line >> /usr/local/etc/v2ray/config.json
    fi
    done < ./v2ray/configTmp.json
    echo "uuid = $id"
}

echo "deployment starts"
# install git
yun install git
# get certificates
curl  https://get.acme.sh | sh
source ~/.bashrc
yum install socat
acme.sh --set-default-ca --server letsencrypt
acme.sh --issue -d jeromes.rocks --standalone
mv  /root/.acme.sh/jeromes.rocks/jeromes.rocks.cer /etc/v2ray/v2ray.crt
mv /root/.acme.sh/jeromes.rocks/jeromes.rocks.key /etc/v2ray/v2ray.key

# get and configure nginx
amazon-linux-extras install nginx1
git clone https://github.com/Jeromexsu/v2ray.git
writeNginxConf() 

# get and configure v2ray
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh)
writeVRayConf()

# start nginx
systemctl start nginx
# start v2ray
systemctl start v2ray
mkdir /etc/v2ray

# open bbr
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
