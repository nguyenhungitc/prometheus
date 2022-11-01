#!/bin/sh

version="${VERSION:-1.4.0}"
arch="${ARCH:-linux-amd64}"
bin_dir="${BIN_DIR:-/usr/bin}"
server="${SERVER:-34.87.26.251/32}"

echo "Downloading node exporter ..."
sudo wget "https://github.com/prometheus/node_exporter/releases/download/v$version/node_exporter-$version.$arch.tar.gz"
sudo tar -xvzf node_exporter-$version.$arch.tar.gz || { echo "ERROR! Extracting the node_exporter tar"; exit 1; }
sudo mv node_exporter-$version.$arch/node_exporter $bin_dir
sudo rm -rf node_exporter-$version.$arch*

echo "Config security ..."
sudo restorecon -rv /usr/bin/node_exporter
sudo iptables -A INPUT -s $server -p tcp -m state --state NEW -m tcp --dport 9100 -j ACCEPT
sudo iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 9100 -j DROP
sudo su -c "iptables-save > /etc/sysconfig/iptables"

echo "Config environment ..."
sudo useradd -M -s /sbin/nologin prometheus
sudo su -c "cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=prometheus
Type=simple
ExecStart=/usr/bin/node_exporter

[Install]
WantedBy=default.target
EOF"

echo "Starting up ..."
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

echo "Done !"
exit
