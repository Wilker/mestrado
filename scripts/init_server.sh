#!/bin/bash

log() {
  date +%s | tee -a teste_script.txt
  echo -e $1 | tee -a teste_script.txt
}

# iniciar atomix
start_atomix() {
  $(log 'Conectando ao servidor')
  cd ~/Documents/atomix/
  ./bin/atomix-agent >log.txt
}
