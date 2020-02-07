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