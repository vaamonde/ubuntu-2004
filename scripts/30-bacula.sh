#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 21/12/2021
# Data de atualização: 12/01/2022
# Versão: 0.03
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do Bacula Server 11.x e do Baculum 11.x
#
# O Bacula é um conjunto de software de código aberto que permitem o gerenciamento 
# de backups, restaurações e verificação de dados através de uma rede de computadores 
# de diversos tipos. É relativamente fácil de usar e muito eficiente, enquanto 
# oferece muitas funcionalidades avançadas de gerenciamento de armazenamento, as quais 
# facilitam a encontrar e recuperar arquivos perdidos ou corrompidos. Com ele é possível 
# fazer backup remotamente de Linux, Solaris, FreeBSD, NetBSD, Windows, Mac OS X, etc... 
#
# O Baculum fornece duas aplicações web: o Baculum Web como interface web para gerenciar 
# o Bacula e a API do Baculum, que é a interface de programação do Bacula. Ambas as 
# ferramentas conectadas criam um ambiente web para facilitar o trabalho com os programas 
# da Comunidade Bacula. 
#
# Site Oficial do Projeto Bacula: https://www.bacula.org/
# Site Oficial do Projeto Baculum: https://baculum.app/
#
# Informações que serão solicitadas na configuração via Web do Baculum WEB/API
# Endereço padrão do Baculum WEB: http://localhost:9095
# Endereço padrão do Baculum API: http://localhost:9096
#
# PRIMEIRA ETAPA: CONFIGURAR O BACULUM API: http://localhost:9096
# Usuário padrão: admin - Senha padrão: admin
# 01. Step 1 - select language
#	Language: English 
#	<Next>
# 02. Step 2 - share the Bacula Catalog Database
#	Do you want to setup and to share the Bacula Catalog Database access for this API instance?: 
#	Select: Yes
#	Database type: MySQL
#	Database name: bacula
#	Login: root
#	Password: pti@2018
#	IP address (or hostname): localhost
#	Port: 3306
#	Connection test: <Test>
#	<Next>
# 03. Step 3 - share the Bacula Bconsole commands interface
#	Do you want to setup and share the Bacula Bconsole interface to execute commands in this API instance?
#	Select: Yes
#	Bconsole binary file path: /usr/sbin/bconsole
#	Bconsole admin config file path: /opt/bacula/etc/bconsole.conf
#	Use sudo: Yes
#	Bconsole connection test: <Test>
#	<Next>
# 04. Step 4 - share the Bacula configuration interface
#	Do you want to setup and share the Bacula configuration interface to configure Bacula components via this API instance?
#	Select: Yes
#	General configuration
#		Baculum working directory for Bacula config: /etc/baculum/Config-api-apache
#		Use sudo: Yes
#	Director
#		bdirjson binary file path: /usr/sbin/bdirjson
#		Main Director config file path (usually bacula-dir.conf): /opt/bacula/etc/bacula-dir.conf
#	Storage Daemon
#		bsdjson binary file path: /usr/sbin/bsdjson
#		Main Storage Daemon config file path (usually bacula-sd.conf): /opt/bacula/etc/bacula-sd.conf
#	File Daemon/Client
#		bfdjson binary file path: /usr/sbin/bfdjson
#		Main File Daemon config file path (usually bacula-fd.conf): /opt/bacula/etc/bacula-fd.conf
#	Bconsole
#		bbconsjson binary file path: /usr/sbin/bbconsjson
#		Admin Bconsole config file path (usually bconsole.conf): /opt/bacula/etc/bconsole.conf
#	<Test Configuration>
#	<Next>
# 05. Step 5 - authentication to AP
#	Use HTTP Basic authentication: Yes
#	Administration login: vaamonde
#	Administration password: vaamonde
#	Retype administration password: vaamonde
#	<Next>
# 06. @@Step 7 - Finish@@
#	<save>
#
# SEGUNDA ETAPA: CONFIGURAR O BACULUM WEB: http://localhost:9095
# 01. Step 1 - select language
#	Language: English 
#	<Next>
# 02. Step 2 - add API instances
#	Baculum web interface requires to add at least one Baculum API instance with shared Catalog access. Please add API instance.
#		Add API host
#			Protocol: HTTP
#			IP Address/Hostname: localhost
#			Port: 9096
#			Use HTTP Basic authentication: Yes
#			API Login: vaamonde
#			API Password: vaamonde
#			API connection test: <Test>
#		<Next>
# 03. Step 3 - authentication params to Baculum Web pane
#	Administration login: robson
#	Administration password: robson
#	Retype administration password: robson
#	<Next>
# 04. Step 4 - Finish
#	<Save>
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
# Verificando todas as dependências do Bacula e Baculum Server
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Bacula Server e do Baculum WEB/API, aguarde... "
	for name in $BACULUMDEP
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
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
# Script de instalação do Bacula Server e do Baculum WEB/API no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Bacula Server e do Baculum WEB/API GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Portas padrão utilizadas pelo Bacula Server.: TCP 9101, 9102 e 9103"
echo -e "Portas padrão utilizadas pelo Baculum WEB/API.: TCP 9095 e 9096"
echo -e "Após a instalação do Baculum WEB acessar a URL: http://$(hostname -d | cut -d' ' -f1):9095"
echo -e "Após a instalação do Baculum API acessar a URL: http://$(hostname -d | cut -d' ' -f1):9096\n"
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
echo -e "Iniciando a Instalação e Configuração do Bacula Server e do Baculum WEB/API, aguarde...\n"
sleep 5
#
echo -e "Adicionando o repositório do Bacula Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando wget: -q -O- (file)
	# opção do redirecionador |: Conecta a saída padrão com a entrada padrão de outro comando
	# opção do comando apt-key: add (file name), - (arquivo recebido do redirecionar | piper)
	cp -v conf/bacula/bacula.list /etc/apt/sources.list.d/ &>> $LOG
	wget -q $BACULAKEY -O- | apt-key add - &>> $LOG
echo -e "Repositório do Bacula adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o repositório do Baculum WEB/API, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando wget: -q -O- (file)
	# opção do redirecionador |: Conecta a saída padrão com a entrada padrão de outro comando
	# opção do comando apt-key: add (file name), - (arquivo recebido dO redirecionar | piper)
	cp -v conf/bacula/baculum.list /etc/apt/sources.list.d/ &>> $LOG
	wget -q $BACULUMKEY -O- | apt-key add - &>> $LOG
echo -e "Repositório do Baculum adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt com os novos repositórios, aguarde..."
	#opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Bacula Server e Console com suporte ao MySQL, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando apt: -y (yes)
	apt -y install $BACULAINSTALL &>> $LOG
echo -e "Bacula Server e Console instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Baculum WEB com suporte ao Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando apt: -y (yes)
	apt -y install $BACULUMWEBINSTALL &>> $LOG
echo -e "Baculum WEB instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Baculum API com suporte ao Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando apt: -y (yes)
	apt -y install $BACULUMAPIINSTALL &>> $LOG
echo -e "Baculum API instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando os sites do Baculum WEB/API no Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	a2enmod rewrite &>> $LOG
	a2ensite baculum-web.conf &>> $LOG
	a2ensite baculum-api.conf &>> $LOG
	systemctl reload apache2 &>> $LOG
echo -e "Baculum WEB e API habilitados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando os atalhos em: /usr/sbin dos binários do Bacula Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando ln: -s (symbolic), -v (verbose)
	for i in $(ls /opt/bacula/bin); do
		ln -sv /opt/bacula/bin/$i /usr/sbin/$i &>> $LOG;
	done
echo -e "Atalhos criados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o arquivo baculum.api do Sudoers, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/bacula/baculum-api /etc/sudoers.d/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração baculum.api, pressione: <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/sudoers.d/baculum-api
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração hosts.allow, pressione: <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/hosts.allow
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando os Serviços do Bacula Server (FD, SD e DIR), aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable bacula-fd.service &>> $LOG
	systemctl enable bacula-sd.service &>> $LOG
	systemctl enable bacula-dir.service &>> $LOG
echo -e "Serviços habilitados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando os Serviços do Bacula Server (FD, SD e DIR), aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl start bacula-fd.service &>> $LOG
	systemctl start bacula-sd.service &>> $LOG
	systemctl start bacula-dir.service &>> $LOG
echo -e "Serviços iniciados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando os serviços do Bacula Server, aguarde..."
	echo -e "Bacula-FD.: $(systemctl status bacula-fd.service | grep Active)"
	echo -e "Bacula-SD.: $(systemctl status bacula-sd.service | grep Active)"
	echo -e "Bacula-DIR: $(systemctl status bacula-dir.service | grep Active)"
echo -e "Serviços verificados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexão do Bacula Server e do Baculum WEB/API, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:'9101,9102,9103,9095,9096' -sTCP:LISTEN
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Testando o acesso ao console do Bacula Server, pressione <Enter> para continuar."
echo -e "Para sair do BConsole do Bacula Server digite: quit <Enter>."
	read
	bconsole
echo -e "Bacula Server BConsole testado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Bacula Server e Baculum WEB/API feita com Sucesso!!!."
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
