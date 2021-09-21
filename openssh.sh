#!/bin/bash
# Autor: Robson Vaamonde
# Procedimentos em TI: http://procedimentosemti.com.br
# Bora para Prática: http://boraparapratica.com.br
# Robson Vaamonde: http://vaamonde.com.br
# Facebook Procedimentos em TI: https://www.facebook.com/ProcedimentosEmTi/
# Facebook Bora para Prática: https://www.facebook.com/boraparapratica/
# Instagram Procedimentos em TI: https://www.instagram.com/procedimentoem/
# YouTUBE Bora Para Prática: https://www.youtube.com/boraparapratica
# LinkedIn Robson Vaamonde: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Data de criação: 20/09/2021
# Data de atualização: 20/09/2021
# Versão: 0.01
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Kernel >= 5.14.x
# Testado e homologado para a versão do OpenSSH Server 
#
# O OpenSSH (Open Secure Shell) é um conjunto de utilitários de rede relacionado à 
# segurança que provém a criptografia em sessões de comunicações em uma rede de 
# computadores usando o protocolo SSH. Foi criado com um código aberto alternativo 
# ao código proprietário da suíte de softwares Secure Shell, oferecido pela SSH 
# Communications Security. OpenSSH foi desenvolvido como parte do projeto OpenBSD.
#
# O TCP Wrapper é um sistema de rede ACL baseado em host, usado para filtrar acesso 
# à rede a servidores de protocolo de Internet (IP) em sistemas operacionais do tipo 
# Unix, como Linux ou BSD. Ele permite que o host, endereços IP de sub-rede, nomes 
# e/ou respostas de consulta ident, sejam usados como tokens sobre os quais realizam-se 
# filtros para propósitos de controle de acesso.
#
# Site Oficial do Projeto OpenSSH: https://www.openssh.com/
#
# Variável da Data Inicial para calcular o tempo de execução do script
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
#
# Variável do caminho do Log dos Script utilizado nesse script
# opções do comando cut: -d (delimiter), -f (fields)
# opção da variável $0: (variável de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Exportando o recurso de Noninteractive do Debconf para não solicitar telas de configuração
export DEBIAN_FRONTEND="noninteractive"
#
# Verificando se o usuário é Root e se a Distribuição é >= 20.04
# [ ] = teste de expressão, 
# && = operador lógico AND,
# == comparação de string, 
# exit 1 = A maioria dos erros comuns na execução
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
# Verificando as dependências do OpenSSH estão instaladas
# opção do comando dpkg: -s (status), 
# opção do comando echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 
# 2> (redirecionar de saída de erro STDERR), 
# && = operador lógico AND, 
# { } = agrupa comandos em blocos, 
# [ ] = testa uma expressão, retornando 0 ou 1, 
# -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do OpenSSH, aguarde... "
	for name in openssh-server
	do
  		[[ $(dpkg -s $name 2> /dev/null) ]] || { 
              echo -en "\n\nO software: $name precisa ser instalado.
			  \n Use o comando 'apt install $name'\n";
              deps=1; 
              }
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || { 
            echo -en "\nInstale as dependências acima e execute novamente este script\n";
            exit 1; 
            }
		sleep 5
#
# Script de configuração do OpenSSH Server no GNU/Linux Ubuntu Server 20.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando cut: -d (delimiter), -f (fields)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
clear
#
echo
echo -e "Configuração do OpenSSH Server no GNU/Linux Ubuntu Server 20.04.x\n"
echo -e "Porta padrão de conexão com o OpenSSH Server: 22"
echo -e "Utilizar o comando: ssh usuario@$(hostname -I | cut -d ' ' -f1) para acessar o servidor\n"
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
echo -e "Configurando o Serviço do OpenSSH Server, aguarde...\n"
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
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do OpenSSH Server, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/ssh/sshd_config
echo -e "Arquivos editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração TCP Wrapper hosts.allow, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/hosts.allow
echo -e "Arquivos editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração TCP Wrapper hosts.deny, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/hosts.deny
echo -e "Arquivos editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração Banner issue.net, pressione <Enter> para continuar..."
	# opção do comando: &>> (redirecionar a saída padrão)
	read
	vim /etc/issue.net
echo -e "Arquivos editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do OpenSSH Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart ssh &>> $LOG
echo -e "Serviços reinicializados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do OpenSSH Server, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric), -l (listening), -t (tcp), -u ()
	# opção do comando ss: -t (), u (), -l (), -p (), -n ()
	# opção do comando lsof: -i (), -P (), -n ()
	# opção do comando grep: -i (ignore case)
	netstat -ant | grep -i tcp | grep 22
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
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
