/*/
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
#include 'parmtype.ch'
/*/
===============================================================================================================================
Programa----------: F110FIL
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 10/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para inclusao de filtro na baixa automatica
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: <programa>
===============================================================================================================================
/*/
user function F110FIL()
	
	Local _aArea		:= GetArea()
	Local cFiltro		:= ""
	Local _MV_PAR01     := MV_PAR01
	Local _MV_PAR02     := MV_PAR02
	Local _MV_PAR03     := MV_PAR03

	CriaSX1("PF110FIL")

	//Chama a tela de parametros
	If !Pergunte("PF110FIL",.T.)
		MV_PAR01 := _MV_PAR01
		MV_PAR02 := _MV_PAR02
		MV_PAR03 := _MV_PAR03
		Return(Nil)
	EndIf
	
	_cAlias  := Alias()
	RestArea(_aArea)
	dbSelectArea(_cAlias) 

	cFiltro := " E1_TIPO in ('"+StrTran(MV_PAR01, ";", "','")+"' )"
	if !empty(MV_PAR02)
		cFiltro += " AND E1_VENCTO >= '"+dtos(MV_PAR02)+"'"
		cFiltro += " AND E1_VENCTO <= '"+dtos(MV_PAR03)+"'"
	endif
	
	MV_PAR01 := _MV_PAR01
	MV_PAR02 := _MV_PAR02
	MV_PAR03 := _MV_PAR03

return cFiltro



static function CriaSX1(cPerg)

	//Grupo de Perguntas
	aHelpPor := {}
	aHelpEsp := {}
	aHelpIng := {}
	Aadd( aHelpPor, 'Tipo a selecionar separado por";" exemplo NF;DP;BOL')
	Aadd( aHelpEsp, 'Tipo a seleccionar separado por ";" ejemplo NF;DP;BOL')
	Aadd( aHelpIng, 'Type to select separated by ";" example NF;DP;BOL')
	U_xPutSX1(cPerg,"01","Tipos?"		,"Tipos?"		,"Types"		,"mv_ch1","C",30,0,1,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEsp,aHelpIng)

	aHelpPor := {}
	aHelpEsp := {}
	aHelpIng := {}
	Aadd( aHelpPor, 'Data de Vencto de";" ')
	Aadd( aHelpEsp, 'Data de Vencto de";"')
	Aadd( aHelpIng, 'Date de Vencto de";"')
	U_xPutSX1(cPerg,"02","Data de Vencto de?"		,"Data de Vencto de?"		,"Data de Vencto de?"		,"mv_ch2","D",8,0,1,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEsp,aHelpIng)

	aHelpPor := {}
	aHelpEsp := {}
	aHelpIng := {}
	Aadd( aHelpPor, 'Data de Vencto ate";" ')
	Aadd( aHelpEsp, 'Data de Vencto ate";"')
	Aadd( aHelpIng, 'Date de Vencto ate";"')
	U_xPutSX1(cPerg,"03","Data de Vencto ate?"		,"Data de Vencto ate?"		,"Data de Vencto ate?"		,"mv_ch3","D",8,0,1,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEsp,aHelpIng)

Return()