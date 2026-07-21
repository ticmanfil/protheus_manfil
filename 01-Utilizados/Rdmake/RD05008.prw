/*/
===============================================================================================================================
Programa----------: RD05008
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 05/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para mostrar o GRID os ORCAMENTOS EM ABERTOS POR VENDEDORES
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

user function RD05008()
	
	local	aObjects	:= {},;
			aPosObj		:= {},;
			aSizeAut  	:= MsAdvSize(),;
			nOpc 		:= GD_DELETE + GD_UPDATE,;
			oDlg,;
			oSay1,;
			oButton2,;
			cTitulo		:= ''

	private	aHeader	:= {},;
			aCols	:= {}


	mnHeader()
	mnDados()
	
	cTitulo	:= '[RD05008] - ACOMPANHAMENTO DOS ORCAMENTOS'

	aadd( aObjects, { 343, 200, .T., .T. } ) //Browse
	aadd( aObjects, { 280, 007, .T., .F. } ) //Linha horizontal
	aadd( aObjects, { 040, 010, .F., .F. } ) //Botao
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7]  ,00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	oBrw:= MsNewGetDados():New(aPosObj[1,2],aPosObj[1,1] -30,aPosObj[1,3],aPosObj[1,4],nOpc, "AllwaysTrue", "AllwaysTrue","" ,,, 999, "AllwaysTrue", "",  "AllwaysFalse", oDlg  ,aHeader, aCols ) //,)

	//oBrw:oBrowse:bChange := { ||  GChange() }

	oBrw:SetArray(aCols)
	oBrw:Refresh(.T.)
	oBrw:oBrowse:lUseDefaultColors := .F. // Desabilita cor padrao das linhas

	oBrw:SetEditLine(.T.)

	//oBrw:bDelOk:={||AlterDados(2)}

	//Linha horizontal
	@ 203, 005 SAY oSay1 PROMPT Repl("_",295) SIZE 280, 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL
	@ aPosObj[2,1], aPosObj[2,2] SAY oSay1 PROMPT Repl("_",aPosObj[1,4]) SIZE aPosObj[1,4], 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL

	@ aPosObj[3,1], aPosObj[1,4] - 40 BUTTON oButton2 PROMPT "Sair" SIZE 040, 010 OF oDlg ACTION oDlg:End() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

return

static function mnDados()
	local cQuery	:= ''
	local nvLinha	:= 0
	local nLinha	:= 0
	local cPerg		:= 'RD05008'
	
	CriaPergunta(cPerg)
	
	if !Pergunte(cPerg,.T.)
		return
	endif

	if select('TB01') <> 0
		dbSelectArea('TB01')
		TB01->(dbCloseArea())
	endif
	
	cQuery	:= 'exec dbo.PR_RD05008A'
	
	//cQuery	:= changeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS 'TB01'
	
	dbSelectArea('TB01')
	TB01->(dbGoTop())
	aCols	:= {}
	while TB01->(!eof())
		nvLinha	:= len(aCols)+1
		aadd(aCols,array((len(aHeader)+1)))
		aCols[nvLinha][len(aHeader)+1]	:= .F.
		nLinha:= len(aCols)
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDEDOR'})]	:= TB01->VENDEDOR
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='QTD'})]			:= TB01->QTD
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='TIME'})]		:= TB01->TIME
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MESATUAL'})]	:= TB01->MESATUAL
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MESANTERIOR'})]	:= TB01->MESANTERIOR
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DEMAISMESES'})]	:= TB01->DEMAISMESES

		TB01->(dbSkip())
	enddo

	TB01->(dbCloseArea())
	
	nvLinha	:= len(aCols)+1
	aadd(aCols,array((len(aHeader)+1)))
	aCols[nvLinha][len(aHeader)+1]	:= .F.
	nLinha:= len(aCols)

	nvLinha	:= len(aCols)+1
	aadd(aCols,array((len(aHeader)+1)))
	aCols[nvLinha][len(aHeader)+1]	:= .F.
	nLinha:= len(aCols)

	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDEDOR'})]	:= 'MOTIVO DE CANCELAMENTO'

	nvLinha	:= len(aCols)+1
	aadd(aCols,array((len(aHeader)+1)))
	aCols[nvLinha][len(aHeader)+1]	:= .F.
	nLinha:= len(aCols)

	cQuery	:= 'exec dbo.PR_RD05008B @DTINI = "'+DTOS(mv_par01)+'", @DTFIN = "'+DTOS(mv_par02)+'"'
	
	//cQuery	:= changeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS 'TB01'
	
	dbSelectArea('TB01')
	TB01->(dbGoTop())
//	aCols	:= {}
	while TB01->(!eof())
		nvLinha	:= len(aCols)+1
		aadd(aCols,array((len(aHeader)+1)))
		aCols[nvLinha][len(aHeader)+1]	:= .F.
		nLinha:= len(aCols)
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDEDOR'})]	:= TB01->MBQ_DSCVEP
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='QTD'})]			:= TB01->QTD

		TB01->(dbSkip())
	enddo

	TB01->(dbCloseArea())

return

static function mnHeader()
	if empty(aHeader)
		aadd(aHeader,{u_ux3Titulo('A3_NREDUZ')		,'VENDEDOR'			, x3Picture('A3_NREDUZ')		, tamSx3('A3_NREDUZ')[1]		, tamSx3('A3_NREDUZ')[2]		, '', '', 'C', '', 'V'})
		aadd(aHeader,{'QTD'							,'QTD'				, '@E 999,999,999'				, 6								, 0								, '', '', 'N', '', 'V'})
		aadd(aHeader,{'TIME'						,'TIME'				, '@E 999,999,999'				, 6								, 0								, '', '', 'N', '', 'V'})
		aadd(aHeader,{'MESATUAL'					,'MESATUAL'			, '@E 999,999,999'				, 6								, 0								, '', '', 'N', '', 'V'})
		aadd(aHeader,{'MESANTERIOR'					,'MESANTERIOR'		, '@E 999,999,999'				, 6								, 0								, '', '', 'N', '', 'V'})
		aadd(aHeader,{'DEMAISMESES'					,'DEMAISMESES'		, '@E 999,999,999'				, 6								, 0								, '', '', 'N', '', 'V'})

	endif
return


static function CriaPergunta(cPerg)
	U_XPUTSX1(cPerg, "01", "Data Inicial?"		, "", "", "mv_ch1", "D", 8, 0, 0, "G", "", "", "", "", "mv_par01")
	U_XPUTSX1(cPerg, "02", "Data Final?"		, "", "", "mv_ch2", "D", 8, 0, 0, "G", "", "", "", "", "mv_par02")
return