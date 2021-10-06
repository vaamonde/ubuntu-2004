#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 06/08/2020
# Data de atualização: 14/01/2021
# Versão: 0.06
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do FusionInventory Server 9.5.x, Agent 2.5.x, GLPI 9.5.x
#
# O FusionInventory Agent é um agente multiplataforma genérico. Ele pode executar uma grande variedade de 
# tarefas de gerenciamento, como inventário local, implantação de software ou descoberta de rede. Ele pode 
# ser usado autônomo ou em combinação com um servidor compatível (OCS Inventory, GLPI, OTRS, Uranos, etc..) 
# atuando como um ponto de controle centralizado.
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
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de instalação do LAMP Server: https://www.youtube.com/watch?v=6EFUu-I3u4s&t
# Vídeo de instalação do GLPI Help Desk: https://www.youtube.com/watch?v=6T9dMwJMeDw&t
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
# Declarando as variáveis de download do FusionInventory (Links atualizados no dia 14/08/2020)
# OBSERVAÇÃO: O FusionInventory depende do GLPI para funcionar corretamente, recomendo sempre manter o GLPI
# é o FusionInventory atualizados para as últimas versões.
FUSIONSERVER="https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi9.5.0%2B1.0/fusioninventory-9.5.0+1.0.tar.bz2"
FUSIONAGENT="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent_2.5.2-1_all.deb"
FUSIONCOLLECT="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent-task-collect_2.5.2-1_all.deb"
FUSIONNETWORK="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent-task-network_2.5.2-1_all.deb"
FUSIONDEPLOY="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent-task-deploy_2.5.2-1_all.deb"
AGENTWINDOWS32="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent_windows-x86_2.5.2.exe"
AGENTWINDOWS64="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent_windows-x64_2.5.2.exe"
AGENTMACOS="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/FusionInventory-Agent-2.5.2-1.dmg"
#
# Localização padrão do diretório de instalação do GLPI Help Desk utilizado no script glpi.sh
GLPI="/var/www/html/glpi"
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
# Verificando se as dependências do FusionInventory estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
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
            echo -en "Recomendo utilizar o script: lamp.sh para resolver as dependências."
            exit 1; 
            }
		sleep 5
#
# Verificando se o GLPI Help Desk está instaladas
# opção do comando: echo: -e (interpretador de escapes de barra invertida)
# opção do comando if: [ ] = testa uma expressão, -e = testa se é diretório existe
echo -e "Verificando se o GLPI Help Desk está instalado, aguarde...\n"
	if [ -e "$GLPI" ]
		then
    		echo -e "O GLPI Help Desk está instalado, continuando com o script...\n"
			sleep 5
	else
    		echo "O GLPI Help Desk não está instalado, instale o GLPI com o script: glpi.sh"
			echo "Depois da instalação e configuração, execute novamente esse script."
			exit 1
			sleep 5
	fi
#
# Script de instalação do FusionInventory no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo -e "Instalação do FusionInventory no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do FusionInventory acesse a URL: http://`hostname -I | cut -d' ' -f1`/glpi\n"
echo -e "As configurações do FusionInventory e feita dentro do GLPI Help Desk\n"
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
echo
#
echo -e "Instalando o FusionInventory Server e Agent, aguarde...\n"
#
echo -e "Fazendo o download do FusionInventory Server do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v fusion.tar.bz2 &>> $LOG
	wget $FUSIONSERVER -O fusion.tar.bz2 &>> $LOG
echo -e "Download do FusionInventory Server feito com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Descompactando o FusionInventory Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando tar: -j (bzip2), -x (extract), -v (verbose), -f (file)
	tar -jxvf fusion.tar.bz2 &>> $LOG
echo -e "FusionInventory Server descompactado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Movendo o diretório do FusionInventory Server para o GLPI Help Desk, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	mv -v fusioninventory/ $GLPI/plugins/ &>> $LOG
echo -e "Diretório do FusionInventory Server movido com sucesso!!!, continuando com o script..."
sleep 5
echo
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
echo -e "Dependências instaladas com sucesso!!!, continuando com o script..."
sleep 5
echo
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
echo -e "Download do FusionInventory Agent feito com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o FusionInventory Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando dpkg: -i (install)
	dpkg -i agent.deb &>> $LOG
	dpkg -i task.deb &>> $LOG
	dpkg -i deploy.deb &>> $LOG
	dpkg -i network.deb &>> $LOG
echo -e "FusionInventory Agent instalado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Configurando o FusionInventory Agent, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
    # opção do comando mkdir: -v (verbose)
	# opção do comando cp: -v (verbose)
	read
	sleep 3
    mkdir -v /var/log/fusioninventory-agent/ &>> $LOG
    touch /var/log/fusioninventory-agent/fusioninventory.log &>> $LOG
	cp -v /etc/fusioninventory/agent.cfg /etc/fusioninventory/agent.cfg.bkp &>> $LOG
	cp -v conf/agent.cfg /etc/fusioninventory/agent.cfg &>> $LOG
	vim /etc/fusioninventory/agent.cfg
echo -e "FusionInventory Agent configurado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Iniciando o serviço do FusionInventory Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable fusioninventory-agent &>> $LOG
	systemctl start fusioninventory-agent &>> $LOG
echo -e "Serviço do FusionInventory Agent iniciado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Executando o Inventário do FusionInventory Agent, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	fusioninventory-agent --debug &>> $LOG
echo -e "Inventário do FusionInventory Agent feito com sucesso!!!, continuando com o script..."
sleep 5
echo
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
echo -e "Download dos FusionInventory Agent feito com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalação do FusionInventory feita com Sucesso!!!."
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
