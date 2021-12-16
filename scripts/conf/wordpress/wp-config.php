<?php
/**
	* Autor: Robson Vaamonde
	* Site: www.procedimentosemti.com.br
	* Facebook: facebook.com/ProcedimentosEmTI
	* Facebook: facebook.com/BoraParaPratica
	* YouTube: youtube.com/BoraParaPratica
	* Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
	* Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
	* Data de criação: 18/10/2021
	* Data de atualização: 23/11/2021
	* Versão: 0.02
	* Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64x
	* Testado e homologado para a versão do Apache2 v2.4.x
	* Testado e homologado para a versão do Wordpress v5.8.x
*/
 
// ** Configurações do MySQL - Você pode pegar estas informações com o serviço de hospedagem ** //

/** O nome do Banco de Dados do WordPress.*/
define('DB_NAME', 'wordpress');

/** Nome do usuário da Base de Dados do MySQL do WordPress.*/
define('DB_USER', 'wordpress');

/** Senha do usuário da Base de Dados do MySQL do WordPress.*/
define('DB_PASSWORD', 'wordpress');

/** Nome ou Endereço IP do Servidor do MySQL que é o Localhost.*/
define('DB_HOST', 'localhost');

/** Charset do banco de dados a ser usado na criação das tabelas.*/
define('DB_CHARSET', 'utf8');

/** Configuração do Collate da Base de Dados do Wordpress, deixar o padrão.*/
define('DB_COLLATE', '');

/** Prefixo padrão das tabelas da Base de Dados do Wordpress.*/
$table_prefix  = 'wp_';

/** Configuração para usar dois domínios ou dois IP's no mesmo site do Wordpress */
/** Utilizado principalmente quando o seu site do Wordpress está na rede local e */
/** você faz NAT (Port Forwarding) utilizando servidores de Firewall, exemplo pfSense */
/** Site-01: https://www.filipemarques.net/diversos-dominios-mesmo-wordpress/ */
/** Site-02: https://suporte.hostgator.com.br/hc/pt-br/articles/115003844573-Como-utilizar-dois-dom%C3%ADnios-em-um-mesmo-WordPress- */

/** Procedimento de utilização de dois ou mais domínios no Wordpress: instale o Wordpress */
/** normalmente no seu Domínio primário, após a instalação remova os comentários das linhas */
/** abaixo, reinicie o Apache2 e teste o acesso ao seu Wordpress */
/** define('WP_SITEURL', 'http://' . $_SERVER['HTTP_HOST']); */
/** define('WP_HOME', 'http://' . $_SERVER['HTTP_HOST']); */

/** Configuração do Debug do Wordpress, deixar desativado (padrão false)*/
define('WP_DEBUG', false);

/** Bloco de configuração Global do Wordpress, deixar o padrão*/

/** Chaves únicas de autenticação e salts.*/
define( 'AUTH_KEY',         'coloque a sua frase única aqui' );
define( 'SECURE_AUTH_KEY',  'coloque a sua frase única aqui' );
define( 'LOGGED_IN_KEY',    'coloque a sua frase única aqui' );
define( 'NONCE_KEY',        'coloque a sua frase única aqui' );
define( 'AUTH_SALT',        'coloque a sua frase única aqui' );
define( 'SECURE_AUTH_SALT', 'coloque a sua frase única aqui' );
define( 'LOGGED_IN_SALT',   'coloque a sua frase única aqui' );
define( 'NONCE_SALT',       'coloque a sua frase única aqui' );

/** Caminho absoluto para o diretório WordPress. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Configura as variáveis e arquivos do WordPress. */
require_once ABSPATH . 'wp-settings.php';
