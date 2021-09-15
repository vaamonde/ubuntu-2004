#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 12/06/2021
# Data de atualização: 18/06/2021
# Versão: 0.04
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do TFTP-HPA v5.2.x e PXE Syslinux v
#
# Trivial File Transfer Protocol (ou apenas TFTP) é um protocolo de transferência de arquivos, 
# muito simples, semelhante ao FTP. É geralmente utilizado para transferir pequenos arquivos 
# entre hosts numa rede, tal como quando um terminal remoto ou um cliente inicia o seu 
# funcionamento, a partir do servidor.
#
# O Ambiente de Pré-execução (PXE do inglês: Preboot eXecution Environment) é um ambiente para 
# inicializar computadores usando a Interface da Placa de Rede sem a dependência da disponibilidade 
# de dispositivos de armazenamento (como Disco Rígidos) ou algum Sistema Operacional instalado. 
# Ou seja, o Sistema Operacional do equipamento é carregado pela interface de rede toda vez que o 
# mesmo é ligado, evitando assim o uso de unidades de armazenamento local e ou ação de atualização 
# para cada equipamento. Basta atualizar o sistema no servidor que disponibiliza o mesmo, que todos
# os equipamentos irão iniciar a nova versão a partir do próximo boot.
#
# Site Oficial do Projeto Tftpd-Hpa: https://git.kernel.org/pub/scm/network/tftp/tftp-hpa.git/about/
# Site Oficial do Projeto Syslinux: https://wiki.syslinux.org/wiki/index.php?title=The_Syslinux_Project 
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de configuração do OpenSSH no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=ecuol8Uf1EE&t
# Vídeo de instalação e configuração do Bind9 DNS e do ISC DHCP Server: https://www.youtube.com/watch?v=NvD9Vchsvbk
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
# Variáveis de localização do TFTP-HPA Server e Syslinux/PXE
TFTP="/var/lib/tftpboot"
PXE="/usr/lib/PXELINUX"
SYSLINUX="/usr/lib/syslinux"
# 
# Link de download do Puppy Linux (Link atualizado no dia 12/06/2021)
PUPPY="http://distro.ibiblio.org/puppylinux/puppy-fossa/fossapup64-9.5.iso"
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
# Verificando se as dependências do Tftpd-Hpa Server e PXE/Syslinux estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Tftpd-Hpa Server e PXE/Syslinux, aguarde... "
	for name in bind9 bind9utils isc-dhcp-server
	do
		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
			echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
			deps=1; 
			}
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
			echo -en "\nInstale as dependências acima e execute novamente este script\n";
			echo -en "Recomendo utilizar o script: dnsdhcp.sh para resolver as dependências."
			exit 1; 
			}
		sleep 5
#
# Script de instalação do Tftpd-Hpa Server e PXE/Syslinux no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do Tftpd-Hpa Server e PXE/Syslinux no GNU/Linux Ubuntu Server 18.04.x\n"
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
echo -e "Instalando o Tftpd-Hpa Server/Client e PXE/Syslinux, aguarde...\n"
sleep 5
#
echo -e "Instalando o Serviço do Tftpd-Hpa Server e Client, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt -y install tftpd-hpa tftp-hpa &>> $LOG
echo -e "Tftpd-Hpa Server e Client instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Serviço do Syslinux e Pxelinux, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt -y install syslinux syslinux-utils syslinux-efi pxelinux &>> $LOG
echo -e "Syslinux e Pxelinux instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o arquivo de configuração do Tftpd-Hpa Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	mv -v /etc/default/tftpd-hpa /etc/default/tftpd-hpa.old &>> $LOG
	cp -v conf/tftpd-hpa /etc/default/tftpd-hpa &>> $LOG
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Copiando a estrutura de arquivos e diretórios do Syslinux e Pxelinux, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose)
	# opção do comando cp: -v (verbose)
	mkdir -v $TFTP/pxelinux.cfg &>> $LOG
	mkdir -v $TFTP/puppy &>> $LOG
	cp -v $PXE/pxelinux.0 $TFTP &>> $LOG
	cp -v $SYSLINUX/memdisk $TFTP &>> $LOG
	cp -v $SYSLINUX/modules/bios/{ldlinux.c32,libcom32.c32,libutil.c32,vesamenu.c32} $TFTP &>> $LOG
	cp -v conf/default-pxe $TFTP/pxelinux.cfg/default &>> $LOG
echo -e "Estrutura de arquivos e diretórios copiados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Tftpd-Hpa Server, pressione <Enter> para continuar."
	read
	vim /etc/default/tftpd-hpa
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do ISC-DHCP Server, pressione <Enter> para continuar."
	read
	vim /etc/dhcp/dhcpd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do TCPWrappers, pressione <Enter> para continuar."
	read
	vim /etc/hosts.allow
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Pxelinux, pressione <Enter> para continuar."
	read
	vim $TFTP/pxelinux.cfg/default
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Baixando a distribuição Puppy Linux e criando o Boot PXE, aguarde esse processo demora um pouco..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output file)
	# opção do comando mount: -v (verbose)
	# opção do comando cp: -a (archive), -v (verbose)
	# opção do comando mkdir: -v (verbose)
	# opção do comando cpio: -i (extract), -v (verbose), -o (create), -H (format), newc (SR4 portable format)
	# opção do comando gzip: -9 (best), -v (verbose)
	# opção do comando umount: -v (verbose)
	# opção do comando cd: - (rollback)
	rm -v puppy.iso &>> $LOG
	wget $PUPPY -O puppy.iso &>> $LOG
	mount -v puppy.iso /mnt &>> $LOG
	cp -av /mnt/vmlinuz $TFTP/puppy &>> $LOG
	mkdir -v /tmp/puppy &>> $LOG
	cd /tmp/puppy &>> $LOG
		zcat /mnt/initrd.gz | cpio -i -v &>> $LOG
		cp -av /mnt/*.sfs . &>> $LOG
		find . | cpio -o -H newc | gzip -9 -v > $TFTP/puppy/initrd.gz
		umount -v /mnt &>> $LOG
	cd - &>> $LOG
echo -e "Criação do Boot PXE do Puppy Linux feito com sucesso!!!, continuando com o script...\n"
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
echo -e "Verificando as portas do ISC-DHCP Server e do Tftpd-Hpa Server, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric)
	netstat -an | grep ':67\|:69'
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Tftpd-Hpa Server/Client e PXE/Syslinux feita com Sucesso!!!"
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
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1
