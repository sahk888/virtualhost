#!bin/bash

### MAXMIND
# Program to update database
# Edit apache.conf to allow maxmind and set <if> block
apt-get update -y;
apt-get upgrade -y;
apt-get install linux-headers-$(uname -r) -y;
apt-get install software-properties-common -y;
add-apt-repository universe -y;
add-apt-repository ppa:certbot/certbot -y;
add-apt-repository ppa:maxmind/ppa -y;
apt-get update -y;
apt-get install libmaxminddb0 libmaxminddb-dev geoipupdate mmdb-bin libapache2-mod-geoip -y;
apt-get install apache2 -y;

cd /usr/local/bin;
wget -O virtualhost https://raw.githubusercontent.com/andrewsokolok/virtualhost/master/virthost.sh;
chmod +x virtualhost;
wget -O addomain https://raw.githubusercontent.com/andrewsokolok/add_apache_alias/master/addomain.sh;
chmod +x addomain;

#add vitualhost nginx
#wget -O virtualhost-nginx https://raw.githubusercontent.com/RoverWire/virtualhost/master/virtualhost-nginx.sh;
#chmod +x virtualhost-nginx;

echo -n "Type your domain name: "; read domainname
virtualhost create $domainname;

sleep 10;
cd;

/etc/init.d/apache2 restart;
service apache2 restart;

apt-get install certbot python-certbot-apache -y;
certbot --apache --register-unsafely-without-email;
wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz;
tar -xvf GeoLite2-Country*;
mkdir /usr/local/share/GeoIP;
mv GeoLite2-Country*/GeoLite2-Country.mmdb /usr/local/share/GeoIP;

#add  city base
#wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
#tar -xvf GeoLite2-City*
#mv GeoLite2-City*/GeoLite2-City.mmdb /usr/local/share/GeoIP

sed -i -e 's/GeoIPEnable Off/GeoIPEnable On/g' /etc/apache2/mods-available/geoip.conf;
sed -i -e 's/#GeoIPDBFile \/usr\/share\/GeoIP\/GeoIP.dat/GeoIPDBFile \/usr\/share\/GeoIP\/GeoIP.dat/g' /etc/apache2/mods-available/geoip.conf;
sed -i -e 's/<\/IfModule>/GeoIPScanProxyHeaders On\n<\/IfModule>/g' /etc/apache2/mods-available/geoip.conf;
echo '<IfModule mod_geoip.c>\nGeoIPEnable On\nGeoIPDBFile /usr/share/GeoIP/GeoIP.dat Standard\nGeoIPEnableUTF8 On\n</IfModule>' >> /etc/apache2/apache2.conf;

a2enmod rewrite;
a2enmod geoip;
/etc/init.d/apache2 restart;
service apache2 restart;

#autoupdate geoip base
echo "9 10 * * 4  /usr/bin/geoipupdate" >> /var/spool/cron/root;
crontab -u root /var/spool/cron/root;
service cron reload;
cd;
exit;
