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
# Update é utilizado para baixar as informações de pacotes de todas as fontes configuradas 
# via sources.list.
sudo apt update
#
# List: é utilizado para listar todos os software que serão atualizados no sistema em 
# comparação com as fontes configuradas via sources.list.
sudo apt list --upgradable
#
# Upgrade: é utilizado para instalar todas as atualizações disponíveis de todos os pacotes 
# atualmente instalados no sistema a partir das fontes configuradas via sources.list
sudo apt upgrade
#
# Dist-Upgrade: além de executar a função de atualização, também lida de forma inteligente 
# com as novas dependências das novas versões de pacotes disponiveis no sources.list
sudo apt dist-upgrade
#
# Full-Upgrade: executa a função de atualização, mas removerá todos os pacotes atualmente 
# instalados se isso for necessário para atualizar o sistema como um todo
sudo apt full-upgrade
#
# Autoremove: é utilizado para remover pacotes que foram instalados automaticamente para 
# satisfazer dependências de outros pacotes e agora não são mais necessários, pois as 
# dependências foram alteradas ou os pacotes que precisavam deles foram removidos.
sudo apt autoremove
#
# Autoclean: igual ao clean, o autoclean limpa o repositório local de arquivos de pacotes
# recuperados, a diferença é que ele remove apenas arquivos de pacotes que não podem mais
# ser baixados e são inúteis.
sudo apt autoclean
#
# Clean: limpa o repositório local de arquivos de pacotes recuperados/baixados que são
# considerados desnecessários para o sistema
sudo apt clean
#
# Conteúdo da arquivo OS-Release: Identificação do Sistema Operacional
sudo cat /etc/os-release
#
# Conteúdo do arquivo lsb-release: Informações específicas da Distribuição
sudo cat /etc/lsb-release
#
# Verificando a versão do Kernel instalado
sudo uname -a