#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 11/12/2021
# Data de atualização: 16/05/2023
# Versão: 0.09
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Zabbix Server e Agent v6.4.x 
#
# O Zabbix é uma ferramenta de software de monitoramento de código aberto para diversos 
# componentes de TI, incluindo redes, servidores, máquinas virtuais e serviços em nuvem. 
# O Zabbix fornece métricas de monitoramento, utilização da largura de banda da rede, 
# carga de uso CPU e consumo de espaço em disco, entre vários outros recursos de 
# monitoramento e alertas.
#
# Site Oficial do Projeto Zabbix: https://www.zabbix.com/
#
# Soluções Open Source de Monitoramento do Rede 
# Site Oficial do Nagios: https://www.nagios.org/
# Site Oficial do OpenNMS: https://www.opennms.com/
# Site Oficial do Cacti: https://www.cacti.net/
# Site Oficial do LibreMNS: https://www.librenms.org/ 
# Site Oficial do CheckMk: https://checkmk.com/
#
# Informações que serão solicitadas na configuração via Web do Zabbix Server
# Welcome to Zabbix 6.4: 
#		Default language: English (en_US): 
#	Next step;
# Check of pre-requisites: 
#	Next step;
# Configure DB connection:
#		Database type: MySQL
#		Database host: localhost
#		Database port: 0 (use default port: 3306)
#		Database name: zabbix
#		Store credentials in: Plain text 
#		User: zabbix
#		Password: zabbix: 
#	Next step;
# Zabbix server details
#		Host: localhost
#		Port: 10051
#		Name: ptispo01ws01
#	Next step;
# GUI settings
#		Default time zone: System
#		Default theme: Dark
#	Next step;
# Pre-installation summary
#	Next step.
# Install
#	Finish
#
# User Default: Admin (com A maiúsculo)
# Password Default: zabbix
#
# Instalação dos Agentes do Zabbix no GNU/Linux e Microsoft
#
# Download do Zabbix Agent para GNU/Linux: https://www.zabbix.com/download
#	Zabbix Version: 6.4
#	OS Distribution: Ubuntu
#	OS Version: 20.04 (Focal)
#	Zabbix Componet: Agent
#	Database: None
#	Web Server: None
#
# Instalação Manual do Zabbix Agent para GNU/Linux:
#	Terminal (Ctrl + Alt + T)
#		wget PACOTE_ZABBIX_AGENT.deb
#		sudo dpkg -i zabbix-release*.deb
#		sudo apt update
#		sudo apt install zabbix-agent vim
#		sudo vim /etc/zabbix/zabbix_agentd.conf
#			INSERT
#				#alterar as linhas 117, 171 e 182:
#				Server=ptispo01ws01.pti.intra
#				ServerActive=ptispo01ws01.pti.intra
#				Hostname=ptispo01dt001.pti.intra
#			ESC SHIFT : <Enter>
#		sudo systemctl enable zabbix-agent
#		sudo systemctl restart zabbix-agent
#		sudo systemctl status zabbix-agent
#		sudo lsof -nP -iTCP:'10050' -sTCP:LISTEN
#
# Download Zabbix Agent para Microsoft: https://www.zabbix.com/download_agents
#	OS Distribution: Windows
#	OS Version: Any
#	Hardware: amd64
#	Zabbix Version: 6.4
#	Encryption: OpenSSL
#	Packaging: MSI
#	Zabbix Release: 6.4.x <Download>
#
# Instalação Manual do Zabbix Agent para Microsoft
# Pasta de Download
#	Welcome to the Zabbix Agent (64-bit) Setup Wizard <Next>
#	End-User License Agreement
#		On I accept the therms in the License Agreement <Next>
#	Custom Setup
#		On Zabbix Agent <Next>
#	Zabbix Agent service configuration
#		Host name: ptispo01dt002.pti.intra
#		Zabbix server IP/DNS: ptispo01ws01.pti.intra
#		Agent listen port: 10050
#		Server or Proxy for active checks: ptispo01ws01.pti.intra
#		Off Enable PSK
#		On Add agent location to the PATH <Next>
#	Ready to install Zabbix Agent (64-bit) <Install>
#		Zabbix Agent MSI package (64)-bit <Sim>
#	Completed the Zabbix Agent (64-bit) <Finish>
#
# Powershell
#	hostname
#	netstat -an | findstr 10050
#	Get-Service Zabbix-Agent
#
# Criação dos Host GNU/Linux e Microsoft Windows no Zabbix Server
# Data collection
#	Hosts
#		<Create host>
#			Host
#				Host name: ptispo01dt001.pti.intra
#				Visible name: ptispo01dt001.pti.intra
#				Templates: <Select>
#					Template group: <Select>
#						Templates/Operating systems
#						Linux by Zabbix agent <Select>
#				Host groups: <select>
#					Discovered hosts <Select>
#				Interfaces: Add:
#					Agent: 
#						DNS name: ptispo01dt001.pti.intra
#						Connect to: DNS
#						Port: 10050
#				Description: Desktop GNU/Linux Mint
#				Monitored by proxy: (no proxy)
#				Enable: On
#			<Add>
#
# Data collection
#	Hosts
#		<Create host>
#			Host
#				Host name: ptispo01dt002.pti.intra
#				Visible name: ptispo01dt002.pti.intra
#				Templates: <Select>
#					Template group: <Select>
#						Templates/Operating systems
#						Windows by Zabbix agent <Select>
#				Host groups: <select>
#					Discovered hosts <Select>
#				Interfaces: Add:
#					Agent: 
#						DNS name: ptispo01dt002.pti.intra
#						Connect to: DNS
#						Port: 10050
#				Description: Desktop Microsoft Windows 10
#				Monitored by proxy: (no proxy)
#				Enable: On
#			<Add>
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
# Verificando se as portas 10050 e 10051 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTZABBIX1 &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTZABBIX1 já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTZABBIX1 está disponível, continuando com o script..."
		sleep 5
fi
if [ "$(nc -vz 127.0.0.1 $PORTZABBIX2 &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTZABBIX2 já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTZABBIX2 está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando se as dependências do Zabbix Server estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Zabbix Server, aguarde... "
	for name in $ZABBIXDEP
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            echo -en "Recomendo utilizar o script: 03-dns.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 07-lamp.sh para resolver as dependências."
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
# Script de instalação do Zabbix Server no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Zabbix Server e Agent no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Zabbix Server.: TCP 10050 e 10051\n"
echo -e "Após a instalação do Zabbix Server acesse a URL: https://$(hostname -d | cut -d' ' -f1)/zabbix/\n"
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
	#opção do comando: &>> (redirecionar a saída padrão)
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
echo -e "Iniciando a Instalação e Configuração do Zabbix Server e Agent, aguarde...\n"
sleep 5
#
echo -e "Fazendo o download e instalando o Repositório do Zabbix Server, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando wget: -O (output document file)
	# opção do comando rm: -v (verbose)
	# opção do comando dpkg: -i (install)
	rm -v zabbix.deb &>> $LOG
	wget $ZABBIXIREP -O zabbix.deb &>> $LOG
	dpkg -i zabbix.deb &>> $LOG
echo -e "Repositório instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt com o novo Repositório do Zabbix Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Zabbix Server e Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y $ZABBIXINSTALL &>> $LOG
echo -e "Zabbix Server e Agent instalados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Banco de Dados e Populando as Tabelas do Zabbix Server, aguarde esse processo demora um pouco..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando: | piper (conecta a saída padrão com a entrada padrão de outro comando)
	# opção do comando mysql: -u (user), -p (password), -e (execute)
	# opção do comando zcat: -v (verbose)
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_DATABASE_ZABBIX" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_USER_DATABASE_ZABBIX" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_DATABASE_ZABBIX" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_ALL_DATABASE_ZABBIX" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$SET_GLOBAL_ZABBIX" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH_ZABBIX" mysql &>> $LOG
	zcat -v $CREATE_TABLE_ZABBIX | mysql -uzabbix -pzabbix zabbix &>> $LOG
echo -e "Banco de Dados criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do Zabbix Server e Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	mv -v /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.old &>> $LOG
	mv -v /etc/zabbix/apache.conf /etc/zabbix/apache.conf.old &>> $LOG
	mv -v /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.old &>> $LOG
	cp -v conf/zabbix/{zabbix_server.conf,apache.conf,zabbix_agentd.conf} /etc/zabbix/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração zabbix_server.conf, pressione <Enter> para continuar..."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/zabbix/zabbix_server.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração apache.conf, pressione <Enter> para continuar..."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/zabbix/apache.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração zabbix_agentd.conf, pressione <Enter> para continuar..."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/zabbix/zabbix_agentd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando os serviços do Zabbix Server, Agent e do Apache2,  aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable zabbix-server zabbix-agent &>> $LOG
	systemctl restart zabbix-server zabbix-agent apache2 &>> $LOG
echo -e "Serviços reinicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando os serviços do Zabbix Server, Agent e do Apache2, aguarde..."
	echo -e "Zabbix Server...: $(systemctl status zabbix-server | grep Active)"
	echo -e "Zabbix Agent....: $(systemctl status zabbix-agent | grep Active)"
	echo -e "Apache2 Server..: $(systemctl status apache2 | grep Active)"
echo -e "Serviços verificados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as versões dos serviços instalados, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "Apache2 Server..: $(dpkg-query -W -f '${version}\n' apache2)"
	echo -e "MySQL Server....: $(dpkg-query -W -f '${version}\n' mysql-server)"
	echo -e "SNMP Server.....: $(dpkg-query -W -f '${version}\n' snmp)"
	echo -e "PHP.............: $(dpkg-query -W -f '${version}\n' php)"
	echo -e "Zabbix Agent....: $(dpkg-query -W -f '${version}\n' zabbix-agent)"
	echo -e "Zabbix Server...: $(dpkg-query -W -f '${version}\n' zabbix-server-mysql)"
echo -e "Versões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "ANTES DE CONTINUAR COM O SCRIPT ACESSE A URL: https://$(hostname -d | cut -d' ' -f1)/zabbix/"
echo -e "PARA FINALIZAR A CONFIGURAÇÃO VIA WEB DO ZABBIX SERVER, APÓS A"
echo -e "CONFIGURAÇÃO PRESSIONE <ENTER> PARA CONTINUAR COM O SCRIPT."
echo -e "MAIS INFORMAÇÕES NA LINHA 30 DO SCRIPT: $0"
read
sleep 5
#
echo -e "Verificando as portas de conexão do Zabbix Server, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:'10050,10051' -sTCP:LISTEN
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Zabbix Server e Agent feita com Sucesso!!!."
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
