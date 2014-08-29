#!/usr/bin/env bash

#############################
# DEFINITIONS
#############################

IF_WAN=enp7s0
SERVICES="http https ssh"


#############################
# DEFAULTS
#############################

iptables -F
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow localhost network activity
iptables -A INPUT -i lo -j ACCEPT

# Allow relevant ICMP types
iptables -A INPUT -p icmp -i ${IF_WAN} --icmp-type 8/0 -j ACCEPT
iptables -A INPUT -p icmp -i ${IF_WAN} --icmp-type 11/0 -j ACCEPT


#############################
# SERVICES
#############################

# Create access ruleset foreach service
for service in ${SERVICES}
do
  iptables -A INPUT -p tcp -i ${IF_WAN} --dport ${service} -j LOG --log-level 7 --log-prefix "Accepted ${service}: "
  iptables -A INPUT -p tcp -i ${IF_WAN} --dport ${service} -j ACCEPT
done


#############################
#  DEFAULT DENY
#############################

iptables -A INPUT -j LOG --log-level 7 --log-prefix "Default Deny: "
iptables -A INPUT -j DROP
