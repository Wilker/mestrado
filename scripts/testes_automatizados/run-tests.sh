#!/bin/bash
SERVER='200.156.91.194'
C1='192.168.2.11'
C2='192.168.2.12'

#executa o comando direto no karaf
# ./bin/client apps

log(){
    date +%s | tee -a teste_script.txt
    echo -e $1 | tee -a teste_script.txt
}


log 'Conectando ao servidor';
log 'Iniciando testes';
log 'Conecantando como root';
ssh -p 2219 wilker@$SERVER 'echo 12345678 |  sudo -S ./init_server.sh'
log 'Conecatando como host';
ssh -p 2219 wilker@$SERVER  ./init_server.sh
