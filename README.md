# Repositório de scripts e arquivos de testes para o Mestrado em Computação


## Script de inicialização de ambiente de testes de controladores distribuídos utilizando o controlador Onos e mininet
#### Pré-requisitos instalados na máquina
1. Docker
    - Criar uma rede docker com o comando abaixo

        `docker network create --subnet=172.18.0.0/16 rede-onos`
2. Mininet

#### Features
Atualmente o script executa os seguintes passos
- Criação dos arquivos de configuração das instâncias Atomix
- Criação dos arquivos de configuração das instâncias Onos
- Execução das instâncias Atomix
- Execução das instâncias Onos
- Criação de um arquivo de topologia* Mininet
- Execução do Mininet com o arquivo de topologia* criado


#### Uso 
`./start <numero_de_instancias>`


***OBS**: A topologia padrão utilizada no teste é a que segue:

![][topologia]

[topologia]:/assets/Topologia.png