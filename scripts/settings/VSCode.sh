#!/bin/bash
#Autor: Robson Vaamonde
#Procedimentos em TI: http://procedimentosemti.com.br
#Bora para Prática: http://boraparapratica.com.br
#Robson Vaamonde: http://vaamonde.com.br
#Facebook Procedimentos em TI: https://www.facebook.com/ProcedimentosEmTi
#Facebook Bora para Prática: https://www.facebook.com/BoraParaPratica
#Instagram Procedimentos em TI: https://www.instagram.com/procedimentoem
#YouTUBE Bora Para Prática: https://www.youtube.com/boraparapratica
#LinkedIn Robson Vaamonde: https://www.linkedin.com/in/robson-vaamonde-0b029028/
#Data de criação: 23/07/2021
#Data de atualização: 26/11/2021
#Versão: 0.05
#Testado e homologado no Linux Mint 20.x e VSCode 1.58.x

O Visual Studio Code é um editor de código-fonte desenvolvido pela Microsoft para Windows, 
Linux e macOS. Ele inclui suporte para depuração, controle de versionamento Git incorporado, 
realce de sintaxe, complementação inteligente de código, snippets e refatoração de código. 
Ele é customizável, permitindo que os usuários possam mudar o tema do editor, teclas de atalho 
e preferências. Ele é um software livre e de código aberto, apesar do download oficial estar 
sob uma licença proprietária.

#Links Oficial do VSCode e do Marketplace
Link do Visual Studio Code: https://code.visualstudio.com/
Link do Marketplace: https://marketplace.visualstudio.com/VSCode

#01_ Baixando o VSCode para o Linux Mint 20.x
https://code.visualstudio.com/download
	Versão: .deb (Debian, Ubuntu 64 Bits)
		Salvar aquivo

#02_ Instalando o Vim, Git e o Python no Linux Mint 20.x
Terminal
	sudo apt update 
	sudo apt install vim git python 
	exit

#03_ Instalando o VSCode utilizando o Gdebi-Gtk do Linux Mint 20.x
Arquivos
	Download
		code_1.xxxx_amd64
			Instalar Pacote
		Fechar

#04_ Verificando o novo repositório do VSCode no MintUpdate do Linux Mint 20.x
Menu
	MintUpdate
		Editar
			Fontes de Programas
				(Digite a senha do seu usuário)
					Repositórios Adicionais
						Habilitado: Microsoft / Stable - code
					Chaves de Autenticação
						Microsoft (Release signing)
			Fechar
	Fechar

#05_ Iniciando o VSCode no Linux Mint 20.x
Menu
	Busca Indexada
		vscode
			Dark Theme
			Notifications: Pacote PT-BR
			Disable: Mostrar página inicial na inicialização

#06_ Configurando o VSCode como Aplicativo de Preferência no Linux Mint 20.x
Menu
	Busca Indexada
		Aplicativos de Preferencias
			Texto puro: Visual Studio Code
			Código fonte: Visual Studio Code

#07_ Instalando e Configurando as Principais Extensões que utilizo no Meu Dia a Dia
Portuguese (Brazil) Language Pack for Visual Studio Code
	(Sem necessidade de configuração)

Brazilian Portuguese - Code Spell Checker (Corretor Ortográfico de Código)
Manter selecionado a extensão: Brazilian Portuguese - Code Spell Checker
	Pressionar F1
		Show Spell Checker Configuration Info
			User
				Language
					English (en_us)
					Portuguese (pt_br)
					Portuguese - Brazil (pt-br)
				File Types and Programming Languages
					shellscript, python, markdown, etc...

Bats (Bash Automated Testing System)
	(Sem necessidade de configuração)

Bash Beautify
	(Sem necessidade de configuração)

Shell-Format
	(Sem necessidade de configuração)

ShellCheck
	(Sem necessidade de configuração)

Cisco IOS Systax
	(Sem necessidade de configuração)

Cisco IOS-XR Systax
	(Sem necessidade de configuração)

Cisco Config Highlight
	(Sem necessidade de configuração)

Pylance
	(Sem necessidade de configuração)

Python
	(Sem necessidade de configuração)

#08_ Configurações principais do VSCode para funcionar perfeitamente no Linux Mint
Gerenciar
	Configurações
		Code Spell Checker
			C Spell: Enabled Language Ids: shellscript
			C Spell: Language: en,pt,pt-BR
			C Spell: Max Duplicate Problems: 5000
			C Spell: Max Number Of Problems: 100000
		Editor
			Editor: Tab Size: 4
			Editor: Detect Indentation: False (Off)
			Editor: Insert Spaces: False (Off)
		Files
			Files: Eol: \n (LF)