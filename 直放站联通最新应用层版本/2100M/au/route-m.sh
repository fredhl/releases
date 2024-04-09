#!/bin/sh

ip ro del default
if [ $# -gt 0 ]
then
    ip ro add default via 192.168.10.$1 dev eth1
else
    ip ro add default via 192.168.10.2 dev eth1
fi
