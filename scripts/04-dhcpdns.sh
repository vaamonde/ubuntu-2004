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
# Versão: 0.15
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do ISC DHCP Server v4.4.x e Bind DNS Sever v9.16.x
#
# O Bind DNS Server BIND (Berkeley Internet Name Domain ou, como chamado previamente, 
# Berkeley Internet Name Daemon) é o servidor para o protocolo DNS mais utilizado na 
# Internet, especialmente em sistemas do tipo Unix, onde ele pode ser considerado um 
# padrão de facto. Foi criado por quatro estudantes de graduação, membros de um grupo 
# de pesquisas em ciência da computação da Universidade de Berkeley, e foi distribuído 
# pela primeira vez com o sistema operacional 4.3 BSD. Atualmente o BIND é suportado e 
# mantido pelo Internet Systems Consortium.
#
# O ISC DHCP Server dhcpd (uma abreviação de "daemon DHCP") é um programa de servidor 
# DHCP que opera como um daemon em um servidor para fornecer serviço de protocolo de 
# configuração dinâmica de hosts (DHCP) a uma rede. Essa implementação, também conhecida 
# como ISC DHCP, é uma das primeiras e mais conhecidas, mas agora existem várias outras 
# implementações de software de servidor DHCP disponíveis.
#
# Site Oficial do Projeto Bind: https://www.isc.org/bind/
# Site Oficial do Projeto Dnsmasq: https://thekelleys.org.uk/dnsmasq/doc.html
# Site Oficial do Projeto Powerdns: https://www.powerdns.com/
# Site Oficial do Projeto ICS DHCP: https://www.isc.org/dhcp/
#
# Configuração do DHCP Client no GNU/Linux ou Microsoft Windows
# Linux Mint Gráfico: NetworkManager - Ícone da Placa de Rede
# Linux Mint Terminal: Ctrl+Alt+T
# 	sudo NetworkManager --print-config (network management daemon)
# 	sudo nmcli device status (command-line tool for controlling NetworkManager)
# 	sudo nmcli device show enp0s3 (command-line tool for controlling NetworkManager)
# 	sudo networkctl status enp0s3 Query the status of network links)
# 	sudo ifconfig enp0s3 (configure a network interface)
# 	sudo ip address show enp0s3 (show / manipulate routing, network devices, interfaces and tunnels)
# 	sudo route -n (show/manipulate IP routing table)
# 	sudo systemd-resolve --status (Resolve domain names, IPV4 and IPv6 addresses, DNS resource records, and services)
# 	sudo dhclient -r enp0s3 (Dynamic Host Configuration Protocol Client)
# 	sudo dhclient enp0s3 (Dynamic Host Configuration Protocol Client)
# 	sudo cat /var/lib/dhcp/dhclient.leases (DHCP client lease database)
#	nslookup pti.intra (query Internet name servers interactively)
#	dig pti.intra (DNS lookup utility)
#	host pti.intra (DNS lookup utility)
#	ping pti.intra (send ICMP ECHO_REQUEST to network hosts)
#
# Windows Powershell: 
#	ipconfig /all
#	ipconfig /release
#	ipconfig /renew
#	netsh interface show interface
#	netsh interface ip show interface
#	netsh interface ip show config
#	nslookup pti.intra
#	ipconfig /displaydns
#	ping pti.intra
#	Resolve-DnsName pti.intra
#	Test-Connection pti.intra
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
# Verificando todas as dependências da Integração do do ICS DHCP Server com Bind DNS Server
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências da Integração do DHCP e DNS Server, aguarde... "
	for name in $DHCPDNSDEP 
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
			echo -en "Recomendo utilizar o script: 02-dhcp.sh para resolver as dependências"
			echo -en "Recomendo utilizar o script: 03-dns.sh para resolver as dependências."
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
# Script de integração do ICS DHCP Server com Bind DNS Server no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Integração do ICS DHCP Server com Bind DNS Server no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Bind9 DNS Server.: UDP 53 e TCP 53"
echo -e "Porta padrão utilizada pelo RNDC.: TCP 953"
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
echo -e "Iniciando a Configuração da Integração do ICS DHCP Server com Bind DNS Server, aguarde...\n"
sleep 5
#
echo -e "Gerando a Chave de atualização do Bind DNS Server utilizada no ISC DHCP Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando dnssec-keygen: Nas versões anteriores do BIND <9.13, os algoritmos HMAC podiam 
	# ser gerados para uso como chaves TSIG, esse recurso foi removido a partir do BIND > 9.13, nesse 
	# cenário é recomendado utilizar o comando: tsig-keygen para gerar chaves TSIG. 
	# opção do comando tsig-keygen: -a (algorithm)
	# opção do comando cut: -d (delimiter), -f (fields)
	# opção do comando tr: -d (delete)
	tsig-keygen -a hmac-md5 $USERUPDATE > tsig.key
	KEYGEN=$(cat tsig.key | grep secret | cut -d' ' -f2 | tr -d ';|"')
echo -e "Geração da chave feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do Bind DNS Server e do ISC DHCP Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando sed: s (replacement)
	# opção do comando cp: -v (verbose)
	sed "s@secret $SECRETUPDATE;@secret $KEYGEN;@" /etc/dhcp/dhcpd.conf > /tmp/dhcpd.conf.old
	sed 's@secret "'$SECRETUPDATE'";@secret "'$KEYGEN'";@' /etc/bind/named.conf.local > /tmp/named.conf.local.old
	sed 's@secret "'$SECRETUPDATE'";@secret "'$KEYGEN'";@' /etc/bind/rndc.key > /tmp/rndc.key.old
	cp -v /tmp/dhcpd.conf.old /etc/dhcp/dhcpd.conf &>> $LOG
	cp -v /tmp/named.conf.local.old /etc/bind/named.conf.local &>> $LOG
	cp -v /tmp/rndc.key.old /etc/bind/rndc.key &>> $LOG
echo -e "Atualização dos arquivos feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração named.conf.local, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/bind/named.conf.local
	named-checkconf /etc/bind/named.conf.local &>> $LOG
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração rndc.key, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/bind/rndc.key
	named-checkconf /etc/bind/rndc.key &>> $LOG
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
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
echo -e "Reinicializando os serviços do ISC DHCP Server e do Bind DNS Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart isc-dhcp-server &>> $LOG
	systemctl restart bind9 &>> $LOG
	systemctl reload bind9 &>> $LOG
	rndc sync -clean &>> $LOG
	rndc stats &>> $LOG
echo -e "Serviços reinicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando os serviços do ISC DHCP Server e do Bind DNS Server, aguarde..."
	echo -e "ISC DHCP: $(systemctl status isc-dhcp-server | grep Active)"
	echo -e "Bind DNS: $(systemctl status bind9 | grep Active)"
echo -e "Serviços verificados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as versões dos serviços instalados, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "Bind DNS Server..: $(dpkg-query -W -f '${version}\n' bind9)"
	echo -e "ISC DHCP Server..: $(dpkg-query -W -f '${version}\n' isc-dhcp-server)"
echo -e "Versões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexão do Bind9 DNS Server e do ISC DHCP Server, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iUDP:"53,67"
	echo -e "============================================================="
	lsof -nP -iTCP:53 -sTCP:LISTEN
	echo -e "============================================================="
	lsof -nP -iTCP:953 -sTCP:LISTEN
echo -e "Portas verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#	
echo -e "Integração do ICS DHCP Server com Bind DNS Server feita com Sucesso!!!."
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
