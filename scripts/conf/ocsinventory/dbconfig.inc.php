<?php
// Autor: Robson Vaamonde
// Site: www.procedimentosemti.com.br
// Facebook: facebook.com/ProcedimentosEmTI
// Facebook: facebook.com/BoraParaPratica
// YouTube: youtube.com/BoraParaPratica
// Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
// Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
// Data de criação: 10/12/2021
// Data de atualização: 19/12/2021
// Versão: 0.01
// Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
// Testado e homologado para a versão do Apache2 v2.4.x 
// Testado e homologado para a versão do MySQL v8.0.x 
// Testado e homologado para a versão do OCS Inventory Server v2.9.x
//
// Nome da Base de Dados do OCS Inventory Server
define("DB_NAME", "ocsweb");
//
// Nome do Servidor de Leitura da Base de Dados do OCS Inventory Server
define("SERVER_READ","localhost");
//
// Nome do Servidor de Escrita da Base de Dados do OCS Inventory Server
define("SERVER_WRITE","localhost");
//
// Porta de Conexão do Banco de Dados do MySQL do OCS Inventory Server
define("SERVER_PORT","3306");
//
// Nome do Usuário de autenticação na Base de Dados do OCS Inventory Server
define("COMPTE_BASE","ocsweb");
//
// Senha do Usuário de autenticação na Base de Dados do OCS Inventory Server
define("PSWD_BASE","ocsweb");
//
// Configurações do Suporte ao SSL HTTPS do OCS Inventory Server (desativado)
define("ENABLE_SSL","0");
define("SSL_MODE","");
define("SSL_KEY","");
define("SSL_CERT","");
define("CA_CERT","");
?>