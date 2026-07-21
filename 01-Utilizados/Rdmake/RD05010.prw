/*/
===============================================================================================================================
Programa----------: RD05010
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 21/02/2020
===============================================================================================================================
Descrição---------: Este programa serve para transformar um pedidos de venda em RESERVAS
===============================================================================================================================
Uso---------------: No orcamentos (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
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


#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'TbiCode.ch'
#include 'rwmake.ch'
#include 'prtopdef.ch'

user function RD05010()
	
	Local 	cNf		:= '',;
	 		cSerie	:= '',;
	 		cNumPed	:= '',;
	 		cNumOrc	:= '',;
	 		cNumCtr	:= ''

	local	aArea		:= getArea(),;
			aAreaSF2	:= SF2->(getArea()),;
			aAreaSD2	:= SD2->(getArea()),;
			aAreaSC5	:= SC5->(getArea()),;
			aAreaSC6	:= SC6->(getArea())
			
	local	_xi	:= 0
			
	private lMsErroAuto     := .F.
	
	private cForm			:= 'RD05010'
	
	//****************************************************************
	//* Abertura do ambiente
	//****************************************************************
	CriaSX1('RD05010') //Cria os parametros
	
	if !Pergunte('RD05010',.T.)   //Chama a tela de parametros
		Return
	EndIf
	
	cNf		:= mv_par01 
	cSerie	:= mv_par02
	
	/*
		1 - Cadastar o Contrato com base no pedido de venda original
		2 - Vincular o contrato gerado ao pedido de venda gerado
		 2.1 - alterar o CONTRAT e ITEMCON para o contrato gerado
		 2.2 - alterar p PEDCOB para o contrato gerado
		 2.3 - alterar o status do contrato para B
		3 - 
	*/
		
	dbSelectArea('SD2')
	SD2->(dbSetOrder(3))
	SD2->(dbGoTop())
	if SD2->(dbSeek(xFilial('SD2')+cNf+cSerie))
		cNumPed	= SD2->D2_PEDIDO
	endif
	SD2->(dbCloseArea())
	
	dbSelectArea('SC5')
	SC5->(dbSetOrder(1))
	SC5->(dbGoTop())
	if SC5->(dbSeek(xFilial('SC5')+cNumPed))
		cNumOrc	= SC5->C5_XNUMORC
	endif
	SC5->(dbCloseArea())
	
	dbSelectArea('SC6')
	SC6->(dbSetOrder(1))
	SC6->(dbGoTop())
	SC6->(dbSeek(xFilial('SC6')+cNumPed))
	if !SC6->(eof()) .and. SC6->C6_NUM == cNumPed .and. !empty(SC6->C6_CONTRAT)
		cNumCtr	:= SC6->C6_CONTRAT
		u_msgErro('Este Pedido já é uma Reserva Num. Controle: '+cNumCtr+' e essa operação será ABORTADO!','['+cForm+']')

		restArea(aAreaSC6)
		restArea(aAreaSC5)
		restArea(aAreaSD2)
		restArea(aArea)

		dbSelectArea('ADA')
		ADA->(dbSetOrder(1))
		ADA->(dbGoTop())
		ADA->(dbSeek(xFilial('ADA')+cNumCtr))
		return
	endif
	SC6->(dbCloseArea())

	dbSelectArea('SF2')
	SF2->(dbSetOrder(1))
	SF2->(dbGoTop())
	if SF2->(dbSeek(xFilial('SF2')+cNf+cSerie))
		if U_NTENCERRADA(SF2->F2_XSTNOTA)
			restArea(aAreaSF2)
			restArea(aAreaSC6)
			restArea(aAreaSC5)
			restArea(aAreaSD2)
			restArea(aArea)
			return
		endif	
	endif
	SF2->(dbCloseArea())

	cNumCtr	:= FSlavaCtr(cNf, cSerie, cNumPed, cNumOrc)
	
	if empty(cNumCtr)
		u_msgErro('Não foi possivel gerar resreva para pedido'+cSerieOrig+cNfOrig,'['+cForm+']')
		restArea(aAreaSF2)
		restArea(aAreaSC6)
		restArea(aAreaSC5)
		restArea(aAreaSD2)
		restArea(aArea)
		return
	endif
	
	dbSelectArea('SC5')
	SC5->(dbSetOrder(1))
	SC5->(dbGoTop())
	if SC5->(dbSeek(xFilial('SC5')+cNumPed))
		if SC5->(recLock('SC5',.F.))
			SC5->C5_XNUMPAR := cNumCtr
			SC5->(msUnLock())
		endif
	endif
	SC5->(dbCloseArea())

	dbSelectArea('SC6')
	SC6->(dbSetOrder(1))
	SC6->(dbGoTop())
	SC6->(dbSeek(xFilial('SC6')+cNumPed))
	while !SC6->(eof()) .and. SC6->C6_NUM == cNumPed
		if SC6->(recLock('SC6',.F.))
			_xi	+= 1
			SC6->C6_CONTRAT	:= cNumCtr
			SC6->C6_ITEMCON	:= strZero(_xi,2)
			SC6->(msUnLock())
		endif
		SC6->(dbSkip())
	enddo
	SC6->(dbCloseArea())

	restArea(aAreaSF2)
	restArea(aAreaSC6)
	restArea(aAreaSC5)
	restArea(aAreaSD2)
	restArea(aArea)

	u_msgInforma('Contrato Gerado com Sucesso. Num Controle: '+cNumCtr,'['+cForm+']')

	dbSelectArea('ADA')
	ADA->(dbSetOrder(1))
	ADA->(dbGoTop())
	ADA->(dbSeek(xFilial('ADA')+cNumCtr))

return

static function CriaSX1(cPerg)

	local 	aHelpPor	:= {},;
			aHelpEsp	:= {},;
			aHelpIng	:= {}

	//Grupo de Perguntas
	aHelpPor := {}
	Aadd( aHelpPor, 'Número Nota do Pedido de Venda 		')
	aHelpEsp := {}
	Aadd( aHelpEsp, 'Nota número de la solicitud de venta	')
	aHelpIng := {}
	Aadd( aHelpIng, 'Note Number of the sale request		')
	U_xPutSX1(cPerg,'01','Num. Nota'		,'Num. Nota'		,'Note Number'		,'mv_ch1','C',09	,0,1,'G','','','','','mv_par01','','','','','','','','','','','','','','','','',aHelpPor,aHelpEsp,aHelpIng)
	aHelpPor := {}
	Aadd( aHelpPor, 'Serie Nota do Pedido de Venda 			')
	aHelpEsp := {}
	Aadd( aHelpEsp, 'Serie a nota de la solicitud de venta	')
	aHelpIng := {}
	Aadd( aHelpIng, 'Serie a note of the sale request		')
	U_xPutSX1(cPerg,'02','Serie Nota'		,'Serie Nota'		,'Serie Nota'		,'mv_ch2','C',03	,0,1,'G','','','','','mv_par02','','','','','','','','','','','','','','','','',aHelpPor,aHelpEsp,aHelpIng)

return()

static function FSlavaCtr(cNf, cSerie, cNumPed, cNumOrc)

	local	cNumCTR		:= '',;
			dEmissao	:= stod('  /  /    '),;
			cCodCli		:= '',;
			cLjCli		:= '',;
			cNomCli		:= '',;
			cCondPgto	:= '',;
			cDescPgto	:= '',;
			cTabela		:= '',;
			cVend		:= '',;
			cNomVend	:= '',;
			nComis		:= 0,;
			cMoeda		:= '',;
			cFilent		:= '',;
			cTipLib		:= '',;
			cStatus		:= '',;
			mObs
			
	local	cItem		:= 0
			cProduto	:= ''
			nQtdVen		:= 0.0
			nPrcVen		:= 0.0
			cTes		:= ''
			nPrcUnit	:= 0.0
			cLocal		:= ''
			cDescProd	:= ''
			cUM			:= ''
			cSegUm		:= ''
			nDescont	:= 0.0
			nValDesc	:= 0.0
	
	local	aArea		:= getArea(),;
			aAreaSC5	:= SC5->(getArea()),;
			aAreaSC6	:= SC6->(getArea())
	
	dbSelectArea('SC5')
	SC5->(dbSetOrder(1))
	SC5->(dbGoTop())
	SC5->(dbSeek(xFilial('SC5')+cNumPed))

	dbSelectArea('SC6')
	SC6->(dbSetOrder(1))
	SC6->(dbGoTop())
	SC6->(dbSeek(xFilial('SC6')+cNumPed))

	//Preencher as Variaveis
	begin transaction

		cNumCTR		:= GETSX8NUM("ADA","ADA_NUMCTR")                                                                                                   
		dEmissao	:= DDATABASE
		cCodCli		:= SC5->C5_CLIENTE		//SCJ->CJ_CLIENTE
		cLjCli		:= SC5->C5_LOJACLI		//SCJ->CJ_LOJA
		cNomCli		:= SC5->C5_XNOMCON		//SA1->A1_NOME
		cCondPgto	:= SC5->C5_CONDPAG		//SCJ->CJ_CONDPAG
		cDescPgto	:= SC5->C5_XDESCON		//SCJ->CJ_XDESCON
		cTabela		:= SC5->C5_TABELA		//GETMV("MV_TABPAD")
		cVend		:= SC5->C5_VEND1		//SCJ->CJ_XVEND
		cNomVend	:= SC5->C5_XNVEND1		//SCJ->CJ_XNOMVEN
		nComis		:= 0
		cMoeda		:= SC5->C5_MOEDA		//SCJ->CJ_MOEDA
		cFilent		:= SC5->C5_FILIAL		//SCJ->CJ_FILIAL
		cTipLib		:= SC5->C5_TIPLIB		//SCJ->CJ_TIPLIB
		cStatus		:= 'B'
		mObs		:= SC5->C5_XOBS			//SCJ->CJ_XOBS
	
		if recLock('ADA',.T.)
			ADA->ADA_FILIAL	:= XFILIAL('ADA')
			ADA->ADA_NUMCTR	:= cNumCTR
			ADA->ADA_EMISSA	:= dEmissao
			ADA->ADA_CODCLI	:= cCodCli
			ADA->ADA_LOJCLI	:= cLjCli
			//ADA->ADA_NOMCLI	:= cNomCli
			ADA->ADA_CONDPG	:= cCondPgto
			ADA->ADA_XDSCPG	:= cDescPgto
			ADA->ADA_TABELA	:= cTabela
			ADA->ADA_VEND1	:= cVend
			ADA->ADA_XNVEN1	:= cNomVend
			//ADA->ADA_COMIS1	:= nComis
			ADA->ADA_MOEDA	:= cMoeda
			//ADA->ADA_FILENT	:= cFilent
			ADA->ADA_TIPLIB	:= cTipLib
			ADA->ADA_STATUS	:= cStatus
			ADA->ADA_XOBS	:= mObs
			ADA->ADA_XNORC	:= cNumOrc
			ADA->ADA_XNOTA	:= cNf
			ADA->ADA_XSERIE	:= cSerie
			ADA->(msUnlock())
		endif

		//item do orcamento
		SC6->(dbselectarea('SC6'))
		SC6->(dbsetorder(1))
		SC6->(dbGoTop())
		SC6->(dbseek(xfilial('SC6') + cNumPed))
		while !SC6->(eof()).and.(SC6->C6_FILIAL == xfilial('SC6').and.SC6->C6_NUM == cNumPed)
		
			cItem	+= 1
			cProduto	:= SC6->C6_PRODUTO
			nQtdVen		:= SC6->C6_QTDVEN
			nPrcVen		:= SC6->C6_PRCVEN
			cTes		:= SC6->C6_TES
			nPrcUnit	:= SC6->C6_PRUNIT
			cLocal		:= SC6->C6_LOCAL
			nDescont	:= SC6->C6_DESCONT
			nValDesc	:= SC6->C6_VALDESC

			dbSelectArea('SB1')
			SB1->(dbSetOrder(1))
			SB1->(dbGoTop())
			SB1->(dbSeek(xFilial('SB1')+cProduto))
			cDescProd	:= SB1->B1_DESC
			cUM			:= SB1->B1_UM
			cSegUm		:= SB1->B1_SEGUM
			SB1->(dbCloseArea())

			if recLock('ADB',.T.)
				ADB->ADB_FILIAL		:= XFILIAL('ADB')
				ADB->ADB_NUMCTR		:= cNumCTR
				ADB->ADB_ITEM		:= strZero(cItem,2)
				ADB->ADB_CODPRO		:= cProduto
				ADB->ADB_DESPRO		:= cDescProd
				ADB->ADB_UM			:= cUM
				ADB->ADB_QUANT		:= nQtdVen
				ADB->ADB_PRCVEN		:= nPrcVen
				ADB->ADB_TOTAL		:= nQtdVen * nPrcVen
				ADB->ADB_TES		:= '524'
				ADB->ADB_TESCOB		:= cTes
				ADB->ADB_LOCAL		:= cLocal
				ADB->ADB_PRUNIT		:= nPrcUnit
				ADB->ADB_SEGUM		:= cSegUm
				ADB->ADB_UNSVEN		:= convUM(cProduto,nQtdVen,0,2)	//convUM(<COD.PRODUTO>,<QTD 1ª UNID>,<QTD 2ª UNID>,<QUAL RETORNO (1 = 1ª UNID, 2 = 2ª UNID)>)
				ADB->ADB_CODCLI		:= cCodCli
				ADB->ADB_LOJCLI		:= cLjCli
				ADB->ADB_PEDCOB		:= cNumPed
				ADB->ADB_DESC		:= nDescont
				ADB->ADB_VALDES		:= nValDesc
				ADB->(msUnlock())
			endif
			
			SC6->(dbskip())
		enddo

		lMsErroAuto	:= .F.

		if lMsErroAuto
			RollBackSX8()
			MostraErro()
			lRet	:= .F.
		else
			ConfirmSX8()
		endif

	end transaction
	
	restArea(aAreaSC6)
	restArea(aAreaSC5)
	restArea(aArea)
	
return cNumCTR
