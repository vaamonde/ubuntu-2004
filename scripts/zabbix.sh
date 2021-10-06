#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 25/07/2020
# Data de atualização: 09/06/2021
# Versão: 0.04
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do Zabbix 5.2.x 
#
# O Zabbix é uma ferramenta de software de monitoramento de código aberto para diversos componentes de TI, 
# incluindo redes, servidores, máquinas virtuais e serviços em nuvem. O Zabbix fornece métricas de monitoramento, 
# utilização da largura de banda da rede, carga de uso CPU e consumo de espaço em disco, entre vários outros
# recursos de monitoramento e alertas.
#
# Informações que serão solicitadas na configuração via Web do Zabbix Server
# Welcome to Zabbix 5.2: 
#   Default language: English (en_US): Next step;
# Check of pre-requisites: Next step;
# Configure DB connection:
#	Database type: MySQL
#	Database host: localhost
#	Database port: 0 (use default port: 3306)
#	Database name: zabbix
#	Store credentials in: Plain text 
#	User: zabbix
#	Password: zabbix: Next step;
# Zabbix server details
#	Host: localhost
#	Port: 10051
#	Name: ptispo01ws01: Next step;
# GUI settings
#	Default time zone: System
#	Default theme: Dark: NExt step;
# Pre-installation summary: Next step.
# Install: Finish
# User Default: Admin (com A maiúsculo)
# Password Default: zabbix
#
# Site Oficial do Projeto: https://www.zabbix.com/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de instalação do LAMP Server no Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=6EFUu-I3u4s
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
# Declarando as variáveis para criação da Base de Dados do Zabbix Server
USER="root"
PASSWORD="pti@2018"
#
# opção do comando create: create (criação), database (base de dados), base (banco de dados), character set (conjunto de caracteres), 
# collate (comparar)
# opção do comando create: create (criação), user (usuário), identified by (identificado por - senha do usuário), password (senha)
# opção do comando grant: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/tabelas), to (para), user (usuário)
# identified by (identificado por - senha do usuário), password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou tabela), *.* (todos os bancos/tabelas)
# to (para), user@'%' (usuário @ localhost), identified by (identificado por - senha do usuário), password (senha)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
DATABASE="CREATE DATABASE zabbix character set utf8 collate utf8_bin;"
CREATETABLE="/usr/share/doc/zabbix-server-mysql/create.sql.gz"
USERDATABASE="CREATE USER 'zabbix' IDENTIFIED BY 'zabbix';"
GRANTDATABASE="GRANT USAGE ON *.* TO 'zabbix' IDENTIFIED BY 'zabbix';"
GRANTALL="GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix' IDENTIFIED BY 'zabbix';"
FLUSH="FLUSH PRIVILEGES;"
#
# Declarando as variáveis para o download do Zabbix Server (Link atualizado no dia 09/06/2021)
ZABBIX="https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1%2Bubuntu18.04_all.deb"
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
# Verificando se as dependências do Zabbix estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Zabbix, aguarde... "
	for name in mysql-server mysql-common apache2 php
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
# Script de instalação do Zabbix Server no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
#
clear
echo
echo -e "Instalação do Zabbix Server no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do Zabbix Server acesse a URL: http://`hostname -I | cut -d' ' -f1`/zabbix/"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
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
echo -e "Instalando o Zabbix Server, aguarde...\n"
#
echo -e "Fazendo o download e instalando o Repositório do Zabbix Server, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando wget: -O (output document file)
	# opção do comando rm: -v (verbose)
	# opção do comando dpkg: -i (install)
	rm -v zabbix.deb &>> $LOG
	wget $ZABBIX -O zabbix.deb &>> $LOG
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
echo -e "Instalando o Zabbix Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent \
	traceroute nmap snmp snmpd snmp-mibs-downloader &>> $LOG
echo -e "Zabbix Server instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Banco de Dados e Populando as Tabelas do Zabbix Server, aguarde esse processo demora um pouco..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando: | piper (conecta a saída padrão com a entrada padrão de outro comando)
	# opção do comando mysql: -u (user), -p (password), -e (execute)
	# opção do comando zcat: -v (verbose)
	mysql -u $USER -p$PASSWORD -e "$DATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$USERDATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTDATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTALL" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG
	zcat -v $CREATETABLE | mysql -uzabbix -pzabbix zabbix &>> $LOG
echo -e "Banco de Dados criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração da Base de Dados do Zabbix Server, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	read
	cp -v /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.bkp &>> $LOG
	cp -v conf/zabbix_server.conf /etc/zabbix/zabbix_server.conf &>> $LOG
	vim /etc/zabbix/zabbix_server.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do PHP do Zabbix Server, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	read
	cp -v /etc/zabbix/apache.conf /etc/zabbix/apache.conf.bkp &>> $LOG
	cp -v conf/apache.conf /etc/zabbix/apache.conf &>> $LOG
	vim /etc/zabbix/apache.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Zabbix Agent, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	read
	cp -v /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.bkp &>> $LOG
	cp -v conf/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf &>> $LOG
	vim /etc/zabbix/zabbix_agentd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando os serviços do Zabbix Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable zabbix-server zabbix-agent &>> $LOG
	systemctl restart zabbix-server zabbix-agent apache2 &>> $LOG
echo -e "Serviços reinicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexões do Zabbix Server, aguarde..."
	# opção do comando netstat: a (all), n (numeric)
	# opção do comando grep: -i (ignore case), \| (função OU)
	netstat -an | grep -i tcp | grep '10050\|10051'
echo -e "Portas verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Zabbix Server feita com Sucesso!!!."
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
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1
