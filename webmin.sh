#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 10/11/2018
# Data de atualização: 23/05/2021
# Versão: 0.9
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do Webmin 1.974.x, Usermin 1.823.x
#
# Webmin é um programa de gerenciamento de servidor, que roda em plataformas Unix/Linux. Com ele você 
# pode usar também o Usermin e o Virtualmin. O Webmin funciona como um centralizador de configurações 
# do sistema, monitoração dos serviços e de servidores, fornecendo uma interface amigável, e que quando 
# configurado com um servidor web, pode ser acessado de qualquer local, através de um navegador: 
# https:\\(ip do servidor):(porta de utilização). Exemplo: https:\\172.16.1.20:10000
#
# Usermin é uma interface baseada na web para webmail, alteração de senha, filtros de e-mail, fetchmail
# e muito mais. Ele é projetado para uso por usuários não-root regulares em um sistema Unix e os limita
# a tarefas que seriam capazes de realizar se logados via SSH ou no console. 
#
# Informações que serão solicitadas na configuração via Web do Webmin e Usermin
# Username: vaamonde
# Password: pti@2018: Sign In
#
# Site oficial do Webmin: http://www.webmin.com/
# Site oficial do Usermin: https://www.webmin.com/usermin.html
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de configuração do OpenSSH no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=ecuol8Uf1EE&t
# Vídeo de instalação do LAMP Server no Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=6EFUu-I3u4s
#
# Variável da Data Inicial para calcular o tempo de execução do script (VARIÁVEL MELHORADA)
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário e "root", versão do ubuntu e kernel
# opções do comando id: -u (user), opções do comando: lsb_release: -r (release), -s (short), 
# opções do comando uname: -r (kernel release), opções do comando cut: -d (delimiter), -f (fields)
# opção do carácter: | (piper) Conecta a saída padrão com a entrada padrão de outro comando
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
# Declarando as variáveis para o download do Webmin (Link atualizado no dia 22/05/2021)
WEBMIN="https://prdownloads.sourceforge.net/webadmin/webmin_1.974_all.deb"
USERMIN="http://prdownloads.sourceforge.net/webadmin/usermin_1.823_all.deb"
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
# Script de instalação do Webmin no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Instalação do Webmin no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do Webmin acessar a URL: https://`hostname -I | cut -d ' ' -f1`:10000/"
echo -e "Após a instalação do Usermin acessar a URL: https://`hostname -I | cut -d ' ' -f1`:20000/\n"
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
	# opção do comando: &>> (redirecionar a saída padrão)
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
echo -e "Instalando o Webmin, aguarde...\n"
#
echo -e "Instalando as dependências do Webmin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes), \ (Bar, opção de quebra de linha no apt)
	apt -y install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime \
	libio-pty-perl apt-show-versions python unzip &>> $LOG
echo -e "Instalação das dependências feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Fazendo o download do Webmin e Usermin do site Oficial, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# removendo versões anteriores baixadas do Webmin
	# opção do comando rm: -v (verbose)
	# opção do comando wget: -O (output document file)
	rm -v webmin.deb &>> $LOG
	rm -v usermin.deb &>> $LOG
	wget $WEBMIN -O webmin.deb &>> $LOG
	wget $USERMIN -O usermin.deb &>> $LOG
echo -e "Download do Webmin e Usermin feito com sucesso!!!, continuando com o script...\n"
sleep 5
#				 
echo -e "Instalando o Webmin, esse processo demora um pouco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando dpkg: -i (install)
	dpkg -i webmin.deb &>> $LOG
echo -e "Instalação do Webmin feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Usermin, esse processo demora um pouco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando dpkg: -i (install)
	dpkg -i usermin.deb &>> $LOG
echo -e "Instalação do Webmin feita com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando os Serviços do Webmin e Usermin, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl start webmin &>> $LOG
	systemctl start usermin &>> $LOG
echo -e "Serviços iniciados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de conexões do Webmin e Usermin, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric)
	# opção do comando grep: -i (ignore case)
	netstat -an | grep -i tcp | grep '10000\|20000'
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Webmin e Usermin feito com Sucesso!!!"
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
