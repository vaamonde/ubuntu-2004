#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 25/11/2021
# Data de atualização: 12/01/2022
# Versão: 0.02
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do OCS Inventory Server v2.9.x e Agent 2.9.x
#
# O OCS Inventory (Open Computer and Software Inventory Next Generation) é um software livre 
# que permite aos usuários inventariar ativos de TI. O OCS-NG coleta informações sobre o 
# hardware e o software das máquinas conectadas, executando um programa cliente do OCS ("OCS 
# Inventory Agent"). O OCS pode visualizar o inventário por meio de uma interface web. Além 
# disso, o OCS inclui a capacidade de implantar aplicações em computadores de acordo com 
# critérios de busca. O IpDiscover do lado do agente possibilita descobrir a totalidade de 
# computadores e dispositivos em rede.
#
# Site Oficial do Projeto OCS Inventory-NG: https://ocsinventory-ng.org/
# Projeto no Github: https://github.com/OCSInventory-NG
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
# 15. Where do you want the API code to be store [/usr/local/share/perl/5.30.1]? Deixe o padrão pressione <Enter>;
# 16. Do you allow Setup renaming Communication Server Apache configuration file to 'z-ocsinventory-server.conf' ([y]/n)?: y <-- digite y pressione <Enter>;
# 17. Do you wish to setup Administration Server (Web Administration Console) on this computer ([y]/n)?: y <-- digite y pressione <Enter>;
# 18. Do you wish to continue ([y]/n)?: y <-- digite y pressione <Enter>;
# 15. Where to copy Administration Server static files for PHP Web Console [/usr/share/ocsinventory-reports]?: Deixe o padrão pressione <Enter>;
# 16. Where to create writable/cache directories for deployment packages administration console logs, IPDiscover and SNMP [/var/lib/ocsinventory-reports]?: Deixe o padrão pressione <Enter>;
#
# INFORMAÇÕES QUE SERÃO SOLICITADAS VIA WEB (NAVEGADOR) DO OCS INVENTORY SERVER E REPORTS:
# 	01. MySQL login: root (usuário padrão do MySQL)
#	02. MySQL password: pti@2018 (senha criada nos arquivos 00-parametros.sh e 07-lamp.sh)
#	03. Name of Database: ocsweb (base de dados padrão do OCS Inventory, não mudar)
# 	04. MySQL HostName: localhost (servidor local do MySQL)
# 	05. MySQL Port: 3306 (porta padrão do MySQL)
# 	06. Enable SSL: NO
# 	07. SSL mode: default
# 	08. SSL key path: default
# 	09. SSL certificate path: default
# 	10. CA certificate path: default
# <Send>
#	11. Click here to enter OCS-NG GUI
#	12. Perform the update
# <Click here to enter OCS-NG GUI>
#
# USUÁRIO E SENHA PADRÃO DO OCS INVENTORY SERVER E REPORTS: 
# 	LANGUAGE: English
# 	USER: admin
# 	PASSWORD: admin
# <Send>
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
# Verificando se as dependências do OCS Inventory Server estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do OCS Inventory Server, aguarde... "
	for name in $OCSINVENTORYDDEP
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            echo -en "Recomendo utilizar o script: 03-dns.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 07-lamp.sh para resolver as dependências."
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
# Script de instalação do OCS Inventory no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do OCS Inventory no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Após a instalação do OCS Inventory acesse a URL: https://$(hostname -d | cut -d' ' -f1)/ocsreports"
echo -e "Usuário padrão após a instalação do OCS Inventory Reports: admin | Senha padrão: admin\n"
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
echo -e "Iniciando a Instalação e Configuração do OCS Inventory Server e Agent, aguarde...\n"
sleep 5
#
echo -e "Instalação das Dependências do OCS Inventory Server e Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $OCSINVENTORYINSTALLDEP &>> $LOG
echo -e "Instalação das dependências feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das Dependências do PHP do OCS Inventory Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $OCSINVENTORYINSTALLPHP &>> $LOG
echo -e "Instalação das dependências feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação das Dependências do PERL do OCS Inventory Server e Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $OCSINVENTORYINSTALLPERL &>> $LOG
echo -e "Instalação das dependências feito com sucesso!!!, continuando com o script...\n"
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
	if [ "$OCSINVENTORYAGENTNVIDIA" == "NVIDIA" ]; then
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
echo -e "Fazendo o download do OCS Inventory Server e Report, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	# opção do comando: tar z (gzip), x (extract), v (verbose) e f (file)
	rm -v ocsserver.tar.gz &>> $LOG
	wget $OCSINVENTORYSERVERINSTALL -O ocsserver.tar.gz &>> $LOG
	tar -zxvf ocsserver.tar.gz &>> $LOG
echo -e "Download feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do OCS Inventory Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	# opção do comando: tar z (gzip), x (extract), v (verbose) e f (file)
	rm -v ocsagent.tar.gz &>> $LOG
	wget $OCSINVENTORYAGENTINSTALL -O ocsagent.tar.gz &>> $LOG
	tar -zxvf ocsagent.tar.gz &>> $LOG
echo -e "Download feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o OCS Inventory Server e Reports, pressione <Enter> para continuar.\n"
echo -e "CUIDADO!!! com as opções que serão solicitadas no decorrer da instalação do OCS Inventory Server."
echo -e "Veja a documentação das opções de instalação a partir da linha: 22 do script $0"
	# opção do comando read: -s (Do not echo keystrokes)
	# opção do comando cd: .. (retorne to root folder)
	read -s
	cd OCSNG_UNIX_SERVER-*
		./setup.sh
	cd ..
echo -e "Instalação do OCS Inventory Server e Reports feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configurando as opções do OCS Inventory Server e Reports no Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando chmod: -R (recursive), -v (verbose), 775 (user=rwx, group=rwx, other=r-x)
	# opção do comando chown: -R (recursive), -v (verbose), www-data (user), www-data (group)
	# opção do comando cp: -v (verbose)
	# opção do comando cd: .. (retorne to root folder)
	a2enconf ocsinventory-reports &>> $LOG
	a2enconf z-ocsinventory-server &>> $LOG
	chmod -Rv 775 /var/lib/ocsinventory-reports/ &>> $LOG
	chown -Rv www-data.www-data /var/lib/ocsinventory-reports/ &>> $LOG
	cp -v OCSNG_UNIX_SERVER-*/*.log /var/log/ &>> $LOG
	systemctl restart apache2 &>> $LOG
echo -e "Configurações do OCS Inventory Server e Reports feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "ANTES DE CONTINUAR COM O SCRIPT ACESSE A URL: http://$(hostname -d | cut -d' ' -f1)/ocsreports"
echo -e "PARA FINALIZAR A CONFIGURAÇÃO VIA WEB DO OCS INVENTORY SERVER E REPORTS, APÓS A CONFIGURAÇÃO"
echo -e "PRESSIONE <ENTER> PARA CONTINUAR COM O SCRIPT. MAIS INFORMAÇÕES NA LINHA 44 DO SCRIPT $0"
read
sleep 5
#
echo -e "Criando o usuário no MySQL do OCS Inventory Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute), mysql (database)
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_USER_DATABASE_OCSINVENTORY" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_DATABASE_OCSINVENTORY" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_ALL_DATABASE_OCSINVENTORY" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH_OCSINVENTORY" mysql &>> $LOG
echo -e "Usuário criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo o arquivo install.php do OCS Inventory Reports, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	mv -v /usr/share/ocsinventory-reports/ocsreports/install.php /usr/share/ocsinventory-reports/ocsreports/install.php.old &>> $LOG
echo -e "Arquivo removido com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do OCS Inventory Server e Reports, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	mv -v /etc/apache2/conf-available/z-ocsinventory-server.conf /etc/apache2/conf-available/z-ocsinventory-server.conf.old &>> $LOG
	mv -v /etc/apache2/conf-available/zz-ocsinventory-restapi.conf /etc/apache2/conf-available/zz-ocsinventory-restapi.conf.old &>> $LOG
	mv -v /etc/apache2/conf-available/ocsinventory-reports.conf /etc/apache2/conf-available/ocsinventory-reports.conf.old &>> $LOG
	mv -v /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php.old &>> $LOG
	cp -v conf/ocsinventory/dbconfig.inc.php /usr/share/ocsinventory-reports/ocsreports/ &>> $LOG
	cp -v conf/ocsinventory/{ocsinventory-reports.conf,zz-ocsinventory-restapi.conf,z-ocsinventory-server.conf} /etc/apache2/conf-available/ &>> $LOG
	cp -v conf/ocsinventory/ocsinventory-server /etc/logrotate.d/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração z-ocsinventory-server.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/apache2/conf-available/z-ocsinventory-server.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração zz-ocsinventory-restapi.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/apache2/conf-available/zz-ocsinventory-restapi.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração ocsinventory-reports.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/apache2/conf-available/ocsinventory-reports.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração dbconfig.inc.php, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /usr/share/ocsinventory-reports/ocsreports/dbconfig.inc.php
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração ocsinventory-server, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a sada padrão)
	# opção do comando read: -s (Do not echo keystrokes)
	# opção do comando logrotate: -d (debug)
	read -s
	vim /etc/logrotate.d/ocsinventory-server
	logrotate /etc/logrotate.d/ocsinventory-server -d &>> $LOG
	systemctl restart apache2 &>> $LOG
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "ANTES DE CONTINUAR COM O SCRIPT ACESSE A URL: http://$(hostname -d | cut -d' ' -f1)/ocsreports"
echo -e "PARA CONFIRMAR AS ATUALIZAÇÕES VIA WEB DO OCS INVENTORY SERVER E REPORTS, APÓS A CONFIRMAÇÃO"
echo -e "PRESSIONE <ENTER> PARA CONTINUAR COM O SCRIPT. MAIS INFORMAÇÕES NA LINHA 66 DO SCRIPT $0"
read
sleep 5
#
echo -e "Instalando o OCS Inventory Agent, pressione <Enter> para instalar.\n"
echo -e "CUIDADO!!! com as opções que serão solicitadas no decorrer da instalação do OCS Inventory Agent."
echo -e "Veja a documentação das opções de instalação a partir da linha: 66 do arquivo $0"
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando cd: .. (retorne to root folder)
	read
	mkdir -v /var/log/ocsinventory-agent/ &>> $LOG
	touch /var/log/ocsinventory-agent/ocsagent.log &>> $LOG
	cd Ocsinventory-Unix-Agent-*
		perl Makefile.PL &>> $LOG
		make &>> $LOG
		make install
	cd ..
echo -e "Instalação do OCS Inventory Agent feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do OCS Inventory Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	mv -v /etc/ocsinventory-agent/ocsinventory-agent.cfg /etc/ocsinventory-agent/ocsinventory-agent.cfg.old &>> $LOG
	mv -v /etc/ocsinventory-agent/modules.conf /etc/ocsinventory-agent/modules.conf.old &>> $LOG
	cp -v conf/ocsinventory/{ocsinventory-agent.cfg,modules.conf} /etc/ocsinventory-agent/ &>> $LOG
	cp -v conf/ocsinventory/ocsinventory-agent /etc/cron.d/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração ocsinventory-agent.cfg, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/ocsinventory-agent/ocsinventory-agent.cfg
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração modules.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/ocsinventory-agent/modules.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração ocsinventory-agent, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/cron.d/ocsinventory-agent
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Forçando o primeiro inventário do OCS Inventory Agent com as novas configurações, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	ocsinventory-agent --debug --info &>> $LOG
echo -e "Inventário do OCS Inventory Agent feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do OCS Inventory Server e Agent feita com Sucesso!!!"
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