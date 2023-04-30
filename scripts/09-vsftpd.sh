#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 17/10/2021
# Data de atualização: 30/04/2023
# Versão: 0.12
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do VSFTPD v3.0.x
#
# O VSFTPd, é um servidor FTP para sistemas do tipo Unix, incluindo Linux. 
# É o servidor FTP padrão nas distribuições Ubuntu, CentOS, Fedora, NimbleX, 
# Slackware e RHEL Linux. Está licenciado pela GNU General Public License. 
# Suporta IPv4, IPv6, TLS e FTPS.
#
# Site Oficial do Projeto VSFTPd: https://security.appspot.com/vsftpd.html
#
# Soluções Open Source de Servidor de FTP
# Site Oficial do Projeto ProFTPD: http://www.proftpd.org/
# Site Oficial do Projeto Pure-FTPD: https://www.pureftpd.org/project/pure-ftpd/
# Site Oficial do Projeto FileZilla: https://filezilla-project.org/
#
# Utilização do FTP Client no GNU/Linux ou Microsoft Windows
# Linux Mint Terminal: Ctrl+Alt+T
# 	touch linux.txt (change file timestamps)
#	ftp ftp.pti.intra (Internet file transfer program)
#		verbose
#		status
#		get robson.txt (ou mget)
#		put linux.txt (ou mput)
#	Gerenciador de Arquivos Neno
#		Ctrl+L
#			ftp://ftp.pti.intra
#				Usuário Registrado
#					Usuário: ftpuser
#					Senha..: pti@2018
#	Cliente de FTP FileZilla
#		sudo apt update && sudo apt install filezilla
#			Host...: ftp.pti.intra
#			Usuário: ftpuser
#			Senha..: pti@2018
#			Porta..: 21
#
# Windows Powershell:
#	OBSERVAÇÃO IMPORTANTE: para o cliente de FTP Funcionar corretamente no Windows você
#	precisar desativar o Firewall ou Criar Regras de Permissão de Envio e Recebimento do
#	Protocolo FTP das portas 20 e 21 do FTP Client no Windows.
# 	New-Item -Path '.\windows.txt' -ItemType File
#	ftp ftp.pti.intra
#		verbose
#		status
#		get robson.txt
#		put windows.txt
#	Gerenciador de Arquivos Windows Explorer
#		Ctrl+L
#			ftp://ftpuser@ftp.pti.intra
#				Usuário: ftpuser
#				Senha..: pti@2018
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
# Verificando se a porta 21 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTFTP &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTFTP já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTFTP está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando se as dependências do Vsftpd Server estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Vsftpd Server, aguarde... "
	for name in $FTPDEP
	do
		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
			echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
			deps=1; 
			}
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
			echo -en "\nInstale as dependências acima e execute novamente este script\n";
			echo -en "Recomendo utilizar o script: 03-dns.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 08-lamp.sh para resolver as dependências"
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
# Script de instalação do Vsftpd no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Vsftpd Server no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Vsftpd Server.: TCP 21 e 990"
echo -e "Após a instalação do Vsftpd acessar o FTP: ftp://ftp.$(hostname -d | cut -d' ' -f1)\n"
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
echo -e "Iniciando a Instalação e Configuração do Vsftpd Server, aguarde...\n"
sleep 5
#
echo -e "Instalando o Serviço do Vsftpd Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt -y install $FTPINSTALL &>> $LOG
echo -e "Vsftpd Server instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Grupo padrão dos Usuários do Vsftpd, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	groupadd $GROUPFTP &>> $LOG
echo -e "Grupo criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Usuário padrão de acesso ao Vsftpd, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando useradd: -s (shell), -G (Groups)
	# opção do comando echo: -e (enable escapes), \n (new line), 
	# opção do redirecionar | "piper": (Conecta a saída padrão com a entrada padrão de outro comando)
	# opção do comando mkdir: -v (verbose)
	# opção do comando chown: -R (recursive), -v (verbose), ftpuser (user), ftpusers (group)
	# opção do comando chmod: -R (recursive), -v (verbose), 755 (User=RWX,Group=R-X,Other=R-X)
	useradd -s /bin/ftponly -G $GROUPFTP $USERFTP &>> $LOG
	echo -e "$PASSWORDFTP\n$PASSWORDFTP" | passwd $USERFTP &>> $LOG
	mkdir -v /home/$USERFTP &>> $LOG
	chown -Rv $USERFTP.$GROUPFTP /home/$USERFTP &>> $LOG
	chmod -Rv 755 /home/$USERFTP &>> $LOG
echo -e "Usuário padrão do Vsftpd criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configurações do Vsftpd Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	# opção do comando chmod: -v (verbose), a (all user), + (bits to be added), x (execute/search only)
	# opção do comando chown: -v (verbose), syslog (user), root (group)
	mv -v /etc/vsftpd.conf /etc/vsftpd.conf.old &>> $LOG
	cp -v conf/ftp/{vsftpd.conf,vsftpd.allowed_users,shells} /etc/ &>> $LOG
	cp -v conf/ftp/ftponly /bin/ &>> $LOG
	chmod -v a+x /bin/ftponly &>> $LOG
	touch /var/log/vsftpd.log &>> $LOG
	chown -v syslog.root /var/log/vsftpd.log &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração vsftpd.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/vsftpd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração vsftpd.allowed_users, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/vsftpd.allowed_users
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo configuração ftponly, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /bin/ftponly
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração shells, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/shells
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração hosts.allow, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/hosts.allow
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração 50-default.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/rsyslog.d/50-default.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando os serviços do Vsftpd Server e do Rsyslog, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando chown: -v (verbose), syslog (user), root (group)
	systemctl restart vsftpd &>> $LOG
	systemctl restart rsyslog &>> $LOG
echo -e "Serviços reinicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do Vsftpd Server, aguarde..."
	echo -e "VSFTPd: $(systemctl status vsftpd | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a versão do serviço instalado, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "VSFTPd Server..: $(dpkg-query -W -f '${version}\n' vsftpd)"
echo -e "Versão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Vsftpd Server, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:'21' -sTCP:LISTEN
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Vsftpd Server feita com Sucesso!!!"
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
