#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Data de criação: 12/01/2022
# Data de atualização: 12/01/2022
# Versão: 0.02
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
# Testado e homologado para a versão do Wordpress v5.8.x
#
# Script de automação da criação das chaves de Salt do arquivo wp-config.php
#
# Variável para a geração do arquivo de Salt padrão do site Oficial do Wordpress
SALT="https://api.wordpress.org/secret-key/1.1/salt/"
#
echo -e "Configuração das chaves do Salt no arquivo wp-config.php\n"
sleep 5
#
echo -e "Baixando o arquivo das chaves do Salt do site do Wordpress, aguarde..."
	# opção do comando wget: -O (output file)
	wget -O salt.key $SALT &>> salt.log
echo -e "Arquivo baixando com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando o arquivo wp-config.php com o Salt baixado, aguarde..."
	# opção do comando cp: -v (verbose)
	cp -v wp-config.php wp-config-semsalt.php.old &>> salt.log
	sed '62r salt.key' wp-config.php > /tmp/wp-config.php
	cp -v /tmp/wp-config.php . &>> salt.log
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo wp-config com o Salt configurado, pressione <Enter>."
	read -s
	vim wp-config.php
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do Apache2, aguarde..."
	systemctl restart apache2
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Acesse a URL: http://$(hostname -I | cut -d' ' -f1)/wp para finalizar a configuração"
echo -e "do Sistema de Site Dinâmicos CMS Wordpress\n"
sleep 5