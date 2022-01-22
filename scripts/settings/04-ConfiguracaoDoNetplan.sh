#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Linkedin: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Instagram: https://www.instagram.com/procedimentoem/?hl=pt-br
# Github: https://github.com/vaamonde
# Data de criação: 10/10/2021
# Data de atualização: 20/01/2022
# Versão: 0.20
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x644
#
# Configuração da Placa de Rede no GNU/Linux Ubuntu 20.04.x LTS
# UDEV (userspace /dev) responsável por controlar os dispositivos do
# sistema utilizando o Systemd para nomear as Placas de Rede no Ubuntu
# Site: https://netplan.io/examples
#
# Verificando os dispositivos PCI de Placa de Rede instalados
# opções do comando lspci: -v (verbose), -s (show)
# opção do comando grep: -i (ignore-case)
sudo lspci -v | grep -i ethernet
sudo lcpci -v -s 00:03.0
#
# Verificando os detalhes do hardware de Placa de Rede instalada
sudo lshw -class network
sudo lshw -class network | grep "logical name"
#
# Verificando as configurações de endereçamento da Placa de Rede instalada
# opção do comando ifconfig: -a (all)
sudo ifconfig -a
sudo ip address
#
# Verificando as configurações de Gateway (route)
# opção do comando route: -n (number)
sudo route -n
sudo ip route
#
# Verificando as configurações dos Servidores DNS (resolução de nomes)
# OBSERVAÇÃO: no Ubuntu Server não é mais utilizado o arquivo resolv.conf como
# sendo o arquivo principal de configuração dos Servidores DNS do sistema
sudo cat /etc/resolv.conf
#
# Verificando as informações de cache dos Servidores DNS (resolução de nomes)
sudo systemd-resolve --status
sudo systemd-resolve --statistics
#
# Não se utiliza mais os comandos ifdown e ifup para desligar os ligar as placas
# de rede no Ubuntu Server, utilizamos os comandos ifconfig ou ip para isso
sudo ifdown enp0s3
sudo ifup enp0s3
#
# Opção ifconfig down e up ainda e utilizado para depende do pacote net-tool
# seja instalado no sistema, o comando ip link set é o padrão do Ubuntu Server
sudo ifconfig enp0s3 down
sudo ifconfig enp0s3 up
sudo ip link set enp0s3 down
sudo ip link set enp0s3 up
#
# Diretório padrão das configurações da Placa de Rede no Ubuntu Server
cd /etc/netplan/
#
# Instalando as dependências das Interfaces de Rede (Placa de Rede)
sudo apt install bridge-utils ifenslave net-tools
#
# Arquivos de configuração da Placa de Rede no Ubuntu Server utilizando
# o Netplan. OBSERVAÇÃO: o nome do arquivo pode mudar dependendo da versão
# do Ubuntu Server.
/etc/netplan/50-cloud-init.yaml #Padrão Ubuntu Server 18.04.x LTS
/etc/netplan/00-installer-config.yaml #Padrão Ubuntu Server 20.04.x LTS
#
# OBSERVAÇÃO IMPORTANTE: o arquivo de configuração o Netplan e baseado no
# formato de serialização de dados legíveis YAML (Yet Another Markup Language)
# utilizado pelo linguagem de programação Python, muito cuidado com espaços e
# tabulação e principalmente sua indentação.
#
# Configuração do endereçamento IPv4 Dynamic (Dinâmico)
network:
	ethernets:
		enp0s3:
			dhcp4: true
	version: 2
#	
# Aplicando as configurações e verificando o status da Placa de Rede
sudo netplan --debug try
sudo netplan --debug apply
sudo netplan ip leases enp0s3
sudo systemd-resolve --status
sudo ifconfig enp0s3
sudo ip address show enp3s0 
sudo route -n
sudo ip route
#
# Configuração do endereçamento IPv4 Static (Estático)
# Configuração do Endereço IPv4 e dos Servidores de DNS na mesma linha
# utilizando os [] (Colchetes)
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
#
# Aplicando as configurações e verificando o status da Placa de Rede
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig enp0s3
sudo ip address show enp3s0 
sudo route -n
sudo ip route
#
# Configuração do endereçamento IPv4 Static (Estático)
# Configuração do Endereço IPv4 e dos Servidores de DNS em linhas separadas
# utilizando o - (traço/menos/hífen) utilizando a tabulação padrão do YAML
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
#
# Aplicando as configurações e verificando o status da Placa de Rede
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig enp0s3
sudo ip address show enp3s0 
sudo route -n
sudo ip route
#
# Configurações de múltiplos endereços IPv4 Static (Estático)
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
#
# Aplicando as configurações e verificando o status da Placa de Rede
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig enp0s3
sudo ip address show enp3s0 
sudo route -n
sudo ip route
#
# Configurações de múltiplos endereços de Gateway Padrão com custo igual
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
#
# Aplicando as configurações e verificando o status da Placa de Rede
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig enp0s3
sudo ip address show enp3s0
sudo route -n
sudo ip route
#
# Configurações de Bonds 802.3d com interface dinâmica
# Obs: no Oracle VirtualBOX as Placas de Rede precisam está configuradas no modo
# Conectado a: Placa de rede exclusiva de hospedeiro (host-only) - Nome: vboxnet0
# Instalar o aplicativo: sudo apt update && sudo apt install ifenslave bridge-utils
# Iniciar o módulo: sudo modprobe bonding 
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
#
# Aplicando as configurações e verificando o status da Placa de Rede
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig bond0
sudo ip address show bond0
sudo route -n
sudo ip route
#
# Configurações de Bonds 802.3d com interface estática
# Obs: no Oracle VirtualBOX as Placas de Rede precisa está configurado o modo
# Conectado a: Placa de rede exclusiva de hospedeiro (host-only) - Nome: vboxnet
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
#
# Aplicando as configurações e verificando o status da Placa de Rede
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig bond0
sudo ip address show bond0
sudo route -n
sudo ip route
#
# Configurações de Bridges com interface dinâmica
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
#
# Aplicando as configurações e verificando o status da Placa de Rede
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig br0
sudo ip address show br0
sudo route -n
sudo ip route
#
# Configurações de VLANs em interfaces como Bonds e endereço estático
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
#
# Aplicando as configurações e verificando o status da Placa de Rede
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig bond0
sudo ip address show bond0
sudo route -n
sudo ip route
#
# Configurações de Wi-Fi (Wireless) com IPv4 Estático
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
#
# Aplicando as configurações e verificando o status da Placa de Rede
sudo netplan --debug try
sudo netplan --debug apply
sudo systemd-resolve --status
sudo ifconfig wlp4s0
sudo ip address show wlp4s0
sudo route -n
sudo ip route