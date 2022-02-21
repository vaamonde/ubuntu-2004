#!/bin/bash
# Autor: Robson Vaamonde
# Procedimentos em TI: http://procedimentosemti.com.br
# Bora para Prática: http://boraparapratica.com.br
# Robson Vaamonde: http://vaamonde.com.br
# Facebook Procedimentos em TI: https://www.facebook.com/ProcedimentosEmTi
# Facebook Bora para Prática: https://www.facebook.com/BoraParaPratica
# Instagram Procedimentos em TI: https://www.instagram.com/procedimentoem
# YouTUBE Bora Para Prática: https://www.youtube.com/boraparapratica
# LinkedIn Robson Vaamonde: https://www.linkedin.com/in/robson-vaamonde-0b029028/
# Github: https://github.com/vaamonde
# Data de criação: 21/02/2022
# Data de atualização: 21/02/2022
# Versão: 0.01
# Testado e homologado no Linux Mint 20.x e VSCode 1.58.x
#
PowerShell é um shell de linha de comando baseado em tarefas e linguagem de script desenvolvido
no .NET. Inicialmente, apenas um componente do Windows, o PowerShell tornou-se de código aberto 
e multiplataforma em 18 de agosto de 2016 com a introdução do PowerShell Core.
#
O SDK do .NET é um conjunto de bibliotecas e ferramentas que permitem aos desenvolvedores criar 
aplicativos e bibliotecas .NET, ele contém os seguintes componentes que são usados para criar e 
executar aplicativos: CLI do .NET, Bibliotecas e Runtime do .NET e o driver dotnet.
#
NET Framework consiste no Common Language Runtime, que fornece gerenciamento de memória e outros 
serviços do sistema, além de em uma biblioteca de classes extensa, o que permite que programadores 
usem o código robusto e confiável para todas as áreas principais do desenvolvimento de aplicativos.
#
# Links Oficial do PowerShell, .NET SDK e .NET Runtime
Link do PowerShell: https://docs.microsoft.com/pt-br/powershell/scripting/overview?view=powershell-7.2
Link do .NET SDK: https://docs.microsoft.com/pt-br/dotnet/core/sdk
Link do .NET Runtime: https://docs.microsoft.com/pt-br/dotnet/framework/get-started/
#
# Links de Instalação do PowerShell e .NET na Distribuição Ubuntu
Link do PowerShell: https://docs.microsoft.com/pt-br/powershell/scripting/install/install-ubuntu?view=powershell-7.2
Link do .NET SDK e Runtime: https://docs.microsoft.com/pt-br/dotnet/core/install/linux-ubuntu#2004-
#
# 01_ Atualização do Sistema Operacional
	01.1 - Recomendado utilizar o MintUpdate
	01.2 - Utilizando o Terminal: Ctrl+Alt+T
			sudo apt update 
			sudo apt upgrade
#
# 02_ Instalando as Dependências do PowerShell e do .NET SDK e Runtime
	02.2 - sudo apt install apt-transport-https software-properties-common libc6 libgcc1 \
	libgssapi-krb5-2 libicu66 libssl1.1 libstdc++6 zlib1g
#
# 03_ Baixando o repositório oficial do PowerShell e do .NET SDK e Runtime
	03.1 - wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
#
# 04_ Instalando o repositório oficial do PowerShell e do .NET SDK e Runtime
	04.1 - sudo dpkg -i packages-microsoft-prod.deb
#
# 05_ Atualizando as Lista do Apt com os novos repositórios
	05.1 - sudo apt update
#
# 06_ Instalando o PowerShell, .NET SDK e Runtime
	06.1 - sudo apt install powershell dotnet-sdk-6.0 aspnetcore-runtime-6.0
#
# 07_ Rodando o PowerShell no Linux Mint
	07.1 - pwsh
#
# 08_ Utilizando o PowerShell no Linux Mint
	Get-Host		- informações detalhadas do PowerShell
	Get-Process		- informações de processos
	Get-Command		- lista todos os comandos que estão disponíveis
	Get-Module		- lista todos os módulos que estão disponíveis
	Get-History		- imprimir todo o histórico de comandos do PowerShell
	dir ou ls 		- lista o conteúdo do diretório
	exit			- sair do PowerShell