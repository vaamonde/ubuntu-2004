#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 21/12/2021
# Data de atualização: 12/01/2022
# Versão: 0.03
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do Graylog v4.2
# Testado e homologado para a versão do MongoDB v4.4.x
# Testado e homologado para a versão do ElasticSearch v6.0.x
#
# O Graylog captura, armazena e permite centralizar a pesquisa e a análise de logs 
# em tempo real de qualquer componente da infraestrutura e aplicativos de TI. O 
# software utiliza uma arquitetura de três camadas de armazenamento escalável baseado 
# no ElasticSearch (Elasticsearch é um servidor de buscas distribuído baseado no 
# Apache Lucene)e no MongoDB (MongoDB é um software de banco de dados orientado a 
# documentos NoSQL).
#
# Site Oficial do Projeto: https://www.graylog.org/
# Site Oficial do MongoDB: https://www.mongodb.com/
# Site Oficial do Elasticsearch: https://www.elastic.co/pt/
#
# Informações que serão solicitadas na configuração via Web do Graylog
# Username: admin
# Password: graylog: Sign In
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
# Verificando se as dependências do Graylog Server estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Graylog Server, aguarde... "
	for name in $GRAYLOGDEP
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
# Verificando se as portas 19000, 27017 e 9200 estão sendo utilizadas no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $GRAYLOGPORT &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $GRAYLOGPORT já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $GRAYLOGPORT está disponível, continuando com o script..."
		sleep 5
fi
if [ "$(nc -vz 127.0.0.1 $MONGODBPORT &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $MONGODBPORT já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $MONGODBPORT está disponível, continuando com o script..."
		sleep 5
fi
if [ "$(nc -vz 127.0.0.1 $ELASTICSEARCHPORT &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $ELASTICSEARCHPORT já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $ELASTICSEARCHPORT está disponível, continuando com o script..."
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
# Script de instalação do Graylog Server no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Graylog Server no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Graylog Server.: TCP 19000"
echo -e "Porta padrão utilizada pelo MongoDB Server.: TCP 27017"
echo -e "Porta padrão utilizada pelo ElasticSearch..: TCP 9200\n"
echo -e "Após a instalação do Graylog acessar a URL: http://$(hostname -d | cut -d' ' -f1):19000/\n"
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
echo -e "Iniciando a Instalação e Configuração do Graylog Server, aguarde...\n"
sleep 5
#
echo -e "Adicionando o repositório do MongoDB Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando wget: -q (quiet), -O (output document file)
	# opção do comando cp: -v (verbose)
	wget -qO - $KEYSRVMONGODB | apt-key add - &>> $LOG
	cp -v conf/graylog/mongodb-org-4.x.list /etc/apt/sources.list.d/ &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o repositório do ElasticSearch, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando wget: -q (quiet), -O (output document file)
	# opção do comando cp: -v (verbose)
	wget -qO - $GPGKEYELASTICSEARCH | apt-key add - &>> $LOG
	cp -v conf/graylog/elastic-6.x.list /etc/apt/sources.list.d/ &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o repositório do Graylog Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	# opção do comando dpkg: -i (install)
	rm -v graylog.deb &>> $LOG
	wget $REPGRAYLOG -O graylog.deb &>> $LOG
	dpkg -i graylog.deb &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt com os novos Repositórios, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt update &>> $LOG
	apt -y upgrade &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando as dependências do Graylog Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	# opção do comando update-java-alternatives: -l (list)
  	apt -y install $GRAYLOGINSTALLDEP &>> $LOG
	java -version &>> $LOG
	update-java-alternatives -l &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o MongoDB Server, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando apt: -y (yes)
  	apt -y install $MONGODBINSTALL &>> $LOG
echo -e "MongoDB instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o ElasticSearch, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	# opção do comando cp: -v (verbose)
	apt -y install $ELASTICSEARCHINSTALL &>> $LOG
echo -e "ElasticSearch instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do ElasticSearch, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	mv -v /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.old &>> $LOG
	mv -v /etc/elasticsearch/jvm.options /etc/elasticsearch/jvm.options.old &>> $LOG
	cp -v conf/graylog/{elasticsearch.yml,jvm.options} /etc/elasticsearch/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração elasticsearch.yml, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/elasticsearch/elasticsearch.yml
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração jvm.options, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/elasticsearch/jvm.options
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Inicializando os serviços do MongoDB e do ElasticSearch, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando curl: -X (request)
	systemctl enable mongod &>> $LOG
	systemctl restart mongod &>> $LOG
	systemctl enable elasticsearch &>> $LOG
	systemctl restart elasticsearch &>> $LOG
	curl -X GET http://localhost:9200 &>> $LOG
echo -e "Serviços inicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Graylog Server, aguarde esse processo demora um pouco..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt install -y $GRAYLOGINSTALL &>> $LOG
echo -e "Graylog instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do Graylog Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comando sed: s (replacement)
	mv -v /etc/graylog/server/server.conf /etc/graylog/server/server.conf.old &>> $LOG
	cp -v conf/graylog/server.conf /etc/graylog/server/server.conf &>> $LOG
	sed "s/password_secret =/password_secret = $SECRETGRAYLOG/" /etc/graylog/server/server.conf > /tmp/server.conf.old
	sed "s/root_password_sha2 =/root_password_sha2 = $SHA2GRAYLOG/" /tmp/server.conf.old > /etc/graylog/server/server.conf
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração server.conf, pressione <Enter> para editar..."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/graylog/server/server.conf
echo -e "Arquivo do editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Inicializando o Serviço Graylog Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable graylog-server &>> $LOG
	systemctl restart graylog-server &>> $LOG
echo -e "Serviço do Graylog iniciado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando os serviços do Graylog, MongoDB e do ElasticSearch, aguarde..."
	echo -e "Graylog: $(systemctl status graylog-server | grep Active)"
	echo -e "MongoDB: $(systemctl status mongod | grep Active)"
	echo -e "Elastic: $(systemctl status elasticsearch | grep Active)"
echo -e "Serviços verificados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexão do Graylog, MongoDB e do ElasticSearch, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	echo -e "OBS: a porta de serviço do Graylog Server demora para iniciar."
	lsof -nP -iTCP:'9200,19000,27017' -sTCP:LISTEN
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Graylog Server feita com Sucesso!!!."
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
