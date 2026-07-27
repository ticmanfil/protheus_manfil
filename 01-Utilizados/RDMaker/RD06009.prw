#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'TbiCode.ch'
#include 'rwmake.ch'

/*/
===============================================================================================================================
Programa----------: RD06009
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 11/09/2019
===============================================================================================================================
Descrição---------: Este programa serve para Demonstrativo Conciliacao de Cartao
===============================================================================================================================
Uso---------------: MV06001 - Concilacao dos Cartoes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FINANCEIRO
===============================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor	|	Data	|										Motivo																
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|           | 																										
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			|																											
=====================================================================================================================================
/*/

user function RD06009()

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
	
	cTitulo	:= '[RD06009] - CONCILIACAO CARTAO REDE'

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
	//@ 203, 005 SAY oSay1 PROMPT Repl("_",295) SIZE 280, 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL
	@ aPosObj[2,1], aPosObj[2,2] SAY oSay1 PROMPT Repl("_",aPosObj[1,4]) SIZE aPosObj[1,4], 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL

	@ aPosObj[3,1], aPosObj[1,4] - 40 BUTTON oButton2 PROMPT "Sair" SIZE 040, 010 OF oDlg ACTION oDlg:End() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

return

static function mnDados()
	local cQuery	:= ''
	local nvLinha	:= 0
	local nLinha	:= 0
	local cPerg		:= 'RD06009'

	local	nVlVenda	:= 0,;
			nVlTaxas	:= 0,;
			nVlReceb	:= 0,;
			nVlCancel	:= 0,;
			nVlOutDev	:= 0,;
			nVlSaldo	:= 0,;
			nVlSldAnt	:= 0,;
			nVlSldPro	:= 0,;
			nVlSldRec	:= 0,;
			nLancFut	:= 0,;
			nData		:= 0,;
			cData		:= ''

	CriaPergunta(cPerg)
	
	if !Pergunte(cPerg,.T.)
		return
	endif

/*	if select('TB01') <> 0
		dbSelectArea('TB01')
		TB01->(dbCloseArea())
	endif
	
	cQuery	:= 'exec dbo.PR_RD06009A @DATA = "'+DTOS(mv_par01)+'", @BANCO = "RED", @AGE = "00001", @CONTA = "0000000001"'
	
	TCQUERY cQuery NEW ALIAS 'TB01'
	
	dbSelectArea('TB01')
	TB01->(dbGoTop())
	if TB01->(!eof())
		nVlSaldo	:= TB01->E8_SALATUA
		nVlSldAnt	:= nVlSaldo
		nVlSldPro	:= nVlSaldo

	endif
*/

	cData:= DTOS(mv_par01)
	nVlSaldo	:= FSldPro(cData)
	nVlSldAnt	:= nVlSaldo
	nVlSldPro	:= nVlSaldo
	nVlSldRec	:= FSldRec(cData)

	aCols	:= {}
	nvLinha	:= len(aCols)+1
	aadd(aCols,array((len(aHeader)+1)))
	aCols[nvLinha][len(aHeader)+1]	:= .F.
	nLinha:= len(aCols)

	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='E5_DATA'})]		:= '**** SLD INI ******'
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='SLDATU'})]		:= nVlSaldo
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='SLDPRO'})]		:= nVlSldPro
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='SLDREC'})]		:= nVlSldRec
	if nVlSaldo != nVlSldPro
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DIVERG'})]		:= '*'
	elseif nVlSaldo != nVlSldRec
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DIVERG'})]		:= '*'
	elseif nVlSldPro != nVlSldRec
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DIVERG'})]		:= '*'
	endif

	cQuery	:= 'exec dbo.PR_RD06009 @DTINI = "'+DTOS(mv_par01)+'", @DTFIN = "'+DTOS(mv_par02)+'", @BANCO = "RED", @AGE = "00001", @CONTA = "0000000001"'
	
	//cQuery	:= changeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS 'TB01'
	
	dbSelectArea('TB01')
	TB01->(dbGoTop())
	while TB01->(!eof())
		nvLinha	:= len(aCols)+1
		aadd(aCols,array((len(aHeader)+1)))
		aCols[nvLinha][len(aHeader)+1]	:= .F.
		nLinha:= len(aCols)
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='E5_DATA'})]		:= TB01->E5_DATA
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDA'})]		:= TB01->VENDA
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='TAXAS'})]		:= TB01->TAXAS
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='RECEB'})]		:= TB01->RECEB
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CANCEL'})]		:= TB01->CANCEL
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='OUTDEV'})]		:= TB01->TXDEV
		
		nVlVenda	+= TB01->VENDA
		nVlTaxas	+= TB01->TAXAS
		nVlReceb	+= TB01->RECEB
		nVlCancel	+= TB01->CANCEL
		nVlOutDev	+= TB01->TXDEV
		nVlSaldo	+= TB01->VENDA-TB01->TAXAS-TB01->RECEB-TB01->CANCEL+TB01->TXDEV

		nLancFut	:= nVlSldAnt-TB01->RECEB-TB01->CANCEL+TB01->TXDEV
		nVlSldAnt	:= nVlSaldo
	
		cData:= DTOS(CTOD(TB01->E5_DATA))
		nData:= Val(cData)
		nData:= nData+1
		cData:= CValToChar(nData)
		nVlSldPro:= FSldPro(cData)
		nVlSldRec:= FSldRec(cData)

		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='SLDATU'})]		:= nVlSaldo
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='SLDPRO'})]		:= nVlSldPro
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='LANCFUT'})]		:= nLancFut
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='SLDREC'})]		:= nVlSldRec
		if nVlSaldo != nVlSldPro
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DIVERG'})]		:= '*'
		elseif nVlSaldo != nVlSldRec
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DIVERG'})]		:= '*'
		elseif nVlSldPro != nVlSldRec
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DIVERG'})]		:= '*'
		endif

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

	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='E5_DATA'})]		:= '**** TOTAL ******'
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDA'})]		:= nVlVenda
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='TAXAS'})]		:= nVlTaxas
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='RECEB'})]		:= nVlReceb
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CANCEL'})]		:= nVlCancel
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='OUTDEV'})]		:= nVlOutDev
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='SLDATU'})]		:= nVlSaldo
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='SLDPRO'})]		:= nVlSldPro
	aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='SLDREC'})]		:= nVlSldRec
	
return

static function mnHeader()
	if empty(aHeader)
		aadd(aHeader,{u_ux3Titulo('E5_DATA')		,'E5_DATA'		, x3Picture('E5_DATA')			, tamSx3('E5_DATA')[1]			, tamSx3('E5_DATA')[2]			, '', '', valtype('E5_DATA'), '', 'V'})
		aadd(aHeader,{'VENDA(+)'					,'VENDA'		, '@E 999,999,999.99'			, 16							, 2								, '', '', 'N', '', 'V'})
		aadd(aHeader,{'TAXAS(-)'					,'TAXAS'		, '@E 999,999,999.99'			, 16							, 2								, '', '', 'N', '', 'V'})
		aadd(aHeader,{'RECEB(=)'					,'RECEB'		, '@E 999,999,999.99'			, 16							, 2								, '', '', 'N', '', 'V'})
		aadd(aHeader,{'CANCEL(-)'					,'CANCEL'		, '@E 999,999,999.99'			, 16							, 2								, '', '', 'N', '', 'V'})
		aadd(aHeader,{'TX CANCEL'					,'OUTDEV'		, '@E 999,999,999.99'			, 16							, 2								, '', '', 'N', '', 'V'})
		aadd(aHeader,{'SLD ATUAL'					,'SLDATU'		, '@E 999,999,999.99'			, 16							, 2								, '', '', 'N', '', 'V'})
		aadd(aHeader,{'SLD PROT'					,'SLDPRO'		, '@E 999,999,999.99'			, 16							, 2								, '', '', 'N', '', 'V'})
		aadd(aHeader,{'SLD REC'						,'SLDREC'		, '@E 999,999,999.99'			, 16							, 2								, '', '', 'N', '', 'V'})
		aadd(aHeader,{'DIVERG'						,'DIVERG'		, ''							, 1								, 0								, '', '', 'C', '', 'V'})
		aadd(aHeader,{'LANC FUT'					,'LANCFUT'		, '@E 999,999,999.99'			, 16							, 2								, '', '', 'N', '', 'V'})
		aadd(aHeader,{''							,'OUTRAS'		, '@E 999,999,999.99'			, 16							, 2								, '', '', 'N', '', 'V'})

	endif
return


static function CriaPergunta(cPerg)
	U_XPUTSX1(cPerg, "01", "Data Inicial?"		, "", "", "mv_ch1", "D", 8, 0, 0, "G", "", "", "", "", "mv_par01")
	U_XPUTSX1(cPerg, "02", "Data Final?"		, "", "", "mv_ch2", "D", 8, 0, 0, "G", "", "", "", "", "mv_par02")
return

static function FSldPro(pData)
	local nSaldo:= 0

	if select('TBTMP') <> 0
		dbSelectArea('TBTMP')
		TBTMP->(dbCloseArea())
	endif
	
	cQuery	:= 'exec dbo.PR_RD06009A @DATA = "'+pData+'", @BANCO = "RED", @AGE = "00001", @CONTA = "0000000001"'
	
	TCQUERY cQuery NEW ALIAS 'TBTMP'
	
	dbSelectArea('TBTMP')
	TBTMP->(dbGoTop())
	if TBTMP->(!eof())
		nSaldo	:= TBTMP->E8_SALATUA
	endif

	if select('TBTMP') <> 0
		dbSelectArea('TBTMP')
		TBTMP->(dbCloseArea())
	endif

return nSaldo

static function FSldRec(pData)
	local nSaldo:= 0

	if select('TBTMP') <> 0
		dbSelectArea('TBTMP')
		TBTMP->(dbCloseArea())
	endif
	
	cQuery	:= 'exec dbo.PR_RD06009A @DATA = "'+pData+'", @BANCO = "RED", @AGE = "00001", @CONTA = "0000000001"'
	
	TCQUERY cQuery NEW ALIAS 'TBTMP'
	
	dbSelectArea('TBTMP')
	TBTMP->(dbGoTop())
	if TBTMP->(!eof())
		nSaldo	:= TBTMP->E8_SALRECO
	endif

	if select('TBTMP') <> 0
		dbSelectArea('TBTMP')
		TBTMP->(dbCloseArea())
	endif

return nSaldo
