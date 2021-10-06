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
#
# Hostname: é usado para exibir o nome DNS do sistema e para exibir ou defina seu nome 
# de host ou nome de domínio NIS. O arquivo /etc/hostname armazena as informações de 
# nome de máquina e domínio no formato FQDN (Fully Qualified Domain Name)
#
# Hosts: pesquisa de tabela estática para nomes de host, é utilizado quando não temos 
# servidores DNS (Domain Name System) e fazermos o apontamento diretamente no arquivo 
# localizado em /etc/hosts
#
# Nsswitch.conf: Arquivo de configuração da troca de serviço de nome, utilizado para 
# mudar as prioridades de resolução de nomes no servidor, por padrão está configurado 
# para utilizar o arquivo hosts e depois o DNS.
#
# Alterando o nome do servidor
sudo vim /etc/hostname
#
# Adicionando as informações de pesquisa de IP e nome no servidor
sudo vim /etc/hosts
#
# Verificando a forma de consulta de nomes no servidor
sudo vim /etc/nsswitch.conf
#
# Reinicializando o servidor
sudo reboot
#
# Checando informações do servidor
sudo hostname
sudo hostname -A
sudo hostname -d
# 
# Verificando os usuário logados no servidor
sudo w