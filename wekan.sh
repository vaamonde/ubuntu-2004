#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 14/01/2021
# Data de atualização: 27/04/2021
# Versão: 0.05
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
# Testado e homologado para a versão do Wekan
#
# O Wekan é um quadro Kanban de código aberto que permite criar tarefas baseadas em cartões e gerenciamento de pendências.
# Wekan permite criar tabuleiros nos quais os cartões podem ser movidos entre várias Colunas. Os tarefas podem ter vários 
# membros simultâneos, o que facilita a colaboração. Você pode atribuir etiquetas coloridas aos cartões para facilitar o 
# agrupamento e a filtragem; além disso, você pode adicionar membros a um cartão, por exemplo, atribuir uma tarefa a alguém.
#
# Kanban é uma estratégia para otimizar o fluxo de valor para partes interessadas através de um processo que utiliza um 
# sistema visual que limita a quantidade de trabalho em andamento através de um sistema de acompanhamento de etapas.
#
# Informações que serão solicitadas na configuração via Web do Wekan
# Não tem conta? Criar conta
#   Nome do usuário: vaamonde
#   Email: vaamonde@pti.intra
#   Senha: vaamonde <Criar Conta>
#
# Site Oficial do Projeto: https://wekan.github.io/
#
# Vídeo de instalação do GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=zDdCrqNhIXI
# Vídeo de configuração do OpenSSH Server no GNU/Linux Ubuntu Server 18.04.x LTS: https://www.youtube.com/watch?v=ecuol8Uf1EE
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
# Declarando as variáveis de configuração do Wekan
PORT="3000"
IP="172.16.1.20"
URL="http://$IP:$PORT"
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
# Verificando se as dependências do Wekan estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida), -n (permite nova linha)
# || (operador lógico OU), 2> (redirecionar de saída de erro STDERR), && = operador lógico AND, { } = agrupa comandos em blocos
# [ ] = testa uma expressão, retornando 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Wekan, aguarde... "
	for name in snapd
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
# Verificando se as portas 3000 e 27019 estão sendo utilizadas no servidor
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando, opção do comando nc: -v (verbose)
# -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 3000 &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: 3000 já está sendo utilizada nesse servidor.\n"
        echo -e "Verifique a porta e o serviço associada a ela e execute novamente esse script.\n"
		exit 1
	else
		echo -e "A porta: 3000 está disponível, continuando com o script..."
        sleep 3
fi
#
if [ "$(nc -vz 127.0.0.1 27019 &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: 27019 já está sendo utilizada nesse servidor.\n"
        echo -e "Verifique a porta e o serviço associada a ela e execute novamente esse script.\n"
		exit 1
	else
		echo -e "A porta: 27019 está disponível, continuando com o script..."
        sleep 3
fi
#
# Script de instalação do Wekan no GNU/Linux Ubuntu Server 18.04.x
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -I (all IP address)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
# opção do comando cut: -d (delimiter), -f (fields)
echo -e "Início do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
#
clear
echo -e "Instalação do Wekan no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do Wekan acesse a URL: http://`hostname -I | cut -d' ' -f1`:3000\n"
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
echo -e "Instalando o Wekan, aguarde...\n"
#
echo -e "Instalando o Wekan utilizando o Snap, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	snap install wekan &>> $LOG
echo -e "Wekan instalado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Configurando a URL, Porta e Reinicializando o Serviço do Wekan, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
    snap set wekan port=$PORT &>> $LOG
	snap set wekan root-url=$URL &>> $LOG
    systemctl restart snap.wekan.wekan.service &>> $LOG
echo -e "Wekan configurado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Verificando as portas de conexão do Wekan e do MongoDB, aguarde..."
	# opção do comando netstat: a (all), n (numeric)
	# opção do comando grep: \| (função OU)
	netstat -an | grep '3000\|27019'
echo -e "Portas verificadas com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalação do Wekan feita com Sucesso!!!."
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
