#INCLUDE "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MCTB000   º Autor³ Leonardo Peixoto    º Data ³  01/02/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para a inclusao automatica de lançamentos padroes º±±
±±º          ³de cancelamento.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MCTB000()

Private cPerg   := "MCTB00"
Private _LpCanc := " "

ValidPerg()
Pergunte(cPerg,.T.)

DbselectArea("CT5")
DbSetOrder(1) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
DbSeek(xFilial("CT5")+MV_PAR01,.T.)
if found()
	While !Eof() .and. CT5->CT5_LANPAD>= MV_PAR01  .and.  CT5->CT5_LANPADB <=MV_PAR02
		_LpCanc := " "
		_cFilial:= CT5->CT5_FILIAL
		_cLanpad:= CT5->CT5_LANPAD
		_cSequen:= CT5->CT5_SEQUEN
		_cDesc  := CT5->CT5_DESC  
		_cStatus:= CT5->CT5_STATUS
		_cDc    := CT5->CT5_DC
		_cDebito:= CT5->CT5_DEBITO
		_cCredit:= CT5->CT5_CREDIT
		_cMoedas:= CT5->CT5_MOEDAS
		_cVrl01 := CT5->CT5_VLR01
		_cVrl02 := CT5->CT5_VLR02
		_cVrl03 := CT5->CT5_VLR03
		_cVrl04 := CT5->CT5_VLR04
		_cVrl05 := CT5->CT5_VLR05
		_cHist  := CT5->CT5_HIST
		_cHaglut:= CT5->CT5_HAGLUT
		_cCCD   := CT5->CT5_CCD
		_cCCC   := CT5->CT5_CCC
		_cOrigem:= CT5->CT5_ORIGEM
		_cInterc:= CT5->CT5_INTERC
		_cItemD := CT5->CT5_ITEMD
		_cItemC := CT5->CT5_ITEMC
		_cCLVLDB:= CT5->CT5_CLVLDB
		_cCLVLCR:= CT5->CT5_CLVLCR
		_cTpSald:= CT5->CT5_TPSALD
		_cMltsld:= CT5->CT5_MLTSLD
		_cCtrlsd:= CT5->CT5_CTRLSD
		
		Do case
			Case _cLanpad == "500"         	//Inclusao de contas a receber
				_LpCanc :="505"
			Case _cLanpad == "501"         	//Inclusao de contas a receber antecipado
				_LpCanc :="502"
			Case _cLanpad == "508"         	//Inclusao de contas a pagar RATEIO CC E MULTIPLAS NATUREZAS
				_LpCanc :="509"                                     
			Case _cLanpad == "510"         	//Inclusao de contas a pagar
				_LpCanc :="515"                    
			Case _cLanpad == "511"         	//Inclusao de contas a pagar - RATEIO CC
				_LpCanc :="512"
			Case _cLanpad == "513"         	//Inclusao de contas a pagar - PA
				_LpCanc :="514"
			Case ALLTRIM(_cLanpad) $ "520"  //Baixa de contas a RECEBER
				_LpCanc :="527"
			Case _cLanpad == "530"         	//Baixa de contas a pagar
				_LpCanc :="531"                                         
			Case _cLanpad == "562"         	//movimento bancario a pagar
				_LpCanc :="564"                                         
			Case _cLanpad == "563"         	//movimento bancario a pagar
				_LpCanc :="565"                                         
			Case _cLanpad == "580"         	//Aplicacao financeira
				_LpCanc :="581"                                         
			Case _cLanpad == "595"         	//Faturas a receber
				_LpCanc :="592"
			Case _cLanpad == "596"         	//compensacao a receber
				_LpCanc :="588"
			Case _cLanpad == "597"         	//compensacao a pagar
				_LpCanc :="589"	
			Case _cLanpad == "610"         	//Itens do documento de saida
				_LpCanc :="630"
			Case _cLanpad == "620"         	//Documento de saida
				_LpCanc :="635"
			Case _cLanpad == "640"         	//itens Documento de entrada
				_LpCanc :="642"                      
			Case _cLanpad == "641"         	//itens Documento de entrada rateio cc
				_LpCanc :="656"
			Case _cLanpad == "650"         	//itens Documento de entrada 
				_LpCanc :="655"
			Case _cLanpad == "651"         	//itens Documento de entrada rateio cc
				_LpCanc :="656"
			Case _cLanpad == "660"         	//Documento de entrada
				_LpCanc :="665"

		Endcase
		DbselectArea("CT5")
		DbGoTop()
		DbSetOrder(1)
		DbSeek(xFilial("CT5")+_LpCanc+_cSequen,.T.)
		If found() .AND. ALLTRIM(_LpCanc) <> ""
			RecLock("CT5",.F.)
			CT5->CT5_FILIAL := _cFilial
			CT5->CT5_LANPAD := _LpCanc
			CT5->CT5_SEQUEN := _cSequen
			CT5->CT5_DESC   := "CANC. " + SUBSTR(ALLTRIM(_cDesc),1,LEN(ALLTRIM(_cDesc)))  
			CT5->CT5_STATUS := _cStatus
			CT5->CT5_DC     := if(_cDc = "3","3",if(_cDc = "2","1","2"))
			CT5->CT5_DEBITO := _cCredit
			CT5->CT5_CREDIT := _cDebito
			CT5->CT5_MOEDAS := _cMoedas
			CT5->CT5_VLR01  := _cVrl01
			CT5->CT5_VLR02  := _cVrl02
			CT5->CT5_VLR03  := _cVrl03
			CT5->CT5_VLR04  := _cVrl04
			CT5->CT5_VLR05  := _cVrl05
			CT5->CT5_HIST   := "'CANC. '+" + ALLTRIM(_cHist)
			CT5->CT5_CCD    := _cCCC
			CT5->CT5_CCC	:= _cCCD
			CT5->CT5_ORIGEM := "'LP "+_LpCanc+"/"+_cSequen + "-'"+"+SUBS(CUSUARIO,7,15) +'-'+DTOS(DDATABASE) + '-' + TIME() + '-' + DTOS(DATE())"
			CT5->CT5_INTERC := _cInterc
			CT5->CT5_ITEMD  := _cItemC
			CT5->CT5_ITEMC  := _cItemD
			CT5->CT5_CLVLDB := _cCLVLCR
			CT5->CT5_CLVLCR := _cCLVLDB
			CT5->CT5_TPSALD := _cTpSald 
			CT5->CT5_MLTSLD	:= _cMltsld
			CT5->CT5_CTRLSD := _cCtrlsd			
			MsUnLock()
		Else                   
			IF ALLTRIM(_LpCanc) <> "" //inclui
			RecLock("CT5",.T.)
			CT5->CT5_FILIAL := _cFilial
			CT5->CT5_LANPAD := _LpCanc
			CT5->CT5_SEQUEN := _cSequen
			CT5->CT5_DESC   := "CANC. " + SUBSTR(ALLTRIM(_cDesc),1,LEN(ALLTRIM(_cDesc)))
			CT5->CT5_DC     := if(_cDc = "3","3",if(_cDc = "2","1","2"))
			CT5->CT5_DEBITO := _cCredit
			CT5->CT5_CREDIT := _cDebito
			CT5->CT5_MOEDAS := _cMoedas
			CT5->CT5_VLR01  := _cVrl01
			CT5->CT5_VLR02  := _cVrl02
			CT5->CT5_VLR03  := _cVrl03
			CT5->CT5_VLR04  := _cVrl04
			CT5->CT5_VLR05  := _cVrl05
			CT5->CT5_HIST   := "' CANC. '+" + ALLTRIM(_cHist)
			CT5->CT5_CCD    := _cCCC
			CT5->CT5_CCC	:= _cCCD
			CT5->CT5_ORIGEM := "'LP "+_LpCanc+"/"+_cSequen +"'"
			CT5->CT5_INTERC := _cInterc
			CT5->CT5_ITEMD  := _cItemC
			CT5->CT5_ITEMC  := _cItemD
			CT5->CT5_CLVLDB := _cCLVLCR
			CT5->CT5_CLVLCR := _cCLVLDB
			CT5->CT5_TPSALD := _cTpSald
			MsUnLock()
			EndIF
		EndIf
		DbselectArea("CT5")
		DbGoTop()
		DbSetOrder(1) //DA0_FILIAL+DA0_CODTAB
		DbSeek(xFilial("CT5")+_cLanpad+_cSequen,.T.)
		dbSkip()
	EndDo
EndIf

MSGBOX("As alterações foram completas com sucesso!")
 
Return


Static Function ValidPerg()
Local _sAlias	:= Alias()
Local aRegs		:= {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg		:= PADR(cPerg,10)

// Grupo/Ordem/Pergunta/Perspa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Defspa1/Defeng1/Cnt01/Var02/Def02/Defspa2/Defeng2/Cnt02/Var03/Def03/Defspa3/Defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt04/Var05/Def05/Defspa5/Defeng5/Cnt05/F3
aAdd(aRegs,{cPerg,"01", "LP?"              ,"","","mv_ch1","C",3,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02", "Ate LP?"             ,"","","mv_ch2","C",3,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return
