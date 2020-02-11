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
  if [ "$(is_onos_running)" -eq 0 ]; then
    log "Entrando na pasta do onos"
    cd ~/Documents/onos-2.1.0
    log "Iniciando Onos controller"
    sudo ./bin/onos-service >../onos.log &
  fi
  if [ "$(onos_started_with_error)" -eq 1 ]; then
    #mata o onos
    sudo pkill java
    sudo pkill onos
    sudo killall java
    sleep 20
    start_onos
  fi

}

execute_test() {
  log "Iniciando o teste"
  log "Desabilitando interface de rede"
  sudo ifconfig enp0s2 down
  log "Dormindo por 1 minuto"
  sleep 60
  log "Habilitando interface de rede"
  sudo ifconfig enp0s2 up
}