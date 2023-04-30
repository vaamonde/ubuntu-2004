#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 22/08/2022
# Data de atualização: 25/09/2022
# Versão: 0.05
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do GLPI Help Desk v10.0.x
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
# Site oficial do Projeto GLPI: https://glpi-project.org/pt-br/
#
# Soluções Open Source de Help Desk
# Site oficial do Projeto OTRS: https://otrs.com/
# Site oficial do Projeto iTop: https://www.combodo.com/itop
#
# Indicação da Empresa Especializada em GLPI Help Desk no Brasil
# ServiceDesk Brasil site: https://www.servicedeskbrasil.com.br/
# Blog da ServiceDesk Brasil: https://blog.servicedeskbrasil.com.br/
# Canal do YouTUBE: https://www.youtube.com/servicedeskbrasil
#
# Informações que serão solicitadas na configuração via Web do GLPI
# GLPI Setup
# Selecione seu idioma: Português do Brasil: <OK>;
# Licença: <Continuar>;
# Início da instalação: <Instalar>;
# Etapa 0: Verificando a compatibilidade do seu ambiente para a execução do GLPI: <Continuar>;
# Etapa 1: Instalação da conexão com o banco de dados:
#	SQL server(MariaDB ou MySQL): localhost
#	Usuário SQL: glpi10
#	Senha SQL: glpi10: <Continuar>;
# Etapa 2: Teste de conexão com o banco de dados: glpi10: <Continuar>;
# Etapa 3: Iniciando banco de dados: <Continuar>;
# Etapa 4: Coletar dados: <Continuar>;
# Etapa 5: Uma última coisa antes de começar: <Continuar>;
# Etapa 6: A instalação foi concluída: <Usar GLPI>
#
# Usuário/Senha: glpi/glpi - conta do usuário administrador
# Usuário/Senha: tech/tech - conta do usuário técnico
# Usuário/Senha: normal/normal - conta do usuário normal
# Usuário/Senha: post-only/postonly - conta do usuário postonly
#
# Configurações básicas pós instalação do GLPI Help Desk v10.x
# Administração
#	Usuários
#		Alterar senha: glpi
#			Senha: pti@2018
#			Confirmação de senha: pti@2018
#		Desativar contas: normal, post-only, tech
#		Adicionar novo usuário: vaamonde
#			Usuário: vaamonde
#			Sobrenome: Vaamonde
#			Nome: Robson
#			Senha: pti@2018
#			Confirmação da senha: pti@2018
#			Perfil: Super-Admin
#
# Software utilizados pelo Agente do GLPI Help Desk v10.x
# glpi-agent: Agente de Inventário e Tarefas Local do GLPI Help Desk v10.x
# glpi-injector: Uma ferramenta para enviar inventário em um Inventário OCS ou servidor compatível.
# glpi-inventory: Inventário autônomo do GLPI Help Desk v10.x
# glpi-remote: Uma ferramenta para escanear, gerenciar e inicializar agentes remotos virtuais
# glpi-wakeonlan: Wake-on-lan autônomo do GLPI Help Desk v10.x
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
echo -n "Verificando as dependências do GLPI Help Desk 10.0.x, aguarde... "
	for name in $GLPIDEP
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
			echo -en "Recomendo utilizar o script: 11-B-openssl-apache.sh para resolver as dependências."
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
echo -e "Instalação e Configuração do GLPI Help Desk 10.0.x no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Após a instalação do GLPI acessar a URL: https://glpi10.$(hostname -d | cut -d' ' -f1)\n"
echo -e "Link de download dos Agentes do GLPI URL: https://$(hostname -d | cut -d' ' -f1)/agentesglpi\n"
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
echo -e "Iniciando a Instalação e Configuração do GLPI Help Desk 10.0.x, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do GLPI Help Desk 10.0.x, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes), \ (faz a função de quebra de pagina no comando apt)
	apt -y install $GLPIINSTALL10 &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do GLPI Help Desk 10.0.x do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v glpi10.tgz &>> $LOG
	wget $GLPI10 -O glpi10.tgz &>> $LOG
echo -e "Download do GLPI feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Descompactando e Instalando o GLPI Help Desk 10.0.x no site do Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando tar: -z (gzip), -x (extract), -v (verbose), -f (file)
	# opção do comando mv: -v (verbose)
	# opção do comando chown: -R (recursive), -v (verbose), www-data.www-data (user and group)
	# opção do comando find: . (path), -type d (directory), , type f (file), -exec (execute command)
	# opção do comando chmod: -v (verbose), 755 (Dono=RWX,Grupo=R-X,Outros=R-X)
	# opção do comando chmod: -v (verbose), 644 (Dono=RW-,Grupo=R--,Outros=R--)
	# opção do comando {} \;: executa comandos em lote e aplicar as permissões para cada arquivo/diretório em loop
	# opção do comando chmod: -R (recursive), -v (verbose), 777 (User=RWX, Group=RWX, Other=RWX)
	tar -zxvf glpi10.tgz &>> $LOG
	mv -v glpi/ $PATHGLPI10 &>> $LOG
	chown -Rv www-data:www-data $PATHGLPI10 &>> $LOG
	find $PATHGLPI10/. -type d -exec chmod -v 755 {} \; &>> $LOG
	find $PATHGLPI10/. -type f -exec chmod -v 644 {} \; &>> $LOG
	chmod -Rv 777 $PATHGLPI10/files/_log &>> $LOG
echo -e "GLPI instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Banco de Dados do GLPI Help Desk 10.0.x, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute), mysql (database)
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_DATABASE_GLPI10" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_USER_DATABASE_GLPI10" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_DATABASE_GLPI10" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_ALL_DATABASE_GLPI10" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH_GLPI10" mysql &>> $LOG
echo -e "Banco de Dados criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do GLPI Help Desk 10.0.x, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/glpi/glpi10/glpi.conf /etc/apache2/conf-available/glpi10.conf &>> $LOG
	cp -v conf/glpi/glpi10/glpi1.conf /etc/apache2/sites-available/glpi10.conf &>> $LOG
	cp -v conf/glpi/glpi10/glpi-cron /etc/cron.d/glpi10-cron &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do glpi10.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/apache2/conf-available/glpi10.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de Virtual Host glpi10.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/apache2/sites-available/glpi10.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de agendamento glpi10-cron, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/cron.d/glpi10-cron
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando o Virtual Host do GLPI Help Desk 10.0.x no Apache2, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando phpenmod: (habilitar módulos do PHP)
	# opção do comando a2enconf: (habilitar arquivo de configuração de site do Apache2)
	# opção do comando a2ensite: (habilitar arquivo de virtual host de site do Apache2)
	# opção do comando systemctl: restart (reinicializar o serviço)
	phpenmod apcu &>> $LOG
	a2enconf glpi10 &>> $LOG
	a2ensite glpi10 &>> $LOG
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
	systemctl reload apache2 &>> $LOG
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
	echo -e "Apache2 Server.....: $(dpkg-query -W -f '${version}\n' apache2)"
	echo -e "GLPI 10 Help Desk..: $()"
	echo -e "OpenSSL............: $(dpkg-query -W -f '${version}\n' openssl)"
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
echo -e "Verificando o Virtual Host do GLPI Help Desk 10.0.x no Apache2, aguarde..."
	# opção do comando apachectl: -s (a synonym)
	apache2ctl -S | grep glpi10.$DOMINIOSERVER
echo -e "Virtual Host verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "ANTES DE CONTINUAR COM O SCRIPT ACESSE A URL: https://glpi10.$(hostname -d | cut -d' ' -f1)/"
echo -e "PARA FINALIZAR A CONFIGURAÇÃO VIA WEB DO GLPI HELP DESK, APÓS A"
echo -e "CONFIGURAÇÃO PRESSIONE <ENTER> PARA CONTINUAR COM O SCRIPT."
echo -e "MAIS INFORMAÇÕES NA LINHA 27 DO SCRIPT: $0"
read
sleep 5
#
echo -e "Removendo o script de instalação do GLPI Help Desk 10.0.x, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	mv -v $PATHGLPI10/install/install.php $PATHGLPI10/install/install.php.old &>> $LOG
echo -e "Arquivo removido com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o diretório de download dos Agentes do GLPI Help Desk 10.0.x, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando chown: -v (verbose)
	# opção do comando chmod: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comando wget: -O (output document file)
	mkdir -v $DOWNLOADAGENTGLPI &>> $LOG
	chown -v www-data.www-data $DOWNLOADAGENTGLPI &>> $LOG
	chmod -v 755 $DOWNLOADAGENTGLPI &>> $LOG
	cp -v conf/glpi/glpi10/agent.cfg $DOWNLOADAGENTGLPI &>> $LOG
	wget $AGENTGLPIWINDOWS32 -O $DOWNLOADAGENTGLPI/agent_windows32.exe &>> $LOG
	wget $AGENTGLPIWINDOWS64 -O $DOWNLOADAGENTGLPI/agent_windows64.exe &>> $LOG
	wget $AGENTGLPIMAC -O $DOWNLOADAGENTGLPI/agent_macos.dmg &>> $LOG
	wget $AGENTGLPILINUX -O $DOWNLOADAGENTGLPI/agent_linux.deb &>> $LOG
	wget $AGENTGLPILINUXNETWORK -O $DOWNLOADAGENTGLPI/agent_linux_network.deb &>> $LOG
	wget $AGENTGLPILINUXCOLLECT -O $DOWNLOADAGENTGLPI/agent_linux_collect.deb &>> $LOG
	wget $AGENTGLPILINUXDEPLOY -O $DOWNLOADAGENTGLPI/agent_linux_deploy.deb &>> $LOG
echo -e "Diretório criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o diretório de agentes: https://$(hostname -d | cut -d' ' -f1)/agentesglpi/, aguarde..."
	tree $DOWNLOADAGENTGLPI
echo -e "Diretório verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do GLPI Help Desk 10.0.x feita com Sucesso!!!."
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
