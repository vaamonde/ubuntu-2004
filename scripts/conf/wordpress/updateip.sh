#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Data de criação: 12/01/2022
# Data de atualização: 18/04/2022
# Versão: 0.03
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Wordpress v5.8.x
#
# Script de atualização da alteração do Endereço IPv4 do Banco de Dados do Wordpress
#
# Variáveis para a conexão do Banco de Dados do Wordpress
USERNAME="wordpress"
PASSWORD="wordpress"
DATABASE_WORDPRESS="wordpress"
#
# Variável de alteração do endereço IPv4 ou FQDN de acesso a URL do Wordpress
IPV4ADDRESS="10.26.0.0"
#
# Variáveis de atualização do endereço IPv4 ou FQDN de acesso a URL do Wordpress
SELECT_WORDPRESS="SELECT * FROM wp_options WHERE option_name IN('siteurl','home');"
UPDATE_SITEURL_WORDPRESS="UPDATE wp_options SET option_value='http://$IPV4ADDRESS' WHERE option_name = 'siteurl';"
UPDATE_HOME_WORDPRESS="UPDATE wp_options SET option_value='http://$IPV4ADDRESS' WHERE option_name = 'home';"
#
echo -e "Alterando o Endereço IPv4 ou FQDN do Banco de Dados do Wordpress\n"
sleep 5
#
echo -e "Listando o Endereço IPv4 atual do computador, aguarde..."
	echo -e "Endereço IPv4: $(hostname -I)"
echo -e "Endereço IPv4 listado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Visualizando o Endereço IPv4 configurado no Banco de Dados do Wordpress, aguarde..."
	mysql -u $USERNAME -p$PASSWORD -e "$SELECT_WORDPRESS" $DATABASE_WORDPRESS
echo -e "Endereço visualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o Endereço IPv4 para: $IPV4ADDRESS, aguarde..."
	mysql -u $USERNAME -p$PASSWORD -e "$UPDATE_SITEURL_WORDPRESS" $DATABASE_WORDPRESS
	mysql -u $USERNAME -p$PASSWORD -e "$UPDATE_HOME_WORDPRESS" $DATABASE_WORDPRESS
echo -e "Endereço IPv4 atualizado sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Visualizando o Endereço IPv4 configurado no Banco de Dados do Wordpress, aguarde..."
	mysql -u $USERNAME -p$PASSWORD -e "$SELECT_WORDPRESS" $DATABASE_WORDPRESS
echo -e "Endereço visualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do Apache2, aguarde..."
	systemctl restart apache2
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Acesse a URL: http://$IPV4ADDRESS/wp para finalizar e testar o acesso"
echo -e "da nova configuração do Sistema de Site Dinâmicos CMS Wordpress\n"
sleep 5