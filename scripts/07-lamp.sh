#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Data de criação: 13/10/2021
# Data de atualização: 05/10/2021
# Versão: 0.06
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Apache2 v2.4.x, MySQL v8.0.x, PHP v7.4.x, 
# Perl v5.30.x, Python v2.x e v3.x, PhpMyAdmin v4.9.x
#
# O Servidor HTTP Apache (do inglês Apache HTTP Server) ou Servidor Apache ou HTTP 
# Daemon Apache ou somente Apache, é o servidor web livre criado em 1995 por Rob McCool. 
# É a principal tecnologia da Apache Software Foundation, responsável por mais de uma 
# dezena de projetos envolvendo tecnologias de transmissão via web, processamento de dados 
# e execução de aplicativos distribuídos.
#
# O MySQL é um sistema de gerenciamento de banco de dados (SGBD), que utiliza a linguagem 
# SQL (Linguagem de Consulta Estruturada, do inglês Structured Query Language) como 
# interface. É atualmente um dos sistemas de gerenciamento de bancos de dados mais 
# populares[2] da Oracle Corporation, com mais de 10 milhões de instalações pelo mundo.
#
# PHP (um acrônimo recursivo para "PHP: Hypertext Preprocessor", originalmente Personal 
# Home Page) é uma linguagem interpretada livre, usada originalmente apenas para o 
# desenvolvimento de aplicações presentes e atuantes no lado do servidor, capazes de gerar 
# conteúdo dinâmico na World Wide Web.
#
# Perl é usada em aplicações de CGI para a Web, para administração de sistemas linux e 
# por várias aplicações que necessitam de facilidade de manipulação de strings.
#
# Python é uma linguagem de programação de alto nível, interpretada de script, imperativa, 
# orientada a objetos, funcional, de tipagem dinâmica e forte. Foi lançada por Guido van 
# Rossum em 1991. Atualmente,possui um modelo de desenvolvimento comunitário, aberto e 
# gerenciado pela organização sem fins lucrativos Python Software Foundation.
#
# Debconf - Sistema de configuração de pacotes Debian
# Site: http://manpages.ubuntu.com/manpages/bionic/man7/debconf.7.html
# Debconf-Set-Selections - insere novos valores no banco de dados debconf
# Site: http://manpages.ubuntu.com/manpages/bionic/man1/debconf-set-selections.1.html
#
# Opção: lamp-server^ Recurso existente no GNU/Ubuntu Server para facilitar a instalação 
# do Servidor LAMP. A opção de circunflexo no final do comando é obrigatória, considerado 
# um meta-carácter de filtragem para a instalação correta de todos os serviços do LAMP.
# Recurso faz parte do software Tasksel: https://help.ubuntu.com/community/Tasksel
#
# O módulo do PHP Mcrypt na versão 7.2 está descontinuado, para fazer sua instalação é 
# recomendado utilizar o comando o Pecl e adicionar o repositório pecl.php.net, a 
# instalação e baseada em compilação do módulo.
#
# OBSERVAÇÃO: Nesse script está sendo feito a instalação do Oracle MySQL, hoje os 
# desenvolvedores estão migrando para o MariaDB, nesse script o mesmo deve ser 
# reconfigurado para instalar e configurar o MariaDB no Ubuntu conforme o comando:
# sudo apt update && sudo apt install mariadb-server mariadb-client mariadb-common
# Instalação do MariaDB será feita no script: lemp.sh
#
# Site Oficial do Projeto Apache2: https://www.apache.org/
# Site Oficial do Projeto Oracle MySQL: https://www.mysql.com/
# Site Oficial do Projeto MariaDB: https://mariadb.org/
# Site Oficial do Projeto PHP: https://www.php.net/
# Site Oficial do Projeto Perl: https://www.perl.org/
# Site Oficial do Projeto Python: https://www.python.org/
# Site Oficial do Projeto PhpMyAdmin: https://www.phpmyadmin.net/
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
# Script de instalação e configuração do LAMP-Server no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable) habilita interpretador, \n = (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação e configuração do LAMP-SERVER no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo APACHE (Apache HTTP Server): TCP 80"
echo -e "Após a instalação do Apache2 acessar a URL: http://$(hostname -I | cut -d ' ' -f1)/"
echo -e "Testar a linguagem HTML acessando a URL: http://$(hostname -I | cut -d ' ' -f1)/teste.html\n"
echo -e "Porta padrão utilizada pelo Oracle MySQL (SGBD): TCP 3306"
echo -e "Após a instalação do MySQL acessar o console: mysql -u root -p (senha: $SENHAMYSQL)\n"
echo -e "PHP (Personal Home Page - PHP: Hypertext Preprocessor)"
echo -e "Após a instalação do PHP acessar a URL: http://$(hostname -I | cut -d ' ' -f1)/phpinfo.php\n"
echo -e "PERL - Linguagem de programação multi-plataforma\n"
echo -e "PYTHON - Linguagem de programação de alto nível\n"
echo -e "PhpMyAdmin - Aplicativo desenvolvido em PHP para administração do MySQL"
echo -e "Após a instalação do PhpMyAdmin acessar a URL: http://$(hostname -I | cut -d ' ' -f1)/phpmyadmin\n"
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
echo -e "Atualizando todo o sistema, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
	apt -y dist-upgrade &>> $LOG
	apt -y full-upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
	apt -y autoclean &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando e Configuração do LAMP-Server, aguarde...\n"
sleep 5
#
echo -e "Configurando as variáveis do Debconf do MySQL para o Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando | (piper): (Conecta a saída padrão com a entrada padrão de outro comando)
	echo "mysql-server-8.0 mysql-server/root_password password $SENHAMYSQL" | debconf-set-selections
	echo "mysql-server-8.0 mysql-server/root_password_again password $AGAIN" | debconf-set-selections
	debconf-show mysql-server-8.0 &>> $LOG
echo -e "Variáveis configuradas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o LAMP-SERVER (Linux, Apache2, MySQL, Php, Perl e Python), aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	# opção do comando ^ (circunflexo): (expressão regular - Casa o começo da linha)
	apt -y install lamp-server^ perl python apt-transport-https &>> $LOG
echo -e "Instalação do LAMP-SERVER feito com sucesso!!!, continuando com o script...\n"
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
	# opção do comando apt: -y (yes), \ (quebra de linha)
	apt -y install phpmyadmin php-bcmath php-mbstring php-pear php-dev php-json \
	libmcrypt-dev pwgen &>> $LOG
echo -e "Instalação do PhpMyAdmin feita com sucesso!!!, continuando com o script...\n"
sleep 5
#				 
echo -e "Instalando a dependência do PHP Mcrypt para da suporte ao PhpMyAdmin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando echo: | = (faz a função de Enter)
	# opção do comando cp: -v (verbose)
	pecl channel-update pecl.php.net &>> $LOG
		echo | pecl install mcrypt &>> $LOG
		cp -v conf/mcrypt.ini /etc/php/7.4/mods-available/ &>> $LOG
	phpenmod mcrypt &>> $LOG
	phpenmod mbstring &>> $LOG
echo -e "Atualização da dependência feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do Apache2 e do PHP, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	mv -v /etc/apache2/apache2.conf /etc/apache2/apache2.conf.old &>> $LOG
	mv -v /etc/apache2/ports.conf /etc/apache2/ports.conf.old &>> $LOG
	cp -v conf/{apache2.conf,ports.conf} /etc/apache2/ &>> $LOG
	cp -v conf/000-default.conf /etc/apache2/sites-available/000-default.conf &>> $LOG
	mv -v /etc/php/7.4/apache2/php.ini /etc/php/7.4/apache2/php.ini.old &>> $LOG
	cp -v conf/php.ini /etc/php/7.4/apache2/php.ini &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração apache2.conf, pressione <Enter> para continuar."
	read
	vim /etc/apache2/apache2.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração ports.conf, pressione <Enter> para continuar."
	read
	vim /etc/apache2/ports.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração 000-default.conf, pressione <Enter> para continuar."
	read
	vim /etc/apache2/sites-available/000-default.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração php.ini, pressione <Enter> para continuar."
	read
	vim /etc/php/7.4/apache2/php.ini
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do Apache2, aguarde..."
	systemctl restart apache2 &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o arquivo de configuração do MySQL, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	mv -v /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.old &>> $LOG
	cp -v conf/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf &>> $LOG
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração mysqld.cnf, pressione <Enter> para continuar."
	read
	vim /etc/mysql/mysql.conf.d/mysqld.cnf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração hosts.allow, pressione <Enter> para continuar."
	read
	vim /etc/hosts.allow
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Permitindo o Root do MySQL se autenticar remotamente, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password) -e (execute), mysql (database)
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATEUSER" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANTALL" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH" mysql &>> $LOG
echo -e "Permissão alterada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do MySQL, aguarde..."
	systemctl restart mysql &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Copiando os arquivos teste.html e phpinfo.php para o diretório raiz, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	# opção do comando chown: -v (verbose), www-data (user), www-data (group)
	cp -v conf/{phpinfo.php,teste.html} /var/www/html/ &>> $LOG
	chown -v www-data.www-data /var/www/html/* &>> $LOG
echo -e "Arquivos copiados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de teste phpinfo.php, pressione <Enter> para continuar."
	read
	vim /var/www/html/phpinfo.php
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de teste teste.html, pressione <Enter> para continuar."
	read
	vim /var/www/html/teste.html
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexão do Apache2 e do MySQL, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:'80,3306' -sTCP:LISTEN
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do LAMP-SERVER feito com Sucesso!!!"
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
