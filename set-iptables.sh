#!/bin/bash +x

ip=/sbin/iptables
tcpservices="80 8080 443 22 123 3784"
udpservices="3784"

# Firewall script for servername
echo -n ">> Applying iptables rules... "

## flushing...
$ip -F
$ip -X
$ip -Z
$ip -t nat -F

# default: DROP!
$ip -P INPUT DROP
$ip -P OUTPUT DROP
$ip -P FORWARD DROP

# filtering...

# localhost - letmein
$ip -A INPUT -i lo -j ACCEPT
$ip -A OUTPUT -o lo -j ACCEPT

# allowed services
for service in $tcpservices ; do
    $ip -A INPUT -p tcp -m tcp --dport $service -j ACCEPT
    $ip -A OUTPUT -p tcp -m tcp --sport $service -m state --state RELATED,ESTABLISHED -j ACCEPT
done
for service in $udpservices ; do
    $ip -A INPUT -p udp -m udp --dport $service -j ACCEPT
    $ip -A OUTPUT -p udp -m udp --sport $service -m state --state RELATED,ESTABLISHED -j ACCEPT
done

$ip -A INPUT -j LOG --log-level 4

# dns...
$ip -A INPUT -p udp -m udp --sport 53 -j ACCEPT
$ip -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
$ip -A INPUT -p tcp -m tcp --sport 53 -j ACCEPT
$ip -A OUTPUT -p tcp -m tcp --dport 53 -j ACCEPT

echo "OK. Check rules with iptables -L -n"
