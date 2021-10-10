#!/bin/bash
#Autor: Robson Vaamonde
#Site: www.procedimentosemti.com.br
#Facebook: facebook.com/ProcedimentosEmTI
#Facebook: facebook.com/BoraParaPratica
#YouTube: youtube.com/BoraParaPratica
#Data de criação: 13/02/2019
#Data de atualização: 22/07/2020
#Versão: 0.03

#Criação das variáveis locais utilizada nesse script
USUARIO="Vaamonde"
USUARIOS=$(who | awk '{print $1}')
TESTE01=$(test A == B ; echo $?)
TESTE02=$(test -f /etc/passwd ; echo $?)

#Utilizando o comando echo para imprimir na tela os valores das variáveis locais
#e variáveis especiais do Shell
echo "Impressão na tela.............: Olá Mundo!!!"
echo "Nome do usuário...............: $USUARIO"
echo "Nome do arquivo shell.........: $0"
echo "Quantidade de parâmetros......: $#"
echo "Todos os parâmetros...........: $*"
echo "Parâmetro 01..................: $1"
echo "Parâmetro 02..................: $2"
echo "Status do comando anterior....: $?"
echo "PID do processo...............: $$"
echo "Usuário logado................: $USUARIOS"
echo "Comando: test A == B..........: $TESTE01"
echo "Comando: test -f /etc/passwd..: $TESTE02"

#Utilizando o comando if para fazer os testes lógicos
if [ $USUARIO == root ];
then
	echo "Teste de usuário..............: Usuário é root."
else
	echo "Teste de usuário..............: Usuário não é root"
fi

#Utilizando o comando if encadeado para aumentar os testes lógicos
if [ $TESTE01 -eq 0 ];
then
	echo "Resultado do comando test é...: VERDADEIRO"
elif [ $TESTE01 -eq 1 ];
then
	echo "Resultado do comando test é...: FALSO"
else
	echo "Resultado do comando test é...: NÃO IDENTIFICADO"
fi

#Utilizando o comando case para fazer os testes lógicos
case $TESTE01 in
	0) echo "Resultado do comando case é...: 0 - VERDADEIRO";;
	1) echo "Resultado do comando case é...: 1 - FALSO";;
	*) echo "Resultado do comando case é...: NÃO IDENTIFICADO"
esac

#Utilizando o comando read para receber os valores e fazer o teste lógico com case
read -p "Digite as letras: A, B ou C...: " LETRAS;
case $LETRAS in
	A|a) echo "A letra digita foi............: $LETRAS";;
	B|b) echo "A letra digita foi............: $LETRAS";;
	C|c) echo "A letra digita foi............: $LETRAS";;
	*) echo "Letra digitada incorretamente.: $LETRAS"
esac

#Utilizando o laço de loop for para verificar os números digitados junto com o comando read
read -p "Uma sequência de números......: " NUMEROS;
for VALORES in $NUMEROS;
do
	echo "Valores passado para o Loop...: $VALORES"
done

#Utilizando o laço de loop for para gerar uma tabuada junto com o comando read
read -p "Digite um número da tabuada...: " NUMERO;
for TABUADA in $(seq 0 10);
do
	echo "$NUMERO x $TABUADA...: $(($TABUADA * $NUMERO))"
done

#Utilizando o laço de loop while para alcançar os valores desejados junto com o comando read e let
read -p "Digite um número de início....: " INICIO;
read -p "Digite um número da fim.......: " FIM;
while [ $INICIO -le $FIM ];
do
	echo "Valor de sequência numérica...: $INICIO"
	let INICIO=INICIO+1
done
