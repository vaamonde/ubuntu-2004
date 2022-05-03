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
# Data de atualização: 31/03/2022
# Versão: 0.20
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do NTP Server v4.2.
#
# O NTP é um protocolo para sincronização dos relógios dos computadores baseado 
# no protocolo UDP sob a porta 123. É utilizado para sincronização do relógio de 
# um conjunto de computadores e dispositivos em redes de dados com latência variável. 
#
# O projeto NTP.br tem por objetivo oferecer condições para que os servidores de 
# Internet no Brasil estejam sincronizados com a Horal Legal Brasileira. Para isso 
# foi firmado um acordo entre o Observatório Nacional (ON) e o NIC.br. 
#
# Os servidores Stratum 1 (primários) de nível mais baixo são sincronizados diretamente 
# com os serviços de horário nacional por meio de um modem de satélite, rádio ou telefone.
#
# Os servidores Stratum 2 (secundários) são sincronizados com os servidores Stratum 1 
# e assim por diante, de forma que os clientes NTP e os servidores com um número 
# relativamente pequeno de clientes não sincronizem com os servidores primários públicos.
#
# O NTS é um mecanismo para usar TLS para prover segurança criptográfica para o NTP no modo 
# cliente/servidor. TLS é o mesmo mecanismo de segurança, baseado em chaves públicas, amplamente
# utilizado na web, para garantir a autenticidade dos sites usando o protocolo https. Confiável 
# e amplamente conhecido e utilizado pela comunidade técnica.
#
# Site Oficial do Projeto NTP: http://www.ntp.org/
# Site Oficial do Projeto NTP.br: https://ntp.br/
# Site Oficial do Projeto NTPSec: https://www.ntpsec.org/
#
# Sincronização de data e hora Windows NTP.br: https://ntp.br/guia/windows/
# Sincronização de data e hora GNU/Linux NTP.br: https://ntp.br/guia/linux/
#
# Configuração do NTP Client no GNU/Linux ou Microsoft Windows
# Linux Mint Terminal: Ctrl+Alt+T
#	sudo apt install ntpdate ntpstat
# 	sudo ntpdate -s 172.16.1.20 ou ntp.pti.intra (set the date and time via NTP)
#	sudo ntpdate -dquv ntp.pti.intra (update date and time via NTP)
#	sudo ntpq -pn (standard NTP query program)
#	sudo ntpq -c sysinfo (standard NTP query program)
#	sudo vim /etc/systemd/timesyncd.conf (Network Time Synchronization configuration files)
#	sudo systemctl restart systemd-timesyncd (Daemon for synchronizing the system clock across the network)
#	sudo timedatectl (Control the system time and date)
#	sudo timedatectl show (Control the system time and date)
#	sudo timedatectl set-ntp true (Controls whether network time synchronization is active and enabled)
#	sudo timedatectl status (Show current settings of the system clock and RTC)
#	sudo timedatectl timesync-status (Show current status)
#	sudo timedatectl show-timesync (Show the same information as timesync-status)
#	sudo date (print or set the system date and time)
#	sudo hwclock (time clocks utility)
#
# Windows Powershell: 
#	Painel de Controle, Relógio e Região, Data e Hora, Horário de Internet
#		Alterar Configurações
#			Servidor: ntp.pti.intra <Atualizar Agora>
#	date
#	time (somente no CMD - PowerShell não funciona)
#	net time \\172.16.1.20 /set /yes (Somente após instalar o SAMBA-4, WINS e NetBIOS)
#	w32tm /query /status
#	w32tm /query /configuration
#	w32tm /config /syncfromflags:manual /manualpeerlist:”ntp.pti.intra” /reliable:yes /update
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
# Verificando se a porta 123 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), u (UDP), &> redirecionador de saída de erro
if [ "$(nc -vzu 127.0.0.1 $PORTNTP &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTNTP já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTNTP está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando as dependências do NTP Server estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retorna 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do NTP Server e Client, aguarde... "
	for name in $NTPDEP
	do
		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
			echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
			deps=1; 
			}
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
			echo -en "\nInstale as dependências acima e execute novamente este script\n";
			echo -en "Recomendo utilizar o script: 02-dhcp.sh para resolver as dependências do ISC DHCP"
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
# Script de instalação do NTP Server e Client no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do NTP Server e Client no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo NTP Server.: UDP 123\n"
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
echo -e "Iniciando a Instalação e Configuração o NTP Server e Client, aguarde...\n"
sleep 5
#
echo -e "Instalando o NTP Server e Client, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $NTPINSTALL &>> $LOG
echo -e "NTP Server e Client instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do NTP Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comando chown: -v (verbose), ntp (user), ntp (group)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	mv -v /etc/ntp.conf /etc/ntp.conf.old &>> $LOG
	mv -v /etc/default/ntpdate /etc/default/ntpdate.old &>> $LOG
	mv -v /etc/default/ntp /etc/default/ntp.old &>> $LOG
	cp -v conf/ntp/ntp.conf /etc/ &>> $LOG
	cp -v conf/ntp/ntp.drift /var/lib/ntp/ &>> $LOG
	cp -v conf/ntp/{ntp,ntpdate} /etc/default/ &>> $LOG
	chown -v ntp.ntp /var/lib/ntp/ntp.drift &>> $LOG
echo -e "Arquivos do NTP Server atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração ntp.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/ntp.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração ntp, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/default/ntp
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração ntpdate, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/default/ntpdate
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração dhcpd.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/dhcp/dhcpd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o Timezone e Locale do Servidor, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	timedatectl set-timezone "$TIMEZONE" &>> $LOG
	locale-gen $LOCALE &>> $LOG
	localectl set-locale LANG=$LOCALE &>> $LOG
	update-locale LANG=$LOCALE LC_ALL=$LOCALE LANGUAGE="pt_BR:pt:en" &>> $LOG
echo -e "Timezone e Locale atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando a Data e Hora do NTP Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando ntpdate: d (debug), q (query), u (unprivileged), v (verbose)
	systemctl stop ntp &>> $LOG
	ntpdate -dquv $NTPSERVER &>> $LOG
	systemctl start ntp &>> $LOG
echo -e "Data e Hora do NTP Server atualizada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a Data e Hora do NTP Server e do Sistema Operacional, aguarde...\n"
sleep 5
#
echo -e "Consultando os servidores NTP Server configurados, aguarde...\n"
	# opção do comando ntpq: -p (print), -n (all address)
	ntpq -pn
echo -e "Consulta realizada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Consultando o sincronismo dos servidores NTP Server configurados, aguarde...\n"
	# opção do comando ntpq: -c (command) rl (display all system or peer variables)
	ntpq -c rl
echo -e "Consulta realizada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as configurações do NTP Server, aguarde...\n"
	# opção do comando ntpq: -c (command) sysinfo (display system operational summary)
	ntpq -c sysinfo
echo -e "Configurações verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as configurações das variáveis de tempo do Kernel, aguarde...\n"
	# opção do comando ntptime: -r (Display Unix and NTP times in raw format)
	ntptime -r
echo -e "Configurações verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a Data e Hora do Sistema Operacional Ubuntu Server, aguarde...\n"
	timedatectl status
echo -e "Data e Hora verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a Data e Hora de Software e Hardware do Ubuntu Server, aguarde..."
	# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60), %S (second 60)
	echo -e "Data/hora do OS: $(date +%d/%m/%Y-"("%H:%M:%S")")\n"
	echo -e "Data/hora do Hardware: $(hwclock)\n"
echo -e "Data e Hora verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do NTP Server, aguarde..."
	echo -e "NTP Server: $(systemctl status ntp | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de Conexão do NTP Server, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iUDP:123
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do NTP Server e Client feita com Sucesso!!!."
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
