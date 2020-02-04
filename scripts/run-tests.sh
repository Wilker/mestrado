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
#1 - sincronizar o tempo entre todas as máquinas
# atualmente ntp no servidor da teasa-10

# 1 - ssh no servidor


#CMD="ssh wilker@'$C1 ./init_test.sh'"
CMD=ssh wilker@$SERVER whoami

gnome-terminal -e "bash -c
\"$(log 'Conectando ao servidor');
$(log 'Iniciando testes');
echo -e '$CMD';
$CMD;
exec bash\""


# ssh wilker@'$C1 ./init_test.sh'  


# 2 - ssh do servidor para o controlador 1
# 3 - ssh do servidor para o controlador 2
# 4 - executar mininet com a topologia no controlador no servidor
# 5 - executar atomix no controlador 1
# 6 - executar atomix no controlador 2
# 7 - executar atomix no servidor
# 8 - iniciar o onos no 