#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 28/02/2019
# Data de atualização: 26/04/2021
# Versão: 0.08
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do OpenSSH Server 7.6.x
#
# OpenSSH (Open Secure Shell) é um conjunto de utilitários de rede relacionado à segurança que provém a criptografia 
# em sessões de comunicações em uma rede de computadores usando o protocolo SSH. Foi criado com um código aberto 
# alternativo ao código proprietário da suíte de softwares Secure Shell, oferecido pela SSH Communications Security.
# OpenSSH foi desenvolvido como parte do projeto OpenBSD.
#
# Site Oficial do Projeto: https://www.openssh.com/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de atualização do Sistema: https://www.youtube.com/watch?v=esnu8TAepHU
# Vídeo de configuração da Placa de Rede: https://www.youtube.com/watch?v=zSUd4k108Zk
# Vídeo de configuração do Hostname e Hosts: https://www.youtube.com/watch?v=J7eyb5ynjZA
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
# Verificando se as dependências do OpenSSH estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do OpenSSH, aguarde... "
	for name in openssh-server
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
# Script de configuração do OpenSSH Server no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
clear
#
echo
echo -e "Configuração do OpenSSH Server no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a configuração do OpenSSH Server sua porta de conexão padrão é: 22\n"
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
echo -e "Configuração do OpenSSH Server, aguarde...\n"
#
echo -e "Atualizando os arquivos de configuração do OpenSSH Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	mv -v /etc/ssh/sshd_config /etc/ssh/sshd_config.old &>> $LOG
	cp -v conf/sshd_config /etc/ssh/sshd_config &>> $LOG
	cp -v conf/hosts.allow /etc/hosts.allow &>> $LOG
	cp -v conf/hosts.deny /etc/hosts.deny &>> $LOG
	cp -v conf/issue.net /etc/issue.net &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Editando o arquivo de configuração do OpenSSH Server, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/ssh/sshd_config
echo -e "Arquivos editado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Editando o arquivo de configuração TCPWrapped hosts.allow, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/hosts.allow
echo -e "Arquivos editado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Editando o arquivo de configuração TCPWrapped hosts.deny, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/hosts.deny
echo -e "Arquivos editado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Editando o arquivo de configuração Banner issue.net, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/issue.net
echo -e "Arquivos editado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Reinicializando o serviço do OpenSSH Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart ssh &>> $LOG
echo -e "Serviços reinicializados com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Verificando a porta de conexão do OpenSSH Server, aguarde..."
	# opção do comando netstat: a (all), n (numeric)
	# opção do comando grep: -i (ignore case)
	netstat -an | grep -i tcp | grep 22
echo -e "Porta verificada com sucesso!!!, continuando com o script..."
sleep 5
echo
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
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1
