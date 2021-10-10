#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 10/02/2019
# Data de atualização: 15/05/2021
# Versão: 0.06
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do Ansible 2.7.x, Rundeck 3.3.x
#
# O Ansible é uma ferramenta de provisionamento de software de código aberto, gerenciamento de configuração e 
# implementação de aplicativos. Ele é executado em muitos sistemas semelhantes ao Unix/Linux e pode configurar 
# tanto sistemas semelhantes ao Unix/Linux quanto o Microsoft Windows. Inclui sua própria linguagem declarativa 
# para descrever a configuração do sistema. Foi escrito por Michael DeHaan e adquirido pela Red Hat em 2015. Ao 
# contrário dos produtos concorrentes, o Ansible não tem agente ele se conecta remotamente via SSH ou PowerShell 
# para executar suas tarefas.
#
# Site Oficial do Projeto: https://www.ansible.com/
#
# O Rundeck é uma aplicação java de código aberto que automatiza processos e rotinas nos mais variados ambientes, 
# gerenciado via interface gráfica fica extremamente simples de verificar status de execuções, saídas de erro, etc. 
# Muito utilizado quando se trata de ambientes DevOps, principalmente em uma abordagem de Entrega Contínua, onde em 
# pequenos ciclos novas versões de software são construídas, testadas e liberadas de forma confiável e em curtos 
# períodos de tempo.
#
# Informações que serão solicitadas na configuração via Web do Rundeck
# Nome de usuário: admin
# Senha: admin: Entrar
#
# Site Oficial do Projeto: https://www.rundeck.com/open-source
#
# Outros projeto de Front End para o Ansible
# Ansible AWX: https://github.com/ansible/awx
# Polemarch: https://polemarch.org/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de configuração do OpenSSH no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=ecuol8Uf1EE&t
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
# Declarando a variável de download do Ansible e do Rundeck (Link atualizado no dia 15/05/2020)
PPA="ppa:ansible/ansible"
RUNDECK="https://dl.bintray.com/rundeck/rundeck-deb/rundeck_3.3.9.20210201-1_all.deb"
PLUGIN="https://github.com/Batix/rundeck-ansible-plugin/releases/download/3.1.1/ansible-plugin-3.1.1.jar"
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
# Verificando se as dependências do Rundeck estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências Ansible e Rundeck, aguarde... "
	for name in openjdk-8-jdk openjdk-8-jre
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            exit 1; 
            }
		sleep 5
#
# Script de instalação do Ansible e do Rundeck no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do Ansible no GNU/Linux Ubuntu Server 18.04.x"
echo -e "Após a instalação do Rundeck acessar a URL: http://`hostname -I | cut -d' ' -f1`:4440/\n"
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
echo -e "Atualizando o sistema, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Ansible, aguarde...\n"
#
echo -e "Adicionando o repositório do Ansible, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt-add-repository: -y (yes)
  	apt-add-repository -y $PPA &>> $LOG
  	apt update &>> $LOG
echo -e "Repositório do Ansible adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando as dependências do Ansible, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
  	apt -y install software-properties-common python &>> $LOG
echo -e "Dependências do Ansible instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Ansible, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando apt: -y (yes)
  	apt -y install ansible &>> $LOG
echo -e "Ansible instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Rundeck, aguarde...\n"
#
echo -e "Verificando a versão do Java instalado, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	java -version &>> $LOG
echo -e "Versão do Java verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando as dependências do Rundeck, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
  	apt -y openjdk-8-jdk-headless &>> $LOG
echo -e "Dependências do Rundeck instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do Rundeck do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v rundeck.deb &>> $LOG
	wget $RUNDECK -O rundeck.deb &>> $LOG
echo -e "Download do Rundeck feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Rundeck, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando dpkg: -i (install)
  	dpkg -i rundeck.deb &>> $LOG
	systemctl start rundeckd &>> $LOG
echo -e "Rundeck instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Rundeck, pressione <Enter> para continuar"
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando cp: -v (verbose)
	read
	sleep 3
	cp -v /etc/rundeck/rundeck-config.properties /etc/rundeck/rundeck-config.properties.bkp &>> $LOG
	cp -v conf/rundeck-config.properties /etc/rundeck/rundeck-config.properties &>> $LOG
	vim /etc/rundeck/rundeck-config.properties
	systemctl restart rundeckd &>> $LOG
echo -e "Rundeck instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do Ansible Plugin para o Rundeck do Github, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v ansible.jar &>> $LOG
	wget $PLUGIN -O ansible.jar &>> $LOG
echo -e "Download do Plugin do Ansible do Rundeck feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Plugin do Ansible do Rundeck, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando cp: -v (verbose)
  	cp -v ansible.jar /var/lib/rundeck/libext/ &>> $LOG
echo -e "Plugin do Ansible do Rundeck instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Rundeck, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric)
	sleep 3
	netstat -an | grep 4440
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Ansible e do Rundeck feita com Sucesso!!!."
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
