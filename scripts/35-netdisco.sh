#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 06/02/2022
# Data de atualização: 13/02/2022
# Versão: 0.02
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Netdisco v2.x
#
# O Netdisco é uma ferramenta de gerenciamento de rede adequada para redes pequenas 
# a muito grandes. Os dados de endereço IP e endereço MAC são coletados em um banco 
# de dados PostgreSQL usando SNMP, CLI ou APIs de dispositivo.
#
# Site Oficial do Netdisco: http://netdisco.org/
#
# MENSAGENS QUE SERÃO SOLICITADAS NA INSTALAÇÃO (DEPLOYMENT) DO NETDISCO:
# 01. digitar o comando: netdisco-deploy <Enter>
# 02. So, is all of the above in place? [y/N]:  y <Enter>
# 03. Would you like to deploy the database schema? [y/N]: y <Enter>
# 04. Username: netdisco <Enter>
# 05. Password: netdisco <Enter>
# 06. Download and update vendor MAC prefixes (OUI data)? [y/N]: y <Enter>
# 07. Download and update MIB files? [y/N]: y <Enter>
# 08. digitar o comando para sair: exit <Enter>
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
# Verificando se a porta 5000 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTNETDISCO &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTNETDISCO já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTNETDISCO está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando se as dependências do Netdisco estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Netdisco, aguarde... "
	for name in $NETDISCODEP
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            echo -en "Recomendo utilizar o script: 31-postgresql.sh para resolver as dependências."
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
# Script de instalação do Netdisco no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Netdisco no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Netdisco.: TCP 5000"
echo -e "Após a instalação do Netdisco acessar a URL: http://$(hostname -d | cut -d ' ' -f1):5000/\n"
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
echo -e "Iniciando a Instalação e Configuração do Netdisco, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do Netdisco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $NETDISCOINSTALLDEP &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o usuário do Netdisco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando useradd: -m (create-home) -p (password), -s (bash)
	useradd -m -p x -s /bin/bash $NETDISCOUSER &>> $LOG
echo -e "Usuário e Banco de Dados criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando os diretórios Base do Netdisco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando su: - (login), -c (command)
	# opção do comando mkdir: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	su - $NETDISCOUSER -c "mkdir -v /home/netdisco/{bin,environments}" &>> $LOG
echo -e "Diretórios Base criados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Usuário e o Banco de Dados do Netdisco, Senha padrão: $NETDISCOPASSWORD, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando su: - (login), -c (command)
	# opção do comando createuser: -D (no-createdb), -R (no-createrole), -S (no-superuser), -P (pwprompt)
	# opção do comando createdb: -O (owner)
	su - postgres -c "createuser -DRSP $NETDISCOUSER"
	su - postgres -c "createdb -O $NETDISCOUSER $DATABASE_NETDISCO"
echo -e "Usuário e Banco de Dados criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Netdisco, esse processo demora um pouco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando su: - (login), -c (command)
	# opção do comando curl: -L (location)
	su - $NETDISCOUSER -c "curl -L $NETDISCOINSTALL" &>> $LOG
echo -e "Netdisco instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando os Links Simbólicos do Netdisco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando su: - (login), -c (command)
	# opção do comando ln: -s (symbolic), -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	su - $NETDISCOUSER -c "ln -sv /home/netdisco/perl5/bin/{localenv,netdisco-*} /home/netdisco/bin/" &>> $LOG
echo -e "Links Simbólicos criados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do Netdisco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/netdisco/deployment.yml /home/netdisco/environments/ &>> $LOG
	cp -v conf/netdisco/netdisco-* /etc/systemd/system/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Alterando as permissões dos Diretórios e Arquivos do Netdisco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando chmod: 600 (User=RW-, Group=---, Other=---)
	# opção do comando chown: - R (recursive), -v (verbose), netdisco (user), netdisco (group)
	chmod 600 /home/netdisco/environments/deployment.yml &>> $LOG
	chown -Rv netdisco.netdisco /home/netdisco/environments/deployment.yml &>> $LOG
echo -e "Alteração feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração deployment.yml, aguarde..."
	# opção do comando read: -s (Do not echo keystrokes)
	# opção do comando su: - (login), -c (command)
	read -s
	su - $NETDISCOUSER -c "vim /home/netdisco/environments/deployment.yml"
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o Deployment do Netdisco, pressione <Enter> para continuar.\n"
echo -e "CUIDADO!!! com as opções que serão solicitadas no decorrer da instalação do Netdisco."
echo -e "Digite o comando: netdisco-deploy <Enter> para a instalação e: exit <Enter> para sair."
echo -e "Veja a documentação das opções de instalação a partir da linha: 20 do script $0"
	# opção do comando read: -s (Do not echo keystrokes)
	# opção do comando su: - (login), -c (command)
	read -s
	su - $NETDISCOUSER
echo -e "Deployment do Netdisco feito sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando os Serviços do Netdisco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable netdisco-daemon &>> $LOG
	systemctl enable netdisco-web &>> $LOG
	systemctl start netdisco-daemon &>> $LOG
	systemctl start netdisco-web &>> $LOG
echo -e "Serviços reinicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do Netdisco, aguarde..."
	echo -e "Netdisco....: $(systemctl status netdisco-daemon | grep Active)"
	echo -e "Netdisco-Web: $(systemctl status netdisco-web | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Netdisco, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:5000 -sTCP:LISTEN
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Netdisco feita com Sucesso!!!"
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

