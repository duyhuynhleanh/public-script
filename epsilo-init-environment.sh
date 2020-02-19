#!/bin/bash
#Company: Epsilo
#Description: this script used to setup some initialize environment for EC2 Instance (CentOS).

# install some neccessary packages
yum install epel-release -y
yum -y install glib* gnutls-devel readline-devel python-devel libaio-devel freetype-devel freetype zlib-devel
yum -y groupinstall "Compatibility libraries" "Hardware monitoring utilities" "Debugging Tools" "Development Tools" "Base"
yum -y install git tree glib* gnutls-devel readline-devel python-devel libaio-devel freetype-devel freetype zlib-devel dmidecode openipmi openipmi-tools pciutils lspci lshw* ipmitool man mlocate vim nano screen ntpdate gcc-c++ autoconf automake rsync tcpdump wget unzip openssl net-snmp net-snmp-utils iptables-services openssl-devel zlib-devel bzip2-devel sqlite sqlite-devel xz-libs krb5-devel pam-devel libX11-devel xmkmf libXt-devel libcurl-devel nfs-utils sg3* OpenIPMI bc net-snmp-libs lshw lsof compat-libstdc* libxml2* net-snmp-devel net-tools libstdc* libsysfs sysfsutils telnet ipmi* libxslt* gdisk parted xfsprogs xfsdump fdisk resize2fs nmap iptables-services perl-ExtUtils-Embed chrony perl-ExtUtils-Embed pam-devel
yum -y install ca-certificates
update-ca-trust force-enable
yum update -y

# Disable SELinux
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

# Install nginx with compiling nginx package
#cd /opt/
#git clone https://github.com/cuongquach/nginx-auto-installer.git nginx-auto-installer
#cd nginx-auto-installer
#chmod +x install.sh
#bash ./install.sh
#systemctl start nginx
#systemctl enable nginx

# Disable ipv6
cat <<EOF >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1ll
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
sysctl -p

# Disable zeroconf
echo "NOZEROCONF=yes" >> /etc/sysconfig/network

# Stop neccessary services
systemctl stop postfix
systemctl stop NetworkManager
systemctl stop firewalld
systemctl stop abrt-ccpp
systemctl stop abrt-oops
systemctl stop abrtd
systemctl stop iscsi
systemctl stop iscsid
systemctl stop lvm2-monitor
systemctl stop mdmonitor
systemctl stop rpcbind
systemctl stop netfs
systemctl stop nfslock
systemctl stop rpcgssd
systemctl stop blk-availability
systemctl stop cpuspeed
systemctl stop abrt-vmcore
systemctl stop abrt-xorg
systemctl stop dmraid-activation
systemctl stop nfs-client
systemctl stop lvm2-lvmetad.socket
systemctl stop lvm2-lvmetad
systemctl stop lvm2-lvmpolld
systemctl stop lvm2-lvmpolld.socket
systemctl stop smartd
systemctl stop libstoragemgmt
systemctl stop microcode

systemctl disable abrt-vmcore
systemctl disable abrt-xorg
systemctl disable dmraid-activation
systemctl disable nfs-client
systemctl disable lvm2-lvmetad.socket
systemctl disable lvm2-lvmetad
systemctl disable lvm2-lvmpolld
systemctl disable lvm2-lvmpolld.socket
systemctl disable smartd
systemctl disable libstoragemgmt
systemctl disable microcode
systemctl disable postfix
systemctl disable NetworkManager
systemctl disable firewalld
systemctl disable abrt-ccpp
systemctl disable abrt-oops
systemctl disable abrtd
systemctl disable iscsi
systemctl disable iscsid
systemctl disable lvm2-monitor
systemctl disable mdmonitor
systemctl disable rpcbind
systemctl disable netfs
systemctl disable nfslock
systemctl disable rpcgssd
systemctl disable blk-availability
systemctl disable cpuspeed

systemctl stop rpcbind
systemctl disable rpcbind
systemctl mask rpcbind
systemctl stop rpcbind.socket
systemctl disable rpcbind.socket


yum remove NetworkManager* wpa_supplicant -y
yum upgrade wget nss* sudo policycoreutils httpd libsoup git perl-Git -y
yum upgrade -y

# Setup limit descriptor
#cat << EOF >> /etc/security/limits.conf
#* soft nproc   250000
#* hard nproc   250000
#* soft nofile   250000
#* hard nofile   250000
#EOF

#cat << EOF >> /root/.bash_profile
#ulimit -n 250000
#ulimit -u 250000
#ulimit -d unlimited
#ulimit -m unlimited
#ulimit -s unlimited
#ulimit -t unlimited
#ulimit -v unlimited
#EOF

# delete user
userdel -r games
userdel -r postfix
userdel -r nfsnobody
userdel -r apps
userdel -r ntp
userdel -r apps
userdel -r saslauth
userdel -r squid
userdel -r unbound
userdel -r tss
userdel -r libstoragemgmt

# Configure time
rm -f /etc/localtime
cat << EOF > /etc/sysconfig/clock
ZONE="Asia/Ho_Chi_Minh"
EOF
ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
timedatectl set-timezone "Asia/Ho_Chi_Minh"
ntpdate -u vn.pool.ntp.org 2>&1 | tee -a /var/log/ntp.log

# Cron NTP Sync Time to Private NTP Gotadi
cat << EOF > /tmp/crontab-epsilo-ntp.txt
# Cron NTP Sync Time to Public NTP
15 * * * * /sbin/ntpdate -u vn.pool.ntp.org 2>&1 | tee -a /var/log/ntp.log
EOF
crontab /tmp/crontab-epsilo-ntp.txt
crontab -l
rm -f /tmp/crontab-epsilo-ntp.txt

# Install node_exporter
wget -O - https://raw.githubusercontent.com/duyhuynhleanh/public-script/master/gtd-prometheus-node-exporter.sh | sudo bash

# Setup infrastructute member users
cd /opt/ && wget -O - https://raw.githubusercontent.com/duyhuynhleanh/public-script/master/epsilo-infrastructure-user.sh | sudo bash

# Update curl version support httpv2
rpm -Uvh http://www.city-fan.org/ftp/contrib/yum-repo/rhel7/x86_64/city-fan.org-release-2-1.rhel7.noarch.rpm
yum --enablerepo=city-fan.org install -y libcurl libcurl-devel

# Setup environment user root
echo 'export HISTTIMEFORMAT="[$(tput setaf 6)%F %T$(tput sgr0)]: "' >> /root/.bash_profile
echo 'export PROMPT_COMMAND="history -a; history -c; history -r"' >> /root/.bash_profile
echo 'export HISTCONTROL="ignoredups:erasedups"' >> /root/.bash_profile
echo 'export HISTFILESIZE=2000' >> /root/.bash_profile
echo 'export HISTSIZE=10000' >> /root/.bash_profile

exit 0
