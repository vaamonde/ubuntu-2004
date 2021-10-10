#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 11/11/2018
# Data de atualização: 27/04/2021
# Versão: 0.09
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do LogAnalyzer 4.1.x
#
# O LogAnalyzer é uma interface da Web para o Syslog/Rsyslog e outros dados de eventos da rede. Ele fornece fácil navegação
# análise de eventos de rede em tempo real e serviços de relatórios. Os relatórios ajudam a manter um visão na atividade da
# rede. Ele consolida o Syslog/Rsyslog e outros dados de eventos, fornecendo uma página web de fácil leitura. Os gráficos 
# ajudam a ver as coisas importantes de relance.
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
# Site oficial: https://loganalyzer.adiscon.com/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de configuração do OpenSSH no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=ecuol8Uf1EE&t
# vídeo de instalação do LAMP Server no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=6EFUu-I3u4s
#
# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário e "root", versão do ubuntu e kernel
# opções do comando id: -u (user)
# opções do comando: lsb_release: -r (release), -s (short), 
# opões do comando uname: -r (kernel release)
# opções do comando cut: -d (delimiter), -f (fields)
# opção do shell script: piper | = Conecta a saída padrão com a entrada padrão de outro comando
# opção do shell script: acento crase ` ` = Executa comandos numa subshell, retornando o resultado
# opção do shell script: aspas simples ' ' = Protege uma string completamente (nenhum caractere é especial)
# opção do shell script: aspas duplas " " = Protege uma string, mas reconhece $, \ e ` como especiais
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
KERNEL=$(uname -r | cut -d'.' -f1,2)
#
# Variável do caminho do Log dos Script utilizado nesse curso (VARIÁVEL MELHORADA)
# opções do comando cut: -d (delimiter), -f (fields)
# $0 (variável de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Declarando as variáveis para o download do LogAnalyzer (Link atualizado no dia 27/05/2021)
LOGANALYZER="http://download.adiscon.com/loganalyzer/loganalyzer-4.1.12.tar.gz"
PTBR="https://loganalyzer.adiscon.com/plugins/files/translations/loganalyzer_lang_pt_BR_3.2.3.zip"
#
# Declarando as variáveis de autenticação no MySQL
MYSQLUSER="root"
MYSQLPASS="pti@2018"
#
# Declarando as variáveis para criação da Base de Dados do Syslog/Rsyslog
RSYSLOGDB="syslog"
#
# opção do comando create: create (criação), database (base de dados), base (banco de dados)
# opção do comando create: create (criação), user (usuário), identified by (identificado por - senha do usuário), password (senha)
# opção do comando grant: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/tabelas), to (para), user (usuário)
# identified by (identificado por - senha do usuário), password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou tabela), *.* (todos os bancos/tabelas)
# to (para), user@'%' (usuário @ localhost), identified by (identificado por - senha do usuário), password (senha)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
RSYSLOGDATABASE="CREATE DATABASE syslog;"
RSYSLOGUSER="CREATE USER 'syslog' IDENTIFIED BY 'syslog';"
RSYSLOGGRANTDATABASE="GRANT USAGE ON *.* TO 'syslog' IDENTIFIED BY 'syslog';"
RSYSLOGGRANTALL="GRANT ALL PRIVILEGES ON syslog.* TO 'syslog';"
RSYSLOGFLUSH="FLUSH PRIVILEGES;"
RSYSLOGINSTALL="/usr/share/dbconfig-common/data/rsyslog-mysql/install/mysql"
#
# Declarando as variáveis para criação da Base de Dados do LogAnalyzer
# opção do comando create: create (criação), database (base de dados), base (banco de dados)
# opção do comando create: create (criação), user (usuário), identified by (identificado por - senha do usuário), password (senha)
# opção do comando grant: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/tabelas), to (para), user (usuário)
# identified by (identificado por - senha do usuário), password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou tabela), *.* (todos os bancos/tabelas)
# to (para), user@'%' (usuário @ localhost), identified by (identificado por - senha do usuário), password (senha)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
LOGDATABASE="CREATE DATABASE loganalyzer;"
LOGUSERDATABASE="CREATE USER 'loganalyzer' IDENTIFIED BY 'loganalyzer';"
LOGGRANTDATABASE="GRANT USAGE ON *.* TO 'loganalyzer' IDENTIFIED BY 'loganalyzer';"
LOGGRANTALL="GRANT ALL PRIVILEGES ON loganalyzer.* TO 'loganalyzer';"
LOGFLUSH="FLUSH PRIVILEGES;"
#
# Exportando o recurso de Noninteractive do Debconf para não solicitar telas de configuração
export DEBIAN_FRONTEND="noninteractive"
#
# Verificando se o usuário é Root, Distribuição é >=18.04 e o Kernel é >=4.15 <IF MELHORADO)
# [ ] = teste de expressão, && = operador lógico AND, == comparação de string, exit 1 = A maioria dos erros comuns na execução
clear
if [ "$USUARIO" == "0" ] && [ "$UBUNTU" == "18.04" ] && [ "$KERNEL" == "4.15" ]
	then
		echo -e "O usuário é Root, continuando com o script..."
		echo -e "Distribuição é >= 18.04.x, continuando com o script..."
		echo -e "Kernel é >= 4.15, continuando com o script..."
		sleep 5
	else
		echo -e "Usuário não é Root ($USUARIO) ou Distribuição não é >=18.04.x ($UBUNTU) ou Kernel não é >=4.15 ($KERNEL)"
		echo -e "Caso você não tenha executado o script com o comando: sudo -i"
		echo -e "Execute novamente o script para verificar o ambiente."
		exit 1
fi
#
# Verificando se as dependências do LogAnalyzer estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do LogAnalyzer, aguarde... "
	for name in mysql-server mysql-common apache2 php unzip
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            echo -en "Recomendo utilizar o script: lamp.sh para resolver as dependências."
            exit 1; 
            }
		sleep 5
#
# Script de instalação do LogAnalyzer no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do LogAnalyzer no GNU/Linux Ubuntu Server 18.04.x"
echo -e "Após a instalação do LogAnalyzer acessar a URL: http://`hostname -I | cut -d ' ' -f1`/log/\n"
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
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
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
	# opção do comando mysql: -u (user), -p (password), -e (execute), < (Redirecionador de entrada STDOUT)
	mysql -u $MYSQLUSER -p$MYSQLPASS -e "$RSYSLOGDATABASE" mysql &>> $LOG
	mysql -u $MYSQLUSER -p$MYSQLPASS -e "$RSYSLOGUSERDATABASE" mysql &>> $LOG
	mysql -u $MYSQLUSER -p$MYSQLPASS -e "$RSYSLOGGRANTDATABASE" mysql &>> $LOG
	mysql -u $MYSQLUSER -p$MYSQLPASS -e "$RSYSLOGGRANTALL" mysql &>> $LOG
	mysql -u $MYSQLUSER -p$MYSQLPASS -e "$RSYSLOGFLUSH" mysql &>> $LOG
	mysql -u$MYSQLUSER -D $RSYSLOGDB -p$MYSQLPASS < $RSYSLOGINSTALL &>> $LOG
echo -e "Base de Dados do Rsyslog criada com sucesso!!!, continuando o script...\n"
sleep 5
#
echo -e "Criando a Base de Dados do LogAnalyzer, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute)
	mysql -u $MYSQLUSER -p$MYSQLPASS -e "$LOGDATABASE" mysql &>> $LOG
	mysql -u $MYSQLUSER -p$MYSQLPASS -e "$LOGUSERDATABASE" mysql &>> $LOG
	mysql -u $MYSQLUSER -p$MYSQLPASS -e "$LOGGRANTDATABASE" mysql &>> $LOG
	mysql -u $MYSQLUSER -p$MYSQLPASS -e "$LOGGRANTALL" mysql &>> $LOG
	mysql -u $MYSQLUSER -p$MYSQLPASS -e "$LOGFLUSH" mysql &>> $LOG
echo -e "Base de Dados do LogAnalyzer criada com sucesso!!!, continuando o script...\n"
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
echo -e "Instalando o LogAnalyzer, aguarde...\n"
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
	wget $PTBR -O pt_BR.zip &>> $LOG
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
	LOGANALYZERDIR=`echo loganalyzer*/`
	SOURCE="src/*"
	mkdir -v /var/www/html/log &>> $LOG
	cp -Rv $LOGANALYZERDIR$SOURCE /var/www/html/log/ &>> $LOG
	mv -v pt_BR/ /var/www/html/log/lang &>> $LOG
	touch /var/www/html/log/config.php &>> $LOG
	chmod -v 666 /var/www/html/log/config.php &>> $LOG
	chown -Rv www-data.www-data /var/www/html/log/ &>> $LOG
echo -e "Arquivos copiados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do LogAnalyzer feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo rsyslog.conf do Rsyslog, Pressione <Enter> para continuar."
	read
	vim /etc/rsyslog.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo mysql.conf do MySQL do Rsyslog, Pressione <Enter> para continuar."
	read
	sleep 3
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
	# opção do comando netstat: -a (all), -n (numeric)
	netstat -an | grep 514
echo -e "Porta de conexão do Syslog/Rsyslog verificado com sucesso!!!, continuando o script...\n"
sleep 5
#
echo -e "Instalação do LogAnalyzer feita com Sucesso!!!"
	# script para calcular o tempo gasto (SCRIPT MELHORADO, CORRIGIDO FALHA DE HORA:MINUTO:SEGUNDOS)
	# opção do comando date: +%T (Time)
	HORAFINAL=`date +%T`
	# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second), 
	TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
	# $0 (variável de ambiente do nome do comando)
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1
