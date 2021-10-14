#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Data de criação: 10/10/2021
# Data de atualização: 14/10/2021
# Versão: 0.02
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do NTP Server 4.2.
#
# O NTP é um protocolo para sincronização dos relógios dos computadores baseado no protocolo UDP sob 
# a porta 123. É utilizado para sincronização do relógio de um conjunto de computadores e dispositivos 
# em redes de dados com latência variável. 
#
# O projeto NTP.br tem por objetivo oferecer condições para que os servidores de Internet no Brasil 
# estejam sincronizados com a Horal Legal Brasileira. Para isso foi firmado um acordo entre o Observatório 
# Nacional (ON) e o NIC.br. 
#
# Os servidores Stratum 1 (primários) de nível mais baixo são sincronizados diretamente com os serviços 
# de horário nacional por meio de um modem de satélite, rádio ou telefone.
#
# Os servidores Stratum 2 (secundários) são sincronizados com os servidores Stratum 1 e assim por diante, 
# de forma que os clientes NTP e os servidores com um número relativamente pequeno de clientes não 
# sincronizem com os servidores primários públicos.
#
# Site Oficial do Projeto NTP: http://www.ntp.org/
# Site Oficial do Projeto NTP.br: https://ntp.br/
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
# Script de instalação do NTP Server e Client no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
#
echo
echo -e "Instalação do NTP Server e Client no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo NTP Server: UDP 123\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository universe &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o Repositório Multiversão do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository multiverse &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt, aguarde..."
	#opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o sistema, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
	apt -y dist-upgrade &>> $LOG
	apt -y full-upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
	apt -y autoclean &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando e Configurando o NTP Server e Client, aguarde...\n"
sleep 5
#
echo -e "Instalando o NTP Server e Client, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando apt: -y (yes)
	apt -y install ntp ntpdate &>> $LOG
echo -e "NTP Server e Client instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do NTP Server, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comando chown: -v (verbose), ntp (user), ntp (group)
	mv -v /etc/ntp.conf /etc/ntp.conf.old &>> $LOG
	cp -v conf/ntp.conf /etc/ &>> $LOG
	cp -v conf/ntp.drift /var/lib/ntp/ntp.drift &>> $LOG
	chown -v ntp.ntp /var/lib/ntp/ntp.drift &>> $LOG
echo -e "Arquivos do NTP Server atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração ntp.conf, pressione <Enter> para continuar"
	read
	vim /etc/ntp.conf
echo -e "NTP Server editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando a Data e Hora do NTP Server, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando ntpdate: d (debug), q (query), u (unprivileged), v (verbose)
	systemctl stop ntp &>> $LOG
	ntpdate -dquv $NTPSERVER &>> $LOG
	systemctl start ntp &>> $LOG
echo -e "Data e Hora do NTP Server atualizada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a Data e Hora do NTP Server e do Sistema Operacional, aguarde...\n"
	echo -e "Consultando os servidor NTP Server configurados...\n"
		# opção do comando ntpq: p (print), n (all address)
		ntpq -pn
		sleep 5
		echo
	echo -e "Verificando a Data e Hora do Sistema Operacional...\n"
		timedatectl set-timezone "$TIMEZONE"
		timedatectl
		sleep 5
		echo
		date
		sleep 5
		echo
	echo -e "Verificando a Data e Hora do Hardware...\n"
		hwclock
		sleep 5
		echo
echo -e "Data e Hora do NTP Server e do Sistema Operacional verificadas com sucesso!!!, continuando com o script..."
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
