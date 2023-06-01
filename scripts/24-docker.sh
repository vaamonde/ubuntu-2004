#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 15/12/2021
# Data de atualização: 26/05/2023
# Versão: 0.07
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Docker v23.x e Portainer v2.18.x
#
# O Docker é uma tecnologia de software que fornece contêineres, promovido pela empresa 
# Docker, Inc. O Docker fornece uma camada adicional de abstração e automação de 
# virtualização de nível de sistema operacional no Windows e no Linux. O Docker usa as 
# características de isolação de recurso do núcleo do Linux como cgroups e espaços de 
# nomes do núcleo, e um sistema de arquivos com recursos de união, como OverlayFS e 
# outros para permitir "contêineres" independentes para executar dentro de uma única 
# instância Linux, evitando a sobrecarga de iniciar e manter máquinas virtuais (VMs).
#
# O Docker Compose é uma ferramenta para definir e executar aplicativos Docker de vários 
# contêineres. Com o Compose, você usa um arquivo YAML para configurar os serviços do seu 
# aplicativo. Então, com um único comando, você cria e inicia todos os serviços da sua 
# configuração. Para saber mais sobre todos os recursos do Compose.
#
# O Portainer.io uma solução de gerenciamento para o Docker, com ele é possível gerenciar 
# facilmente os seus hosts Docker e clusters com Docker Swarm através de uma interface web 
# limpa, simples e intuitiva.
#
# Site oficial do Projeto Docker Community: https://www.docker.com/docker-community
# Site oficial do Projeto Docker Compose: https://docs.docker.com/compose/
# Site oficial do Projeto Portainer: https://portainer.io/
#
# Soluções Open Source de Container
# Site Oficial do Projeto ContainerD: https://containerd.io/
# Site Oficial do Projeto LXC: https://linuxcontainers.org/
# Site Oficial do Kubernetes: https://kubernetes.io/pt-br/
#
# Comandos básicos do Docker no Terminal
#	docker version              #versão do docker
#	docker-compose version      #versão do docker-compose
#	docker info                 #informações do docker
#	docker system info          #informações do sistema do docker
#	docker search hello-world   #pesquisando um container no docker
#	docker run hello-world      #rodando um container no docker
#	docker search ubuntu        #pesquisando um container no docker
#	docker run -it ubuntu bash  #rodando um container no docker
#	docker images               #verificando as imagens de container no docker
#	docker ps                   #verificando os processos do docker
#
# Informações que serão solicitadas na configuração via Web do Portainer.io
# URL: http://pti.intra:9000
# Username: admin;
# Password: vaamonde@2018;
# Confirm password: vaamonde@2018: Create User;
# Connect Portainer to the Docker environment you want to manage: Local: Connect
#
# Configuração do Docker Compose do NGINX
#   Local:
#       Stacks:
#           Add stack:
#               Name: webserver
#               Web editor: (copiar o docker-compose do NGIX)
#               Enable Access Control: OFF
#               Deploy the Stack.
#services:
# web:
#  image: nginx:latest
#  container_name: nginx
#  restart: always
#  ports:
#   - "8080:80"
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
# Verificando se a porta 9000 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTPORTAINER &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTPORTAINER já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTPORTAINER está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando se as dependências do Docker Community estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Docker Community, aguarde... "
	for name in $DOCKERDEP
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
# Script de instalação do Docker Community e do Portainer.io no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Docker Community e do Portainer.io no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Portainer.io.: TCP 9000\n"
echo -e "Após a instalação do Portainer.io acessar a URL: http://$(hostname -d | cut -d ' ' -f1):9000/\n"
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
echo -e "Iniciando a Instalação e Configuração do Docker Community, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do Docker Community, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes), \ (bar left) quebra de linha na opção do apt
	apt -y install $DOCKERINSTALLDEP &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando a Chave GPG do Docker Community, aguarde..."
	# opção do comando curl: -f (fail), -s (silent), -S (show-error), -L (location)
	# opção do comando apt-key add: - (file name recebido do redirecionador | )
	curl -fsSL $DOCKERGPG | apt-key add - &>> $LOG
echo -e "Chave adicionada com sucesso!!!, continuando com o script...\n"
sleep 5
#				 
echo -e "Verificando a Chave GPG do Docker Community, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt-key fingerprint $DOCKERKEY &>> $LOG
echo -e "Chave verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o repositório do Docker Community, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository "$DOCKERREP" &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt com o novo repositório do Docker, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Docker Community CE, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $DOCKERINSTALL &>> $LOG
echo -e "Docker instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Docker Compose do Github, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando wget: -O (Output File)
	# opção do comando cp: -v (verbose)
	# opção do comando chmod: -v (verbose), +x (add executable for all)
	# opção do comando ln: -v (verbose), -s (link symbolic)
	wget -O docker-compose $DOCKERCOMPOSE &>> $LOG
	cp -v docker-compose /usr/local/bin/ &>> $LOG
	chmod -v +x /usr/local/bin/docker-compose &>> $LOG
	ln -vs /usr/local/bin/docker-compose /usr/bin/docker-compose &>> $LOG
	docker-compose --version &>> $LOG
echo -e "Docker Compose instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o usuário Root no Grupo do Docker, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando usermod: -a (append), -G (groups), docker (grupo) docker (usuário)
	usermod -a -G docker $USER &>> $LOG
echo -e "Usuário adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando o Serviço Docker Community, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl start docker &>> $LOG
echo -e "Serviço iniciado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando o Container de teste Hello-Word do Docker Community, aguarde..."
	docker run hello-world
	echo
echo -e "Container executado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando o Container de Teste do Ubuntu, aguarde..."
echo -e "Para sair do Container de Teste do Ubuntu utilize o comando: exit\n"
	# opção do comando docker: -i (Keep STDIN open even if not attached), -t (Allocate a pseudo-TTY)
	docker run -it ubuntu bash
	echo
echo -e "Container executado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando a Instalação e Configuração do Portainer.io, aguarde...\n"
sleep 5
#
echo -e "Criando o volume do Portainer.io no Docker, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	docker volume create portainer_data &>> $LOG
echo -e "Volume criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Container do Portainer.io no Docker, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando docker: -d (Run container in background and print container ID), 
	# -p (Publish a container’s port(s) to the host), -v (Bind mount a volume)
	docker run --name portainer -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer &>> $LOG
echo -e "Container criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Serviço de Inicialização Automática do Portainer.io, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/docker/portainer.service /etc/systemd/system/ &>> $LOG
	systemctl daemon-reload &>> $LOG
	systemctl enable portainer &>> $LOG
	systemctl start portainer &>> $LOG
echo -e "Serviço criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando os serviços do Docker e Portainer.io, aguarde..."
	echo -e "Docker...: $(systemctl status docker | grep Active)"
	echo -e "Portainer: $(systemctl status portainer | grep Active)"
echo -e "Serviços verificados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as versões dos serviços instalados, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (package information), \n (newline)
	echo -e "Docker Compose..: $(docker-compose --version)"
	echo -e "Docker Server...: $(dpkg-query -W -f '${version}\n' docker-ce)"
	echo -e "Portainer.io....: $()"
echo -e "Versões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Portainer.io, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:9000 -sTCP:LISTEN
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Docker Community e do Portainer.io feita com Sucesso!!!"
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