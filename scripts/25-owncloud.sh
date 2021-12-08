#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 08/02/2019
# Data de atualização: 27/04/2021
# Versão: 0.09
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do ownCloud 10.4.x
#
# O ownCloud é um sistema de computador mais conhecido como "serviço de armazenamento e sincronização de arquivos". 
# Como tal, ownCloud é muito semelhante ao amplamente usado Dropbox, cuja principal diferença é que ownCloud é gratuito
# e open-source, e permitindo assim qualquer um de instalar e operar sem custo em um servidor privado, sem limite de 
# espaço de armazenamento (com exceção da capacidade do disco rígido) ou o número de clientes conectados.
#
# Informações que serão solicitadas na configuração via Web do ownCloud
# Nome do usuário: admin
# Senha: pti@2018
# Pasta de dados: /var/www/html/own/data
# Usuário do banco de dados: owncloud
# Senha do banco de dados: owncloud
# Nome do banco de dados: owncloud
# Host do banco de dados: localhost: Concluir Configuração
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de instalação do LAMP Server no Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=6EFUu-I3
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
# opção do comando create: create (criação), database (base de dados), base (banco de dados)
# opção do comando create: create (criação), user (usuário), identified by (identificado por - senha do usuário), password (senha)
# opção do comando grant: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/tabelas), to (para), user (usuário)
# identified by (identificado por - senha do usuário), password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou tabela), *.* (todos os bancos/tabelas)
# to (para), user@'%' (usuário @ localhost), identified by (identificado por - senha do usuário), password (senha)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
USER="root"
PASSWORD="pti@2018"
DATABASE="CREATE DATABASE owncloud;"
USERDATABASE="CREATE USER 'owncloud' IDENTIFIED BY 'owncloud';"
GRANTDATABASE="GRANT USAGE ON *.* TO 'owncloud' IDENTIFIED BY 'owncloud';"
GRANTALL="GRANT ALL PRIVILEGES ON owncloud.* TO 'owncloud' IDENTIFIED BY 'owncloud' WITH GRANT OPTION;"
FLUSH="FLUSH PRIVILEGES;"
#
# Declarando a variável de download do ownCloud (Link atualizado no dia 24/11/2020)
RELEASE="https://download.owncloud.org/community/owncloud-10.5.0.tar.bz2"
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
# Verificando se as dependências do ownCloud estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do ownCloud, aguarde... "
	for name in mysql-server mysql-common apache2 php
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
# Script de instalação do ownCloud no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do ownCloud no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do ownCloud acessar a URL: http://`hostname -I | cut -d ' ' -f1`/own/\n"
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
#
echo -e "Instalando o ownCloud, aguarde...\n"
#
echo -e "Habilitando os recursos do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando echo |: faz a função de Enter
	# opção do comando a2dismod: desabilitar módulos do Apache2
	# opção do comando a2enmod: habilitar módulos do Apache2
	echo | a2dismod autoindex &>> $LOG
	a2enmod rewrite &>> $LOG
	a2enmod headers &>> $LOG
	a2enmod env &>> $LOG
	a2enmod dir &>> $LOG
	a2enmod mime &>> $LOG
echo -e "Recursos habilitados com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando as dependências do ownCloud, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install software-properties-common &>> $LOG
	apt -y install php-cli php-common php-mbstring php-gd php-intl php-xml php-mysql php-zip php-curl php-xmlrpc &>> $LOG
	systemctl restart apache2 &>> $LOG
echo -e "Source List criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Fazendo o download e Instalando o ownCloud do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando tar: -j (bzip2), -x (extract), -v (verbose), -f (file)
	# opção do comando chown: -R (recursive), -v (verbose), www-data.www-data (user and group)
	# opção do comando chmod: -R (recursive), -v (verbose), 755 (User=RWX, Group=R-X, Other=R-X)
	# opção do comando mysql: -u (user), -p (password), -e (execute)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	# opção do comando mv: -v (verbose)
	rm -v owncloud.tar.bz2 &>> $LOG
	wget $RELEASE -O owncloud.tar.bz2 &>> $LOG
	tar -jxvf owncloud.tar.bz2 &>> $LOG
	mv -v owncloud/ /var/www/html/own/ &>> $LOG
	chown -Rv www-data:www-data /var/www/html/own/ &>> $LOG
	chmod -Rv 755 /var/www/html/own/ &>> $LOG
echo -e "Download e instalação do ownCloud feito com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Criando o Banco de Dados do ownCloud, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute)
	mysql -u $USER -p$PASSWORD -e "$DATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$USERDATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTDATABASE" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTALL" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG
echo -e "Banco de Dados criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalação do ownCloud feita com Sucesso!!!."
	# script para calcular o tempo gasto (SCRIPT MELHORADO, CORRIGIDO FALHA DE HORA:MINUTO:SEGUNDOS)
	# opção do comando date: +%T (Time)
	HORAFINAL=`date +%T`
	# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second), 
	TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
	# $0 (variável de ambiente do nome do comando)
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1
