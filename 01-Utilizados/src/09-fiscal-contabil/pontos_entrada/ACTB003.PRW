#INCLUDE "rwmake.ch"
#include 'protheus.ch'
#INCLUDE "TOPCONN.CH"  
#INCLUDE "TBICONN.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACTB003   º Autor³  Tiago Lucio        º Data ³  28/11/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programa para validar o centro de custos de acordo         º±±
±±º          ³ conta contbil.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ACTB003(_cCusto,_cTipoLan, _cLanpad,_cSeq)   

Local _cConta  := ''
Local _cCCRet  := ''
Local _aArea := GetArea()

Default _cCusto   := ''
Default _cTipoLan := ''
Default _cLanpad  := ''
Default _cSeq	  := ''


dbSelectArea("CT5")
CT5->(dbSetOrder(1))
if CT5->(dbSeek(xFilial("CT5")+AllTrim(_cLanpad)+AllTrim(_cSeq)))

	if _cTipoLan=='C'
		_cConta:= &(CT5->CT5_CREDIT)
		
	ElseIf _cTipoLan=='D'
		_cConta:= &(CT5->CT5_DEBITO)

	EndIf
	
	dbSelectArea("CT1")
	CT1->(dbSetOrder(1))
	IF CT1->(dbSeek(xFilial("CT1")+allTrim(_cConta)))
		if CT1->CT1_ACCUST=='1' 
			_cCCRet:= _cCusto
		EndIf
	EndIf
EndIf

restArea(_aArea)

Return (_cCCRet)


