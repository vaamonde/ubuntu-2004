#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 11/01/2021
# Data de atualização: 10/05/2021
# Versão: 0.05
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do PostgreSQL 13.x e PgAdmin 4.x
#
# PostgreSQL é um sistema gerenciador de banco de dados objeto relacional (SGBD), desenvolvido como projeto de 
# código aberto. O PostgreSQL possui recursos mais avançados para o gerenciamento de Banco de Dados disponível
# no mercado em relação aos seus concorrente (por exemplo: MySQL, MariaDB, Firebird, etc...)
#
# O pgAdmin é uma plataforma Open Source de administração do PostgreSQL e seus banco de dados relacionados. Escrito 
# em Python e jQuery, ele suporta todos os recursos encontrados no PostgreSQL por linha de comando (console).
# 
# Mensagem da configuração da senha do PostgreSQL
# Enter new password: postgres
# Enter it again: postgres
#
# Mensagem da configuração do email e senha do PgAdmin4 Web
# Email address: postgres@localhost
# Password: postgres
# Retype password: postgres
# We can now configure the Apache Web server for you. This involves enabling the wsgi module and configuring the 
# pgAdmin 4 application to mount at /pgadmin4. Do you wish to continue (y/n)? y <Enter>
# The Apache web server is running and must be restarted for the pgAdmin 4 installation to complete. Continue (y/n)? y <Enter>
# 
# Site oficial: https://www.postgresql.org/
# Site oficial: https://www.pgadmin.org/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de instalação do LAMP Server no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=6EFUu-I3u4s&t
#
# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário e "root", versão do ubuntu e kernel
# opções do comando id: -u (user), opções do comando: lsb_release: -r (release), -s (short), 
# opções do comando uname: -r (kernel release), opções do comando cut: -d (delimiter), -f (fields)
# opção do carácter: | (piper) Conecta a saída padrão com a entrada padrão de outro comando
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
# Variáveis de configuração do PostgreSQL
KEYPOSTGRESQL="https://www.postgresql.org/media/keys/ACCC4CF8.asc"
USER="postgres"
PASSWORD="postgres"
#
# Variáveis de configuração do PgAdmin4 Web
KEYPGADMIN4="https://www.pgadmin.org/static/packages_pgadmin_org.pub"
EMAIL="$USER@localhost"
EMAILPASS=$PASSWORD
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
# Verificando se as dependências do PgAdmin4 estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do PgAdmin4, aguarde... "
	for name in apache2 php python
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
# Script de instalação do PostgreSQL e PgAdmin4 no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable) habilita interpretador, \n = (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando sleep: 5 (seconds)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do PostgreSQL e PgAdmin4 no GNU/Linux Ubuntu Server 18.04.x"
echo -e "Após a instalação do PgAdmin4 acessar a URL: http://`hostname -I | cut -d ' ' -f1`/pgadmin4\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet..."
sleep 5
echo
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
	# opção do comando: &>> (redirecionar a saída padrão)
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
echo -e "Software removidos com Sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o PostgreSQL e PgAdmin4, aguarde...\n"
#
echo -e "Adicionando o Repositório do PostgreSQL, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando wget: -q (quiet) -O (output document file)
	# opção do comando cp: -v (verbose)
    wget -qO - $KEYPOSTGRESQL | sudo apt-key add - &>> $LOG
    cp -v conf/pgdg.list /etc/apt/sources.list.d/pgdg.list &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o Repositório do PgAdmin4, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando wget: -q (quiet) -O (output document file)
	# opção do comando cp: -v (verbose)
    wget -qO - $KEYPGADMIN4 | sudo apt-key add - &>> $LOG
    cp -v conf/pgadmin4.list /etc/apt/sources.list.d/pgadmin4.list &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as Lista do Apt com os novos Repositórios, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
    apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando as dependências do PostgreSQL e do PgAdmin4, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install build-essential libssl-dev libffi-dev libgmp3-dev virtualenv python-pip \
    libpq-dev python-dev apache2-utils libapache2-mod-wsgi libexpat1 ssl-cert python &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o PostgreSQL Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install postgresql postgresql-contrib postgresql-client &>> $LOG
echo -e "Instalação do PostgreSQL Server feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configurando a senha do usuário: $USER do PostgreSQL Server, pressione <Enter> para continuar"
echo -e "Senha que será configurada do usuário $USER: $PASSWORD"
	# opção do comando sudo: -u (user)
    read
	sudo -u $USER psql --command '\password postgres'
echo -e "Senha configurada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o PgAdmin4 e PgAdmin4 Web, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install pgadmin4 pgadmin4-web &>> $LOG
echo -e "Instalação do PgAdmin4 feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configurando o PgAdmin4 Web, pressione <Enter> para continuar"
echo -e "Cuidado com as mensagens que serão solicitadas: email: $EMAIL - senha: $EMAILPASS"
echo -e "Dúvidas veja a linha: 25 do script: $0"
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	read
    /usr/pgadmin4/bin/./setup-web.sh
echo -e "Configuração do PgAdmin4 Web feita com sucesso!!!, continuando com o script...\n"
sleep 5
#			 
echo -e "Reinicializando os serviços do Apache2, aguarde..."
	systemctl restart apache2 &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do PostgreSQL, aguarde..."
	# opção do comando netstat: a (all), n (numeric)
	# opção do comando grep: ' ' (aspas simples)
	netstat -an | grep '5432'
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do PostgreSQL e PgAdmin4 feito com Sucesso!!!"
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
