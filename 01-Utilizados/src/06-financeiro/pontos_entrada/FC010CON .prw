#include 'protheus.ch'
#include 'parmtype.ch'
#include 'prtopdef.ch'
#include 'rwmake.ch'

/*/
===============================================================================================================================
Programa----------: FC010CON 
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 03/12/2024
===============================================================================================================================
Descrição---------: Este programa serve CRIAR O BOTAO DE CONSULTA ESPECIFICA
===============================================================================================================================
Uso---------------: FINC010 - Posição de Clientes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGAFIN
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

user function FC010CON()

	u_msgInforma('Rotina em construção')

/*	local	aArea	as object

	aArea	:= getArea()

	@ 200, 100 TO 505, 440 DIALOG oDlg2 TITLE "Selecione a Consulta Especifica"

//	@ 020, 055 BUTTON OemToAnsi(" _Cad. Produtos      ") SIZE 60,10 ACTION MATA010() .And. Close(oDlg2)
//	@ 035, 055 BUTTON OemToAnsi(" NFs _Devolucao      ") SIZE 60,10 ACTION LPCLIDEV()
//	@ 050, 055 BUTTON OemToAnsi(" NFs _Beneficiamento ") SIZE 60,10 ACTION LPCLIBEN()
//	@ 065, 055 BUTTON OemToAnsi(" NFs _Bonif. Total   ") SIZE 60,10 ACTION LPCLIOUT()
//	@ 080, 055 BUTTON OemToAnsi(" NFs Bonif. _Itens   ") SIZE 60,10 ACTION U_LPITBOM(SA1->A1_COD,SA1->A1_LOJA)
//	@ 095, 055 BUTTON OemToAnsi("      Co_missoes     ") SIZE 60,10 ACTION Comissoes()
//	@ 110, 055 BUTTON OemToAnsi(" _Produtos X Cliente ") SIZE 60,10 ACTION LPAMASA7(SA1->A1_COD,SA1->A1_LOJA,"N")
//	@ 125, 055 BUTTON OemToAnsi(" NFs Loja (Varejo)   ") SIZE 60,10 ACTION U_LPNFLOJA(SA1->A1_COD,SA1->A1_LOJA)
//	@ 125, 055 BUTTON OemToAnsi("  Títulos em aberto  ") SIZE 60,10 ACTION LPCLITIT(SA1->A1_COD,SA1->A1_LOJA)

	@ 020, 055 BUTTON OemToAnsi(" Títulos em _Aberto  ") SIZE 60,10 ACTION TABERTO()
	@ 140, 055 BUTTON OemToAnsi("         _Sair       ") SIZE 60,10 ACTION Close(oDlg2)
	ACTIVATE DIALOG oDlg2 CENTERED

	restArea(aArea)
*/
return nil

static function TABERTO()

	Processa({|| MTitAberto()},"Processando ...")

return nil

static function MTitAberto()
	aHeader  := {}
	aCols    := {}
	
	// SELECIONA SE1
	_aCpoSX3 := FwSX3Util():GetAllFields('SE1')
	
	//E1_PREFIXO
	_nPos := Ascan(_aCpoSX3,{|xCpo| Alltrim(xCpo) == "E1_PREFIXO"})
	If _nPos > 0
		Aadd (aHeader, {GetSx3Cache(_aCpoSX3[_nPos], 'X3_TITULO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CAMPO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_PICTURE')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TAMANHO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_DECIMAL')	,;
						".T."										,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_USADO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TIPO')		,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_ARQUIVO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CONTEXT')	})			
	EndIf	
	
	// E1_NUM
	_nPos := Ascan(_aCpoSX3,{|xCpo| Alltrim(xCpo) == "E1_NUM"})
	If _nPos > 0
		Aadd (aHeader, {GetSx3Cache(_aCpoSX3[_nPos], 'X3_TITULO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CAMPO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_PICTURE')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TAMANHO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_DECIMAL')	,;
						".T."										,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_USADO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TIPO')		,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_ARQUIVO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CONTEXT')	})			
	EndIf	
	
	// E1_PARCELA
	_nPos := Ascan(_aCpoSX3,{|xCpo| Alltrim(xCpo) == "E1_PARCELA"})
	If _nPos > 0
		Aadd (aHeader, {GetSx3Cache(_aCpoSX3[_nPos], 'X3_TITULO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CAMPO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_PICTURE')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TAMANHO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_DECIMAL')	,;
						".T."										,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_USADO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TIPO')		,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_ARQUIVO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CONTEXT')	})			
	EndIf				

	// E1_TIPO
	_nPos := Ascan(_aCpoSX3,{|xCpo| Alltrim(xCpo) == "E1_TIPO"})
	If _nPos > 0
		Aadd (aHeader, {GetSx3Cache(_aCpoSX3[_nPos], 'X3_TITULO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CAMPO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_PICTURE')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TAMANHO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_DECIMAL')	,;
						".T."										,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_USADO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TIPO')		,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_ARQUIVO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CONTEXT')	})	
	EndIf
	
	//E1_EMISSAO
	_nPos := Ascan(_aCpoSX3,{|xCpo| Alltrim(xCpo) == "E1_EMISSAO"})
	If _nPos > 0
		Aadd (aHeader, {GetSx3Cache(_aCpoSX3[_nPos], 'X3_TITULO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CAMPO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_PICTURE')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TAMANHO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_DECIMAL')	,;
						".T."										,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_USADO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TIPO')		,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_ARQUIVO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CONTEXT')	})			
	EndIf	
	
	//E1_VENCTO
	_nPos := Ascan(_aCpoSX3,{|xCpo| Alltrim(xCpo) == "E1_VENCTO"})
	If _nPos > 0
		Aadd (aHeader, {GetSx3Cache(_aCpoSX3[_nPos], 'X3_TITULO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CAMPO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_PICTURE')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TAMANHO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_DECIMAL')	,;
						".T."										,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_USADO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TIPO')		,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_ARQUIVO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CONTEXT')	})			
	EndIf	

	//E1_VENCREA
	_nPos := Ascan(_aCpoSX3,{|xCpo| Alltrim(xCpo) == "E1_VENCREA"})
	If _nPos > 0
		Aadd (aHeader, {GetSx3Cache(_aCpoSX3[_nPos], 'X3_TITULO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CAMPO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_PICTURE')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TAMANHO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_DECIMAL')	,;
						".T."										,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_USADO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TIPO')		,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_ARQUIVO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CONTEXT')	})			
	EndIf	

	//E1_VALOR
	_nPos := Ascan(_aCpoSX3,{|xCpo| Alltrim(xCpo) == "E1_VALOR"})
	If _nPos > 0
		Aadd (aHeader, {GetSx3Cache(_aCpoSX3[_nPos], 'X3_TITULO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CAMPO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_PICTURE')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TAMANHO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_DECIMAL')	,;
						".T."										,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_USADO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TIPO')		,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_ARQUIVO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CONTEXT')	})			
	EndIf	

	//E1_SALDO
	_nPos := Ascan(_aCpoSX3,{|xCpo| Alltrim(xCpo) == "E1_SALDO"})
	If _nPos > 0
		Aadd (aHeader, {GetSx3Cache(_aCpoSX3[_nPos], 'X3_TITULO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CAMPO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_PICTURE')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TAMANHO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_DECIMAL')	,;
						".T."										,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_USADO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_TIPO')		,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_ARQUIVO')	,;
						GetSx3Cache(_aCpoSX3[_nPos], 'X3_CONTEXT')	})			
	EndIf	

	_xVLTOTNF  := 0
	_xQTTOTNF  := 0
	
	aAreaSE1   := SE1->(GetArea())
	
	DbSelectArea("SE1")
	Processa({|| PTitAberto()},"Processando ...")
return

static function PTitAberto()
	ProcRegua(RecCount())
	
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA)
	Do While !Eof() .And. SF1->F1_FILIAL==xFilial("SF1") .And. SF1->F1_FORNECE+SF1->F1_LOJA == SA1->A1_COD+SA1->A1_LOJA
		If !(SF1->F1_TIPO $ _zTIPO)
			DbSkip()
			Loop
		Endif
		If SF1->F1_EMISSAO < _xParam1 .Or. SF1->F1_EMISSAO > _xParam2
			DbSkip()
			Loop
		Endif
		IncProc("Processando Documento "+SF1->F1_DOC+" "+SF1->F1_SERIE)
		
		_xTOTNF:=SF1->F1_VALMERC+SF1->F1_FRETE+SF1->F1_VALIPI+SF1->F1_DESPESA-SF1->F1_DESCONT
		If SF1->F1_TIPO == "N"
			_xTipo := "NF Normal"
		ElseIf SF1->F1_TIPO == "P"
			_xTipo := "NF de Compl. IPI"
		ElseIf SF1->F1_TIPO == "I"
			_xTipo := "NF de Compl. ICMS"
		ElseIf SF1->F1_TIPO == "P"
			_xTipo := "NF de Compl. IPI"
		ElseIf SF1->F1_TIPO == "C"
			_xTipo := "NF de Compl. Preco/Frete"
		ElseIf SF1->F1_TIPO == "B"
			_xTipo := "NF de Beneficiamento"
		ElseIf SF1->F1_TIPO == "D"
			_xTipo := "NF de Devolucao"
		Else
			_xTipo := ""
		Endif
		
		aAdd ( aCols , { _xTipo          ,;
		SF1->F1_DOC     ,;
		SF1->F1_EMISSAO ,;
		_xTOTNF         ,;
		SF1->F1_DUPL    ,;
		Recno() })
		_xVLTOTNF += _xTOTNF
		_xQTTOTNF += 1
		DbSelectArea("SF1")
		DbSkip()
	Enddo

	RestArea(aAreaSF1)
	
	FinalOpc()

return

/*
static function MTitAberto()
	_oSQL:= ClsSQL ():New ()
	_oSQL:_sQuery := ""
	_oSQL:_sQuery += " SELECT "
	_oSQL:_sQuery += " 	   E1_FILIAL AS FILIAL"
	_oSQL:_sQuery += "    ,E1_NUM AS TITULO "
	_oSQL:_sQuery += "    ,E1_PARCELA AS PARCELA "
	_oSQL:_sQuery += "    ,E1_TIPO AS TIPO"
	_oSQL:_sQuery += "    ,E1_CLIENTE AS CLIENTE"
	_oSQL:_sQuery += "    ,E1_LOJA AS LOJA"
	_oSQL:_sQuery += "    ,E1_NOMCLI AS NOME "
	_oSQL:_sQuery += "    ,E1_EMISSAO AS DT_EMISSAO "
	_oSQL:_sQuery += " 	  ,CONVERT(VARCHAR,CONVERT(DATE,E1_VENCTO),103) AS DT_VENC "
	_oSQL:_sQuery += " 	  ,CONVERT(VARCHAR,CONVERT(DATE,E1_VENCREA),103) AS DT_VENCREAL "
	_oSQL:_sQuery += "    ,E1_VALOR AS VALOR "
	_oSQL:_sQuery += "    ,E1_SALDO AS SALDO "
	_oSQL:_sQuery += " FROM " + RetSQLName ("SE1")
	_oSQL:_sQuery += " WHERE D_E_L_E_T_ = '' "
	_oSQL:_sQuery += " AND E1_CLIENTE   = '"+ SA1->A1_COD +"' "
	//_oSQL:_sQuery += " AND E1_LOJA      = '"+ _sLoja    +"' "
	//_oSQL:_sQuery += " AND E1_PREFIXO   = '10' "
	//_oSQL:_sQuery += " AND E1_EMISSAO BETWEEN '"+ dtos(mv_par01) +"' AND '"+ dtos(mv_par02) +"' "
	//_oSQL:_sQuery += " AND E1_VENCREA BETWEEN '"+ dtos(mv_par03) +"' AND '"+ dtos(mv_par04) +"' "
	_oSQL:_sQuery += " AND E1_SALDO > 0 "
	_oSQL:ArqDestXLS = 'MTITABERTO'
	_oSQL:Log()
	_oSQL:Qry2Xls(.F., .F., .F.)
return nil
*/
