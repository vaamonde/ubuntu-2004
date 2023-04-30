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
# Versão: 0.18
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do ISC DHCP Server v4.4.x
# Testado e homologado para a versão do Bind DNS Sever v9.16.x
#
# O Bind DNS Server BIND (Berkeley Internet Name Domain ou, como chamado previamente, 
# Berkeley Internet Name Daemon) é o servidor para o protocolo DNS mais utilizado na 
# Internet, especialmente em sistemas do tipo Unix, onde ele pode ser considerado um 
# padrão de facto. Foi criado por quatro estudantes de graduação, membros de um grupo 
# de pesquisas em ciência da computação da Universidade de Berkeley, e foi distribuído 
# pela primeira vez com o sistema operacional 4.3 BSD. Atualmente o BIND é suportado e 
# mantido pelo Internet Systems Consortium.
#
# Site Oficial do Projeto Bind: https://www.isc.org/bind/
#
# Soluções Open Source de Servidor de DNS
# Site Oficial do Projeto Dnsmasq: https://thekelleys.org.uk/dnsmasq/doc.html
# Site Oficial do Projeto Powerdns: https://www.powerdns.com/
#
# Testando o DNS no GNU/Linux ou Microsoft Windows
# Linux Mint Terminal: Ctrl+Alt+T 
#	nslookup pti.intra (query Internet name servers interactively)
#	dig pti.intra (DNS lookup utility)
#	host pti.intra (DNS lookup utility)
#	ping pti.intra (send ICMP ECHO_REQUEST to network hosts)
#
# Windows Powershell.: 
#	nslookup pti.intra
#	nslookup 172.16.1.20
#	nslookup ptispo01ws01
#	nslookup ptispo01ws01.pti.intra
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
# Verificando se a porta 53 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), u (UDP), &> redirecionador de saída de erro
if [ "$(nc -vzu 127.0.0.1 $PORTDNS &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTDNS já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTDNS está disponível, continuando com o script..."
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
# Script de instalação do Bind9 DNS Server no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Bind DNS Server no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Bind9 DNS Server.: UDP 53 e TCP 53"
echo -e "Porta padrão utilizada pelo RNDC.: TCP 953\n"
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
echo -e "Iniciando a Instalação e Configuração do Bind9 DNS Server, aguarde...\n"
sleep 5
#
echo -e "Instalando o Bind9 DNS Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $DNSINSTALL &>> $LOG
echo -e "Bind9 DNS Server instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração hostname, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/hostname
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração hosts, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/hosts
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração nsswitch.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/nsswitch.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
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
echo -e "Atualizando os arquivos de configuração do Bind DNS Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	# opção do comando chown: -R (recursive), -v (verbose), root (user), bind (user), bind (group)
	mkdir -v /var/log/named/ &>> $LOG
	chown -Rv bind:bind /var/log/named/ &>> $LOG
	mv -v /etc/bind/named.conf /etc/bind/named.conf.old &>> $LOG
	mv -v /etc/bind/named.conf.local /etc/bind/named.conf.local.old &>> $LOG
	mv -v /etc/bind/named.conf.options /etc/bind/named.conf.options.old &>> $LOG
	mv -v /etc/bind/named.conf.default-zones /etc/bind/named.conf.default-zones.old &>> $LOG
	mv -v /etc/bind/rndc.key /etc/bind/rndc.key.old &>> $LOG
	mv -v /etc/default/named /etc/default/named.old &>> $LOG
	cp -v conf/dns/{named.conf,named.conf.local,named.conf.options,named.conf.default-zones,rndc.key} /etc/bind/ &>> $LOG
	cp -v conf/dns/{pti.intra.hosts,172.16.1.rev} /var/lib/bind/ &>> $LOG
	cp -v conf/dns/{dnsupdate-cron,rndcupdate-cron} /etc/cron.d/ &>> $LOG
	cp -v conf/dns/named /etc/default/ &>> $LOG
	cp -v conf/dns/rndcstats /etc/logrotate.d/ &>> $LOG
	chown -v root:bind /etc/bind/rndc.key &>> $LOG
	chown -v root:bind /var/lib/bind/{pti.intra.hosts,172.16.1.rev} &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração named.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/bind/named.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração named.conf.local, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/bind/named.conf.local
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração named.conf.options, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/bind/named.conf.options
	named-checkconf &>> $LOG
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração named.conf.default-zones, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/bind/named.conf.default-zones
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração rndc.key, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/bind/rndc.key
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração pti.intra.hosts, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /var/lib/bind/pti.intra.hosts
	named-checkzone $DOMAIN /var/lib/bind/pti.intra.hosts &>> $LOG
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração 172.16.1.rev, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /var/lib/bind/172.16.1.rev
	named-checkzone $DOMAINREV /var/lib/bind/172.16.1.rev &>> $LOG
	named-checkzone $NETWORK /var/lib/bind/172.16.1.rev &>> $LOG
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração named, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/default/named
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração dnsupdate-cron, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/cron.d/dnsupdate-cron
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração rndcupdate-cron, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/cron.d/rndcupdate-cron
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração rndcstats, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando read: -s (Do not echo keystrokes)
	# opção do comando logrotate: -d (debug)
	read -s
	vim /etc/logrotate.d/rndcstats
	logrotate /etc/logrotate.d/rndcstats -d &>> $LOG
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Inicializando os serviços do Netplan e do Bind DNS Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	netplan --debug apply &>> $LOG
	systemctl restart bind9 &>> $LOG
	systemctl reload bind9 &>> $LOG
	rndc sync -clean &>> $LOG
	rndc stats &>> $LOG
echo -e "Serviços inicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do Bind DNS Server, aguarde..."
	echo -e "Bind DNS Server: $(systemctl status bind9 | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a versão do serviço instalado, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "Bind DNS Server..: $(dpkg-query -W -f '${version}\n' bind9)"
echo -e "Versão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexões do Bind DNS Server, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iUDP:53
	echo -e "============================================================="
	lsof -nP -iTCP:53 -sTCP:LISTEN
	echo -e "============================================================="
	lsof -nP -iTCP:953 -sTCP:LISTEN
echo -e "Portas verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a resolução do Domínio: $DOMAIN, aguarde..."
	# opção do comando dig: +noall (set or clean all display flags), +answer (display the answer 
	# section of a reply)
	dig $DOMAIN +noall +answer
echo -e "Domínio verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Bind DNS Server feita com Sucesso!!!."
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
