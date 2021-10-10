#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 22/11/2018
# Data de atualização: 27/04/2021
# Versão: 0.08
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do Tomcat 9.0.x
#
# O software Tomcat, desenvolvido pela Fundação Apache, permite a execução de aplicações para web. 
# Sua principal característica técnica é estar centrada na linguagem de programação Java, mais especificamente 
# nas tecnologias de Servlets e de Java Server Pages (JSP).
#
# Site Oficial do Tomcat: http://tomcat.apache.org/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de instalação do OPENFIRE: https://www.youtube.com/watch?v=_2-cVeA-Rvo&t
#
# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário é "root", versão do ubuntu e kernel
# opções do comando id: -u (user), opções do comando: lsb_release: -r (release), -s (short), 
# opões do comando uname: -r (kernel release), opções do comando cut: -d (delimiter), -f (fields)
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
KERNEL=$(uname -r | cut -d'.' -f1,2)
#
# Variável do caminho do Log dos Script utilizado nesse curso (VARIÁVEL MELHORADA)
# opções do comando cut: -d (delimiter), -f (fields)
# $0 (variável de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
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
		echo -e "Kernel é >=4.15, continuando com o script..."
		sleep 5
	else
		echo -e "Usuário não é Root ($USUARIO) ou Distribuição não é >=18.04.x ($UBUNTU) ou Kernel não é >=4.15 ($KERNEL)"
		echo -e "Caso você não tenha executado o script com o comando: sudo -i"
		echo -e "Execute novamente o script para verificar o ambiente."
		exit 1
fi
#
# Verificando se as dependências do Tomcat estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Tomcat, aguarde... "
	for name in openjdk-8-jdk openjdk-8-jre
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
# Script de instalação do Tomcat no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do Tomcat no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do Tomcat acessar a URL: http://`hostname -I | cut -d' ' -f1`:8080/\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet..."
sleep 5
echo
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
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
	# opção do comando: &>> (redirecionar de saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Atualizando o sistema, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Removendo software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o Tomcat, aguarde..."
echo
#
echo -e "Instalando as dependências do Tomcat, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install default-jdk &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Verificando a versão do Java, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando update-java-alternatives: -l (list)
	java -version &>> $LOG
	update-java-alternatives -l &>> $LOG
echo -e "Versão verificada com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando o Tomcat, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install tomcat9 tomcat9-admin tomcat9-common tomcat9-docs tomcat9-examples tomcat9-user &>> $LOG
echo -e "Tomcat instalado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Configurando o usuário e senha do Tomcat, pressione <Enter> para continuar"
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando apt: -y (yes)
	# opção do comando cp: -v (verbose)
	read
	cp -v /etc/tomcat9/tomcat-users.xml /etc/tomcat9/tomcat-users.xml.bkp &>> $LOG
	cp -v conf/tomcat-users.xml /etc/tomcat9/tomcat-users.xml &>> $LOG
	vim /etc/tomcat9/tomcat-users.xml
	systemctl restart tomcat9
echo -e "Usuário do Tomcat configurado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Verificando a porta de conexão do Tomcat, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric)
	netstat -an | grep 8080
echo -e "Porta de conexão verificada com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalação do Tomcat feita com Sucesso!!!"
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
