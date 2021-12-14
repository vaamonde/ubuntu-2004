#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 21/03/2021
# Data de atualização: 12/05/2021
# Versão: 0.06
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do Bacula 11.x e do Baculum 11.x
#
# O Bacula é um conjunto de software de código aberto que permitem o gerenciamento de backups, restaurações
# e verificação de dados através de uma rede de computadores de diversos tipos. É relativamente fácil de 
# usar e muito eficiente, enquanto oferece muitas funcionalidades avançadas de gerenciamento de armazenamento, 
# as quais facilitam a encontrar e recuperar arquivos perdidos ou corrompidos. Com ele é possível fazer 
# backup remotamente de Linux, Solaris, FreeBSD, NetBSD, Windows, Mac OS X, etc... 
#
# O Baculum fornece duas aplicações web: o Baculum Web como interface web para gerenciar o Bacula e a API 
# do Baculum, que é a interface de programação do Bacula. Ambas as ferramentas conectadas criam um ambiente
# web para facilitar o trabalho com os programas da Comunidade Bacula. 
#
# Informações que serão solicitadas na configuração via Web do Baculum
# Endereço padrão do Baculum WEB: http://localhost:9095
# Endereço padrão do Baculum API: http://localhost:9096
# Usuário padrão: admin - Senha padrão: admin
#
# PRIMEIRA ETAPA: CONFIGURAR O BACULUM API: http://localhost:9096
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
# SEGUNDA ETAPA: CONFIGURAR O BACULUM WEB: http://localhost:9096
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
# Site Oficial do Projeto Bacula: https://www.bacula.org/
# Site Oficial do Projeto Baculum: https://baculum.app/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de configuração do OpenSSH no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=ecuol8Uf1EE&t
# Vídeo de instalação do LAMP Server no Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=6EFUu-I3
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
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
KERNEL=$(uname -r | cut -d'.' -f1,2)
#
# Variável do caminho do Log dos Script utilizado nesse curso (VARIÁVEL MELHORADA)
# opções do comando cut: -d (delimiter), -f (fields)
# $0 (variável de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Declarando as variáveis de download do Bacula (Link atualizado no dia 12/05/2021)
BACULAKEY="https://www.bacula.org/downloads/Bacula-4096-Distribution-Verification-key.asc"
BACULUMKEY="http://bacula.org/downloads/baculum/baculum.pub"
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
# Verificando se as dependências do Bacula estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Bacula, aguarde... "
	for name in apt-transport-https apache2 php python mysql-server mysql-common
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
# Script de instalação do Bacula no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do Bacula e Baculum no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do Baculum WEB acessar a URL: http://`hostname -I | cut -d' ' -f1`:9095"
echo -e "Após a instalação do Baculum API acessar a URL: http://`hostname -I | cut -d' ' -f1`:9096\n"
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
echo -e "Instalando o Bacula Server e Baculum WEB/API, aguarde...\n"
sleep 5
#
echo -e "Adicionando o repositório do Bacula Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando wget: -q -O- (file)
	# opção do redirecionador |: Conecta a saída padrão com a entrada padrão de outro comando
	# opção do comando apt-key: add (file name), - (arquivo recebido do redirecionar | piper)
	cp -v conf/bacula.list /etc/apt/sources.list.d/bacula.list &>> $LOG
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
	cp -v conf/baculum.list /etc/apt/sources.list.d/baculum.list &>> $LOG
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
	apt -y install bacula-client bacula-common bacula-mysql bacula-console &>> $LOG
echo -e "Bacula Server e Console instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Baculum WEB com suporte ao Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando apt: -y (yes)
	apt -y install baculum-web baculum-web-apache2 &>> $LOG
echo -e "Baculum WEB instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Baculum API com suporte ao Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando apt: -y (yes)
	apt -y install baculum-common baculum-api-apache2 &>> $LOG
echo -e "Baculum API instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando os Sites do Baculum WEB e API no Apache2, aguarde..."
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
	for i in `ls /opt/bacula/bin`; do
		ln -sv /opt/bacula/bin/$i /usr/sbin/$i &>> $LOG;
	done
echo -e "Atalhos criados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o arquivo baculum.api do Sudoers e hosts.allow do TCPWrappers, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/baculum-api /etc/sudoers.d/ &>> $LOG
	cp -v conf/hosts.allow /etc/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo baculum.api, pressione: <Enter> para continuar"
	read
	sleep 3
	vim /etc/sudoers.d/baculum-api
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo hosts.allow, pressione: <Enter> para continuar"
	read
	sleep 3
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
echo -e "Testando o acesso ao Bacula BConsole, pressione <Enter> para continuar."
echo -e "Para sair do Bacula BConsole digite: quit <Enter>."
	read
	bconsole
echo -e "Bacula BConsole testado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de Conexões do Bacula Server e do Baculum WEB/API, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric)
	netstat -an | grep '9101\|9102\|9103\|9095\|9096'
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script...\n"
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
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1
