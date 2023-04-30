#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 18/10/2021
# Data de atualização: 21/07/2022
# Versão: 0.19
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Wordpress v6.0.x
#
# WordPress: é um sistema livre e aberto de gestão de conteúdo para internet (do inglês: 
# Content Management System - CMS), baseado em PHP com banco de dados MySQL, executado em 
# um servidor interpretador, voltado principalmente para a criação de páginas eletrônicas 
# (sites) e blogs online. Criado a partir do extinto b2/cafelog, por Ryan Boren e Matthew 
# Mullenweg, e distribuído gratuitamente sob a GNU General Public License.
#
# Site oficial do Projeto Wordpress: https://wordpress.org/
#
# Soluções Open Source de CMS
# Site Oficial do Projeto Joomla: https://www.joomla.org/
# Site Oficial do Projeto Drupal: https://www.drupal.org/
#
# Informações que serão solicitadas na configuração via Web do WordPress
# URL: https://wp.pti.intra
# 	Português do Brasil: Continuar;
# 	Informação necessária
#		Título do site: Bora para Prática;
#		Nome de usuário: admin;
#		Senha: pti@2018;
#		Confirme a senha: Confirmar o uso de uma senha fraca;
#		O seu e-mail: admin@pti.intra; 
#		<Instalar WordPress>.
#
# Configurações Básicas do Wordpress e Instalação de Plugins
# URL: https://wp.pti.intra/wp-login.php
#
# Indicação de Temas e Plugins utilizados pelos Docentes/Professores e Profissional de TI:
# José de Assis: 
#	Linkedin: https://www.linkedin.com/in/professorjosedeassis/
#	Github..: https://github.com/professorjosedeassis
#	YouTUBE.: https://www.youtube.com/c/RoboticapraticaBr
# Sirlene Sanches: 
#	Linkedin: https://www.linkedin.com/in/sirlene-sanches/
# Tales Wallef: 
#	Linkedin: https://www.linkedin.com/in/tallis-wallef-330508166/
#
# Instalação do Tema: Astra Child
# Aparência
#	Temas
#		Adicionar novo
#			Pesquisar temas: Astra
#				Astra: Instalar
#				Astra: Ativar
#
# Instalação do Plugins:
# Plugins
#	Adicionar novo
#		Pesquisar plugins: 
#			Companion auto update: atualiza automaticamente os plugins e temas mantendo o seu site mais seguro;
#				Instalar Agora
#				Ativar
#			EWWW image optimizer: otimizador de imagens existentes no Wordpress;
#				Instalar Agora
#				Ativar
#			Imsanity: Redimensione automaticamente grandes uploads de imagens com o Imsanity;
#				Instalar Agora
#				Ativar
#			Microthemer: Um editor visual leve e poderoso para personalizar o estilo CSS de qualquer aspecto do seu site;
#				Instalar Agora
#				Ativar
#			Astra widgets: O plugin Astra Widgets pode ser instalado como qualquer outro plugin WordPress;
#				Instalar Agora
#				Ativar
#			Gutenberg: “editor de blocos” que apresenta uma abordagem modular para modificar todo o seu site.
#				Instalar Agora
#				Ativar
#			Wordfence Security: inclui um firewall de endpoint e um scanner de malware que foram construídos para proteger o WordPress.
#				Instalar Agora
#				Ativar
#					Email: admin@pti.intra
#					Join Wordpress security? NO
#					License: Yes <Continue>
#					No Thanks
#			W3 Total Cache: melhora o SEO, experiência geral do usuário do seu site, aumentando o desempenho do site e reduz os tempos de carregamento.
#				Instalar Agora
#				Ativar
#			Yoast SEO: otimização de mecanismos de pesquisa para WordPress
#				Instalar Agora
#				Ativar
#					Skip
#
# Utilização do FTP Client no GNU/Linux ou Microsoft Windows
#	Cliente de FTP FileZilla
#			Host...: ftp.pti.intra
#			Usuário: wordpress
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
# Verificando se as dependências do Wordpress estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Wordpress, aguarde... "
	for name in $WORDPRESSDEP
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
			echo -en "Recomendo utilizar o script: 09-vsftpd.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 11-A-openssl-ca.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 11-B-openssl-apache.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 11-C-openssl-vsftpd.sh para resolver as dependências."
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
# Script de instalação do Wordpress no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable) habilita interpretador, \n = (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Wordpress no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Após a instalação do Wordpress acessar a URL: https://wp.$(hostname -d | cut -d' ' -f1)/\n"
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
	# opção do comando: &>> (redirecionar a saída padrão)
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
echo -e "Iniciando a Instalação e Configuração do Wordpress no Apache2, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do Wordpress, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $WORDPRESSDEPINSTALL &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do Wordpress do site oficial PT-BR, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output-document)
	rm -v wordpress.zip salt.key &>> $LOG
	wget -O wordpress.zip $WORDPRESS &>> $LOG
	wget -O salt.key $WORDPRESSSALT &>> $LOG
echo -e "Download do Wordpress feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Descompactando o Wordpress, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	unzip wordpress.zip &>> $LOG
echo -e "Descompactação feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Copiando os arquivos do Wordpress para site padrão do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	mv -v wordpress/ $PATHWORDPRESS &>> $LOG
	cp -v conf/wordpress/htaccess $PATHWORDPRESS/.htaccess &>> $LOG
	cp -v conf/wordpress/wp-config.php $PATHWORDPRESS &>> $LOG
	cp -v conf/wordpress/wordpress.conf /etc/apache2/sites-available/ &>> $LOG
echo -e "Arquivos copiados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Aplicando as informações do Salt no arquivo wp-config.php, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando sed: 64 (line), r (filename)
	# opção do comando cp: -v (verbose)
	sed '64r salt.key' $PATHWORDPRESS/wp-config.php > /tmp/wp-config.php
	cp -v $PATHWORDPRESS/wp-config.php $PATHWORDPRESS/wp-config-semsalt.php &>> $LOG
	cp -v /tmp/wp-config.php $PATHWORDPRESS &>> $LOG
echo -e "Informações de Salt aplicadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Alterando as permissões dos arquivos e diretórios do Wordpress, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando chown: -R (recursive), -f (silent), -v (verbose), www-data (user), www-data (group)
	# opção do comando find: . (path), -type d (directory), , type f (file), -exec (execute command)
	# opção do comando chmod: -v (verbose), 755 (Dono=RWX,Grupo=R-X,Outros=R-X)
	# opção do comando chmod: -v (verbose), 644 (Dono=RW-,Grupo=R--,Outros=R--)
	# opção do comando {} \;: executa comandos em lote e aplicar as permissões para cada arquivo/diretório em loop
	chown -Rfv www-data.www-data $PATHWORDPRESS &>> $LOG
	find $PATHWORDPRESS/. -type d -exec chmod -v 755 {} \; &>> $LOG
	find $PATHWORDPRESS/. -type f -exec chmod -v 644 {} \; &>> $LOG
echo -e "Permissões alteradas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando a Base de Dados do Wordpress no MySQL, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute), mysql (database)
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_DATABASE_WORDPRESS" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_USER_DATABASE_WORDPRESS" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_DATABASE_WORDPRESS" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_ALL_DATABASE_WORDPRES" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH_WORDPRESS" mysql &>> $LOG
echo -e "Base de Dados do Wordpress criada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Usuário de FTP do Wordpress, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando useradd: -d (home-dir), -s (shell), -G (Groups)
	# opção do comando echo: -e (enable escapes), \n (new line)
	# opção do redirecionar | "piper": (Conecta a saída padrão com a entrada padrão de outro comando)
	useradd -d $PATHWORDPRESS -s /bin/ftponly -G www-data,$GROUPFTP $USERFTPWORDPRESS &>> $LOG
	echo -e "$PASSWORDFTPWORDPRESS\n$PASSWORDFTPWORDPRESS" | passwd $USERFTPWORDPRESS &>> $LOG
echo -e "Usuário de FTP do Wordpress criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração wp-config.php, Pressione <Enter> continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /var/www/wp/wp-config.php
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do .htaccess, Pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /var/www/wp/.htaccess
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
echo -e "Editando o arquivo de Virtual Host wordpress.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/apache2/sites-available/wordpress.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando o Virtual Host do Wordpress no Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	a2enmod rewrite &>> $LOG
	a2ensite wordpress &>> $LOG
echo -e "Virtual Host habilitado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as configurações do Apache2, aguarde..."
	apachectl configtest &>> $LOG
echo -e "Configurações do Apache2 verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
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
echo -e "Verificando as versões dos serviços instalados, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "Apache2 Server..: $(dpkg-query -W -f '${version}\n' apache2)"
	echo -e "OpenSSL.........: $(dpkg-query -W -f '${version}\n' openssl)"
	echo -e "Wordpress CMS...: $(grep "wp_version =" /var/www/wp/wp-includes/version.php)"
echo -e "Versões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Apache2, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:443 -sTCP:LISTEN
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o Virtual Host do Wordpress no Apache2, aguarde..."
	# opção do comando apachectl: -s (a synonym)
	apache2ctl -S | grep wp.$DOMINIOSERVER
echo -e "Virtual Host verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do CMS Wordpress feito com Sucesso!!!"
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
