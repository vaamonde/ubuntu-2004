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

#Atualização das Listas do Apt-Get - Apt
sudo apt update

#Atualização dos Software instalados
sudo apt upgrade

#Atualização das Versões de Kernel
sudo apt dist-upgrade

#Nova opção de atualização, a mesma utilizada no Debian
sudo apt full-upgrade

#Verificando o Espaço em Disco
sudo df -h

#verificando o arquivo Swapfile
sudo ls -lh swapfile

#Analisando o conteúdo da arquivo OS-Release
sudo cat /etc/os-release

#Analisando o conteúdo do arquivo lsb-release
sudo cat /etc/lsb-release