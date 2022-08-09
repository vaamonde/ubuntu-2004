#Autor: Robson Vaamonde<br>
#Procedimentos em TI: http://procedimentosemti.com.br<br>
#Bora para Prática: http://boraparapratica.com.br<br>
#Robson Vaamonde: http://vaamonde.com.br<br>
#Facebook Procedimentos em TI: https://www.facebook.com/ProcedimentosEmTi<br>
#Facebook Bora para Prática: https://www.facebook.com/BoraParaPratica<br>
#Instagram Procedimentos em TI: https://www.instagram.com/procedimentoem<br>
#YouTUBE Bora Para Prática: https://www.youtube.com/boraparapratica<br>
#Data de criação: 31/05/2022<br>
#Data de atualização: 28/07/2022<br>
#Versão: 0.02<br>
#Testado e homologado no Linux Mint 20.1 Ulyssa, 20.2 Uma e 20.3 Una x64

#Instalação do Microsoft Visual Studio Code VSCode no Linux Mint 20.1 Ulyssa, 20.2 Uma e 20.3 Una x64

Site Oficial do Visual Studio Code: https://code.visualstudio.com/<br>
Link do Marketplace: https://marketplace.visualstudio.com/VSCode

#00_ Verificando as Informações do Sistema Operacional Linux Mint<br>

	OBSERVAÇÃO IMPORTANTE: Linux Mint 20.3 Una é derivado do Ubuntu Desktop 20.04.4 Focal Fossa
	sudo cat /etc/os-release

#01_ Atualização do Sistema Operacional Linux Mint<br>

	sudo apt update
	sudo apt upgrade
	sudo apt full-upgrade
	sudo apt dist-upgrade
	sudo apt autoremove
	sudo apt autoclean

#02_ Instalando as Dependências do Microsoft Visual Studio Code VSCode no Linux Mint<br>

	sudo apt install vim git python2 python3 cloc

#03_ Baixando o Microsoft Visual Studio Code VSCode para o Linux Mint<br>

	https://code.visualstudio.com/download
		Versão: .deb (Debian, Ubuntu 64 Bits)
			Salvar aquivo

#04_ Instalando o Microsoft Visual Studio Code VSCode utilizando o Gdebi-Gtk no Linux Mint<br>

	Arquivos
		Download
			code_1.xxxx_amd64
				Instalar Pacote
			Fechar

#05_ Verificando o novo repositório do Microsoft Visual Studio Code VSCode no MintUpdate<br>

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

#06_ Iniciando o Microsoft Visual Studio Code VSCode no Linux Mint<br>

	Menu
		Busca Indexada
			vscode
				Dark Theme
				Notifications: Pacote PT-BR
				Disable: Mostrar página inicial na inicialização

#07_ Configurando o Microsoft Visual Studio Code VSCode como Aplicativo de Preferência no Linux Mint<br>

	Menu
		Busca Indexada
			Aplicativos de Preferencias
				Texto puro: Visual Studio Code
				Código fonte: Visual Studio Code

#08_ Instalando e Configurando as Principais Extensões que utilizo no Meu Dia a Dia<br>

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

	Code Spell Checker
		(Sem necessidade de configuração)

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

	Docker
		(Sem necessidade de configuração)

	Powershell
		(Sem necessidade de configuração)

	Ansible
		(Sem necessidade de configuração)

	YAML
		(Sem necessidade de configuração)

#09_ Configurações principais do Microsoft Visual Studio Code VSCode para funcionar perfeitamente no Linux Mint<br>

	Gerenciar
		Configurações
			Code Spell Checker
				C Spell: Enabled Language Ids: 
					Adicionar Item: shellscript
				C Spell: Language: en,pt,pt-BR
				C Spell: Max Duplicate Problems: 500000
				C Spell: Max Number Of Problems: 500000
			Editor
				Editor: Tab Size: 4
				Editor: Detect Indentation: False (Off)
				Editor: Insert Spaces: False (Off)
				Render Whitespace: All
			Files
				Files: Eol: \n (LF)

			#OBSERVAÇÃO IMPORTANTE: executar essa configuração somente se você fez a instalação
			#do ZSH, das Fontes Hack e do Oh My ZSH.
			Font
				Integrated: Font Family
					Hack Nerd Font
			
			#Configuração do Terminal Padrão do VSCODE
			Ctrl + Shift + P
				Terminal: Selecionar o Perfil Padrão
					zsh