# IP's
- 192.168.1.142 - Taesa 10
- 192.168.2.11 - RAV1
- 192.168.2.12 - RAV2
- 192.168.2.10 - Taesa 10 (USB)


 # Iniciar NTP no servidor
##

## Sincronizar relógios via NTP no server
`sudo ntpdate taesa-10`

## TCP Dump 
>arg 1: numero do teste
>
>arg 2: rodada do teste

``sudo tcpdump -w $1-$2-`hostname`.pcap``

## TCP Replay
`sudo tcpreplay --intf1=enp1s0 -K --loop 1000 --pps 10 pacotes_com_macs_origem_diferentes.pcapng`

# Configuracao Atomix
Arquivo `atomix/conf/atomix.conf`
## RAV-1

```
cluster {
        cluster-id: onos
        node {
        id: RAV-1
        address: "192.168.2.11:5679"
        }
        discovery {
        type: bootstrap
        nodes.1 {
            id: RAV-1
            address: "192.168.2.11:5679"
        }
        nodes.2 {
            id: RAV-2
            address: "192.168.2.12:5679"
        }
    }
}

  management-group {
    type: raft
    partitions: 1
    storage.level: disk
    members: [RAV-1,RAV-2]
  }
  
  partition-groups.raft {
    type: raft
    partitions: 1
    storage.level: disk
    members: [RAV-1,RAV-2]
} 
  ```

___
## RAV-2
```
cluster {
    cluster-id: onos
    node {
      id: RAV-2
      address: "192.168.2.12:5679"
    }
    discovery {
      type: bootstrap
      nodes.1 {
        id: RAV-1
        address: "192.168.2.11:5679"
      }
      nodes.2 {
        id: RAV-2
        address: "192.168.2.12:5679"
      }
  }
}

management-group {
    type: raft
    partitions: 1
    storage.level: disk
    members: [RAV-1,RAV-2]
}
  
partition-groups.raft {
    type: raft
    partitions: 1
    storage.level: disk
    members: [RAV-1,RAV-2]
} 
  ```

# Configuracao ONOS
Arquivo `onos/config/cluster.json`
## RAV-1 
```
{
  "name": "onos",
  "node": {
    "id": "ONOS-RAV-1",
    "ip": "192.168.2.11",
    "port": 9876
  },
  "storage": [
    {
      "id": "RAV-1",
      "ip": "192.168.2.11",
      "port": "5679"
    },
    {
      "id": "RAV-2",
      "ip": "192.168.2.12",
      "port": "5679"
    }
  ]
}
```
## RAV-2
```
{
  "name": "onos",
  "node": {
    "id": "ONOS-RAV-2",
    "ip": "192.168.2.12",
    "port": 9876
  },
  "storage": [
    {
      "id": "RAV-1",
      "ip": "192.168.2.11",
      "port": "5679"
    },
    {
      "id": "RAV-2",
      "ip": "192.168.2.12",
      "port": "5679"
    }
  ]
}
```