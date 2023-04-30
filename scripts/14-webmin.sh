#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 02/11/2021
# Data de atualização: 30/04/2023
# Versão: 0.08
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Webmin v1.9x e do Usermin v1.8x 
#
# Webmin é um programa de gerenciamento de servidor, que roda em plataformas Unix/Linux. 
# Com ele você pode usar também o Usermin e o Virtualmin. O Webmin funciona como um 
# centralizador de configurações do sistema, monitoração dos serviços e de servidores, 
# fornecendo uma interface amigável, e que quando configurado com um servidor web, pode 
# ser acessado de qualquer local, através de um navegador: 
# Exemplo: https://(ip do servidor):(porta de utilização) - https://172.16.1.20:10000
#
# Usermin é uma interface baseada na web para webmail, alteração de senha, filtros de 
# e-mail, fetchmail e muito mais. Ele é projetado para uso por usuários não-root regulares 
# em um sistema Unix e os limita a tarefas que seriam capazes de realizar se logados via 
# SSH ou no console.
#
# Virtualmin é um módulo Webmin para gerenciar vários hosts virtuais por meio de uma única 
# interface, como Plesk ou Cpanel. Ele suporta a criação e gerenciamento de hosts virtuais 
# Apache, domínios BIND DNS, bancos de dados MySQL e caixas de correio e aliases com 
# Sendmail ou Postfix. Ele faz uso dos módulos Webmin existentes para esses servidores e, 
# portanto, deve funcionar com qualquer configuração de sistema existente, ao invés de 
# precisar de seu próprio servidor de e-mail, servidor web e assim por diante.
#
# O Cloudmin foi projetado para uso por empresas de hospedagem VPS que vendem sistemas 
# virtuais para seus clientes, mas também é adequado para quem deseja entrar na virtualização 
# para gerenciamento de aplicativos, testes, controle de um cluster de hosts 
#
# Site oficial do Projeto Webmin: http://www.webmin.com/
# Site oficial do Projeto Usermin: https://www.webmin.com/usermin.html
# Site oficial do Projeto Virtualmin: https://www.webmin.com/virtualmin.html
#
# # Soluções Open Source de Gerenciamento via Web
# Site oficial do Projeto Cokipit: https://cockpit-project.org/
# Site oficial do Projeto ISPConfig: https://www.ispconfig.org/
# Site oficial do Projeto Ajenti: https://ajenti.org/core/
# Site oficial do Projeto Hestia: https://www.hestiacp.com/
# Site oficial do Projeto aaPanel: https://www.aapanel.com/index.html
# Site oficial do Projeto CyberPanel: https://cyberpanel.net/
#
# Informações que serão solicitadas na configuração via Web do Webmin e Usermin
# Username: vaamonde
# Password: pti@2018: Sign In
#
# Webmin
# 	Refresh Modules
#
# Site dos Módulos de Terceiros do Webmin: https://www.webmin.com/cgi-bin/search_third.cgi?modules=1
# Download Módulo VSFTPd Server: https://www.webmin.com/cgi-bin/search_third.cgi?search=vsftp
# Webmin
#	Webmin Configuration
#		Webmin Modules
#			Install From: From upload file
#				(Selecione o arquivo do VSFTPd Server)
#			<Install Module>
# Refresh Modules
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
# Verificando se as portas 10000 e 20000 estão sendo utilizadas no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTWEBMIN &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTWEBMIN já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTWEBMIN está disponível, continuando com o script..."
		sleep 5
fi
if [ "$(nc -vz 127.0.0.1 $PORTUSERMIN &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTUSERMIN já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTUSERMIN está disponível, continuando com o script..."
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
# Script de instalação do Webmin e do Usermin no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable) habilita interpretador, \n = (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Webmin no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Webmin..: TCP 10000"
echo -e "Porta padrão utilizada pelo Usermin.: TCP 20000\n"
echo -e "Após a instalação do Webmin acessar a URL: https://$(hostname -d | cut -d' ' -f1):10000/"
echo -e "Após a instalação do Usermin acessar a URL: https://$(hostname -d | cut -d' ' -f1):20000/\n"
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
echo -e "Iniciando a Instalação e Configuração do Webmin e do Usermin, aguarde...\n"
sleep 5
#
echo -e "Instalando as dependências do Webmin e do Usermin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes), \ (Bar, opção de quebra de linha no apt)
	apt -y install $WEBMINDEP &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o arquivo do Source List do Apt com o repositório do Webmin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/webmin/webmin.list /etc/apt/sources.list.d/ &>> $LOG
echo -e "Source List do Apt atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando a chave GPG do Webmin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando wget: -q (quiet), -O- (output-document)
	wget -q -O- $WEBMINPGP | apt-key add - &>> $LOG
echo -e "Chave GPG do Webmin adicionada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as Listas do Apt com o novo Repositório do Webmin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Webmin e Usermin, esse processo demora um pouco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $WEBMININSTALL &>> $LOG
echo -e "Instalação do Webmin e do Usermin feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando os Serviços do Webmin e do Usermin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl start webmin &>> $LOG
	systemctl start usermin &>> $LOG
echo -e "Serviços iniciados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando os serviços do Webmin e do Usermin, aguarde..."
	echo -e "Webmin.: $(systemctl status webmin | grep Active)"
	echo -e "Usermin: $(systemctl status usermin | grep Active)"
echo -e "Serviços verificados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as versões dos serviços instalados, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "Usermin Server..: $(dpkg-query -W -f '${version}\n' usermin)"
	echo -e "Webmin Server...: $(dpkg-query -W -f '${version}\n' webmin)"
echo -e "Versões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexões do Webmin e do Usermin, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:'10000,20000' -sTCP:LISTEN
echo -e "Portas verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação e Configuração do Webmin e do Usermin feita com Sucesso!!!"
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