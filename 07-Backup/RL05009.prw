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
	oPrinter:SetPaperSize(DMPAPER_A4) // Letter   216mm x 279mm  637 x 823
	oPrinter:SetMargin(60,60,60,10) // Margem

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

	local	cQry	as char

	cQry := 'exec PR_RL05001A @SERIE = "'+_cSerie+'", @NUMDOC = "'+_cDoc+'"'
		
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	if select('TBRES') <> 0
		dbSelectArea('TBRES')
		TBRES->(dbCloseArea())
	endif
	
	//crio o novo alias
	tcQuery cQry NEW alias 'TBRES'
	
	dbSelectArea('TBRES')
	TBRES->(dbGoTop())

return nil


static function ImpRes(cVia)

	local 	nXi			as numeric,;
			cImpresso	as char

	local	cNumPedPri	as char,;
			cNumOrcPri	as char,;
			cNumDocPri	as char,;
			cSeriePri	as char

	local	cNumPed		as char,;
			cNumRes		as char,;
			cSerie		as char,;
			cDoc		as char,;
			cDtEmissao	as date,;
			cCodCli		as char,;
			cLojCli		as char,;
			cCliente	as char,;
			cTelefone	as char,;
			cVendRes	as char,;
			cObs		as char

	local	cCodProd	as char,;
			cQtd		as char,;
			cUnid		as char,;
			cPeso		as char,;
			cProduto	as char,;
			nTPeso		as numeric,;
			nQtd		as numeric

	//Preenchendo as variaveis de controle
	_cHrimp		:= SubStr(TIME(),1,8)
	_cImp		:= CUSERNAME + " " + DTOC(DATE()) + " - " + _cHrimp
	cImpresso	:= SC5->C5_XIMP

	TBRES->(dbGoTop())
	//Preenchendo os dados do pedido principal
	cNumOrcPri	:= TBRES->C5_XNUMORC
	cNumPedPri	:= TBRES->C5_NUM
	cNumDocPri	:= TBRES->C5_NOTA
	cSeriePri	:= TBRES->C5_SERIE

	//Preenchendo os dados da reserva
	cNumRes		:= TBRES->C6_CONTRAT
	cNumPed		:= TBRES->C5_NUMRES
	cSerie		:= TBRES->F2_SERIE
	cDoc		:= TBRES->F2_DOC
	cVendRes	:= TBRES->C5_XNVEND1
	cDtEmissao	:= dtoc(TBRES->F2_EMISSAO)
	cCodCli		:= TBRES->F2_CLIENTE
	cLojCli		:= TBRES->F2_LOJA
	cCliente	:= alltrim(TBRES->C5_XNOMCON)
	cTelefone	:= '(' + SA1->A1_XDDD + ')' + SA1->A1_XCEL
	cEndereco	:= alltrim(TBRES->C5_XENDE)
	cBairro		:= alltrim(TBRES->C5_XBAIRRE)
	cObs		:= SC5->C5_XOBS

	if cVia	= 1 .or. cVia = 2
		_nLinBox := 000
		oPrinter:StartPage()

	else
		_nLinBox	+= 006
	endif
		
	//CABECALHO
	oPrinter:Box(_nLinBox,_nColIni,_nLinBox+23,_nColFim) //Box cidade e numero nota

	//_cTexto	:= "RESERVA DE PEDIDOS"
	oPrinter:SayAlign(_nLinBox+002,_nColIni+002,"RESERVA DE PEDIDOS",oFont12N:oFont,200,,,2,0)
	oPrinter:Line(_nLinBox,210,_nLinBox+23,210)

	//_cTexto	:= " Pedido: "+cSeriePri+cNumDocPri
	oPrinter:Say(_nLinBox+15,230," Pedido: "+cSeriePri+cNumDocPri, oFont12N:oFont)

	//_cTexto	:= "No.Ped: "+cNumPedPri+" No.Orç: "+cNumOrcPri+" No. Controle: "+cNumRes
	oPrinter:Say(_nLinBox+20,240, "No.Ped: "+cNumPedPri+" No.Orç: "+cNumOrcPri+" No. Controle: "+cNumRes, oFont05:oFont)
	oPrinter:Fillrect( {_nLinBox,_nColFim-160,_nLinBox+23,_nColFim }, oBrush, "-2")

	if cVia = 1
		oPrinter:Say(_nLinBox+14,_nColFim-140, cValToChar(cVia)+"ª VIA - CONTROLE", oFont12N:oFont,,CLR_WHITE)
	elseif cVia = 2
		oPrinter:Say(_nLinBox+14,_nColFim-140, cValToChar(cVia)+"ª VIA - CLIENTE", oFont12N:oFont,,CLR_WHITE)
	elseif cVia = 3
		oPrinter:Say(_nLinBox+14,_nColFim-140, cValToChar(cVia)+"ª VIA - ENTREGA", oFont12N:oFont,,CLR_WHITE)
	endif

	_nLinBox+= 25
	oPrinter:Box(_nLinBox,_nColIni,_nLinBox+100,_nColFim) //Box dados do cliente
	_nLinAnt := _nLinBox
	
	if (cImpresso == 'S')
		oPrinter:Say(_nLinAnt+=005,_nColFim-155,"Reimpressão: "+Alltrim(_cImp),oFont05:oFont)
	else
		oPrinter:Say(_nLinAnt+=005,_nColFim-155,"Impressão: "+Alltrim(_cImp),oFont05:oFont)
	endif
	
	oPrinter:Say(_nLinAnt+=005,001,"  Num. Reserva: ",oFont09:oFont)
	oPrinter:Say(_nLinAnt     ,080,cSerie+cDoc+' / '+cNumPed,oFont09N:oFont)

	oPrinter:Say(_nLinAnt	  ,200,"  Emissão: ",oFont09:oFont)
	oPrinter:Say(_nLinAnt     ,260,cDtEmissao,oFont09N:oFont)

	oPrinter:Say(_nLinAnt+=012,001,"  Cliente: ",oFont09:oFont)
	oPrinter:Say(_nLinAnt     ,060, cCodCli+'-'+cLojCli+' - '+cCliente+' - '+cTelefone,oFont09N:oFont)
	oPrinter:Say(_nLinAnt     ,380,"Vendedor:",oFont09:oFont)
	oPrinter:Say(_nLinAnt     ,430, cVendRes,oFont09N:oFont)

	oPrinter:Say(_nLinAnt+=012,001,"  Endereço p/a Entrega:",oFont09:oFont)
	oPrinter:Say(_nLinAnt	  ,120, cEndereco+' - '+cBairro,oFont09N:oFont)

	_nBkpLin := _nLinAnt - 003
	For nXi := 1 To MLCount(cObs,100)
		 If ! Empty(MLCount(cObs,100))
			  If ! Empty(MemoLine(cObs,100,nXi))
				   oPrinter:SayAlign(_nBkpLin+=9,010,OemToAnsi(MemoLine(cObs,100,nXi)),oFont08:oFont,_nColFim,60,,0,1)
			  EndIf
		 EndIf
	Next nXi

	_nLinAnt	:= _nBkpLin

	//ITENS
	dbSelectArea('TBRES')
	TBRES->(dbGoTop())
	
	_nLinBox+= 82
	
	_nLinAlign := _nLinBox
	
	_nLinBox+= 253	//303
	
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
	nTPeso	:= 0
	nQtd	:= 0
	TBRES->(dbGoTop())
	while !TBRES->(Eof())

		cCodProd	:= alltrim(TBRES->D2_COD)
		cQtd		:= TransForm(TBRES->D2_QUANT,"@E 999,999.99")
		cUnid		:= TBRES->D2_UM
		cPeso		:= TransForm(TBRES->PESLIQ,"@E 999,999.99")
		cProduto	:= SubStr(TBRES->B1_DESC,1,55)
		nTPeso		:= TBRES->PESLIQ
		nQtd		+= 1

		oPrinter:SayAlign(_nLinAlign ,002, cCodProd	, oFont08:oFont ,040,,,1,1)
		oPrinter:SayAlign(_nLinAlign ,050, cQtd		, oFont08:oFont ,050,,,1,1)
		oPrinter:SayAlign(_nLinAlign ,110, cUnid	, oFont08:oFont ,025,,,1,1)
		oPrinter:SayAlign(_nLinAlign ,145, cPeso	, oFont08:oFont ,050,,,1,1)
		oPrinter:SayAlign(_nLinAlign ,205, cProduto	, oFont08:oFont ,300,,,0,1)
		
		_nLinAlign += 9

		TBRES->(DbSkip())
	enddo
	
	//SUB TOTAIS
	oPrinter:Box(_nLinBox,_nColIni,_nLinBox-15,_nColFim) //Box vendedor / totais
	_nLinAlign += 6
	oPrinter:SayAlign(_nLinBox - 14 ,002, TransForm(nQtd,"@E 999,999"),oFont08:oFont ,040,,,1,1)
	oPrinter:SayAlign(_nLinBox - 14 ,145, TransForm(nTPeso,"@E 999,999.99"),oFont08:oFont ,050,,,1,1)

	_nLinAlign := _nLinBox
	_nLinBox += 15

	if cVia	= 3
		oPrinter:Say(_nLinAlign+=024,002,"Conferente: _________________________________ ",oFont08:oFont)
		//oPrinter:Say(_nLinAlign     ,002,"Data da Entrega: _____/_____/_____",oFont08:oFont)
		oPrinter:Say(_nLinAlign		,230,"Data/Assinatura: _____________________________________________",oFont08:oFont)
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

