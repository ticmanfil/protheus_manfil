#include 'protheus.ch'
#include 'topconn.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: RD06010
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 29/08/2024
===============================================================================================================================
Descrição---------: Este programa serve para LIQUIDAR PEDIDOS DE VENDAS com boletos
===============================================================================================================================
Uso---------------: FINANCEIRO
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
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
user function RD06011(aTitOri,aTitGer)

	//variaveis da liquidacao
	local	cCond		as char,;
			cNaturez	as char,;
			cLiqTipo	as char,;
			cLiqCli		as char,;
			cLiqLoja	as char,;
			nMoeda		as numeric,;
			lAutoPix	as logical,;
			lRet		as logical

	//variaveis de apoio
	local	nX		as numeric,;
			aCab	as array,;
			aItens	as array,;
			cFilSQL	as char,;		//filtro quem conterá os títulos que serão liquidados, gerado com base no array aTitOri
			cQry	as char

    Private lMsErroAuto     := .F.
    Private lAutoErrNoFile  := .T.

	//preencher as variaveis da liquidacao
	cCond		:= ''
	cNaturez	:= '0101002'
	cLiqTipo	:= 'BOL'
	cLiqCli		:= aTitGer[1][6]
	cLiqLoja	:= aTitGer[1][7]
	nMoeda		:= 1
	lAutoPix	:= .F.
	lRet		:= .F.
     
	aItens:= {}
	for nX:= 1 to len(aTitGer)
		aadd(aItens,{{'E1_PREFIXO',aTitGer[nX][2]},{'E1_NUM',aTitGer[nX][3]},{'E1_PARCELA',aTitGer[nX][4]},{'E1_VENCTO',aTitGer[nX][8]},{'E1_VLCRUZ',aTitGer[nX][9]}})
		//Aadd(aItens,{{"E1_PREFIXO",cLiqPref}, {'E1_NUM', cLiqNum}, {'E1_PARCELA', cLiqParcela}, {'E1_VENCTO', dDatabase}, {'E1_VLCRUZ', nLiqVal}}) 
	next nX
  
    cFilSQL := " ("
    For nX := 1 To Len(aTitOri)
        If nX > 1
            cFilSQL += " OR "
        EndIf
        cFilSQL += " ("
        cFilSQL += " E1_FILIAL  = '" + aTitOri[nX][1] + "' AND "
        cFilSQL += " E1_PREFIXO = '" + aTitOri[nX][2] + "' AND E1_NUM  = '" + aTitOri[nX][3] + "' AND "
        cFilSQL += " E1_PARCELA = '" + aTitOri[nX][4] + "' AND E1_TIPO = '" + aTitOri[nX][5] + "' AND "
        cFilSQL += " E1_CLIENTE = '" + aTitOri[nX][6] + "' AND E1_LOJA = '" + aTitOri[nX][7] + "' )"   
    Next nX
    cFilSQL += ") AND E1_SITUACA IN ('0','F','G') AND E1_SALDO > 0 AND LTRIM(E1_NUMLIQ) = '' "
 
    aCab := {}
    aadd(aCab, {"cCondicao",    cCond}) 	//Condição de pagamento
    aadd(aCab, {"cNatureza",    cNaturez}) 	//Natureza
    aadd(aCab, {"E1_TIPO",      cLiqTipo}) 	//Tipo
    aadd(aCab, {"cCliente",     cLiqCli}) 	//Cliente
    aadd(aCab, {"cLoja",        cLiqLoja}) 	//Loja
    aadd(aCab, {"nMoeda",       nMoeda}) 	//Moeda
    aadd(aCab, {"AUTMRKPIX",    lAutoPix}) 	//Pix
 
    lRet:= Fina460(/*nPosArotina*/,aCab,aItens,3,/*cFiltroADVPL*/,/*xNumLiq*/,/*xRotAutoVa*/,/*xOutMoe*/,/*xTxNeg*/,/*xTpTaxa*/,/*xFunOrig*/,/*xTxCalJur*/,cFilSQL)

return lRet
