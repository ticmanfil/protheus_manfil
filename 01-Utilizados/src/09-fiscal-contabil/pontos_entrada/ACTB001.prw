#INCLUDE "rwmake.ch"
#include 'protheus.ch'
#INCLUDE "TOPCONN.CH"  
#INCLUDE "TBICONN.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACTB001   º Autor³  Leonardo Peixoto   º Data ³  09/06/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programa para incluir itens contabeis a partir do cadastro º±±
±±º          ³ dos clientes.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ACTB001(_cCod,_cloja,_cTipoLan, _cLanpad,_cSeq,_cTpTit,_cNota)   

Local _cCodCli := ''
Local _cConta  := ''
Local _aArea := GetArea()

Default _cTipoLan := ''
Default _cLanpad  := ''
Default _cSeq	  := ''
Default _cTpTit	  := ''
Default _cNota	  := ''

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
			if empty(_cTpTit) .or. !alltrim(_cTpTit) $ 'CD|CR|CC'
				_cCodCli := 'C' + ALLTRIM(_ccod)
			else
				dbSelectArea('SF2')
				SF2->(dbSetOrder(1))
				if SF2->(dbSeek(xFilial('SF2')+_cNota))
					_cCodCli := 'C' + ALLTRIM(SF2->F2_CLIENTE)
				else
					_cCodCli := 'C' + ALLTRIM(_ccod)
				endif
			endif

		EndIf
	EndIf
EndIf
restArea(_aArea)

Return (_cCodCli)


