Autor: Robson Vaamonde<br>
Procedimentos em TI: http://procedimentosemti.com.br<br>
Bora para Prática: http://boraparapratica.com.br<br>
Robson Vaamonde: http://vaamonde.com.br<br>
Facebook Procedimentos em TI: https://www.facebook.com/ProcedimentosEmTi<br>
Facebook Bora para Prática: https://www.facebook.com/BoraParaPratica<br>
Instagram Procedimentos em TI: https://www.instagram.com/procedimentoem<br>
YouTUBE Bora Para Prática: https://www.youtube.com/boraparapratica<br>
LinkedIn Robson Vaamonde: https://www.linkedin.com/in/robson-vaamonde-0b029028/<br>
Data de criação: 10/10/2021<br>
Data de atualização: 10/10/2021<br>
Versão: 0.01<br>
Testado e homologado no GNU/Linux Ubuntu Server 20.04.3 LTS

Atualização da versão do Ubuntu Server 20.04.3: https://wiki.ubuntu.com/FocalFossa/ReleaseNotes<br>
Mudanças da versão do Ubuntu Server 20.04.3: https://wiki.ubuntu.com/FocalFossa/ReleaseNotes/ChangeSummary/20.04.3<br>
Ciclo de Lançamento do Ubuntu Server: https://ubuntu.com/about/release-cycle

OBS1 - lentidão da instalação e configuração do Ubuntu Server 20.04.x no Oracle VirtualBOX<br>
Link1: https://forums.virtualbox.org/viewtopic.php?f=3&t=98944<br>
Link2: https://forums.virtualbox.org/viewtopic.php?f=7&t=98586<br>

Primeira etapa: Download da ISO do Ubuntu Server 20.04.3 LTS
01. Link de download do Ubuntu Server: https://releases.ubuntu.com/20.04.3/
02. Versão do download Ubuntu Server: ubuntu-20.04.3-live-server-amd64.iso (24/08/2021)
03. Arquitetura do Ubuntu Server: AMD64 (64-bit)
04. Tipo de instalação: DVD Image (ISO) Installer

Segunda etapa: Criação e Configuração da Máquina Virtual no Oracle VirtualBOX<br>
Link de download do Oracle VirtualBOX: https://www.virtualbox.org/wiki/Downloads
01. Ferramentas;
		Novo
02. Nome e Sistema Operacional:
		Nome: UbuntuServer-2004
		Pasta da Máquina: (deixar o padrão do sistema) 
		Tipo: Linux
		Versão: Ubuntu (64-bit)
	<Próximo>
03. Tamanho da memória:
		Tamanho: 2048MB
	<Próximo>
04. Disco Rígido:
		Criar um novo disco rígido virtual agora
	<Criar>
05. Tipo de arquivo de disco rígido
		VDI (VirtualBOX Disk Image)
	<Próximo>
06. Armazenamento em disco rígido físico
		Dinamicamente alocado
	<Próximo>
07. Localização e tamanho do arquivo
		Localização: (deixar o padrão do sistema)
		Tamanho do disco: 50GB
	<Criar>
04. Configurações da Máquina Virtual UbuntuServer-2004 (Propriedades/Configurações)
	Sistema
		Placa Mãe
			Recurso Estendidos
				Relógio da máquina retorno hora UTC: Desabilitar
		Processador
			Processadores: 02 CPUs
			Recursos Estendidos: Habilitar PAE/NX
	Monitor
		Tela
			Memória de Vídeo: 128MB
			Aceleração: Habilitar Aceleração 3D
	Áudio
		Habilitar Áudio: Desabilitar
	Rede
		Adaptador 1 (LAN)
			Habilitar Placa de Rede
			Conectado a: Rede Interna
			Nome: (deixar o padrão do sistema: intnet)
<OK>

Instalação do Ubuntu Server: https://ubuntu.com/server/docs/installation

Terceira etapa: Instalação do Ubuntu Server 20.04.3 LTS (localizar a ISO)
01. VM UbuntuServer-2004: Iniciar
02. Selecione o disco rígido de boot
		Selecionar um arquivo de disco óptico virtual
03. Seletor de Discos Ópticos
		Acrescentar
		Selecione o arquivo de disco óptico virtual: ubuntu-20.04.3-live-server-amd64.iso
	<Abrir>
04. Not Attached
		Selecionar: ubuntu-20.04.3-live-server-amd64.iso
	<Escolher>
<Iniciar>

01. Use UP, DOWN and ENTER keys to select your language 
		English - <Enter>
02. Keyboard configuration
		Layout: [English (US)]
		Variant: [English (US)]
	<Done>
03. Network connections
		enp0s3 eth <Enter>
			Edit IPv4 <Enter>
				IPv4 Method: Manual <Enter>
					Subnet: 172.16.1.0/24 <Tab>
					Address: 172.16.1.20 <Tab>
					Gateway: 172.16.1.254 <Tab>
					Name servers: 172.16.1.254 <Tab>
					Search domains: pti.intra
				<Save>
	<Done>
04. Configure proxy - <Done>
05. Configure Ubuntu archive mirror - <Done>
06. Guided storage configuration - <Done>
07. Storage configuration - <Done>
		Confirm destructive action - <Continue>
08. Profile setup
		Your name: Robson Vaamonde <Tab>
		Your server's name: ptispo01ws01 <Tab>
		Pick a username: vaamonde <Tab>
		Choose a passwords: pti@2018 <Tab>
		Confirm your passwords: pti@2018
	<Done>
09. SSH Setup
		Install OpenSSH server: ON <Space>
		Import SSH identity: No <Tab>
	<Done>
10. Featured Server Snaps - <Done>
11. Reboot Now - <Enter>
12. Please remove the installation medium, then press ENTER - <Enter>
