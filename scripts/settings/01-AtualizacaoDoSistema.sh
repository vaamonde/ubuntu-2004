#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 04/11/2018
# Data de atualização: 14/09/2020
# Versão: 0.08
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x

#é usado para baixar informações de pacotes de todas as fontes configuradas.
sudo apt update

#é usado para listar todos os software que serão atualizados no sistema.
sudo apt list --upgradable
 
#é usado para instalar atualizações disponíveis de todos os pacotes atualmente 
#instalados no sistema a partir das fontes configuradas via sources.list
sudo apt upgrade
 
#além de executar a função de atualização, também lida de forma inteligente com 
#as novas dependências das novas versões de pacotes
sudo apt dist-upgrade
 
#executa a função de atualização, mas removerá os pacotes atualmente instalados 
#se isso for necessário para atualizar o sistema como um todo
sudo apt full-upgrade
 
#é usado para remover pacotes que foram instalados automaticamente para satisfazer 
#dependências de outros pacotes e agora não são mais necessários, pois as dependências 
#foram alteradas ou os pacotes que precisavam deles foram removidos nesse meio tempo.
sudo apt autoremove
 
#como clean, o autoclean limpa o repositório local de arquivos de pacotes recuperados. 
#A diferença é que ele remove apenas arquivos de pacotes que não podem mais ser baixados 
#e são inúteis.
sudo apt autoclean
 
#limpa o repositório local de arquivos de pacotes recuperados
sudo apt clean

#Analisando o conteúdo da arquivo OS-Release
sudo cat /etc/os-release

#Analisando o conteúdo do arquivo lsb-release
sudo cat /etc/lsb-release