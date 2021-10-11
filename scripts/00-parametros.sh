#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 10/10/2021
# Data de atualização: 10/10/2021
# Versão: 0.01
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
#                  VARIÁVEIS DO SERVIDOR UTILIZADAS EM TODOS OS SCRIPTS                      #
#=============================================================================================
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
# Variável da Configuração do Netplan do Servidor
NETPLAN="/etc/netplan/50-cloud-init.yaml"
#
#=============================================================================================
#                       VARIÁVEIS UTILIZADAS NO SCRIPT: 02-dnsdhcp.sh                        #
#=============================================================================================
#
# Declarando as variáveis de geração da chave de atualização dos registros do Bind9 DNS Server 
# integrado no ISC DHCP Server e informações da Pesquisa Direta do Domínio e Reversa
# 
# Variável da senha utilizada na criação da chave de atualização dos ponteiros do DNS e DHCP
USERUPDATE="vaamonde"
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