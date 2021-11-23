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
# Versão: 0.03
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do LogAnalyzer v4.1.x
#
# O LogAnalyzer é uma interface da Web para o Syslog/Rsyslog e outros dados de eventos 
# da rede. Ele fornece fácil navegação análise de eventos de rede em tempo real e 
# serviços de relatórios. Os relatórios ajudam a manter um visão na atividade da rede. 
# Ele consolida o Syslog/Rsyslog e outros dados de eventos, fornecendo uma página web 
# de fácil leitura. Os gráficos ajudam a ver as coisas importantes de relance.
#
# Informações que serão solicitadas na configuração via Web do LogAnalyzer
# Step 0 - Errordetails: Click here to Install Adiscon LogAnalyzer!
# Step 1 - Prerequisites: Next;
# Step 2 - Verify File Permissions: 
#		   file './config.php' Writeable: Next;
# Step 3 - Basic Configuration: 
#		   Number of syslog messages per page: 50
#		   Message character limit for the main view: 80
#          Character display limit for all string type fields: 30
#          Show message details popup: Yes
#          Automatically resolved IP Addresses (inline): Yes
#		   Enable User Database: Yes
#		   Database Host: localhost
#		   Database Port: 3306
#		   Database Name: loganalyzer
#		   Table prefix: logcon_
#		   Database User: loganalyzer
#		   Database Password: loganalyzer
#		   Require user to be logged in: Yes
#		   Authentication method: Internal Authentication: Next;
# Step 4 - Create Tables: Next;
# Step 5 - Check SQL Results: Next;
# Step 6 - Creating the Main Useraccount
#		   Username: admin
#		   Password: pti@2018
#		   Repeat Password: pti@2018: Next;
# Step 7 - Create the first source for syslog messages
#		   Name of the Source: ptispo01ws01
#		   Source Type: MYSQL Native
#          Select View: Syslog Fields
#		   Table type: MonitorWare
#		   Database Host: localhost
#		   Database Name: syslog
#		   Database Tablename: SystemEvents
#		   Database User: syslog
#		   Database Password: syslog: Next;
#          Enable Row Counting: Yes
# Step 8 - Done: Finish.
#
# Site oficial do LogAnalyzer: https://loganalyzer.adiscon.com/
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
# Verificando se as dependências do LogAnalyzer estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do LogAnalyzer, aguarde... "
	for name in mysql-server mysql-common apache2 php
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
            exit 1; 
            }
		sleep 5
#
# Script de instalação do LogAnalyzer no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação e Configuração do LogAnalyzer no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Syslog/Rsyslog.: UDP 514"
echo -e "Após a instalação do LogAnalyzer acessar a URL: http://$(hostname -I | cut -d ' ' -f1)/log/\n"
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
echo -e "Iniciando a Instalação e Configurando o LogAnalyzer, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do LogAnalyzer, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	echo "rsyslog-mysql rsyslog-mysql/dbconfig-install boolean false" | debconf-set-selections &>> $LOG
    debconf-show rsyslog-mysql &>> $LOG
	apt -y install rsyslog-mysql &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando a Base de Dados do Rsyslog, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute), -D (database), < (Redirecionador de entrada STDOUT)
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_DATABASE_SYSLOG" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_USER_DATABASE_SYSLOG" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_DATABASE_SYSLOG" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_ALL_DATABASE_SYSLOG" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH_SYSLOG" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -D $DATABASE_NAME_SYSLOG < $INSTALL_DATABASE_SYSLOG &>> $LOG
echo -e "Base de Dados do Rsyslog criada com sucesso!!!, continuando o script...\n"
sleep 5
#
echo -e "Criando a Base de Dados do LogAnalyzer, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute)
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_DATABASE_LOGANALYZER" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_USER_DATABASE_LOGANALYZER" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_DATABASE_LOGANALYZER" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_ALL_DATABASE_LOGANALYZER" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH_LOGANALYZER" mysql &>> $LOG
echo -e "Base de Dados do LogAnalyzer criada com sucesso!!!, continuando o script...\n"
sleep 5
#
echo -e "Fazendo o download do LogAnalyzer do site oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# removendo versões anteriores baixadas do LogAnalyzer
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v loganalyzer.tar.gz &>> $LOG
	rm -v pt_BR.zip &>> $LOG
	wget $LOGANALYZER -O loganalyzer.tar.gz &>> $LOG
	wget $LOGPTBR -O pt_BR.zip &>> $LOG
echo -e "Download LogAnalyzer feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Descompactando o LogAnalyzer, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando tar: -z (gzip), -x (extract), -v (verbose), -f (file)
	tar -xzvf loganalyzer.tar.gz &>> $LOG
	unzip pt_BR.zip &>> $LOG
echo -e "Descompactação do LogAnalyzer feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Copiando os arquivos de configuração do LogAnalyzer, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando cp: -R (recurse), -v (verbose)
	# opção do comando chmod: -v (verbose), 775 (Dono=R-X,Grupo=R-X=Outros=R-X)
	# opção do comando chown: -R (recursive), -v (verbose), www-data (user), www-data (group)
	LOGANALYZERDIR=$(echo loganalyzer*/)
	SOURCE="src/*"
	mkdir -v /var/www/html/log &>> $LOG
	cp -Rv $LOGANALYZERDIR$SOURCE /var/www/html/log/ &>> $LOG
	mv -v pt_BR/ /var/www/html/log/lang/ &>> $LOG
	touch /var/www/html/log/config.php &>> $LOG
	chmod -v 666 /var/www/html/log/config.php &>> $LOG
	chown -Rv www-data.www-data /var/www/html/log/ &>> $LOG
echo -e "Arquivos copiados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do Rsyslog, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/rsyslog.conf /etc/rsyslog.conf >> $LOG
	cp -v conf/mysql.conf /etc/rsyslog.d/mysql.conf >> $LOG
echo -e "Arquivos atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração rsyslog.conf, Pressione <Enter> para continuar."
	read
	vim /etc/rsyslog.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração mysql.conf, Pressione <Enter> para continuar."
	read
	vim /etc/rsyslog.d/mysql.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o Serviço do Rsyslog, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart rsyslog &>> $LOG
echo -e "Serviço do Rsyslog reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Syslog/Rsyslog, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iUDP:"514"
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do LogAnalyzer feita com Sucesso!!!"
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