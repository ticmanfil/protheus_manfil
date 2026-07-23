/*/
===============================================================================================================================
Programa----------: RD05007
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 05/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para mostrar o GRID com os custos dos produtos
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
#include 'rwmake.ch'

user function RD05007(_cFilial, cNumOrc)
	
	local	aObjects	:= {},;
			aPosObj		:= {},;
			aSizeAut  	:= MsAdvSize(),;
			nOpc 		:= GD_UPDATE,; //GD_INSERT + GD_UPDATE + GD_DELETE 
			oDlg,;
			oSay1,;
			oButton2,;
			nMarg		:= 1.2,;
			cPerg		:= 'RD05007'

	private	aHeader	:= {},;
			aCols	:= {},;
			cTitulo	:= ''
			
	CriaPergunta(cPerg)
	
	if !Pergunte(cPerg,.T.)
		return
	else
		nMarg	:= mv_par01
	endif

	mnHeader()
	mnDados(_cFilial, cNumOrc, nMarg, 1)
	
	cTitulo	:= '[RD05007] - ORÇAMENTO POR CUSTO - '+alltrim(cNumOrc)

	aadd( aObjects, { 343, 200, .T., .T. } ) //Browse
	aadd( aObjects, { 280, 007, .T., .F. } ) //Linha horizontal
	aadd( aObjects, { 040, 010, .F., .F. } ) //Botao
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7]  ,00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	oBrw:= MsNewGetDados():New(aPosObj[1,2],aPosObj[1,1] -30,aPosObj[1,3],aPosObj[1,4],nOpc, 'AllwaysTrue', 'AllwaysTrue','' ,{'CK_XCUSTO'},, 999, 'AllwaysTrue', '',  'AllwaysTrue', oDlg  ,aHeader, aCols, {||  GChange(nMarg), oBrw:Refresh() })

	oBrw:oBrowse:bChange := { ||  GChange(nMarg) }

	oBrw:SetArray(aCols)
	oBrw:Refresh(.T.)
	oBrw:oBrowse:lUseDefaultColors := .F. // Desabilita cor padrao das linhas

	oBrw:SetEditLine(.T.)

	//oBrw:bDelOk:={||AlterDados(2)}

	//Linha horizontal
	@ 203, 005 SAY oSay1 PROMPT Repl("_",295) SIZE 280, 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL
	@ aPosObj[2,1], aPosObj[2,2] SAY oSay1 PROMPT Repl("_",aPosObj[1,4]) SIZE aPosObj[1,4], 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL

	@ aPosObj[3,1], aPosObj[1,4] - 40 BUTTON oButton2 PROMPT "Sair" SIZE 040, 010 OF oDlg ACTION oDlg:End() PIXEL
	@ aPosObj[3,1], aPosObj[1,4] - 150 BUTTON oButton1 PROMPT "Confirmar" SIZE 070, 010 OF oDlg ACTION MsAguarde({|| bSalvar(oDlg, _cFilial, cNumOrc, cTitulo)},'Orçamentos','Aguarde, gravando registros',.F.)  PIXEL
	@ aPosObj[3,1], aPosObj[1,4] - 260 BUTTON oButton1 PROMPT "Alterar Margem" SIZE 100, 010 OF oDlg ACTION MsAguarde({|| bAlMargem(_cFilial, cNumOrc, cPerg, nMarg)},'Orçamento','Aguarde, atualizando o custos...',.F.)  PIXEL
	@ aPosObj[3,1], aPosObj[1,4] - 370 BUTTON oButton1 PROMPT "Exp. p/ Excel" SIZE 100, 010 OF oDlg ACTION MsAguarde({|| bExpExcel(oDlg, _cFilial, cNumOrc)},'Orçamento','Aguarde, exportando para excel...',.F.)  PIXEL
	@ aPosObj[3,1], aPosObj[1,4] - 480 BUTTON oButton1 PROMPT "Recarga Custo" SIZE 100, 010 OF oDlg ACTION MsAguarde({|| mnDados(_cFilial, cNumOrc, nMarg)},'Orçamento','Aguarde, recarregando custo...',.F.)  PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

return

static function mnDados(_cFilial, cNumOrc, nMarg, opcao)
	local 	cQuery		:= '',;
			nvLinha		:= 0,;
			nLinha		:= 0,;
			nTotalPeso	:= 0,;
			nVlTotal	:= 0,;
			nCustoTotal	:= 0,;
			nTotal		:= 0,;
			lCustoPad	as logical

	lCustoPad	:= .F.
	
	if opcao != 1
		oBrw:refresh(.T.)
	endif

	if select('TB01') <> 0
		dbSelectArea('TB01')
		TB01->(dbCloseArea())
	endif
	
	cQuery	:= 'exec dbo.PR_RD05007 @FILIAL = '+chr(39)+_cFilial+chr(39)+', @NUMORC = '+chr(39)+cNumOrc+chr(39)
	
	TCQUERY cQuery NEW ALIAS 'TB01'
	
	dbSelectArea('TB01')
	TB01->(dbGoTop())

	nvLinha		:= 0
	nLinha		:= 0
	nTotalPeso	:= 0
	nVlTotal	:= 0
	nCustoTotal	:= 0
	nTotal		:= 0
	aCols		:= {}
	
	if apMsgYesNo('Deseja carregar o custo padrão?')
		lCustoPad	:= .T.
	else
		mv_par01	:= TB01->CK_XMARGEM
	endif
	
	while TB01->(!eof())
		nvLinha	:= len(aCols)+1
		aadd(aCols,array((len(aHeader)+1)))
		aCols[nvLinha][len(aHeader)+1]	:= .F.
		nLinha:= len(aCols)
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_ITEM'})]		:= TB01->CK_ITEM
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_DESCRI'})]	:= TB01->CK_DESCRI
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_QTDVEN'})]	:= TB01->CK_QTDVEN
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_UM'})]		:= TB01->CK_UM
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XUNSVEN'})]	:= TB01->CK_XUNSVEN
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XSEGUM'})]	:= TB01->CK_XSEGUM
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XPESUNI'})]	:= TB01->CK_XPESUNI
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XPESO'})]	:= TB01->CK_XPESO
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_PRCVEN'})]	:= TB01->CK_PRCVEN
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_VALOR'})]	:= TB01->CK_VALOR
		if lCustoPad
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XCC2UM'})]	:= TB01->B1_CUSTOSEG
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XCUSTO'})]	:= TB01->B1_CUSTO
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XCUSTOT'})]	:= TB01->B1_CUSTO*TB01->CK_QTDVEN
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XPRVALT'})]	:= (TB01->B1_CUSTO*nMarg)
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XPRCTOT'})]	:= (TB01->B1_CUSTO*nMarg)*TB01->CK_QTDVEN
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XMARGEM'})]	:= nMarg
		else
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XCC2UM'})]	:= TB01->CK_XCC2UM
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XCUSTO'})]	:= TB01->CK_XCUSTO
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XCUSTOT'})]	:= TB01->CK_XCUSTOT
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XPRVALT'})]	:= TB01->CK_XPRVALT
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XPRCTOT'})]	:= TB01->CK_XPRCTOT
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XMARGEM'})]	:= TB01->CK_XMARGEM
		endif
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_NUM'})]		:= TB01->CK_NUM
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_PRUNIT'})]	:= TB01->CK_PRUNIT
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_TES'})]		:= TB01->CK_TES
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XTIPCON'})]	:= TB01->CK_XTIPCON
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XCONV'})]	:= TB01->CK_XCONV
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='B1_CUSTO'})]	:= TB01->B1_CUSTO
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='B1_UPRC'})]		:= TB01->B1_UPRC
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='B1_UCOM'})]		:= TB01->B1_UCOM
		
		nTotalPeso	+= TB01->CK_XPESO
		nVlTotal	+= TB01->CK_VALOR
		if lCustoPad
			nCustoTotal	+= TB01->B1_CUSTO*TB01->CK_QTDVEN
			nTotal		+= (TB01->B1_CUSTO*nMarg)*TB01->CK_QTDVEN
		else
			nCustoTotal	+= CK_XCUSTOT
			nTotal		+= CK_XPRCTOT
		endif
		TB01->(dbSkip())
	enddo
	TB01->(dbCloseArea())

	//LINHA TOTALIZADOR
	nvLinha	:= len(aCols)+1
	aadd(aCols,array((len(aHeader)+1)))
	aCols[nvLinha][len(aHeader)+1]	:= .F.
	nLinha:= len(aCols)
	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XPESO'})]	:= nTotalPeso
	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_VALOR'})]	:= nVlTotal
	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XCUSTOT'})]	:= nCustoTotal
	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XPRCTOT'})]	:= nTotal
	
	if opcao != 1
		oBrw:SetArray(aCols)
		oBrw:refresh(.T.)
	endif
	
return


static function mnHeader()
	if empty(aHeader)
	/*01*/	aadd(aHeader,{u_ux3Titulo('CK_ITEM')		,'CK_ITEM'			, x3Picture('CK_ITEM')			, tamSx3('CK_ITEM')[1]			, tamSx3('CK_ITEM')[2]			, '', '', 'C', '', 'V'})
	/*02*/	aadd(aHeader,{u_ux3Titulo('CK_DESCRI')		,'CK_DESCRI'		, x3Picture('CK_DESCRI')		, tamSx3('CK_DESCRI')[1]		, tamSx3('CK_DESCRI')[2]		, '', '', 'C', '', 'V'})
	/*03*/	aadd(aHeader,{u_ux3Titulo('CK_QTDVEN')		,'CK_QTDVEN'		, x3Picture('CK_QTDVEN')		, tamSx3('CK_QTDVEN')[1]		, tamSx3('CK_QTDVEN')[2]		, '', '', 'N', '', 'V'})
	/*04*/	aadd(aHeader,{u_ux3Titulo('CK_UM')			,'CK_UM'			, x3Picture('CK_UM')			, tamSx3('CK_UM')[1]			, tamSx3('CK_UM')[2]			, '', '', 'C', '', 'V'})
	/*05*/	aadd(aHeader,{u_ux3Titulo('CK_XUNSVEN')		,'CK_XUNSVEN'		, x3Picture('CK_XUNSVEN')		, tamSx3('CK_XUNSVEN')[1]		, tamSx3('CK_XUNSVEN')[2]		, '', '', 'N', '', 'V'})
	/*06*/	aadd(aHeader,{u_ux3Titulo('CK_XSEGUM')		,'CK_XSEGUM'		, x3Picture('CK_XSEGUM')		, tamSx3('CK_XSEGUM')[1]		, tamSx3('CK_XSEGUM')[2]		, '', '', 'C', '', 'V'})
	/*07*/	aadd(aHeader,{u_ux3Titulo('CK_PRCVEN')		,'CK_PRCVEN'		, x3Picture('CK_PRCVEN')		, tamSx3('CK_PRCVEN')[1]		, tamSx3('CK_PRCVEN')[2]		, '', '', 'N', '', 'V'})
	/*08*/	aadd(aHeader,{u_ux3Titulo('CK_VALOR')		,'CK_VALOR'			, x3Picture('CK_VALOR')			, tamSx3('CK_VALOR')[1]			, tamSx3('CK_VALOR')[2]			, '', '', 'N', '', 'V'})
	/*09*/	aadd(aHeader,{u_ux3Titulo('CK_XCUSTO')		,'CK_XCUSTO'		, x3Picture('CK_XCUSTO')		, tamSx3('CK_XCUSTO')[1]		, tamSx3('CK_XCUSTO')[2]		, '', '', 'N', '', 'V'})
	/*10*/	aadd(aHeader,{u_ux3Titulo('CK_XCUSTOT')		,'CK_XCUSTOT'		, x3Picture('CK_XCUSTOT')		, tamSx3('CK_XCUSTOT')[1]		, tamSx3('CK_XCUSTOT')[2]		, '', '', 'N', '', 'V'})
	/*11*/	aadd(aHeader,{u_ux3Titulo('CK_XMARGEM')		,'CK_XMARGEM'		, x3Picture('CK_XMARGEM')		, tamSx3('CK_XMARGEM')[1]		, tamSx3('CK_XMARGEM')[2]		, '', '', 'N', '', 'V'})
	/*12*/	aadd(aHeader,{u_ux3Titulo('CK_XPRCTOT')		,'CK_XPRCTOT'		, x3Picture('CK_XPRCTOT')		, tamSx3('CK_XPRCTOT')[1]		, tamSx3('CK_XPRCTOT')[2]		, '', '', 'N', '', 'V'})
	/*13*/	aadd(aHeader,{u_ux3Titulo('CK_XPRVALT')		,'CK_XPRVALT'		, x3Picture('CK_XPRVALT')		, tamSx3('CK_XPRVALT')[1]		, tamSx3('CK_XPRVALT')[2]		, '', '', 'N', '', 'V'})
	/*14*/	aadd(aHeader,{u_ux3Titulo('CK_XCC2UM')		,'CK_XCC2UM'		, x3Picture('CK_XCC2UM')		, tamSx3('CK_XCC2UM')[1]		, tamSx3('CK_XCC2UM')[2]		, '', '', 'N', '', 'V'})
	/*15*/	aadd(aHeader,{u_ux3Titulo('CK_XPESUNI')		,'CK_XPESUNI'		, x3Picture('CK_XPESUNI')		, tamSx3('CK_XPESUNI')[1]		, tamSx3('CK_XPESUNI')[2]		, '', '', 'N', '', 'V'})
	/*16*/	aadd(aHeader,{u_ux3Titulo('CK_XPESO')		,'CK_XPESO'			, x3Picture('CK_XPESO')			, tamSx3('CK_XPESO')[1]			, tamSx3('CK_XPESO')[2]			, '', '', 'N', '', 'V'})
	/*17*/	aadd(aHeader,{u_ux3Titulo('CK_NUM')			,'CK_NUM'			, x3Picture('CK_NUM')			, tamSx3('CK_NUM')[1]			, tamSx3('CK_NUM')[2]			, '', '', 'C', '', 'V'})
	/*18*/	aadd(aHeader,{u_ux3Titulo('CK_PRUNIT')		,'CK_PRUNIT'		, x3Picture('CK_PRUNIT')		, tamSx3('CK_PRUNIT')[1]		, tamSx3('CK_PRUNIT')[2]		, '', '', 'N', '', 'V'})
	/*19*/	aadd(aHeader,{u_ux3Titulo('CK_TES')			,'CK_TES'			, x3Picture('CK_TES')			, tamSx3('CK_TES')[1]			, tamSx3('CK_TES')[2]			, '', '', 'C', '', 'V'})
	/*20*/	aadd(aHeader,{u_ux3Titulo('CK_XTIPCON')		,'CK_XTIPCON'		, x3Picture('CK_XTIPCON')		, tamSx3('CK_XTIPCON')[1]		, tamSx3('CK_XTIPCON')[2]		, '', '', 'N', '', 'V'})
	/*21*/	aadd(aHeader,{u_ux3Titulo('CK_XCONV')		,'CK_XCONV'			, x3Picture('CK_XCONV')			, tamSx3('CK_XCONV')[1]			, tamSx3('CK_XCONV')[2]			, '', '', 'N', '', 'V'})
	/*22*/	aadd(aHeader,{u_ux3Titulo('B1_CUSTO')		,'B1_CUSTO'			, x3Picture('B1_CUSTO')			, tamSx3('B1_CUSTO')[1]			, tamSx3('B1_CUSTO')[2]			, '', '', 'N', '', 'V'})
	/*23*/	aadd(aHeader,{u_ux3Titulo('B1_UPRC')		,'B1_UPRC'			, x3Picture('B1_UPRC')			, tamSx3('B1_UPRC')[1]			, tamSx3('B1_UPRC')[2]			, '', '', 'N', '', 'V'})
	/*24*/	aadd(aHeader,{u_ux3Titulo('B1_UCOM')		,'B1_UCOM'			, x3Picture('B1_UCOM')			, tamSx3('B1_UCOM')[1]			, tamSx3('B1_UCOM')[2]			, '', '', 'D', '', 'V'})
	endif
return

static function bSalvar(oDlg, _cFilial, cNumOrc, cTitulo)

	local 	nI		:= 0,;
			lRet	:= .T.
	
	local oDlgD, oGet01, oGet02, oGet03, nOpca
	
	local	nVlTBrut	:= 0,;
			nIndeniz	:= 0,;
			nVlTLiq		:= 0
	
	if fValSalva()
		//Confirma arrendondamento
		
		nVlTBrut	:= fTotal()
		nIndeniz	:= 0
		nVlTLiq		:= nVlTBrut
		
		SetPrvt('oDlg1','oSay1','oSay2','oSay3','oSay4','oSay5','oSay6','oSBtnOk','oSBtnCan','oMGet1')
		
		DEFINE MSDIALOG oDlgD TITLE cTitulo From 0,0 TO 175,530 PIXEL
		
		@ 010,004 SAY OemToAnsi('Vl. Total:') SIZE 073,008 OF oDlgD PIXEL
		@ 010,060 MSGET oGet01 VAR nVlTBrut SIZE 052,008 WHEN .F. PICTURE x3Picture('CK_XPRCTOT') OF oDlgD PIXEL
		
		@ 025,004 SAY OemToAnsi('Desc. Geral:') SIZE 073,008 OF oDlgD PIXEL
		@ 025,060 MSGET oGet02 VAR nIndeniz SIZE 052,008 PICTURE x3Picture('CK_XPRCTOT') VALID fValid(oDlgD, nVlTBrut, nIndeniz, nVlTLiq, oGet02, oGet03) OF oDlgD PIXEL
		
		@ 040,004 SAY OemToAnsi('Vl. Total a Salvar:') SIZE 073,008 OF oDlgD PIXEL
		@ 040,060 MSGET oGet03 VAR nVlTLiq SIZE 052,008 WHEN .F. PICTURE x3Picture('CK_XPRCTOT') VALID fValid(oDlgD, nVlTBrut, nIndeniz, nVlTLiq, oGet02, oGet02) OF oDlgD PIXEL
	
		DEFINE SBUTTON FROM 70, 206 When .T. TYPE 19 ACTION (oDlgD:End(),nOpca:='1') ENABLE OF oDlgD
		DEFINE SBUTTON FROM 70, 234 When .T. TYPE 20 ACTION (oDlgD:End(),nOpca:='2') ENABLE OF oDlgD
		
		ACTIVATE MSDIALOG oDlgD CENTERED	
	
		//SALVA ORCAMENTO
		if nOpca == '1'
			lMsErroAuto	:= .F.
			begin transaction
		
				if RecLock('SCJ',.F.)
					SCJ->CJ_DESCONT	:= nIndeniz
					SCJ->(MsUnlock())
				endif
	
				dbSelectArea('SCK')
				SCK->(dbSetOrder(1))
			    for nI := 1 to len(oBrw:aCols)-1
			    	if SCK->(dbSeek(xFilial('SCK')+cNumOrc+oBrw:aCols[nI][01]))
						if RecLock('SCK',.F.)
							SCK->CK_PRCVEN	:= oBrw:aCols[nI][13]
							SCK->CK_XPRVALT	:= oBrw:aCols[nI][13]
	
							SCK->CK_VALOR	:= oBrw:aCols[nI][12]
							SCK->CK_XPRCTOT	:= oBrw:aCols[nI][12]
	
							SCK->CK_XCUSTO 	:= oBrw:aCols[nI][09]
							SCK->CK_XCC2UM	:= oBrw:aCols[nI][14]
							SCK->CK_XCUSTOT	:= oBrw:aCols[nI][10]
							SCK->CK_XMARGEM	:= oBrw:aCols[nI][11]
	
							SCK->CK_DESCONT	:= round((1-(SCK->CK_PRCVEN/SCK->CK_PRUNIT))*100,2)			//(1-(CK_PRCVEN/CK_PRUNIT)*100)	
							SCK->CK_VALDESC	:= round((SCK->CK_PRUNIT-SCK->CK_PRCVEN)*SCK->CK_QTDVEN,2)	//(CK_PRUNIT/CK_PRCVEN)*CK_QTDVEN                                                   
	
							SCK->(msUnlock())
						endif
					endif
				next nI
					
				if lMsErroAuto
					disarmtransaction()
					MostraErro()
					lRet	:= .F.
		
				endif
			end transaction
			
			if lRet
				apMsgInfo('Alteração Orçamento realizado com sucesso!','[RD05007] - ORÇAMENTO POR CUSTO')
				oDlg:End()
			endif
		endif
	endif
return

static function bAlMargem(_cFilial, cNumOrc, cPerg, nMarg)

	if !Pergunte(cPerg,.T.)
		return
	else
		nMarg	:= mv_par01
	endif

	fRecalcula(nMarg)
	
return

static function fRecalcula(nMarg)

	local 	nI			:= 0,;
			nTotal		:= 0,;
			nTotalCusto	:= 0
	
	for nI := 1 to len(oBrw:aCols)
		if nI != len(oBrw:aCols)
			oBrw:aCols[nI][11]	:= nMarg											//  atualiza o campo CK_XMARGEM
			oBrw:aCols[nI][10]	:= oBrw:aCols[nI][03]*oBrw:aCols[nI][09]			//  atualiza o campo CK_XCUSTOT
			oBrw:aCols[nI][13]	:= oBrw:aCols[nI][09]*nMarg							//  atualiza o campo CK_XPRVALT
			oBrw:aCols[nI][12]	:= oBrw:aCols[nI][03]*(oBrw:aCols[nI][09]*nMarg)	//  atualiza o campo CK_XPRCTOT
			nTotalCusto			+= oBrw:aCols[nI][03]*oBrw:aCols[nI][09]
			nTotal				+= oBrw:aCols[nI][03]*(oBrw:aCols[nI][09]*nMarg)
		else
			oBrw:aCols[nI][10]	:= nTotalCusto
			oBrw:aCols[nI][12]	:= nTotal 

		endif

	next nI
	
	oBrw:Refresh()

return

static function CriaPergunta(cPerg)
	U_XPUTSX1(cPerg, "01", "Margem?"		, "", "", "mv_ch1", "N", 4, 2, 0, "G", "", "", "", "", "mv_par01")
return

static function GChange(nMarg)
	fRecalcula(nMarg)
return

static function bExpExcel(oDlg, _cFilial, cNumOrc)

	if bSlvExp(oDlg, _cFilial, cNumOrc)
		u_RL05003(cNumOrc)
	endif

return .T.

static function bSlvExp(oDlg, _cFilial, cNumOrc)

	local 	nI			:= 0,;
			lRet		:= .T.
	
	lMsErroAuto	:= .F.
	begin transaction

		if RecLock('SCJ',.F.)
			SCJ->CJ_DESCONT	:= 0
			SCJ->(MsUnlock())
		endif

		dbSelectArea('SCK')
		SCK->(dbSetOrder(1))
	    for nI := 1 to len(oBrw:aCols)-1
	    	if SCK->(dbSeek(xFilial('SCK')+cNumOrc+oBrw:aCols[nI][01]))
				if RecLock('SCK',.F.)
					SCK->CK_XCUSTO 	:= oBrw:aCols[nI][09]
					SCK->CK_XCC2UM	:= oBrw:aCols[nI][14]
					SCK->CK_XCUSTOT	:= oBrw:aCols[nI][10]
					SCK->CK_XPRVALT	:= oBrw:aCols[nI][13]
					SCK->CK_XPRCTOT	:= oBrw:aCols[nI][12]
					SCK->CK_XMARGEM	:= oBrw:aCols[nI][11]
					SCK->(msUnlock())
				endif
			endif
		next nI
			
		if lMsErroAuto
			disarmtransaction()
			MostraErro()
			lRet	:= .F.

		endif
	end transaction

return lRet

static function fTotal()
	local 	nI			:= 0,;
			nTotal		:= 0
			
	for nI := 1 to len(oBrw:aCols)
		if nI != len(oBrw:aCols)
			nTotal	+= oBrw:aCols[nI][12]
		endif
	next nI

return nTotal
	
static function fValid(oDlgD, nVlTBrut, nIndeniz, nVlTLiq, oGet02, oGet03)

	nVlTLiq	:= nVlTBrut - nIndeniz

	oGet02:refresh()
	oGet03:refresh()
	//oDlgD:refresh()

return .T.

static function fValSalva()
	local	nI		:= 0,;
			lRet	:= .T.

    for nI := 1 to len(oBrw:aCols)-1
    	if oBrw:aCols[nI][11] = 0
    		apMsgAlerta('O item '+cValToChar(oBrw:aCols[nI][01])+' está com VALOR TOTAL ZERADO!!!...'+CRLF+'Favor corrigir.',cTitulo)
    		lRet	:= .F.
		endif
	next nI

return lRet
