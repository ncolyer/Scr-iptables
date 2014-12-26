#!/bin/bash +x

ip=/sbin/iptables
tcpservices="80 443 22 3784"
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

# Surfs up
$ip -A INPUT -p tcp -m tcp --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT
$ip -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT
$ip -A INPUT -p tcp -m tcp --sport 443 -m state --state RELATED,ESTABLISHED -j ACCEPT
$ip -A OUTPUT -p tcp -m tcp --dport 443 -j ACCEPT

$ip -A INPUT -p tcp -m tcp --sport 8080 -m state --state RELATED,ESTABLISHED -j ACCEPT
$ip -A OUTPUT -p tcp -m tcp --dport 8080 -j ACCEPT

# dns...
$ip -A INPUT -p udp -m udp --sport 53 -j ACCEPT
$ip -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT
$ip -A INPUT -p tcp -m tcp --sport 53 -j ACCEPT
$ip -A OUTPUT -p tcp -m tcp --dport 53 -j ACCEPT

$ip -A INPUT -p udp -m udp --dport 123 -j ACCEPT
$ip -A OUTPUT -p udp -m udp --sport 123 -j ACCEPT


# temporary backup if we change from DROP to ACCEPT policies
$ip -A INPUT -p tcp -m tcp --dport 1:1024 -j DROP
$ip -A INPUT -p udp -m udp --dport 1:1024 -j DROP


echo "OK. Check rules with iptables -L -n"
