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
#include "rwmake.ch"
#include "topconn.CH"
#include "tbiconn.CH"
/*/
===============================================================================================================================
Programa----------: MTA440C9
Autor-------------: Tiago Lucio/TOTVS
Data da Criacao---: 12/07/17
===============================================================================================================================
Descrição---------: Ponto de Entrada chamado na liberação do item do pedido de venda.
					1.	Implementa a regra para Pedidos de Venda com condição de pagamento
						com DINHEIRO ou CARTAO valida se o cliente não possui titulos
						em atraso e libera o pedido por credito mesmo que o cliente
						não tenha limite
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Bloqueia ou nao a venda por credito
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGAFAT
===============================================================================================================================
/*/

user function MTA440C9()

	local	aArea		:= FWgetArea(),;
			aSE4		:= SE4->(FWgetArea())

	Local 	cTPCond		as char,;
			cForma		as char,;
			cAmbiente	as char

	cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))

	if cAmbiente == '1' .and. empty(SC6->C6_CONTRAT)
		dbSelectArea('SE4')
		SE4->(dbSetOrder(1))
		SE4->(dbGoTop())
		if (SE4->(dbSeek(xFilial('SE4')+SC5->C5_CONDPAG)))
			cTPCond	:= SE4->E4_XAVISTA
			cForma	:= SE4->E4_FORMA
		endif
		SE4->(dbCloseArea())

		if cTPCond	== 'A' //condição pagto a vista
			//bloqueia se o valor do pedido esta acima do permitido
			if Valor(SC5->C5_NUM,cForma) .and. FunName() <> 'MATA450A'
				if !Alltrim(SC9->C9_BLCRED) $ '01|02|04'  //foi bloqueado por (01-Credito), (02-estoque) ou (04-vencto credito)
					SC9->(a460Estorna()) //Estorna liberação caso houver   
					RecLock("SC6")
					Begin Transaction    
					MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,.F.,.F.,.F.,.T.,.F.,.F.,,,,,,0,)    //Bloqueia somente financeiro sem avalidar o limite de credito do cliente.
					End Transaction
					SC6->(MsUnLock())
					SC6->(MaLiberOk({SC5->C5_NUM},.T.))//atualiza C5_LIBEROK 
				endif
			
			//libera bloqueio se não tiver titulo vencidos 
			elseif TitVencOK(SC5->C5_CLIENTE, SC5->C5_LOJACLI) 
				if Alltrim(SC9->C9_BLCRED)!= ''  //Já foi liberado
					SC9->(a460Estorna()) 		 //Estorna liberação caso houver   
					RecLock("SC6")
					Begin Transaction    
					MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,.T.,.F.,.F.,.T.,.F.,.F.,,,,,,0,)    //Libera somente financeiro sem avalidar o limite de credito do cliente.
					End Transaction
					SC6->(MsUnLock())
					SC6->(MaLiberOk({SC5->C5_NUM},.T.))//atualiza C5_LIBEROK 
				endif
			endif
		endif
	endif
	
	FWrestArea(aSE4)
	FWrestArea(aArea)
return 

/*MaLibDoFat(;
        SC6->(RecNo()),; //nRegSC6
        SC6->C6_QTDVEN,; //nQtdaLib
        ,;               //lCredito
        ,;               //lEstoque
        .T.,;            //lAvCred
        .T.,;            //lAvEst
        .F.,;            //lLibPar
        .F.;             //lTrfLocal
    )
*/

Static Function TitVencOK(_cCliente, _cLoja)

	local	lRet	as logical,;
			cQry	as caractere,;
			nSld	as numeric
  
	lRet	:= .T.
	cQry	:= ''
	nSld	:= 0

	cQry	:= 'exec dbo.PR_MTA440C9 @FILIAL = "'+fwxFilial('SE1')+'", @DTVENCTO = "'+dtos(date())+'", @CLIENTE = "'+_cCliente+'", @LOJA = "'+_cLoja+'"'

	if select('TMPSE1') > 1
		TMPSE1->(dbCloseArea())
	endif

	tcquery cQry new alias 'TMPSE1'

	while !TMPSE1->(eof())
		nSld += TMPSE1->E1_SALDO
		TMPSE1->(dbSkip())
	enddo
	TMPSE1->(dbCloseArea())

	if nSld > 0
		lRet:= .F.
		//	Alert("O cliente "+allTrim(_cCliente)+"/"+allTrim(_cLoja)+" possuie R$ "+TRANSFORM(_nSaldo, "@E 999,999,999.99")+" em titulos atrasados! O pedido será bloqueado por Credito!")
	endif

return lRet


Static Function SRA(_cCliente, _cLoja)
	
	Local _lRet:= .F.
	Local _cQuery:=""    
	Local _chr :=  Chr(13) + Chr(10) 

	_cQuery+="	SELECT A1_XRA  "+_chr

	_cQuery+="		FROM "+RetSqlName("SA1")+" "+_chr

	_cQuery+=" WHERE A1_COD= '"+_cCliente+"'      "+_chr
	_cQuery+="		AND A1_LOJA= '"+_cLoja+"'      "+_chr
	_cQuery+=" 		AND D_E_L_E_T_ =' ' "+_chr     

	_cQuery := ChangeQuery(_cQuery)

	IF SELECT("TMPSA1") > 1
		TMPSA1->(dbCloseArea())
	ENDIF  

							
	TCQUERY _cQuery NEW ALIAS "TMPSA1"   
									
	While  ! TMPSA1->(EOF()) 
		if TMPSA1->A1_XRA == 'T'
			_lRet:= .T.
		else
			_lRet:= .F.
		endif
	
		TMPSA1->(dbSkip())
	End

return _lRet

static function Valor(pNumPed,pForma)
	
	local	lRet	as logical,;
			nVlMin	as numeric,;
			nVlPed	as numeric

	lRet	:= .F.
	nVlMin	:= getMv('MV_XLIBAV')
	nVlPed	:= SC5->C5_XVLTOT

	if nVlPed > nVlMin .and. !alltrim(pForma) $ 'CC|CD'
		lRet:= .T.		// SE O VALOR DO PEDIDO FOR ACIMA DO PERMITIDO O PEDIDO SERÁ BLOQUEADO PELO FINANCEIRO
	endif
	
return lRet
