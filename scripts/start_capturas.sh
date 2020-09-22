#!/bin/bash
container_name=$1
delay=$2
echo "dormindo por $2"
sleep $2
echo "Tentando captura em $1"
for container in $(docker ps -q); do
    iflink=`docker exec -it $container bash -c 'cat /sys/class/net/eth0/iflink'`
    iflink=`echo $iflink|tr -d '\r'`
    veth=`grep -l $iflink /sys/class/net/veth*/ifindex`
    veth=`echo $veth|sed -e 's;^.*net/\(.*\)/ifindex$;\1;'`
    name=`echo $(sudo docker ps -aq --format "table {{.ID}}\t{{.Names}}" -f id=$container) | cut -c33-100`
    echo $name
    if [[ $name == *"$container_name"* ]]; then
        echo "Iniciando captura em $1"
        sudo tcpdump -i $veth -w `pwd`/$(date '+%H-%M-%S')-$name.pcap
     fi
done