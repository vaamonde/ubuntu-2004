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
# Data de atualização: 12/01/2022
# Versão: 0.10
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
# Site Oficial do Projeto: https://www.openssl.org/
# Manual do OpenSSL: https://man.openbsd.org/openssl.1
#
# Instalação da Autoridade Certificadora CA no Mozilla Firefox (GNU/Linux ou Microsoft Windows)
# Abrir menu de Aplicativo
#	Preferências ou Opções ou Configurações
#		Pesquisar em preferências: Ver certificados
#			Autoridades
#				Importar: ca-pticrt.crt
#					Yes: Confiar nesta CA para identificar sites
#					Yes: Confiar nesta autoridade certificadora para identificar usuários de email
#				Bora para Pratica
#					ptispo01ws01.pti.intra
#
# Instalação da Autoridade Certificadora CA no Google Chrome (GNU/Linux)
# chrome://settings/certificates
#	Autoridades
#		Importar: ca-pticrt.crt
#			Yes: Confiar neste certificado para a identificação de websites.
#			Yes: Confiar neste certificado para identificar usuários de e-mail
#			Yes: Confiar neste certificado para a identificação de criadores de software
#		org-Bora para Pratica
#			ptispo01ws01.pti.intra
#	chrome://restart
#
# Instalação da Autoridade Certificadora CA no Microsoft Edge (GNU/Linux)
# Abrir menu de Aplicativo
#	Configurações
#		Gerenciar Certificados
#			Autoridades
#				Importar
#
# Instalação da Autoridade Certificadora CA no Opera (GNU/Linux)
# Abrir o Easy Setup
#	Go to full browser settings
#		Search settings: manage certificates
#			Security
#				Manage Certificates
#					Authorities
#						Imports

# Instalação da Autoridade Certificadora CA no GNU/Linux
# Pasta: Download
#		Abrir como Root (Botão direito do Mouse: Abrir como root)
#			Copiar: ca-pticrt.crt
#			Para: /usr/local/share/ca-certificates/
#		Terminal
#			sudo update-ca-certificates
#
# Instalação da Autoridade Certificadora CA no Microsoft Windows
# Pasta: Download
#		ca-pticrt.crt (clicar duas vezes em cima do certificado)
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
			echo -en "Recomendo utilizar o script: 07-lamp.sh para resolver as dependências."
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
echo -e "Configuração do OpenSSL no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Download da Autoridade Certificadora CA na URL: http://www.$(hostname -d | cut -d' ' -f1)/download\n"
echo -e "Depois de executar a instalação da CA no GNU/Linux e no Windows, testar o acesso seguro abaixo.\n"
echo -e "Confirmar o acesso com o Endereço IPv4 na URL: https://$(hostname -I | cut -d' ' -f1)/"
echo -e "Confirmar o acesso com o Nome CNAME na URL: https://www.$(hostname -d | cut -d' ' -f1)/"
echo -e "Confirmar o acesso com o Nome Domínio na URL: https://$(hostname -d | cut -d' ' -f1)/"
echo -e "Confirmar o acesso com o Nome FQDN na URL: https://$(hostname -A | cut -d' ' -f1)/\n"
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
echo -e "Iniciando a Configuração do OpenSSL no Apache2, aguarde...\n"
sleep 5
#
echo -e "Criando a estrutura de diretórios do CA e dos Certificados, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	mkdir -v /etc/ssl/{newcerts,certs,crl,private,requests} &>> $LOG
echo -e "Estrutura de diretórios criada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração da CA e dos Certificados, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão adicionando)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	touch /etc/ssl/{index.txt,index.txt.attr} &>> $LOG
	echo "1234" > /etc/ssl/serial
	cp -v conf/ssl/{pti-ca.conf,pti-ssl.conf} /etc/ssl/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Primeira Etapa: Criando a CA (Certificate Authority) Interna, aguarde...\n"
sleep 5
#
echo -e "Criando o Chave Raiz de $BITS bits da CA, senha padrão: $PASSPHRASE, aguarde..." 
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
	openssl genrsa -$CRIPTOKEY -out /etc/ssl/private/ca-ptikey.key.old -passout pass:$PASSPHRASE $BITS &>> $LOG
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
	openssl rsa -in /etc/ssl/private/ca-ptikey.key.old -out /etc/ssl/private/ca-ptikey.key \
	-passin pass:$PASSPHRASE &>> $LOG
	rm -v /etc/ssl/private/ca-ptikey.key.old &>> $LOG
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
	openssl rsa -noout -modulus -in /etc/ssl/private/ca-ptikey.key | openssl md5 &>> $LOG
echo -e "Arquivo de Chave Raiz da CA verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração da CA pti-ca.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/ssl/pti-ca.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o arquivo CSR (Certificate Signing Request), confirme as mensagens do arquivo: pti-ca.conf, aguarde...\n"
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
	openssl req -new -$CRIPTOCERT -nodes -key /etc/ssl/private/ca-ptikey.key -out \
	/etc/ssl/requests/ca-pticsr.csr -config /etc/ssl/pti-ca.conf
	echo
echo -e "Criação do arquivo CSR feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o arquivo CRT (Certificate Request Trust), confirme as mensagens do arquivo: pti-ca.conf, aguarde...\n"
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
	openssl req -new -x509 -$CRIPTOCERT -days 3650 -in /etc/ssl/requests/ca-pticsr.csr -key \
	/etc/ssl/private/ca-ptikey.key -out /etc/ssl/newcerts/ca-pticrt.crt -config /etc/ssl/pti-ca.conf
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
	openssl x509 -noout -modulus -in /etc/ssl/newcerts/ca-pticrt.crt | openssl md5 &>> $LOG
	openssl x509 -noout -text -in /etc/ssl/newcerts/ca-pticrt.crt &>> $LOG
echo -e "Arquivo CRT da CA verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando o arquivo CRT (Certificate Request Trust) da CA, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando ls: -l (list), -h (human-readable), -a (all)
	cp -v /etc/ssl/newcerts/ca-pticrt.crt /usr/local/share/ca-certificates/ &>> $LOG
	update-ca-certificates &>> $LOG
	ls -lha /etc/ssl/certs/ca-pticrt* &>> $LOG
echo -e "Arquivo CRT da CA habilitado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Segunda Etapa: Criando o Certificado de Servidor Assinado do Apache2, aguarde...\n"
sleep 5
#
echo -e "Criando o Chave Privada de $BITS do Apache2, senha padrão: $PASSPHRASE, aguarde..." 
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# genrsa (command generates an RSA private key),
	# -criptokey (Encrypt the private key with the AES, CAMELLIA, DES, triple DES or the IDEA ciphers)
	# -out (The output file to write to, or standard output if not specified), 
	# -passout (The output file password source), 
	# pass: (The actual password is password), 
	# bits (The size of the private key to generate in bits)
	#
	openssl genrsa -$CRIPTOKEY -out /etc/ssl/private/apache2-ptikey.key.old -passout pass:$PASSPHRASE $BITS &>> $LOG
echo -e "Chave Privada do Apache2 criada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo a senha da Chave Privada do Apache2, senha padrão: $PASSPHRASE, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# rsa (command processes RSA keys),
	# -in (The input file to read from, or standard input if not specified),
	# -out (The output file to write to, or standard output if not specified),
	# -passin (The key password source),
	# pass: (The actual password is password)
	# opção do comando rm: -v (verbose)
	#
	openssl rsa -in /etc/ssl/private/apache2-ptikey.key.old -out /etc/ssl/private/apache2-ptikey.key \
	-passin pass:$PASSPHRASE &>> $LOG
	rm -v /etc/ssl/private/apache2-ptikey.key.old &>> $LOG
echo -e "Senha da Chave Privada do Apache2 removida com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o arquivo de Chave Privada do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# rsa (command processes RSA keys), 
	# -noout (Do not output the encoded version of the key), 
	# -modulus (Print the value of the modulus of the key), 
	# -in (The input file to read from, or standard input if not specified), 
	# md5 (The message digest to use MD5 checksums)
	#
	openssl rsa -noout -modulus -in /etc/ssl/private/apache2-ptikey.key | openssl md5 &>> $LOG
echo -e "Arquivo de Chave Privada do Apache2 verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo configuração do Certificado do Apache2 pti-ssl.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/ssl/pti-ssl.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o arquivo CSR (Certificate Signing Request), confirme as mensagens do arquivo: pti-ssl.conf, aguarde...\n"
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
	openssl req -new -$CRIPTOCERT -nodes -key /etc/ssl/private/apache2-ptikey.key -out \
	/etc/ssl/requests/apache2-pticsr.csr -extensions v3_req -config /etc/ssl/pti-ssl.conf
	echo
echo -e "Criação do arquivo CSR feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o arquivo CSR (Certificate Signing Request) do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# req (command primarily creates and processes certificate requests in PKCS#10 format), 
	# -noout (Do not output the encoded version of the request), 
	# -text (Print the certificate request in plain text), 
	# -in (The input file to read a request from, or standard input if not specified)
	#
	openssl req -noout -text -in /etc/ssl/requests/apache2-pticsr.csr &>> $LOG
echo -e "Arquivo CSR verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o certificado assinado CRT (Certificate Request Trust), do Apache2, aguarde...\n"
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
	# -CAcreatesrial (Create the CA serial number file if it does not exist instead of generating an error),
	# -out (The output file to write to, or standard output if none is specified)
	# -config (Specify an alternative configuration file)
	# -extensions (The section to add certificate extensions from),
	# -extfile (File containing certificate extensions to use).
	#
	# Sign the certificate? [y/n]: y <Enter>
	# 1 out of 1 certificate request certified, commit? [y/n]: y <Enter>
	#
	# OPÇÃO DE ASSINATURA DO ARQUIVO CRT SEM UTILIZAR O WIZARD DO CA, CÓDIGO APENAS DE DEMONSTRAÇÃO
	# openssl x509 -req -days 3650 -$CRIPTOCERT -in /etc/ssl/requests/apache2-pticsr.csr -CA \
	# /etc/ssl/newcerts/ca-pticrt.crt -CAkey /etc/ssl/private/ca-ptikey.key -CAcreateserial \
	# -out /etc/ssl/newcerts/apache2-pticrt.crt -extensions v3_req -extfile /etc/ssl/pti-ssl.conf &>> $LOG
	#
	openssl ca -in /etc/ssl/requests/apache2-pticsr.csr -out /etc/ssl/newcerts/apache2-pticrt.crt \
	-config /etc/ssl/pti-ca.conf -extensions v3_req -extfile /etc/ssl/pti-ssl.conf
	echo
echo -e "Criação do certificado assinado CRT do Apache2 feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o arquivo CRT (Certificate Request Trust) do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando openssl: 
	# x509 (command is a multi-purpose certificate utility), 
	# -noout (Do not output the encoded version of the request),
	# -text (Print the full certificate in text form), 
	# -modulus (Print the value of the modulus of the public key contained in the certificate), 
	# -in (he input file to read from, or standard input if not specified), 
	# md5 (The message digest to use MD5 checksums)
	#
	openssl x509 -noout -modulus -in /etc/ssl/newcerts/apache2-pticrt.crt | openssl md5 &>> $LOG
	openssl x509 -noout -text -in /etc/ssl/newcerts/apache2-pticrt.crt &>> $LOG
	cat /etc/ssl/index.txt &>> $LOG
	cat /etc/ssl/serial &>> $LOG
echo -e "Arquivo CRT do Apache2 verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Terceira Etapa: Configurando o suporte TLS/SSL HTTPS no Apache2, aguarde...\n"
sleep 5
#
echo -e "Atualizando o arquivo de configuração do Apache2 HTTPS, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	mv -v /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.old &>> $LOG
	cp -v conf/lamp/default-ssl.conf /etc/apache2/sites-available/ &>> $LOG
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração default-ssl.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/apache2/sites-available/default-ssl.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o diretório de Download para baixar a Unidade Certificadora CA, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando chown: -v (verbose), www-data (user), www-data (group)
	# opção do comando cp: -v (verbose)
	mkdir -v $DOWNLOADCERT &>> $LOG
	chown -v www-data:www-data $DOWNLOADCERT &>> $LOG
	cp -v /etc/ssl/newcerts/ca-pticrt.crt $DOWNLOADCERT &>> $LOG
echo -e "Diretório criado com sucesso!!!, continuando com o script...\n"
sleep 2
#
echo -e "Verificando o diretório de download: http://$(hostname -d | cut -d' ' -f1)/download/, aguarde..."
	tree $DOWNLOADCERT
echo -e "Diretório verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando o suporte ao TLS/SSL e o Site HTTPS do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	a2enmod ssl &>> $LOG
	a2enmod headers &>> $LOG
	a2ensite default-ssl &>> $LOG
	apache2ctl configtest &>> $LOG
echo -e "Site HTTPS do Apache2 habilitado com sucesso!!!, continuando com o script...\n"
sleep 2
#
echo -e "Reinicializando o serviço do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart apache2 &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do Apache2, aguarde..."
	echo -e "Apache2: $(systemctl status apache2 | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Apache2, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:'443' -sTCP:LISTEN
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Testando o Certificado TLS/SSL do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando echo: | (piper, faz a função de Enter no comando)
	# opções do comando openssl: 
	# s_client (command implements a generic SSL/TLS client which connects to a remote host using SSL/TLS)
	# -connect (The host and port to connect to)
	# -servername (Include the TLS Server Name Indication (SNI) extension in the ClientHello message)
	# -showcerts (Display the whole server certificate chain: normally only the server certificate itself is displayed)
	#
	echo | openssl s_client -connect localhost:443 -servername www.$DOMINIOSERVER -showcerts &>> $LOG
echo -e "Certificado do Apache2 testado sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configuração do OpenSSL e TLS/SSL do Apache2 feita com Sucesso!!!."
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
