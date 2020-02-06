#!/bin/bash
C1='192.168.2.11'
C2='192.168.2.12'

log() {
  date | tee -a teste_script.txt
  echo -e $1 | tee -a teste_script.txt
}

# iniciar atomix
start_atomix() {
  log 'Iniciando servidor atomix'
  cd ~/Documentos/atomix/
  ./bin/atomix-agent > result.txt 2>&1 &
}


start_mininet() {
  log 'Iniciando mininet'
 #cd ~/Documentos/mininet/
  python myTopology.py
}

start_controllers() {
  log 'Conectando aos Controladores'
  for c in $C1 $C2 
  do
    log "Conectando ao $c"
    ssh $c 'cd Documents; echo hello world from server> testee'
  done
}

start_controllers
