#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 08/01/2022
# Data de atualização: 30/04/2023
# Versão: 0.13
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do Apache2 v2.4.x
#
# WebDAV é um acrônimo de Web-based Distributed Authoring and Versioning, ou Criação 
# e Distribuição de Conteúdo pela Web. É uma extensão do protocolo HTTP para transferência 
# de arquivos; suporta bloqueio de recursos. Quando uma pessoa está editando um arquivo, 
# ele fica bloqueado, impedindo que outras pessoas façam alterações ao mesmo tempo.
# Esse recurso esta presente no Microsoft SharePoint, Notability, Pages, Keynote, Number, 
# entre vários outros apps e serviços. 
#
# Site Oficial do Projeto Webdav: http://www.webdav.org/
#
# Configuração do Webdav Client no GNU/Linux ou Microsoft Windows
# Linux Mint Terminal: Ctrl+Alt+T
#	sudo apt update && sudo apt install davfs2
#		Usuários sem privilégios podem montar recursos WebDAV? <SIM>
#	sudo usermod -a -G davfs2 vaamonde (modify a user account)
#	sudo mkdir -v /mnt/davs (make directories)
#	id (print real and effective user and group IDs)
#	groups (print the groups a user is in)
#	sudo cat /etc/groups
#	sudo mount -v -t davfs -o rw,noexec,nosuid,nodev,noauto,uid=1000,gid=1000 https://webdav.pti.intra /mnt/davs/ (mount a filesystem)
#		Username: vaamonde
#		Password: pti@2018
#	sudo mount | grep davfs (mount a filesystem)
#	sudo umount /mnt/davs (umount a filesystem)
#
# Gerenciador de Arquivos Neno
#	Ctrl+L
#		davs://vaamonde@webdav.pti.intra/
#
# Navegadores de Internet (Firefox, Chrome, Edge, etc...)
#	URL: https://webdav.pti.intra/
#		Username: vaamonde
#		Password: pti@2018
#
# Windows Explorer:
#	Este Computador
#		Computador
#			Adicionar Local de Rede
#				<Avançar>;
#				Escolher um Local de Rede Personalizado <Avançar>;
#				Endereço de Rede ou na Internet: https://webdav.pti.intra <Avançar>;
#					Nome do usuário: vaamonde
#					Senha do usuário: pti@2018 <OK>
#				Digite o nome para este local de rede: webdav.pti.intra <Avançar>;
#				Abrir esse local de rede quando eu clicar em Concluir <Concluir>.
#
# Windows Powershell:
#	OBSERVAÇÃO IMPORTANTE: conforme comentado no vídeo está sendo analisado as falhas de autenticação de acesso 
#	ao Webdav via Powershell e Net Use no Windows 10 e 11 verificar o arquivo BUG: 0023 - Falha na montagem do 
#	compartilhamento do Protocolo Webdav - STATUS: RESOLVIDO
#	Executar o Powershell como Administrador 
#		Get-Service WebClient
#		Start-Service WebClient
#		Set-Service WebClient –StartupType Automatic
#	Fechar o Powershell e abrir em modo de usuário normal
#
#	OBSERVAÇÃO IMPORTANTE: o comando New-PSDriver do Powershell não aparece o compartilhamento no Windows Explorer
#	já o comando Net Use aparece no compartilhamento do Windows Explorer (recomendado)
#	New-PSDrive -Name W -PSProvider FileSystem -Root \\webdav.pti.intra@SSL\webdav -Credential vaamonde
#		cd w:
#	net use X: https://webdav.pti.intra /USER:vaamonde pti@2018
#		cd x:
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
# Verificando se as dependências do Webdav estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Webdav, aguarde... "
	for name in $WEBDAVDEP
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
			echo -en "Recomendo utilizar o script: 11-A-openssl-ca.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 11-B-openssl-apache.sh para resolver as dependências."
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
# Script de configuração do Webdav no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Configuração do Webdav no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Webdav.: TCP 443"
echo -e "Após a instalação do Webdav acessar a URL: https://webdav.$(hostname -d | cut -d' ' -f1)/\n"
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
echo -e "Iniciando a Configuração do Webdav no Apache2, aguarde...\n"
sleep 5
#
echo -e "Habilitando os módulos do Webdav no Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	a2enmod dav &>> $LOG
	a2enmod dav_fs &>> $LOG
	a2enmod auth_digest &>> $LOG
echo -e "Módulos habilitados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando os diretórios do Webdav e do DAVLockDB no Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando chown: -v (verbose), www-data (user), www-data (group)
	mkdir -v $PATHWEBDAV &>> $LOG
	mkdir -v $PATHDAVLOCK &>> $LOG
	chown -v www-data:www-data $PATHWEBDAV $PATHDAVLOCK &>> $LOG
echo -e "Diretórios criados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o diretório do Banco de Dados de Usuários do Webdav no Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	mkdir -v $PATHWEBDAVUSERS &>> $LOG
echo -e "Diretório criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o arquivo de Banco de Dados de usuários do Webdav, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	touch $PATHWEBDAVUSERS/users.password &>> $LOG
echo -e "Arquivo criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Copiando o arquivo de Virtual Host do Webdav no Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/webdav/webdav.conf /etc/apache2/sites-available/ &>> $LOG
echo -e "Arquivo copiando com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração webdav.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/apache2/sites-available/webdav.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando o Virtual Host do Webdav no Apache2, aguarde..."
	a2ensite webdav &>> $LOG
echo -e "Virtual Host habilitado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o usuário: $USERWEBDAV do Webdav, senha padrão: $PASSWORDWEBDAV, aguarde..."
	htdigest $PATHWEBDAVUSERS/users.password $REALWEBDAV $USERWEBDAV
echo -e "Usuário criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as configurações do Apache2, aguarde..."
	apachectl configtest &>> $LOG
echo -e "Configurações do Apache2 verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart apache2 &>> $LOG
	systemctl reload apache2 &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do Apache2, aguarde..."
	echo -e "Apache2: $(systemctl status apache2 | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as versões dos serviços instalados, aguarde..."
	echo -e "Apache2 Server..: $(apache2ctl -V | grep -i "server version" | cut -d':' -f2)"
echo -e "Versões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as versões dos serviços instalados, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "Apache2 Server..: $(dpkg-query -W -f '${version}\n' apache2)"
	echo -e "OpenSSL.........: $(dpkg-query -W -f '${version}\n' openssl)"
echo -e "Versões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Apache2, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:443 -sTCP:LISTEN
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o Virtual Host do Webdav no Apache2, aguarde..."
	# opção do comando apachectl: -s (a synonym)
	apache2ctl -S | grep webdav.$DOMINIOSERVER
echo -e "Virtual Host verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configuração do Webdav no Apache2 feita com Sucesso!!!."
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
