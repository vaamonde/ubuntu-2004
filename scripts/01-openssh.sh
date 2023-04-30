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
# Data de atualização: 30/04/2023
# Versão: 0.28
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Testado e homologado para a versão do OpenSSH Server v8.2.x
#
# OpenSSH (Open Secure Shell) é um conjunto de utilitários de rede relacionado à segurança que 
# provém a criptografia em sessões de comunicações em uma rede de computadores usando o protocolo 
# SSH. Foi criado com um código aberto alternativo ao código proprietário da suíte de softwares 
# Secure Shell, oferecido pela SSH Communications Security. OpenSSH foi desenvolvido como parte 
# do projeto OpenBSD.
#
# O TCP Wrapper é um sistema de rede ACL baseado em host, usado para filtrar acesso à rede a 
# servidores de protocolo de Internet (IP) em sistemas operacionais do tipo Unix, como Linux ou 
# BSD. Ele permite que o host, endereços IP de sub-rede, nomes e/ou respostas de consulta ident, 
# sejam usados como tokens sobre os quais realizam-se filtros para propósitos de controle de acesso.
#
# Site Oficial do Projeto OpenSSH: https://www.openssh.com/
# Site Oficial do Projeto OpenSSL: https://www.openssl.org/
# Site Oficial do Projeto Shell-In-a-Box: https://code.google.com/archive/p/shellinabox/
# Site Oficial do Projeto Neofetch: https://github.com/dylanaraps/neofetch
#
# Acesso remoto utilizando o GNU/Linux ou Microsoft Windows
#
# Linux Mint Terminal: Ctrl+Alt+T
# 	ssh vaamonde@172.16.1.20
#	ssh vaamonde@ssh.pti.intra
#
# Windows Powershell: Menu, Powershell 
#	ssh vaamonde@172.16.1.20
#	ssh vaamonde@ssh.pti.intra
#
# Linux Mint ou Windows:
#	apt install putty putty-tools
#	windows: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
#
# Verificando os usuários logados na sessão do OpenSSH Server no Ubuntu Server
# Terminal:
#	sudo who -a (show who is logged on)
#	sudo w (Show who is logged on and what they are doing)
#	sudo users (print the user names of users currently logged in to the current host)
#	sudo last -a | grep 'still logged in' (show a listing of last logged in users)
#	sudo ss | grep -i ssh (another utility to investigate sockets)
#	sudo netstat -tnpa | grep 'ESTABLISHED.*sshd' (show networking connection)
#	sudo ps -axfj | grep sshd (report a snapshot of the current processes)
#
# Gerando os pares de chaves Pública/Privadas utilizando o GNU/Linux
# Linux Mint Terminal: Ctrl+Alt+T
#	ssh-keygen
#		Enter file in which to save the key (/home/vaamonde/.ssh/id_rsa): /home/vaamonde/.ssh/vaamonde <Enter>
#		Enter passphrase (empty for no passphrase): <Enter>
#		Enter same passphrase again: <Enter>
#	ssh-copy-id vaamonde@172.16.1.20
#
# Importando os pares de chaves Públicas/Privadas utilizando o Powershell
# Windows Powershell: Menu, Powershell 
#	Primeira etapa: clicar com o botão direito do mouse e selecionar: Abrir como Administrador
#		Get-Service ssh-agent <Enter>
#		Set-Service ssh-agent -StartupType Manual <Enter> (Ou mudar para: Automatic)
#		Start-Service ssh-agent <Enter>
#
#	Segunda etapa: Powershell do perfil do usuário sem ser como administrador
#		ssh-add .\vaamonde <Enter>
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
# Verificando se a porta 22 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTSSH &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTSSH está sendo utilizada pelo serviço do OpenSSH Server, continuando com o script..."
		sleep 5
	else
		echo -e "A porta: $PORTSSH não está sendo utilizada nesse servidor."
		echo -e "Verifique as dependências desse serviço e execute novamente esse script.\n"
		sleep 5
		exit 1
fi
#
# Verificando se a porta 4200 está sendo utilizada no servidor Ubuntu Server
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, 
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 $PORTSHELLINABOX &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: $PORTSHELLINABOX já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: $PORTSHELLINABOX está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando todas as dependências do OpenSSH Server
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), 
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando 
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do OpenSSH Server, aguarde... "
	for name in $SSHDEP
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
# Script de configuração do OpenSSH Server no GNU/Linux Ubuntu Server 20.04.x LTS
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando hostname: -I (all-ip-addresses)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Configuração do OpenSSH Server no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão utilizada pelo OpenSSH Server.: TCP $PORTSSH"
echo -e "Porta padrão utilizada pelo Shell-In-a-Box.: TCP $PORTSHELLINABOX"
echo -e "Após a instalação do Shell-In-a-Box acessar a URL: https://$(hostname -I | cut -d' ' -f1):$PORTSHELLINABOX/\n"
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
echo -e "Iniciando a Configuração do OpenSSH Server, aguarde...\n"
sleep 5
#
echo -e "Instalando as ferramentas básicas de rede do OpenSSH Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install $SSHINSTALL &>> $LOG
echo -e "Ferramentas instaladas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração do OpenSSH Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando mkdir: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do bloco e agrupamentos {}: (Agrupa comandos em um bloco)
	mv -v /etc/ssh/sshd_config /etc/ssh/sshd_config.old &>> $LOG
	mv -v /etc/default/shellinabox /etc/default/shellinabox.old &>> $LOG
	mv -v /etc/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf.old &>> $LOG
	mkdir -v /etc/neofetch/ &>> $LOG
	cp -v conf/ubuntu/config.conf /etc/neofetch/ &>> $LOG
	cp -v conf/ubuntu/neofetch-cron /etc/cron.d/ &>> $LOG
	cp -v conf/ubuntu/50-default.conf /etc/rsyslog.d/ &>> $LOG
	cp -v conf/ubuntu/{hostname,hosts,hosts.allow,hosts.deny,issue.net,nsswitch.conf} /etc/ &>> $LOG
	cp -v conf/ubuntu/vimrc /etc/vim/ &>> $LOG
	cp -v conf/ssh/sshd_config /etc/ssh/ &>> $LOG
	cp -v conf/ssh/shellinabox /etc/default/ &>> $LOG
	cp -v $NETPLAN $NETPLAN.old &>> $LOG
	cp -v conf/ubuntu/00-installer-config.yaml $NETPLAN &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo $NETPLAN, pressione <Enter> para continuar.\n"
echo -e "CUIDADO!!!: o nome do arquivo de configuração da placa de rede pode mudar"
echo -e "dependendo da versão do Ubuntu Server, verifique o conteúdo do diretório:"
echo -e "/etc/netplan para saber o nome do arquivo de configuração do Netplan e altere"
echo -e "o valor da variável NETPLAN no arquivo de configuração: 00-parametros.sh"
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim $NETPLAN
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração hostname, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/hostname
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração hosts, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/hosts
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração nsswitch.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/nsswitch.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração sshd_config, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando read: -s (Do not echo keystrokes)
	# opção do comando sshd: -t (text mode check configuration)
	read -s
	vim /etc/ssh/sshd_config
	sshd -t &>> $LOG
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
echo -e "Editando o arquivo de configuração hosts.deny, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/hosts.deny
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração issue.net, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/issue.net
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração shellinabox, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/default/shellinabox
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração config.conf, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/neofetch/config.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração neofetch-cron, pressione <Enter> para continuar."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/cron.d/neofetch-cron
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração 50-default.conf, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saída padrão
	# opção do comando read: -s (Do not echo keystrokes)
	# opção do comando chown: -v (verbose), syslog (user), root (group)
	read -s
	vim /etc/rsyslog.d/50-default.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o arquivo personalizado de Banner em: /etc/motd, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando chmod: -v (verbose), -x (remove executable)
	neofetch --config /etc/neofetch/config.conf > /etc/motd
	chmod -v -x /etc/update-motd.d/* &>> $LOG
echo -e "Arquivo criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Aplicando as mudanças da Placa de Rede do Netplan, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	netplan --debug apply &>> $LOG
echo -e "Mudanças aplicadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando os serviços do OpenSSH Server e do Shell-In-a-Box, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart sshd &>> $LOG
	systemctl restart shellinabox &>> $LOG
	systemctl restart syslog &>> $LOG
	systemctl restart cron &>> $LOG
	systemctl restart logrotate &>> $LOG
echo -e "Serviços reinicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando os serviços do OpenSSH Server e do Shell-In-a-Box, aguarde..."
	echo -e "OpenSSH....: $(systemctl status sshd | grep Active)"
	echo -e "Shellinabox: $(systemctl status shellinabox | grep Active)"
echo -e "Serviços verificados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as versões dos serviços instalados, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (packge information), \n (newline)
	echo -e "Neofetch.....: $(dpkg-query -W -f '${version}\n' neofetch)"
	echo -e "OpenSSH......: $(dpkg-query -W -f '${version}\n' openssh-server)"
	echo -e "Shellinabox..: $(dpkg-query -W -f '${version}\n' shellinabox)"
echo -e "Versões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexões do OpenSSH Server e do Shell-In-a-Box, aguarde..."
	# opção do comando lsof: -n (inhibits the conversion of network numbers to host names for 
	# network files), -P (inhibits the conversion of port numbers to port names for network files), 
	# -i (selects the listing of files any of whose Internet address matches the address specified 
	# in i), -s (alone directs lsof to display file size at all times)
	lsof -nP -iTCP:'22,4200' -sTCP:LISTEN
echo -e "Portas verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configuração do OpenSSH Server feita com Sucesso!!!."
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
