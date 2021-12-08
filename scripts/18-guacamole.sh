#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 04/01/2021
# Data de atualização: 15/05/2021
# Versão: 0.06
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do Apache Guacamole Server 1.3.x e Cliente 1.3.x
#
# O Apache Guacamole é um gateway de desktop remoto sem cliente, ele suporta protocolos padrão como VNC, 
# RDP e SSH., ele é chamado de Clientless porque nenhum plug-in ou software cliente é necessário para o
# seu funcionamento isso e possível graças ao HTML5, uma vez que o Apache Guacamole é instalado em um 
# servidor, tudo que você precisa para acessar seus desktops é um navegador da web.
#
# Informações que serão solicitadas na configuração via Web do Apache Guacamole
# Username: guacadmin
# Password: guacadmin
#
# Instalação do Vino VNC Server no Linux Mint 19.x e 20.x
# 	sudo apt update
#	sudo apt install vino
#	sudo gsettings set org.gnome.Vino prompt-enabled true
#	sudo gsettings set org.gnome.Vino require-encryption false
#	cd /usr/lib/vino/
#	./vino-server &
#	sudo netstat -pl | grep 5900
#	sudo nc -vz 127.0.0.1 5900
#
# Instalação do Telnet Server no Ubuntu Server 18.04.x
#	sudo apt update
#	sudo apt install telnetd
#
# Instalação do OpenSSH Sever no Ubuntu Server 18.04.x
#	sudo apt update
# 	sudo apt install openssh-server
#
# Site Oficial do Projeto: https://guacamole.apache.org/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de configuração do OpenSSH Sever: https://www.youtube.com/watch?v=ecuol8Uf1EE
# Vídeo de instalação do Tomcat Server: https://www.youtube.com/watch?v=yXc3v3HAG5w
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
# Declarando as variáveis de download do Apache Guacamole (Links atualizados no dia 04/01/2021)
SERVER="https://apachemirror.wuchna.com/guacamole/1.3.0/source/guacamole-server-1.3.0.tar.gz"
CLIENT="https://apachemirror.wuchna.com/guacamole/1.3.0/binary/guacamole-1.3.0.war"
#
# Localização padrão do diretório de configuração e do webapp do Tomcat utilizado no script tomcat.sh
TOMCAT="/usr/share/tomcat9/"
WEBAPPS="/var/lib/tomcat9/webapps/"
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
# Verificando se as dependências do Apache Guacamole estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Apache Guacamole, aguarde... "
	for name in tomcat9 tomcat9-admin tomcat9-common tomcat9-docs tomcat9-examples tomcat9-user
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            echo -en "Recomendo utilizar o script: tomcat.sh para resolver as dependências."
            exit 1; 
            }
		sleep 5
#
# Script de instalação do Apache Guacamole Server e Client no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo -e "Instalação do Apache Guacamole Server e Client no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do Apache Guacamole acesse a URL: http://`hostname -I | cut -d' ' -f1`:8080/guacamole\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository universe &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Adicionando o Repositório Multiversão do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	add-apt-repository multiverse &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando as listas do Apt, aguarde..."
	#opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando o sistema, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Removendo software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o Apache Guacamole Server e Client, aguarde...\n"
#
echo -e "Instalando as Dependências do Apache Guacamole Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev \
	libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev \
	libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libpulse-dev libssl-dev \
	libvorbis-dev libwebp-dev gcc-6 g++-6 make libfreerdp-dev freerdp2-x11 libguac-client-rdp0 &>> $LOG
echo -e "Dependências instaladas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Fazendo o download do Apache Guacamole Server do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando rm: -v (verbose), -f (force), -R (recursive)
	# opção do comando wget: -O (output document file)
	rm -v guacamole.tar.gz &>> $LOG
	rm -Rfv guacamole-server-*/ &>> $LOG
	wget $SERVER -O guacamole.tar.gz &>> $LOG
echo -e "Download do Apache Guacamole Server feito com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Descompactando o Apache Guacamole Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando tar: -z (gzip), -x (extract), -v (verbose), -f (file)
	tar -zxvf guacamole.tar.gz &>> $LOG
echo -e "Apache Guacamole Server descompactado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o Apache Guacamole Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando autoreconf: -f (force), -i (install)
	cd guacamole-server-*/ &>> $LOG
		autoreconf -fi &>> $LOG
		./configure --with-init-dir=/etc/init.d &>> $LOG
		make &>> $LOG
		make install &>> $LOG
		ldconfig &>> $LOG
	cd .. &>> $LOG
echo -e "Apache Guacamole Server instalado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Iniciando o serviço do Apache Guacamole Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable guacd &>> $LOG
	systemctl start guacd &>> $LOG
echo -e "Serviço do Apache Guacamole Server iniciado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Criando o diretório e baixando o Apache Guacamole Client, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mkdir: -v (verbose), {} (block command)
	# opção do comando {}: Agrupa comandos em um bloco
	# opção do comando wget: -O (output document file)
	# opção do comando ln: -s (symbolic), -v (verbose)
	mkdir -v /etc/guacamole &>> $LOG
	mkdir -v /etc/guacamole/{extensions,lib} &>> $LOG
	wget $CLIENT -O /etc/guacamole/guacamole.war &>> $LOG
	ln -sv /etc/guacamole/guacamole.war $WEBAPPS &>> $LOG
	ln -sv /etc/guacamole $TOMCAT.guacamole &>> $LOG
echo -e "Download dos Apache Guacamole Client feito com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando os arquivos de configuração do Apache Guacamole Client, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando cp: -v (verbose)
	cp -v conf/guacamole.properties /etc/guacamole/guacamole.properties &>> $LOG
	cp -v conf/user-mapping.xml /etc/guacamole/user-mapping.xml &>> $LOG
	cp -v /etc/default/tomcat9 /etc/default/tomcat9.old &>> $LOG
	cp -v conf/tomcat9 /etc/default/tomcat9 &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
	echo -e "Editando o arquivo de configuração do Apache Guacamole Properties, pressione <Enter> para continuar"
		read
		sleep 3
		vim /etc/guacamole/guacamole.properties
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
	echo -e "Editando o arquivo de configuração do Apache Guacamole User Mapping, pressione <Enter> para continuar"
		read
		sleep 3
		vim /etc/guacamole/user-mapping.xml
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
    echo -e "Editando o arquivo de configuração do Tomcat9, pressione <Enter> para continuar"
	    read
		sleep 3
		vim /etc/default/tomcat9
	echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
    echo -e "Reiniciando os Serviços do Apache Guacamole Server e Tomcat9, pressione <Enter> para continuar"
	systemctl restart tomcat9 &>> $LOG
	systemctl restart guacd &>> $LOG
echo -e "Arquivos atualizados com com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Verificando a porta de conexão do Tomcat e do Apache Guacamole Server, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric)
	netstat -an | grep '8080\|4822'
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalação do Apache Guacamole Server e Client feita com Sucesso!!!."
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
