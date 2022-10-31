#!/bin/sh

echo "Downloading node exporter ..."
sudo wget "https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz"
sudo tar -xvzf node_exporter-1.4.0.linux-amd64.tar.gz
sudo mv node_exporter-1.4.0.linux-amd64/node_exporter /usr/bin
sudo rm -rf node_exporter-1.4.0.linux-amd64*

echo "Config security ..."
sudo restorecon -rv /usr/bin/node_exporter
sudo iptables -A INPUT -s 34.87.26.251/32 -p tcp -m state --state NEW -m tcp --dport 9100 -j ACCEPT
sudo iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 9100 -j DROP
sudo su -c "iptables-save > /etc/sysconfig/iptables"

echo "Config environment ..."
sudo useradd -M -s /sbin/nologin prometheus
sudo cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=prometheus
Type=simple
ExecStart=/usr/bin/node_exporter

[Install]
WantedBy=default.target
EOF

echo "Starting up ..."
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

echo "Done !"
exit
