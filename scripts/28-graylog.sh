#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 26/07/2020
# Data de atualização: 18/05/2021
# Versão: 0.04
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do Graylog 3.3.x
#
# O Graylog captura, armazena e permite centralizar a pesquisa e a análise de logs em tempo real de qualquer 
# componente da infraestrutura e aplicativos de TI. O software utiliza uma arquitetura de três camadas de 
# armazenamento escalável baseado no ElasticSearch (Elasticsearch é um servidor de buscas distribuído baseado 
# no Apache Lucene)e no MongoDB (MongoDB é um software de banco de dados orientado a documentos NoSQL).
#
# Informações que serão solicitadas na configuração via Web do Graylog
# Username: admin
# Password: graylog: Sign In
#
# Site Oficial do Projeto: https://www.graylog.org/
# Site Oficial do MongoDB: https://www.mongodb.com/
# Site Oficial do Elasticsearch: https://www.elastic.co/pt/
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
# Declarando as variáveis de download do Graylog (Links atualizados no dia 22/07/2020)
# opção do comando pwgen: -N (num passwords), -s (secure)
# opção do comando tr: -d (delete)
# opção do comando cut: -d (delimiter), -f (fields)
KEYSRVMONGODB="https://www.mongodb.org/static/pgp/server-4.2.asc"
KEYELASTICSEARCH="https://artifacts.elastic.co/GPG-KEY-elasticsearch"
REPGRAYLOG="https://packages.graylog2.org/repo/packages/graylog-3.3-repository_latest.deb"
USERGRAYLOG="graylog"
SECRET=$(pwgen -N 1 -s 96)
SHA2=$(echo $USERGRAYLOG | tr -d '\n' | sha256sum | cut -d" " -f1)
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
# Verificando se as dependências do Graylog estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Graylog, aguarde... "
	for name in pwgen 
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
# Script de instalação do Graylog no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do Graylog no GNU/Linux Ubuntu Server 18.04.x"
echo -e "Após a instalação do Graylog acessar a URL: http://`hostname -I | cut -d' ' -f1`:19000/\n"
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
echo -e "Instalando o Graylog, aguarde...\n"
#
echo -e "Adicionando o repositório do MongoDB, aguarde..."
	# baixando e instalando a chave GPG do MongoDB
	# copiando o source list do MongoDB para o diretório do Apt
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando wget: -q (quiet), -O (output document file)
	# opção do comando cp: -v (verbose)
	wget -qO - $KEYSRVMONGODB | apt-key add - &>> $LOG
	cp -v conf/mongodb-org-4.2.list /etc/apt/sources.list.d/ &>> $LOG
echo -e "Repositório do MongoDB adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o repositório do Elasticsearch, aguarde..."
	# baixando e instalando a chave GPG do Elasticsearch
	# copiando o source list do Elasticsearch para o diretório do Apt
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando wget: -q (quiet), -O (output document file)
	# opção do comando cp: -v (verbose)
	wget -qO - $KEYELASTICSEARCH | apt-key add - &>> $LOG
	cp -v conf/elastic-6.x.list /etc/apt/sources.list.d/ &>> $LOG
echo -e "Repositório do Elasticsearch adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o repositório do Graylog, aguarde..."
	# removendo o download da versão anterior do repositório do Graylog
	# baixando o repositório do Graylog
	# instalando o repositório do Graylog
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	# opção do comando dpkg: -i (install)
	rm -v graylog.deb &>> $LOG
	wget $REPGRAYLOG -O graylog.deb &>> $LOG
	dpkg -i graylog.deb &>> $LOG
echo -e "Repositório do Graylog adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando as dependências do Graylog, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	# opção do comando update-java-alternatives: -l (list)
	apt update &>> $LOG
	apt -y upgrade &>> $LOG
  	apt -y install gnupg apt-transport-https openjdk-8-jdk openjdk-8-jre openjdk-8-jre-headless default-jdk \
	default-jre uuid-runtime pwgen ca-certificates-java &>> $LOG
	java -version &>> $LOG
	update-java-alternatives -l &>> $LOG
echo -e "Dependências do Graylog instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o MongoDB, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando apt: -y (yes)
  	apt -y install mongodb-org &>> $LOG
	systemctl enable mongod &>> $LOG
	systemctl restart mongod &>> $LOG
echo -e "MongoDB instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Elasticsearch, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	# opção do comando cp: -v (verbose)
	apt -y install elasticsearch-oss &>> $LOG
echo -e "Elasticsearch instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do Elasticsearch, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando vim: + (number line)
	cp -v /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.bkp &>> $LOG
	cp -v /etc/elasticsearch/jvm.options /etc/elasticsearch/jvm.options.bkp &>> $LOG
	cp -v conf/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml &>> $LOG
	cp -v conf/jvm.options /etc/elasticsearch/jvm.options &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Elasticsearch, pressione <Enter> para continuar"
	read
	sleep 3
	vim /etc/elasticsearch/elasticsearch.yml +14
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Java do Elasticsearch, pressione <Enter> para continuar"
	read
	sleep 3
	vim /etc/elasticsearch/jvm.options +15
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Inicializando o serviço do Elasticsearch, aguarde..."
	systemctl enable elasticsearch &>> $LOG
	systemctl restart elasticsearch &>> $LOG
echo -e "Serviço inicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Graylog, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando: | piper (conecta a saída padrão com a entrada padrão de outro comando)
	# opção do comando apt: -y (yes)
	apt install -y graylog-server graylog-integrations-plugins &>> $LOG
echo -e "Graylog instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Graylog, pressione <Enter> para editar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cut: -d (delimiter), -f (fields)
	# opção do comando cp: -v (verbose)
	# opção do comando sed: s (replacement)
	read
	cp -v /etc/graylog/server/server.conf /etc/graylog/server/server.conf.bkp &>> $LOG
	cp -v conf/server.conf /etc/graylog/server/server.conf &>> $LOG
	sed "s/password_secret =/password_secret = $SECRET/" /etc/graylog/server/server.conf > /tmp/server.conf.old
	sed "s/root_password_sha2 =/root_password_sha2 = $SHA2/" /tmp/server.conf.old > /etc/graylog/server/server.conf
	vim /etc/graylog/server/server.conf
echo -e "Arquivo do Graylog editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando e Iniciando o Serviço Graylog, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable graylog-server &>> $LOG
	systemctl restart graylog-server &>> $LOG
    systemctl status graylog-server &>> $LOG
echo -e "Serviço do Graylog iniciado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Graylog, MongoDB e Elasticsearch, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric)
	# opção do comando grep: \| (função OU)
	netstat -an | grep ':19000\|27017\|9200'
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Graylog feita com Sucesso!!!."
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
