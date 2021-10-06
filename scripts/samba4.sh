#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 01/02/2019
# Data de atualização: 06/02/2019
# Versão: 0.03
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do SAMBA 4.7.x
#
# O SAMBA 4 é uma reimplementação de software livre do protocolo de rede SMB e foi originalmente 
# desenvolvido por Andrew Tridgell. O Samba fornece serviços de arquivo e impressão para vários 
# clientes do Microsoft Windows e pode se integrar a um domínio do Microsoft Windows Server, como 
# um controlador de domínio (DC) ou como um membro do domínio. A partir da versão 4, ele suporta 
# domínios do Active Directory e do Microsoft Windows NT.
#
# O KERBEROS Kerberos é o nome de um Protocolo de rede, que permite comunicações individuais seguras
# e identificadas, em uma rede insegura. Para isso o Massachusetts Institute of Technology (MIT) 
# disponibiliza um pacote de aplicativos que implementam esse protocolo. O protocolo Kerberos previne 
# Eavesdropping e Replay attack, e ainda garante a integridade dos dados. Seus projetistas inicialmente 
# o modelaram na arquitetura cliente-servidor, e é possível a autenticação mutua entre o cliente e o 
# servidor, permitindo assim que ambos se autentiquem.
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de atualização do Sistema: 
# Vídeo de configuração da Placa de Rede: 
# Vídeo de configuração do Hostname e Hosts: 
#
# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário e "root", versão do ubuntu e kernel
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
# Variáveis de configuração do Kerberos e SAMBA4
REALM="PTI.INTRA"
NETBIOS="PTI"
DOMAIN="pti.intra"
FQDN="ptispo01ws01.pti.intra"
IP="172.16.1.20"
#
# Variáveis de configuração do NTP Server
NTP="a.st1.ntp.br"
#
# Variáveis de configuração do SAMBA4
ROLE="dc"
DNS="SAMBA_INTERNAL"
USER="administrator"
PASSWORD="pti@2018"
LEVEL="2008_R2"
SITE="PTI.INTRA"
INTERFACE="enp0s3"
GATEWAY="172.16.1.254"
#
# Variáveis de configuração do DNS
ARPA="1.16.172.in-addr.arpa"
ARPAIP="20"
#
# Exportando o recurso de Noninteractive do Debconf para não solicitar telas de configuração
export DEBIAN_FRONTEND="noninteractive"
#
# Verificando se o usuário e Root, Distribuição e >=18.04 e o Kernel >=4.15 <IF MELHORADO)
# [ ] = teste de expressão, && = operador lógico AND, == comparação de string, exit 1 = A maioria dos erros comuns na execução
clear
if [ "$USUARIO" == "0" ] && [ "$UBUNTU" == "18.04" ] && [ "$KERNEL" == "4.15" ]
	then
		echo -e "O usuário e Root, continuando com o script..."
		echo -e "Distribuição e >= 18.04.x, continuando com o script..."
		echo -e "Kernel e >= 4.15, continuando com o script..."
		sleep 5
	else
		echo -e "Usuário não e Root ($USUARIO) ou Distribuição não e >=18.04.x ($UBUNTU) ou Kernel não e >=4.15 ($KERNEL)"
		echo -e "Caso você não tenha executado o script com o comando: sudo -i"
		echo -e "Execute novamente o script para verificar o ambiente."
		exit 1
fi
#		
# Script de instalação do SAMBA 4 no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
#
echo -e "Instalação do SAMBA 4 no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	add-apt-repository universe &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando o Repositório Multiversão do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	add-apt-repository multiverse &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt, aguarde..."
	#opção do comando: &>> (redirecionar a entrada padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o sistema, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o SAMBA 4 com suporte ao Active Directory, aguarde..."
echo
#
echo -e "Instalando as dependências do SAMBA-4, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando apt: -y (yes), \ (bar left) quedra de linha na opção do apt
	apt -y install ntp ntpdate build-essential libacl1-dev libattr1-dev libblkid-dev libgnutls28-dev libreadline-dev \
	python-dev libpam0g-dev python-dnspython gdb pkg-config libpopt-dev libldap2-dev dnsutils libbsd-dev docbook-xsl acl \
	attr debconf-utils figlet &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o KERBEROS, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando apt: -y (yes)
	# opção do comando | (piper): (Conecta a saída padrão com a entrada padrão de outro comando)
	# opção do comando cp: -v (verbose)
	# opção do comando mv: -v (verbose)
	echo "krb5-config krb5-config/default_realm string $REALM" | debconf-set-selections
	echo "krb5-config krb5-config/kerberos_servers string $FQDN" | debconf-set-selections
	echo "krb5-config krb5-config/admin_server string $FQDN" | debconf-set-selections
	echo "krb5-config krb5-config/add_servers_realm string $REALM" | debconf-set-selections
	echo "krb5-config krb5-config/add_servers boolean true" | debconf-set-selections
	echo "krb5-config krb5-config/read_config boolean true" | debconf-set-selections
	debconf-show krb5-config &>> $LOG
	apt -y install krb5-user krb5-config &>> $LOG
	mv -v /etc/krb5.conf /etc/krb5.conf.old &>> $LOG
	cp -v conf/krb5.conf /etc/krb5.conf &>> $LOG
		echo -e "Editando o arquivo de configuração do KERBEROS, pressione <Enter> para continuar..."
		read
		sleep 3
		vim /etc/krb5.conf
		echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
echo -e "KERBEROS instalado com sucesso!!!, continuando com o script..."
sleep 5
clear
#
echo -e "Atualizando as configurações do NTP Server, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando: > (redirecionar a entrada padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comando chown: -v (verbose), ntp.ntp (user e group)
	# opção do comando systemctl: stop (stop daemon - service)
	# opção do comando timedatectl: set-timezone (Zona de Horário)
	mv -v /etc/ntp.conf /etc/ntp.conf.old &>> $LOG
	cp -v conf/ntp.drift /var/lib/ntp/ntp.drift &>> $LOG
	chown -v ntp.ntp /var/lib/ntp/ntp.drift &>> $LOG
	cp -v conf/ntp.conf /etc/ntp.conf &>> $LOG
	systemctl stop ntp.service &>> $LOG
	timedatectl set-timezone "America/Sao_Paulo" &>> $LOG
	echo -e "Editando o arquivo de configuração do NTP, pressione <Enter> para continuar..."
		read
		sleep 3
		vim /etc/ntp.conf
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
	# opção do comando ntpdate: d (debug), q (query), u (unprivileged), v (verbose)
	# opção do comando systemctl: start (start daemon - service)
	# opção do comando ntpq: p (peers), n (numeric)
	# opção do comando hwclock: --systohc (Set the Hardware Clock to the current System Time)
	ntpdate -dquv $NTP &>> $LOG
	systemctl start ntp.service &>> $LOG
	ntpq -pn &>> $LOG
	hwclock --systohc &>> $LOG
		echo -e "Informações de Data/Hora de hardware: `hwclock`\n"
		echo -e "Informações de Data/Hora de software: `date`\n"
		echo -e "Pressione <Enter> para continuar...\n"
		read
echo -e "Atualização do NTP Server feita com sucesso!!!, continuando com o script..."
sleep 5
clear
#
echo -e "Atualizando as configurações do FSTAB, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando mount: -o (options)
	cp -v /etc/fstab /etc/fstab.old &>> $LOG
	echo -e "Editando o arquivo de configuração do FSTAB, pressione <Enter> para continuar..."
		read
		sleep 3
		vim /etc/fstab
		mount -o remount,rw /dev/sda2 &>> $LOG
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
echo -e "Atualização do FSTAB feita com sucesso!!!, continuando com o script..."
sleep 5
clear
#
echo -e "Atualizando as configurações do HOSTNAME, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando cp: -v (verbose)
	cp -v /etc/hostname /etc/hostname.old &>> $LOG
	echo -e "Editando o arquivo de configuração do HOSTNAME, pressione <Enter> para continuar..."
		read
		sleep 3
		vim /etc/hostname
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
echo -e "Atualização do HOSTNAME feita com sucesso!!!, continuando com o script..."
sleep 5
clear
#
echo -e "Atualizando as configurações do HOSTS, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando cp: -v (verbose)
	cp -v /etc/hosts /etc/hosts.old &>> $LOG
	echo -e "Editando o arquivo de configuração do HOSTS, pressione <Enter> para continuar..."
		read
		sleep 3
		vim /etc/hosts
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
echo -e "Atualização do HOSTS feita com sucesso!!!, continuando com o script..."
sleep 5
clear
#
echo -e "Atualizando as configurações do NSSWITCH, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando cp: -v (verbose)
	# opção do comando mv: -v (verbose)
	mv -v /etc/nsswitch.conf /etc/nsswitch.conf.old &>> $LOG
	cp -v conf/nsswitch.conf /etc/nsswitch.conf &>> $LOG
	echo -e "Editando o arquivo de configuração do NSSWITCH, pressione <Enter> para continuar..."
		read
		sleep 3
		vim /etc/nsswitch.conf
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
echo -e "Atualização do NSSWITCH feita com sucesso!!!, continuando com o script..."
sleep 5
clear
#
echo -e "Instalando o SAMBA-4, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando apt: -y (yes), \ (bar left) quedra de linha na opção do apt
	apt -y install samba samba-common smbclient cifs-utils samba-vfs-modules samba-testsuite samba-dsdb-modules \
	winbind ldb-tools libnss-winbind libpam-winbind unzip kcc tree &>> $LOG
echo -e "Instalação do SAMBA4 feito com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando as configurações do NETPLAN, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando cp: -v (verbose)
	cp -v /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.old &>> $LOG
	echo -e "Editando o arquivo de configuração do NETPLAN, pressione <Enter> para continuar..."
		read
		sleep 3
		vim /etc/netplan/50-cloud-init.yaml
		netplan --debug apply &>> $LOG
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
echo -e "Atualização do NETPLAN feita com sucesso!!!, continuando com o script..."
sleep 5
clear
#

echo -e "Promovendo o SAMBA-4 como Controlador de Domínio do Active Directory AD-DS, aguarde..."
	# opção do comando: &>> (redirecionar a entrada padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando systemctl: stop (), start (), disable (), mask (), unmask (), enable ()
	# opção do comando samba-tool: domain (), provision (), realm (), domain (), server-role (), dns-backend (), 
	# use-rc2307 (), adminpass (), function-level (), site (), host-ip (), option ()
	
	#
	systemctl stop samba-ad-dc.service smbd.service nmbd.service &>> $LOG
	
	#
	mv -v /etc/samba/smb.conf /etc/samba/smb.conf.old &>> $LOG
	
	#
	samba-tool domain provision --realm=$REALM --domain=$NETBIOS --server-role=$ROLE --dns-backend=$DNS --use-rfc2307 \
	--adminpass=$PASSWORD --function-level=$LEVEL --site=$SITE --host-ip=$IP --option="interfaces = lo $INTERFACE" \
	--option="bind interfaces only = yes" --option="allow dns updates = nonsecure and secure" \
	--option="dns forwarder = $GATEWAY" --option="winbind use default domain = yes" --option="winbind enum users = yes" \
	--option="winbind enum groups = yes" --option="winbind refresh tickets = yes" --option="server signing = auto" \
	--option="vfs objects = acl_xattr" --option="map acl inherit = yes" --option="store dos attributes = yes" \
	--option="client use spnego = no" --option="use spnego = no" --option="client use spnego principal = no" &>> $LOG
	
	#
	samba-tool user setexpiry $USER --noexpiry &>> $LOG
	
	#
	systemctl disable nmbd.service smbd.service winbind.service &>> $LOG
	
	#
	systemctl mask nmbd.service smbd.service winbind.service &>> $LOG
	
	#
	systemctl unmask samba-ad-dc.service &>> $LOG
	
	#
	systemctl enable samba-ad-dc.service &>> $LOG
	
	#
	systemctl start samba-ad-dc.service &>> $LOG
	
	#
	net rpc rights grant 'PTI\Domain Admins' SeDiskOperatorPrivilege -U $USER%$PASSWORD &>> $LOG
	
	#
	samba-tool dns zonecreate $DOMAIN $ARPA -U $USER --password=$PASSWORD &>> $LOG
	
	#
	samba-tool dns add $DOMAIN $ARPA $ARPAIP PTR $FQDN -U $USER --password=$PASSWORD &>> $LOG
	
	#
	samba_dnsupdate --use-file=/var/lib/samba/private/dns.keytab --verbose --all-names &>> $LOG
echo -e "Controlador de Domínio SAMBA-4 promovido com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalação do SAMBA-4 feita com Sucesso!!!, recomendado reinicializar o servidor no final da instalação."
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
