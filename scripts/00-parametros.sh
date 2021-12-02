#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Data de criação: 10/10/2021
# Data de atualização: 02/12/2021
# Versão: 0.18
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
# Declarando as variáveis utilizadas na verificação e validação da versão do Ubuntu Server 
#
# Variável da Hora Inicial do Script, utilizada para calcular o tempo de execução do script
# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
#
# Variáveis para validar o ambiente, verificando se o usuário é "Root" e versão do "Ubuntu"
# opções do comando id: -u (user)
# opções do comando: lsb_release: -r (release), -s (short), 
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
#
# Variável do Caminho e Nome do arquivo de Log utilizado em todos os script
# $0 (variável de ambiente do nome do comando/script executado)
# opção do redirecionador | piper: Conecta a saída padrão com a entrada padrão de outro comando
# opções do comando cut: -d (delimiter), -f (fields)
LOGSCRIPT="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Exportando o recurso de Noninteractive do Debconf para não solicitar telas de configuração e
# nenhuma interação durante a instalação ou atualização do sistema via Apt ou Apt-Get. Ele 
# aceita a resposta padrão para todas as perguntas.
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
# Variável do Nome (Hostname) FQDN (Fully Qualified Domain Name) do Servidor Ubuntu
FQDNSERVER="ptispo01ws01.pti.intra"
#
# Variável do Nome de Domínio do Servidor Ubuntu
DOMINIOSERVER="pti.intra"
#
# Variável do Endereço IPv4 do Servidor Ubuntu
IPV4SERVER="172.16.1.20"
#
# Variável do arquivo de configuração da Placa de Rede do Netplan do Servidor Ubuntu
# CUIDADO!!! o nome do arquivo de configuração da placa de rede pode mudar dependendo da 
# versão do Ubuntu Server, verificar o conteúdo do diretório: /etc/netplan para saber o nome 
# do arquivo de configuração do Netplan e mudar a variável NETPLAN com o nome correspondente.
NETPLAN="/etc/netplan/00-installer-config.yaml"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 01-openssh.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede OpenSSH utilizados nesse script
# 01. /etc/ssh/sshd_config = arquivo de configuração do Servidor OpenSSH
# 02. /etc/hostname = arquivo de configuração do Nome do Servidor
# 03. /etc/hosts = arquivo de configuração da pesquisa estática para nomes de host 
# 04. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço
# 05. /etc/hosts.deny = arquivo de configuração de negação de hosts por serviço
# 06. /etc/issue.net = arquivo de configuração do Banner utilizado pelo OpenSSH
# 07. /etc/nsswitch.conf = arquivo de configuração do switch de serviço de nomes
# 08. /etc/netplan/00-installer-config.yaml = arquivo de configuração da placa de rede
#
# Arquivos de monitoramento (log) do Serviço de Rede OpenSSH Server utilizados nesse script
# 01. systemctl status ssh = status do serviço do OpenSSH
# 02. journalctl -t sshd = todas as mensagens referente ao serviço do OpenSSH
# 03. tail -f /var/log/syslog | grep sshd = filtrando as mensagens do serviço do OpenSSH
# 04. tail -f /var/log/auth.log | grep ssh = filtrando as mensagens de autenticação do OpenSSH
# 05. tail -f /var/log/tcpwrappers-allow-ssh.log = filtrando as conexões permitias do OpenSSH
# 06. tail -f /var/log/tcpwrappers-deny.log = filtrando as conexões negadas do OpenSSH
#
# Variável das dependências do laço de loop do OpenSSH Server
SSHDEP="openssh-server openssh-client"
#
# Variável de instalação dos softwares extras do OpenSSH Server
SSHINSTALL="net-tools ipcalc nmap"
#
#=============================================================================================
#                          VARIÁVEIS UTILIZADAS NO SCRIPT: 02-dhcp.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede ISC DHCP Sever utilizados nesse script
# 01. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
# 02. /etc/netplan/00-installer-config.yaml = arquivo de configuração da placa de rede
#
# Arquivos de monitoramento (log) do Serviço de Rede ISC DHCP Server utilizados nesse script
# 01. systemctl status isc-dhcp-server = status do serviço do ISC DHCP
# 02. journalctl -t dhcpd = todas as mensagens referente ao serviço do ISC DHCP
# 03. tail -f /var/log/syslog | grep dhcpd = filtrando as mensagens do serviço do ISC DHCP
# 04. tail -f /var/log/dmesg | grep dhcpd = filtrando as mensagens de erros do ISC DHCP
# 05. less /var/lib/dhcp/dhcpd.leases = filtrando os alugueis de endereços IPv4 do ISC DHCP
#
# Variável de instalação do serviço de rede ISC DHCP Server
DHCPINSTALL="isc-dhcp-server net-tools"
#
#=============================================================================================
#                          VARIÁVEIS UTILIZADAS NO SCRIPT: 03-dns.sh                         #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede BIND DNS Server utilizados nesse script
# 01. /etc/hostname = arquivo de configuração do Nome do Servidor
# 02. /etc/hosts = arquivo de configuração da pesquisa estática para nomes de host 
# 03. /etc/nsswitch.conf = arquivo de configuração do switch de serviço de nomes
# 04. /etc/netplan/00-installer-config.yaml = arquivo de configuração da placa de rede
# 05. /etc/bind/named.conf = arquivo de configuração da localização dos Confs do Bind9
# 06. /etc/bind/named.conf.local = arquivo de configuração das Zonas do Bind9
# 07. /etc/bind/named.conf.options = arquivo de configuração do Serviço do Bind9
# 08. /etc/bind/rndc.key = arquivo de configuração das Chaves RNDC de integração Bind9 e DHCP
# 09. /var/lib/bind/pti.intra.hosts = arquivo de configuração da Zona de Pesquisa Direta
# 10. /var/lib/bind/172.16.1.rev = arquivo de configuração da Zona de Pesquisa Inversa
# 11. /etc/cron.d/dnsupdate-cron = arquivo de configuração das atualizações de Ponteiros
# 12. /etc/default/named = arquivo de configuração do Daemon do Serviço do Bind9
#
# Arquivos de monitoramento (log) do Serviço de Rede Bind DNS Server utilizados nesse script
# 01. systemctl status bind9 = status do serviço do Bind DNS
# 02. journalctl -t named = todas as mensagens referente ao serviço do Bind DNS
# 03. tail -f /var/log/named/* = vários arquivos de Log do serviço do Bind DNS
#
# Declarando as variáveis de Pesquisa Direta do Domínio, Inversa e Subrede do Bind DNS Server
#
# Variável do nome do Domínio do Servidor DNS (veja a linha: 58 desse arquivo)
DOMAIN=$DOMINIOSERVER
#
# Variável do nome da Pesquisa Inversa do Servidor de DNS
DOMAINREV="1.16.172.in-addr.arpa"
#
# Variável do endereço IPv4 da Subrede do Servidor de DNS
NETWORK="172.16.1."
#
# Variável de instalação do serviço de rede Bind DNS Server
DNSINSTALL="bind9 bind9utils bind9-doc dnsutils net-tools"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 04-dhcpdns.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) da integração do Bind9 e do DHCP utilizados nesse script
# 01. tsig.key - arquivo de geração da chave TSIG de integração do Bind9 e do DHCP
# 02. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
# 03. /etc/bind/named.conf.local = arquivo de configuração das Zonas do Bind9
# 04. /etc/bind/rndc.key = arquivo de configuração das Chaves RNDC de integração Bind9 e DHCP
#
# Declarando a variável de geração da chave de atualização dos registros do Bind DNS Server 
# integrado no ISC DHCP Server
# 
# Variável da senha utilizada na criação da chave de atualização dos ponteiros do DNS e DHCP
USERUPDATE="vaamonde"
#
# Variável das dependências do laço de loop da integração do Bind DNS e do ISC DHCP Server
DHCPDNSDEP="isc-dhcp-server bind9"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 05-ntp.sh                            #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede NTP Server utilizados nesse script
# 01. /etc/ntp.conf = arquivo de configuração do serviço de rede NTP Server
# 02. /etc/default/ntp = arquivo de configuração do Daemon do NTP Server
# 03. /var/lib/ntp/ntp.drift = arquivo de configuração do escorregamento de memória do NTP
# 04. /etc/systemd/timesyncd.conf = arquivo de configuração do sincronismo de Data e Hora
# 05. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
#
# Declarando as variáveis utilizadas nas configurações do Serviço do NTP Server e Client
#
# Variável de sincronização do NTP Server com o Site ntp.br
NTPSERVER="a.st1.ntp.br"
#
# Variável do Zona de Horário do NTP Server
TIMEZONE="America/Sao_Paulo"
#
# Variável das dependências do laço de loop do NTP Server
NTPDEP="isc-dhcp-server"
#
# Variável de instalação do serviço de rede NTP Server e Client
NTPINSTALL="ntp ntpdate"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 06-tftphpa.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede TFTPHPA utilizados nesse script
# 01. /etc/default/tftpd-hpa = arquivo de configuração do Servidor TFTP-HPA
# 02. /etc/dhcp/dhcpd.conf = arquivo de configuração do Servidor ISC DHCP Server
# 03. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço
#
# Declarando as variáveis utilizadas nas configurações do Serviço do TFTP-HPA Server
#
# Variável de criação do diretório padrão utilizado pelo serviço do TFTP-HPA
PATHTFTP="/var/lib/tftpboot"
#
# Variável das dependências do laço de loop do TFTP-HPA Server
TFTPDEP="bind9 bind9utils isc-dhcp-server"
#
# Variável de instalação do serviço de rede TFTP-HPA Server
TFTPINSTALL="tftpd-hpa tftp-hpa"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 07-lamp.sh                          #
#=============================================================================================
# 
# Arquivos de configuração (conf) do Serviço de Rede LAMP Server utilizados nesse script
# 01. /etc/apache2/apache2.conf = arquivo de configuração do Servidor Apache2
# 02. /etc/apache2/ports.conf = arquivo de configuração das portas do Servidor Apache2
# 03. /etc/apache2/sites-available/000-default.conf = arquivo de configuração do site padrão HTTP
# 04. /etc/php/7.4/apache2/php.ini = arquivo de configuração do PHP
# 05. /etc/mysql/mysql.conf.d/mysqld.cnf = arquivo de configuração do Servidor MySQL
# 06. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço
# 07. /var/www/html/phpinfo.php = arquivo de geração da documentação do PHP
# 08. /var/www/html/teste.html = arquivo de teste de páginas HTML
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
# Variável de instalação do serviço de rede LAMP Server (^ (circunflexo): expressão regular)
LAMPINSTALL="lamp-server^ perl python apt-transport-https"
#
# Variável de instalação do serviço de rede PhpMyAdmin
PHPMYADMININSTALL="phpmyadmin php-bcmath php-mbstring php-pear php-dev php-json libmcrypt-dev pwgen"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 08-openssl.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Certificados OpenSSL utilizados nesse script
# 01. /etc/ssl/index.txt = arquivo de configuração da base de dados do OpenSSL
# 02. /etc/ssl/index.txt.attr = arquivo de configuração dos atributos da base de dados do OpenSSL
# 03. /etc/ssl/serial = arquivo de configuração da geração serial dos certificados
# 04. /etc/ssl/pti-ca.conf = arquivo de configuração de Unidade Certificadora CA
# 05. /etc/ssl/pti-ssl.conf = arquivo de configuração do certificado do Apache2
# 06. /etc/apache2/sites-available/default-ssl.conf = arquivo de configuração do site HTTPS do Apache2
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
# Variável da assinatura da chave de criptografia privada com as opções de: md5, -sha1, sha224, 
# sha256, sha384 ou sha512, padrão utilizado: sha256
CRIPTOCERT="sha256" 
#
# Variável das dependências do laço de loop do OpenSSL
SSLDEP="openssl apache2 bind9"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 09-vsftpd.sh                         #
#=============================================================================================
#
# Arquivos de configuração (conf) do Serviço de Rede VSFTPd utilizados nesse script
# 01. /etc/vsftpd.conf = arquivo de configuração do servidor VSFTPd
# 02. /etc/vsftpd.allowed_users = arquivo de configuração da base de dados de usuários do VSFTPd
# 03. /etc/shells = arquivo de configuração do shells válidos
# 04. /etc/ssl/vsftpd-ssl.conf = arquivo de configuração da geração do certificado TLS/SSL
# 05. /bin/ftponly = arquivo de configuração da mensagem (banner) do VSFTPd
# 06. /etc/hosts.allow = arquivo de configuração de liberação de hosts por serviço
#
# Declarando as variáveis utilizadas nas configurações do Serviço do VSFTPd Server
#
# Variável de criação do Grupo dos Usuários de acesso ao VSFTPd Server
GROUPFTP="ftpusers"
#
# Variável de criação do Usuário de acesso ao VSFTPd Server
USERFTP="ftpuser"
#
# Variável da senha do Usuário de VSFTPd Server
PASSWORDFTP="ftpuser"
#
# Variável da senha utilizada na geração das chaves privadas/públicas de criptografia do OpenSSL 
PWDSSLFTP="vaamonde"
#
# Variável das dependências do laço de loop do VSFTPd Server
FTPDEP="bind9 bind9utils apache2 openssl"
#
# Variável de instalação do serviço de rede VSFTPd Server
FTPINSTALL="vsftpd"
#
#=============================================================================================
#                        VARIÁVEIS UTILIZADAS NO SCRIPT: 10-tomcat.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do Servidor Apache Tomcat utilizados nesse script
# 01. /etc/tomcat9/tomcat-users.xml = arquivo de configuração dos usuários do Tomcat
# 02. /etc/tomcat9/server.xml = arquivo de configuração do servidor Tomcat
#
# Variável de instalação das dependências do Java do Apache Tomcat Server
TOMCATDEP="openjdk-11-jdk openjdk-11-jre default-jdk"
#
# Variável de instalação do serviço de rede Apache Tomcat Server
TOMCATINSTALL="tomcat9 tomcat9-admin tomcat9-common tomcat9-docs tomcat9-examples tomcat9-user"
#
#=============================================================================================
#                      VARIÁVEIS UTILIZADAS NO SCRIPT: 11-wordpress.sh                       #
#=============================================================================================
#
# Arquivos de configuração (conf) do Site CMS Wordpress utilizados nesse script
# 01. /var/www/html/wp/wp-config.php = arquivo de configuração do site Wordpress
# 02. /var/www/html/wp/.htaccess = arquivo de segurança de páginas e diretórios do Wordpress
# 03. /etc/vsftpd.allowed_users = arquivo de configuração da base de dados de usuários do VSFTPd
# 04. /etc/apache2/sites-available/wordpress.conf = arquivo de configuração do Virtual Host
#
# Declarando as variáveis utilizadas nas configurações do Site do Wordpress
#
# Declarando a variável do download do Wordpress (Link atualizado em: 18/10/2021)
WORDPRESS="https://br.wordpress.org/latest-pt_BR.zip"
#
# Declarando as variáveis para criação da Base de Dados do Wordpress
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 11-WORDPRESS.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 232 até 238, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHA: 217
CREATE_DATABASE_WORDPRESS="CREATE DATABASE wordpress;"
CREATE_USER_DATABASE_WORDPRESS="CREATE USER 'wordpress' IDENTIFIED BY 'wordpress';"
GRANT_DATABASE_WORDPRESS="GRANT USAGE ON *.* TO 'wordpress';"
GRANT_ALL_DATABASE_WORDPRES="GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress';"
FLUSH_WORDPRESS="FLUSH PRIVILEGES;"
#
# Variáveis de usuário e senha do FTP para acessar o diretório raiz da instalação do Wordpress
USERFTPWORDPRESS="wordpress"
PASSWORDFTPWORDPRESS="wordpress"
PATHWORDPRESS="/var/www/html/wp"
#
# Variável das dependências do laço de loop do Wordpress
WORDPRESSDEP="mysql-server mysql-common apache2 php vsftpd bind9"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 12-webmin.sh                         #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Webmin e Userrmin utilizados nesse script
# 01. /etc/apt/sources.list.d/webmin.list = arquivo de configuração do source list do Apt
#
# Declarando as variáveis utilizadas nas configurações do Webmin e do Usermin
# 
# Variável de download da Chave PGP do Webmin (Link atualizado no dia 30/11/2021)
WEBMINPGP="http://www.webmin.com/jcameron-key.asc"
#
# Variável da instalação das dependências do Webmin e do Usermin (\ quebra de linha no apt)
WEBMINDEP="perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl \
apt-show-versions python unzip apt-transport-https software-properties-common"
#
# Variável de instalação do serviço de rede Webmin e Usermin
WEBMINNSTALL="webmin usermin"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 13-netdata.sh                        #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema Netdata utilizados nesse script
# 01. /usr/lib/netdata/conf.d/python.d/mysql.conf = arquivo de monitoramento do MySQL
# 02. /usr/lib/netdata/conf.d/python.d/isc_dhcpd.conf = arquivo de monitoramento do ISC DHCP
# 03. /usr/lib/netdata/conf.d/python.d/bind_rndc.conf = arquivo de monitoramento do Bind DNS
#
# Declarando as variáveis utilizadas nas configurações do sistema de monitoramento Netdata
#
# Declarando a variável de download do Netdata (Link atualizado no dia 18/10/2021)
# opção do comando git clone --depth=1: Cria um clone superficial com um histórico truncado 
# para o número especificado de confirmações (somente o último commit geral do repositório)
NETDATA="https://github.com/firehol/netdata.git --depth=1"
#
# Variável das dependências do laço de loop do Netdata
NETDATADEP="mysql-server mysql-common apache2 php vsftpd bind9 isc-dhcp-server"
#
# Variável de instalação das dependências do Netdata (\ quebra de linha no apt)
NETDATAINSTALL="zlib1g-dev gcc make git autoconf autogen automake pkg-config uuid-dev python3 \
python3-mysqldb python3-pip python3-dev libmysqlclient-dev python-ipaddress libuv1-dev netcat \
libwebsockets15 libwebsockets-dev libjson-c-dev libbpfcc-dev liblz4-dev libjudy-dev libelf-dev \
libmnl-dev autoconf-archive curl cmake protobuf-compiler protobuf-c-compiler lm-sensors \
python3-psycopg2 python3-pymysql"
#
#=============================================================================================
#                     VARIÁVEIS UTILIZADAS NO SCRIPT: 14-loganalyzer.sh                      #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema LogAnalyzer utilizados nesse script
# 01. /etc/rsyslog.conf = arquivo de configuração do serviço de rede Rsyslog
# 02. /etc/rsyslog.d/mysql.conf = arquivo de configuração da base de dados do Rsyslog
#
# Declarando as variáveis utilizadas nas configurações do sistema de monitoramento LogAnalyzer
#
# Variável de download do LogAnalyzer (atualizada no dia: 02/11/2021)
LOGANALYZER="http://download.adiscon.com/loganalyzer/loganalyzer-4.1.12.tar.gz"
#
# Variável de download do Plugin de Tradução PT-BR do LogAnalyzer (atualizada no dia: 02/11/2021)
LOGPTBR="https://loganalyzer.adiscon.com/plugins/files/translations/loganalyzer_lang_pt_BR_3.2.3.zip"
#
# Declarando as variáveis para criação da Base de Dados do Rsyslog
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 14-LOGANALYZER.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 232 até 236, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHA: 217
CREATE_DATABASE_SYSLOG="CREATE DATABASE syslog;"
CREATE_USER_DATABASE_SYSLOG="CREATE USER 'syslog' IDENTIFIED BY 'syslog';"
GRANT_DATABASE_SYSLOG="GRANT USAGE ON *.* TO 'syslog';"
GRANT_ALL_DATABASE_SYSLOG="GRANT ALL PRIVILEGES ON syslog.* TO 'syslog';"
FLUSH_SYSLOG="FLUSH PRIVILEGES;"
DATABASE_NAME_SYSLOG="syslog"
INSTALL_DATABASE_SYSLOG="/usr/share/dbconfig-common/data/rsyslog-mysql/install/mysql"
#
# Declarando as variáveis para criação da Base de Dados do LogAnalyzer
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 14-LOGANALYZER.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA
# DO ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 119 até 124, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHA: 114
CREATE_DATABASE_LOGANALYZER="CREATE DATABASE loganalyzer;"
CREATE_USER_DATABASE_LOGANALYZER="CREATE USER 'loganalyzer' IDENTIFIED BY 'loganalyzer';"
GRANT_DATABASE_LOGANALYZER="GRANT USAGE ON *.* TO 'loganalyzer';"
GRANT_ALL_DATABASE_LOGANALYZER="GRANT ALL PRIVILEGES ON loganalyzer.* TO 'loganalyzer';"
FLUSH_LOGANALYZER="FLUSH PRIVILEGES;"
#
# Variável das dependências do laço de loop do LogAnalyzer
LOGDEP="mysql-server mysql-common apache2 php bind9"
#
# Variável de instalação das dependências do LogAnalyzer
LOGINSTALL="rsyslog-mysql"
#
#=============================================================================================
#                         VARIÁVEIS UTILIZADAS NO SCRIPT: 15-glpi.sh                         #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema GLPI Help Desk utilizados nesse script
# 01. /etc/apache2/conf-available/glpi.conf = arquivo de configuração do Virtual Host do GLPI
# 02. /etc/cron.d/glpi-cron = arquivo de configuração do agendamento do CRON do GLPI
#
# Declarando as variáveis utilizadas nas configurações do sistema de help desk GLPI
#
# Variável de download do GLPI (atualizada no dia: 25/11/2021)
GLPI="https://github.com/glpi-project/glpi/releases/download/9.5.6/glpi-9.5.6.tgz"
#
# Declarando as variáveis para criação da Base de Dados do GLPI
# opções do comando CREATE: create (criação), database (base de dados), base (banco de dados)
# opções do comando CREATE: create (criação), user (usuário), identified by (identificado por
# senha do usuário), password (senha)
# opções do comando GRANT: grant (permissão), usage (uso em | uso na), *.* (todos os bancos/
# tabelas), to (para), user (usuário), identified by (identificado por - senha do usuário), 
# password (senha)
# opões do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na | banco ou 
# tabela), *.* (todos os bancos/tabelas), to (para), user@'%' (usuário @ localhost), identified 
# by (identificado por - senha do usuário), password (senha)
# opções do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
#
# OBSERVAÇÃO: NO SCRIPT: 15-GLPI.SH É UTILIZADO AS VARIÁVEIS DO MYSQL DE USUÁRIO E SENHA DO
# ROOT DO MYSQL CONFIGURADAS NO BLOCO DAS LINHAS: 232 até 236, VARIÁVEIS UTILIZADAS NO SCRIPT: 
# 07-lamp.sh LINHA: 217
CREATE_DATABASE_GLPI="CREATE DATABASE glpi;"
CREATE_USER_DATABASE_GLPI="CREATE USER 'glpi' IDENTIFIED BY 'glpi';"
GRANT_DATABASE_GLPI="GRANT USAGE ON *.* TO 'glpi';"
GRANT_ALL_DATABASE_GLPI="GRANT ALL PRIVILEGES ON glpi.* TO 'glpi';"
FLUSH_GLPI="FLUSH PRIVILEGES;"
#
# Variável das dependências do laço de loop do GLPI Help Desk
GLPIDEP="mysql-server mysql-common apache2 php bind9"
#
# Variável de instalação das dependências do GLPI Help Desk (\ quebra de linha no apt)
GLPIINSTALL="php-curl php-gd php-intl php-pear php-imagick php-imap php-memcache php-pspell \
php-mysql php-tidy php-xmlrpc php-mbstring php-ldap php-cas php-apcu php-json php-xml php-cli \
libapache2-mod-php xmlrpc-api-utils"
#
#=============================================================================================
#                    VARIÁVEIS UTILIZADAS NO SCRIPT: 16-fusioninventory.sh                   #
#=============================================================================================
#
# Arquivos de configuração (conf) do sistema GLPI Help Desk utilizados nesse script
# 01. /var/log/fusioninventory-agent/fusioninventory.log = arquivo de log do agent do FusionInventory
# 02. /etc/fusioninventory/agent.cfg = arquivo de configuração do agent do FusionInventory
#
# Declarando as variáveis utilizadas nas configurações do sistema de inventário FusionInventory
#
# Variável de localização da instalação do diretório do GLPI Help Desk
PATHGLPI="/var/www/html/glpi"
#
# Variável de download do FusionInventory (atualizada no dia: 30/11/2021)
# OBSERVAÇÃO: O FusionInventory depende do GLPI para funcionar corretamente, é recomendado sempre 
# manter o GLPI é o FusionInventory atualizados para as últimas versões compativeis no site.
FUSIONSERVER="https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi9.5%2B3.0/fusioninventory-9.5+3.0.tar.bz2"
FUSIONAGENT="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_2.6-1_all.deb"
FUSIONCOLLECT="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent-task-collect_2.6-1_all.deb"
FUSIONNETWORK="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent-task-network_2.6-1_all.deb"
FUSIONDEPLOY="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent-task-deploy_2.6-1_all.deb"
AGENTWINDOWS32="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_windows-x86_2.6.exe"
AGENTWINDOWS64="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/fusioninventory-agent_windows-x64_2.6.exe"
AGENTMACOS="https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.6/FusionInventory-Agent-2.6-2.dmg"
#
# Variável das dependências do laço de loop do GLPI Help Desk
FUSIONDEP="mysql-server mysql-common apache2 php bind9"
#
# Variável de instalação das dependências do FusionInventory Agent (\ quebra de linha no apt)
AGENTINSTALL="dmidecode hwdata ucf hdparm perl libuniversal-require-perl libwww-perl libparse-edid-perl \
libproc-daemon-perl libfile-which-perl libhttp-daemon-perl libxml-treepp-perl libyaml-perl libnet-cups-perl \
libnet-ip-perl libdigest-sha-perl libsocket-getaddrinfo-perl libtext-template-perl libxml-xpath-perl \
libyaml-tiny-perl libio-socket-ssl-perl libnet-ssleay-perl libcrypt-ssleay-perl"
#
# Variável de instalação das dependências do FusionInventory Task Network
NETWORKINSTALL="libnet-snmp-perl libcrypt-des-perl libnet-nbname-perl"
#
# Variável de instalação das dependências do FusionInventory Task Deploy 
DEPLOYINSTALL="libfile-copy-recursive-perl libparallel-forkmanager-perl"
#
# Variável de instalação das dependências do FusionInventory Task WakeOnLan
WAKEINSTALL="libwrite-net-perl"
#
# Variável de instalação das dependências do FusionInventory SNMPv3
SNMPNSTALL="libdigest-hmac-perl"
#



