#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 18/04/2021
# Data de atualização: 30/04/2021
# Versão: 0.6
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do Nginx 1.14, MariaDB 10.1, PHP 7.2.x, Perl 5.26.x, Python 2.x/3.x, PhpMyAdmin 4.6.x
#
# LEMP é um grupo de softwares que são usados para exibir páginas ou aplicativos Web dinâmicos escritos em 
# PHP/PERL/PYTHON. Este é um acrônimo de sistema operacional Linux, servidor Web Nginx (se pronuncia “Engine-X)
# Os dados do backend são armazenados no banco de dados MySQL ou MariaDB e o processamento dinâmico é 
# tratado pela linguagem de programação dinâmica PHP.
#
# O Servidor NGINX (lê-se "engine x") é um servidor leve de HTTP, Proxy Reverso e Proxy de E-mail IMAP/POP3. 
# O Nginx consome menos memória que o Apache, pois lida com requisições Web do tipo “event-based web server”; 
# e o Apache é baseado no “process-based server”, podendo trabalhar juntos. É possível diminuir o consumo 
# de memória do Apache, passando as requisições Web primeiro no Nginx, assim, o Apache não precisa servir 
# arquivos estáticos, e pode depender do bom controle de cache feito pelo Nginx.
#
# O MariaDB é um sistema de gerenciamento de banco de dados (SGBD) que surgiu como fork do MySQL, criado 
# pelo próprio fundador do projeto após sua aquisição pela Oracle. A intenção principal do projeto é manter 
# uma alta fidelidade com o MySQL. MariaDB é um avançado substituto para o MySQL e está disponível sob os 
# termos da licença GPL v2. 
#
# PHP (um acrônimo recursivo para "PHP: Hypertext Preprocessor", originalmente Personal Home Page) é uma 
# linguagem interpretada livre, usada originalmente apenas para o desenvolvimento de aplicações presentes 
# e atuantes no lado do servidor, capazes de gerar conteúdo dinâmico na World Wide Web.
#
# FPM (FastCGI Process Manager) é um gerenciador de processos para gerenciar o FastCGI SAPI (Server API) 
# em PHP. O PHP-FPM é um serviço e não um módulo. Este serviço é executado completamente independente do 
# servidor web em um processo à parte e é suportado por qualquer servidor web compatível com FastCGI 
# (Fast Common Gateway Interface).
#
# Perl é usada em aplicações de CGI para a web, para administração de sistemas linux e por várias 
# aplicações que necessitam de facilidade de manipulação de strings.
#
# Python é uma linguagem de programação de alto nível,[5] interpretada de script, imperativa, orientada a 
# objetos, funcional, de tipagem dinâmica e forte. Foi lançada por Guido van Rossum em 1991. Atualmente,
# possui um modelo de desenvolvimento comunitário, aberto e gerenciado pela organização sem fins lucrativos 
# Python Software Foundation.
#
# PhpMyAdmin é um aplicativo web livre e de código aberto desenvolvido em PHP para administração do MySQL 
# ou MariaDB pela Internet. A partir deste sistema é possível criar e remover bases de dados, criar, remover
# e alterar tabelas, inserir, remover e editar campos, executar códigos SQL e manipular campos chaves.
#
# NGINX-1.14 (HTTP Server) -Servidor de Hospedagem de Páginas Web: https://www.nginx.com/
# MARIADB-10.1.x (SGBD) - Sistemas de Gerenciamento de Banco de Dados: https://mariadb.org/
# PHP-7.2 (Personal Home Page - PHP: Hypertext Preprocessor) - Linguagem de Programação Dinâmica para Web: http://www.php.net/
# PERL-5.26 - Linguagem de programação multiplataforma: https://www.perl.org/
# PYTHON-2.7 - Linguagem de programação de alto nível: https://www.python.org/
# PHPMYADMIN-4.6 - Aplicativo desenvolvido em PHP para administração do MariaDB pela Internet: https://www.phpmyadmin.net/
#
# Debconf - Sistema de configuração de pacotes Debian
# Site: http://manpages.ubuntu.com/manpages/bionic/man7/debconf.7.html
# Debconf-Set-Selections - insere novos valores no banco de dados debconf
# Site: http://manpages.ubuntu.com/manpages/bionic/man1/debconf-set-selections.1.html
#
# O módulo do PHP Mcrypt na versão 7.2 está descontinuado, para fazer sua instalação é recomendado utilizar
# o comando o Pecl e adicionar o repositório pecl.php.net, a instalação é baseada em compilação do módulo.
#
# Site oficial: https://www.nginx.com/
# Site oficial: https://mariadb.org/
# Site oficial: https://www.php.net/
# Site oficial: https://pecl.php.net/
# Site oficial: https://www.php.net/manual/pt_BR/install.fpm.php
# Site oficial: https://www.perl.org/
# Site oficial: https://www.python.org/
# Site oficial: https://www.phpmyadmin.net/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de configuração do OpenSSH Server no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=ecuol8Uf1EE
#
# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário e "root", versão do ubuntu e kernel
# opções do comando id: -u (user), opções do comando: lsb_release: -r (release), -s (short), 
# opções do comando uname: -r (kernel release), opções do comando cut: -d (delimiter), -f (fields)
# opção do carácter: | (piper) Conecta a saída padrão com a entrada padrão de outro comando
# opção do shell script: acento crase ` ` = Executa comandos numa subshell, retornando o resultado
# opção do shell script: aspas simples ' ' = Protege uma string completamente (nenhum caractere é especial)
# opção do shell script: aspas duplas " " = Protege uma string, mas reconhece $, \ e ` como especiais
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
KERNEL=$(uname -r | cut -d'.' -f1,2)
#
# Variável do caminho do Log dos Script utilizado nesse curso (VARIÁVEL MELHORADA)
# $0 (variável de ambiente do nome do comando)
# opção do comando | (piper): (Conecta a saída padrão com a entrada padrão de outro comando)
# opções do comando cut: -d (delimiter), -f (fields)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Variáveis de configuração do usuário root e senha do MariaDB para acesso via console e do PhpMyAdmin
USER="root"
PASSWORD="pti@2018"
AGAIN=$PASSWORD
#
# Variáveis de configuração e liberação da conexão remota para o usuário Root do MariaDB
# opções do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou tabela), 
# *.* (todos os bancos/tabelas) to (para), user@'%' (usuário @ localhost), identified by (identificado 
# por - senha do usuário)
# opções do comando UPDATE: user (table mysql), SET Password=PASSWORD (columns), WHERE (condition), User (value)
# opções do comando UPDATE: user (table mysql), SET plugin (columns), WHERE (condition), User (value)
# opção do comando FLUSH: privileges (recarregar as permissões)
GRANTALL="GRANT ALL ON *.* TO $USER@'%' IDENTIFIED BY '$PASSWORD';"
UPDATE1045="UPDATE user SET Password=PASSWORD('$PASSWORD') WHERE User='$USER';"
UPDATE1698="UPDATE user SET plugin='' WHERE User='$USER';"
FLUSH="FLUSH PRIVILEGES;"
#
# Variáveis de configuração do PhpMyAdmin
ADMINUSER=$USER
ADMIN_PASS=$PASSWORD
APP_PASSWORD=$PASSWORD
APP_PASS=$PASSWORD
WEBSERVER="localhost"
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
# Script de instalação do LEMP-Server no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable) habilita interpretador, \n = (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando sleep: 5 (seconds)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo -e "Instalação do LEMP-SERVER no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "NGINX (HTTP Server) - Servidor de Hospedagem de Páginas Web - Porta 80/443"
echo -e "Após a instalação do Nginx acessar a URL: http://`hostname -I | cut -d ' ' -f1`/"
echo -e "Testar a linguagem HTML acessando a URL: http://`hostname -I | cut -d ' ' -f1`/teste.html\n"
echo -e "MariaDB (SGBD) - Sistemas de Gerenciamento de Banco de Dados - Porta 3306"
echo -e "Após a instalação do MariaDB acessar o console: mariadb -u root -p\n"
echo -e "PHP (Personal Home Page - PHP: Hypertext Preprocessor) - Linguagem de Programação Dinâmica para Web"
echo -e "Após a instalação do PHP acessar a URL: http://`hostname -I | cut -d ' ' -f1`/phpinfo.php\n"
echo -e "PERL - Linguagem de programação multi-plataforma\n"
echo -e "PYTHON - Linguagem de programação de alto nível\n"
echo -e "PhpMyAdmin - Aplicativo desenvolvido em PHP para administração do MariaDB pela Internet"
echo -e "Após a instalação do PhpMyAdmin acessar a URL: http://`hostname -I | cut -d ' ' -f1`/phpmyadmin\n"
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
	# opção do comando: &>> (redirecionar a saída padrão)
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
echo -e "Software removidos com Sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configurando as variáveis do Debconf do MariaDB para o Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando | (piper): (Conecta a saída padrão com a entrada padrão de outro comando)
	echo "mariadb-server-10.1 mysql-server/root_password password $PASSWORD" | debconf-set-selections
	echo "mariadb-server-10.1 mysql-server/root_password_again password $AGAIN" | debconf-set-selections
	debconf-show mariadb-server-10.1 &>> $LOG
echo -e "Variáveis configuradas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o LEMP-SERVER, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes), \ (bar left) quebra de linha na opção do apt
	apt -y install nginx mariadb-server mariadb-client mariadb-common php-fpm php-mysql \
	perl python mcrypt apt-transport-https &>> $LOG
echo -e "Instalação do LEMP-SERVER feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando as dependências do PHP do LEMP-SERVER, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes), \ (bar left) quebra de linha na opção do apt
	apt -y install php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc \
	php-zip php-cli php-json php-readline php-imagick php-bcmath php-apcu &>> $LOG
echo -e "Dependências do PHP do LEMP-SERVER feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configurando as variáveis do Debconf do PhpMyAdmin para o Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando | (piper): (Conecta a saída padrão com a entrada padrão de outro comando)
	echo "phpmyadmin phpmyadmin/internal/skip-preseed boolean true" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/app-password-confirm password $APP_PASSWORD" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect $WEBSERVER" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-user string $ADMINUSER" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-pass password $ADMIN_PASS" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/app-pass password $APP_PASS" | debconf-set-selections
	debconf-show phpmyadmin &>> $LOG
echo -e "Variáveis configuradas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o PhpMyAdmin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install phpmyadmin php-mbstring php-gettext php-dev libmcrypt-dev php-pear pwgen &>> $LOG
echo -e "Instalação do PhpMyAdmin feita com sucesso!!!, continuando com o script...\n"
sleep 5
#				 
echo -e "Atualizando as dependências do PHP para o PhpMyAdmin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando echo: | = (faz a função de Enter)
	# opção do comando cp: -v (verbose)
	pecl channel-update pecl.php.net &>> $LOG
	echo | pecl install mcrypt-1.0.1 &>> $LOG
	cp -v conf/mcrypt.ini /etc/php/7.2/mods-available/ &>> $LOG
	phpenmod mcrypt &>> $LOG
	phpenmod mbstring &>> $LOG
echo -e "Atualização das dependências feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Aplicando os Patch de Correção do PhpMyAdmin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/sql.lib.php /usr/share/phpmyadmin/libraries/ &>> $LOG
	cp -v conf/plugin_interface.lib.php /usr/share/phpmyadmin/libraries/ &>> $LOG
echo -e "Patch de correção aplicados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Link Simbólico do PhpMyAdmin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando ln: -v (verbose), -s (symbolic)
	ln -vs /usr/share/phpmyadmin /var/www/html &>> $LOG
echo -e "Link simbólico criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Copiando os arquivos de teste do PHP phpinfo.php e do HTML teste.html, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando chown: -v (verbose), www-data (user), www-data (group)
	cp -v conf/phpinfo.php /var/www/html/phpinfo.php &>> $LOG
	cp -v conf/teste.html /var/www/html/teste.html &>> $LOG
	chown -v www-data.www-data /var/www/html/* &>> $LOG
echo -e "Arquivos copiados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do LEMP-Server e PhpMyAdmin feito com sucesso!!! Pressione <Enter> para continuar."
read
sleep 5
#
echo -e "Atualizando os arquivos de configuração do Nginx, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old &>> $LOG
	cp -v conf/nginx.conf /etc/nginx/nginx.conf &>> $LOG
	cp -v conf/default /etc/nginx/sites-available/default &>> $LOG
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração: nginx.conf, Pressione <Enter> para continuar..."
	# opção do comando sleep: 3 (seconds)
	read
	sleep 3
	vim /etc/nginx/nginx.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração: default, Pressione <Enter> para continuar..."
	# opção do comando sleep: 3 (seconds)
	read
	sleep 3
	vim /etc/nginx/sites-available/default
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do PHP-FPM, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando sleep: 3 (seconds)
	cp -v /etc/php/7.2/fpm/php.ini /etc/php/7.2/fpm/php.ini.old &>> $LOG
	cp -v conf/php.ini /etc/php/7.2/fpm/php.ini &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração: php.ini, Pressione <Enter> para continuar..."
	# opção do comando sleep: 3 (seconds)
	read
	sleep 3
	vim /etc/php/7.2/fpm/php.ini
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando os serviços do PHP-FPM e Nginx, aguarde..."
	systemctl restart php7.2-fpm &>> $LOG
	systemctl restart nginx &>> $LOG
echo -e "Serviços reinicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Permitindo o Root do MariaDB se autenticar remotamente, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password) -e (execute), mysql (database)
	mariadb -u $USER -p$PASSWORD -e "$GRANTALL" mysql &>> $LOG
	mariadb -u $USER -p$PASSWORD -e "$UPDATE1045" mysql &>> $LOG
	mariadb -u $USER -p$PASSWORD -e "$UPDATE1698" mysql &>> $LOG
	mariadb -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG
echo -e "Permissão alterada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o arquivo de configuração do MariaDB, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.old &>> $LOG
	cp -v conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf &>> $LOG
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração: 50-server.cnf, Pressione <Enter> para continuar..."
	# opção do comando sleep: 3 (seconds)
	read
	sleep 3
	vim /etc/mysql/mariadb.conf.d/50-server.cnf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando os serviço do MariaDB, aguarde..."
	systemctl restart mariadb &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de Conexão do Nginx e do MariaDB, aguarde..."
	# opção do comando netstat: a (all), n (numeric)
	# opção do comando grep: ' ' (aspas simples) protege uma string, \| (Escape e opção OU)
	netstat -an | grep '80\|3306'
echo -e "Portas verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do LEMP-SERVER feito com Sucesso!!!"
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
