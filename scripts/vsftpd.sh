#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 09/06/2021
# Data de atualização: 17/06/2021
# Versão: 0.05
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do VSFTPD v3.0.x
#
# O VSFTPd, é um servidor FTP para sistemas do tipo Unix, incluindo Linux. É o servidor FTP 
# padrão nas distribuições Ubuntu, CentOS, Fedora, NimbleX, Slackware e RHEL Linux. Está 
# licenciado pela GNU General Public License. Suporta IPv4, IPv6, TLS e FTPS.
#
# Site Oficial do Projeto Vsftpd: https://security.appspot.com/vsftpd.html
# Site Oficial do Projeto FileZilla: https://filezilla-project.org/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de configuração do OpenSSH no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=ecuol8Uf1EE&t
# Vídeo de instalação do LAMP Server no Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=6EFUu-I3u4s
# Vídeo de instalação e configuração do Bind9 DNS e do ISC DHCP Server: https://www.youtube.com/watch?v=NvD9Vchsvbk
# Vídeo de configuração do OpenSSL no Apache2: https://www.youtube.com/watch?v=GXcwpJfp7eo
# Vídeo de instalação e configuração do Wordpress: https://www.youtube.com/watch?v=Fs2B7kLdlm4
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
# Criação do Grupo dos Usuários de FTP e Usuários de Acesso ao FTP
GROUPFTP="ftpusers"
USERFTP1="ftpuser"
USERFTP2="wordpress"
PASSWORD="pti@2018"
WORDPRESS="/var/www/html/wp"
#
# Variável do caminho do Log dos Script utilizado nesse curso (VARIÁVEL MELHORADA)
# opções do comando cut: -d (delimiter), -f (fields)
# $0 (variável de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
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
# Verificando se as dependências do Vsftpd Server estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Vsftpd Server, aguarde... "
	for name in bind9 bind9utils apache2 openssl
	do
		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
			echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
			deps=1; 
			}
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
			echo -en "\nInstale as dependências acima e execute novamente este script\n";
			echo -en "Recomendo utilizar o script: lamp.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: wordpress.sh para resolver as dependências"
			echo -en "Recomendo utilizar o script: dnsdhcp.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: openssl.sh para resolver as dependências."
			exit 1; 
			}
		sleep 5
#
# Script de instalação do Vsftpd no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do Vsftpd Server no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do Vsftpd acessar o FTP: ftp://ftp.`hostname -d | cut -d' ' -f1`"
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
echo -e "Instalando o Vsftpd Server e criando os usuários, aguarde...\n"
sleep 5
#
echo -e "Instalando o Serviço do Vsftpd Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt -y install vsftpd &>> $LOG
echo -e "Vsftpd Server instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Grupo padrão dos Usuários do FTP, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	groupadd ftpusers &>> $LOG
echo -e "Grupo criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Usuário padrão de acesso ao FTP, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando useradd: -s (shell), -G (Groups)
	# opção do comando echo: -e (enable escapes), \n (new line), 
	# opção do redirecionar | "piper": (Conecta a saída padrão com a entrada padrão de outro comando)
	# opção do comando mkdir: -v (verbose)
	# opção do comando chown: -R (recursive), -v (verbose)
	# opção do comando chmod: -R (recursive), -v (verbose), 755 (User=RWX,Group=R-X,Other=R-X)
	useradd -s /bin/ftponly -G $GROUPFTP $USERFTP1 &>> $LOG
	echo -e "$PASSWORD\n$PASSWORD" | passwd $USERFTP1 &>> $LOG
	mkdir -v /home/$USERFTP1 &>> $LOG
	chown -Rv $USERFTP1.$GROUPFTP /home/$USERFTP1 &>> $LOG
	chmod -Rv 755 /home/$USERFTP1 &>> $LOG
echo -e "Usuário padrão do FTP criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Usuário de FTP do Wordpress, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando useradd: -d (home-dir), -s (shell), -G (Groups)
	# opção do comando echo: -e (enable escapes), \n (new line), 
	# opção do redirecionar | "piper": (Conecta a saída padrão com a entrada padrão de outro comando)
	useradd -d $WORDPRESS -s /bin/ftponly -G www-data,$GROUPFTP $USERFTP2 &>> $LOG
	echo -e "$PASSWORD\n$PASSWORD" | passwd $USERFTP2 &>> $LOG
echo -e "Usuário de FTP do Wordpress criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o arquivo de configuração do Vsftpd Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comand chmod: a (all user), + (bits to be added), x (execute/search only)
	mv -v /etc/vsftpd.conf /etc/vsftpd.conf.old &>> $LOG
	cp -v conf/vsftpd.conf /etc/vsftpd.conf &>> $LOG
	cp -v conf/vsftpd.allowed_users /etc/vsftpd.allowed_users &>> $LOG
	cp -v conf/vsftpd-ssl.conf /etc/ssl/vsftpd-ssl.conf &>> $LOG
	cp -v conf/ftponly /bin/ftponly &>> $LOG
	cp -v conf/shells /etc/shells &>> $LOG
	chmod -v a+x /bin/ftponly &>> $LOG
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Vsftpd Server, pressione <Enter> para continuar."
	read
	vim /etc/vsftpd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de liberação do Vsftpd Server, pressione <Enter> para continuar."
	read
	vim /etc/vsftpd.allowed_users
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de TLS/SSL do Vsftpd Server, pressione <Enter> para continuar."
	read
	vim /etc/ssl/vsftpd-ssl.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de segurança de acesso ao Vsftpd Server, pressione <Enter> para continuar."
	read
	vim /bin/ftponly
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de shell válidos para o acesso ao Vsftpd Server, pressione <Enter> para continuar."
	read
	vim /etc/shells
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo hosts.allow do TCPWrappers de liberação Vsftpd Server, pressione <Enter> para continuar."
	read
	vim /etc/hosts.allow
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Chave Privada/Pública e o Certificado Assinado do Vsftpd Server, aguarde..." 
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando openssl: genrsa (command generates an RSA private key),
	#							-aes256 (Encrypt the private key with the AES)
	#							-out (The output file to write to, or standard output if not specified), 
	#							-passout (The output file password source), 
	#							pass: (The actual password is password), 
	#							2048 (The size of the private key to generate in bits)
	# opção do comando openssl: rsa (command processes RSA keys),
	#							-in (The input file to read from, or standard input if not specified),
	#							-out (The output file to write to, or standard output if not specified),
	#							-passin (The key password source),
	#							pass: (The actual password is password)
	# opção do comando openssl: req (command primarily creates and processes certificate requests in PKCS#10 format), 
	#							-new (Generate a new certificate request),
	#							-sha256 (The message digest to sign the request with sha256)
	#							-nodes (Do not encrypt the private key),
	#							-key (The file to read the private key from), 
	#							-out (The output file to write to, or standard output if not specified),
	#							-extensions (Specify alternative sections to include certificate extensions), 
	#							-config (Specify an alternative configuration file)
	# Criando o arquivo CSR, mensagens que serão solicitadas na criação do CSR
	# 	Country Name (2 letter code): BR <-- pressione <Enter>
	# 	State or Province Name (full name): Brasil <-- pressione <Enter>
	# 	Locality Name (eg, city): Sao Paulo <-- pressione <Enter>
	# 	Organization Name (eg, company): Bora para Pratica <-- pressione <Enter>
	# 	Organization Unit Name (eg, section): Procedimentos em TI <-- pressione <Enter>
	# 	Common Name (eg, server FQDN or YOUR name): pti.intra <-- pressione <Enter>
	# 	Email Address: pti@pti.intra <-- pressione <Enter>
	# opção do comando openssl: x509 (command is a multi-purpose certificate utility),
	#							ca (command is a minimal certificate authority (CA) application)							
	#							-in (The input file to read from, or standard input if not specified),
	#							-out (The output file to write to, or standard output if none is specified)
	#							-config (Specify an alternative configuration file)
	#							-extensions (The section to add certificate extensions from),
	#							-extfile (File containing certificate extensions to use).
	# Sign the certificate? [y/n]: y <Enter>
	# 1 out of 1 certificate request certified, commit? [y/n]: y <Enter>
	openssl genrsa -aes256 -out /etc/ssl/private/vsftpd-ptikey.key.old \
	-passout pass:$PASSWORD 2048 &>> $LOG
	echo -e "Chave Privada/Pública criada com sucesso!!!, continuando com o script..."
	#
	openssl rsa -in /etc/ssl/private/vsftpd-ptikey.key.old -out /etc/ssl/private/vsftpd-ptikey.key \
	-passin pass:$PASSWORD &>> $LOG
	rm -v /etc/ssl/private/vsftpd-ptikey.key.old &>> $LOG
	echo -e "Senha da Chave Privada/Pública removida com sucesso!!!, continuando com o script...\n"
	#
	openssl req -new -sha256 -nodes -key /etc/ssl/private/vsftpd-ptikey.key -out /etc/ssl/requests/vsftpd-pticsr.csr \
	-extensions v3_req -config /etc/ssl/vsftpd-ssl.conf
	echo -e "Geração do Certificado CSR feito com sucesso!!!, continuando com o script...\n"
	#
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
echo -e "Verificando a porta do Vsftpd Server, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric)
	netstat -an | grep ':21'
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
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
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1
