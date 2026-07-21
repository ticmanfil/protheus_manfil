/*/
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
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'rwmake.ch'

/*/
===============================================================================================================================
Programa----------: MTA416PV
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 08/06/2017
===============================================================================================================================
Descrição---------: Este programa serve para preencher com campos adcionais na efetivação do pedido de venda
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
===============================================================================================================================
/*/

user function MTA416PV()

	local	nX			as numeric,;
			nLocal		as caractere,;
			nPosQtdLib	as numeric

	Local	nComis		as numeric,;
			cCliente	as caractere,;
			mObs		as memo

	nX			:= 0
	nLocal		:= alltrim(getmv('MV_XLOCAL'))
	nPosQtdLib	:= 0
	nComis		:= posicione('SA3',1,xFilial('SA3')+SCJ->CJ_XVEND,'A3_COMIS')
	cCliente	:= posicione('SA1',1,xFilial('SA1')+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,'A1_NOME')
	mObs		:= SCJ->CJ_XSEQ
	mObs		:= mObs+CRLF+'==='
	mObs		:= mObs+CRLF+SCJ->CJ_XOBS

	M->C5_TIPO		:= 'N'
	M->C5_XCLIENT	:= cCliente
	M->C5_XNOMCON	:= SCJ->CJ_XNOMCLI
	M->C5_TIPOCLI	:= SCJ->CJ_TIPOCLI
	M->C5_TABELA	:= SCJ->CJ_TABELA
	M->C5_VEND1		:= SCJ->CJ_XVEND
	M->C5_XNVEND1	:= SCJ->CJ_XNOMVEN
	M->C5_COMIS1	:= nComis
	M->C5_XDESCON	:= SCJ->CJ_XDESCON
	M->C5_TPFRETE	:= SCJ->CJ_TPFRETE
	M->C5_FRETE		:= SCJ->CJ_FRETE
	M->C5_TPLIB		:= SCJ->CJ_TIPLIB
	M->C5_TPCARGA	:= SCJ->CJ_TPCARGA
	M->C5_DESCONT	:= SCJ->CJ_DESCONT
	M->C5_XNUMORC	:= SCJ->CJ_NUM
	M->C5_XOBS		:= mObs
	M->C5_XVIAS		:= alltrim(cQtdVias)
	M->C5_FLENT		:= alltrim(cTipoEnt)
	M->C5_XVLTOT	:= SCJ->CJ_XVLTOT

	if alltrim(cTipoEnt) == 'A'
		M->C5_XENDE		:= ',ALMOXARIFADO - '+alltrim(cEndEnt)
		M->C5_TPCARGA	:= '2'

	elseif alltrim(cTipoEnt) == 'E'
		M->C5_XESTE		:= alltrim(cUFEnt)
		M->C5_XCDMUNE	:= alltrim(cCodMunEnt)
		M->C5_XMUNE		:= alltrim(cMunEnt)
		M->C5_XENDE		:= alltrim(cEndEnt)
		M->C5_TPCARGA	:= '1'
	
	elseif alltrim(cTipoEnt) == 'R'
		M->C5_XENDE		:= 'RETIRA - '+alltrim(cEndEnt)
		M->C5_TPCARGA	:= '2'
	
	endif

	if len(aCAdm)>0
		M->C5_XADM		:= cCAdm
		M->C5_XDADM		:= posicione('SAE',1,xFilial('SAE')+cCAdm,'AE_DESC')
	endif

	for nX :=1 TO len(_aCols)                                            
//		nPosOrc		:= aScan( aHeadC6, { |x| Alltrim(x[2])=="C6_NUMORC" } )
//		nPosCCusto	:= aScan( aHeadC6, { |x| Alltrim(x[2])=="C6_CCUSTO" } )
		nPosQtdLib	:= aScan( aHeadC6, { |x| Alltrim(x[2])=="C6_XPEM2" } )
		_aCols[nX][nPosQtdLib]	:= SCK->CK_XPEM2
	next
	aColsC6:=_aCols

return
