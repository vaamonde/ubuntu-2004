#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 19/10/2021
# Data de atualização: 30/04/2023
# Versão: 0.13
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Tomcat v9.0.x, OpenJDK v11.x, OpenJRE v11.x
#
# O software Tomcat, desenvolvido pela Fundação Apache, permite a execução de 
# aplicações para web. Sua principal característica técnica é estar centrada 
# na linguagem de programação Java, mais especificamente nas tecnologias de 
# Servlets e de Java Server Pages (JSP).
#
# OpenJDK é uma implementação livre e gratuita da plataforma Java, Edição 
# Standard. É o resultado dos esforços da Comunidade Java para a evolução 
# atemporal da linguagem. Serve como incubadora de novas ideias que normalmente 
# são implementadas no JDK comercial da Oracle para serem rentabilizadas 
# posteriormente.
#
# Site Oficial do Projeto Tomcat: http://tomcat.apache.org/
#
# Soluções Open Source de Servidor de Aplicativo
# Site Oficial do Projeto OpenJDK: https://openjdk.java.net/
# Site Oficial do Projeto WildFly (antigo JBOSS): https://www.wildfly.org/
# Site Oficial do Projeto Payara: https://www.payara.fish
#
# Administrando o Tomcat9 via Navegador
#	URL: http://pti.intra:8080
#	Manager Webapp: http://pti.intra:8080/manager/
#	Aplicativo Agenda: http://pti.intra:8080/agenda/
#	PhpMyAdmin: http://pti.intra/phpmyadmin
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
# Verificando se a porta 8080 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTTOMCAT &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTTOMCAT já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTTOMCAT está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando se as dependências do Apache Tomcat9 Server estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Apache Tomcat9 Server, aguarde... "
	for name in $TOMCATDEP
	do
		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
			echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
			deps=1; 
			}
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
			echo -en "\nInstale as dependências acima e execute novamente este script\n";
			echo -en "Recomendo utilizar o script: 03-dns.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 08-lamp.sh para resolver as dependências."
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
# Script de instalação e configuração do Tomcat9 no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação e Configuração do Apache Tomcat9 no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Apache Tomcat9.: TCP 8080"
echo -e "Após a instalação do Apache Tomcat acessar a URL: http://$(hostname -d | cut -d' ' -f1):8080/\n"
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
	# opção do comando: &>> (redirecionar de saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando todo o sistema operacional, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
	apt -y dist-upgrade &>> $LOG
	apt -y full-upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo todos os software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
	apt -y autoclean &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando a Instalação e Configuração do Servidor Web Apache Tomcat9, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do Apache Tomcat9, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $TOMCATDEPINSTALL &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a versão do Java instalada, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando update-java-alternatives: -l (list)
	java -version &>> $LOG
	update-java-alternatives -l &>> $LOG
echo -e "Versão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Servidor Web Apache Tomcat9, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $TOMCATINSTALL &>> $LOG
echo -e "Servidor Web Apache Tomcat9 instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do Apache Tomcat9, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	mv -v /etc/tomcat9/tomcat-users.xml /etc/tomcat9/tomcat-users.xml.old &>> $LOG
	mv -v /etc/tomcat9/server.xml /etc/tomcat9/server.xml.old &>> $LOG
	cp -v conf/tomcat/{tomcat-users.xml,server.xml} /etc/tomcat9/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração tomcat-users.xml, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/tomcat9/tomcat-users.xml
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração server.xml, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/tomcat9/server.xml
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando a Base de Dados da Agenda de Contatos no MySQL, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute), mysql (database)
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_DATABASE_JAVAEE" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_USER_DATABASE_JAVAEE" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_DATABASE_JAVAEE" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_ALL_DATABASE_JAVAEE" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH_JAVAEE" mysql &>> $LOG
	mysql -u $USERNAME_JAVAEE -p$PASSWORD_JAVAEE -e "$CREATE_TABLE_JAVAEE" $NAME_DATABASE_JAVAEE &>> $LOG
echo -e "Base de Dados da Agenda de Contatos criada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download da Agenda de Contatos do projeto do Github, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output-document)
	rm -v $PATHWEBAPPS/agenda.war &>> $LOG
	wget -O $PATHWEBAPPS/agenda.war $AGENDAJAVAEE &>> $LOG
echo -e "Download da Agenda de Contatos feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do Apache Tomcat9, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	systemctl restart tomcat9 &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do Apache Tomcat9, aguarde..."
	echo -e "Tomcat9: $(systemctl status tomcat9 | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as versões dos serviços instalados, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "Java OpenJDK...: $(dpkg-query -W -f '${version}\n' openjdk-11-jdk)"
	echo -e "Tomcat Server..: $(dpkg-query -W -f '${version}\n' tomcat9)"
echo -e "Versões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Apache Tomcat9, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:"8080" -sTCP:LISTEN
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação e Configuração do Apache Tomcat9 feita com Sucesso!!!"
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
