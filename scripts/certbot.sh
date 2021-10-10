#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 28/05/2021
# Data de atualização: 28/05/2021
# Versão: 0.01
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do Certbot Let's Encrypt 1.x.x e Apache2 2.4.x
#
# O Servidor HTTP Apache (do inglês Apache HTTP Server) ou Servidor Apache ou HTTP Daemon Apache ou somente 
# Apache, é o servidor web livre criado em 1995 por Rob McCool. É a principal tecnologia da Apache Software 
# Foundation, responsável por mais de uma dezena de projetos envolvendo tecnologias de transmissão via web, 
# processamento de dados e execução de aplicativos distribuídos.
#
# Arquivos de virtual host são arquivos que especificam a configuração real do nosso virtual host e determina 
# como o servidor web Apache irá responder às várias requisições de domínio.
#
# O Certbot é uma ferramenta de software de código aberto gratuita para usar certificados Let’s Encrypt 
# automaticamente em sites administrados manualmente com suporte a páginas HTTPS em sistemas de hospedagem 
# de páginas web utilizando o Apache2 ou NGINX.
#
# Site oficial do Projeto: https://www.apache.org/
# Site Oficial do Projeto: https://certbot.eff.org/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de configuração do OpenSSH no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=ecuol8Uf1EE&t
# Vídeo de instalação do LAMP Server no Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=6EFUu-I3
# Vídeo de instalação do Bind9 DNS e ISC DHCP Server no Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=NvD9Vchsvbk
#
# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário e "root", versão do ubuntu e kernel
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
# Declarando as variáveis de PPA do Certbot e Domínio para a criação do certificado
PPA="ppa:certbot/certbot"
D1="pti.intra"
D2="www.pti.intra"
D3="ptispo01ws01.pti.intra"
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
# Verificando se as dependências do Certbot estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Certbot, aguarde... "
	for name in openssl apache2 bind9
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
			echo -en "Recomendo utilizar o script: lamp.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: dnsdhcp.sh para resolver as dependências."
            exit 1; 
            }
		sleep 5
#
# Script de configuração do Virtual Host e Certbot no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address), -A (all FQDN name), -d (domain)
# opções do comando cut: -d (delimiter), -f (fields)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação e Configuração do Certbot e Apache Virtual Host no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a configuração do Certbot no Apache2 acessar a URL: https://`hostname -I | cut -d' ' -f1`/"
echo -e "Confirmar o acesso com o Nome FQDN na URL: https://`hostname -A | cut -d' ' -f1`/"
echo -e "Confirmar o acesso com o Nome Domínio na URL: https://`hostname -d | cut -d' ' -f1`/"
echo -e "Confirmar o acesso com o Nome CNAME na URL: https://www.`hostname -d | cut -d' ' -f1`/\n"S
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
echo -e "Instalação e configuração do Certbot e criação do Virtual Host, aguarde...\n"
#
echo -e "Adicionando o PPA do Certbot, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	echo | add-apt-repository $PPA &>> $LOG
	apt update &>> $LOG
echo -e "PPA do Certbot adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Certbot com suporte ao Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install python-certbot-apache &>> $LOG
echo -e "Certbot instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Virtual Host do Domínio pti.intra no Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando chown: -R (recursive), -v (verbose), www-data (user), www-data (group)
	# opção do comando chmod: -R (recursive), -v (verbose), 755 (User=RWX,Group=R-X,Other=R-X)
	# opção do comando cp: -v (verbose)
	mkdir -v /var/www/html/pti.intra &>> $LOG
	chown -Rv www-data:www-data /var/www/html/pti.intra &>> $LOG
	chmod -Rv 755 /var/www/html/pti.intra &>> $LOG
	cp -v conf/pti-intra.conf /etc/apache2/sites-available/pti-intra.conf &>> $LOG
echo -e "Virtual Host criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo do Virtual Host do Apache2 pti-intra.conf, Pressione <Enter> para continuar."
	read
	vim /etc/apache2/sites-available/pti-intra.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando o Virtual Host do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	a2ensite pti-intra.conf &>> $LOG
	a2dissite 000-default.conf &>> $LOG
	apache2ctl configtest &>> $LOG
echo -e "Virtual Host do Apache2 habilitado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart apache2 &>> $LOG
	systemctl reload apache2 &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Certificado do Certbot para suportar o HTTPS no Virtual Host, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# Informações que serão solicitadas pelo Certbot
	# 01. Enter email address (used for urgent renewal and security notices) (Enter 'c' to cancel): seuemail <Enter>
	# 02. Please read the Terms of Service at: A <Enter>
	# 03. Would you be willing to share your email address with the Electronic Frontier Foundation: Y <Enter>
	# 04. 
	certbot --apache -d $D1 -d $D2 -d $D3
echo -e "Certificado criado com sucesso!!!, continuando com o script...\n"
sleep 2
#
echo -e "Editando o arquivo de atualização do Certificado do Certbot, Pressione <Enter> para continuar."
	read
	#vim /etc/cron.d/
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexões do Apache2 HTTP e HTTPS, aguarde..."
	# opção do comando netstat: a (all), n (numeric)
	# opção do comando grep: -i (ignore case)
	netstat -an | grep ':80\|:443'
echo -e "Portas verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#	
echo -e "Configuração do Certbot e do Apache Virtual Host feita com Sucesso!!!."
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
