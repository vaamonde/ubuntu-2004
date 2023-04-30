#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 02/11/2021
# Data de atualização: 30/04/2023
# Versão: 0.18
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Netdata v1.37.x
#
# O Netdata é uma ferramenta para visualizar e monitorar métricas em tempo real, 
# otimizado para acumular todos os tipos de dados, como uso da CPU, atividade do 
# disco, consultas SQL, visitas a um site, etc. A ferramenta é projetada para 
# visualizar o agora com o máximo de detalhes possível, permitindo que o usuário 
# tenha uma visão do que está acontecendo e do que acaba de acontecer em seu 
# sistema ou aplicativo, sendo uma opção ideal para resolver problemas de desempenho
# em tempo real.
#
# Site oficial do Projeto Netdata: https://github.com/netdata/netdata
#
# Soluções Open Source de Monitoramento
# Site oficial do Projeto Monitorix: https://www.monitorix.org
# Site oficial do Projeto Alerta: https://alerta.io/
# Site oficial do Projeto MRTG: https://oss.oetiker.ch/mrtg/
#
# Informações que serão solicitadas na configuração via Web do Netdata
# URL: https://pti.intra:19999
#	Remember my choice: Yes
#		Later, stay at the agent dashboard
#
# OBSERVAÇÃO IMPORTANTE: por padrão o Netdata não faz atualização automática de versão,
# precisando executar manualmente o script de Update localizado em: /usr/libexec/netdata
# ou criar um arquivo de CRON para essa finalidade, recomendo usar manualmente o update.
#	./netdata-updater.sh
#
# Verificando a versão do Netdata instalada
#	sudo netdata -v
#
# Habilitando o Auto-Update do Netdata: 
#	sudo /usr/libexec/netdata/netdata-updater.sh --enable-auto-updates
#	sudo ls -lh /etc/cron.daily/netdata-updater
#
# Desabilitando o Auto-Update do Netdata: 
#	sudo /usr/libexec/netdata/netdata-updater.sh --disable-auto-updates
#
# Atualizando o Netdata:
#	sudo /usr/libexec/netdata/netdata-updater.sh
#	sudo netdata -v
#	sudo systemctl status netdata
#
# Arquivo de configuração dos parâmetros utilizados nesse script
source 00-parametros.sh
#
# Configuração da variável de Log utilizado nesse script
LOG=$LOGSCRIPT
#
# Verificando se o usuário é Root e se a Distribuição é >= 20.04.x 
# [ ] = teste de expressão, && = operador lógico AND, == comparação de string, exit 1 = A maioria 
# dos erros comuns na execução
clear
if [ "$USUARIO" == "0" ] && [ "$UBUNTU" == "20.04" ]
	then
		echo -e "O usuário é Root, continuando com o script..."
		echo -e "Distribuição é >= 20.04.x, continuando com o script..."
		sleep 5
	else
		echo -e "Usuário não é Root ($USUARIO) ou a Distribuição não é >= 20.04.x ($UBUNTU)"
		echo -e "Caso você não tenha executado o script com o comando: sudo -i"
		echo -e "Execute novamente o script para verificar o ambiente."
		exit 1
fi
#
# Verificando o acesso a Internet do servidor Ubuntu Server
# [ ] = teste de expressão, exit 1 = A maioria dos erros comuns na execução
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -z (scan for listening daemons), -w (timeouts), 1 (one timeout), 443 (port)
if [ "$(nc -zw1 google.com 443 &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "Você tem acesso a Internet, continuando com o script..."
		sleep 5
	else
		echo -e "Você NÃO tem acesso a Internet, verifique suas configurações de rede IPV4"
		echo -e "e execute novamente este script."
		sleep 5
		exit 1
fi
#
# Verificando se a porta 19999 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTNETDATA &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTNETDATA já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTNETDATA está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando se as dependências do Netdata estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Netdata, aguarde... "
	for name in $NETDATADEP
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            echo -en "Recomendo utilizar o script: 02-dhcp.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 03-dns.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 05-ntp.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 08-lamp.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 09-vsftpd.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 10-tomcat.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 11-A-openssl-ca.sh para resolver as dependências."
            exit 1; 
            }
		sleep 5
#
# Verificando se o script já foi executado mais de 1 (uma) vez nesse servidor
# OBSERVAÇÃO IMPORTANTE: OS SCRIPTS FORAM PROJETADOS PARA SEREM EXECUTADOS APENAS 1 (UMA) VEZ
if [ -f $LOG ]
	then
		echo -e "Script $0 já foi executado 1 (uma) vez nesse servidor..."
		echo -e "É recomendado analisar o arquivo de $LOG para informações de falhas ou erros"
		echo -e "na instalação e configuração do serviço de rede utilizando esse script..."
		echo -e "Todos os scripts foram projetados para serem executados apenas 1 (uma) vez."
		sleep 5
		exit 1
	else
		echo -e "Primeira vez que você está executando esse script, tudo OK, agora só aguardar..."
		sleep 5
fi
#
# Script de instalação do Netdata no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação e Configuração do Netdata no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Netdata.: TCP 19999"
echo -e "Após a instalação do Netdata acessar a URL: http://$(hostname -d | cut -d' ' -f1):19999/\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	# Universe - Software de código aberto mantido pela comunidade:
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository universe &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o Repositório Multiversão do Apt, aguarde..."
	# Multiverse – Software não suportado, de código fechado e com patente: 
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository multiverse &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o Repositório Restrito do Apt, aguarde..."
	# Restricted - Software de código fechado oficialmente suportado:
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository restricted &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando todo o sistema operacional, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
	apt -y dist-upgrade &>> $LOG
	apt -y full-upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo todos os software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
	apt -y autoclean &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando a Instalação e Configuração do Netdata, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do Netdata, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $NETDATAINSTALL &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Clonando o projeto do Netdata do Github, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando git clone: --recurse-submodules (initialize and clone submodules within
    # based on the provided pathspec)
	git clone --recurse-submodules $NETDATA &>> $LOG
echo -e "Clonagem do Netdata feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Netdata, esse processo demora um pouco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando echo |: faz a função de Enter no Script
	cd netdata/
		echo | ./netdata-installer.sh &>> $LOG
	cd ..
echo -e "Instalação do Netdata feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Usuário de monitoramento do MySQL do Netdata, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute), mysql (database)
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_USER_NETDATA" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_USAGE_NETDATA" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH_NETDATA" mysql &>> $LOG
echo -e "Usuário de monitoramento criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do Netdata, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/netdata/*.conf /usr/lib/netdata/conf.d/python.d/ &>> $LOG
	cp -v conf/netdata/apps_groups.conf /etc/netdata/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de monitoramento apache.conf, pressione <Enter> para editar"
	# opção do comando read: -s (Do not echo keystrokes)
	# teste de debug: /usr/libexec/netdata/plugins.d/python.d.plugin debug apache
	read -s
	vim /usr/lib/netdata/conf.d/python.d/apache.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de monitoramento mysql.conf, pressione <Enter> para editar"
	# opção do comando read: -s (Do not echo keystrokes)
	# teste de debug: /usr/libexec/netdata/plugins.d/python.d.plugin debug mysql
	read -s
	vim /usr/lib/netdata/conf.d/python.d/mysql.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de monitoramento isc_dhcpd.conf, pressione <Enter> para editar"
	# opção do comando read: -s (Do not echo keystrokes)
	# teste de debug: /usr/libexec/netdata/plugins.d/python.d.plugin debug isc_dhcpd
	read -s
	vim /usr/lib/netdata/conf.d/python.d/isc_dhcpd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de monitoramento tomcat.conf, pressione <Enter> para editar"
	# opção do comando read: -s (Do not echo keystrokes)
	# teste de debug: /usr/libexec/netdata/plugins.d/python.d.plugin debug tomcat
	read -s
	vim /usr/lib/netdata/conf.d/python.d/tomcat.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de estatísticas bind_rndc.conf, pressione <Enter> para editar"
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando read: -s (Do not echo keystrokes)
	# opção do comando chown: -v (verbose), :netdata (group netdata)
	# teste de debug: /usr/libexec/netdata/plugins.d/python.d.plugin debug bind_rndc
	read -s
	vim /usr/lib/netdata/conf.d/python.d/bind_rndc.conf
	chown -v :netdata /etc/bind/rndc.key &>> $LOG
	rndc stats &>> $LOG
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de monitoramento dockerd.conf, pressione <Enter> para editar"
	# opção do comando read: -s (Do not echo keystrokes)
	# teste de debug: /usr/libexec/netdata/plugins.d/python.d.plugin dockerd
	read -s
	vim /usr/lib/netdata/conf.d/python.d/dockerd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de monitoramento elasticsearch.conf, pressione <Enter> para editar"
	# opção do comando read: -s (Do not echo keystrokes)
	# teste de debug: /usr/libexec/netdata/plugins.d/python.d.plugin debug elasticsearch
	read -s
	vim /usr/lib/netdata/conf.d/python.d/elasticsearch.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de monitoramento mongodb.conf, pressione <Enter> para editar"
	# opção do comando read: -s (Do not echo keystrokes)
	# teste de debug: /usr/libexec/netdata/plugins.d/python.d.plugin mongodb
	read -s
	vim /usr/lib/netdata/conf.d/python.d/mongodb.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de monitoramento redis.conf, pressione <Enter> para editar"
	# opção do comando read: -s (Do not echo keystrokes)
	# teste de debug: /usr/libexec/netdata/plugins.d/python.d.plugin debug redis
	read -s
	vim /usr/lib/netdata/conf.d/python.d/redis.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de monitoramento ntpd.conf, pressione <Enter> para editar"
	# opção do comando read: -s (Do not echo keystrokes)
	# teste de debug: /usr/libexec/netdata/plugins.d/python.d.plugin debug ntpd
	read -s
	vim /usr/lib/netdata/conf.d/python.d/ntpd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do Netdata, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart netdata &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do Netdata, aguarde..."
	echo -e "Netdata: $(systemctl status netdata | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a versão do serviço instalado, aguarde..."
	# opção do comando netdata: -v (version)
	echo -e "Netdata Server..: $(netdata -v)"
echo -e "Versão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Netdata, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:"19999" -sTCP:LISTEN
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Netdata feita com Sucesso!!!"
	# script para calcular o tempo gasto (SCRIPT MELHORADO, CORRIGIDO FALHA DE HORA:MINUTO:SEGUNDOS)
	# opção do comando date: +%T (Time)
	HORAFINAL=$(date +%T)
	# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second), 
	TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
	# $0 (variável de ambiente do nome do comando)
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
read
exit 1
