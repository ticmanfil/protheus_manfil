#include 'protheus.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: MT410CPY  
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 29/09/2025
===============================================================================================================================
Descrição---------: Este programa serve para fazer as tratativas ao copiar um pedido de venda
===============================================================================================================================
Uso---------------: MATA410 - PEDIDO DE VENDA
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------:
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
=====================================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor	|	Data	|										Motivo																
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|           | 																										
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			|																											
=====================================================================================================================================
/*/

user function MT410CPY()

	local	nPosPRODUTO	as numeric,;
			nPosQTDVEN	as numeric,;
			nPosPRUNIT	as numeric,;
			nPosPRCVEN	as numeric,;
			nPosDESCONT	as numeric,;
			nPosVALDESC	as numeric,;
			nPosVALOR	as numeric

	local	cTabela		as caractere

/*
			nX			as numeric,;
			cPRODUTO	as caractere,;
			nQTDVEN		as numeric,;
			nPRUNIT		as numeric,;
			nPRCVEN		as numeric,;
			nDesc		as numeric,;
			nValDesc	as numeric,;
			nValor		as numeric
*/
	cTabela			:= M->C5_TABELA
	nPosPRODUTO		:= gdFieldPos('C6_PRODUTO')
	nPosQTDVEN		:= gdFieldPos('C6_QTDVEN')
	nPosPRUNIT		:= gdFieldPos('C6_PRUNIT')
	nPosPRCVEN		:= gdFieldPos('C6_PRCVEN')
	nPosDESCONT		:= gdFieldPos('C6_DESCONT')
	nPosVALDESC		:= gdFieldPos('C6_VALDESC')
	nPosVALOR		:= gdFieldPos('C6_VALOR')

	M->C5_XDESCON	:= posicione('SE4',1,fwxFilial('SE4')+M->C5_CONDPAG,'E4_DESCRI')
	M->C5_XNUMORC	:= ''
	M->C5_XIMP   	:= 'N'
	M->C5_XUSERIM	:= ''
	M->C5_DTIMP  	:= stod('')
	M->C5_HRIMP  	:= ''
	M->C5_XUSRLIB	:= ''
	M->C5_XDTLIBC	:= stod('')
	M->C5_XHRLIBC	:= ''
	M->C5_DESCONT	:= 0
	M->C5_FRETE		:= 0
	M->C5_XDTVAL 	:= daysum(ddatabase,getmv('MV_XVALORC'))

	if M->C5_CONDPAG == '999'
		M->C5_DATA1:= iif(M->C5_DATA1<DDATABASE,DDATABASE,M->C5_DATA1)
		M->C5_DATA2:= iif(M->C5_DATA2<DDATABASE,DDATABASE,M->C5_DATA2)
		M->C5_DATA3:= iif(M->C5_DATA3<DDATABASE,DDATABASE,M->C5_DATA3)
		M->C5_DATA4:= iif(M->C5_DATA4<DDATABASE,DDATABASE,M->C5_DATA4)
	endif

/*	for nX:= 1 to len(aCols)
		cPRODUTO	:= aCols[nX][nPosPRODUTO]
		nQTDVEN		:= aCols[nX][nPosQTDVEN]
		nPRUNIT		:= posicione('DA1',1,fwXFilial('DA1')+cTabela+cPRODUTO,'DA1_PRCVEN')
		nPRCVEN		:= nPRUNIT
		nDesc		:= 0
		nValDesc	:= 0
		nValor		:= nQTDVEN * nPRUNIT

		aCols[nX][nPosPRUNIT]	:= nPRUNIT
		aCols[nX][nPosPRCVEN]	:= nPRCVEN
		aCols[nX][nPosDESCONT]	:= nDesc
		aCols[nX][nPosVALDESC]	:= nValDesc
		aCols[nX][nPosVALOR]	:= nValor
	next nX
*/	
return
