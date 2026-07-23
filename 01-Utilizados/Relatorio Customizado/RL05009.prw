#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'colors.ch'
#include 'rptdef.ch'
#include 'fwprintsetup.ch'
#include 'topconn.ch'
/*/
===============================================================================================================================
Programa----------: RL05009
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 12/02/2020
===============================================================================================================================
Descrição---------: Este programa serve para IMPRIMIR O PEDIDO DE VENDA referente a RESERVA
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
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor	|	Data	|										Motivo																
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			| 																										
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			| 																										
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			|																											
=====================================================================================================================================
/*/
user function RL05009(pNumPed,pNumDoc,pImp)

	Private lImprimiu:= .F.

	private	oPrinter,;
			_plAdjustToLegacy	:= .F.,;
			cPathInServer		:= GetTempPath(),;
			lDisabeSetup		:= .T.
	
	private	cPerg 		:= 'RL05009',;
			_cLogo 		:= GetSrvProfString("StartPath","")+"lgrl01.bmp",;
			cNomePDF	:= 'Reserva'
	
	private _nLinBox	:= 5,;
			_nLinAnt	:= 0,;
			_nColIni	:= 02,;
			_nColFim	:= 560,;
			_nEspacador	:= 8,;
			_cImp		:= '',;
			_cHrimp		:= '',;
			lPreview	:= .T.

	//Fontes
	private oFontTit,;
			oFontRod,;
			oFont05,;
			oFont05N,;
			oFont08,;
			oFont08N,;
			oFont09,;
			oFont09N,;
			oFont10,;
			oFont10N,;
			oFont12,;
			oFont12N,;
			oFont14,;
			oFont14N,;
			oFont16,;
			oFont16N

	private oBrush		:= TBrush():New( , CLR_GRAY)
	
	private	aArea		:= getArea(),;
			aAreaSC5	:= SC5->(GetArea()),;
			aAreaADA	:= ADB->(getArea()),;
			aAreaADB	:= ADB->(getArea()) 

	Default pNumPed:= SC5->C5_NUM
	Default pNumDoc:= SC5->C5_NOTA
	Default pImp:= ''

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do objeto.                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNomePDF := cNomePDF+"_"+SC5->C5_SERIE+SC5->C5_NOTA
	
	if pImp == ''
		pImp := U_SelImp(pTitulo)
	endif

	oPrinter := FWMSPrinter():New(cNomePDF+"_" + DtoS(Date())+ "_"+StrTran(Time(),':','-'), IMP_SPOOL, _plAdjustToLegacy,cPathInServer,lDisabeSetup,.F., ,pImp)  
	if GetMv("MV_XPRGER")==pImp
		oPrinter:SetDevice(IMP_PDF) //IMP_SPOOL=IMPRESSORA, IMP_PDF=PDF
	else
		oPrinter:SetDevice(IMP_SPOOL) //IMP_SPOOL=IMPRESSORA, IMP_PDF=PDF
	endif
	
	//oPrinter:SetDevice(IMP_SPOOL) //IMP_SPOOL=IMPRESSORA, IMP_PDF=PDF
	oPrinter:SetPortrait() // Formato Retrato
	oPrinter:SetPaperSize(1) // Letter   216mm x 279mm  637 x 823
	oPrinter:SetMargin(60,60,60,60) // Margem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao das fontes.                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFontTit	:= TFontEx():New(oPrinter,"courier new",,018,,.T.,,,,,.F.,.F.)
	oFont05		:= TFontEx():New(oPrinter,"courier new",05,05,.F.,.T.,.F.)
	oFont08		:= TFontEx():New(oPrinter,"courier new",08,08,.F.,.T.,.F.)
	oFont09		:= TFontEx():New(oPrinter,"courier new",09,09,.F.,.T.,.F.)
	oFont10		:= TFontEx():New(oPrinter,"courier new",10,10,.F.,.T.,.F.)
	oFont12		:= TFontEx():New(oPrinter,"courier new",12,12,.F.,.T.,.F.)
	oFont14		:= TFontEx():New(oPrinter,"courier new",14,14,.F.,.T.,.F.)
	oFont16		:= TFontEx():New(oPrinter,"courier new",16,16,.F.,.T.,.F.)

	oFont05N	:= TFontEx():New(oPrinter,"courier new",05,05,.T.,.T.,.F.)
	oFont08N	:= TFontEx():New(oPrinter,"courier new",08,08,.T.,.T.,.F.)
	oFont09N	:= TFontEx():New(oPrinter,"courier new",09,09,.T.,.T.,.F.)
	oFont10N	:= TFontEx():New(oPrinter,"courier new",10,10,.T.,.T.,.F.)
	oFont12N	:= TFontEx():New(oPrinter,"courier new",12,12,.T.,.T.,.F.)
	oFont14N	:= TFontEx():New(oPrinter,"courier new",14,14,.T.,.T.,.F.)
	oFont16N	:= TFontEx():New(oPrinter,"courier new",16,16,.T.,.T.,.F.)
	
	oPrinter:SetFont(oFont10:oFont) // Fonte Padrao para calculo do objeto de impressao
	
	Processa({|| PrintRes(pNumPed) },"Imprimindo Nota de Pedido de Venda...","")

	restArea(aArea)
	restArea(aAreaSC5)
	restArea(aAreaADA)
	restArea(aAreaADB)

return lImprimiu

static function PrintRes(pNumPed)

	local _cPedido	:= pNumPed
	
	if select('TB1')<>0
		TB1->(DbCloseArea())
	endif
	
	beginsql alias 'TB1'
		select distinct
			 SD2.D2_SERIE
			,SD2.D2_DOC
		from
			%table:SD2% SD2
		
		where
				SD2.%NotDel% 
			and SD2.D2_FILIAL	= %xFilial:SD2% 
			and SD2.D2_PEDIDO	= %Exp:_cPedido%
	endsql
		
	dbSelectArea('TB1')
	TB1->(DbGoTop())
	
	While !TB1->(Eof())
	
		IncProc("Gerando impressao "+Alltrim(TB1->D2_SERIE)+Alltrim(TB1->D2_DOC))
	
		MntTRBRES(TB1->D2_DOC, TB1->D2_SERIE)
		
		ImpRes(1)
		ImpRes(2)
		ImpRes(3)
//		ImpRes(4)

		dbSelectArea('TB1')
		TB1->(dbSkip())
	enddo
		
	if lPreview
		lImprimiu:= oPrinter:Preview()
	endif
	
	if oPrinter # Nil
		FreeObj(oPrinter)
	endif

	oPrinter := Nil

return

static function MntTRBRES(_cDoc, _cSerie)

	local	xdoc	:= ''

	local cQuery := 'exec PR_RL05001A @SERIE = "'+_cSerie+'", @NUMDOC = "'+_cDoc+'"'
		
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	if select('TBRES') <> 0
		dbSelectArea('TBRES')
		TBRES->(dbCloseArea())
	endif
	
	//crio o novo alias
	TCQUERY cQuery NEW ALIAS 'TBRES'
	
	dbSelectArea('TBRES')
	TBRES->(dbGoTop())

	xDoc	:= TBRES->F2_DOC

return xDoc


static function ImpRes(cVia)

	local 	cMemo		:= SC5->C5_XOBS,;
			_nTPeso		:= 0,;
			_cTexto		:= '',;
			_nQtd		:= 0
			
	local	nXi			:= 0,;
			_cVendedor	:= SC5->C5_XNVEND1

	
	if cVia	= 1 .or. cVia = 2
		_nLinBox := 000
		oPrinter:StartPage()
	else
		_nLinBox	+= 006
	endif
	
	TBRES->(dbGoTop())
	
	//CABECALHO
	oPrinter:Box(_nLinBox,_nColIni,_nLinBox+23,_nColFim) //Box cidade e numero nota
	_cTexto	:= "RESERVA DE PEDIDOS"
	oPrinter:SayAlign(_nLinBox+002,_nColIni+002,Alltrim(_cTexto),oFont12N:oFont,200,,,2,0)
	oPrinter:Line(_nLinBox,210,_nLinBox+23,210)
	_cTexto	:= " Pedido: "+TBRES->C5_SERIE+TBRES->C5_NOTA
	oPrinter:Say(_nLinBox+15,230,Alltrim(_cTexto), oFont12N:oFont)
	_cTexto	:= "No.Ped: "+TBRES->C5_NUM+" No.Orç: "+TBRES->C5_XNUMORC+" No. Controle: "+TBRES->C6_CONTRAT
	oPrinter:Say(_nLinBox+20,240, Alltrim(_cTexto), oFont05:oFont)
	oPrinter:Fillrect( {_nLinBox,_nColFim-160,_nLinBox+23,_nColFim }, oBrush, "-2")
	if cVia = 1
		_cTexto	:= cValToChar(cVia)+"ª VIA - CONTROLE"
	elseif cVia = 2
		_cTexto	:= cValToChar(cVia)+"ª VIA - CLIENTE"
	else
		_cTexto	:= cValToChar(cVia)+"ª VIA - ENTREGA"
	endif
	oPrinter:Say(_nLinBox+14,_nColFim-140, _cTexto, oFont12N:oFont,,CLR_WHITE)

	_nLinBox+= 25
	oPrinter:Box(_nLinBox,_nColIni,_nLinBox+100,_nColFim) //Box dados do cliente
	_nLinAnt := _nLinBox
	_cHrimp	:= SubStr(TIME(),1,8)
	_cImp	:= CUSERNAME + " " + DTOC(DATE()) + " - " + _cHrimp
	
	if (SC5->C5_XIMP == 'S')
		oPrinter:Say(_nLinAnt+=005,_nColFim-155,"Reimpressão: "+Alltrim(_cImp),oFont05:oFont)
	else
		oPrinter:Say(_nLinAnt+=005,_nColFim-155,"Impressão: "+Alltrim(_cImp),oFont05:oFont)
	endif
	
	oPrinter:Say(_nLinAnt+=005,001,"  Num. Reserva: ",oFont09:oFont)
	oPrinter:Say(_nLinAnt     ,080,TBRES->F2_SERIE+TBRES->F2_DOC+' / '+TBRES->C5_NUMRES,oFont09N:oFont)

	oPrinter:Say(_nLinAnt	  ,200,"  Emissão: ",oFont09:oFont)
	oPrinter:Say(_nLinAnt     ,260,dtoc(TBRES->F2_EMISSAO),oFont09N:oFont)

//	oPrinter:Say(_nLinAnt	  ,315,"Num. Controle: ",oFont09:oFont)
//	oPrinter:Say(_nLinAnt     ,375,TBRES->C6_CONTRAT,oFont09N:oFont)

	oPrinter:Say(_nLinAnt+=012,001,"  Cliente: ",oFont09:oFont)
	oPrinter:Say(_nLinAnt     ,060,alltrim(TBRES->F2_CLIENTE+'-'+TBRES->F2_LOJA+' - '+TBRES->C5_XNOMCON)+'s - '+alltrim(SA1->A1_XDDD)+" "+Alltrim(SA1->A1_XCEL),oFont09N:oFont)
	oPrinter:Say(_nLinAnt     ,370,"Vendedor:",oFont09:oFont)
	oPrinter:Say(_nLinAnt     ,420, _cVendedor,oFont09N:oFont)

	oPrinter:Say(_nLinAnt+=012,001,"  Endereço p/a Entrega:",oFont09:oFont)
	oPrinter:Say(_nLinAnt	  ,120,alltrim(TBRES->C5_XENDE)+' - '+alltrim(TBRES->C5_XBAIRRE)+' - '+alltrim(TBRES->C5_XMUNE)+'-'+alltrim(TBRES->C5_XESTE),oFont09N:oFont)

	_nBkpLin := _nLinAnt - 003
	For nXi := 1 To MLCount(cMemo,100)
		 If ! Empty(MLCount(cMemo,100))
			  If ! Empty(MemoLine(cMemo,100,nXi))
				   oPrinter:SayAlign(_nBkpLin+=9,010,OemToAnsi(MemoLine(cMemo,100,nXi)),oFont08:oFont,_nColFim,60,,0,1)
			  EndIf
		 EndIf
	Next nXi

	_nLinAnt	:= _nBkpLin

	//ITENS
	dbSelectArea('TBRES')
	TBRES->(dbGoTop())
	
	_nLinBox+= 82
	
	_nLinAlign := _nLinBox
	
	if cVia=1
		_nLinBox+= 609
	else
		_nLinBox+= 233
	endif

	oPrinter:Box(_nLinAlign,_nColIni,_nLinBox,_nColFim) //Box das mercadorias
	oPrinter:Box(_nLinAlign,_nColIni,_nLinAlign+15,_nColFim) //Box titulos mercadorias
	
	oPrinter:Line(_nLinAlign,045,_nLinBox,045)
	oPrinter:Line(_nLinAlign,105,_nLinBox,105)
	oPrinter:Line(_nLinAlign,140,_nLinBox,140)
	oPrinter:Line(_nLinAlign,200,_nLinBox,200)

	_nLinAlign += 4
	oPrinter:SayAlign(_nLinAlign-3 ,001, "CÓDIGO"		,oFont09N:oFont ,040,,,2 ,1) //,ALIGN_LEFT ,1)
	oPrinter:SayAlign(_nLinAlign-3 ,050, "QUANT."		,oFont09N:oFont ,065,,,2,1)
	oPrinter:SayAlign(_nLinAlign-3 ,110, "UNID."		,oFont09N:oFont ,025,,,2,1)
	oPrinter:SayAlign(_nLinAlign-3 ,145, "PESO"			,oFont09N:oFont ,050,,,2,1)
	oPrinter:SayAlign(_nLinAlign-3 ,205, "PRODUTO" 		,oFont09N:oFont ,210,,,0,1)
	
	_nLinAlign += 13
	
	//IMPRIME LINHAS DE PRODUTOS
	TBRES->(dbGoTop())
	while !TBRES->(Eof())

		oPrinter:SayAlign(_nLinAlign ,002, ALLTRIM(TBRES->D2_COD)							,oFont08:oFont ,040,,,1,1) //,ALIGN_LEFT ,1)
		oPrinter:SayAlign(_nLinAlign ,050, TransForm(TBRES->D2_QUANT,"@E 999,999.99")		,oFont08:oFont ,050,,,1,1)
		oPrinter:SayAlign(_nLinAlign ,110, TBRES->D2_UM										,oFont08:oFont ,025,,,1,1)
		oPrinter:SayAlign(_nLinAlign ,145, TransForm(TBRES->PESLIQ,"@E 999,999.99")			,oFont08:oFont ,050,,,1,1)
		oPrinter:SayAlign(_nLinAlign ,205, SUBSTR(TBRES->B1_DESC,1,55) 						,oFont08:oFont ,300,,,0,1)
		
		_nTPeso	+= TBRES->PESLIQ 
		_nQtd	+= 1
	 
		_nLinAlign += 9

		TBRES->(DbSkip())
	enddo
	
	//SUB TOTAIS
	oPrinter:Box(_nLinBox,_nColIni,_nLinBox-15,_nColFim) //Box vendedor / totais
	_nLinAlign += 6
	oPrinter:SayAlign(_nLinBox - 14 ,002, TransForm(_nQtd,"@E 999,999"),oFont08:oFont ,040,,,1,1)
	oPrinter:SayAlign(_nLinBox - 14 ,145, TransForm(_nTPeso,"@E 999,999.99"),oFont08:oFont ,050,,,1,1)

	_nLinAlign := _nLinBox
	_nLinBox += 15

	if cVia	= 3
		oPrinter:Say(_nLinAlign+=024,002,"Conferente..........: _________________________________ ",oFont09:oFont)
		oPrinter:Say(_nLinAlign+=024,002,"Data da Entrega: _____/_____/_____",oFont09:oFont)
		oPrinter:Say(_nLinAlign		,330,"Assinatura: ___________________________________",oFont09:oFont)
		oPrinter:Say(_nLinAlign+=020,150,"*** ESTA VIA DEVE SER RETORNADO PARA EMPRESA ***",oFont12N:oFont)
		if cVia = 4
			if select('TBRES') <> 0
				TBRES->(dbCloseArea())
			endif
		endif
	else
		oPrinter:Say(_nLinAlign+=012,001,"===============================================================================================================================================================================================================",oFont10:oFont)
	endif

return

