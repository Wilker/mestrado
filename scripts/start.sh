#!/bin/bash
echo 'Criando Cluster atomix'
echo 'Criando arquivos de configuração do cluster'
VAR=""
for i in $(seq 1 $1)
do

    echo "cluster {
  cluster-id: onos
  node {
    id: biscoito-$i
    address: "172.21.0.`expr $i + 1`:5679"
  }
  discovery {
    type: bootstrap" > "atomix-$i.conf"

VAR="${VAR}biscoito-1"

for j in $(seq 1 $1)
do 
    if [ $1 -gt 1 ] && [ $j -lt `expr $1 - 1` ]
    then
            VAR="${VAR},biscoito-`expr $j + 1`"
    fi
    echo "      nodes.$j {
      id: biscoito-$j
      address: "172.21.0.`expr $j + 2`:5679"
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
# sudo docker run --net rede-onos --ip 172.18.0.2 -it --name atomix1 --hostname atomix-1 -v caminho_para_o_arquivo_atomix https://atomix.io/1:/etc/atomix/conf atomix/atomix:3.0.7 --config /etc/atomix/conf/atomix.conf --ignore-resources