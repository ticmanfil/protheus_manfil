#include 'protheus.ch'
#include 'tbiconn.ch'
#include "rwmake.CH"
#include "topconn.ch"

/*/
===============================================================================================================================
Programa----------: SC05001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 21/08/2018
===============================================================================================================================
Descrição---------: Este PE é executado para imprimir os DANFE's ainda nao impressos
===============================================================================================================================
Uso---------------: SCHEDULE
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: 05 - Faturamento
=====================================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor		|	Data	|										Motivo																
----------------:-----------:-------------------------------------------------------------------------------------------------------:
				|			|																											
=====================================================================================================================================
/*/

user function SC05001()
//user function SC05001(lAuto,cDoc,cSerie,cEmail)

	local cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))
	
	if cAmbiente == '2'
		//ImpDANFE(lAuto,cDoc,cSerie,cEmail)
		ImpDANFE()
	endif

return

static function ImpDANFE()
	local cQuery	:= ''
	
	cQuery	:='exec dbo.PR_WS01001'	
	
	if select('TMPDANFE') <> 0
		dbSelectArea('TMPDANFE')
		TMPDANFE->(dbCloseArea())
	endif
	
	tcquery cQuery new alias 'TMPDANFE'
	
	dbSelectArea('TMPDANFE')
	TB1TMP->(dbGoTop())
	while !EOF()
		dbSelectArea('SF2')
		SF2->(dbSetOrder(1))
		SF2->(dbGoTo())
		SF2->(dbSeek(xFilial('SF2')+TMPDANFE->F2_SERIE+TMPDANFE->F2_DOC))
		
		dbSelectArea('SC5')
		SC5->(dbSetOrder(10))
		SC5->(dbGoTo())
		SC5->(dbSeek(xFilial('SC5')+TMPDANFE->F2_SERIE+TMPDANFE->F2_DOC))
		
		dbSelectArea('SF3')
		SF3->(dbSetOrder(5))
		SF3->(dbGoTop())
		SF3->(dbSeek(xFilial('SF3')+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA))
		if SF3->F3_CODRSEF	== '100'
			U_RL05002('000001', Nil, Nil, .F.)
			if RecLock('SC5',.F.)
				SC5->C5_XUSERIM	:= CUSERNAME
				SC5->C5_DTIMP	:= DATE()
				SC5->C5_HRIMP	:= TIME()
				if empty(SC5->C5_XIMP)
					SC5->C5_XIMP	:= 'S'
				else
					SC5->C5_XIMP	:= 'R'
				endif
				msUnLock()
			endif
		endif

		SF3->(dbCloseArea())
		SC5->(dbCloseArea())
		SF2->(dbCloseArea())
	
		dbSelectArea('TMPDANFE')
		TMPDANFE->(dbSkip())
	enddo
	dbSelectArea('TMPDANFE')
	TMPDANFE->(dbCloseArea())

return

static function GerPDF(_cNumNF,_cEmail,cXML,cEmaTransp,cFil)

	Local _aAreaSX1 := SX1->(GetArea())
	
	Pergunte("NFSIGW",.F.)
	
	xMV_PAR01 := MV_PAR01
	xMV_PAR02 := MV_PAR02
	xMV_PAR03 := MV_PAR03
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	//Altera valor do MV_PAR01
	If DbSeek("NFSIGW    "+"01")
	   If RecLock("SX1",.F.)
	      X1_CNT01 := _cNumNF
	      MsUnLock()
	   EndIf
	EndIf
	//Altera valor do MV_PAR02
	If DbSeek("NFSIGW    "+"02")
	   If RecLock("SX1",.F.)
	      X1_CNT01 := _cNumNF
	      MsUnLock()
	   EndIf
	EndIf
	//Altera valor do MV_PAR03
	If DbSeek("NFSIGW    "+"03")
	   If RecLock("SX1",.F.)
	      X1_CNT01 := Iif(cFil=='02','2',"10")
	      MsUnLock()
	   EndIf
	EndIf
	//Altera valor do MV_PAR04
	If DbSeek("NFSIGW    "+"04")
	   If RecLock("SX1",.F.)
	      X1_PRESEL := 2
	      MsUnLock()
	   EndIf
	   Pergunte("NFSIGW",.F.)
	
		cFilePrint := "DANFE_"+AllTrim(MV_PAR01)+"_"+AllTrim(MV_PAR02)
		lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
		oDanfe     := FWMSPrinter():New(cFilePrinte, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)
		nFlags     := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
		oSetup     := FWPrintSetup():New(nFlags, "DANFE")
		__RelDir := "\spool\"
	
		U_PrtNfeSef(StrZero(Val(cFil),6),MV_PAR01,MV_PAR01,oDanfe,oSetup,cFilePrint,.t.,_cEmail,cXML,cEmaTransp, .f.)
		
	EndIf
	
	// Retorno Numeração Anterior
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	//Altera valor do MV_PAR01
	If DbSeek("NFSIGW    "+"01")
	   If RecLock("SX1",.F.)
	      X1_CNT01 := xMV_PAR01
	      MsUnLock()
	   EndIf
	EndIf
	//Altera valor do MV_PAR02
	If DbSeek("NFSIGW    "+"02")
	   If RecLock("SX1",.F.)
	      X1_CNT01 := xMV_PAR02
	      MsUnLock()
	   EndIf
	EndIf
	//Altera valor do MV_PAR03
	If DbSeek("NFSIGW    "+"03")
	   If RecLock("SX1",.F.)
	      X1_CNT01 := xMV_PAR03
	      MsUnLock()
	   EndIf
	EndIf
	
	RestArea(_aAreaSX1)
	Return
