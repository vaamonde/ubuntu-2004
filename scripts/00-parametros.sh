#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Data de criação: 10/10/2021
# Data de atualização: 17/10/2021
# Versão: 0.07
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
#
# Parâmetros (variáveis de ambiente) utilizados nos scripts de instalação dos Serviços de Rede
# no Ubuntu Server 20.04.x LTS, antes de modificar esse arquivo, veja os arquivos: BUGS, NEW e
# CHANGELOG para mais informações.
#
#=============================================================================================
#                    VARIÁVEIS GLOBAIS UTILIZADAS EM TODOS OS SCRIPTS                        #
#=============================================================================================
#
# Declarando as variáveis utilizadas nas verificações e validação da versão do Servidor Ubuntu 
#
# Variável da Data Inicial do script, utilizada para calcular o tempo de execução do script
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário é "root" e versão do "ubuntu"
# opções do comando id: -u (user)
# opções do comando: lsb_release: -r (release), -s (short), 
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
#
# Variável do caminho e nome do arquivo de Log utilizado nesse script
# $0 (variável de ambiente do nome do comando/script executado)
# opção do redirecionador | piper: Conecta a saída padrão com a entrada padrão de outro comando
# opções do comando cut: -d (delimiter), -f (fields)
LOGSCRIPT="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Exportando o recurso de Noninteractive do Debconf para não solicitar telas de configuração
export DEBIAN_FRONTEND="noninteractive"
#
#=============================================================================================
#              VARIÁVEIS DE REDE DO SERVIDOR UTILIZADAS EM TODOS OS SCRIPTS                  #
#=============================================================================================
#
# Declarando as variáveis utilizadas nas configurações de Rede do Servidor Ubuntu 
#
# Variável do Nome (Hostname) do Servidor
NOMESERVER="ptispo01ws01"
#
# Variável do Nome (Hostname) FQDN (Fully Qualified Domain Name) do Servidor
FQDNSERVER="ptispo01ws01.pti.intra"
#
# Variável do Nome de Domínio do Servidor
DOMINIOSERVER="pti.intra"
#
# Variável do Endereço IPv4 do Servidor
IPV4SERVER="172.16.1.20"
#
# Variável do arquivo de configuração da Placa de Rede do Netplan do Servidor
# CUIDADO!!! o nome do arquivo de configuração da placa de rede pode mudar dependendo da versão
# do Ubuntu Server, verificar o conteúdo do diretório: /etc/netplan para saber o nome do arquivo
# de configuração do Netplan e mudar a variável NETPLAN
NETPLAN="/etc/netplan/00-installer-config.yaml"
#
#=============================================================================================
#                          VARIÁVEIS UTILIZADAS NO SCRIPT: 03-dns.sh                         #
#=============================================================================================
#
# Declarando as variáveis de Pesquisa Direta do Domínio, Reversa e Subrede do Bind DNS Server
#
# Variável do nome do Domínio do Servidor DNS
DOMAIN=$DOMINIOSERVER
#
# Variável do nome da Pesquisa Reversar do Servidor de DNS
DOMAINREV="1.16.172.in-addr.arpa"
#
# Variável do endereço IPv4 da Subrede do Servidor de DNS
NETWORK="172.16.1."
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 04-dhcpdns.sh                        #
#=============================================================================================
#
# Declarando a variável de geração da chave de atualização dos registros do Bind DNS Server 
# integrado no ISC DHCP Server
# 
# Variável da senha utilizada na criação da chave de atualização dos ponteiros do DNS e DHCP
USERUPDATE="vaamonde"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 05-ntp.sh                            #
#=============================================================================================
#
# Declarando as variáveis utilizadas nas configurações do Serviço do NTP Server e Client

# Variável de sincronização do NTP Server com o Site ntp.br
NTPSERVER="a.st1.ntp.br"
#
# Variável do Zona de Horário do NTP Sever
TIMEZONE="America/Sao_Paulo"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 06-tftphpa.sh                        #
#=============================================================================================
# 
# Declarando as variáveis utilizadas nas configurações do Serviço do TFTP-HPA Server
#
# Variável de criação do diretório padrão utilizado pelo serviço do TFTP-HPA
TFTP="/var/lib/tftpboot"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 07-lamp.sh                          #
#=============================================================================================
# 
# Declarando as variáveis utilizadas nas configurações dos Serviços do LAMP-Server
#
# Variável do usuário padrão do MySQL (Root do Mysql, diferente do Root do GNU/Linux)
USERMYSQL="root"
#
# Variáveis da senha e confirmação da senha do usuário Root do Mysql 
SENHAMYSQL="pti@2018"
AGAIN=$SENHAMYSQL
#
# Variáveis de configuração e liberação da conexão remota para o usuário Root do MySQL
# opções do comando CREATE: create (criar), user (criação de usuário), user@'%' (usuário @ localhost), 
# identified by (identificado por - senha do usuário)
# opções do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas) to (para), user@'%' (usuário @ localhost), 
# opção do comando FLUSH: privileges (recarregar as permissões de privilegios)
CREATEUSER="CREATE USER '$USERMYSQL'@'%' IDENTIFIED BY '$SENHAMYSQL';"
GRANTALL="GRANT ALL ON *.* TO '$USERMYSQL'@'%';"
FLUSH="FLUSH PRIVILEGES;"
#
# Variável de configuração do usuário padrão de administração do PhpMyAdmin (Root do MySQL)
ADMINUSER=$USERMYSQL
#
# Variáveis da senha do usuário Root do Mysql e senha de administração o PhpMyAdmin
ADMIN_PASS=$SENHAMYSQL
APP_PASSWORD=$SENHAMYSQL
APP_PASS=$SENHAMYSQL
#
# Variável de configuração do serviço de hospedagem de site utilizado pelo PhpMyAdmin
WEBSERVER="apache2"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 08-openssl.sh                        #
#=============================================================================================
#
# Variáveis utilizadas na geração das chaves privadas/públicas dos certificados do OpenSSL
#
# Variável da senha utilizada na geração das chaves privadas/públicas da CA e dos certificados
PASSPHRASE="vaamonde"
#
# Variável do tipo de criptografia da chave privada com as opções de: -aes128, -aes192, -aes256, 
# -camellia128, -camellia192, -camellia256, -des, -des3 ou -idea, padrão utilizado: -aes256
CRIPTOKEY="aes256" 
#
# Variável do tamanho da chave privada utilizada em todas as configurações dos certificados,
# opções de: 1024, 2048, 3072 ou 4096, padrão utilizado: 2048
BITS="2048" 
#
# Variável da assinatura da chaves de criptografia privada com as opções de: md5, -sha1, sha224, 
# sha256, sha384 ou sha512, padrão utilizado: sha256
CRIPTOCERT="sha256" 
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 09-vsftpd.sh                         #
#=============================================================================================
#
# Declarando as variáveis utilizadas nas configurações do Serviço do VSFTPd Server
#
# Variável de criação do Grupo dos Usuários de acesso ao FTP
GROUPFTP="ftpusers"
#
# Variável de criação do Usuário de acesso ao FTP
USERFTP="ftpuser"
#
# Variável da senha do Usuário de FTP
PASSWORDFTP="pti@2018"
#
# Variável da senha utilizada na geração das chaves privadas/públicas de criptografia do OpenSSL 
PWDSSLFTP="pti@2018"
#