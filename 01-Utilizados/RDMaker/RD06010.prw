#include 'protheus.ch'
#include 'topconn.ch'
/*/
===============================================================================================================================
Programa----------: RD06010
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 05/11/2019
===============================================================================================================================
Descrição---------: Este programa serve para gerar os bordero com opcao de enviar ou nao por email
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
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
user function RD06010(cFuncao, pDanfe, pBoleta, pViewPDF)

	local	aArea		as object,;
			aAreaSC5	as object,;
			aAreaSF2	as object,;
			aAreaSL1	as object,;
			cLocal		as char

	local	aTitulo		as array,;
			aItem		as array,;
			lRet		as logical,;
			cSerie		as char,;
			cNota		as char,;
			cCliente	as char,;
			cLoja		as char,;
			cParcela	as char
			
	private	lDanfe		as logical,;
			lBolet		as logical,;
			lViewPDF	as logical


	default pViewPDF	:= .T.

	aArea		:= getArea()
	aAreaSC5	:= SC5->(getArea())
	aAreaSF2	:= SF2->(getArea())
	aAreaSL1	:= SL1->(getArea())
	cLocal		:= alltrim(getmv('MV_XLOCAL'))
			
	aTitulo		:= {}
	aItem		:= {}
	lRet		:= .F.
	cSerie		:= ''
	cNota		:= ''
	cCliente	:= ''
	cLoja		:= ''
	cParcela	:= ''
			
	lDanfe		:= pDanfe
	lBolet		:= pBoleta
	lViewPDF	:= pViewPDF

	if cFuncao $ 'MATA410|LOJA701|MATA461'
		
		aItem		:= {}
		cSerie		:= SC5->C5_SERIE
		cNota		:= SC5->C5_NOTA
		cCliente	:= SC5->C5_CLIENTE
		cLoja		:= SC5->C5_LOJACLI
		cParcela	:= ''
		
		dbSelectArea('SL1')
		SL1->(dbSetOrder(2))
		SL1->(dbGoTop())
		SL1->(dbSeek(xFilial('SL1')+SC5->C5_SERIE+SC5->C5_NOTA))

		aadd(aItem,xFilial('SE1'))
		aadd(aItem,cSerie)
		aadd(aItem,cNota)
		aadd(aItem,cCliente)
		aadd(aItem,cLoja)
		aadd(aItem,'N')			//Impresso Bordero
		aadd(aItem,'N')			//Impresso Boleto
		aadd(aItem,cSerie)		//Incluido serie por Fabricio Antunes
		aadd(aitem,cParcela)
		aadd(aTitulo,aItem)
		
		lRet	:= .T.
					
	elseif cFuncao == "FINA740"

		cSerie		:= SE1->E1_PREFIXO
		cNota		:= SE1->E1_NUM
		cCliente	:= SE1->E1_CLIENTE
		cLoja		:= SE1->E1_LOJA
		cParcela	:= SE1->E1_PARCELA
		
		aadd(aItem,xFilial('SE1'))
		aadd(aItem,cSerie)
		aadd(aItem,cNota)
		aadd(aItem,cCliente)
		aadd(aItem,cLoja)
		aadd(aItem,'N')			//Impresso Bordero
		aadd(aItem,'N')			//Impresso Boleto
		aadd(aItem,cSerie)
		aadd(aitem,cParcela)
		aadd(aTitulo,aItem)
		
		lRet	:= .T.

	else
		lRet	:= .F.
		u_msgErro('Programa '+alltrim(FunName())+' não previsto para usar este RDMAKE.'+CRLF;
				+'Favor informe ao administrador do sistema.'+CRLF;
				+'Essa ação será ABORTADA.')
				
	endif
	
	if lRet	
		U_RD06007(cFuncao,aTitulo)
	endif

	restArea(aAreaSL1)
	restArea(aAreaSF2)
	restArea(aAreaSC5)
	restArea(aArea)
	
return
