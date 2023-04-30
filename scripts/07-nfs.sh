#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 08/01/2022
# Data de atualização: 30/04/2023
# Versão: 0.10
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do NFS Server v4.x
#
# NFS (acrônimo para Network File System) é um sistema de arquivos distribuídos desenvolvido 
# inicialmente pela Sun Microsystems, Inc., a fim de compartilhar arquivos e diretórios entre 
# computadores conectados em rede, formando assim um diretório virtual. O protocolo Network 
# File System é especificado nas seguintes RFCs: RFC 1094, RFC 1813 e RFC 7931 (que atualiza 
# a RFC 7530, que tornou obsoleta a RFC 3530). 
#
# Site Oficial do Projeto NFS: http://nfs.sourceforge.net/
#
# Utilização do NFS Client no GNU/Linux ou Microsoft Windows
# Linux Mint Terminal: Ctrl+Alt+T
# 	sudo apt update && sudo apt install nfs-common
#	sudo rpcinfo -p nfs.pti.intra (report RPC information)
#	sudo showmount -e nfs.pti.intra (show mount information for an NFS server)
#	sudo mkdir -v /mnt/nfs (make directories)
#	sudo mount -v nfs.pti.intra:/mnt/nfs /mnt/nfs (mount a filesystem)
#	sudo mount | grep nfs (mount a filesystem)
#	sudo umount /mnt/nfs (umount a filesystem)
#	sudo nfsiostat -p (emulate iostat for NFS mount points using)
#
# Windows CMD (Command Prompt):
#	Painel de Controle, Programas, Ativar ou Desativar Recursos do Windows, Serviço de NFS, Cliente NFS	
#	rpcinfo -p nfs.pti.intra
#	showmount -e nfs.pti.intra
#	mount -o anon nfs.pti.intra:/mnt/nfs z:
#	mount
#	umount z:
#
# Windows Powershell: (Infelizmente não está funcionando corretamente, buscando solução)
#	New-PSDrive -Name W -PSProvider FileSystem -Root "\\nfs.pti.intra:\mnt\nfs"
#	Get-PSDrive W
#	Remove-PSDrive W
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
# Verificando se as portas 111 e 2049 estão sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTNFSRPC &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTNFSRPC já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTNFSRPC está disponível, continuando com o script..."
		sleep 5
fi
if [ "$(nc -vz 127.0.0.1 $PORTNFSPORTMAPPER &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTNFSPORTMAPPER já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTNFSPORTMAPPER está disponível, continuando com o script..."
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
# Script de instalação do NFS Server no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do NFS Server e Client no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo NFS Server.: TCP/UDP 111 e TCP/UDP 2049\n"
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
echo -e "Iniciando a Instalação e Configuração do NFS Server e Client, aguarde...\n"
sleep 5
#
echo -e "Instalando o NFS Server e Client, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $NFSINSTALL &>> $LOG
echo -e "NFS Server e Client instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do NFS Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comando mkdir: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	mv -v /etc/idmapd.conf /etc/idmapd.conf.old &>> $LOG
	mv -v /etc/exports /etc/exports.old &>> $LOG
	mv -v /etc/default/nfs-kernel-server /etc/default/nfs-kernel-server.old &>> $LOG
	cp -v conf/nfs/{idmapd.conf,exports} /etc/ &>> $LOG
	cp -v conf/nfs/nfs-kernel-server /etc/default/ &>> $LOG
	mkdir -v /etc/systemd/system/nfs-blkmap.service.d/ &>> $LOG
	cp -v conf/nfs/override.conf /etc/systemd/system/nfs-blkmap.service.d/ &>> $LOG
	touch /run/rpc_pipefs/nfs/blocklayout &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração idmapd.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/idmapd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração exports, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/exports
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração nfs-kernel-server, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)echo -e "NFS: 
	read -s
	vim /etc/default/nfs-kernel-server
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
echo -e "Criando o diretório de Exportação do NFS Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando chown: -R (recursive), -v (verbose)
	# opção do comando chmod: -R (recursive), -v (verbose), 777 (User=RWX,Group=RWX,Other=RWX)
	mkdir -v $PATHNFS &>> $LOG
	chown -Rv nobody:nogroup $PATHNFS &>> $LOG
	chmod -Rv 777 $PATHNFS &>> $LOG
echo -e "Diretório criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Exportando os Compartilhamentos do NFS Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando exportfs: -a (Export all directories), -r (Reexport  all  directories), -v (verbose)
	exportfs -arv &>> $LOG
echo -e "Compartilhamentos exportados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando os Compartilhamentos do NFS Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando exportfs: -s (Display the current export list), -v (verbose)
	echo -e "NFS: $(exportfs -sv)"
echo -e "Compartilhamentos verificados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as Estatísticas do NFS Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando nfsstat: -v (verbose)
	nfsstat -v
echo -e "Estatísticas verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o Serviço do NFS Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart nfs-kernel-server &>> $LOG
echo -e "Serviços reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do NFS Server, aguarde..."
	echo -e "NFS: $(systemctl status nfs-kernel-server | grep Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a versão do serviço instalado, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "NFS Server..: $(dpkg-query -W -f '${version}\n' nfs-kernel-server)"
echo -e "Versão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do NFS Server, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:'111' -sTCP:LISTEN
	echo ============================================
	rpcinfo -p | grep nfs
	rpcinfo -p | grep portmapper
echo -e "Portas verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do NFS Server e Client feita com Sucesso!!!."
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
