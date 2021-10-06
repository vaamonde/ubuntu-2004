#!/bin/bash
# Autor: Robson Vaamonde
# Procedimentos em TI: http://procedimentosemti.com.br
# Bora para Prática: http://boraparapratica.com.br
# Robson Vaamonde: http://vaamonde.com.br
# Facebook Procedimentos em TI: https://www.facebook.com/ProcedimentosEmTi/
# Facebook Bora para Prática: https://www.facebook.com/boraparapratica/
# Instagram Procedimentos em TI: https://www.instagram.com/procedimentoem/
# YouTUBE Bora Para Prática: https://www.youtube.com/boraparapratica
# LinkedIn Robson Vaamonde: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Data de criação: 20/09/2021
# Data de atualização: 20/09/2021
# Versão: 0.01
# Testado e homologado para a versão do Ubuntu Server 20.04.x LTS x64
# Kernel >= 5.14.x
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
sudo init 0 (Poweroff)
sudo init 6 (Reboot)
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