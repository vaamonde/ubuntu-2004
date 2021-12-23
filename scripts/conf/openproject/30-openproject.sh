#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 03/01/2021
# Data de atualização: 19/04/2021
# Versão: 0.03
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do OpenProject-
#
# OpenProject é um sistema de gerenciamento de projeto baseado na web para colaboração de equipe 
# independente da localização. Este aplicativo de código aberto gratuito é lançado sob a GNU General
# Public License Versão 3 e está disponível como uma edição da comunidade e uma Enterprise Edition.
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
# Site oficial: https://www.openproject.org/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de instalação do LAMP Server no Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=6EFUu-I3
# Vídeo de instalação do PostgreSQL no Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=POCafSY3LAk&t
#
# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário é "root", versão do ubuntu e kernel
# opções do comando id: -u (user)
# opções do comando: lsb_release: -r (release), -s (short), 
# opões do comando uname: -r (kernel release)
# opções do comando cut: -d (delimiter), -f (fields)
# opção do shell script: piper | = Conecta a saída padrão com a entrada padrão de outro comando
# opção do shell script: acento crase ` ` = Executa comandos numa subshell, retornando o resultado
# opção do shell script: aspas simples ' ' = Protege uma string completamente (nenhum caractere é especial)
# opção do shell script: aspas duplas " " = Protege uma string, mas reconhece $, \ e ` como especiais
# opção do shell script: $() = Executa comandos numa subshell, retornando o resultado
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
KERNEL=$(uname -r | cut -d'.' -f1,2)
#
# Variável de configuração do PostgreSQL
USER="postgres"
#
# Variável do caminho do Log dos Script utilizado nesse curso (VARIÁVEL MELHORADA)
# opções do comando cut: -d (delimiter), -f (fields)
# $0 (variável de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Declarando a variável da chave do Repositório do OpenProject (Link atualizado no dia 03/01/2021)
KEY="https://dl.packager.io/srv/opf/openproject/key"
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
# Verificando se as dependências do OpenProject estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do OpenProject, aguarde... "
	for name in apache2 php postgresql postgresql-client
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            echo -en "Recomendo utilizar o script: lamp.sh para resolver as dependências do Apache e PHP."
			echo -en "Recomendo utilizar o script: postgresql.sh para resolver as dependências do PostgreSQL"
            exit 1; 
            }
		sleep 5
#
# Script de instalação do OpenProject no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opções do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do OpenProject no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do OpenProject acessar a URL: http://`hostname -I | cut -d' ' -f1`/openproject/\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository universe &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Adicionando o Repositório Multiversão do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository multiverse &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando as listas do Apt, aguarde..."
	#opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando o sistema, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Removendo software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o OpenProject, aguarde...\n"
#
echo -e "Baixando e instalando a Chave (Key) e Source List do Repositório do OpenProject, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando wget: -q (quiet), -O (output document)
	# opção do comando apt-key: - (input file)
	# opção do comando cp: -v (verbose)
	wget -qO- $KEY| apt-key add - &>> $LOG
	cp -v conf/openproject.list /etc/apt/sources.list.d/ &>> $LOG
echo -e "Repositório instalado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando novamente as listas do Apt, aguarde..."
	#opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o OpenProject, aguarde..."
	#opção do comando: &>> (redirecionar a saída padrão)
	apt -y install openproject &>> $LOG
echo -e "OpenProject instalado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Configurando o OpenProject, aguarde..."
	#opção do comando: &>> (redirecionar a saída padrão)
    #opção do comando cp: -v (verbose)
    cp -v conf/installer.dat /etc/openproject/ &>> $LOG
    sleep 3
    echo -e "Arquivo de configuração atualizado com sucesso!!!, continuando com o script...\n"
	echo -e "Editando o arquivo de configuração do OpenProject, pressione <Enter> para continuar"
		read
		sleep 3
		vim /etc/openproject/installer.dat
	echo -e "Arquivo editado com sucesso!!!, continuando com o script, aguarde esse processo demora...\n"
	    openproject configure &>> $LOG
echo -e "OpenProject configurado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Verificando a porta de conexão do PostgreSQL do OpenProject, aguarde..."
	# opção do comando netstat: a (all), n (numeric)
	netstat -an | grep 45432
echo -e "Porta verificada com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Verificando o Database do OpenProject no PostgreSQL, aguarde..."
	# opção do comando sudo: -u (user)
	# opção do comando psql: -p (port), \l (list databases)
	sudo -u $USER psql -p 45432 openproject --command '\l' | grep openproject
echo -e "Database verificado com sucesso!!!, continuando com o script..."
sleep 5
echo
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
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1
