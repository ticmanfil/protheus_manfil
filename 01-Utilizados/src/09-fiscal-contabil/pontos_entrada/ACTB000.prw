#INCLUDE "rwmake.ch"
#include 'protheus.ch'
#INCLUDE "TOPCONN.CH"  
#INCLUDE "TBICONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACTB000   º Autor³ Leonardo Peixoto    º Data ³ 09/06/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programa para a inclusão de itens contabeis a partir do    º±±
±±º          ³ cadastro do Fornecedor                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ACTB000(_ccod,_cloja,_cTipoLan, _cLanpad,_cSeq)

Local _cCodFor := ''
Local _cConta  := ''
Local _aArea   := GetArea()

Default _cTipoLan := ''
Default _cLanpad  := ''
Default _cSeq	  := ''

//Alterado por Tiago Lucio - 28/11/2019 para verificar dinamicamente se a conta contabil aceita item contabil
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
		if CT1->CT1_ACITEM=='1'
			_cCodFor := 'F' + ALLTRIM(_ccod)
		EndIf
	EndIf

EndIf
/*
dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial("SA2")+_ccod+_cloja)

If found()	
	_cCodFor := 'F' + ALLTRIM(_ccod) + ALLTRIM(_cloja)
	_cNome   := SA2->A2_NOME
	
	dbSelectArea("CTD")
	dbGoTop()
	dbSetorder(1)
	dbSeek(xFilial("CTD")+_cCodFor)
	If !Found() .AND. _cCodFor <> ''
		RecLock("CTD",.T.)
		CTD->CTD_FILIAL 	:= xFilial("CTD")
		CTD->CTD_ITEM  		:= _cCodFor
		CTD->CTD_CLASSE 	:= '2'
		CTD->CTD_DESC01 	:= _cNome
		CTD->CTD_BLOQ		:= '2'
		CTD->CTD_DTEXIS		:= STOD('20170101')
		CTD->CTD_ITLP		:= _cCodFor
		CTD->CTD_ITSUP      := SUBSTR(ALLTRIM(_cCodFor),1,1)
		MsUnLock()
	EndIf 
EndIf*/
restArea(_aArea)

Return ( _cCodFor) 
