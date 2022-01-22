#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 10/10/2021
# Data de atualização: 20/01/2022
# Versão: 0.20
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64

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