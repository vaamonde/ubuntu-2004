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
# RAID foi originalmente denominado de "Redundant Array of Inexpensive Drives" (Conjunto Redundante 
# de Discos Baratos). Com o tempo, numa tentativa de dissociar o conceito de "discos baratos", a 
# indústria reviu o acrônimo para "Redundant Array of Independent Disks" (Conjunto Redundante de 
# Discos Independentes). RAID é um meio de se criar um subsistema de armazenamento composto por 
# vários discos individuais, com a finalidade de ganhar segurança -- por meio da redundância de 
# dados e desempenho.
#
# Tipos de RAID (Obs: os RAID 0 e 1 obrigatoriamente precisa de 2 (dois) Hard Disk, os RAID superiores
# ao 5 precisam de 3 (três) ou mais Hard Disk para serem configurados)
#	RAID 0 - Striping (fracionamento)
#	RAID 1 - Mirror (espelho)
#	RAID 5 - Strip Set (distribuição com paridade)
#	RAID 6 - Double Strip Set (distribuição com paridade dupla)
#	RAID 10 - combinação do RAID-1 (Mirror) e RAID-0 (Striping)
#	RAID 50 - combinação do RAID-5 (Strip Set) e RAID-0 (Striping)
# 	RAID 60 - combinação do RAID-6 (Duble Strip Set) e RAID-0 (Striping)
#
# Fdisk: é um programa orientado a menus para criação e manipulação de tabelas de partição, ele 
# compreende tabelas de partição do tipo DOS e etiquetas de disco do tipo BSD ou SUN. O fdisk 
# não entende GPTs (tabelas de partição GUID) e não foi projetado para partições grandes, nesses 
# casos, use o GNU mais avançado dividido. O fdisk não usa o modo e os cilindros compatíveis com 
# DOS como unidades de exibição por padrão.
#
# Cfdisk: é um editor de partições do Linux, semelhante ao fdisk, mas com uma interface de usuário 
# diferente (ncurses). Faz parte do pacote de programas utilitários do Linux, o util-linux. 
#
# Parted: (o nome sendo a conjunção das duas palavras PARTition e EDitor) é um editor de partições 
# livre, usado para criar e excluir partições. Isso é útil para criar espaço para novos sistemas 
# operacionais, reorganizar o uso do disco rígido, copiar dados entre discos rígidos e imagens de disco.
#
# Mdadm: é um utilitário Linux usado para gerenciar e monitorar dispositivos RAID de software, é usado 
# em distribuições Linux modernas no lugar de utilitários RAID de software mais antigos, como raidtools2 
# ou raidtools.
#
# Mkfs: é um comando usado para formatar um dispositivo de armazenamento em bloco com um sistema de 
# arquivos específico. O comando é parte dos sistemas operacionais UNIX e tipo UNIX.
#
# Mount ou Umount: tem a função de montar ou desmontar um dispositivo na hierarquia do sistema de arquivos 
# do Linux, muito utilizado para acessar partições em Hard Disk, Pendrive, CD-Rom, DVD, etc... 
#
# Fstab: O arquivo /etc/fstab permite que as partições do sistema sejam montadas facilmente especificando 
# somente o dispositivo ou o ponto de montagem. Este arquivo contém parâmetros sobre as partições que são 
# lidos pelo comando mount. 

# Localizando os Hard Disk no Ubuntu Server
lshw -class disk | less

# Verificando os Hard Disk com os comandos: Fdisk, Parted e Cfdisk
# opção do comando fdisk: -l (list)
# opção do comando parted: -l (list)
fdisk -l | less (sem suporte a GPT somente MBR)
parted -l | less (com suporte a GPT e MBR)
cfdisk (com suporte a GPT e MBR)

# Verificando o UUID (Universally Unique IDentifier) dos Hard Disk utilizados
blkid

# Listando os Hard Disk e Partições montadas do UUID (Universally Unique IDentifier)
lsblk

# Utilizando o fdisk para criar o particionamento no Hard Disk SDB com suporte ao RAID
fdisk /dev/sdb
	n <-- adicionar uma nova partição
	p <-- primaria (0 primaria, 0 estendida, 4 livres)
	1 <-- primeira partição (1-4, padrão 1)
		<-- valor do primeiro cilindro (padrão 2048)
		<-- valor do último cilindro (padrão tudo alocado)
	p <-- imprime na tela o particionamento
	t <-- mudar o tipo de partição
		<-- fd Linux RAID auto-detecção (valor em Hexadecimal)
	p <-- imprime na tela o particionamento
	w <-- sair e gravar as informações de partição

# Utilizando o fdisk para criar o particionamento no Hard Disk SDC com suporte ao RAID
fdisk /dev/sdc
	n <-- adicionar uma nova partição
	p <-- primaria (0 primaria, 0 estendida, 4 livres)
	1 <-- primeira partição (1-4, padrão 1)
		<-- valor do primeiro cilindro (padrão 2048)
		<-- valor do último cilindro (padrão tudo alocado)
	p <-- imprime na tela o particionamento
	t <-- mudar o tipo de partição
		<-- fd Linux RAID auto-detecção (valor em Hexadecimal)
	p <-- imprime na tela o particionamento
	w <-- sair e gravar as informações de partição

# Utilizando o Cfdisk para criar o particionamento no Hard Disk SDD sem suporte ao RAID
cfdisk /dev/sdd
	dos <-- tipo do rótulo da partição
	New <-- nova partição
	Partition size: 20GB <-- toda a partição alocada
	Primary <-- partição primária
	Partition Type: Linux (83)
	Write (yes)
	Quit

# Listando o conteúdo do diretório: /dev/ para verificar os arquivos de blocos dos Hard Disk
# opções do comando ls: -l (long listing), -h (--human-readable), -a (--all)
ls -lha /dev/sd*

# Criando o Array de RAID-1 com os Hard Disk SDB e SDC utilizando o mdadm
# Opção do comando mdadm: -C (create), -v (verbose), -l (level), -n (raid-devices)
# opções do comando ls: -l (long listing), -h (--human-readable), -a (--all)
mdadm -C -v /dev/md1 -l 1 -n 2 /dev/sdb1 /dev/sdc1
	Continue creating array? y <Enter>
ls -lha /dev/md*

# Criando o sistema de arquivos EXT4 no Array de RAID-1 do dispositivo MD1 e do HD de Backup
# opção do comando mkfs.ext4: -v (verbose)
mkfs.ext4 -v /dev/md1
mkfs.ext4 -v /dev/sdd1

# Verificando o Array do RAID-1 criado no MD1
# Opção do comado mdadm: -D (--detail), -E (--examine)
cat /proc/mdstat
mdadm -D /dev/md1
mdadm -E /dev/sdb1
mdadm -E /dev/sdc1

# Verificando os detalhes do Array do RAID-1
# Opção do comado mdadm: -D (--detail), -s (--scan)
mdadm -D -s

# Atualizando o arquivo de configuração do Array do RAID-1 em /etc/mdadm/mdadm.conf
# Opção do comado mdadm: -D (--detail), -s (--scan)
# opção do redirecionador >>: (Redireciona a saída padrão, anexando)
mdadm -D -s >> /etc/mdadm/mdadm.conf

# Editando o arquivo de configuração do mdadm.conf
vim /etc/mdadm/mdadm.conf

# Montando o disco do Array do RAID-1 manualmente com o comando mount
# opção do comando mkdir: -v (verbose)
# opção do comando mount: -v (verbose), -l (list)
# opção do bloco de agrupamento {}: (Agrupa comandos em um bloco)
# opções do comando ls: -l (long listing), -h (--human-readable), -a (--all)
# opção do redirecionamento |: (Conecta a saída padrão com a entrada padrão de outro comando)
# Material de apoio: https://www.guiafoca.org/guiaonline/iniciante/ch04s05.html
mkdir -v /arquivos
mount -v /dev/md1 /arquivos
mount -l | grep /arquivos
cd /arquivos
mkdir -v teste{1..9}
touch teste{1..9}.txt
ls -lha
cd /
umount /arquivos
mount -l | grep /arquivos

# Montando o disco de BACKUP manualmente com o comando mount
# opção do comando mkdir: -v (verbose)
# opção do comando mount: -v (verbose), -l (list)
# opção do bloco de agrupamento {}: (Agrupa comandos em um bloco)
# opções do comando ls: -l (long listing), -h (--human-readable), -a (--all)
# opção do redirecionamento |: (Conecta a saída padrão com a entrada padrão de outro comando)
# Material de apoio: https://www.guiafoca.org/guiaonline/iniciante/ch04s05.html
mkdir -v /backup
mount -v /dev/sdd1 /backup
mount -l | grep /backup
cd /backup
mkdir -v teste{1..9}
touch teste{1..9}.txt
ls -lha
cd /
umount /backup
mount -l | grep /backup

# Configurando o ponto de montagem automático do Array do RAID-1 e do Backup no arquivo Fstab
# Material de apoio: https://www.guiafoca.org/guiaonline/intermediario/ch05s13.html#disc-fstab
cp -v /etc/fstab /etc/fstab.bkp
vim /etc/fstab
	#File System: partição do HD, o CD-ROM, disquete, pendrive ou pasta de rede a serem montados no boot
	#Mount Point: local onde serão montadas as partições, dispositivos e pastas compartilhadas da rede
	#Type: sistema de aquivos utilizado, mais comuns são: swap, ext4, ReiserFS, XFS, JFS, VFAT, NTFS, etc
	#Options: regras de montagem, permissão para cada ponto de montagem: defaults aplica as regras padrão
	#Dump: opção de backup da partição onde: 0 está desativado e 1 está ativo
	#Pass: opção de verificação da partição onde: 0 não verifica, 1 verificação / "raiz", 2 outra partições
	#<file system>	<mount point>	<type>	<options>	<dump>	<pass>
	/dev/md1		/arquivos   	ext4	defaults	   0	   2
	/dev/sdd1		/backup			ext4	defaults	   0	   2

# Atualizando o initramfs (sistema de arquivos raiz, res)
# Opção do comando update-initramfs: -u (update)
update-initramfs -u

# Reinicializar o Servidor para testar a montagem do Array do RAID-1 e a Partição de Backup
reboot
ls -lha /arquivos
ls -lha /backup