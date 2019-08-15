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
for i in $(seq 1 $1)
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

  for j in $(seq 1 $1)
  do 
      if [ $1 -gt 1 ] && [ $j -lt `expr $1` ]
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

for i in $(seq 1 $1)
do
  echo "{
  \"name\": \"onos\",
  \"node\": {
    \"id\": \"onos-$i\",
    \"ip\": \"172.18.0.`expr $i + $1 + 1`\",
    \"port\": 9876
  },
  \"storage\": [" > "onos-$i.json"
    for j in $(seq 1 $1)
    do
    echo "    {
      \"id\": \"biscoito-$j\",
      \"ip\": \"172.18.0.`expr $j + 1`\",
      \"port\": \"5679\"" >> "onos-$i.json"
  
    if [ $j -lt $1 ]
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
echo "Executando intâncias de cluster atomix"

for i in $(seq 1 $1)
do 
  CMD="sudo docker run -it --net rede-onos --ip 172.18.0.`expr $i + 1` --name atomix$i --hostname atomix-$i -v $DIR/.config/atomix-$i.conf:/etc/atomix/conf/atomix.conf atomix/atomix:3.1.0 --config /etc/atomix/conf/atomix.conf --ignore-resources"
  gnome-terminal -e "bash -c 
  \"sudo docker rm atomix$i;
  echo -e '$CMD';
  $CMD;
  exec bash\""
done

echo "Executando intâncias de cluster ONOS"
for i in $(seq 1 $1)
do 
  CMD="sudo docker run -it --net rede-onos --ip 172.18.0.`expr $i + $1 + 1` --name onos$i --hostname onos-$i -v $DIR/.config/onos-$i.json:/root/onos/config/cluster.json onosproject/onos:2.1.0"
  gnome-terminal -e "bash -c 
  \"sudo docker rm onos$i;
  echo -e '$CMD';
  $CMD;
  exec bash\""
done

