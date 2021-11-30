#!/bin/bash
#Autor: Robson Vaamonde
#Site: www.procedimentosemti.com.br
#Facebook: facebook.com/ProcedimentosEmTI
#Facebook: facebook.com/BoraParaPratica
#YouTube: youtube.com/BoraParaPratica
#Data de criação: 19/07/2019
#Data de atualização: 26/11/2021
#Versão: 0.04

#OBSERVAÇÃO IMPORTANTE: A partir do dia 13 de Agosto 2020 o Github não aceitará mais usuários e 
#senhas de contas para se autenticar no github utilizando operações do comando Git (terminal).
#Sendo necessário fazer a criação do Token de acesso para se autenticar no terminal e enviar os
#commit para o github.

Link: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

#Instalando o Git no Debian, Ubuntu ou Linux Mint
sudo apt update && sudo apt install git vim python

#Configuração do Git Localmente
	#Seu nome completo que vai ser utilizado em qualquer commit (confirmação) recém-criado.
	git config --global user.name "Robson Vaamonde"
	
	#Seu endereço de e-mail que vai ser utilizado em qualquer commit (confirmação) recém-criado.
	git config --global user.email robsonvaamonde@gmail.com
	
	#Seu editor de texto padrão para todos os commit (confirmação) e tags.
	git config --global core.editor vim
	
	#Seu software de mesclagem que vai ser utilizado pelo git-mergetool para comparar arquivos.
	git config --global merge.tool vimdiff
	
	#Habilitando o uso de cores do comando git.
	git config --global color.ui true
	
	#Lista todas as variáveis definidas no arquivo de configuração, junto com seus valores.
	git config --list
	
	#Localização do arquivo de configuração do Git.
	ls -lha ~/.gitconfig
	cat ~/.gitconfig

#Acessando site do Github, criando uma conta e criando um Repositório Remoto.
https://github.com

	New Repository
		Repository name: devops
		Description: Básico de Git e Github no Linux Mint
		Public
		Check: Initialize this repository with a README
		Add a license: GNU General Public License v3.0
		Edit: Description (Emoji) - Website: http://www.boraparapratica.com.br
			(https://gist.github.com/rxaviers/7360908)
		Manage topics: git github bash shell linux linux-mint
			Link: https://github.com/vaamonde/devops.git
			Link: https://github.com/vaamonde/devops
	
	Create new file: 	teste01.sh
						Edit new file: Criando nosso primeiro script em Shell
						Preview
						Commit new file: Criando nosso primeiro script em Shell
						Add and optional: Criando nosso primeiro script em Shell
						Check: Commit directly to the master branch

	Upload files:	 	teste02.sh
						Or choose your files: teste02.sh
						Commit changes: Upload do nosso segundo script em Shell
						Add and optional: Upload do nosso segundo script em Shell
						Check: Commit directly to the master branch

	Upload directory:	teste03
						Or choose your files: teste03
						Commit changes: Upload do diretório do nosso terceiro script
						Add and optional: Upload do diretório do nosso terceiro script
						Check: Commit directly to the master branch

#Criando um Token para acesso remoto utilizando o comando git
Link da geração do Token: https://github.com/settings/tokens
Gerando um novo Token

#Clonando um Repositório Remoto do Github.
git clone https://github.com/vaamonde/devops.git
cd devops
ls -lha

#Criando um arquivo dentro do Repositório Clonado
echo "#Teste de versionamento utilizando o Git" > teste04.sh
cat teste04.sh

#Vendo o status dos arquivos no Repositório Clonado
git status

#Adicionando o rastreamento de versionamento do arquivo no Repositório Clonado
git add teste04.sh
git status

#Confirmando (commits) a modificação do arquivo no Repositório Clonado
git commit -m "Criação do Arquivo teste04.sh"
git status

#Listando vários tipos de objetos (blobs, trees, tags e commits) no Repositório Clonado
git show

#Mostrando os logs de confirmação (commits) no Repositório Clonado
git log
Q para sair

#Envia o novo arquivo confirmado (commit) do Repositório Clonado para o Repositório Remoto do Github
git push

#Editando arquivo, criando diretório, fazendo Upload de arquivo e diretório no Repositório Remoto do Github
README.md
teste05/teste05.sh

#Baixando o novo arquivo confirmado (commit) do Repositório Remoto do Github para o Repositório Clonado
git pull

#Editando um arquivo localmente e enviando as confirmações (commit) para o Repositório Remoto do Github
vim README.md
git add * ou git add .
git commit -m "Alteração do arquivo README.md"
git status
git show
git log
git push

#Criando um diretório e arquivo no Repositório Clonado, confirmando (commit) as modificações e atualizando o
#Repositório Remoto do Github
mkdir -v teste06
cd teste06
echo "#Teste de versionamento utilizando o Git" > teste06.sh
git add * ou git add .
git commit -m "Criação do Diretório teste06 e Arquivo teste06.sh"
git status
git show
git log
git push

#Criando um novo Repositório Local com o Git e enviando as confirmações (commit) para a criação de um novo 
#Repositório Remoto no Github
mkdir vaamonde
cd vaamonde
git init
ls -lha
echo "#Teste de versionamento utilizando o Git" > teste.sh
git add * ou git add .
git commit -m "Criação do arquivo teste.sh"
git status
git show
git log
git push (utilizar o seu Token criado na etapa)

#Automatizando no bash o Commit do Git
git pull && git add . && git commit -m "Atualizacao" && git push