#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 16/05/2021
# Data de atualização: 09/06/2021
# Versão: 0.04
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do Zimbra Collaboration Community 8.8.x, Zimbra Desktop 7.3.x
#
# O Zimbra é uma solução de e-mail, calendário e colaboração de classe empresarial desenvolvida para 
# rede local ou nuvem (pública ou privada). Com uma interface baseada em navegador redesenhada, o 
# Zimbra oferece a experiência de mensagens mais inovadora disponível atualmente, conectando os 
# usuários finais às informações e atividades em suas nuvens pessoais. 
#
# MENSAGENS QUE SERÃO SOLICITADAS NA INSTALAÇÃO DO ZIMBRA COLLABORATION COMMUNITY:
# 01. Do you agree with the terms of the software license agreement? [N] Y <Enter>
# 02. Use Zimbra's package repository [Y] <Enter>
# 03. Install zimbra-ldap [Y] Y <Enter>
# 04. Install zimbra-logger [Y] <enter>
# 05. Install zimbra-mta [Y] <Enter>
# 06. Install zimbra-dnscache [Y] N <Enter>
# 07. Install zimbra-snmp [Y] <Enter>
# 08. Install zimbra-store [Y] <Enter>
# 09. Install zimbra-apache [Y] <Enter>
# 10. Install zimbra-spell [Y] <Enter>
# 11. Install zimbra-memcached [Y] <Enter>
# 12. Install zimbra-proxy [Y] <Enter>
# 13. Install zimbra-drive [Y] <Enter>
# 14. Install zimbra-imapd (BETA - for evaluation only) [N] <Enter>
# 15. Install zimbra-chat [Y] <Enter>
# 16. The system will be modified.  Continue? [N] Y <Enter>
# 17. Change domain name? [Yes] Y <Enter>
# 18. Create domain: [ptispo01ws01.pti.intra] pti.intra <Enter>
# 19. Address unconfigured (**) items  (? - help) 6 <Enter>
#	19.1 Select, or 'r' for previous menu [r] 4 <Enter>
#	19.2 Password for admin@pti.intra (min 6 characters): [XXXXXX] pti@2018 <Enter>
#	19.3 Select, or 'r' for previous menu [r] <Enter>
# 20. Select from menu, or press 'a' to apply config (? - help) a <Enter>
# 21. Save configuration data to a file? [Yes] <Enter>
# 22. Save config in file: [/opt/zimbra/config.16728] <Enter>
# 23. The system will be modified - continue? [No] Yes <Enter>
# 24. Notify Zimbra of your installation? [Yes] <Enter>
# 25. Configuration complete - press return to exit <Enter>
#
# INFORMAÇÕES QUE SERÃO SOLICITADAS VIA WEB (NAVEGADOR) DO ZIMBRA ADMIN CONSOLE:
# 01. Acessar a URL: https://mail.pti.intra:7071
# 02. Nome do usuário: admin
# 03. Senha: pti@2018 <Login>
#
# INFORMAÇÕES QUE SERÃO SOLICITADAS VIA WEB (NAVEGADOR) DO ZIMBRA WEBMAIL:
# 01. Acessar a URL: https://mail.pti.intra
# 02. Nome do usuário: admin
# 03. Senha: pti@2018
# 04. Versão: Padrão <Login>
#
# Site Oficial do Projeto Zimbra: https://www.zimbra.org
# Download do Zimbra Collaboration Community: https://zimbra.org/download/zimbra-collaboration
# Download do Zimbra Desktop: https://zimbra.org/download/zimbra-desktop
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de configuração do OpenSSH no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=ecuol8Uf1EE&t
# Vídeo de instalação e configuração do Bind9 DNS Server e do ISC DHCP Server no GNU/Linux Ubuntu Server 18.04.x LTS: 
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
# Declarando as variáveis de download do Zimbra (Link atualizado no dia 23/05/2021)
ZIMBRA="https://files.zimbra.com/downloads/8.8.15_GA/zcs-8.8.15_GA_3869.UBUNTU18_64.20190918004220.tgz"
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
# Verificando se as dependências do Zimbra estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Zimbra Collaboration Community, aguarde... "
	for name in bind9 bind9utils 
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
# Script de instalação do Zimbra Collaboration Community no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do Zimbra Collaboration Community no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do Zimbra Admin Console acessar a URL: https://mail.`hostname -d | cut -d' ' -f1`:7071"
echo -e "Após a instalação do Zimbra Webmail acessar a URL: https://mail.`hostname -d | cut -d' ' -f1`\n"
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
echo -e "Instalando o Zimbra Collaboration Community, aguarde...\n"
sleep 5
#
echo -e "Fazendo o download do site Oficial do Zimbra Collaboration Community, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v zimbra.tgz &>> $LOG
	wget $ZIMBRA -O zimbra.tgz &>> $LOG
echo -e "Download do Zimbra feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Descompactando o Zimbra Collaboration Community, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando tar: -x (extract), -v (verbose), -f (file)
	tar -xvf zimbra.tgz &>> $LOG
echo -e "Zimbra descompactado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Zimbra Collaboration Community, pressione <Enter> para instalar.\n"
echo -e "CUIDADO!!! com as opções que serão solicitadas no decorrer da instalação do Zimbra."
echo -e "Veja a documentação das opções de instalação a partir da linha: 19 do arquivo $0"
echo -e "Existe a possibilidade da instalação automatizada utilizando o comando: ./install /root/ubuntu/conf/zimbra-install"
	read
	sleep 5
	cd zcs*/
		./install.sh
	cd ..
echo -e "Instalação do Zimbra Collaboration Community feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Habilitando o Serviço do Zimbra Collaboration Community, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable zimbra.service &>> $LOG
	systemctl start zimbra.service &>> $LOG
echo -e "Serviço habilitado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o Status dos Serviços do Zimbra Collaboration Community, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando su: - (login), -c (command)
	su - zimbra -c "zmcontrol status" &>> $LOG
echo -e "Verificação do Status dos Serviços feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de Conexões do Zimbra Collaboration Community, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric)
	# portas do Zimbra: 80 (http), 25 (smtp), 110 (pop3), 143 (imap4), 443 (https), 587 (smtp), 7071 (admin)
	netstat -an | grep '0:80\|0:25\|0:110\|0:143\|0:443\|0:587\|0:7071'
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Zimbra Collaboration Community feita com Sucesso!!!."
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
