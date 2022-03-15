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
# Data de atualização: 21/01/2022
# Versão: 0.07
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do VSFTPD v3.0.x
#
# O VSFTPd, é um servidor FTP para sistemas do tipo Unix, incluindo Linux. 
# É o servidor FTP padrão nas distribuições Ubuntu, CentOS, Fedora, NimbleX, 
# Slackware e RHEL Linux. Está licenciado pela GNU General Public License. 
# Suporta IPv4, IPv6, TLS e FTPS.
#
# Site Oficial do Projeto Vsftpd: https://security.appspot.com/vsftpd.html
# Site Oficial do Projeto FileZilla: https://filezilla-project.org/
#
# Utilização do FTP Client no GNU/Linux ou Microsoft Windows
# Linux Mint Terminal: Ctrl+Alt+T
# 	ftp ftp.pti.intra (Internet file transfer program)
#		verbose
#		status
#		get robson.txt
#		put vaamonde.txt
#
# Windows Powershell:
# 	ftp ftp.pti.intra
#		verbose
#		status
#		get robson.txt
#		put vaamonde.txt
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
			echo -en "Recomendo utilizar o script: 07-lamp.sh para resolver as dependências"
			echo -en "Recomendo utilizar o script: 08-openssl.sh para resolver as dependências."
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
echo -e "Porta padrão utilizada pelo Vsftpd Server.: TCP 21"
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
	# opção do comando chown: -R (recursive), -v (verbose)
	# opção do comando chmod: -R (recursive), -v (verbose), 755 (User=RWX,Group=R-X,Other=R-X)
	useradd -s /bin/ftponly -G $GROUPFTP $USERFTP &>> $LOG
	echo -e "$PASSWORDFTP\n$PASSWORDFTP" | passwd $USERFTP &>> $LOG
	mkdir -v /home/$USERFTP &>> $LOG
	chown -Rv $USERFTP.$GROUPFTP /home/$USERFTP &>> $LOG
	chmod -Rv 755 /home/$USERFTP &>> $LOG
echo -e "Usuário padrão do Vsftpd criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o arquivo de configuração do Vsftpd Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	# opção do comando chmod: a (all user), + (bits to be added), x (execute/search only)
	mv -v /etc/vsftpd.conf /etc/vsftpd.conf.old &>> $LOG
	cp -v conf/ftp/{vsftpd.conf,vsftpd.allowed_users,shells} /etc/ &>> $LOG
	cp -v conf/ftp/vsftpd-ssl.conf /etc/ssl/ &>> $LOG
	cp -v conf/ftp/ftponly /bin/ &>> $LOG
	touch /var/log/vsftpd.log &>> $LOG
	chmod -v a+x /bin/ftponly &>> $LOG
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração vsftpd.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/vsftpd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de liberação vsftpd.allowed_users, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/vsftpd.allowed_users
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de TLS/SSL vsftpd-ssl.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/ssl/vsftpd-ssl.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de segurança de acesso ftponly, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /bin/ftponly
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de shell válidos shells, pressione <Enter> para continuar."
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
echo -e "Criando a Chave Privada/Pública e o Certificado Assinado do Vsftpd Server, aguarde..." 
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opções do comando openssl: 
	# genrsa (command generates an RSA private key),
	# -aes256 (Encrypt the private key with the AES)
	# -out (The output file to write to, or standard output if not specified), 
	# -passout (The output file password source), 
	# pass: (The actual password is password), 
	# 2048 (The size of the private key to generate in bits)
	#
	# opções do comando openssl: 
	# rsa (command processes RSA keys),
	# -in (The input file to read from, or standard input if not specified),
	# -out (The output file to write to, or standard output if not specified),
	# -passin (The key password source),
	# pass: (The actual password is password)
	#
	# opções do comando openssl: 
	# req (command primarily creates and processes certificate requests in PKCS#10 format), 
	# -new (Generate a new certificate request),
	# -sha256 (The message digest to sign the request with sha256)
	# -nodes (Do not encrypt the private key),
	# -key (The file to read the private key from), 
	# -out (The output file to write to, or standard output if not specified),
	# -extensions (Specify alternative sections to include certificate extensions), 
	# -config (Specify an alternative configuration file)
	#
	# Criando o arquivo CSR, mensagens que serão solicitadas na criação do CSR
	# 	Country Name (2 letter code): BR <-- pressione <Enter>
	# 	State or Province Name (full name): Brasil <-- pressione <Enter>
	# 	Locality Name (eg, city): Sao Paulo <-- pressione <Enter>
	# 	Organization Name (eg, company): Bora para Pratica <-- pressione <Enter>
	# 	Organization Unit Name (eg, section): Procedimentos em TI <-- pressione <Enter>
	# 	Common Name (eg, server FQDN or YOUR name): pti.intra <-- pressione <Enter>
	# 	Email Address: pti@pti.intra <-- pressione <Enter>
	#
	# opções do comando openssl: 
	# x509 (command is a multi-purpose certificate utility),
	# ca (command is a minimal certificate authority (CA) application)							
	# -in (The input file to read from, or standard input if not specified),
	# -out (The output file to write to, or standard output if none is specified)
	# -config (Specify an alternative configuration file)
	# -extensions (The section to add certificate extensions from),
	# -extfile (File containing certificate extensions to use).
	#
	# Sign the certificate? [y/n]: y <Enter>
	# 1 out of 1 certificate request certified, commit? [y/n]: y <Enter>
	#
	openssl genrsa -aes256 -out /etc/ssl/private/vsftpd-ptikey.key.old \
	-passout pass:$PWDSSLFTP 2048 &>> $LOG
	echo -e "Chave Privada/Pública criada com sucesso!!!, continuando com o script..."
	sleep 5
	#
	openssl rsa -in /etc/ssl/private/vsftpd-ptikey.key.old -out /etc/ssl/private/vsftpd-ptikey.key \
	-passin pass:$PWDSSLFTP &>> $LOG
	rm -v /etc/ssl/private/vsftpd-ptikey.key.old &>> $LOG
	echo -e "Senha da Chave Privada/Pública removida com sucesso!!!, continuando com o script...\n"
	sleep 5
	#
	echo -e "Gerando o Certificado CSR do Vsftpd Server, pressione <Enter> para continuar."
	read
	openssl req -new -sha256 -nodes -key /etc/ssl/private/vsftpd-ptikey.key -out /etc/ssl/requests/vsftpd-pticsr.csr \
	-extensions v3_req -config /etc/ssl/vsftpd-ssl.conf
	echo -e "Geração do Certificado CSR feito com sucesso!!!, continuando com o script...\n"
	sleep 5
	#
	echo -e "Gerando o Certificado CRT do Vsftpd Server, pressione <Enter> para continuar."
	read
	openssl ca -in /etc/ssl/requests/vsftpd-pticsr.csr -out /etc/ssl/newcerts/vsftpd-pticrt.crt \
	-config /etc/ssl/pti-ca.conf -extensions v3_req -extfile /etc/ssl/vsftpd-ssl.conf
	echo -e "Geração do Certificado CRT feito com sucesso!!!, continuando com o script...\n"
	#
echo -e "Chave Privada/Pública e Certificado Assinado do Vsftpd Server configurado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do Vsftpd Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart vsftpd &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do Vsftpd Server, aguarde..."
	echo -e "VSFTPd: $(systemctl status vsftpd | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Vsftpd Server, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:21 -sTCP:LISTEN
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
