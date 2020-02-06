#!/bin/bash

log() {
  date +%s | tee -a teste_script.txt
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


start_mininet
