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
# Testado e homologado no Linux Mint 20.x e VSCode 1.58.x
#
Link do Visual Studio Code: https://code.visualstudio.com/
Link do Marketplace: https://marketplace.visualstudio.com/VSCode
Link do Marketplace do Remote VSCode: https://marketplace.visualstudio.com/items?itemName=rafaelmaiolla.remote-vscode
Link de Atalhos do VSCode: https://github.com/microsoft/vscode-tips-and-tricks
#
Vídeo de Instalação do Linux Mint 19.2: https://www.youtube.com/watch?v=LZoDULxZQpA
Vídeo de Instalação do Visual Studio Code: https://www.youtube.com/watch?v=ZSEwwtQuccY&t
Vídeo de Configuração do OpenSSH Server: https://www.youtube.com/watch?v=ecuol8Uf1EE
#
# Primeira Etapa: Instalação do Remote VSCode
Extensions, Remote VSCode
#
# Segunda Etapa: Configuração do Remote VSCode
Manage, Configure Extension Settings
#
# Terceira Etapa: Inicialização do Remote VSCode
Ctrl + Shift + P
Remote: Start Server
#
# Quarta Etapa: Ver o Status do Serviço e Porta do Remote VSCode
# opção do comando netstat: -a (all), -n (numeric)
Ctrl + Shift + "``" Acento Grave ou Crase
netstat -an | grep 52698
#
# Quinta Etapa: Instalação do Rmate no Ubuntu Server 18.04.x LTS
ssh vaamonde@172.16.1.20
sudo apt update
sudo apt install python-pip
sudo pip install rmate
exit
#
# Outra opção de instalação do Rmate:
# sudo wget -O /usr/local/bin/rmate https://raw.githubusercontent.com/aurora/rmate/master/rmate
# sudo chmod a+x /usr/local/bin/rmate
#
# Sexta Etapa: Criando o Túnel SSH com o Remote VSCode
# opções do comando ssh:
# -R:        Especifica que as conexões à porta TCP fornecidos no servidor devem ser encaminhadas para o lado do cliente.
# 52698:     Porta do Túnel Virtual que será criada no lado do servidor
# 127.0.0.1: Endereço de Loopback do lado servidor e cliente
# 52698:     Porta Padrão do Túnel Virtual que será criada no lado do cliente utilizado pelo Remote VSCode
# opção do comando netstat: -a (all), -n (numeric)
ssh -R 52698:127.0.0.1:52698 vaamonde@172.16.1.20
netstat -an | grep 52698
#
# Sétima Etapa: Editando arquivos remotamente com o Remote VSCode
# opção do comando rmate: -p (port)
rmate -p 52698 teste.sh
sudo rmate -p 52698 /etc/ssh/sshd_config
