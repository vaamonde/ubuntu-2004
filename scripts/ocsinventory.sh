#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 04/05/2021
# Data de atualização: 10/05/2021
# Versão: 0.05
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do OCS Inventory Server 2.9, Agent 2.8.1
#
# O OCS Inventory (Open Computer and Software Inventory Next Generation) é um software livre que permite 
# aos usuários inventariar ativos de TI. O OCS-NG coleta informações sobre o hardware e o software das 
# máquinas conectadas, executando um programa cliente do OCS ("OCS Inventory Agent"). O OCS pode visualizar 
# o inventário por meio de uma interface web. Além disso, o OCS inclui a capacidade de implantar aplicações 
# em computadores de acordo com critérios de busca. O IpDiscover do lado do agente possibilita descobrir a 
# totalidade de computadores e dispositivos em rede.
#
# MENSAGENS QUE SERÃO SOLICITADAS NA INSTALAÇÃO DO OCS INVENTORY SERVER E REPORTS:
# 01. Do you wish to continue ([y]/n): y <-- digite y pressione <Enter>;
# 02. Which host is running database server [localhost]?: Deixe o padrão pressione <Enter>;
# 03. On which port is running database server [3306]?: Deixe o padrão pressione <Enter>;
# 04. Where is Apache daemon binary [/usr/sbin/apache2ctl]?: Deixe o padrão pressione <Enter>;
# 05. Where is Apache main configuration file [/etc/apache2/apache2.conf]?: Deixe o padrão pressione <Enter>;
# 06. Which user account is running Apache Web Server [www-data]?: Deixe o padrão pressione <Enter>;
# 07. Which user group is running Apache web server [www-data]?: Deixe o padrão pressione <Enter>;
# 08. Where is Apache Include configuration directory [/etc/apache2/conf-available]?: Deixe o padrão pressione <Enter>;
# 09. Where is PERL Interpreter binary [/usr/bin/perl]?: Deixe o padrão pressione <Enter>;
# 10. Do you wish to setup Communication Server on this computer ([y]/n)? y <-- digite y pressione <Enter>;
# 11. Where to put Communication server log directory [/var/log/ocsinventory-server]? Deixe o padrão pressione <Enter>;
# 12. Where to put Communication server plugins configuration files [/etc/ocsinventory-server/plugins]? Deixe o padrão pressione <Enter>;
# 13. Where to put Communication server plugins Perl modules files [/etc/ocsinventory-server/perl]? Deixe o padrão pressione <Enter>;
# 14. Do you wish to setup Rest API server on this computer ([y]/n)? y <-- digite y pressione <Enter>;
# 15. Where do you want the API code to be store [/usr/local/share/perl/5.26.1]? Deixe o padrão pressione <Enter>;
# 16. Do you allow Setup renaming Communication Server Apache configuration file to 'z-ocsinventory-server.conf' ([y]/n)?: y <-- digite y pressione <Enter>;
# 17. Do you wish to setup Administration Server (Web Administration Console) on this computer ([y]/n)?: y <-- digite y pressione <Enter>;
# 18. Do you wish to continue ([y]/n)?: y <-- digite y pressione <Enter>;
# 15. Where to copy Administration Server static files for PHP Web Console [/usr/share/ocsinventory-reports]?: Deixe o padrão pressione <Enter>;
# 16. Where to create writable/cache directories for deployment packages administration console logs, IPDiscover and SNMP [/var/lib/ocsinventory-reports]?: Deixe o padrão pressione <Enter>;
#
# INFORMAÇÕES QUE SERÃO SOLICITADAS VIA WEB (NAVEGADOR) DO OCS INVENTORY SERVER E REPORTS:
# 01. MySQL login: root (usuário padrão do MySQL)
# 02. MySQL password: pti@2018 (senha criada no arquivo lamp.sh)
# 03. Name of Database: ocsweb (base de dados padrão do OCS Inventory, não mudar)
# 04. MySQL HostName: localhost (servidor local do MySQL)
# 05. MySQL Port: 3306 (porta padrão do MySQL)
# 06. Enable SSL: no
# 07. SSL mode: default
# 08. SSL key path: default
# 09. SSL certificate path: default
# 10. CA certificate path: default
# 11. Perform the update
#
# USUÁRIO E SENHA PADRÃO DO OCS INVENTORY SERVER E REPORTS: 
# LANGUAGE: English
# USER: admin
# PASSWORD: admin
#
# MENSAGENS QUE SERÃO SOLICITADAS NA INSTALAÇÃO DO OCS INVENTORY AGENT:
# 01: Please enter 'y' or 'n'?> [y] <-- pressione <Enter>
# 02: Where do you want to write the configuration file? <-- digite 2 pressione <Enter>
# 03: Do you want to create the directory /etc/ocsinventory-agent? <-- pressione <Enter>
# 04: Should the ond linux_agent settings be imported? <-- pressione <Enter>
# 05: What is the address of your ocs server? digite: http://localhost/ocsinventory, pressione <Enter>
# 06: Do you need credential for the server? (You probably don't) <-- pressione <Enter>
# 07: Do you want to apply an administrative tag on this machine? <-- pressione <Enter>
# 08: tag?> digite: server, pressione <Enter>
# 09: Do yo want to install the cron task in /etc/cron.d? <-- pressione <Enter>
# 10: Where do you want the agent to store its files? <-- pressione <Enter>
# 11: Do you want to create the? <-- pressione <Enter>
# 12: Should I remove the old linux_agent? <-- pressione <Enter>
# 13: Do you want to activate debug configuration option? <-- pressione <Enter>
# 14: Do you want to use OCS Inventory NG Unix Unified agent log file? <-- pressione <Enter>
# 15: Specify log file path you want to use?> digite: /var/log/ocsinventory-agent/ocsagent.log, pressione <Enter>
# 16: Do you want disable SSL CA verification configuration option (not recommended)? digite: y, pressione <Enter>
# 17: Do you want to set CA certificate chain file path? digite: n, pressione <Enter>
# 18: Do you want to use OCS-Inventory software deployment feature? <-- pressione <Enter>
# 19: Do you want to use OCS-Inventory SNMP scans features? <-- pressione <Enter>
# 20: Do you want to send an inventory of this machine? n, <-- pressione <Enter>
#
# Site Oficial do Projeto: https://ocsinventory-ng.org/
# Projeto no Github: https://github.com/OCSInventory-NG
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de configuração do OpenSSH no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=ecuol8Uf1EE&t
# Vídeo de instalação do LAMP Server: https://www.youtube.com/watch?v=6EFUu-I3u4s&t
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
# Declarando as variáveis de download do OCS Inventory (Links atualizados no dia 07/05/2021)
#
# Variáveis de configuração do usuário root e senha do MySQL para acesso via console e do PhpMyAdmin
# Observação: essa senha será utilizada no usuário: ocs do Banco de Dados do OCS Inventory
USER="root"
PASSWORD="pti@2018"
#
# Variável de download do OCS Inventory Server e Reports
# Site: https://www.ocsinventory-ng.org/en/
# Github: https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases
OCSSERVER="https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/2.9/OCSNG_UNIX_SERVER-2.9.tar.gz"
#
# Variável de download do OCS Inventory Agent
# Site: https://www.ocsinventory-ng.org/en/
# Github: https://github.com/OCSInventory-NG/UnixAgent/releases
OCSAGENT="https://github.com/OCSInventory-NG/UnixAgent/releases/download/v2.8.1/Ocsinventory-Unix-Agent-2.8.1.tar.gz"
#
# Variável de verificação do Chip Gráfico da NVIDIA
# opção do comando lshw: -class display (lista as informações da placa de vídeo)
# opção do comando grep: NVIDIA (filtra as linhas que contém a palavra NVIDIA) 
# opção do comando cut: -d':' (delimitador) -f2 (mostrar segunda coluna)
NVIDIA=`lshw -class display | grep NVIDIA | cut -d':' -f2 | cut -d' ' -f2`
#
# Variáveis de alteração de senha do OCS Inventory Reports no Banco de Dados do MySQL
# 'ocs'@'localhost' usuário de administração do banco de dados do OCS Inventory
# PASSWORD('pti@2018') nova senha do usuário ocs
# CUIDADO!!!!: essa senha será utilizada nos arquivos de configuração do OCS Inventory: dbconfig.inc.php, 
# z-ocsinventory-server.conf e zz-ocsinventory-restapi.conf
SETOCSPWD="SET PASSWORD FOR 'ocs'@'localhost' = PASSWORD('$PASSWORD');"
FLUSH="FLUSH PRIVILEGES;"
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
# Verificando se as dependências do OCS Inventory estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do OCS Inventory, aguarde... "
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
# Script de instalação do OCS Inventory no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo -e "Instalação do OCS Inventory no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do OCS Inventory acesse a URL: http://`hostname -I | cut -d' ' -f1`/ocsreports\n"
echo -e "Usuário padrão após a instalação do OCS Inventory Reports: admin | Senha padrão: admin\n"
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
echo -e "Instalando as Dependências do OCS Inventory, PHP e Perl, aguarde...\n"
#
echo -e "Instalação das Dependências do OCS Inventory Server e Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install gcc make autoconf autogen automake pkg-config uuid-dev net-tools pciutils \
	smartmontools read-edid nmap ipmitool dmidecode samba samba-common samba-testsuite snmp \
	snmp-mibs-downloader snmpd unzip hwdata perl-modules python-dev python3-dev python-pip \
	apache2-dev mysql-client python-pymssql python-mysqldb &>> $LOG
echo -e "Instalação das Dependências feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das Dependências do PHP, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install php-snmp php-mysql php-dev php-soap php-apcu php-xmlrpc php-zip php-gd \
	php-mysql php-pclzip php-json php-mbstring php-curl php-imap php-ldap zlib1g-dev php-cas \
	php-curl &>> $LOG
echo -e "Instalação das Dependências feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das Dependências do PERL, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install libc6-dev libcompress-raw-zlib-perl libwww-perl libdigest-md5-file-perl \
	libnet-ssleay-perl libcrypt-ssleay-perl libnet-snmp-perl libproc-pid-file-perl libproc-daemon-perl \
	libarchive-zip-perl libnet-cups-perl libmysqlclient-dev libapache2-mod-perl2 \
	libapache2-mod-php libnet-netmask-perl libio-compress-perl libxml-simple-perl libdbi-perl \
	libdbd-mysql-perl libapache-dbi-perl libsoap-lite-perl libnet-ip-perl libmodule-build-perl \
	libmodule-install-perl libfile-which-perl libfile-copy-recursive-perl libuniversal-require-perl \
	libtest-http-server-simple-perl libhttp-server-simple-authen-perl libhttp-proxy-perl libio-capture-perl \
	libipc-run-perl libnet-telnet-cisco-perl libtest-compile-perl libtest-deep-perl libtest-exception-perl \
	libtest-mockmodule-perl libtest-mockobject-perl libtest-nowarnings-perl libxml-treepp-perl \
	libparallel-forkmanager-perl libparse-edid-perl libdigest-sha-perl libtext-template-perl \
	libsocket-getaddrinfo-perl libcrypt-des-perl libnet-nbname-perl libyaml-perl libyaml-shell-perl \
	libyaml-libyaml-perl libdata-structure-util-perl liblwp-useragent-determined-perl libio-socket-ssl-perl \
	libdatetime-perl libthread-queue-any-perl libnet-write-perl libarchive-extract-perl libjson-pp-perl \
	liburi-escape-xs-perl liblwp-protocol-https-perl libnmap-parser-perl \
	libmojolicious-perl libswitch-perl libplack-perl liblwp-useragent-determined-perl \
	libdigest-hmac-perl libossp-uuid-perl libperl-dev libsnmp-perl libsnmp-dev libsoap-lite-perl &>> $LOG
echo -e "Instalação das Dependências feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das dependências do Perl XML::Entities via CPAN, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando perl: -e (single line command)
	# Mensagem: Would you like to configure as much as possible automatically? [Yes] <-- Pressione <Enter>
	echo -e "Yes" | perl -MCPAN -e 'install XML::Entities' &>> $LOG
echo -e "Instalação concluída com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das dependências do Perl SOAP::Lite via CPAN, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando perl: -e (single line command)
	# Mensagem: WARNING: Please tell me where I can find your apache src: <-- digite q Pressione <Enter>
	# Esse procedimento demora um pouco, não se preocupe com a mensagem de erro no final, essa mensagem 
	# está associada ao Source do Apache2 que não está disponível no servidor
	echo -e "q" | perl -MCPAN -e 'install SOAP::Lite' &>> $LOG
echo -e "Instalação concluída com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das dependências do Perl Linux::Ethtool via CPAN, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando perl: -e (single line command)
	perl -MCPAN -e 'install Linux::Ethtool' &>> $LOG
echo -e "Instalação concluída com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das dependências do Perl Apache2::SOAP via CPAN, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando perl: -e (single line command)
	# opção do comando if: [ ] = testa uma expressão, -d = testa se é diretório
	# opção do comando mkdir: -v (verbose)
	if [ -d /usr/include/apache2 ]; then
		echo -e "Diretório /usr/include/apache2 já existe, continuando com o script..."
	else
		echo -e "Diretório /usr/include/apache2 não existe, criando o diretório, aguarde..."
			mkdir -v /usr/include/apache2 &>> $LOG
		echo -e "Diretório criado com sucesso!!!, continuando o script..."
	fi
	perl -MCPAN -e 'install Apache2::SOAP' &>> $LOG
echo -e "Instalação concluída com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das dependências do Perl nvidia::ml via CPAN, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando perl: -e (single line command)
	# opção do comando if: [ ] = testa uma expressão, == comparação de string 
	if [ "$NVIDIA" == "NVIDIA" ]; then
		echo -e "Você tem o Chip Gráfico da NVIDIA, instalando o Módulo Perl, aguarde..."
			perl -MCPAN -e 'install nvidia::ml' &>> $LOG
		echo -e "Instalação concluída com sucesso!!!, continuando com o script...\n"
		sleep 5
	else
		echo -e "Você não tem o Chip Gráfico da NVIDIA, continuando com o script...\n"
		sleep 5
	fi
#
echo -e "Instalação das dependências do Perl Net::Ping via CPAN, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando perl: -e (single line command)
	perl -MCPAN -e 'install Net::Ping' &>> $LOG
echo -e "Instalação concluída com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das dependências do Perl Net::Ping::External via CPAN, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando perl: -e (single line command)
	perl -MCPAN -e 'install Net::Ping::External' &>> $LOG
echo -e "Instalação concluída com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das dependências do Perl LWP::UserAgent::Cached via CPAN, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando perl: -e (single line command)
	# Mensagem: Append this modules to installation queue? [y] <-- Pressione <Enter>
	perl -MCPAN -e 'install LWP::UserAgent::Cached' &>> $LOG
echo -e "Instalação concluída com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das dependências do Perl Mac::SysProfile via CPAN, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando perl: -e (single line command)
	perl -MCPAN -e 'install Mac::SysProfile' &>> $LOG
echo -e "Instalação concluída com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das dependências do Perl Mojolicious::Lite via CPAN, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando perl: -e (single line command)
	perl -MCPAN -e 'install Mojolicious::Lite' &>> $LOG
echo -e "Instalação concluída com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das dependências do Perl NetSNMP::OID via CPAN, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando perl: -e (single line command)
	perl -MCPAN -e 'install NetSNMP::OID' &>> $LOG
echo -e "Instalação concluída com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das dependências do Perl Sys::Syslog via CPAN, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando perl: -e (single line command)
	perl -MCPAN -e 'install Sys::Syslog' &>> $LOG
echo -e "Instalação concluída com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Download do OCS Inventory Server e Agent, aguarde...\n"
#
echo -e "Fazendo o download do OCS Inventory Server e Report, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	# opção do comando: tar z (gzip), x (extract), v (verbose) e f (file)
	rm -v ocsserver.tar.gz &>> $LOG
	wget $OCSSERVER -O ocsserver.tar.gz &>> $LOG
	tar -zxvf ocsserver.tar.gz &>> $LOG
echo -e "Download do OCS Inventory Server e Report feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do OCS Inventory Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	# opção do comando: tar z (gzip), x (extract), v (verbose) e f (file)
	rm -v ocsagent.tar.gz &>> $LOG
	wget $OCSAGENT -O ocsagent.tar.gz &>> $LOG
	tar -zxvf ocsagent.tar.gz &>> $LOG
echo -e "Download do OCS Inventory Agent feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o OCS Inventory Server e Reports, pressione <Enter> para instalar."
echo -e "CUIDADO!!! com as opções que serão solicitadas no decorrer da instalação do OCS Inventory Server."
echo -e "Veja a documentação das opções de instalação a partir da linha: 21 do arquivo $0"
	read
	sleep 2
	cd OCSNG_UNIX_SERVER-*
	./setup.sh
echo
echo -e "Instalação do OCS Inventory Server e Reports feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configurando as opções do OCS Inventory Server e Reports no Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando chmod: -R (recursive), -v (verbose), 775 (user=rwx, group=rwx, other=r-x)
	# opção do comando chown: -R (recursive), -v (verbose), www-data (user), www-data (group)
	# opção do comando cp: -v (verbose)
	# opção do comando cd: .. (retorne to root folder)
	a2dissite 000-default &>> $LOG
	a2enconf ocsinventory-reports &>> $LOG
	a2enconf z-ocsinventory-server &>> $LOG
	chmod -Rv 775 /var/lib/ocsinventory-reports/ &>> $LOG
	chown -Rv www-data.www-data /var/lib/ocsinventory-reports/ &>> $LOG
	cp -v *.log /var/log/ &>> $LOG
	systemctl restart apache2 &>> $LOG
	cd ..
echo -e "Configurações do OCS Inventory Server e Reports feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "ANTES DE CONTINUAR COM O SCRIPT ACESSE A URL: http://`hostname -I | cut -d' ' -f1`/ocsreports"
echo -e "PARA FINALIZAR A CONFIGURAÇÃO VIA WEB DO OCS INVENTORY SERVER E REPORTS, APÓS A CONFIGURAÇÃO"
echo -e "PRESSIONE <ENTER> PARA CONTINUAR COM O SCRIPT. MAIS INFORMAÇÕES NA LINHA 56 DO SCRIPT $0"
read
sleep 5
#
echo -e "Alterando a senha do usuário OCS no MySQL, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute), mysql (database)
	mysql -u $USER -p$PASSWORD -e "$SETOCSPWD" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG
echo -e "Senha alterada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo o arquivo install.php do OCS Inventory Reports, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	mv -v /usr/share/ocsinventory-reports/ocsreports/install.php /usr/share/ocsinventory-reports/ocsreports/install.php.bkp &>> $LOG
echo -e "Arquivo removido com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do OCS Inventory Server e Reports, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	mv -v /etc/apache2/conf-available/z-ocsinventory-server.conf /etc/apache2/conf-available/z-ocsinventory-server.conf.bkp &>> $LOG
	cp -v conf/z-ocsinventory-server.conf /etc/apache2/conf-available/ &>> $LOG
	mv -v /etc/apache2/conf-available/zz-ocsinventory-restapi.conf /etc/apache2/conf-available/zz-ocsinventory-restapi.conf.bkp &>> $LOG
	cp -v conf/zz-ocsinventory-restapi.conf /etc/apache2/conf-available/ &>> $LOG
	mv -v /etc/apache2/conf-available/ocsinventory-reports.conf /etc/apache2/conf-available/ocsinventory-reports.conf.bkp &>> $LOG
	cp -v conf/ocsinventory-reports.conf /etc/apache2/conf-available/ &>> $LOG
	mv -v /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php.bkp &>> $LOG
	cp -v conf/dbconfig.inc.php /usr/share/ocsinventory-reports/ocsreports/ &>> $LOG
	mv -v /etc/logrotate.d/ocsinventory-server /etc/logrotate.d/ocsinventory-server.bkp &>> $LOG
	cp -v conf/ocsinventory-server /etc/logrotate.d/ocsinventory-server &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando os arquivos de configuração do OCS Inventory Server e Reports, aguarde...\n"
sleep 5
#
echo -e "Editando o arquivo: z-ocsinventory-server.conf, pressione <Enter> para continuar."
	read
	vim /etc/apache2/conf-available/z-ocsinventory-server.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo: zz-ocsinventory-restapi.conf, pressione <Enter> para continuar."
	read
	vim /etc/apache2/conf-available/zz-ocsinventory-restapi.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo: ocsinventory-reports.conf, pressione <Enter> para continuar."
	read
	vim /etc/apache2/conf-available/ocsinventory-reports.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo: dbconfig.inc.php, pressione <Enter> para continuar."
	read
	vim /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo: ocsinventory-server, pressione <Enter> para continuar."
	read
	vim /etc/logrotate.d/ocsinventory-server
	systemctl restart apache2 &>> $LOG
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "ANTES DE CONTINUAR COM O SCRIPT ACESSE A URL: http://`hostname -I | cut -d' ' -f1`/ocsreports"
echo -e "PARA CONFIRMAR AS ATUALIZAÇÕES VIA WEB DO OCS INVENTORY SERVER E REPORTS, APÓS A CONFIRMAÇÃO"
echo -e "PRESSIONE <ENTER> PARA CONTINUAR COM O SCRIPT. MAIS INFORMAÇÕES NA LINHA 56 DO SCRIPT $0"
read
sleep 5
#
echo -e "Instalando o OCS Inventory Agent, pressione <Enter> para instalar."
echo -e "CUIDADO!!! com as opções que serão solicitadas no decorrer da instalação do OCS Inventory Agent."
echo -e "Veja a documentação das opções de instalação a partir da linha: 61 do arquivo $0"
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando cd: .. (retorne to root folder)
	read
	sleep 2
	mkdir -v /var/log/ocsinventory-agent/ &>> $LOG
	touch /var/log/ocsinventory-agent/ocsagent.log &>> $LOG
	cd Ocsinventory-Unix-Agent-*
	perl Makefile.PL &>> $LOG
	make &>> $LOG
	make install
	cd ..
echo
echo -e "Instalação do OCS Inventory Agent feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do OCS Inventory Agent, aguarde...\n"
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	mv -v /etc/ocsinventory-agent/ocsinventory-agent.cfg /etc/ocsinventory-agent/ocsinventory-agent.cfg.bkp &>> $LOG
	cp -v conf/ocsinventory-agent.cfg /etc/ocsinventory-agent/ &>> $LOG
	mv -v /etc/ocsinventory-agent/modules.conf /etc/ocsinventory-agent/modules.conf.bkp &>> $LOG
	cp -v conf/modules.conf /etc/ocsinventory-agent/ &>> $LOG
	cp -v conf/ocsinventory-agent /etc/cron.d/ocsinventory-agent &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando os arquivos de configuração do OCS Inventory Agent, aguarde...\n"
sleep 5
#
echo -e "Editando o arquivo: ocsinventory-agent.cfg, pressione <Enter> para continuar."
	read
	vim /etc/ocsinventory-agent/ocsinventory-agent.cfg
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo: modules.conf, pressione <Enter> para continuar."
	read
	vim /etc/ocsinventory-agent/modules.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo: ocsinventory-agent, pressione <Enter> para continuar."
	read
	vim /etc/cron.d/ocsinventory-agent
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Forçando o inventário do OCS Inventory Agent com as novas configurações, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	ocsinventory-agent --debug --info &>> $LOG
echo -e "Inventário do OCS Inventory Agent feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do OCS Inventory Server, Reports e Agent feita com Sucesso!!!."
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