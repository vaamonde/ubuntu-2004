#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 14/01/2022
# Data de atualização: 18/04/2022
# Versão: 0.04
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Asterisk v19.1.x
#
# O Asterisk é um software livre, de código aberto, que implementa em software os recursos 
# encontrados em um PABX convencional, utilizando tecnologia de VoIP. Ele foi criado pelo 
# Mark Spencer em 1999. Inicialmente desenvolvido pela empresa Digium, hoje recebe contribuições 
# de programadores ao redor de todo o mundo. Seu desenvolvimento é ativo e sua área de aplicação 
# muito promissora.
#
# DAHDI = DAHDI (Digium\Asterisk Hardware Device Interface) é uma coleção de drivers de código 
# aberto, para o Linux, que são usados para fazer interface com uma variedade de hardware 
# relacionado à telefonia.
#
# DAHDI Tools = contém uma variedade de utilitários de comandos do usuário que são usados para 
# configurar e testar os drivers de hardware desenvolvidos pela Digium e Zapatel.
#
# LIBPRI = A biblioteca libpri permite que o Asterisk se comunique com conexões ISDN. Você só 
# precisará disso se for usar o DAHDI com hardware de interface ISDN (como placas T1/E1/J1/BRI).
#
# iLBC = O iLBC (internet Low Bitrate Codec) é um codec de voz GRATUITO adequado para comunicação 
# de voz robusta sobre IP. O codec é projetado para fala de banda estreita e resulta em uma taxa 
# de bits de carga útil de 13,33 kbit / s com um comprimento de quadro de codificação de 30 ms e 
# 15,20 kbps com um comprimento de codificação de 20 ms.
#
# H.323 =  é um conjunto de padrões da ITU-T que define um conjunto de protocolos para o fornecimento 
# de comunicação de áudio e vídeo numa rede de computadores. O H.323 é um protocolo relativamente 
# antigo que está atualmente sendo substituído pelo SIP.
#
# Site Oficial do Asterisk: https://www.asterisk.org/
#
# Informações que serão solicitadas na configuração dos Módulos do Asterisk: (Utilizar TAB e ENTER)
# Add-ons (See README-addons.txt): --- Extended ---
#	* chan_ooh323
#	* format_mp3
# Applications: --- Core ---
#	* app_skel
#	* app_ivrdemo
#	* app_saycounted	
#	* app_statsd
#	* app_meetme
# Resource Modules: --- Core ---
#	* res_wmi_external
#	* res_wmi_external_ami
#	* res_chan_stats
#	* res_corosynsc
# 	* res_endpoint_stats
#	* res_remb_modifier
#	* res_pktccops
# Utilities: --- Extended ---
#	* check_expr
#	* check_expr2
# <Save and Exit>
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
# Verificando se a porta 5060 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), -u (UDP), &> redirecionador de saída de erro
if [ "$(nc -vzu 127.0.0.1 $PORTSIP &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTSIP já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTSIP está disponível, continuando com o script..."
		sleep 5
fi
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
# Script de instalação do Asterisk no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Asterisk no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo SIP.: UDP 5060"
echo -e "Após a instalação, acessar o CLI do Asterisk digitando o comando: asterisk -rvvvv\n"
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
echo -e "Iniciando a Instalação e Configuração do Asterisk, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do Asterisk, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt install -y $ASTERISKINSTALLDEP &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download e instalando do DAHDI Linux do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -R (recursive), -v (verbose)
	# opção do comando git: -b ()
	# opção do comando cd: .. (dois pontos sequenciais - Subir uma pasta)
	rm -Rv dahdi-linux/ &>> $LOG
	git clone -b next $DAHDIINSTALL dahdi-linux &>> $LOG
	cd dahdi-linux/ &>> $LOG
		make &>> $LOG
		make install &>> $LOG
	cd ..
echo -e "Download e instalação do DAHDI feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download e instalando do DAHDI Tools do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -R (recursive), -v (verbose)
	# opção do comando cd: .. (dois pontos sequenciais - Subir uma pasta)
	rm -Rv dahdi-tools/ &>> $LOG
	git clone -b next $DAHDITOOLSINSTALL dahdi-tools &>> $LOG
	cd dahdi-tools/ &>> $LOG
		autoreconf -i &>> $LOG
		./configure &>> $LOG
		make install &>> $LOG
		make install-config &>> $LOG
		dahdi_genconf modules &>> $LOG
	cd ..
echo -e "Download e instalação do DAHDI Tools feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download e instalando do LIBPRI do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -R (recursive), -v (verbose)
	# opção do comando cd: .. (dois pontos sequenciais - Subir uma pasta)
	rm -Rv libpri/ &>> $LOG
	git clone $LIBPRIINSTALL libpri &>> $LOG
	cd libpri/ &>> $LOG
		make &>> $LOG
		make install &>> $LOG
		ldconfig &>> $LOG
	cd ..
echo -e "Download e instalação do LIBPRI feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download e configurando o Asterisk do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (file)
	# opção do comando tar: -z (gzip), -x (extract), -v (verbose), -f (file)
	# opção do comando | (piper): (Conecta a saída padrão com a entrada padrão de outro comando)
	# opção do comando yes: yes é um comando utilizado normalmente em conjunto com outro programa, para responder sempre 
	# positivamente (ou negativamente) às perguntas do segundo programa
	rm -v asterisk.tar.gz &>> $LOG
	wget -O asterisk.tar.gz $ASTERISKINSTALL &>> $LOG
	tar -zxvf asterisk.tar.gz &>> $LOG
	cd asterisk*/ &>> $LOG
		# resolvendo as dependências do suporte a Música e Sons em MP3
		bash contrib/scripts/get_mp3_source.sh &>> $LOG
		# resolvendo as dependências do suporte ao Codec iLBC
		bash contrib/scripts/get_ilbc_source.sh &>> $LOG
		# instalando as dependência do MP3 e ILBC utilizando o debconf-set-selections
		echo "libvpb1 libvpb1/countrycode $COUNTRYCODE" | debconf-set-selections &>> $LOG
		yes | bash contrib/scripts/install_prereq install &>> $LOG
		./configure &>> $LOG
		make clean  &>> $LOG
		# menu de seleção da configuração do Asterisk (recomendado)
		make menuselect
echo -e "Configuração do Asterisk feita com sucesso!!!, continuando com o script\n"
sleep 5
#
echo -e "Compilando e instalando o Asterisk, esse processo demora um pouco, aguarde...."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cd: .. (dois pontos sequenciais - Subir uma pasta)
		# compila todas as opções do software marcadas nas opções do make menuselect
		make all &>> $LOG
		# executa os comandos para instalar o programa com as opções do make maneselect
		make install &>> $LOG
		# instala um conjunto de arquivos de configuração de amostra para o Asterisk
		make samples &>> $LOG
		# instala um conjunto de configuração básica para o Asterisk
		make basic-pbx &>> $LOG
		# instala um conjunto de documentação para o Asterisk
		# se você habilitar esse recurso, o processo de compilação demora bastante
		#make progdocs &>> $LOG
		# instala um conjunto de scripts de inicialização do Asterisk (systemctl)
		make config &>> $LOG
		# instala um conjunto de scripts de configuração dos Logs do Asterisk (rsyslog)
		make install-logrotate &>> $LOG
		# inicializando o serviço do Asterisk
		systemctl start asterisk &>> $LOG
	cd ..
echo -e "Compilação e instalação do Asterisk feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download dos arquivos de Sons em Português/Brasil do Asterisk, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comando wget: -O (file)
	# opção do comando unzip: -o (overwrite)
	# opção do comando cd: - (traço, rollback voltar para a pasta anterior)
	mkdir -v $SOUNDSPATH &>> $LOG
	cp -v conf/asterisk/convert.sh $SOUNDSPATH &>> $LOG
	cd $SOUNDSPATH &>> $LOG
		wget -O core.zip $SOUNDPTBRCORE &>> $LOG
		wget -O extra.zip $SOUNDPTBREXTRA &>> $LOG
		unzip -o core.zip &>> $LOG
		unzip -o extra.zip &>> $LOG
		bash convert.sh &>> $LOG
	cd - &>> $LOG
echo -e "Download dos arquivos de Sons em Português/Brasil feito com sucesso!!!!, continuado com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos dos Ramais SIP, Plano de Discagem e Módulos do Asterisk, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	mv -v /etc/asterisk/sip.conf /etc/asterisk/sip.conf.old &>> $LOG
	mv -v /etc/asterisk/extensions.conf /etc/asterisk/extensions.conf.old &>> $LOG
	mv -v /etc/asterisk/modules.conf /etc/asterisk/modules.conf.old &>> $LOG
	mv -v /etc/asterisk/asterisk.conf /etc/asterisk/asterisk.conf.old &>> $LOG
	cp -v conf/asterisk/{sip.conf,extensions.conf,modules.conf,asterisk.conf} /etc/asterisk/ &>> $LOG
	cp -v conf/asterisk/asterisk /etc/default/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configurando a Segurança do Asterisk, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando useradd: -r (system account), -d (home directory), -g (group GID), asterisk (user)
	# opções do comando usermod: -a (append), -G (groups), asterisk (user)
	# opções do comando chown: -R (recursive), -v (verbose), Asterisk.Asterisk (Usuário.Grupo)
	# opção do comando chmod: -R (recursive), -v (verbose), 775 (Dono=RWX,Grupo=RWX=Outros=R-X)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	groupadd asterisk &>> $LOG
	useradd -r -d /var/lib/asterisk -g asterisk asterisk &>> $LOG
	usermod -aG audio,dialout asterisk &>> $LOG
	chown -Rv asterisk.asterisk /etc/asterisk &>> $LOG
	chown -Rv asterisk.asterisk /var/{lib,log,spool}/asterisk &>> $LOG
	chown -Rv asterisk.asterisk /usr/lib/asterisk  &>> $LOG
	chmod -Rv 775 /var/lib/asterisk/sounds/pt_BR &>> $LOG
echo -e "Configuração da segurança do Asterisk feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração asterisk, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/default/asterisk
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração asterisk.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/asterisk/asterisk.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração modules.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/asterisk/modules.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração sip.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/asterisk/sip.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração extensions.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/asterisk/extensions.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o Serviço do Asterisk, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable asterisk &>> $LOG
	systemctl restart asterisk &>> $LOG
echo -e "Serviço habilitado e iniciado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do Asterisk, aguarde..."
	echo -e "Asterisk: $(systemctl status asterisk | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do SIP do Asterisk, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iUDP:5060
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Asterisk feita com Sucesso!!!"
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