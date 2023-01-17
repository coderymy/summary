#!/bin/bash
#¹Ø±Õ·À»ðÇ½ºÍselinux
systemctl stop firewalld
systemctl disable firewalld &> /dev/null
setenforce 0


#²¿ÊðyumÔ´
#µ½°¢ÀïÔÆÔ´²éÕÒcentos¾µÏñ
#curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/rep o/Centos-vault-8.5.2111.repo 
#yum install -y https://mirrors.aliyun.com/epel/epel-release-latest-8.noar ch.rpm 
#sed -i 's|^#baseurl=https://download.example/pub|baseurl=https://mirrors. aliyun.com|' /etc/yum.repos.d/epel* 
#sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*


#°²×°ÒÀÀµ°ü
echo "ÕýÔÚ°²×°ÒÀÀµ°ü"
yum -y install libncurses* &> /dev/null
echo "°²×°Íê³É"

#´´½¨mysqlÓÃ»§
echo "ÕýÔÚ´´½¨mysqlÓÃ»§"
id mysql &> /dev/null
if [ $? -eq 0 ];then
        echo    "mysqlÓÃ»§´´½¨³É¹¦"
else
        echo "ÕýÔÚ´´½¨mysqlÓÃ»§"
        useradd -r -M -s /sbin/nologin mysql
        echo "mysqlÓÃ»§´´½¨³É¹¦"
fi

#ÅäÖÃmysqlÊý¾Ý¿â
echo "½âÑ¹mysqlÑ¹Ëõ°ü"
tar -xzf /opt/mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz -C /usr/local 
ln -sv /usr/local/mysql-5.7.37-linux-glibc2.12-x86_64 /usr/local/mysql &>/dev/null
chown -R mysql.mysql /usr/local/mysql &> /dev/null
mkdir -p /opt/data &> /dev/null
chown -R mysql.mysql /opt/data  &>/dev/null

#³õÊ¼»¯Êý¾Ý¿â
/usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --datadir=/opt/data/ &>/dev/null
ln -sv /usr/local/mysql/include/ /usr/local/include/mysql &> /dev/null
echo '/usr/local/mysql/lib '> /etc/ld.so.conf.d/mysql.conf &> /dev/null
ldconfig &> /dev/null
ln -s /usr/local/mysql/bin/mysql /usr/bin

#±à¼­mysqlÅäÖÃÎÄ¼þ
cat > /etc/my.cnf << EOF
[mysqld]
basedir = /usr/local/mysql
datadir = /opt/data
socket = /tmp/mysql.sock
port = 3306
pid-file = /opt/data/mysql.pid
user = mysql
skip-name-resolve
EOF

sed -ri "s#^(basedir=).*#\1/usr/local/mysql#g" /usr/local/mysql/support-files/mysql.server
sed -ri "s#^(datadir=).*#\1/opt/data#g" /usr/local/mysql/support-files/mysql.server

#¶¨Òåmysql·þÎñ¿ÉÒÔÊ¹ÓÃsystemdÀ´½øÐÐ¹ÜÀí
cat > /usr/lib/systemd/system/mysqld.service <<EOF
[Unit]
Description=mysql server daemon
After=network.targe

[Service]
Type=forking
ExecStart=/usr/local/mysql/support-files/mysql.server start
ExecStop=/usr/local/mysql/support-files/mysql.server stop
ExecReload=/bin/kill -HUP \$MAINPID

[install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload && echo "ÖØÔØ³É¹¦"
systemctl enable --now mysqld && echo "ÅäÖÃ¿ª»ú×ÔÆô"

#ÉèÖÃÊý¾Ý¿âÃÜÂë
read -p "ÇëÊäÈëÊý¾Ý¿âÃÜÂë:"a
/usr/local/mysql/bin/mysql -uroot -e "set password=password('$a')"

#×öÒ»¸öÁ´½Ó£¬Ìí¼ÓmysqÃüÁîµÄ±äÁ¿µ½»·¾³±äÁ¿
echo "export PATH=/usr/local/mysql/bin:/usr/local/mysql/lib:$PATH" >>/etc/profile
source /etc/profile
echo "-----mysql²¿ÊðÍê³É-----"


