#!/bin/bash
# Autor: Robson Vaamonde
# Site: www.procedimentosemti.com.br
# Facebook: facebook.com/ProcedimentosEmTI
# Facebook: facebook.com/BoraParaPratica
# YouTube: youtube.com/BoraParaPratica
# Data de criação: 04/11/2018
# Data de atualização: 22/07/2020
# Versão: 0.07
# Testado e homologado para a versão do Ubuntu Server 18.04.x LTS x64
# Kernel >= 4.15.x

#Desligando e reinicializando o servidor com halt
sudo hatl -p (Poweroff)
sudo halt --reboot

#Desligando e reinicializando o servidor com poweroff
sudo poweroff
sudo poweroff --reboot

#Desligando e reinicializando o servidor com init
sudo init 0
sudo init 6

#Desligando e reinicializando o servidor com reboot
sudo reboot --halt (Poweroff)
sudo reboot

#Desligando e reinicializando o servidor com shutdown
sudo shutdown -P (Poweroff)
sudo shutdown -h (Halt padrão de desligamento em 60 segundos)
sudo shutdown -h now
sudo shutdown -r now
sudo shutdown -h 19:50 Servidor será desligado
sudo shutdown -c (Para cancelar o agendamento)
sudo date