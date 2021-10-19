#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 04/11/2018
# Data de atualização: 22/07/2020
# Versão: 0.07
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x
#
#Hostname: é usado para exibir o nome DNS do sistema e para exibir ou defina seu nome de host ou 
#nome de domínio NIS. O arquivo /etc/hostname armazena as informações de nome de máquina e domínio 
#no formato FQDN (Fully Qualified Domain Name)
#
#Hosts: pesquisa de tabela estática para nomes de host, é utilizado quando não temos servidores DNS 
#(Domain Name System) e fazermos o apontamento diretamente no arquivo localizado em /etc/hosts
#
#Nsswitch.conf: Arquivo de configuração da troca de serviço de nome, utilizado para mudar as prioridades 
#de resolução de nomes no servidor, por padrão está configurado para utilizar o arquivo hosts e depois o 
#DNS.
#
#TCP Wrappers: O TCP Wrapper é um sistema de rede ACL baseado em host, usado para filtrar acesso à rede 
#a servidores de protocolo de Internet (IP) em sistemas operacionais do tipo Unix, como Linux ou BSD. 
#Ele permite que o host, endereços IP de sub-rede, nomes e/ou respostas de consulta ident, sejam usados 
#como tokens sobre os quais realizam-se filtros para propósitos de controle de acesso.
#
#Hosts.allow e Hosts.Deny: formato de arquivos de controle de acesso ao host
#

#Alterando o nome do servidor
sudo vim /etc/hostname

#Adicionando as informações de pesquisa de IP e nome no servidor
sudo vim /etc/hosts

#Verificando a forma de consulta de nomes no servidor
sudo vim /etc/nsswitch.conf

#Configurando a segurança de acesso remoto do servidor
sudo vim /etc/hosts.allow
sudo vim /etc/hosts.deny

#Reinicializando o servidor
sudo reboot

#Checando informações do servidor
sudo hostname
sudo hostname -A
sudo hostname -d

#Verificando os usuário logados no servidor
sudo w

#Verificando o arquivo de log do servidor
sudo cat /var/log/hosts.allow.log