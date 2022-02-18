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
# Data de atualização: 09/02/2022
# Versão: 0.21
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
#
# Configuração do Locale (Localidade) do Sistema Operacional Ubuntu Server
sudo localectl
sudo cat /etc/default/locale
sudo ls /usr/share/X11/locale
	LANG=en_US.UTF-8 (Padrão Inglês Americano com acentuação)
	LANG=pt_BR.UTF-8 (Padrão Português Brasileiro com acentuação)
sudo locale -a
sudo locale-gen pt_BR.UTF-8
sudo localectl set-locale LANG=pt_BR.UTF-8
sudo update-locale LANG=pt_BR.UTF-8 LC_ALL=pt_BR.UTF-8 LANGUAGE="pt_BR:pt:en"
sudo reboot
#
# Configuração do Timezone (Fuso Horário) do Sistema Operacional Ubuntu Server
sudo timedatectl
sudo systemctl status systemd-timesyncd.service
sudo timedatectl set-timezone "America/Sao_Paulo"
# OBSERVAÇÃO IMPORTANTE: geralmente mudar para o Time Zone de America/Sao_Paulo a hora
# fica errada no sistema, nesse caso podemos mudar para America/Fortaleza ou America/Bahia
# esse error e por causa do Fuso Horário em relação ao Horário de Verão que não existe 
# mais no Brasil
sudo cat /etc/timezone
sudo cat /etc/systemd/timesyncd.conf
sudo vim /etc/systemd/timesyncd.conf
	[Time]
	NTP=a.st1.ntp.br
	FallbackNTP=a.ntp.br
sudo systemctl restart systemd-timesyncd.service
sudo systemctl status systemd-timesyncd.service
sudo timedatectl
#
# Configuração de Data e Hora do Sistema Operacional Ubuntu Server
sudo date
sudo date +%d/%m/%Y
sudo date -s 03/25/2019	(-s=set, Mês, Dia e Ano)
sudo date +%H:%M:%S
sudo date -s 13:30:00 (-s=set, Hora, Minuto, Segundos)
#
# Sincronizando Data e Hora do Sistema Operacional Ubuntu Server e Hardware (BIOS)
sudo hwclock --show
sudo hwclock --systohc (Atualização do Sistema para o Hardware)
sudo hwclock --hctosys (Atualização do Hardware para o Sistema)
#
# Instalação e Configuração do Agente/Cliente do NTP (Network Time Protocol)
sudo apt update
sudo apt install ntpdate
sudo ntpdate
sudo ntpdate a.st1.ntp.br
#
# Configuração do Teclado Português/Brasil ABNT-2
sudo cat /etc/default/keyboard
	XKBMODEL="pc105" (Padrão 105 teclas pc105)
	XKBLAYOUT="br" (Layout de Teclado Português Brasileiro ABNT2)

sudo dpkg-reconfigure keyboard-configuration
	Keyboard model: Generic 105-Key PC (intl <- Internacional) <Enter>;
	Country of origin for the keyboard: Portuguese (Brazil) <Enter>;
	Keyboard layout: Portuguese (Brazil) (Padrão ABNT-2) <Enter>;
	Key to function as AltGr: Right Alt (AltGr) <Enter>;
		(The Default for the Keyboard Layout (O padrão para o layout do teclado));
	No Compose Key (Nenhuma combinação de composição) <Enter>.
reboot
#
# Configuração do UTF-8 (8-bit Unicode Transformation Format) e Console (Bash/Shell)
sudo cat /etc/default/console-setup
	CHARMAP="UTF-8"

sudo dpkg-reconfigure console-setup
	UTF-8 <Enter>;
	Guess optimal character set (Supor o melhor conjunto de caracteres) <Enter>;
	Fixed <Enter>;
	8x16 <Enter>.
#
# Reinicializar o Servidor para Verificar todas as Mudanças
sudo reboot