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
# Data de atualização: 30/04/2023
# Versão: 0.14
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do GLPI Help Desk v9.5.x
# Testado e homologado para a versão do FusionInventory Server 9.5.x e Agent 2.6.x
#
# O FusionInventory Agent é um agente multiplataforma genérico. Ele pode executar uma 
# grande variedade de tarefas de gerenciamento, como inventário local, implantação de 
# software ou descoberta de rede. Ele pode ser usado autônomo ou em combinação com um 
# servidor compatível (OCS Inventory, GLPI, OTRS, Uranos, etc..) atuando como um ponto 
# de controle centralizado.
#
# Site Oficial do Projeto FusionInventory: http://fusioninventory.org/
#
# Soluções Open Source de Inventário de Rede
# Site Oficial do Projeto OCS Inventory: https://ocsinventory-ng.org
# Site Oficial do Projeto Snipe-IT: https://snipeitapp.com/
# Site Oficial do Projeto Open-Audit: https://www.open-audit.org/
#
# Informações que serão solicitadas na configuração via Web do FusionInventory Server no GLPI
# Configurar
#   Plug-ins
#       FusionInventory: Instalar
#       FusionInventory: Habilitar
# OBSERVAÇÃO: existe várias configurações para serem feitas no FusionInventory Server no GLPI,
# apenas habilitando o serviço os Agentes do FusionInventory já consegue enviar os inventários
# para o GLPI Help Desk.
#
# Software utilizados pelo FusionInventory:
# fusioninventory-agent: Agente de Inventário e Tarefas Local do FusionInventory
# fusioninventory-injector: Ferramenta de Envio de Inventário Remoto do FusionInventory
# fusioninventory-inventory: Inventário Autônomo do FusionInventory, utilizado nas tarefas do GLPI
# fusioninventory-netdiscovery: Descoberta de Rede Autônomo do FusionInventory, utilizado nas tarefas do GLPI
# fusioninventory-netinventory: Inventário de Rede Autônomo do FusionInventory, utilizado nas tarefas do GLPI
# fusioninventory-remoteinventory: Ferramenta de Inventário Remoto do FusionInventory
# fusioninventory-wakeonlan: Wake-on-LAN de Computadores FusionInventory, utilizado nas tarefas do GLPI
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
# Verificando se a porta 62354 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTFUSION &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTFUSION já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTFUSION está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando se as dependências do FusionInventory estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do FusionInventory, aguarde... "
	for name in $FUSIONDEP
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
			echo -en "Recomendo utilizar o script: 17-A-glpi-9.sh para resolver as dependências."
            exit 1; 
            }
		sleep 5
#
# Verificando se o GLPI Help Desk está instalado (dependência principal do FusionInventory)
# opção do comando: echo: -e (interpretador de escapes de barra invertida)
# opção do comando if: [ ] = testa uma expressão, -e = testa se é diretório existe
echo -e "Verificando se o GLPI Help Desk está instalado, aguarde..."
	if [ -e "$PATHGLPI9" ]
		then
    		echo -e "O GLPI Help Desk está instalado, tudo OK, continuando com o script..."
			sleep 5
	else
    		echo "O GLPI Help Desk não está instalado, instale o GLPI com o script: 17-A-glpi-9.sh"
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
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação e Configuração do FusionInventory no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo FusionInventory.: TCP 62354\n"
echo -e "Após a instalação do FusionInventory acesse a URL: https://glpi9.$(hostname -d | cut -d' ' -f1)/"
echo -e "As configurações do FusionInventory Server é feita dentro do GLPI Help Desk\n"
echo -e "Link de download dos Agentes do FusionInventory URL: https://$(hostname -d | cut -d' ' -f1)/agentesfusion\n"
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
echo -e "Iniciando a Instalação e Configuração do FusionInventory Server e Agent, aguarde...\n"
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
	mv -v fusioninventory/ $PATHGLPI9/plugins/ &>> $LOG
echo -e "Diretório do FusionInventory Server movido com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando as Dependências do FusionInventory Server e Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	# dependências do FusionInventory Agent
	apt -y install $AGENTINSTALL &>> $LOG
	# dependências do FusionInventory Task Network
	apt -y install $NETWORKINSTALL &>> $LOG
	# dependências do FusionInventory Task Deploy
	apt -y install $DEPLOYINSTALL &>> $LOG
	# dependências do FusionInventory Task WakeOnLan
	apt -y install $WAKEINSTALL &>> $LOG
    # dependências do FusionInventory SNMPv3
	apt -y install $SNMPINSTALL &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do FusionInventory Agent do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v agent.deb task.deb deploy.deb network.deb &>> $LOG
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
echo -e "Atualizando o arquivo de configuração do FusionInventory Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	mkdir -v /var/log/fusioninventory-agent/ &>> $LOG
	touch /var/log/fusioninventory-agent/fusioninventory.log &>> $LOG
	mv -v /etc/fusioninventory/agent.cfg /etc/fusioninventory/agent.cfg.old &>> $LOG
	cp -v conf/fusioninventory/agent.cfg /etc/fusioninventory/agent.cfg &>> $LOG
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração agent.cfg, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/fusioninventory/agent.cfg
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando o serviço do FusionInventory Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable fusioninventory-agent &>> $LOG
	systemctl start fusioninventory-agent &>> $LOG
echo -e "Serviço iniciado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do FusionInventory Agent, aguarde..."
	echo -e "Agent: $(systemctl status fusioninventory-agent | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as versões dos serviços instalados, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "FusionInventory Agent....: $(dpkg-query -W -f '${version}\n' fusioninventory-agent)"
	echo -e "FusionInventory Collect..: $(dpkg-query -W -f '${version}\n' fusioninventory-agent-task-collect)"
	echo -e "FusionInventory Deploy...: $(dpkg-query -W -f '${version}\n' fusioninventory-agent-task-deploy)"
	echo -e "FusionInventory Network..: $(dpkg-query -W -f '${version}\n' fusioninventory-agent-task-network)"
echo -e "Versões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "ANTES DE CONTINUAR COM O SCRIPT ACESSE A URL: https://glpi9.$(hostname -d | cut -d' ' -f1)/"
echo -e "PARA FINALIZAR A CONFIGURAÇÃO VIA WEB DO FUSIONINVENTORY SERVER, APÓS A"
echo -e "CONFIGURAÇÃO PRESSIONE <ENTER> PARA CONTINUAR COM O SCRIPT."
echo -e "MAIS INFORMAÇÕES NA LINHA 21 DO SCRIPT: $0"
read
sleep 5
#
echo -e "Verificando a porta de conexão do FusionInventory, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:"62354" -sTCP:LISTEN
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Executando o primeiro Inventário do FusionInventory Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	fusioninventory-agent --debug &>> $LOG
echo -e "Inventário feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o diretório de download dos Agentes do FusionInventory, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando chown: -v (verbose)
	# opção do comando chmod: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comando wget: -O (output document file)
	mkdir -v $DOWNLOADAGENTFS &>> $LOG
	chown -v www-data.www-data $DOWNLOADAGENTFS &>> $LOG
	chmod -v 755 $DOWNLOADAGENTFS &>> $LOG
	cp -v conf/fusioninventory/agent.cfg $DOWNLOADAGENTFS &>> $LOG
	wget $AGENTWINDOWS32 -O $DOWNLOADAGENTFS/agent_windows32.exe &>> $LOG
	wget $AGENTWINDOWS64 -O $DOWNLOADAGENTFS/agent_windows64.exe &>> $LOG
	wget $AGENTMACOS -O $DOWNLOADAGENTFS/agent_macos.dmg &>> $LOG
	wget $FUSIONAGENT -O $DOWNLOADAGENTFS/agent_linux.deb &>> $LOG
echo -e "Diretório criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o diretório de agentes: https://$(hostname -d | cut -d' ' -f1)/agentesfusion/, aguarde..."
	tree $DOWNLOADAGENTFS
echo -e "Diretório verificado com sucesso!!!, continuando com o script...\n"
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
