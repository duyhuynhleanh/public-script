#!/bin/bash

echo "-+ Add user : prometheus"
useradd -m -s /bin/bash prometheus

echo "-+ Download package node_exporter"
cd /opt/
rm -f node_exporter-0.18.0.linux-amd64.tar.gz
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.0/node_exporter-0.18.0.linux-amd64.tar.gz
tar -xzvf node_exporter-0.18.0.linux-amd64.tar.gz

if [ -d /home/prometheus/node_exporter/ ];then
    rm -rf /home/prometheus/node_exporter/
fi

mkdir -p /home/prometheus/node_exporter/
mv node_exporter-0.18.0.linux-amd64/* /home/prometheus/node_exporter/
chown -R prometheus:prometheus /home/prometheus/node_exporter
touch /var/log/node_exporter.log
chown prometheus:prometheus /var/log/node_exporter.log
chmod 644 /var/log/node_exporter.log

if [[ -f /etc/redhat-release ]];then
    echo "-+ Create startup service node_exporter"

cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=/home/prometheus/node_exporter/node_exporter

[Install]
WantedBy=default.target
EOF

    echo "-+ Start service node_exporter"
    systemctl daemon-reload
    systemctl start node_exporter
    systemctl enable node_exporter

elif [[ -f /etc/os-release ]];then
    cd /etc/init.d/
    wget -O node_exporter https://raw.githubusercontent.com/duyhuynhleanh/Script/master/scripts-env/node-exporter-initd.sh?token=ANNECVVYMRSJFFIFREY6RQK5V75MA
    chmod +x node_exporter
    service node_exporter restart
    chkconfig node_exporter on
    cd /etc/rc3.d/
    
fi

echo "-+ Check port listen node_exporter 9100"
netstat -anltlp | grep 9100

exit 0
