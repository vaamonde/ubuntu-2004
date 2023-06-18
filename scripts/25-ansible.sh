#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 16/12/2021
# Data de atualização: 18/06/2023
# Versão: 0.04
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Ansible v2.18.x e do Rundeck v4.13.x
#
# O Ansible é uma ferramenta de provisionamento de software de código aberto, 
# gerenciamento de configuração e implementação de aplicativos. Ele é executado 
# em muitos sistemas semelhantes ao Unix/Linux e pode configurar tanto sistemas 
# semelhantes ao Unix/Linux quanto o Microsoft Windows. Inclui sua própria 
# linguagem declarativa para descrever a configuração do sistema. Foi escrito por 
# Michael DeHaan e adquirido pela Red Hat em 2015. Ao contrário dos produtos 
# concorrentes, o Ansible não tem agente ele se conecta remotamente via SSH ou 
# PowerShell para executar suas tarefas.
#
# O Rundeck é uma aplicação java de código aberto que automatiza processos e rotinas 
# nos mais variados ambientes, gerenciado via interface gráfica fica extremamente 
# simples de verificar status de execuções, saídas de erro, etc. Muito utilizado 
# quando se trata de ambientes DevOps, principalmente em uma abordagem de Entrega 
# Contínua, onde em pequenos ciclos novas versões de software são construídas, 
# testadas e liberadas de forma confiável e em curtos períodos de tempo.
#
# Site Oficial do Projeto Ansible: https://www.ansible.com/
# Site Oficial do Projeto Rundeck: https://www.rundeck.com/open-source
#
# Outros projeto de Front End para o Ansible
# Ansible AWX: https://github.com/ansible/awx
# Polemarch..: https://polemarch.org/
#
# Configurações Básicas do Ansible
# URL: https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
# URL: https://docs.ansible.com/ansible/latest/reference_appendices/config.html
# opção do comando mkdir: -v (verbose)
# opção do comando chmod: -R (recursive), -v (verbose), 666 (User=RW-,Group=RW-Other=RW-)
# sudo vim /etc/ansible/hosts
# sudo vim /etc/ansible/ansible.cfg
# sudo mkdir -v /var/log/ansible
# sudo touch /var/log/ansible/ansible.log
# sudo chmod -Rv 666 /var/log/ansible/
#
# Comandos Básicos AD HOC (one-time tasks) do Ansible
# URL: https://docs.ansible.com/ansible/latest/command_guide/intro_adhoc.html
# URL: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ping_module.html
# URL: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html
# URL: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html
# URL: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/setup_module.html
# opções do comando ansible: -m (module-name), -a (args)
# sudo ansible localhost -m ping 
# sudo ansible localhost -m shell -a "cat /etc/os-release"
# sudo ansible localhost -m apt -a "update_cache=yes name=python3 state=present"
# sudo ansible localhost -m shell -a "apt list python3"
# sudo ansible localhost -m setup
#
# Informações que serão solicitadas na configuração via Web do Rundeck
# URL do Rundeck: http://pti.intra:4440/
# Nome de usuário: admin
# Senha: admin: Entrar
#
# Criando um Projeto Simples no Rundeck
# <Create a New Project>
#	Create a new Project
#		Detail
#			Project Name: ptispo01ws01
#			Label: WebServer
#			Description: Servidor Ubuntu Server
#	<Criar>
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
# Verificando se a porta 4440 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTRUNDECK &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTRUNDECK já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTRUNDECK está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando se as dependências do Rundeck estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Rundeck, aguarde... "
	for name in $RUNDECKDEP
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            echo -en "Recomendo utilizar o script: 03-dns.sh para resolver as dependências."
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
# Script de instalação do Ansible e do Rundeck no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Ansible e do Rundeck no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Rundeck.: TCP 4440"
echo -e "Após a instalação do Rundeck acessar a URL: http://$(hostname -d | cut -d' ' -f1):4440/\n"
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
echo -e "Iniciando a Instalação e Configuração do Ansible e do Rundeck, aguarde...\n"
sleep 5
#
echo -e "Adicionando o repositório PPA do Ansible, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt-add-repository: -y (yes)
	apt-add-repository -y $ANSIBLEPPA &>> $LOG
	apt update &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando as dependências do Ansible e do Rundeck, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $RUNDECKDEPINSTALL &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Ansible, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $ANSIBLEINSTALL &>> $LOG
echo -e "Ansible instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Rundeck, aguarde...\n"
sleep 5
#
echo -e "Verificando a versão do Java instalado, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	java -version &>> $LOG
echo -e "Versão do Java verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do Rundeck do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v rundeck.deb &>> $LOG
	wget $RUNDECKINSTALL -O rundeck.deb &>> $LOG
echo -e "Download do Rundeck feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Rundeck, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando dpkg: -i (install)
	dpkg -i rundeck.deb &>> $LOG
echo -e "Rundeck instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Plugin Ansible para o Rundeck, aguarde...\n"
sleep 5
#
echo -e "Fazendo o download do Plugin Ansible para o Rundeck do Github, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v ansible.jar &>> $LOG
	wget $PLUGINANSIBLE -O ansible.jar &>> $LOG
echo -e "Download do Plugin feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Plugin do Ansible para o Rundeck, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v ansible.jar /var/lib/rundeck/libext/ &>> $LOG
echo -e "Plugin do Ansible instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o arquivo de configuração do Rundeck, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	mv -v /etc/rundeck/rundeck-config.properties /etc/rundeck/rundeck-config.properties.old &>> $LOG
	cp -v conf/ansible/rundeck-config.properties /etc/rundeck/ &>> $LOG
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração rundeck-config.properties, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/rundeck/rundeck-config.properties
echo -e "Rundeck instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando o serviço do Rundeck, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable rundeckd &>> $LOG
	systemctl start rundeckd &>> $LOG
echo -e "Serviço iniciado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do Rundeck, aguarde..."
	echo -e "Rundeck: $(systemctl status rundeckd | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as versões dos serviços instalados, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (package information), \n (newline)
	echo -e "Ansible..: $(dpkg-query -W -f '${version}\n' ansible)"
	echo -e "Rundeck..: $(dpkg-query -W -f '${version}\n' rundeck)"
echo -e "Versões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Rundeck, aguarde..."
	# opção do comando nc: -v (verbose), -z (DCC mode)
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	nc -vz localhost 4440 &>> $LOG
	lsof -nP -iTCP:4440 -sTCP:LISTEN
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Ansible e do Rundeck feita com Sucesso!!!"
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
