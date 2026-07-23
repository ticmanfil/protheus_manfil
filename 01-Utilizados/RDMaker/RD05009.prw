/*/
===============================================================================================================================
Programa----------: RD05009
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 20/02/2020
===============================================================================================================================
Descrição---------: Este programa serve para mostrar os DETALHES DO PRODUTO DO CONTRATO DE ENTREGA
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
#include 'prtopdef.ch'

user function RD05009()
	
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
	
	cTitulo	:= '[RD05009] - DETALHE CONTRATO '+alltrim(ADA->ADA_NUMCTR) + ' - '+Posicione("SA1",1,xFilial("SA1")+ADA->ADA_CODCLI+ADA->ADA_LOJCLI,"A1_NOME")     

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
	local 	nvLinha	:= 0,;
			nLinha	:= 0
			
	local	cContr	:= ADA->ADA_NUMCTR,;
			nTVenda	:= 0,;
			nTEmp	:= 0,;
			nSldo	:= 0
	
	if select('TB01') <> 0
		dbSelectArea('TB01')
		TB01->(dbCloseArea())
	endif
	
	beginsql alias 'TB01'
		select distinct
			 ADB.ADB_FILIAL
			,ADB.ADB_NUMCTR
			,ADB.ADB_ITEM
			,ADB.ADB_CODPRO
			,ADB.ADB_DESPRO
			,ADB.ADB_UM
			,ADB.ADB_QUANT
			,ADB.ADB_QTDEMP

		from
			%table:ADB% ADB
		
		where
				ADB.%NotDel% 
			and ADB.ADB_FILIAL	= %xFilial:ADB% 
			and ADB.ADB_NUMCTR	= %Exp:cContr%
		
		order by
			%order:ADB,1%

	endsql
	
	dbSelectArea('TB01')
	TB01->(dbGoTop())
	aCols	:= {}
	while TB01->(!eof())
		nvLinha	:= len(aCols)+1
		aadd(aCols,array((len(aHeader)+1)))
		aCols[nvLinha][len(aHeader)+1]	:= .F.
		nLinha:= len(aCols)
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='ITEM'})]		:= TB01->ADB_ITEM
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CODPROD'})]		:= TB01->ADB_CODPRO
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PRODUTO'})]		:= TB01->ADB_DESPRO
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='UNIDADE'})]		:= TB01->ADB_UM
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='QUANTIDADE'})]	:= TB01->ADB_QUANT
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='QTDEMP'})]		:= TB01->ADB_QTDEMP
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='SLDO'})]		:= TB01->ADB_QUANT-TB01->ADB_QTDEMP
//		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PESLIQ'})]		:= U_FPedPesl(cContr,TB01->ADB_CODPRO)
//		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PESENT'})]		:= U_FPedEnt(cContr,TB01->ADB_CODPRO)
//		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PESSAL'})]		:= U_FPedPesl(cContr,TB01->ADB_CODPRO)-U_FPedEnt(cContr,TB01->ADB_CODPRO)
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='EXTRA'})]		:= ''

//		nPesLiq	+= U_FPedPesl(cContr,TB01->ADB_CODPRO)
//		nPesEnt	+= U_FPedEnt(cContr,TB01->ADB_CODPRO)
//		nPesSal	:= nPesLiq - nPesEnt

		nTVenda	+= TB01->ADB_QUANT
		nTEmp	+= TB01->ADB_QTDEMP
		nSldo	:= nTVenda-nTEmp

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

	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PRODUTO'})]		:= 'TOTAL'
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='QUANTIDADE'})]	:= nTVenda
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='QTDEMP'})]		:= nTEmp
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='SLDO'})]		:= nSldo

//	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PRODUTO'})]	:= 'TOTAL'
//	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PESLIQ'})]	:= nPesLiq
//	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PESENT'})]	:= nPesEnt
//	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PESSAL'})]	:= nPesSal
return

static function mnHeader()
	if empty(aHeader)
		aadd(aHeader,{u_ux3Titulo('ADB_ITEM')		,'ITEM'			, x3Picture('ADB_ITEM')		, tamSx3('ADB_ITEM')[1]		, tamSx3('ADB_ITEM')[2]		, '', '', 'C', '', 'V'})
		aadd(aHeader,{u_ux3Titulo('ADB_CODPRO')		,'CODPROD'		, x3Picture('ADB_CODPRO')	, tamSx3('ADB_CODPRO')[1]	, tamSx3('ADB_CODPRO')[2]	, '', '', 'C', '', 'V'})
		aadd(aHeader,{u_ux3Titulo('ADB_DESPRO')		,'PRODUTO'		, x3Picture('ADB_DESPRO')	, tamSx3('ADB_DESPRO')[1]	, tamSx3('ADB_DESPRO')[2]	, '', '', 'C', '', 'V'})
		aadd(aHeader,{u_ux3Titulo('ADB_UM')			,'UNIDADE'		, x3Picture('ADB_UM')		, tamSx3('ADB_UM')[1]		, tamSx3('ADB_UM')[2]		, '', '', 'C', '', 'V'})
		aadd(aHeader,{u_ux3Titulo('ADB_QUANT')		,'QUANTIDADE'	, x3Picture('ADB_QUANT')	, tamSx3('ADB_QUANT')[1]	, tamSx3('ADB_QUANT')[2]	, '', '', 'N', '', 'V'})
		aadd(aHeader,{u_ux3Titulo('ADB_QTDEMP')		,'QTDEMP'		, x3Picture('ADB_QTDEMP')	, tamSx3('ADB_QTDEMP')[1]	, tamSx3('ADB_QTDEMP')[2]	, '', '', 'N', '', 'V'})
		aadd(aHeader,{'Sld. Entregar'				,'SLDO'			, x3Picture('ADB_QTDEMP')	, tamSx3('ADB_QTDEMP')[1]	, tamSx3('ADB_QTDEMP')[2]	, '', '', 'N', '', 'V'})
//		aadd(aHeader,{'P. Liq Total'				,'PESLIQ'		, '@E 999,999,999.9999'		, tamSx3('F2_PLIQUI')[1]	, tamSx3('F2_PLIQUI')[2]	, '', '', 'N', '', 'V'})
//		aadd(aHeader,{'Entregue'					,'PESENT'		, '@E 999,999,999.9999'		, tamSx3('F2_PLIQUI')[1]	, tamSx3('F2_PLIQUI')[2]	, '', '', 'N', '', 'V'})
//		aadd(aHeader,{'A Entregar'					,'PESSAL'		, '@E 999,999,999.9999'		, tamSx3('F2_PLIQUI')[1]	, tamSx3('F2_PLIQUI')[2]	, '', '', 'N', '', 'V'})
		aadd(aHeader,{''							,'EXTRA'		, ''						, 1							, 0							, '', '', 'C', '', 'V'})

	endif
return
