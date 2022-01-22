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
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
#
# Desligando e reinicializando o servidor com halt
sudo hatl -p (Poweroff)
sudo halt --reboot
#
# Desligando e reinicializando o servidor com poweroff
sudo poweroff
sudo poweroff --reboot
#
# Desligando e reinicializando o servidor com init
sudo init 0
sudo init 6
#
# Desligando e reinicializando o servidor com reboot
sudo reboot --halt (Poweroff)
sudo reboot
#
# Desligando e reinicializando o servidor com shutdown
sudo shutdown -P (Poweroff)
sudo shutdown -h (Halt padrão de desligamento em 60 segundos)
sudo shutdown -h now
sudo shutdown -r now
sudo shutdown -h 19:50 Servidor será desligado
sudo shutdown -c (Para cancelar o agendamento)
sudo date