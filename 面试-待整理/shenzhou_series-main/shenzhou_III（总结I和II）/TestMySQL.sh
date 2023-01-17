#!/bin/bash
#�0�1�0�1���0�9���0�8�0�3�0�8�0�5�0�5�0�2�0�1selinux
systemctl stop firewalld
systemctl disable firewalld &> /dev/null
setenforce 0


#�0�5�0�7�0�8�0�8yum�0�8�0�7
#�0�8�0�5��0�4�0�8�0�7�0�8�0�4�0�8�0�7�0�5���0�9�0�6centos�0�6�0�8�0�3�0�9
#curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/rep o/Centos-vault-8.5.2111.repo 
#yum install -y https://mirrors.aliyun.com/epel/epel-release-latest-8.noar ch.rpm 
#sed -i 's|^#baseurl=https://download.example/pub|baseurl=https://mirrors. aliyun.com|' /etc/yum.repos.d/epel* 
#sed -i 's|^metalink|#metalink|' /etc/yum.repos.d/epel*


#��0�5����0�6�0�8�0�8�0�8�㨹
echo "�0�9�0�5�0�8�0�3��0�5����0�6�0�8�0�8�0�8�㨹"
yum -y install libncurses* &> /dev/null
echo "��0�5����0�1���0�6�0�7"

#�0�7�0�7�0�5��mysql�0�7�0�1�0�3��
echo "�0�9�0�5�0�8�0�3�0�7�0�7�0�5��mysql�0�7�0�1�0�3��"
id mysql &> /dev/null
if [ $? -eq 0 ];then
        echo    "mysql�0�7�0�1�0�3��0�7�0�7�0�5���0�6�0�7�0�1�0�7"
else
        echo "�0�9�0�5�0�8�0�3�0�7�0�7�0�5��mysql�0�7�0�1�0�3��"
        useradd -r -M -s /sbin/nologin mysql
        echo "mysql�0�7�0�1�0�3��0�7�0�7�0�5���0�6�0�7�0�1�0�7"
fi

#�0�3�0�1�0�0�0�1mysql�0�8�0�5�0�6�0�6�0�7�0�9
echo "�0�5�0�9�0�5�0�1mysql�0�5�0�1�0�9�0�1�㨹"
tar -xzf /opt/mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz -C /usr/local 
ln -sv /usr/local/mysql-5.7.37-linux-glibc2.12-x86_64 /usr/local/mysql &>/dev/null
chown -R mysql.mysql /usr/local/mysql &> /dev/null
mkdir -p /opt/data &> /dev/null
chown -R mysql.mysql /opt/data  &>/dev/null

#�0�6�0�1�0�8�0�4�0�3�0�4�0�8�0�5�0�6�0�6�0�7�0�9
/usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --datadir=/opt/data/ &>/dev/null
ln -sv /usr/local/mysql/include/ /usr/local/include/mysql &> /dev/null
echo '/usr/local/mysql/lib '> /etc/ld.so.conf.d/mysql.conf &> /dev/null
ldconfig &> /dev/null
ln -s /usr/local/mysql/bin/mysql /usr/bin

#�����0�4�0�2mysql�0�3�0�1�0�0�0�1�0�2�0�2�0�4�0�6
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

#�0�9���0�6�0�2mysql���0�6�0�2�0�9�0�7�0�7�0�6�0�8�0�8�0�1�0�7�0�1systemd�0�8�0�7�0�5�0�3�0�4�0�4�0�1�0�5�0�8��
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
systemctl daemon-reload && echo "�0�0�0�1�0�8�0�1�0�6�0�7�0�1�0�7"
systemctl enable --now mysqld && echo "�0�3�0�1�0�0�0�1�0�7�0�9�0�3�����0�8�0�4�0�0"

#�0�7���0�0�0�1�0�8�0�5�0�6�0�6�0�7�0�9�0�1�0�5�0�0�0�5
read -p "�0�5�0�5�0�8�0�1�0�6�0�5�0�8�0�5�0�6�0�6�0�7�0�9�0�1�0�5�0�0�0�5:"a
/usr/local/mysql/bin/mysql -uroot -e "set password=password('$a')"

#���0�2�0�6�0�3�0�0�0�2�0�9�0�7�0�5�0�7�0�5�0�1�0�0���0�4�0�7mysq�0�1���0�9�0�6�0�8�0�2���0�1�0�9�0�7�0�8�0�5�0�3���0�6�0�6���0�1�0�9�0�7
echo "export PATH=/usr/local/mysql/bin:/usr/local/mysql/lib:$PATH" >>/etc/profile
source /etc/profile
echo "-----mysql�0�5�0�7�0�8�0�8�0�1���0�6�0�7-----"


