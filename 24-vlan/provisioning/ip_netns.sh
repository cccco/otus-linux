#!/bin/bash

ip netns add vrf$1
ip link set eth2.$1 netns vrf$1
ip netns exec vrf$1 ip address add 10.10.10.2/24 dev eth2.$1
ip netns exec vrf$1 ip link set eth2.$1 up
ip link add veth$1-vrf type veth peer name veth$1
ip link set veth$1-vrf up
ip link set veth$1 netns vrf$1
ip netns exec vrf$1 ip link set veth$1 up
ip address add 172.29.$1.1/30 dev veth$1-vrf
ip netns exec vrf$1 ip address add 172.29.$1.2/30 dev veth$1
ip netns exec vrf$1 ip route add default via 172.29.$1.1
ip route add 10.10.$1.0/24 via 172.29.$1.2
ip netns exec vrf$1 iptables -t nat -I PREROUTING -d 10.10.$1.0/24 -j NETMAP --to 10.10.10.0/24
ip netns exec vrf$1 iptables -t nat -I POSTROUTING -s 10.10.10.0/24 -j NETMAP --to 10.10.$1.0/24
