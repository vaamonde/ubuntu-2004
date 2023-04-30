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
# Data de atualização: 30/04/2023
# Versão: 0.15
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do OpenSSL v1.1.x
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
# Site Oficial do OpenSSL: https://www.openssl.org/
# Manual do OpenSSL: https://man.openbsd.org/openssl.1
# Site Oficial do Certbot (Let's Encrypt): https://certbot.eff.org/
#
# CA (Certificate Authority Trust) Autoridades Certificadoras Validas
# SSL.com: https://www.ssl.com/
# Secured Signing: https://www.securedsigning.com/
# Globalsing: https://www.globalsign.com/
# D-Trust: https://www.d-trust.net/
# Digicert: https://www.digicert.com
# Verisign: https://www.verisign.com/
# Let's Encrypt: https://letsencrypt.org/
#
# Instalação da Autoridade Certificadora CA no Mozilla Firefox (GNU/Linux ou Microsoft Windows)
# Abrir menu de Aplicativo
#	Preferências ou Opções ou Configurações
#		Pesquisar em preferências: Ver certificados
#			Autoridades
#				Importar: pti-ca.crt
#					Yes: Confiar nesta CA para identificar sites
#					Yes: Confiar nesta autoridade certificadora para identificar usuários de email
#					<Ver> Examinar certificado da CA
#					<OK>
#				<OK>
#			Autoridades
#				Bora para Pratica
#					ptispo01ws01.pti.intra
#
# Instalação da Autoridade Certificadora CA no Google Chrome (GNU/Linux)
# chrome://settings/certificates
#	Autoridades
#		Importar: pti-ca.crt
#			Yes: Confiar neste certificado para a identificação de websites.
#			Yes: Confiar neste certificado para identificar usuários de e-mail
#			Yes: Confiar neste certificado para a identificação de criadores de software
#		<OK>
#		org-Bora para Pratica
#			ptispo01ws01.pti.intra
#	chrome://restart
#
# Instalação da Autoridade Certificadora CA no Microsoft Edge (GNU/Linux)
# OBSERVAÇÃO IMPORTANTE: O Microsoft Edge é um navegador baseado no Chromium e usa um 
# armazenamento privado semelhante ao Chromium. O Edge usa um keystore em ~/.pki e você 
# precisa do programa utilitário CertUtil para instalar o certificado no Edge
# Mais informações acesse: https://chromium.googlesource.com/chromium/src/+/master/docs/linux/cert_management.md
# sudo apt update && sudo apt install libnss3-tools
#	certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n BoraParaPratica -i pti-ca.crt
#	certutil -d sql:$HOME/.pki/nssdb -L
# Abrir menu de Aplicativo
#	Configurações
#		Gerenciar Certificados
#			Autoridades
#				Importar
#
# Instalação da Autoridade Certificadora CA no Opera (GNU/Linux)
# OBSERVAÇÃO IMPORTANTE: O navegador Opera utiliza o mesmo gerenciador de Certificado do 
# Google Chrome, se você já importou o certificado no Google Chrome na hora de importar
# o certificado no Navegador Opera a seguinte mensagem de erro aparece para você: 
# Certification Authority Import Error: The file contained one certificate, which was not 
# imported: ptispo01ws01.pti.intra: Certificate already exists.
# Abrir o Menu de Configuração Fácil
#	Ir para as configurações completas do navegador
#		Configurações de pesquisa: certificado
#			Segurança
#				Gerenciar Certificados
#					Autoridades
#						Importar
#							Yes: Confie neste certificado para identificar sites
#							Yes: Confie neste certificado para identificar usuários de e-mail
#							Yes: Confie neste certificado para identificar fabricantes de software
#						<OK>
#					org-Bora para Pratica
#						ptispo01ws01.pti.intra
#
# Instalação da Autoridade Certificadora CA no GNU/Linux (Linux Mint ou Ubuntu)
# Pasta: Download
#		Abrir como Root (Botão direito do Mouse: Abrir como root)
#			Copiar: pti-ca.crt
#			Para: /usr/local/share/ca-certificates/
#		Abrir o Terminal como Root (Botão direito do Mouse: Abrir no Terminal)
#			update-ca-certificates
#			ls -lha /etc/ssl/certs/pti-ca.pem
#
# Instalação da Autoridade Certificadora CA no Microsoft Windows (10 ou 11)
# Pasta: Download
#		pti-ca.crt (clicar duas vezes em cima do certificado)
#			Abrir
#				Instalar Certificado...
#					Assistente para Importação de Certificados
#						Máquina Local <Avançar>
#							Deseja permitir que este aplicativo faça alterações no seu dispositivo? <sim>
#								Colocar todos os certificados no repositório a seguir
#									Repositório de Certificados <Procurar>
#										Autoridades de Certificação Raiz Confiáveis <OK>
#										<Avançar>
#										<Concluir>
#										<OK>
#										<OK>
#
# Pesquisa do Windows
#	Gerenciar Certificados de Computador <Sim>
#		Autoridades de Certificação Raiz Confiáveis
#			Certificados
#				Emitido para:
#					ptispo01ws01.pti.intra
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
	for name in $SSLDEPCA
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
echo -e "Configuração do OpenSSL CA no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "URL de Download da Autoridade Certificadora CA: http://$(hostname -d | cut -d' ' -f1)/download\n"
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
echo -e "Iniciando a Configuração da Autoridade Certificadora CA, aguarde...\n"
sleep 5
#
echo -e "Criando a estrutura de diretórios da CA e dos Certificados, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	mkdir -v /etc/ssl/{newcerts,certs,crl,private,requests} &>> $LOG
echo -e "Estrutura de diretórios criada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração da CA, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão adicionando)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	touch /etc/ssl/{index.txt,index.txt.attr} &>> $LOG
	echo "1234" > /etc/ssl/serial
	cp -v conf/ssl/ca.conf /etc/ssl/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Chave Raiz de: $BITS bits da CA, senha padrão: $PASSPHRASE, aguarde..." 
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opções do comando openssl: 
	# genrsa (command generates an RSA private key),
	# -criptokey (Encrypt the private key with the AES, CAMELLIA, DES, triple DES or the IDEA ciphers)
	# -out (The output file to write to, or standard output if not specified), 
	# -passout (The output file password source), 
	# pass: (The actual password is password), 
	# bits (The size of the private key to generate in bits)
	#
	openssl genrsa -$CRIPTOKEY -out /etc/ssl/private/$DOMINIONETBIOS-ca.key.old -passout pass:$PASSPHRASE $BITS &>> $LOG
echo -e "Chave Raiz da CA criada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo a senha da Chave Raiz da CA, senha padrão: $PASSPHRASE, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# rsa (command processes RSA keys),
	# -in (The input file to read from, or standard input if not specified),
	# -out (The output file to write to, or standard output if not specified),
	# -passin (The key password source),
	# pass: (The actual password is password)
	# opção do comando rm: -v (verbose)
	#
	openssl rsa -in /etc/ssl/private/$DOMINIONETBIOS-ca.key.old -out /etc/ssl/private/$DOMINIONETBIOS-ca.key \
	-passin pass:$PASSPHRASE &>> $LOG
	rm -v /etc/ssl/private/$DOMINIONETBIOS-ca.key.old &>> $LOG
echo -e "Senha da Chave Raiz da CA removida com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o arquivo de Chave Raiz da CA, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# rsa (command processes RSA keys), 
	# -noout (Do not output the encoded version of the key), 
	# -modulus (Print the value of the modulus of the key), 
	# -in (The input file to read from, or standard input if not specified), 
	# md5 (The message digest to use MD5 checksums)
	#
	openssl rsa -noout -modulus -in /etc/ssl/private/$DOMINIONETBIOS-ca.key | openssl md5 &>> $LOG
echo -e "Arquivo de Chave Raiz da CA verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração ca.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/ssl/ca.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o arquivo CSR (Certificate Signing Request), confirme as mensagens do arquivo: ca.conf, aguarde...\n"
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
	# 	Common Name (eg, server FQDN or YOUR name): ptispo01ws01.pti.intra <-- pressione <Enter>
	# 	Email Address: pti@pti.intra <-- pressione <Enter>
	#
	openssl req -new -$CRIPTOCERT -nodes -key /etc/ssl/private/$DOMINIONETBIOS-ca.key -out \
	/etc/ssl/requests/$DOMINIONETBIOS-ca.csr -config /etc/ssl/ca.conf
	echo
echo -e "Criação do arquivo CSR feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o arquivo CRT (Certificate Request Trust), confirme as mensagens do arquivo: ca.conf, aguarde...\n"
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# req (command primarily creates and processes certificate requests in PKCS#10 format),
	# -new (Generate a new certificate request),
	# -x509 (Output a self-signed certificate instead of a certificate request),
	# -criptocert (The message digest to sign the request with)
	# -days (Specify the number of days to certify the certificate for),
	# -in (The input file to read from, or standard input if not specified)
	# -key (The file to read the private key from),
	# -out (The output file to write to, or standard output if not specified),
	# -set_serial (Serial number to use when outputting a self-signed certificate),
	# -extensions (Specify alternative sections to include certificate extensions),
	# -config (Specify an alternative configuration file).
	#
	# Criando o arquivo CRT, mensagens que serão solicitadas na criação da CA
	# 	Country Name (2 letter code): BR <-- pressione <Enter>
	# 	State or Province Name (full name): Brasil <-- pressione <Enter>
	# 	Locality Name (eg, city): Sao Paulo <-- pressione <Enter>
	# 	Organization Name (eg, company): Bora para Pratica <-- pressione <Enter>
	# 	Organization Unit Name (eg, section): Procedimentos em TI <-- pressione <Enter>
	# 	Common Name (eg, server FQDN or YOUR name): pti.intra <-- pressione <Enter>
	# 	Email Address: pti@pti.intra <-- pressione <Enter>
	#
	openssl req -new -x509 -$CRIPTOCERT -days 3650 -in /etc/ssl/requests/$DOMINIONETBIOS-ca.csr -key \
	/etc/ssl/private/$DOMINIONETBIOS-ca.key -out /etc/ssl/newcerts/$DOMINIONETBIOS-ca.crt -config /etc/ssl/ca.conf
	echo
echo -e "Criação do arquivo CRT feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o arquivo CRT (Certificate Request Trust) da CA, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# x509 (command is a multi-purpose certificate utility), 
	# -noout (Do not output the encoded version of the request), 
	# -modulus (Print the value of the modulus of the public key contained in the certificate),
	# -text (Print the full certificate in text form), 
	# -in (The input file to read from, or standard input if not specified), 
	# md5 (The message digest to use MD5 checksums)
	#
	openssl x509 -noout -modulus -in /etc/ssl/newcerts/$DOMINIONETBIOS-ca.crt | openssl md5 &>> $LOG
	openssl x509 -noout -text -in /etc/ssl/newcerts/$DOMINIONETBIOS-ca.crt &>> $LOG
echo -e "Arquivo CRT da CA verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o certificado CRT (Certificate Request Trust) da CA no Ubuntu, aguarde..."
echo -e "OBSERVAÇÃO: será criado o arquivo PEM (Privacy Enhanced Mail) no diretório de certificados de Ubuntu"
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando ls: -l (list), -h (human-readable), -a (all)
	cp -v /etc/ssl/newcerts/$DOMINIONETBIOS-ca.crt /usr/local/share/ca-certificates/ &>> $LOG
	update-ca-certificates &>> $LOG
	ls -lha /etc/ssl/certs/$DOMINIONETBIOS* &>> $LOG
echo -e "Certificado CRT da CA instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o diretório de Download para baixar a Autoridade Certificadora CA, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando chown: -v (verbose), www-data (user), www-data (group)
	# opção do comando cp: -v (verbose)
	mkdir -v $DOWNLOADCERT &>> $LOG
	chown -v www-data:www-data $DOWNLOADCERT &>> $LOG
	cp -v /etc/ssl/newcerts/$DOMINIONETBIOS-ca.crt $DOWNLOADCERT &>> $LOG
echo -e "Diretório criado com sucesso!!!, continuando com o script...\n"
sleep 2
#
echo -e "Verificando o diretório de download: http://$(hostname -d | cut -d' ' -f1)/download/, aguarde..."
	tree $DOWNLOADCERT
echo -e "Diretório verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a versão do serviço instalado, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "OpenSSL..: $(dpkg-query -W -f '${version}\n' openssl)"
echo -e "Versão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configuração da Autoridade Certificadora CA feita com Sucesso!!!."
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
