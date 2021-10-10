#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 14/09/2021
# Data de atualização: 14/09/2021
# Versão: 0.01
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do IPTables v1.6.x
#
# O Netfilter é um módulo que fornece ao sistema operacional Linux as funções de firewall, 
# NAT e log dos dados que trafegam por rede de computadores.
#
# O IPTables é o nome da ferramenta do espaço do usuário que permite a criação de regras 
# de firewall e NATs. Apesar de, tecnicamente, o iptables ser apenas uma ferramenta que 
# controla o módulo netfilter, o nome "iptables" é frequentemente utilizado como referência 
# ao conjunto completo de funcionalidades do netfilter. O iptables é parte de todas as 
# distribuições modernas do Linux.
#
# O Ubuntu (Server e Desktop) vem com uma ferramenta de configuração de firewall chamada UFW 
# (Uncomplicated Firewall). É um front-end amigável para gerenciar regras de firewall iptables. 
# Seu principal objetivo é tornar o gerenciamento do firewall mais fácil ou, como o nome diz, 
# descomplicado.
#
# Site Oficial do Projeto Netfilter: https://www.netfilter.org/
# Site Oficial do Projeto IPTables: https://www.netfilter.org/projects/iptables/index.html
# Site Oficial do Projeto UFW: https://launchpad.net/ufw
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Lista de Portas TCP e UDP de todos os Serviços dos Scripts: https://github.com/vaamonde/ubuntu-1804/blob/master/Portas.sh
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
# Variável de criação do diretório das regras de firewall e do script do IPTables
PATHSBIN="/usr/bin"
PATHCONF="/etc/firewall"
PATHLOG="/var/log"
RSYSLOG="/etc/rsyslog.d"
SYSTEMD="/lib/systemd/system"
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
# Script de configuração do IPTables no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
#
echo
echo -e "Configuração do IPTables no GNU/Linux Ubuntu Server 18.04.x\n"
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
echo -e "Configurando as Regras de Firewall utilizando o IPTables, aguarde...\n"
sleep 5
#
echo -e "Criando o diretório das Configurações do Firewall, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	mkdir -v $PATHCONF &>> $LOG
echo -e "Diretório criado com sucesso!!!, continuando o script...\n"
sleep 5
#
echo -e "Copiando os arquivos de Configurações do Firewall, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando chmod: -v (verbose), +x (all execution)
	cp -v conf/portslibtcp $PATHCONF/portslibtcp &>> $LOG
	cp -v conf/portslibudp $PATHCONF/portslibudp &>> $LOG
	cp -v conf/multiportslibtcp $PATHCONF/multiportslibtcp &>> $LOG
	cp -v conf/portsblo $PATHCONF/portsblo &>> $LOG
	cp -v conf/dnsserver $PATHCONF/dnsserver &>> $LOG
	cp -v conf/firewall $PATHSBIN/firewall &>> $LOG
	chmod -v +x $PATHSBIN/firewall &>> $LOG
echo -e "Arquivos copiados com sucesso!!!, continuando o script...\n"
sleep 5
#
echo -e "Copiando o arquivo de Configuração do Log do Firewall, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando chown: -v (verbose), syslog (user), adm (group)
	cp -v conf/firewall.conf $RSYSLOG/firewall.conf &>> $LOG
	touch $PATHLOG/firewall.log &>> $LOG
	chown -v syslog.adm $PATHLOG/firewall.log &>> $LOG
	systemctl restart rsyslog &>> $LOG
echo -e "Arquivo copiado com sucesso!!!, continuando o script...\n"
sleep 5
#
echo -e "Copiando o arquivo de Serviço do Firewall, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/firewall.service $SYSTEMD/firewall.service &>> $LOG
	systemctl daemon-reload &>> $LOG
	systemctl enable firewall.service &>> $LOG
	systemctl start firewall.service &>> $LOG
echo -e "Arquivo copiado com sucesso!!!, continuando o script...\n"
sleep 5
#
echo -e "Editando os arquivos de configuração do IPTables, aguarde...\n"
sleep 5
#
	echo -e "Editando o arquivo: $PATHSBIN/firewall, pressione <Enter> para editar."
	read
		vim $PATHSBIN/firewall
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
	sleep 5
	#
	echo -e "Editando o arquivo: $PATHCONF/portslibtcp, pressione <Enter> para editar."
	read
		vim $PATHCONF/portslibtcp
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
	sleep 5
	#
	echo -e "Editando o arquivo: $PATHCONF/portslibudp, pressione <Enter> para editar."
	read
		vim $PATHCONF/portslibudp
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
	sleep 5
	#
	echo -e "Editando o arquivo: $PATHCONF/multiportslibtcp, pressione <Enter> para editar."
	read
		vim $PATHCONF/multiportslibtcp
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
	sleep 5
	#
	echo -e "Editando o arquivo: $PATHCONF/portsblo, pressione <Enter> para editar."
	read
		vim $PATHCONF/portsblo
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
	sleep 5
	#
	echo -e "Editando o arquivo: $PATHCONF/dnsserver, pressione <Enter> para editar."
	read
		vim $PATHCONF/dnsserver
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
	sleep 5
	#
	echo -e "Editando o arquivo: $RSYSLOG/firewall.conf, pressione <Enter> para editar."
	read
		vim $RSYSLOG/firewall.conf
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
	sleep 5
	#
	echo -e "Editando o arquivo: $SYSTEMD/firewall.service, pressione <Enter> para editar."
	read
		vim $SYSTEMD/firewall.service
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
	sleep 5
	#
echo -e "Todos os arquivos editados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Configuração do IPTables feita com Sucesso!!!."
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
