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

	local	aArea		:= getArea(),;
			aAreaSC5	:= SC5->(getArea()),;
			aAreaSF2	:= SF2->(getArea()),;
			aAreaSL1	:= SL1->(getArea())
			
	local	aTitulo		:= {},;
			aItem		:= {},;
			lRet		:= .F.,;
			cSerie		:= '',;
			cNota		:= '',;
			cCliente	:= '',;
			cLoja		:= '',;
			cParcela	:= ''
			
	private	lDanfe		:= pDanfe,;
			lBolet		:= pBoleta,;
			lViewPDF	:= pViewPDF

	default pViewPDF	:= .T.


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
		aadd(aItem,cSerie)		//Incluido serie por Fabricio Antunes
		aadd(aitem,cParcela)
		aadd(aTitulo,aItem)
		
		lRet	:= .T.

	else
		lRet	:= .F.
		Alert('Programa '+alltrim(FunName())+' não previsto para usar este RDMAKE.'+chr(10)+chr(13);
				+'Favor informe ao administrador do sistema.'+chr(10)+chr(13);
				+'Essa ação será ABORTADA.')
				
	endif
	
	if lRet	

		/*if MsgYesNo("Deseja enviar por e-mail?")
			
			for nX:=1 to Len(aTitulo)
				U_FATWS001(aTitulo[nX,3],aTitulo[nX,8],aTitulo[nX,4],aTitulo[nX,5],aTitulo[nX,2],aTitulo[nX,9],.F.)
			next nX
			//MSGINFO("E-mail enviado com sucesso")
		
		else
			lViewPDF	:= .T.
			nX			:= Len(aTitulo)

			if lDanfe
				if alltrim(SF2->F2_ESPECIE) $ 'SPED|RPS'
					u_zGerDanfe(aTitulo[nX,3], aTitulo[nX,2], lViewPDF)
				elseif SF2->F2_ESPECIE == 'NFCE'
					LjNfceImp(SL1->L1_FILIAL,SL1->L1_NUM)
				endif
			endif
			
			if lBolet
				U_RD06007(cFuncao,aTitulo,lViewPDF)
			endif
				
		endif
		*/
		U_RD06007(cFuncao,aTitulo)

	endif
	
	restArea(aAreaSL1)
	restArea(aAreaSF2)
	restArea(aAreaSC5)
	restArea(aArea)
	
return
