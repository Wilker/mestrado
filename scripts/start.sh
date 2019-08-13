#!/bin/bash
echo 'Criando Cluster atomix'
echo 'Criando arquivos de configuração do cluster'

for i in $(seq 1 $1)
do

    echo "cluster {
  cluster-id: onos
  node {
    id: biscoito-$i
    address: "172.21.0.`expr $i + 1`:5679"
  }
  discovery {
    type: bootstrap
    nodes.1 {
      id: biscoito-1
      address: "172.21.0.2:5679"
    }
    nodes.2 {
      id: biscoito-2
      address: "172.21.0.3:5679"
    }
    nodes.3 {
      id: biscoito-3
      address: "172.21.0.4:5679"
    }
  }
}
 
management-group {
  type: raft
  partitions: 1
  storage.level: disk
  members: [biscoito-1,biscoito-2,biscoito-3]
}
 
partition-groups.raft {
  type: raft
  partitions: 1
  storage.level: disk
  members: [biscoito-1,biscoito-2,biscoito-3]
} " > "atomix-$i.conf"
done




# sudo docker run --net rede-onos --ip 172.18.0.2 -it --name atomix1 --hostname atomix-1 -v caminho_para_o_arquivo_atomix https://atomix.io/1:/etc/atomix/conf atomix/atomix:3.0.7 --config /etc/atomix/conf/atomix.conf --ignore-resources