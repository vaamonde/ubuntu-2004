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
# Data de atualização: 21/01/2022
# Versão: 0.03
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do OpenFire v4.6.x
#
# Extensible Messaging and Presence Protocol (XMPP) (conhecido anteriormente como Jabber) 
# é um protocolo aberto, extensível, baseado em XML, para sistemas de mensagens instantâneas,
# desenvolvido originalmente para mensagens instantâneas e informação de presença formalizado 
# pelo IETF. Softwares com base XMPP são distribuídos em milhares de servidores através da 
# internet, e usados por cerca de dez milhões de pessoas em todo mundo, de acordo com a XMPP 
# Standards Foundation.
#
# O OpenFire (anteriormente conhecido como Wildfire e Jive Messenger) é um servidor de 
# mensagens instantâneas e de conversas em grupo que usa o servidor XMPP escrito em Java 
# e licenciado sob a licença Apache 2.0.
#
# Site Oficial do Projeto OpenFire: https://www.igniterealtime.org/projects/openfire/
#
# Informações que serão solicitadas na configuração via Web do OpenFire
# Welcome to Setup:
#		Português Brasileiro (pt_BR)
#	Continuar;
# Configurações do Servidor:
#		Domínio: pti.intra
#		Server Host Name (FQDN): ptispo01ws01.pti.intra
#		Porta do Console Admin: 9090
#		Porta Segura do Console Admin: 9091: 
#		Blowfish
#	Continuar;
# Configurações do Banco de Dados:
#		Conexão Padrão do Banco de Dados
#	Continuar;
# Configurações do Banco de Dados - Conexão Padrão:
#		Predefinições do Driver de Banco de Dados: MySQL
#		Classe do Driver JDBC: com.mysql.cj.jdbc.Driver
#		URL do banco de dados: jdbc:mysql://localhost:3306/openfire?rewriteBatchedStatements=true&characterEncoding=UTF-8&characterSetResults=UTF-8&serverTimezone=UTC
#		Nome do Usuário: openfire
#		Senha: openfire
#		Minimum Connections: 5
#		Maximum Connections: 25
#		Tempo de expiração da Conexão: 1
#	Continuar;
# Configurações de Perfis:
#		Padrão
#	Continuar;
# Conta do Administrador:
#		Endereço de e-mail do Admin: vaamonde@pti.intra
#		Nova senha: pti@2018
#		Confirme a senha: pti@2018
#	Continuar;
# Loge-se no console de administração.
#
# Usuário padrão: admin
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
# Verificando se a porta 9090 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTOPENFIRE &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTOPENFIRE já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTOPENFIRE está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando se as dependências do OpenFire estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do OpenFire, aguarde... "
	for name in $OPENFIREDEP
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
# Script de instalação do OpenFire no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do OpenFire no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo OpenFire.: TCP 9090"
echo -e "Após a instalação do OpenFire acessar a URL: http://$(hostname -d | cut -d' ' -f1):9090/\n"
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
	# opção do comando: &>> (redirecionar de saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando todo o sistema operacional, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
	apt -y dist-upgrade &>> $LOG
	apt -y full-upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo todos os software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
	apt -y autoclean &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando a Instalação e Configuração do OpenFire, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do OpenFire, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $OPENFIREINSTALLDEP &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a versão do Java instalado, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	java -version &>> $LOG
echo -e "Versão do Java verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do OpenFire do site oficial, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando wget: -O (output document file)
	# opção do comando rm: -v (verbose)
	rm -v openfire.deb &>> $LOG
	wget $OPENFIREINSTALL -O openfire.deb &>> $LOG
echo -e "Download do OpenFire feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o OpenFire, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando dpkg: -i (install)
	dpkg -i openfire.deb &>> $LOG
echo -e "OpenFire instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Banco de Dados do OpenFire, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute)
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando: | piper (conecta a saída padrão com a entrada padrão de outro comando)
	# opção do comando mysql: -u (user), -p (password), -e (execute)
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_DATABASE_OPENFIRE" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL < $CREATE_TABLE_OPENFIRE $DATABASE_OPENFIRE &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$CREATE_USER_DATABASE_OPENFIRE" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_DATABASE_OPENFIRE" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$GRANT_ALL_DATABASE_OPENFIRE" mysql &>> $LOG
	mysql -u $USERMYSQL -p$SENHAMYSQL -e "$FLUSH_OPENFIRE" mysql &>> $LOG
echo -e "Banco de Dados criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando o serviço do OpenFire, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable openfire &>> $LOG
	systemctl start openfire &>> $LOG
echo -e "Serviço do OpenFire iniciado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do OpenFire, aguarde..."
	echo -e "Openfire: $(systemctl status openfire | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do OpenFire, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:9090 -sTCP:LISTEN
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do OpenFire feita com Sucesso!!!"
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
