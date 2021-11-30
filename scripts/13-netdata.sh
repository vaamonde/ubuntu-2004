#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Data de criação: 02/11/2021
# Data de atualização: 23/11/2021
# Versão: 0.02
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Netdata v1.31.x
#
# O Netdata é uma ferramenta para visualizar e monitorar métricas em tempo real, 
# otimizado para acumular todos os tipos de dados, como uso da CPU, atividade do 
# disco, consultas SQL, visitas a um site, etc. A ferramenta é projetada para 
# visualizar o agora com o máximo de detalhes possível, permitindo que o usuário 
# tenha uma visão do que está acontecendo e do que acaba de acontecer em seu 
# sistema ou aplicativo, sendo uma opção ideal para resolver problemas de desempenho
# em tempo real.
#
# Exemplo: https://(ip do servidor):(porta de utilização) - https://172.16.1.20:19999
#
# Site oficial do Netdata: https://github.com/netdata/netdata
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
# Verificando se as dependências do Netdata estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Netdata, aguarde... "
	for name in mysql-server mysql-common apache2 php vsftpd bind9 isc-dhcp-server
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
			echo -en "Recomendo utilizar o script: 07-lamp.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 09-vsftpd.sh para resolver as dependências."
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
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação e Configuração do Netdata no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Netdata.: TCP 19999"
echo -e "Após a instalação do Netdata acessar a URL: http://$(hostname -I | cut -d ' ' -f1):19999/\n"
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
	# opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando todo o sistema, aguarde..."
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
echo -e "Iniciando a Instalação e Configurando o Netdata, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do Netdata, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes), \ (bar left) quebra de linha na opção do apt
	apt -y install zlib1g-dev gcc make git autoconf autogen automake pkg-config uuid-dev python3 \
	python3-mysqldb python3-pip python3-dev libmysqlclient-dev python-ipaddress libuv1-dev netcat \
	libwebsockets15 libwebsockets-dev libjson-c-dev libbpfcc-dev liblz4-dev libjudy-dev libelf-dev \
	libmnl-dev autoconf-archive curl cmake protobuf-compiler protobuf-c-compiler lm-sensors \
	python3-psycopg2 python3-pymysql &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Clonando o projeto do Netdata do Github, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	git clone $NETDATA &>> $LOG
echo -e "Clonagem do Netdata feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Netdata, esse processo demora um pouco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando echo |: faz a função de Enter no Script
	cd netdata/
	echo | ./netdata-installer.sh &>> $LOG
echo -e "Instalação do Netdata feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de monitoramento do MySQL mysql.conf, pressione <Enter> para editar"
echo -e "Remover os comentários das variáveis: user e pass"
echo -e "Adicionar o usuário: $USERMYSQL é a senha: $SENHAMYSQL nas configurações do tcp:"
	read
	vim /usr/lib/netdata/conf.d/python.d/mysql.conf +151
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de monitoramento do ISC DHCP Server isc_dhcpd.conf, pressione <Enter> para editar"
echo -e "Remover os comentários das variáveis: job_name, name, leases_path, pools e office"
echo -e "Adicionar o name: dhcppti, leases_path: /var/lib/dhcp/dhcpd.leases e office: 172.16.1.0/24"
	read
	vim /usr/lib/netdata/conf.d/python.d/isc_dhcpd.conf +53
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de estatísticas do Bind9 DNS Server bind_rndc.conf, pressione <Enter> para editar"
echo -e "Remover os comentários das variáveis: job_name, name, named_stats_path"
echo -e "Adicionar o name: dnspti, named_stats_path: /var/log/named/named.stats"
	read
	vim /usr/lib/netdata/conf.d/python.d/bind_rndc.conf +53
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do Netdata, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart netdata &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
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
