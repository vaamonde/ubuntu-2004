#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Data de criação: 25/11/2021
# Data de atualização: 30/11/2021
# Versão: 0.02
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do FusionInventory Server 9.5.x, Agent 2.6.x e GLPI 9.5.x
#
# O FusionInventory Agent é um agente multiplataforma genérico. Ele pode executar uma 
# grande variedade de tarefas de gerenciamento, como inventário local, implantação de 
# software ou descoberta de rede. Ele pode ser usado autônomo ou em combinação com um 
# servidor compatível (OCS Inventory, GLPI, OTRS, Uranos, etc..) atuando como um ponto 
# de controle centralizado.
#
# Informações que serão solicitadas na configuração via Web do FusionInventory no GLPI
# Configurar
#   Plug-ins
#       FusionInventory: Instalar
#       FusionInventory: Habilitar 
#
# Software utilizados pelo FusionInventory:
# fusioninventory-agent: Agente de Inventário e Tarefas Local do FusionInventory
# fusioninventory-inventory: Inventário Autônomo do FusionInventory, utilizado nas tarefas do GLPI
# fusioninventory-remoteinventory: Ferramenta de Inventário Remoto do FusionInventory
# fusioninventory-netdiscovery: Descoberta de Rede Autônomo do FusionInventory, utilizado nas tarefas do GLPI
# fusioninventory-netinventory: Inventário de Rede Autônomo do FusionInventory, utilizado nas tarefas do GLPI
# fusioninventory-wakeonlan: Wake-on-LAN de Computadores FusionInventory, utilizado nas tarefas do GLPI
# fusioninventory-injector: Ferramenta de Envio de Inventário Remoto do FusionInventory
# 
# Site Oficial do Projeto: http://fusioninventory.org/
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
# Verificando se as dependências do FusionInventory estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do FusionInventory, aguarde... "
	for name in mysql-server mysql-common apache2 php
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
# Verificando se o GLPI Help Desk está instalado (dependência principal do FusionInventory)
# opção do comando: echo: -e (interpretador de escapes de barra invertida)
# opção do comando if: [ ] = testa uma expressão, -e = testa se é diretório existe
echo -e "Verificando se o GLPI Help Desk está instalado, aguarde...\n"
	if [ -e "$PATHGLPI" ]
		then
    		echo -e "O GLPI Help Desk está instalado, tudo OK, continuando com o script...\n"
			sleep 5
	else
    		echo "O GLPI Help Desk não está instalado, instale o GLPI com o script: 15-glpi.sh"
			echo "Depois da instalação e configuração do GLPI, execute novamente esse script."
			exit 1
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
# Script de instalação do FusionInventory Server e Agent no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
#
echo -e "Instalação e Configuração do FusionInventory no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Após a instalação do FusionInventory acesse a URL: http://$(hostname -I | cut -d' ' -f1)/glpi\n"
echo -e "As configurações do FusionInventory Server e feita dentro do GLPI Help Desk\n"
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
	#opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando todo o sistema, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
	apt -y full-upgrade &>> $LOG
	apt -y dist-upgrade &>> $LOG
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
echo -e "Instalando e Configurando o FusionInventory Server e Agent, aguarde...\n"
sleep 5
#
echo -e "Fazendo o download do FusionInventory Server do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v fusion.tar.bz2 &>> $LOG
	wget $FUSIONSERVER -O fusion.tar.bz2 &>> $LOG
echo -e "Download do FusionInventory feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Descompactando o arquivo do FusionInventory Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando tar: -j (bzip2), -x (extract), -v (verbose), -f (file)
	tar -jxvf fusion.tar.bz2 &>> $LOG
echo -e "Arquivo do FusionInventory descompactado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Movendo o diretório do FusionInventory Server para o diretório do GLPI Help Desk, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	mv -v fusioninventory/ $PATHGLPI/plugins/ &>> $LOG
echo -e "Diretório do FusionInventory Server movido com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando as Dependências do FusionInventory Server e Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	# dependências do FusionInventory Agent
	apt -y install dmidecode hwdata ucf hdparm perl libuniversal-require-perl libwww-perl libparse-edid-perl \
	libproc-daemon-perl libfile-which-perl libhttp-daemon-perl libxml-treepp-perl libyaml-perl libnet-cups-perl \
	libnet-ip-perl libdigest-sha-perl libsocket-getaddrinfo-perl libtext-template-perl libxml-xpath-perl \
	libyaml-tiny-perl libio-socket-ssl-perl libnet-ssleay-perl libcrypt-ssleay-perl &>> $LOG
	# dependências do FusionInventory Task Network
	apt -y install libnet-snmp-perl libcrypt-des-perl libnet-nbname-perl &>> $LOG
	# dependências do FusionInventory Task Deploy
	apt -y install libfile-copy-recursive-perl libparallel-forkmanager-perl &>> $LOG
	# dependências do FusionInventory Task WakeOnLan
	apt -y install libwrite-net-perl &>> $LOG
    # dependências do FusionInventory SNMPv3
	apt -y install libdigest-hmac-perl &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do FusionInventory Agent do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v agent.deb task.deb deploy.deb snmp.deb &>> $LOG
	wget $FUSIONAGENT -O agent.deb &>> $LOG
	wget $FUSIONCOLLECT -O task.deb &>> $LOG
	wget $FUSIONDEPLOY -O deploy.deb &>> $LOG
	wget $FUSIONNETWORK -O network.deb &>> $LOG
echo -e "Download do FusionInventory Agent feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o FusionInventory Agent e seus aplicativos extras, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando dpkg: -i (install)
	dpkg -i agent.deb &>> $LOG
	dpkg -i task.deb &>> $LOG
	dpkg -i deploy.deb &>> $LOG
	dpkg -i network.deb &>> $LOG
echo -e "FusionInventory Agent instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do FusionInventory Agent, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
    # opção do comando mkdir: -v (verbose)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	read
    mkdir -v /var/log/fusioninventory-agent/ &>> $LOG
    touch /var/log/fusioninventory-agent/fusioninventory.log &>> $LOG
	mv -v /etc/fusioninventory/agent.cfg /etc/fusioninventory/agent.cfg.old &>> $LOG
	cp -v conf/agent.cfg /etc/fusioninventory/agent.cfg &>> $LOG
	vim /etc/fusioninventory/agent.cfg
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando o serviço do FusionInventory Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable fusioninventory-agent &>> $LOG
	systemctl start fusioninventory-agent &>> $LOG
echo -e "Serviço do iniciado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Executando o primeiro Inventário do FusionInventory Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	fusioninventory-agent --debug &>> $LOG
echo -e "Inventário feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o repositório local e fazendo o download dos Agentes do FusionInventory, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando chown: -v (verbose)
	# opção do comando chmod: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comando wget: -O (output document file)
	mkdir -v /var/www/html/agentes &>> $LOG
	chown -v www-data.www-data /var/www/html/agentes &>> $LOG
	chmod -v 755 /var/www/html/agentes &>> $LOG
	cp -v conf/agent.cfg /var/www/html/agentes &>> $LOG
	wget $AGENTWINDOWS32 -O /var/www/html/agentes/agent_windows32.exe &>> $LOG
	wget $AGENTWINDOWS64 -O /var/www/html/agentes/agent_windows64.exe &>> $LOG
	wget $AGENTMACOS -O /var/www/html/agentes/agent_macos.dmg &>> $LOG
	wget $FUSIONAGENT -O agent_linux.deb &>> $LOG
echo -e "Download dos FusionInventory Agent feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do FusionInventory Server e Agent feita com Sucesso!!!."
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
