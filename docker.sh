#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 12/11/2018
# Data de atualização: 27/04/2021
# Versão: 0.09
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do Docker 19.03.x, Portainer 1.24.x
#
# O Docker é uma tecnologia de software que fornece contêineres, promovido pela empresa Docker, Inc. O Docker fornece uma 
# camada adicional de abstração e automação de virtualização de nível de sistema operacional no Windows e no Linux. O Docker
# usa as características de isolação de recurso do núcleo do Linux como cgroups e espaços de nomes do núcleo, e um sistema de
# arquivos com recursos de união, como OverlayFS e outros para permitir "contêineres" independentes para executar dentro de 
# uma única instância Linux, evitando a sobrecarga de iniciar e manter máquinas virtuais (VMs).
#
# Site oficial: https://www.docker.com/docker-community
#
# O Portainer.io uma solução de gerenciamento para o Docker, com ele é possível gerenciar facilmente os seus hosts Docker e 
# clusters com Docker Swarm através de uma interface web limpa, simples e intuitiva.
#
# Informações que serão solicitadas na configuração via Web do Portainer
# Username: admin;
# Password: pti@2018;
# Confirm password: pti@2018: Create User;
# Connect Portainer to the Docker environment you want to manage: Local: Connect
#
# Site oficial: https://portainer.io/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
#
# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário é "root", versão do ubuntu e kernel
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
# Declarando as variáveis para o download Docker (Link atualizado no dia 22/07/2020)
DOCKERGPG="https://download.docker.com/linux/ubuntu/gpg"
DOCKERDEB="deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
DOCKERKEY="0EBFCD88"
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
# Script de instalação do Docker e Portainer no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do Docker e Portainer no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do Portainer acessar a URL: http://`hostname -I | cut -d ' ' -f1`:9000/\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet..."
sleep 5
echo
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
	# opção do comando: &>> (redirecionar a saída padrão)
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
echo -e "Instalando o Docker e o Portainer, aguarde..."
echo
#
echo -e "Instalando as dependências do Docker, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes), \ (bar left) quebra de linha na opção do apt
	apt -y install apt-transport-https ca-certificates curl software-properties-common linux-image-generic \
	linux-image-extra-virtual &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Adicionando as Chaves GPG do Docker, aguarde..."
	# opção do comando curl: -f (fail), -s (silent), -S (show-error), -L (location)
	# opção do comando apt-key add: - (file name recebido do redirecionador | )
	curl -fsSL $DOCKERGPG | apt-key add -
echo -e "Chaves adicionadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#				 
echo -e "Verificando as Chaves do GPG do Docker, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt-key fingerprint $DOCKERKEY &>> $LOG
echo -e "Chaves verificadas com sucesso com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Adicionando o repositório do Docker, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository "$DOCKERDEB" &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando novamente as listas do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o Docker, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install docker-ce cgroup-lite &>> $LOG
echo -e "Docker instalado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Adicionando o usuário Root do Grupo do Docker, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando usermod: -a (append), -G (groups), docker (grupo) docker (usuário)
	usermod -a -G docker $USER &>> $LOG
echo -e "Usuário adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Iniciando o Serviço Docker, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl start docker &>> $LOG
echo -e "Serviço iniciado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Docker instalado com sucesso!!!, pressione <Enter> para continuar com o script."
read
sleep 5
#
echo -e "Iniciando o Container de teste do Docker, aguarde..."
	docker run hello-world
	echo
echo -e "Container executado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Iniciando o Container de Teste do Ubuntu, aguarde..."
echo -e "Para sair do Container utilize o comando: exit"
echo
	# opção do comando docker: -i (Keep STDIN open even if not attached), -t (Allocate a pseudo-TTY)
	docker run -it ubuntu bash
	echo
echo -e "Container executado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Container criados com sucesso!!!, pressione <Enter> para continuar com o script."
read
sleep 5
#
echo -e "Instalando o Portainer, aguarde..."
sleep 3
echo
#
echo -e "Criando o volume do Portainer, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	docker volume create portainer_data &>> $LOG
echo -e "Volume criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Criando o Container do Portainer, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando docker: -d (Run container in background and print container ID), -p (Publish a container’s port(s) 
	# to the host), -v (Bind mount a volume)
	docker run --name portainer -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer &>> $LOG
echo -e "Container criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Criando o Serviço de Inicialização Automática do Portainer, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/portainer.service /etc/systemd/system/ &>> $LOG
	systemctl daemon-reload &>> $LOG
	systemctl enable portainer &>> $LOG
	systemctl start portainer &>> $LOG
echo -e "Serviço criado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Verificando a porta de conexão do Portainer, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric)
	netstat -an | grep 9000
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalação do Docker e Portainer feita com Sucesso!!!"
	# script para calcular o tempo gasto (SCRIPT MELHORADO, CORRIGIDO FALHA DE HORA:MINUTO:SEGUNDOS)
	# opção do comando date: +%T (Time)
	HORAFINAL=`date +%T`
	# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second), 
	TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
	# $0 (variável de ambiente do nome do comando)
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1