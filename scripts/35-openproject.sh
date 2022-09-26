#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 14/05/2022
# Data de atualização: 14/05/2022
# Versão: 0.02
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão OpenProject v12.1.x
#
# OpenProject é um sistema de gerenciamento de projeto baseado na web para colaboração
# de equipe independente da localização. Este aplicativo de código aberto gratuito é 
# lançado sob a GNU General Public License Versão 3 e está disponível como uma edição 
# da comunidade e uma Enterprise Edition.
#
# Site oficial do Projeto OpenProject: https://www.openproject.org/
#
# Informações que serão solicitadas na configuração via Console do OpenProject
# Obs: informações utilizadas no arquivo: installer.dat ele será utilizado com o comando: openproject configure
# 01. Select your OpenProject Edition: default <OK>
# 02. Do you want to use this wizard to help setup your PostgreSQL database? install <OK>
# 03. Do you want to use this wizard to help setup your Web Server? install <OK>
# 04. Your fully qualified domain name: ptispo01ws01.pti.intra (172.16.1.20) <OK>
# 05. Server path prefix: /openproject <OK>
# 06. Do you want to enable SSL for your Web Server? no <OK>
# 07. Do yoi want to use this wizard to setup Subversion repositories support for openproject? install <OK>
# 08. Enter the path to the directory that hosts the SVN repositories: /var/db/openproject/svn <OK>
# 09. Do you want to use this wizard to setup Git repositories support for openproject? install <OK>
# 10. Enter the path to the directory that hosts the Git repositories: /var/db/openproject/git <OK>
# 11. Enter the path to the git http backend CGI directory: /usr/lib/git-core/git-http-backend/ <OK>
# 12. What do you want to use to send emails from openprojects? skip <OK>
# 13. Do you want to install a memcached server? install <OK>
#
# Informações que serão solicitadas na configuração via Web do OpenProject
# Username: admin
# Password: admin
# Current password: admin
# New password: BoraParaPratica
# Confirm password: BoraParaPratica (Save)
# Language: Português Brasileiro (Save)
# Tour Virtual (Pular)
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
# Verificando se as dependências do OpenProject estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do OpenProject, aguarde... "
	for name in $OPENPROJECTDEP
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
            echo -en "Recomendo utilizar o script: 31-postgresql.sh para resolver as dependências."
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
# Script de instalação do OpenProject no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Netdisco no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Após a instalação do OpenProject acessar a URL: https://$(hostname -d | cut -d ' ' -f1)/openproject/\n"
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
echo -e "Iniciando a Instalação e Configuração do OpenProject, aguarde...\n"
sleep 5
#
echo -e "Adicionando o Repositório do OpenProject, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando wget: -q (quiet) -O (output document file)
	# opção do comando cp: -v (verbose)
    wget -qO - $GPGOPENPROJECT | apt-key add - &>> $LOG
	cp -v conf/openproject/openproject.list /etc/apt/sources.list.d/ &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt com os novos Repositórios, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
    apt update &>> $LOG
	apt -y upgrade &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o OpenProject, aguarde..."
	#opção do comando: &>> (redirecionar a saída padrão)
	apt -y install $OPENPROJECTINSTALL &>> $LOG
	cp -v conf/openproject/installer.dat /etc/openproject/ &>> $LOG
echo -e "OpenProject instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o arquivo de configuração do OpenProject, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	cp -v conf/openproject/installer.dat /etc/openproject/ &>> $LOG
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração installer.dat, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/openproject/installer.dat 
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configurando o OpenProject, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	openproject configure &>> $LOG
echo -e "OpenProject configurado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o Database do OpenProject no PostgreSQL, aguarde..."
	# opção do comando sudo: -u (user)
	# opção do comando psql: -p (port), \l (list databases)
	sudo -u $USERPOSTGRESQL psql -p 45432 openproject --command '\l' | grep openproject
echo -e "Database verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do OpenProject feita com Sucesso!!!."
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
exit 
