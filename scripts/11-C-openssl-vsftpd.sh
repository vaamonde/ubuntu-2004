#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 16/10/2021
# Data de atualização: 01/05/2023
# Versão: 0.14
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do OpenSSL v1.1.x
# Testado e homologado para a versão do VSFTPd v3.0.x
#
# OpenSSL é uma implementação de código aberto dos protocolos SSL e TLS. A biblioteca 
# (escrita na linguagem C) implementa as funções básicas de criptografia e disponibiliza 
# várias funções utilitárias. Também estão disponíveis wrappers que permitem o uso desta 
# biblioteca em várias outras linguagens. 
#
# O OpenSSL está disponível para a maioria dos sistemas do tipo Unix, incluindo Linux, 
# Mac OS X, as quatro versões do BSD de código aberto e também para o Microsoft Windows. 
# O OpenSSL é baseado no SSLeay de Eric Young e Tim Hudson. O OpenSSL é utilizado para 
# gerar certificados de autenticação de serviços/protocolos em servidores (servers).
#
# O Transport Layer Security (TLS), assim como o seu antecessor Secure Sockets Layer 
# (SSL), é um protocolo de segurança projetado para fornecer segurança nas comunicações 
# sobre uma rede de computadores. Várias versões do protocolo encontram amplo uso em 
# aplicativos como navegação na web, email, mensagens instantâneas e voz sobre IP (VoIP). 
# Os sites podem usar o TLS para proteger todas as comunicações entre seus servidores e 
# navegadores web.
#
# O VSFTPd, é um servidor FTP para sistemas do tipo Unix, incluindo Linux. 
# É o servidor FTP padrão nas distribuições Ubuntu, CentOS, Fedora, NimbleX, 
# Slackware e RHEL Linux. Está licenciado pela GNU General Public License. 
# Suporta IPv4, IPv6, TLS e FTPS.
#
# Site Oficial do Projeto OpenSSL: https://www.openssl.org/
# Manual do OpenSSL: https://man.openbsd.org/openssl.1
# Site Oficial do Projeto VSFTPd: https://security.appspot.com/vsftpd.html
#
# Utilização do FTP Client no GNU/Linux ou Microsoft Windows
# Linux Mint Terminal: Ctrl+Alt+T
#	sudo apt update && sudo apt install lftp
# 	touch linux.txt (change file timestamps)
#	lftp -u ftpuser ftps://ftp.pti.intra (Internet file transfer program security)
#		history
#		get robson.txt (ou mget)
#		put linux.txt (ou mput)
#	Cliente de FTP FileZilla
#		sudo apt update && sudo apt install filezilla
#			Host...: ftp.pti.intra
#			Usuário: ftpuser
#			Senha..: pti@2018
#			Porta..: 990
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
# Verificando se as dependências do OpenSSL estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do OpenSSL, aguarde... "
	for name in $SSLDEP
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
			echo -en "Recomendo utilizar o script: 03-dns.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 09-vsftpd.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 11-A-openssl-ca.sh para resolver as dependências."
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
# Script de configuração do OpenSSL no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address), -A (all FQDN name), -d (domain)
# opções do comando cut: -d (delimiter), -f (fields)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Configuração do TLS/SSL no VSFTPd no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo VSFTPd Server TLS/SSL.: TCP 990"
echo -e "Depois de executar a instalação da CA no GNU/Linux e no Windows, testar o acesso seguro abaixo.\n"
echo -e "Confirmar o acesso com o Endereço IPv4: lftp ftps://$(hostname -I | cut -d' ' -f1)/"
echo -e "Confirmar o acesso com o Nome CNAME: lftp ftps://ftp.$(hostname -d | cut -d' ' -f1)/"
echo -e "Confirmar o acesso com o Nome Domínio: lftp ftps://$(hostname -d | cut -d' ' -f1)/"
echo -e "Confirmar o acesso com o Nome FQDN: lftp ftps://$(hostname -A | cut -d' ' -f1)/\n"
echo -e "Aguarde, esse processo demora um pouco, esse é o script mais complexo desse curso...\n"
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
echo -e "Iniciando a Configuração do OpenSSL TLS/SSL no VSFTPd, aguarde...\n"
sleep 5
#
echo -e "Atualizando o arquivo de configuração do Certificado do VSFTPd, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão adicionando)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	cp -v conf/ssl/vsftpd.conf /etc/ssl/ &>> $LOG
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Chave Privada de: $BITS do VSFTPd, senha padrão: $PASSPHRASE, aguarde..." 
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# genrsa (command generates an RSA private key),
	# -criptokey (Encrypt the private key with the AES, CAMELLIA, DES, triple DES or the IDEA ciphers)
	# -out (The output file to write to, or standard output if not specified), 
	# -passout (The output file password source), 
	# pass: (The actual password is password), 
	# bits (The size of the private key to generate in bits)
	#
	openssl genrsa -$CRIPTOKEY -out /etc/ssl/private/vsftpd.key.old -passout pass:$PASSPHRASE $BITS &>> $LOG
echo -e "Chave Privada do VSFTPd criada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo a senha da Chave Privada do VSFTPd, senha padrão: $PASSPHRASE, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# rsa (command processes RSA keys),
	# -in (The input file to read from, or standard input if not specified),
	# -out (The output file to write to, or standard output if not specified),
	# -passin (The key password source),
	# pass: (The actual password is password)
	# opção do comando rm: -v (verbose)
	#
	openssl rsa -in /etc/ssl/private/vsftpd.key.old -out /etc/ssl/private/vsftpd.key \
	-passin pass:$PASSPHRASE &>> $LOG
	rm -v /etc/ssl/private/vsftpd.key.old &>> $LOG
echo -e "Senha da Chave Privada do VSFTPd removida com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o arquivo de Chave Privada do VSFTPd, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# rsa (command processes RSA keys), 
	# -noout (Do not output the encoded version of the key), 
	# -modulus (Print the value of the modulus of the key), 
	# -in (The input file to read from, or standard input if not specified), 
	# md5 (The message digest to use MD5 checksums)
	#
	openssl rsa -noout -modulus -in /etc/ssl/private/vsftpd.key | openssl md5 &>> $LOG
echo -e "Arquivo de Chave Privada do VSFTPd verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Certificado do VSFTPd vsftpd.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/ssl/vsftpd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o arquivo CSR (Certificate Signing Request), confirme as mensagens do arquivo: vsftpd.conf, aguarde...\n"
	# opções do comando openssl: 
	# req (command primarily creates and processes certificate requests in PKCS#10 format), 
	# -new (Generate a new certificate request),
	# -criptocert (The message digest to sign the request with)
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
	openssl req -new -$CRIPTOCERT -nodes -key /etc/ssl/private/vsftpd.key -out \
	/etc/ssl/requests/vsftpd.csr -extensions v3_req -config /etc/ssl/vsftpd.conf
	echo
echo -e "Criação do arquivo CSR feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o arquivo CSR (Certificate Signing Request) do VSFTPd, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# req (command primarily creates and processes certificate requests in PKCS#10 format), 
	# -noout (Do not output the encoded version of the request), 
	# -text (Print the certificate request in plain text), 
	# -in (The input file to read a request from, or standard input if not specified)
	#
	openssl req -noout -text -in /etc/ssl/requests/vsftpd.csr &>> $LOG
echo -e "Arquivo CSR verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o certificado assinado CRT (Certificate Request Trust), do VSFTPd, aguarde...\n"
	# opção do comando: &>> (redirecionar a saída padrão
	# opções do comando openssl: 
	# x509 (command is a multi-purpose certificate utility),
	# ca (command is a minimal certificate authority (CA) application)
	# -req (Expect a certificate request on input instead of a certificate),
	# -days (The number of days to make a certificate valid for),
	# -criptocert (The message digest to sign the request with),							
	# -in (The input file to read from, or standard input if not specified),
	# -CA (The CA certificate to be used for signing),
	# -CAkey (Set the CA private key to sign a certificate with),
	# -CAcreateserial (Create the CA serial number file if it does not exist instead of generating an error),
	# -out (The output file to write to, or standard output if none is specified)
	# -config (Specify an alternative configuration file)
	# -extensions (The section to add certificate extensions from),
	# -extfile (File containing certificate extensions to use).
	#
	# Sign the certificate? [y/n]: y <Enter>
	# 1 out of 1 certificate request certified, commit? [y/n]: y <Enter>
	#
	# OPÇÃO DE ASSINATURA DO ARQUIVO CRT SEM UTILIZAR O WIZARD DO CA, CÓDIGO APENAS DE DEMONSTRAÇÃO
	# openssl x509 -req -days 3650 -$CRIPTOCERT -in /etc/ssl/requests/vsftpd.csr -CA \
	# /etc/ssl/newcerts/ca.crt -CAkey /etc/ssl/private/ca.key -CAcreateserial \
	# -out /etc/ssl/newcerts/vsftpd.crt -extensions v3_req -extfile /etc/ssl/vsftpd.conf &>> $LOG
	#
	openssl ca -in /etc/ssl/requests/vsftpd.csr -out /etc/ssl/newcerts/vsftpd.crt \
	-config /etc/ssl/ca.conf -extensions v3_req -extfile /etc/ssl/vsftpd.conf
	echo
echo -e "Criação do certificado assinado CRT do VSFTPd feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o arquivo CRT (Certificate Request Trust) do VSFTPd, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# x509 (command is a multi-purpose certificate utility), 
	# -noout (Do not output the encoded version of the request),
	# -text (Print the full certificate in text form), 
	# -modulus (Print the value of the modulus of the public key contained in the certificate), 
	# -in (he input file to read from, or standard input if not specified), 
	# md5 (The message digest to use MD5 checksums)
	#
	openssl x509 -noout -modulus -in /etc/ssl/newcerts/vsftpd.crt | openssl md5 &>> $LOG
	openssl x509 -noout -text -in /etc/ssl/newcerts/vsftpd.crt &>> $LOG
	cat /etc/ssl/index.txt &>> $LOG
	cat /etc/ssl/index.txt.attr &>> $LOG
	cat /etc/ssl/serial &>> $LOG
echo -e "Arquivo CRT do VSFTPd verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração vsftpd.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/vsftpd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do VSFTPd Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart vsftpd &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do VSFTPd Server, aguarde..."
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
echo -e "Verificando a porta de conexão do VSFTPd Server, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:990 -sTCP:LISTEN
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Testando o Certificado TLS/SSL do VSFTPd, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando echo: | (piper, faz a função de Enter no comando)
	# opções do comando openssl: 
	# s_client (command implements a generic SSL/TLS client which connects to a remote host using SSL/TLS)
	# -connect (The host and port to connect to)
	# -servername (Include the TLS Server Name Indication (SNI) extension in the ClientHello message)
	# -showcerts (Display the whole server certificate chain: normally only the server certificate itself is displayed)
	#
	echo | openssl s_client -connect $IPV4SERVER:990 -servername ftp.$DOMINIOSERVER -showcerts &>> $LOG
echo -e "Certificado do VSFTPd testado sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configuração do OpenSSL e TLS/SSL do VSFTPd feita com Sucesso!!!."
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
