#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 25/11/2021
# Data de atualização: 21/01/2022
# Versão: 0.12
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do GLPI Help Desk v9.5.x
#
# GLPI (sigla em francês: Gestionnaire Libre de Parc Informatique, ou "Free IT Equipment 
# Manager" em inglês) é um sistema gratuito de Gerenciamento de Ativos de TI, sistema de 
# rastreamento de problemas e central de atendimento. Este software de código aberto é 
# escrito em PHP e distribuído sob a Licença Pública Geral GNU.
#
# O GLPI é um aplicativo baseado na Web que ajuda as empresas a gerenciar seu sistema de 
# informações. A solução é capaz de criar um inventário de todos os ativos da organização 
# e gerenciar tarefas administrativas e financeiras. As funcionalidades dos sistemas 
# auxiliam os administradores de TI a criar um banco de dados de recursos técnicos, além 
# de um gerenciamento e histórico de ações de manutenções. Os usuários podem declarar 
# incidentes ou solicitações (com base no ativo ou não) graças ao recurso de Helpdesk.
#
# Informações que serão solicitadas na configuração via Web do GLPI
# GLPI Setup
# Select your language: Português do Brasil: OK;
# Licença: Eu li e ACEITO os termos de licença acima: Continuar;
# Início da instalação: Instalar;
# Etapa 0: Verificação do ambiente: Continuar;
# Etapa 1: Instalação da conexão com o bando de dados:
#	SQL server(MariaDB ou MySQL): localhost
#	Usuário SQL: glpi
#	Senha SQL: glpi: Continuar;
# Etapa 2: Conexão com banco de dados: glpi: Continuar;
# Etapa 3: Iniciando banco de dados: Continuar;
# Etapa 4: Coletar dados: Continuar;
# Etapa 5: Uma última coisa antes de começar: Continuar;
# Etapa 6: A instalação foi concluída: Usar GLPI
#
# Usuário/Senha: glpi/glpi - conta do usuário administrador
# Usuário/Senha: tech/tech - conta do usuário técnico
# Usuário/Senha: normal/normal - conta do usuário normal
# Usuário/Senha: post-only/postonly - conta do usuário postonly
#
# Site oficial: https://glpi-project.org/pt-br/
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
# Verificando se as dependências do GLPI estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do GLPI, aguarde... "
	for name in $GLPIDEP
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            echo -en "Recomendo utilizar o script: 02-dhcp.sh para resolver as dependências."
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
# Script de instalação do GLPI no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação e Configuração do GLPI Help Desk no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Após a instalação do GLPI acessar a URL: http://glpi.$(hostname -d | cut -d' ' -f1)\n"
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
echo -e "Iniciando a Instalação e Configuração do GLPI Help Desk, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do GLPI, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes), \ (faz a função de quebra de pagina no comando apt)
	apt -y install $GLPIINSTALL &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do GLPI do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v glpi.tgz &>> $LOG
	wget $GLPI -O glpi.tgz &>> $LOG
echo -e "Download do GLPI feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Descompactando e Instalando o GLPI no site do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando tar: -z (gzip), -x (extract), -v (verbose), -f (file)
	# opção do comando mv: -v (verbose)
	# opção do comando chown: -R (recursive), -v (verbose), www-data.www-data (user and group)
	# opção do comando chmod: -R (recursive), -v (verbose), 755 (User=RWX, Group=R-X, Other=R-X)
	tar -zxvf glpi.tgz &>> $LOG
	mv -v glpi/ $PATHGLPI &>> $LOG
	chown -Rv www-data:www-data $PATHGLPI &>> $LOG
	chmod -Rv 755 $PATHGLPI &>> $LOG
	chmod -Rv 777 $PATHGLPI/files/_log &>> $LOG
echo -e "GLPI instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Banco de Dados do GLPI, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute), mysql (database)
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_DATABASE_GLPI" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_USER_DATABASE_GLPI" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_DATABASE_GLPI" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_ALL_DATABASE_GLPI" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH_GLPI" mysql &>> $LOG
echo -e "Banco de Dados criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do GLPI, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/glpi/glpi.conf /etc/apache2/conf-available/ &>> $LOG
	cp -v conf/glpi/glpi1.conf /etc/apache2/sites-available/glpi.conf &>> $LOG
	cp -v conf/glpi/glpi-cron /etc/cron.d/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do glpi.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/apache2/conf-available/glpi.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de Virtual Host glpi.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/apache2/sites-available/glpi.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de agendamento glpi-cron, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/cron.d/glpi-cron
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando o Virtual Host do GLPI no Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando phpenmod: (habilitar módulos do PHP)
	# opção do comando a2enconf: (habilitar arquivo de configuração de site do Apache2)
	# opção do comando a2ensite: (habilitar arquivo de virtual host de site do Apache2)
	# opção do comando systemctl: restart (reinicializar o serviço)
	phpenmod apcu &>> $LOG
	a2enconf glpi &>> $LOG
	a2ensite glpi &>> $LOG
echo -e "Virtual Host habilitado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl reload apache2 &>> $LOG
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
	lsof -nP -iTCP:80 -sTCP:LISTEN
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o Virtual Host do GLPI no Apache2, aguarde..."
	# opção do comando apachectl: -s (a synonym)
	apache2ctl -S | grep glpi.$DOMINIOSERVER
echo -e "Virtual Host verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "ANTES DE CONTINUAR COM O SCRIPT ACESSE A URL: http://glpi.$(hostname -d | cut -d' ' -f1)/"
echo -e "PARA FINALIZAR A CONFIGURAÇÃO VIA WEB DO GLPI HELP DESK, APÓS A"
echo -e "CONFIGURAÇÃO PRESSIONE <ENTER> PARA CONTINUAR COM O SCRIPT."
echo -e "MAIS INFORMAÇÕES NA LINHA 27 DO SCRIPT: $0"
read
sleep 5
#
echo -e "Removendo o script de instalação do GLPI Help Desk, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	mv -v $PATHGLPI/install/install.php $PATHGLPI/install/install.php.old &>> $LOG
echo -e "Arquivo removido com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do GLPI Help Desk feita com Sucesso!!!."
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
