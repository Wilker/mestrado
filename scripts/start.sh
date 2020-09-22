#!/bin/bash
DIR="./.config"
echo 'Criando diretórios para arquivos de configuração'
mkdir -p $DIR
echo 'Entrando diretório de arquivos de configuração'
cd $DIR
echo $DIR
echo 'Criando arquivos de configuração do cluster Atomix'
echo '.'
echo '.'
echo '.'
VAR=""

ATOMIX_INSTANCE_COUNTER=3
ONOS_INSTANCE_COUNTER=$1

for i in $(seq 1 $ATOMIX_INSTANCE_COUNTER)
do
  VAR=""
      echo "cluster {
    cluster-id: onos
    node {
      id: biscoito-$i
      address: \"172.18.0.`expr $i + 1`:5679\"
    }
    discovery {
      type: bootstrap" > "atomix-$i.conf"

  VAR="${VAR}biscoito-1"

  for j in $(seq 1 $ATOMIX_INSTANCE_COUNTER)
  do
      if [ $1 -gt 1 ] && [ $j -lt `expr $ATOMIX_INSTANCE_COUNTER` ]
      then
              VAR="${VAR},biscoito-`expr $j + 1`"
      fi
      echo "      nodes.$j {
        id: biscoito-$j
        address: \"172.18.0.`expr $j + 1`:5679\"
      }" >> "atomix-$i.conf"
  done

  VAR="${VAR%"${VAR##*[![:space:]]}"}"

  echo "  }
  }" >> "atomix-$i.conf"
      echo "
  management-group {
    type: raft
    partitions: 1
    storage.level: disk
    members: [$VAR]
  }

  partition-groups.raft {
    type: raft
    partitions: 1
    storage.level: disk
    members: [$VAR]
  } " >> "atomix-$i.conf"
done

echo 'Criando arquivos de configuração do cluster Onos'
echo '.'
echo '.'
echo '.'

for i in $(seq 1 $ONOS_INSTANCE_COUNTER)
do
  echo "{
  \"name\": \"onos\",
  \"node\": {
    \"id\": \"onos-$i\",
    \"ip\": \"172.18.0.`expr $i + $ATOMIX_INSTANCE_COUNTER + 1`\",
    \"port\": 9876
  },
  \"storage\": [" > "onos-$i.json"
    for j in $(seq 1 $ATOMIX_INSTANCE_COUNTER)
    do
    echo "    {
      \"id\": \"biscoito-$j\",
      \"ip\": \"172.18.0.`expr $j + 1`\",
      \"port\": \"5679\"" >> "onos-$i.json"

    if [ $j -lt $ATOMIX_INSTANCE_COUNTER ]
    then
    echo "    }," >> "onos-$i.json"
    else
    echo "    }" >> "onos-$i.json"
    fi
    done
    echo "  ]
}" >> "onos-$i.json"
done

echo "Deixando o diretório de arquivos de configuração"
cd "../"
DIR=`pwd`
echo $DIR

echo 'Criando diretórios para arquivos de log'
DIR="./.log"
mkdir -p $DIR
echo 'Entrando diretório de arquivos de log'
cd $DIR
echo `pwd`
DIR="$(date '+%H-%M-%S')"
LOG_DIR=$DIR

echo 'Criando diretório de log '$DIR''
mkdir -p $DIR
echo 'Entrando no diretório de log'
cd $DIR
echo `pwd`
echo 'Criando subdiretórios de log'
for i in $(seq 1 $1)
do
  mkdir -p "onos-$i"
done

echo "Deixando o diretório de arquivos de log"
cd "../../"
DIR=`pwd`
echo $DIR
echo "Executando intâncias de cluster Atomix"

for i in $(seq 1 $ATOMIX_INSTANCE_COUNTER)
do
  CMD="sudo docker run -it --net rede-onos --ip 172.18.0.`expr $i + 1` --name atomix$i --hostname atomix-$i -v $DIR/.config/atomix-$i.conf:/etc/atomix/conf/atomix.conf atomix/atomix:3.1.0 --config /etc/atomix/conf/atomix.conf --ignore-resources"
  gnome-terminal -e "bash -c
  \"sudo docker rm atomix$i;
  echo -e '$CMD';
  $CMD;
  exec bash\""
done

#echo "Executando intâncias de cluster ONOS"
#for i in $(seq 1 $1)
#do
#  CMD="sudo docker run -it --net rede-onos --ip 172.18.0.`expr $i + $1 + 1` --name onos$i --hostname onos-$i -v $DIR/.config/onos-$i.json:/root/onos/config/cluster.json -v $DIR/.log/$LOG_DIR/onos-$i/:/root/onos/apache-karaf-4.2.3/data/log/ onosproject/onos:2.1.0"
#  gnome-terminal -e "bash -c
#  \"sudo docker rm onos$i;
#  echo -e '$CMD';
#  $CMD;
#  exec bash\""
#done

echo "Executando intância de cluster ONOS1"
  CMD="sudo docker run -it --net rede-onos --ip 172.18.0.`expr 1 + $ATOMIX_INSTANCE_COUNTER + 1` --name onos1 --hostname onos-1 -v $DIR/.config/onos-1.json:/root/onos/config/cluster.json -v $DIR/.log/$LOG_DIR/onos-1/:/root/onos/apache-karaf-4.2.3/data/log/ onosproject/onos:2.1.0"
  gnome-terminal -e "bash -c
  \"sudo docker rm onos1;
  echo -e '$CMD';
  $CMD;
  exec bash\""


CMD="./start_capturas.sh onos1 6"
gnome-terminal -e "bash -c
\"echo -e 'Iniciando captura';
echo -e '$CMD';
$CMD;
exec bash\""

echo "Criando script mininet"
echo "."
echo "."
echo "."

echo "from mininet.net import Mininet
from mininet.node import Controller, RemoteController, OVSController
from mininet.node import CPULimitedHost, Host, Node
from mininet.node import OVSKernelSwitch, UserSwitch
from mininet.node import IVSSwitch
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from mininet.link import TCLink, Intf
from subprocess import call

def myNetwork():

    net = Mininet( topo=None,
                   build=False,
                   ipBase='172.18.0.0/16')

    info( '*** Adding controllers\n' )" > myTopology.py
  for i in $(seq 1 $1)
  do
  echo "    c$i=net.addController(name='c$i',
                      controller=RemoteController,
                      ip='172.18.0.`expr $i + $ATOMIX_INSTANCE_COUNTER + 1`',
                      protocol='tcp',
                      port=6653)
  " >> myTopology.py

  done
  CONTROLLERS=""
  for i in $(seq 1 $1)
  do
    CONTROLLERS=$CONTROLLERS"c$i"
    if [ $i -lt $1 ]
    then
      CONTROLLERS=$CONTROLLERS","
    fi
  done
  echo "    info( '*** Add switches\n')
    s1 = net.addSwitch('s1', cls=OVSKernelSwitch)
    s2 = net.addSwitch('s2', cls=OVSKernelSwitch)
    s3 = net.addSwitch('s3', cls=OVSKernelSwitch)
    s4 = net.addSwitch('s4', cls=OVSKernelSwitch)

    info( '*** Add hosts\n')
    h1 = net.addHost('h1', cls=Host, ip='172.18.0.10', defaultRoute=None)
    h2 = net.addHost('h2', cls=Host, ip='172.18.0.11', defaultRoute=None)
    h3 = net.addHost('h3', cls=Host, ip='172.18.0.12', defaultRoute=None)
    h4 = net.addHost('h4', cls=Host, ip='172.18.0.13', defaultRoute=None)

    info( '*** Add links\n')
    net.addLink(h1, s1)
    net.addLink(h2, s4)
    net.addLink(h3, s3)
    net.addLink(h4, s2)

    net.addLink(s1, s2)
    net.addLink(s1, s3)

    net.addLink(s2, s4)
    net.addLink(s3, s4)

    info( '*** Starting network\n')
    net.build()
    info( '*** Starting controllers\n')
    for controller in net.controllers:
        info(controller)
        controller.start()

    info( '*** Starting switches\n')
    net.get('s1').start([$CONTROLLERS])
    net.get('s2').start([$CONTROLLERS])
    net.get('s3').start([$CONTROLLERS])
    net.get('s4').start([$CONTROLLERS])


    info( '*** Post configure switches and hosts\n')

    net.pingAll()

    CLI(net)
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    myNetwork()" >> myTopology.py


echo "Iniciando CLI onos em onos1"
echo "."
echo "."
echo "."

CMD="sudo docker exec -it onos1 bash -c '~/onos/apache-karaf-4.2.3/bin/client app activate org.onosproject.openflow'"
gnome-terminal -e "bash -c
\"echo -e 'Aguardando contêiner docker';
sleep 30;
echo -e '$CMD';
$CMD;
exec bash\""


echo "Executando intâncias de cluster ONOS"
for i in $(seq 2 $1)
do
  CMD="sudo docker run -it --net rede-onos --ip 172.18.0.`expr $i + $ATOMIX_INSTANCE_COUNTER + 1` --name onos$i --hostname onos-$i -v $DIR/.config/onos-$i.json:/root/onos/config/cluster.json -v $DIR/.log/$LOG_DIR/onos-$i/:/root/onos/apache-karaf-4.2.3/data/log/ onosproject/onos:2.1.0"
  gnome-terminal -e "bash -c
  \"sudo docker rm onos$i;
  sleep 35;
  echo -e '$CMD';
  $CMD;
  exec bash\""
done

CMD="./start_capturas.sh onos2 38"
gnome-terminal -e "bash -c
\"echo -e 'Iniciando captura';
echo -e '$CMD';
$CMD;
exec bash\""

echo "Iniciando Mininet"
echo "."
echo "."
echo "."
sudo python myTopology.py
