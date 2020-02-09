#!/bin/bash

log() {
  date | tee -a teste_script.txt
  echo -e $1 | tee -a teste_script.txt
}

is_onos_running() {
  if [ "$(ps aux | grep onos | wc -l)" -gt 1 ]; then
    echo 1
  else
    echo 0
  fi
}

onos_started_with_error() {
  if [ "$(cat onos.log | grep ERROR | grep -c "onos-core")" -gt 1 ]; then
    echo 1
  else
    echo 0
  fi
}

start_onos() {
  log "Entrando na pasta do onos"
  cd ~/Documents/onos-2.1.0
  log "Iniciando Onos controller"
  sudo ./bin/onos-service > ../onos.log &
}