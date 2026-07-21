#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Topconn.ch"
/*/
===============================================================================================================================
Programa----------: M410STTS 
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 18/06/2019
===============================================================================================================================
Descrição---------: Este programa serve para integrar o os pedidos vendas ao orcamento do cupom fiscal
===============================================================================================================================
Uso---------------: MATA410 - PEDIDO DE VENDA
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: .T. ou .F.
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

/*

3 - Inclusão
4 - Alteração
5 - Exclusão
6 - Cópia
7 - Devolução de Compras


*/

User Function M410STTS()

	Local 	_nOper 		:= PARAMIXB[1],;
			cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))

	if cAmbiente == '2'
		if _nOper == 3 .or.  _nOper == 4 .or. _nOper == 6
		 
			if SC5->C5_XLOJA=="S"
				XLOJA701()
			else
				valPedido("E")
			endif
			 
		elseif  _nOper== 5 //Exclusao
			if SC5->C5_XLOJA=="S"
				valPedido("E")
			 EndIf
		EndIf
	endif

return nil


Static Function XLOJA701()

	Local 	_aCab 		:= {},;	 	//Array do Cabeçalho do Orçamento
			_aItem		:= {},; 	//Array dos Itens do Orçamento
			_aParcelas	:= {},; 	//Array das Parcelas do Orçamento
			cMsgErro 	:= "",;
			_cVendedor 	:= "",; 	//Codigo do Vendedor
			_cCodCli	:= "",; 	//Codigo do Cliente
			_cCodLoja	:= "",; 	//Codigo da Loja do Cliente
			nTamProd 	:= 0,;
			nTamUM 		:= 0,;
			nTamTabela 	:= 0,;
			aParc,;
			nVlTotal	:= U_UVlOrc(SC5->C5_NUM,'P'),;
			xi			:= 0,;
			_nDescont   := 0,;
			_nAcresci   := 0,;
			_cCondPag	:= "",;
			_cFormPag	:= "",;
			cForm		:= '[M410STTS] - PE Salvar Pedido de Venda'
			
	//Local aSL1area:=SL1->(getArea())
	//Local aSL2area:=SL2->(getArea())

	private	lMsHelpAuto := .T.,; 	//Variavel de controle interno do ExecAuto
			lMsErroAuto := .F.,; 	//Variavel que informa a ocorrência de erros no ExecAuto
			INCLUI 		:= .T.,; 	//Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
			ALTERA 		:= .F. 		//Variavel necessária para o ExecAuto identificar que se trata de uma inclusão


	//Indica inclusão
	lMsHelpAuto := .T.
	lMsErroAuto := .F.

	_cVendedor 	:= SC5->C5_VEND1 	//Codigo do Vendedor
	_cCodCli 	:= SC5->C5_CLIENTE	//Codigo do Cliente
	_cCodLoja 	:= SC5->C5_LOJACLI	//Codigo da Loja do Cliente

	//Retorna o tamanho dos campos
	nTamProd 	:= TamSX3("LR_PRODUTO")[1]
	nTamUM 		:= TamSX3("LR_UM")[1]
	nTamTabela 	:= TamSX3("LR_TABELA")[1]

	//Acerta o tamanho do codigo o Vendedor
	_cVendedor := PadR(_cVendedor,TamSX3("A3_COD")[1])

	//Verifica se o pedido já está integrado
	
	BEGIN TRANSACTION
	
	IF ! valPedido("I") //Se retorno for falso cancela a operacao
		 DisarmTransaction()
		return
	EndIf

	//BEGINTRAN() 
	
	dbSelectArea("SE4")
	SE4->(dbSetOrder(1))
	SE4->(dbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
	
	if SE4->E4_TIPO=="9"
		//_cCondPag:='CN '
		//_cFormPag:='"F'
	Else
		_cCondPag:=SC5->C5_CONDPAG
		_cFormPag:=SE4->E4_FORMA
	EndIf
	
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	SA1->(MsSeek(xFilial("SA1")+_cCodCli+_cCodLoja))

	//***********************************
	// Monta cabeçalho do orçamento (SLQ)
	//***********************************
	aadd( _aCab, {"LQ_VEND"		, _cVendedor 		, NIL} )
	aadd( _aCab, {"LQ_COMIS"	, SC5->C5_COMIS1 	, NIL} )				//ver com analista se nao vai impactar as comissoes -> nao seria a porcentagem de comissao do vendedor aqui
	aadd( _aCab, {"LQ_CLIENTE" 	, SA1->A1_COD 		, NIL} )
	aadd( _aCab, {"LQ_LOJA" 	, SA1->A1_LOJA 		, NIL} )
	aadd( _aCab, {"LQ_TIPOCLI" 	, SA1->A1_TIPO 		, NIL} )
	aadd( _aCab, {"LQ_DESCONT" 	, SC5->C5_DESCONT	, NIL} )
	aadd( _aCab, {"LQ_DTLIM" 	, dDatabase 		, NIL} )
	aadd( _aCab, {"LQ_EMISSAO" 	, dDatabase 		, NIL} )
	aadd( _aCab, {"LQ_CONDPG" 	, _cCondPag     	, NIL} )
	aadd( _aCab, {"LQ_FORMPG" 	, _cFormPag	    	, NIL} )
	aadd( _aCab, {"LQ_NUMMOV" 	, "01" 				, NIL} )
	aadd( _aCab, {"LQ_XPEDIDO" 	, SC5->C5_NUM 		, NIL} )
	
	//aAdd( _aCab, {"AUTRESERVA" , "000001" , NIL} ) //Codigo da Loja (Campo SLJ->LJ_CODIGO) que deseja efetuar a reserva quando existir item(s) que for do tipo entrega (LR_ENTREGA = 3)

	//***********************************
	// Monta Itens do orçamento (SLR)
	//***********************************
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial('SC6')+SC5->C5_NUM))
	while !EOF() .and. SC6->C6_NUM == SC5->C5_NUM
	
		/*dbSelectArea("DA1")
		DA1->(dbSetOrder(1))//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
		IF DA1->(dbSeek(xFilial("DA1")+GETMV("MV_TABPAD")+PadR(SC6->C6_PRODUTO,nTamProd)))
			if SC6->C6_PRUNIT < DA1->DA1_PRCVEN //Grava o desconto
				_nDescont:= Round(DA1->DA1_PRCVEN - SC6->C6_PRUNIT,2)
			ElseIf SC6->C6_PRUNIT > DA1->DA1_PRCVEN //Grava o Acrescimo
				_nAcresci:= Round(SC6->C6_PRUNIT -  DA1->DA1_PRCVEN,2) 
			EndIf
			
		EndIf */

		dbSelectArea("SB0")
		SB0->(dbSetOrder(1))//B0_FILIAL+B0_COD  
		IF SB0->(dbSeek(xFilial("SB0")+PadR(SC6->C6_PRODUTO,nTamProd)))
			IF SC6->C6_PRUNIT != SB0->B0_PRV1
			
				RecLock("SB0", .F.) //Altera
				SB0->B0_PRV1 := SC6->C6_PRUNIT 
				MsUnLock()
			
			EndIf
			
		Else
		
			RecLock("SB0", .T.) //Inclui
			SB0->B0_FILIAL := xFilial("SB0")
			SB0->B0_COD    := PadR(SC6->C6_PRODUTO,nTamProd)
			SB0->B0_PRV1   := SC6->C6_PRUNIT 
			MsUnLock()
	
		EndiF
		
		aadd( _aItem, {} )
		aadd( _aItem[Len(_aItem)], {"LR_PRODUTO"	, PadR(SC6->C6_PRODUTO,nTamProd) 	, NIL} )
		aadd( _aItem[Len(_aItem)], {"LR_DESCRI"		, SC6->C6_DESCRI 				 	, NIL} )
		aadd( _aItem[Len(_aItem)], {"LR_LOCAL"		, SC6->C6_LOCAL					 	, NIL} )
		aadd( _aItem[Len(_aItem)], {"LR_QUANT" 		, SC6->C6_QTDVEN 					, NIL} )
		aadd( _aItem[Len(_aItem)], {"LR_UM" 		, PadR(SC6->C6_UM,nTamUM) 			, NIL} )
		aadd( _aItem[Len(_aItem)], {"LR_VRUNIT" 	, SC6->C6_PRUNIT 					, NIL} )
		aadd( _aItem[Len(_aItem)], {"LR_VLRITEM" 	, SC6->C6_VALOR 					, NIL} )
		aadd( _aItem[Len(_aItem)], {"LR_DESC" 		, Round(_nDescont*100/SC6->C6_PRUNIT,2)     	, NIL} )
		aadd( _aItem[Len(_aItem)], {"LR_VALDESC"	, _nDescont     					, NIL} )
		aadd( _aItem[Len(_aItem)], {"LR_VALACRS" 	, _nAcresci     					, NIL} )
		aadd( _aItem[Len(_aItem)], {"LR_VEND" 		, _cVendedor 						, NIL} )
		//aadd( _aItem[Len(_aItem)], {"LR_TABELA" 	, GETMV("MV_TABPAD") 				, NIL} )
		SC6->(dbSkip())
	enddo

	//************************************************
	// Monta o Pagamento do orçamento (aPagtos) (SL4)
	//************************************************
	if SE4->E4_TIPO=="9"
		
		if SC5->C5_PARC1 > 0
			aadd( _aParcelas, {} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_DATA"		, SC5->C5_DATA1	, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_VALOR"		, SC5->C5_PARC1	, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_FORMA"		, "FI"          , NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_ADMINIS" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_NUMCART" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_FORMAID" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_MOEDA" 		, 1 			, NIL} )
		EndIf
		if SC5->C5_PARC2 > 0
			aadd( _aParcelas, {} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_DATA"		, SC5->C5_DATA2	, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_VALOR"		, SC5->C5_PARC2	, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_FORMA"		, "FI"      	, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_ADMINIS" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_NUMCART" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_FORMAID" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_MOEDA" 		, 1 			, NIL} )
		EndIf
		if SC5->C5_PARC3 > 0
			aadd( _aParcelas, {} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_DATA"		, SC5->C5_DATA3	, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_VALOR"		, SC5->C5_PARC3	, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_FORMA"		, "FI"         	, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_ADMINIS" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_NUMCART" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_FORMAID" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_MOEDA" 		, 1 			, NIL} )
		EndIf
		if SC5->C5_PARC4 > 0
			aadd( _aParcelas, {} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_DATA"		, SC5->C5_DATA4	, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_VALOR"		, SC5->C5_PARC4	, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_FORMA"		, "FI" 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_ADMINIS" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_NUMCART" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_FORMAID" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_MOEDA" 		, 1 			, NIL} )
		EndIf
	Else
		//aParc	:= CONDICAO( nVlTotal ,SC5->C5_CONDPAG, , dDatabase)
		aParc	:= CONDICAO( nVlTotal ,_cCondPag, , dDatabase)
		for xi := 1 to len(aParc)
			aadd( _aParcelas, {} )
				
			aadd( _aParcelas[Len(_aParcelas)], {"L4_DATA"		, aParc[xi,1]	, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_VALOR"		, aParc[xi,2]	, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_FORMA"		, _cFormPag		, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_ADMINIS" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_NUMCART" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_FORMAID" 	, " " 			, NIL} )
			aadd( _aParcelas[Len(_aParcelas)], {"L4_MOEDA" 		, 1 			, NIL} )
		next xi
	EndIf
	
	
	SetFunName("LOJA701")
	
	MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},_aCab,_aItem ,_aParcelas)

	if lMsErroAuto
		cMsgErro := MostraErro()
		DisarmTransaction()
		
		RecLock("SC5", .F.)	
			SC5->C5_XLOJA := "N"
		MsUnLock() 
			
		//_msgErro(cMsgErro,cForm)
		MsgStop(cMsgErro,cForm)
		DisarmTransaction()
	else
	//	u_msgInforma("Pedido importado com sucesso. Favor finalizar a venda na rotina Venda Assistida!",cForm)
		MsgInfo("Pedido importado com sucesso. Favor finalizar a venda na rotina Venda Assistida!",cForm)
	endif
	
	//EndTran() 
	
	//SL1->(RestArea(aSL1area))
	//SL2->(RestArea(aSL2area))
	END TRANSACTION
return

Static Function valPedido(_cflag)
	
	Local _aArea := getArea()
	Local _lRet  := .T.
	Local cForm	 := '[M410STTS] - PE Salvar Pedido de Venda'
	
	
	Local 	_aCab 		:= {},;	 	//Array do Cabeçalho do Orçamento
			_aItem		:= {},; 	//Array dos Itens do Orçamento
			_aParcelas	:= {} 	//Array das Parcelas do Orçamento
	
	private	lMsHelpAuto := .T.,; 	//Variavel de controle interno do ExecAuto
		lMsErroAuto := .F.,; 	//Variavel que informa a ocorrência de erros no ExecAuto
		INCLUI 		:= .F.,; 	//Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
		ALTERA 		:= .F. 		//Variavel necessária para o ExecAuto identificar que se trata de uma inclusão


	//Indica inclusãoD
	lMsHelpAuto := .T.
	lMsErroAuto := .F.
	
	IF Select("TMPSL1") >1
		TMPSL1->(dbCloseArea())
	EndIf
	
	BEGIN TRANSACTION
	
	_cQuery:= "	SELECT L1_FILIAL, L1_XPEDIDO, L1_NUM, L1_DOC, L1_SERIE,L1_SITUA, R_E_C_N_O_ AS RECNUM FROM "+RetSqlName("SL1")+" WHERE D_E_L_E_T_='' AND  L1_FILIAL='"+xFilial("SL1")+"' AND L1_XPEDIDO='"+SC5->C5_NUM+"' AND L1_MSBLQL<>'1' " 
					
	TcQuery _cQuery New Alias "TMPSL1"
	_status:= ""
	if ! TMPSL1->(EOF())
		if ! Empty(TMPSL1->L1_DOC)//Nota já foi gerada
			
			//Não permite integração de pedido já integrado caso a venda tenha sido efetuada ou o cancelamento se encontra em processamento
			
			if TMPSL1->L1_SITUA=="OK"  
				_status:= "Status: Venda Finalizada"
				_lRet  := .F.	
			ElseIf TMPSL1->L1_SITUA=="X0"
				_status:= "Status: Cancelamento não enviado ao TSS"
				_lRet  := .F.	
			ElseIf TMPSL1->L1_SITUA=="X1"
				_status:= "Status: Cancelamento aguarda autorização SEFAZ"
				_lRet  := .F.	
			ElseIf TMPSL1->L1_SITUA=="X3"
				_status:= " Status: Cancelamento não autorizado pelo SEFAZ"
				_lRet  := .F.	
			EndIf
			
			if ! _lRet  
				  //u_msgInforma("Pedido "+SC5->C5_NUM+" já está integrqado ao SIGALOJA e não pode ser integrado novamente! Nota/Serie:"+TMPSL1->L1_DOC+"/"+ TMPSL1->L1_SERIE+" Status: Cancelamento não autorizado pelo SEFAZ.",cForm)
				  	if _cflag=="I"
				  		MsgAlert( "Pedido "+SC5->C5_NUM+" já está integrqado ao SIGALOJA e não pode ser integrado novamente! Nota/Serie:"+TMPSL1->L1_DOC+"/"+ TMPSL1->L1_SERIE+" Status: Cancelamento não autorizado pelo SEFAZ.", cForm )
				  	ElseIf	_cflag=="E"
				  		MsgAlert( "Pedido "+SC5->C5_NUM+" já está integrqado ao SIGALOJA e não pode ser excluido! Nota/Serie:"+TMPSL1->L1_DOC+"/"+ TMPSL1->L1_SERIE+" Status: Cancelamento não autorizado pelo SEFAZ.", cForm )
				  	EndIf
				  	 DisarmTransaction()
				  return .F.
			EndIf		
			//SL1->(RestArea(aSL1area))
			//SL2->(RestArea(aSL2area))
			
			
		Else
			If EMPTY(TMPSL1->L1_SITUA) //Exclui o orçamento atual e gera um novo
				
				 dbSelectArea("SL1")
				 dbSetOrder(1)
				 IF dbSeek(xFilial("SL1")+TMPSL1->L1_NUM)
				 
				 	  RecLock("SL1", .F.)		
					  SL1->L1_MSBLQL  := "1"		
					  MsUnLock() //Confirma e finaliza a operação
				 	  
				     
				 EndIf
				
			Endif
			
		EndIf
		
	EndIf 
	RestArea(_aArea)
	
	END TRANSACTION
Return _lRet
