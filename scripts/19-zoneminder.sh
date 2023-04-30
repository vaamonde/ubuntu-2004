#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 03/12/2021
# Data de atualização: 30/04/2023
# Versão: 0.17
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do ZoneMinder 1.37.x
#
# ZoneMinder é um sistema de CFTV (Circuito Fechado de Televisão) Open Source, desenvolvido 
# para sistemas operacionais Linux. Ele é liberado sob os termos da GNU General Public 
# License (GPL). Os usuários controlam o ZoneMinder através de uma interface baseada na Web; 
# também fornece LiveCD. O aplicativo pode usar câmeras padrão (por meio de uma placa de 
# captura, USB, Firewire etc.) ou dispositivos de câmera baseados em IP. O software permite 
# três modos de operação: monitoramento (sem gravação), gravação após movimento detectado e 
# gravação permanente.
#
# CCTV / CFTV = (Closed-Circuit Television - Circuito Fechado de Televisão);
# PTZ Pan/Tilt/Zoom (Uma câmera de rede PTZ oferece funcionalidade de vídeo em rede combinada 
# com o recurso de movimento horizontal, vertical e de zoom - Pan = Panorâmica Horizontal - 
# Tilt = Vertical | Zoom - Aproximar)
#
# ONVIF (Open Network Video Interface Forum) é um fórum global e aberto a todos, tem o objetivo 
# de ajudar no desenvolvimento de um padrão aberto para a interface de produtos de segurança 
# físicos baseados em IP.
#
# RTSP (Real Time Streaming Protocol) é um protocolo a nível de aplicação desenvolvido pela 
# IETF em 1998 com a RFC 2326 para controle na transferência de dados com propriedades de 
# tempo real. RTSP torna possível a transferência, sob demanda, de dados em tempo real como 
# áudio e vídeo.
#
# Site Oficial do Projeto ZoneMinder: https://zoneminder.com/
#
# Soluções Open Source de Monitoramento de CFTV
# Site Oficial do Projeto Shinobi: https://shinobi.video/
# Site Oficial do Projeto MotionEye: https://github.com/motioneye-project/motioneye
#
# Informações que serão solicitadas na configuração via Web do ZoneMinder
# URL: https://pti.intra/zm
# 	Privacy: Accept: Apply
#
# Configurações básicas do ZoneMinder
# #01_ Alteração da Linguagem;
#	Options
#		System
#			LANG_DEFAULT: pt_br
#
# #02_ Habilitando a Autenticação;
#	Options
#		System
#			OPT_USE_AUTH: ON
#				Uername Default.: admin
#				Password Default: admin
#
# Localizando dispositivos de Rede IP (CFTV/CCTV) na Rede com NMAP (Network Mapper)
# Terminal (Ctrl + Alt + T)
#	#opções do comando nmap: -sP (Ping Scan), .0/24 (All Subnet Address)
#	sudo apt install nmap
#	sudo nmap -sP 192.168.0.0/24
#
# Adicionando Monitor (Câmeras) no ZoneMinder
# #01_ Câmera PTZ IPCAM <Adicionar Monitor>
#	General
#		Nome: IPCAM
#		Tipo de Origem: Remoto
#	Origem
#		Remote Protocol: HTTP
#		Remote Method: Simple
#		Nome do host remoto: admin:admin@192.168.0.189
#		Porta do host remoto: 80
#		Caminho do host remoto: /videostream.cgi
#		Largura de Captura (pixels): 640
#		Altura de Captura (pixels): 480
#	Recording
#		Video Writer: Disable
#	<Salvar>
#
# #02_ Câmera IPWEBCAM <Adicionar Monitor>
#	General
#		Nome: IPWEBCAM
#		Tipo de Origem: Remoto
#	Origem
#		Remote Protocol: HTTP
#		Remote Method: Simple
#		Nome do host remoto: admin:admin@192.168.0.177
#		Porta do host remoto: 8080
#		Caminho do host remoto: /video
#		Largura de Captura (pixels): 640
#		Altura de Captura (pixels): 480
#	Recording
#		Video Writer: Disable
#	<Salvar>
#
# #03_ Câmera IPEGA <Adicionar Monitor>
#	General
#		Nome: IPEGA
#		Tipo de Origem: Remoto
#	Origem
#		Remote Protocol: RTSP
#		Remote Method: RTP/Unicast
#		Nome do host remoto: admin:admin@192.168.188
#		Porta do host remoto: 554
#		Caminho do host remoto: /onvif1
#		Largura de Captura (pixels): 640
#		Altura de Captura (pixels): 480
#	Recording
#		Video Writer: Disable
#	<Salvar>
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
# Verificando se as dependências do ZoneMinder estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do ZoneMinder, aguarde... "
	for name in $ZONEMINDERDEP
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
			echo -en "Recomendo utilizar o script: 11-A-openssl-ca.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 11-B-openssl-apache.sh para resolver as dependência."
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
# Script de instalação do ZoneMinder no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do ZoneMinder no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Após a instalação do ZoneMinder acessar a URL: https://$(hostname -d | cut -d ' ' -f1)/zm/\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet..."
sleep 5
echo
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
echo -e "Iniciando a Instalação e Configuração do ZoneMinder, aguarde...\n"
sleep 5
#
echo -e "Adicionando o PPA do ZoneMinder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando echo |: (faz a função do Enter)
	echo | add-apt-repository $ZONEMINDER &>> $LOG
echo -e "PPA adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando novamente as listas do Apt com o novo PPA, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando as configurações MySQL mysqld.cnf, pressione <Enter> para continuar"
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/mysql/mysql.conf.d/mysqld.cnf 
	systemctl restart mysql &>> $LOG
echo -e "Arquivo do MySQL editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando as configurações do PHP php.ini, pressione <Enter> para continuar"
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/php/7.4/apache2/php.ini
	systemctl restart apache2 &>> $LOG
echo -e "Arquivo do PHP editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o ZoneMinder, esse processo demora um pouco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $ZONEMINDERINSTALL &>> $LOG
echo -e "ZoneMinder instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o Banco de Dados do ZoneMinder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute), < (Redirecionador de Entrada STDIN)
	#mysql -u $USERMYSQL -p$SENHAMYSQL -e "$DROP_DATABASE_ZONEMINDER" mysql &>> $LOG
	#mysql -u $USERMYSQL -p$SENHAMYSQL < $CREATE_DATABASE_ZONEMINDER &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$ALTER_USER_DATABASE_ZONEMINDER" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_DATABASE_ZONEMINDER" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_ALL_DATABASE_ZONEMINDER" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH_ZONEMINDER" mysql &>> $LOG
echo -e "Banco de Dados atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Alterando as permissões dos arquivos e diretórios do ZoneMinder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando chmod: -v (verbose), 740 (dono=RWX,grupo=R,outro=)
	# opções do comando chown: -v (verbose), -R (recursive), root (dono), www-data (grupo)
	# opções do comando usermod: -a (append), -G (group), video (grupo), www-data (user)
	chmod -v 740 /etc/zm/zm.conf &>> $LOG
	chown -v root.www-data /etc/zm/zm.conf &>> $LOG
	chown -Rv www-data.www-data /usr/share/zoneminder/ &>> $LOG
	usermod -a -G video www-data &>> $LOG
echo -e "Permissões alteradas com sucesso com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando os recursos do Apache2 para o ZoneMinder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# a2enmod (Apache2 Enable Mode), a2enconf (Apache2 Enable Conf)
	a2enmod cgi &>> $LOG
	a2enmod rewrite &>> $LOG
	a2enmod headers &>> $LOG
	a2enmod expires &>> $LOG
	a2enconf zoneminder &>> $LOG
echo -e "Recursos habilitados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as configurações do Apache2, aguarde..."
	apachectl configtest &>> $LOG
echo -e "Configurações do Apache2 verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o Serviço do Apache2, aguarde..."
	systemctl restart apache2 &>> $LOG
echo -e "Serviço do Apache2 reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando o Serviço do ZoneMinder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable zoneminder &>> $LOG
	systemctl restart zoneminder &>> $LOG
echo -e "Serviço habilitado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando os serviços do Apache2, MySQL e do ZoneMinder, aguarde..."
	echo -e "Apache2...: $(systemctl status apache2 | grep Active)"
	echo -e "MySQL.....: $(systemctl status mysql | grep Active)"
	echo -e "Zoneminder: $(systemctl status zoneminder | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as versões dos serviços instalados, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "Apache2 Server..: $(dpkg-query -W -f '${version}\n' apache2)"
	echo -e "MySQL Server....: $(dpkg-query -W -f '${version}\n' mysql-server)"
	echo -e "OpenSSL.........: $(dpkg-query -W -f '${version}\n' openssl)"
	echo -e "Zoneminder......: $(dpkg-query -W -f '${version}\n' zoneminder)"
echo -e "Versões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexão do Apache2 e do MySQL, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:'80,443,3306' -sTCP:LISTEN
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do ZoneMinder feita com Sucesso!!!"
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