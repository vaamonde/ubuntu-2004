#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 14/01/2022
# Data de atualização: 21/01/2022
# Versão: 0.03
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Asterisk v19.1.x
#
# Editando o arquivo de configuração dos módulos modules.conf
vim /etc/asterisk/modules.conf
#
# Editando o arquivo de configuração dos ramais sip.conf
vim /etc/asterisk/sip.conf
#
# Editando o arquivo de configuração dos planos de discagens extensões extensions.conf
vim /etc/asterisk/extensions.conf
#
# Reinicializando o serviço do Asterisk
sudo systemctl restart asterisk.service
#
# Verificando o status do serviço do Asterisk
sudo systemctl status asterisk.service
#
# Acessando o console de gerenciamento do Asterisk
asterisk -rvvvv
#
# Recarregando as configurações dos ramais sip
sip reload
#
# Verificando as configurações dos ramais sip
sip show peers
#
# Recarregando as configurações do plano de discagem
dialplan reload
#
# Verificando as configurações do plano de discagem
dialplan show