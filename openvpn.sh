#!/bin/bash

# Allows you to install OpenVPN on Linux Machines
# Perfect for AWS instances!


#install openvpn here
sudo apt-get install -y openvpn

#allow forwarding and masquerading on the instance
sudo modprobe iptable_nat
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -A POSTROUTING -s 10.10.10.1/24 -o eth0 -j MASQUERADE

#Add permissioning on the openvpn directory
sudo chmod +x -R /etc/openvpn

####
cd /etc/openvpn
sudo openvpn --genkey --secret ovpn.key
####

#openvpn service on Linux (Ubuntu Server)
cd /etc/openvpn/
INSTANCE=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
sudo openvpn --genkey --secret ${INSTANCE}.key
sudo cat > openvpn.conf <<OPENVPN
dev tun1
ifconfig 10.10.10.1 10.10.10.2
port 443
proto tcp-server
secret ${INSTANCE}.key
OPENVPN
#sudo service openvpn start


#client section
cd /etc/openvpn/
sudo cat > ${INSTANCE}.conf <<OPENVPN
dev tun
dhcp-option DNS 8.8.8.8
ifconfig 10.10.10.2 10.10.10.1
port 443
proto tcp-client
redirect-gateway def1
remote ${INSTANCE}
secret ${INSTANCE}.key
OPENVPN
sudo apt-get install -y zip
sudo zip client.zip ${INSTANCE}.conf ${INSTANCE}.key


#start the openvpn server
sudo service openvpn start

