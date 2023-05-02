#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 23/04/2023
# Data de atualização: 02/05/2023
# Versão: 0.04
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Prometheus v2.43.x
#
# Prometheus é um aplicativo de software livre usado para monitoramento de eventos e alertas.
# Ele registra métricas em tempo real em um banco de dados de séries temporais (permitindo alta 
# dimensionalidade) construído usando um modelo HTTP pull, com consultas flexíveis e alertas em 
# tempo real. É um projeto código aberto originalmente criado na SoundCloud em 2012 e agora é 
# mantido independentemente de qualquer empresa.
#
# Site Oficial do Projeto Prometheus: https://prometheus.io/
# Projeto Github Node Exporter Linux: https://github.com/prometheus/node_exporter/
# Projeto Github Windows Exporter...: https://github.com/prometheus-community/windows_exporter
#
# Informações que serão solicitadas na configuração via Web do Prometheus
# URL padrão do Prometheus: http://pti.intra:9100
# URL das targets do Prometheus: http://pti.intra:9100/targets
#
# Instalação e configuração da coleta de métricas do Prometheus no Linux e Windows
#
# Instalação do Node Exporter Linux
# #01_ download do exportador de métricas: https://github.com/prometheus/node_exporter/releases/ (versão 1.5.0 - 29/11/2022)
# #02_ descompactar o conteúdo da pasta: node_exporter-*.linux-amd64
# #03_ executar o aplicativo: ./node_exporter
# #04_ acessar as métricas na URL: http://localhost:9100
# #05_ filtrando as métricas do Node no Prometheus: {job="linuxmint"}
#		a) Expression: node_os_info{job="linuxmint"} <Execute>
#		b) Expression: node_disk_info{job="linuxmint"} <Execute>
#		c) Expression: node_dmi_info{job="linuxmint"} <Execute>
#		d) Expression: node_memory_Active_bytes{job="linuxmint"} <Execute> - <Graph>
#		e) Expression: node_cpu_seconds_total{job="linuxmint"} <Execute> - <Graph>
#		f) Expression: rate(node_cpu_seconds_total{job="linuxmint"}[1m]) <Execute> - <Graph>
#
# Instalação do Windows Exporter
# #01_ download do exportador de métricas: https://github.com/prometheus-community/windows_exporter/releases (versão 0.22.0 - 26/03/2023)
# #02_ executar a instalação do Windows Exporter via Powershell
# 	OBSERVAÇÃO IMPORTANTE: fazer a instalação do Prometheus Windows Exporter utilizando o Powershell em modo Administrador.
# #03_ acessar o diretório de download e executar a instalação: msiexec -i windows_exporter-*-amd64.msi ENABLED_COLLECTORS=cpu,memory,net,logical_disk,os,system,logon,thermalzone
# #04_ verificar a porta de conexão do Windows Exporter: netstat -an | findstr 9182
# #05_ acessar as métricas na URL: http://localhost:9182/metrics
# #06_ filtrando as métricas no Windows Exporter no Prometheus: {job="windows10"}
#		a) Expression: windows_os_info{job="windows10"} <Execute>
#		b) Expression: windows_logical_disk_reads_total{job="windows10"} <Execute> - <Graph>
#		c) Expression: windows_net_bytes_total{job="windows10"} <Execute> - <Graph>
#		d) Expression: rate(windows_memory_available_bytes{job="windows10"}[1m]) <Execute> - <Graph>
#		e) Expression: rate(windows_cpu_time_total{job="windows10"}[1m]) <Execute> - <Graph>
#		f) Expression: windows_net_packets_sent_total{job="windows10"} <Execute> - <Graph>
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
# Verificando se a porta 9091 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTPROMETHEUS &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTPROMETHEUS já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTPROMETHEUS está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando se as dependências do Prometheus estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Prometheus, aguarde... "
	for name in $PROMETHEUSDEP
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            echo -en "Recomendo utilizar o script: 03-dns.sh para resolver as dependências."
			echo -en "Recomendo utilizar o script: 21-grafana.sh para resolver as dependências."
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
# Script de instalação do Prometheus no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Prometheus no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Prometheus.: TCP 9091\n"
echo -e "Após a instalação do Prometheus acessar a URL: http://$(hostname -d | cut -d' ' -f1):9091\n"
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
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando a Instalação e Configuração do Prometheus, aguarde...\n"
sleep 5
#
echo -e "Criando o Grupo e o Usuário de Sistema do Prometheus, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando useradd: -s (shell), -g (group) 
	groupadd --system $GROUPPROMETHEUS &>> $LOG
	useradd -s /sbin/nologin --no-create-home --system -g $GROUPPROMETHEUS $USERPROMETHEUS &>> $LOG
echo -e "Grupo e Usuário criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando os diretórios do Prometheus, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: =p (parents), -v (verbose)
	mkdir -pv /etc/prometheus &>> $LOG
	mkdir -pv /var/lib/prometheus &>> $LOG
echo -e "Diretórios criados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do Prometheus do Site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v prometheus.tar.gz &>> $LOG
	wget -O prometheus.tar.gz $PROMETHEUS &>> $LOG
echo -e "Download do Prometheus feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Descompactando o arquivo do Prometheus, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -R (recursive), -f (force), -v (verbose)
	# opção do comando tar: -z (gzip), -x (extract), -v (verbose), -f (file)
	rm -Rfv prometheus-*/ &>> $LOG
	tar -zxvf prometheus.tar.gz &>> $LOG
echo -e "Descompactação do Prometheus feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração Prometheus, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -R (recursive), -v (verbose)
	# opção do comando chown: -R (recursive) -v (verbose), prometheus (user), :prometheus (group)
	# opção do comando chmod: -R (recursive) -v (verbose), 775 (User: RWX, Group: RWX, Other: R-X)
	cp -Rv prometheus*/{prometheus,promtool} /usr/local/bin/ &>> $LOG
	cp -Rv prometheus*/{consoles/,console_libraries/} /etc/prometheus/ &>> $LOG
	cp -Rv conf/prometheus/prometheus.yml /etc/prometheus/ &>> $LOG
	cp -v conf/prometheus/prometheus.service /etc/systemd/system/prometheus.service &>> $LOG
	chown -Rv prometheus:prometheus /etc/prometheus/ /var/lib/prometheus/ &>> $LOG
	chmod -Rv 775 /etc/prometheus/ /var/lib/prometheus/ &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração prometheus.yml, pressione <Enter> para continuar..."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/prometheus/prometheus.yml
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando o serviço do Prometheus, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable prometheus &>> $LOG
	systemctl start prometheus &>> $LOG
echo -e "Serviço iniciado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do Prometheus, aguarde..."
	echo -e "Prometheus: $(systemctl status prometheus | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a versão do serviço instalado, aguarde..."
	echo -e "Prometheus..: $(prometheus --version | grep prometheus)"
echo -e "Versão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Prometheus, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:9091 -sTCP:LISTEN
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Prometheus feita com Sucesso!!!."
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
