#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 10/10/2021
# Data de atualização: 31/03/2022
# Versão: 0.11
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do TFTP-HPA v5.2.x
#
# Trivial File Transfer Protocol (ou apenas TFTP) é um protocolo de transferência 
# de arquivos, muito simples, semelhante ao FTP. É geralmente utilizado para transferir 
# pequenos arquivos entre hosts numa rede, tal como quando um terminal remoto ou um 
# cliente inicia o seu funcionamento, a partir do servidor.
#
# Preboot Execution Environment (ou apenas PXE) é um ambiente para inicializar computadores 
# usando a Interface da Placa de Rede sem a dependência da disponibilidade de dispositivos 
# de armazenamento ou algum Sistema Operacional instalado.
#
# O Projeto Syslinux é um conjunto de cinco carregadores de boot diferentes para inicializar 
# distribuições GNU/Linux em computadores locais ou remotos.
#
# Site Oficial do Projeto Tftpd-Hpa: https://git.kernel.org/pub/scm/network/tftp/tftp-hpa.git/about/
# Site Oficial do Projeto PXE: https://en.wikipedia.org/wiki/Preboot_Execution_Environment
# Site Oficial do Projeto Syslinux: https://wiki.syslinux.org/wiki/index.php?title=The_Syslinux_Project
#
# Utilização do TFTP Client no GNU/Linux ou Microsoft Windows
# Linux Mint Terminal: Ctrl+Alt+T
#	sudo apt update && sudo apt install tftp ou sudo apt install tftp-hpa
#	touch linux.txt (change file timestamps)
# 	tftp tftp.pti.intra (IPv4 Trivial File Transfer Protocol client)
#		verbose
#		status
#		get robson.txt
#		put linux.txt
#		quit
#
# Windows Powershell:
#	#01_ Painel de Controle, Programas, Ativar ou Desativar Recursos do Windows, Cliente TFTP
#		OBSERVAÇÃO IMPORTANTE: para o cliente de TFTP Funcionar corretamente no Windows você
#		precisar desativar o Firewall ou Criar Regras de Permissão de Envio e Recebimento do
#		Protocolo UDP da porta 69 do TFTP Client no Windows.
#	#02_ Verificar o status do firewall, Ativar ou Desativar o Windows Defender Firewall, 
#	Desativar o Windows Defender Firewall
#		New-Item -Path '.\windows.txt' -ItemType File
# 		tftp -i tftp.pti.intra get robson.txt
# 		tftp -i tftp.pti.intra put windows.txt
#
# VirtualBOX Protocolo PXE:
#	Primeira etapa: Na inicialização da máquina virtual, clicar com o mouse no Logo do
#	VirtualBOX (tela de início/start) da máquina virtual;
#	Segunda etapa.: Pressionar a tecla F12 (Select Boot Menu/Seleção do Menu de Boot)
#	Terceira etapa: Pressionar a letra: l (Boot for LAN/PXE - Iniciar pela Placa de Rede)
#
# Backup das Configurações dos Switches ou Router Cisco
#	enable
#		copy startup-config tftp:
#		copy flash: tftp:
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
# Verificando se a porta 69 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), u (UDP), &> redirecionador de saída de erro
if [ "$(nc -vzu 127.0.0.1 $PORTTFTP &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTTFTP já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTTFTP está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando as dependências do Tftpd-Hpa Server estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retorna 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Tftpd-Hpa Server e Client, aguarde... "
	for name in $TFTPDEP
	do
		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
			echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
			deps=1; 
			}
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
			echo -en "\nInstale as dependências acima e execute novamente este script\n";
			echo -en "Recomendo utilizar o script: 02-dhcp.sh para resolver as dependências do ISC DHCP"
			echo -en "Recomendo utilizar o script: 03-dns.sh para resolver as dependências do Bind9 DNS"
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
# Script de instalação do Tftpd-Hpa Server e Client no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Tftpd-Hpa Server e Client no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo Tftpd-Hpa Server.: UDP 69\n"
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
echo -e "Iniciando a Instalação e Configuração do Tftpd-Hpa Server e Client, aguarde...\n"
sleep 5
#
echo -e "Instalando o Serviço do Tftpd-Hpa Server e Client, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt -y install $TFTPINSTALL &>> $LOG
echo -e "Tftpd-Hpa Server e Client instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do Tftpd-Hpa Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comando mkdir: -v (verbose)
	# opção do comando chown: -v (verbose), tftp (user), tftp (group)
	mv -v /etc/default/tftpd-hpa /etc/default/tftpd-hpa.old &>> $LOG
	cp -v conf/tftp/tftpd-hpa /etc/default/ &>> $LOG
	mkdir -v $PATHTFTP &>> $LOG
	mkdir -v $PATHTFTP/pxelinux.cfg &>> $LOG
	cp -v $PATHPXE/pxelinux.0 $PATHTFTP &>> $LOG
	cp -v $PATHSYSLINUX/memdisk $PATHTFTP &>> $LOG
	cp -v $PATHSYSLINUX/modules/bios/{ldlinux.c32,libcom32.c32,libutil.c32,vesamenu.c32} $PATHTFTP &>> $LOG
	cp -v conf/tftp/default $PATHTFTP/pxelinux.cfg/ &>> $LOG
	chown -v tftp.tftp $PATHTFTP &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Download o software de Teste de Memória Memtest86, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando wget: -O (output-document)
	# opção do comando gunzip: -v (verbose)
	# opção do comando mv: -v (verbose)
	wget -O memtest86.bin.gz $MEMTEST86 &>> $LOG
	gunzip -v memtest86.bin.gz &>> $LOG
	mv -v memtest86*.bin $PATHTFTP/memtest &>> $LOG
echo -e "Download do software feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração tftpd-hpa, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/default/tftpd-hpa
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração hosts.allow, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/hosts.allow
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração default, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /var/lib/tftpboot/pxelinux.cfg/default
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração dhcpd.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/dhcp/dhcpd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do Tftpd-Hpa Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart tftpd-hpa &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do ISC-DHCP Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart isc-dhcp-server &>> $LOG
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando os serviços do ISC DHCP Server e do Bind DNS Server, aguarde..."
	echo -e "ISC DHCP.: $(systemctl status isc-dhcp-server | grep Active)"
	echo -e "TFTPD-HPA: $(systemctl status tftpd-hpa | grep Active)"
echo -e "Serviços verificados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexão do ISC-DHCP Server e do Tftpd-Hpa Server, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iUDP:"67,69"
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Tftpd-Hpa Server e Client feita com Sucesso!!!"
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
