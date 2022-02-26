Autor: Robson Vaamonde<br>
Procedimentos em TI: http://procedimentosemti.com.br<br>
Bora para Prática: http://boraparapratica.com.br<br>
Robson Vaamonde: http://vaamonde.com.br<br>
Facebook Procedimentos em TI: https://www.facebook.com/ProcedimentosEmTi<br>
Facebook Bora para Prática: https://www.facebook.com/BoraParaPratica<br>
Instagram Procedimentos em TI: https://www.instagram.com/procedimentoem<br>
YouTUBE Bora Para Prática: https://www.youtube.com/boraparapratica<br>
LinkedIn Robson Vaamonde: https://www.linkedin.com/in/robson-vaamonde-0b029028/<br>
Github Procedimentos em TI: https://github.com/vaamonde<br>
Data de criação: 24/08/2021<br>
Data de atualização: 22/09/2021<br>
Versão: 0.4<br>
Testado e homologado no Raspberry Pi 3 B e Ubuntu Core 20 ARM x64 Bits

#Instalação do Ubuntu Core 20 ARM x64 Bits

#01_ Software para a gravação das imagens no microSD Card<br>

	_ RPI-Manager: https://www.raspberrypi.org/software/

#02_ Download da Imagem do Ubuntu Core 20 ARM x64 Bits
	
	_ Informações sobre o Ubuntu Core: https://ubuntu.com/core
	_ Link para download: https://cdimage.ubuntu.com/ubuntu-core/20/stable/current/
	_ Snapcraft: https://snapcraft.io/
	_ Man Page Snap: http://manpages.ubuntu.com/manpages/bionic/man1/snap.1.html
	_ Channel Snap: https://snapcraft.io/docs/channels
	_ Suporte para as versões do Raspberry: Pi3, Pi4, Pi400 e PiCM4

#03_ Limpando as Partições microSD Card

	_ Recomendado utilizar o Gerenciador de Unidade de Disco do Linux Mint (Menu, Discos)
	_ Limpar todas as partições antes de gravar a imagem do Ubuntu Core no microSD Card
	_ OBS1: utilizar sempre microSD Card >= 16GB Classe 10

#04_ Gravando a imagem do Ubuntu Core 20 ARM x64 Bits no microSD Card

	_ Botão direito do mouse na imagem: ubuntu-core-20-arm64+raspi.img.xz
	_ Selecionar: Abrir com o Gravador de imagem de disco
	_ Destino: Driver de 16GB/32GB - Generic SD/MMC/MS PRO (/dev/sdb) <Iniciar restauração>

#05_ Criando sua conta no Ubuntu One SSO (Single Sign On)

	_ Ubuntu One SSO: https://login.ubuntu.com/

#06_ Criando o Par de Chaves SSH para autenticação no Ubuntu Core 20 ARM x64 Bits

	_ Criando a chave pública: ssh-keygen -t rsa
	_ Alterando o nome da chave pública: /home/vaamonde/.ssh/id_rsa_ubuntucore
	_ Visualizando o conteúdo da chave pública: cat ~/.ssh/id_rsa_ubuntucore.pub

#07_ Copiando o conteúdo da Chave Pública no Ubuntu One

	_ Ubuntu One SSo SSH Key: https://login.ubuntu.com/ssh-keys
	_ Copiar a colar todo o conteúdo da chave pública no campo: Import new SSH key <Import SSH Key>

#08_ Ligando o Raspberry Pi 3 B com o microSD Card do Ubuntu Core 20 ARM x64 Bits

	_ OBSERVAÇÃO IMPORTANTE: No primeiro boot do Ubuntu Core o processo demora um pouco, 
	_ devido ao reparticionamento do microSD e a instalação e configuração dos serviços 
	_ base da distribuição e do Snaps, após essa configuração o sistema será reinicializado.
	_ Será necessário confirmar na tela: "Press enter to configure" as configurações básicas
	_ do sistema, o Ubuntu Core será reinicializado duas vezes antes de começar o processo de
	_ configuração da Placa de Rede e do Usuário de acesso remoto via SSH.

#09_ Configurando o Ubuntu Core 20 ARM x64 Bits

	_ Após as reinicializações do Ubuntu Core, vamos configurar o sistema;
	_	Press enter to configure <Enter>
	_	Configure the network and setup an administrator account on this all-snap Ubuntu Core system. <OK>
	_	Configure at least one interfaces this server can use to talk to other machines, and which
	_	preferably provides sufficient access for updates. <Done>
	_	Enter an email address from your account in the store. <Done>
	_ 	This device is registered to: seu_email@seudominio.com. <Done>

#10_ Acessando remotamente via SSH o Ubuntu Core 20 ARM x64 Bits

	_ OBS2: para se autenticar no Ubuntu Core é necessário utilizar o seu usuário do Ubuntu One SSO
	_ Terminal: ssh seu_usuario_ubuntu_one@endereço_ipv4_ubuntu_core

#11 _ Instalando o Snap Core e Classic no Ubuntu Core 20 ARM x64 Bits

	_ OBS3: o Ubuntu Core trabalha principalmente com Snap, caso queira utilizar os comandos
	_       básicos da distribuição é necessário instalar o Snap Classic.
	_ 01 Atualizando as opções de software do Snap: sudo snap refresh
	_ OBS4: Após a atualização do Snap o sistema será reinicializado
	_ 02 Verificando a versão do Snap Core: sudo snap info core
	_ OBS5: No Snap existe vários canais para a instalação de softwares
	_	stable (estável): para a grande maioria dos usuários em ambientes de produção.
	_	candidate (candidato): para usuários que precisam testar as atualizações antes da implantação estável.
	_	beta (beta): para usuários que desejam testar os recursos mais recentes.
	_	edge (borda): para usuários que desejam acompanhar de perto o desenvolvimento.
	_ 03 Instalando o Snap Core: sudo snap install core --edge
	_ 04 Verificando o Snap Core instalado: sudo snap list core
	_ 05 Verificando a versão do Snap Classic: sudo snap info classic
	_ 06 Instalando o Snap Classic: sudo snap install classic --edge --devmode
	_ OBS6: Testes feito no Classic 18 no Ubuntu Core 20 não funcionou perfeitamente, falha de execução
	_ 07 Verificando o Snap Classic instalado: sudo snap list classic
	_ 08 Verificando todos os Snap instalados: sudo snap list
	_ 09 Executando o modo Classic: sudo classic
	_ 10 Instalando o Git: sudo apt install git