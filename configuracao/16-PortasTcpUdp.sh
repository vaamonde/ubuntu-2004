#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 10/02/2019
# Data de atualização: 15/09/2021
# Versão: 0.12
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x

001: openssh.sh --------> TCP 22 (SSH)
002: lamp.sh -----------> TPC 80 (HTTP), TCP 3306 (MySQL)
003: wordpress.sh ------> TPC 80 (HTTP), TCP 3306 (MySQL)
004: webmin.sh ---------> TCP 10000 (HTTPS)
005: netdata.sh --------> TCP 19999 (HTTP)
006: loganalyzer.sh ----> TPC 80 (HTTP), TCP 3306 (MySQL), UDP 514 (Syslog)
007: docker.sh ---------> TCP 9000 (HTTP)
008: openfire.sh -------> TCP 9090 (HTTP)
009: zoneminder.sh -----> TPC 80 (HTTP), TCP 3306 (MySQL)
010: asterisk.sh -------> UDP 5060 (SIP)
011: bareos.sh ---------> TPC 80 (HTTP), TCP 3306 (MySQL), TCP 9102:9103 (BACULA)
012: owncloud.sh -------> TPC 80 (HTTP), TCP 3306 (MySQL)
013: ansible.sh --------> TCP 4440 (HTTP)
014: glpi.sh -----------> TPC 80 (HTTP), TCP 3306 (MySQL)
015: grafana.sh --------> TCP 3000 (HTTP)
016: tomcat.sh ---------> TCP 8080 (HTTP)
017: graylog.sh --------> TCP 19000 (HTTP), TCP 9200 (HTTP), TCP 27017 (MONGODB)
018: zabbix.sh ---------> TCP 80 (HTTP), TCP 10050:10051 (ZABBIX-AGENT)
019: ntopng.sh ---------> TCP 3001 (HTTP)
020: fusion.sh ---------> TPC 80 (HTTP), TCP 3306 (MySQL)
021: postgresql.sh -----> TCP 5432 (POSTGRE)
022: guacamole.sh ------> TCP 8080 (HTTP), 4822 (GUACD)
023: unifi.sh ----------> TCP 8080 (HTTP), TCP 8443 (HTTPS), TCP 27017 (MONGODB)
024: openproject.sh ----> TCP 80 (HTTP), TCP 45432 (POSTGRE)
025: lemp.sh -----------> TCP 80 (HTTP), TCP 3306 (MARIADB)
026: wekan.sh ----------> TCP 3000 (HTTP), TCP 27019 (MONGODB)
027: rocketcjat.sh -----> TCP 3000 (HTTP), TCP 27017 (MONGODB)
028: ocsinventory.sh ---> TPC 80 (HTTP), TCP 3306 (MySQL)
029: bacula.sh ---------> TPC 80 (HTTP), TCP 3306 (MySQL), TCP 9101:9103 (BACULA), TCP 9095:9096 (BACULUM)
030: dnsdhcp.sh --------> UDP 53 (BIND9), UDP 67 (DHCP)
031: zimbra.sh ---------> TCP 80 (HTTP), TCP 25 (SMTP), TCP 110 (POP3), TCP 143 (IMAP4), TCP 443 (HTTPS), TCP 587 (SMTP), TCP 7071 (ADMIN ZIMBRA)
032: tftppxe.sh --------> UDP 69 (TFTP)
033: vsftpd.sh ---------> TCP 20:21 (FTP), TCP 990 (SFTP)
034: ntp.sh ------------> UDP 123 (NTP)