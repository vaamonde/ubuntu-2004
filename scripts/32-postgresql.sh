#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 23/12/2021
# Data de atualização: 12/01/2022
# Versão: 0.03
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do PostgreSQL v14.x
# Testado e homologado para a versão do PgAdmin v6.x
#
# PostgreSQL é um sistema gerenciador de banco de dados objeto relacional (SGBD), 
# desenvolvido como projeto de código aberto. O PostgreSQL possui recursos mais 
# avançados para o gerenciamento de Banco de Dados disponível no mercado em 
# relação aos seus concorrente (por exemplo: MySQL, MariaDB, Firebird, etc...)
#
# O pgAdmin é uma plataforma Open Source de administração do PostgreSQL e seus 
# banco de dados relacionados. Escrito em Python e jQuery, ele suporta todos os 
# recursos encontrados no PostgreSQL por linha de comando (console).
# 
# Site oficial: https://www.postgresql.org/
# Site oficial: https://www.pgadmin.org/
#
# Mensagem da configuração da senha do PostgreSQL
# Enter new password: postgres
# Enter it again: postgres
#
# Mensagem da configuração do email e senha do PgAdmin4 Web
# Email address: postgres@pti.intra
# Password: postgres
# Retype password: postgres
# We can now configure the Apache Web server for you. This involves enabling the wsgi module and 
# configuring the pgAdmin 4 application to mount at /pgadmin4. Do you wish to continue (y/n)? y <Enter>
# The Apache web server is running and must be restarted for the pgAdmin 4 installation to complete. 
# Continue (y/n)? y <Enter>
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
# Verificando se as dependências do PgAdmin4 estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do PgAdmin4, aguarde... "
	for name in $PGADMIN4DEP
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
# Verificando se a porta 5432 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $POSTGRESQLPORT &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $POSTGRESQLPORT já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $POSTGRESQLPORT está disponível, continuando com o script..."
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
# Script de instalação do PostgreSQL e PgAdmin4 no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable) habilita interpretador, \n = (new line)
# opção do comando hostname: -d (domain)
# opção do comando sleep: 5 (seconds)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do PostgreSQL e do PgAdmin4 no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo PostgreSQL Server.: TCP 5432"
echo -e "Após a instalação do PgAdmin4 acessar a URL: http://$(hostname -d | cut -d ' ' -f1)/pgadmin4\n"
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
echo -e "Software removidos com Sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando a Instalação e Configuração do PostgreSQL e do PgAdmin4, aguarde...\n"
sleep 5
#
echo -e "Adicionando o Repositório do PostgreSQL Server, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando wget: -q (quiet) -O (output document file)
	# opção do comando cp: -v (verbose)
    wget -qO - $KEYPOSTGRESQL | apt-key add - &>> $LOG
    cp -v conf/postgresql/pgdg.list /etc/apt/sources.list.d/ &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o Repositório do PgAdmin4, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando wget: -q (quiet) -O (output document file)
	# opção do comando cp: -v (verbose)
    wget -qO - $KEYPGADMIN4 | apt-key add - &>> $LOG
    cp -v conf/postgresql/pgadmin4.list /etc/apt/sources.list.d/ &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt com os novos Repositórios, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
    apt update &>> $LOG
	apt -y upgrade &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando as dependências do PostgreSQL e do PgAdmin4, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $POSTGRESQLDEPINSTALL &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o PostgreSQL Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $POSTGRESQLINSTALL &>> $LOG
echo -e "Instalação do PostgreSQL Server feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configurando a senha do usuário: $USERPOSTGRESQL do PostgreSQL Server, pressione <Enter> para continuar"
echo -e "Senha que será configurada do usuário $USERPOSTGRESQL é: $PASSWORDPOSTGRESQL"
	# opção do comando sudo: -u (user)
    read
	sudo -u $USERPOSTGRESQL psql --command '\password postgres'
echo -e "Senha configurada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o PgAdmin4 e PgAdmin4 Web, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $PGADMININSTALL &>> $LOG
echo -e "Instalação do PgAdmin4 feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configurando o PgAdmin4 Web, pressione <Enter> para continuar\n"
echo -e "CUIDADO!!! com as mensagens que serão solicitadas: email: $EMAILPGADMIN - senha: $EMAILPASSPGADMIN"
echo -e "Dúvidas veja a documentação na linha: 29 do script: $0"
	read
    /usr/pgadmin4/bin/./setup-web.sh
echo -e "Configuração do PgAdmin4 Web feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivo de configuração do PostgreSQL, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	mv -v /etc/postgresql/14/main/pg_hba.conf /etc/postgresql/14/main/pg_hba.conf.old &>> $LOG
	mv -v /etc/postgresql/14/main/postgresql.conf /etc/postgresql/14/main/postgresql.conf.old &>> $LOG
	cp -v conf/postgresql/{pg_hba.conf,postgresql.conf} /etc/postgresql/14/main/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração postgresql.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/postgresql/14/main/postgresql.conf 
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração pg_hba.conf, pressione <Enter> para continuar"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/postgresql/14/main/pg_hba.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando os serviços do Apache2 e do PostgreSQL, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart apache2 &>> $LOG
	systemctl restart postgresql &>> $LOG
echo -e "Serviços reinicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando os serviços do PostgreSQL e do Apache2, aguarde..."
	echo -e "PostgreSQL: $(systemctl status postgresql | grep Active)"
	echo -e "Apache2...: $(systemctl status apache2 | grep Active)"
echo -e "Serviços verificados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do PostgreSQL Server, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:'5432' -sTCP:LISTEN
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do PostgreSQL Server e do PgAdmin4 feita com Sucesso!!!."
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
exit 
