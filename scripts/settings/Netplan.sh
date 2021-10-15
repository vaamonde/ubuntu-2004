#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 22/07/2020
# Data de atualização: 06/05/2021
# Versão: 0.04
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x

#Configuração da Placa de Rede no GNU/Linux Ubuntu 18.04.x LTS
#UDEV controlado pelo Systemd nomeando as Placas de Rede
#Site: https://netplan.io/examples

#Verificando os dispositivos PCI de placa de rede instalados
#opções do comando lspci: -v (verbose), -s (show)
#opção do comando grep: -i (ignore-case)
sudo lspci -v | grep -i ethernet
sudo lcpci -v -s 00:03.0

#Verificando os detalhes do hardware de placa de rede instalada
sudo lshw -class network
sudo lshw -class network | grep "logical name"

#Verificando as configurações de endereçamento da placa de rede instalada
#opção do comando ifconfig: -a (all)
sudo ifconfig -a
sudo ip address

#Verificando as configurações de gateway (route)
#opção do comando route: -n (number)
sudo route -n
sudo ip route

#Verificando as configurações de DNS (resolução de nomes)
sudo cat /etc/resolv.conf

#Verificando as informações de cache de DNS (resolução de nomes)
sudo systemd-resolve --status
sudo systemd-resolve --statistics

#Não se utiliza mais os comandos ifdown e ifup
sudo ifdown enp0s3
sudo ifup enp0s3

#Opção ifconfig down e up ainda e utilizado e do ip link set
sudo ifconfig enp0s3 down
sudo ifconfig enp0s3 up
sudo ip link set enp0s3 down
sudo ip link set enp0s3 up

#Diretório de configuração da placa de rede
cd /etc/netplan/

#Instalando as dependências das Interfaces
sudo apt install bridge-utils ifenslave

#Arquivos de configurações da placa de rede
/etc/netplan/50-cloud-init.yaml
/etc/netplan/00-installer-config.yaml

#Configuração do endereçamento IPv4 Dynamic (Dinâmico)
network:
	ethernets:
		enp0s3:
			dhcp4: true
	version: 2
	
#Aplicando as configurações e verificando os status
sudo netplan --debug try
sudo netplan --debug apply
sudo netplan ip leases enp0s3
sudo systemd-resolve --status
sudo ifconfig enp0s3

#Configuração do endereçamento IPv4 Static (Estático)
network:
	ethernets:
		enp0s3:
			dhcp4: false
			addresses: [172.16.1.20/24]
			gateway4: 172.16.1.254
			nameservers:
				addresses: [172.16.1.254, 8.8.8.8, 8.8.4.4]
				search: [pti.intra]
	version: 2

#Aplicando as configurações e verificando os status
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig enp0s3

#Configuração do endereçamento IPv4 Static (Estático)
network:
	ethernets:
		enp0s3:
			dhcp4: false
			addresses: 
			- 172.16.1.20/24
			gateway4: 172.16.1.254
			nameservers:
				addresses: 
				- 172.16.1.254
				- 8.8.8.8 
				- 8.8.4.4
				search: 
				- pti.intra
	version: 2

#Aplicando as configurações e verificando os status
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig enp0s3

#Configurações de múltiplos endereços IP
network:
	ethernets:
		enp0s3:
			dhcp4: false
			addresses: 
			- 192.168.1.100/24
			- 192.168.2.100/24
			- 192.168.3.100/24
			gateway4: 192.168.1.1
			nameservers:
				addresses:
				- 10.0.0.1
				- 8.8.8.8 
				- 8.8.4.4
				search: 
				- pti.intra
	version: 2

#Aplicando as configurações e verificando os status
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig enp0s3

#Configurações de múltiplos endereços de gateway
network:
	ethernets:
		enp0s3:
			dhcp4: false
			addresses: 
			- 192.168.1.100/24
			- 192.168.2.100/24
			- 192.168.3.100/24
			nameservers:
				addresses:
				- 10.0.0.1
				- 8.8.8.8 
				- 8.8.4.4
				search: 
				- pti.intra
			routers:
				- to: 0.0.0.0/0
         		via: 9.0.0.1
         		metric: 100
       			- to: 0.0.0.0/0
         		via: 10.0.0.1
         		metric: 100
       			- to: 0.0.0.0/0
         		via: 11.0.0.1
         		metric: 100
	version: 2

#Aplicando as configurações e verificando os status
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig enp0s3

#Configurações de bonds 802.3d com interface dinâmica
#Obs: no Oracle VirtualBOX as Placas de Rede precisam está configuradas no modo
#Conectado a: Placa de rede exclusiva de hospedeiro (host-only) - Nome: vboxnet0
#Instalar o aplicativo: sudo apt update && sudo apt install ifenslave bridge-utils
#Iniciar o módulo: sudo modprobe bonding 
network:
	ethernets:
		enp0s3:
			dhcp4: false
		enp0s8
			dhcp4: false
	bonds:
		bond0:
			dhcp4: true
			interfaces:
				- enp0s3
				- enp0s8
			parameters:
				mode: balance-rr
	version: 2

#Aplicando as configurações e verificando os status
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig bond0

#Configurações de bonds 802.3d com interface estática
#Obs: no Oracle VirtualBOX as Placas de Rede precisa está configurado o modo
#Conectado a: Placa de rede exclusiva de hospedeiro (host-only) - Nome: vboxnet
network:
	ethernets:
		enp0s3:
			dhcp4: false
		enp0s8
			dhcp4: false
	bonds:
		bond0:
			dhcp4: false
			interfaces:
				- enp0s3
				- enp0s8
			addresses: [172.16.1.20/24]
			gateway4: 172.16.1.254
			nameservers:
				addresses: [172.16.1.254,8.8.8.8,8.8.4.4]
				search:
					- pti.intra
			parameters:
				mode: balance-rr
	version: 2

#Aplicando as configurações e verificando os status
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig bond0

#Configurações de bridges:
network:
	ethernets:
		enp0s3:
			dhcp4: false
	bridges:
		br0:
			dhcp4: yes
			interfaces:
				- enp0s3
	version: 2

#Aplicando as configurações e verificando os status
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig br0

#Configurações de vlans: 
network:
	vlans:
        inet:
            id: 50
            link: bond0
            addresses: [172.16.1.20/24]
            gateway4: 172.16.1.254
            dhcp4: false
            nameservers:
                addresses: [172.16.1.254,8.8.8.8,8.8.4.4]
	version: 2

#Aplicando as configurações e verificando os status
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status

#Configurações de Wi-Fi (Wireless) com IPv4 Estático:
network:
	wifis:
		wlp4s0:
			dhcp4: no
			dhcp6: no
			addresses: [192.168.0.21/24]
			gateway4: 192.168.0.1
			nameservers:
				addresses: [192.168.0.1, 8.8.8.8]
			access-points:
				"pti-intra":
				password: "pti@2018"
	version: 2

#Aplicando as configurações e verificando os status
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig wlp4s0