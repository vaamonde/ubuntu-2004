#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 10/10/2021
# Data de atualização: 30/04/2023
# Versão: 0.16
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do ISC DHCP Server v4.4.x
#
# O ISC DHCP Server dhcpd (uma abreviação de "daemon DHCP") é um programa de servidor 
# DHCP que opera como um daemon em um servidor para fornecer serviço de protocolo de 
# configuração dinâmica de hosts (DHCP) a uma rede. Essa implementação, também conhecida 
# como ISC DHCP, é uma das primeiras e mais conhecidas, mas agora existem várias outras 
# implementações de software de servidor DHCP disponíveis.
#
# Site Oficial do Projeto ICS DHCP: https://www.isc.org/dhcp/
#
# Configuração do DHCP Client no GNU/Linux ou Microsoft Windows
# Linux Mint Gráfico: NetworkManager - Ícone da Placa de Rede
# Linux Mint Terminal: Ctrl+Alt+T
# 	sudo NetworkManager --print-config (network management daemon)
# 	sudo nmcli device status (command-line tool for controlling NetworkManager)
# 	sudo nmcli device show enp0s3 (command-line tool for controlling NetworkManager)
# 	sudo networkctl status enp0s3 (Query the status of network links)
# 	sudo ifconfig enp0s3 (configure a network interface)
# 	sudo ip address show enp0s3 (show / manipulate routing, network devices, interfaces and tunnels)
# 	sudo route -n (show/manipulate IP routing table)
# 	sudo systemd-resolve --status (Resolve domain names, IPV4 and IPv6 addresses, DNS resource records, and services)
# 	sudo dhclient -v -r enp0s3 (Dynamic Host Configuration Protocol Client)
# 	sudo dhclient -v enp0s3 (Dynamic Host Configuration Protocol Client)
# 	sudo cat /var/lib/dhcp/dhclient.leases (DHCP client lease database)
#
# Windows Powershell: 
#	getmac
#	ipconfig /all
#	ipconfig /release
#	ipconfig /renew
#	route print
#	netsh interface show interface
#	netsh interface ip show interface
#	netsh interface ip show config
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
# Verificando se a porta 67 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), u (UDP), &> redirecionador de saída de erro
if [ "$(nc -vzu 127.0.0.1 $PORTDHCP &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTDHCP já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTDHCP está disponível, continuando com o script..."
		sleep 5
fi
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
# Script de instalação do ICS DHCP Server no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do ISC DHCP Server no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo ISC DHCP Server.: UDP 67\n"
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
echo -e "Iniciando a Instalação e Configuração do ISC DHCP Server, aguarde...\n"
sleep 5
#
echo -e "Instalando o ISC DHCP Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $DHCPINSTALL &>> $LOG
echo -e "ISC DHCP Server instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo $NETPLAN, pressione <Enter> para continuar.\n"
echo -e "CUIDADO!!!: o nome do arquivo de configuração da placa de rede pode mudar"
echo -e "dependendo da versão do Ubuntu Server, verifique o conteúdo do diretório:"
echo -e "/etc/netplan para saber o nome do arquivo de configuração do Netplan e altere"
echo -e "o valor da variável NETPLAN no arquivo de configuração: 00-parametros.sh"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim $NETPLAN
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do ISC DHCP Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comando wget: -P (directory-prefix)
	mv -v /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.old &>> $LOG
	mv -v /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.old &>> $LOG
	cp -v conf/dhcp/dhcpd.conf /etc/dhcp/ &>> $LOG
	cp -v conf/dhcp/isc-dhcp-server /etc/default/ &>> $LOG
	cp -v conf/dhcp/isc-dhcp-server.service /lib/systemd/system/ &>> $LOG
	wget $OUI -P /usr/local/etc/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração dhcpd.conf, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando read: -s (Do not echo keystrokes)
	# opção do comando dhcpd: -t (test the configuration file)
	read -s
	vim /etc/dhcp/dhcpd.conf
	dhcpd -t &>> $LOG
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração isc-dhcp-server, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando read: -s (Do not echo keystrokes)
	# opção do comando dhcpd: -t (test the configuration file)
	read -s
	vim /etc/default/isc-dhcp-server
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando os serviços do Netplan e do ISC DHCP Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	netplan --debug apply &>> $LOG
	systemctl start isc-dhcp-server &>> $LOG
echo -e "Serviços inicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do ISC DHCP Server, aguarde..."
	echo -e "ISC DHCP: $(systemctl status isc-dhcp-server | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a versão do serviço instalado, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "ISC DHCP Server..: $(dpkg-query -W -f '${version}\n' isc-dhcp-server)"
echo -e "Versão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do ISC DHCP Server, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iUDP:67
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#	
echo -e "Instalação do ICS DHCP Server feita com Sucesso!!!."
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
