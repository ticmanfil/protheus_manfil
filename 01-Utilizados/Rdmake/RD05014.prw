#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'rwmake.ch'

/*/
===============================================================================================================================
Programa----------: RD05014
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 08/10/2025
===============================================================================================================================
Descrição---------: Este programa serve para visualizar o DETALHE MAPA DA PRODUCAO
===============================================================================================================================
Uso---------------: PRODUCAO
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: PRODUCAO
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
user function RD05014(xType)

	if xType == '03'		//CORTE E DOBRA
		CorteDobra(xType)
	elseif xType == '05'	//TELHA
		Telha(xType)
	else
		u_msgInformacao('Situção sem DETALHE!')
	endif

return

static function CorteDobra(xType)

	//botoes
	Local 	btnAEntrar	as object,;
			btnEntProd	as object,;
			btnAgRet	as object,;
			btnVoltar	as object
	
	//GruposPainelPrincipal
	Local 	grpAEntrar	as object,;
			grpEntProd	as object,;
			grpAgRet	as object
			
	Local 	oAEntrar	as object,;
			oEntProd	as object,;
			oAgRetira	as object

	Local 	_oAEntrar	as object,;
			_oEntProd	as object,;
			_oAgRet		as object

	local	oFontSit	as object,;
			oFontTitulo	as object

	local	pButtom		as object,;
			pCadastro	as object,;
			pTitulo		as object

	local	cVend		as caractere

	private	aHeader		as array,;
			aCols		as array

	Static oDlg01
	
	aHeader		:= {}
	aCols		:= {}
	oFontSit 	:= TFont():New("Calibri",,028,,.T.,,,,,.F.,.F.)
	oFontTitulo	:= TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)

	cVend:= alltrim(mv_par01)

	//Preenchendo os Label's do painel principal
	_oAEntrar	:= FSoma(xType,'S',cVend) 
	_oEntProd	:= FSoma('31','S',cVend) 
	_oAgRet		:= FSoma('39','S',cVend)

//	nQtd:= val(_oAEntrar)-val(_oEntProd) - val(_oAgRet)
//	_oAEntrar	:= transform(nQtd,'@E 999.999')

	DEFINE MSDIALOG oDlg01 TITLE "[RD05014] - Mapa de Produção OS" FROM 000, 000  TO 457, 630 COLORS 0, 16777215 PIXEL
	
		//paineis
		@ 000, 000 MSPANEL pTitulo PROMPT "Mapa de Produção OS" SIZE 313, 020 OF oDlg01 COLORS 0, 16777215 FONT oFontTitulo CENTERED RAISED
		@ 020, 000 MSPANEL pCadastro SIZE 313, 186 OF oDlg01 COLORS 0, 16777215 RAISED
		@ 207, 000 MSPANEL pButtom SIZE 313, 022 OF oDlg01 COLORS 0, 16777215 RAISED
		
		//grupos
		@ 003, 005 GROUP grpSituacao 	TO 193, 311 PROMPT "Situação dos Pedidos" OF pCadastro COLOR 0, 16777215 PIXEL

		@ 013, 011 GROUP grpAEntrar 	TO 050, 069 PROMPT "A Entrar" OF pCadastro COLOR 0, 16777215 PIXEL
		@ 013, 071 GROUP grpEntProd 	TO 050, 128 PROMPT "Entrada na Produção" OF pCadastro COLOR 0, 16777215 PIXEL
		@ 013, 130 GROUP grpAgRet	 	TO 050, 188 PROMPT "Ag Retirada" OF pCadastro COLOR 0, 16777215 PIXEL

		//label	
		@ 028, 012 SAY oAEntrar 	PROMPT _oAEntrar 	SIZE 053, 019 OF grpAEntrar FONT oFontSit COLORS 0, 16777215 PIXEL
		@ 028, 072 SAY oEntProd 	PROMPT _oEntProd 	SIZE 053, 019 OF grpEntProd FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 028, 131 SAY oAgRetira 	PROMPT _oAgRet	 	SIZE 053, 019 OF grpAgRet FONT oFontSit COLORS 0, 16777215 PIXEL

		//botoes
		@ 051, 012 BUTTON btnAEntrar 	PROMPT "A Entrar"		SIZE 055, 012 OF pCadastro ACTION bMostraReg('03',cVend) PIXEL
		@ 051, 072 BUTTON btnEntProd 	PROMPT "Ent Produção"	SIZE 055, 012 OF pCadastro ACTION bMostraReg('31',cVend) PIXEL
		@ 051, 131 BUTTON btnAgRet		PROMPT "Ag. Retirada"	SIZE 055, 012 OF pCadastro ACTION bMostraReg('39',cVend) PIXEL

		@ 004, 263 BUTTON btnVoltar PROMPT "Voltar" SIZE 037, 012 OF pButtom ACTION oDlg01:End() PIXEL

	ACTIVATE MSDIALOG oDlg01 CENTERED

return

static function Telha(xType)

	//botoes
	Local 	btnAEntrar	as object,;
			btnEntProd	as object,;
			btnRetirado	as object,;
			btnColagem	as object,;
			btnCura		as object,;
			btnAgRet	as object,;
			btnVoltar	as object
	
	//GruposPainelPrincipal
	Local 	grpAEntrar	as object,;
			grpEntProd	as object,;
			grpRetirado	as object,;
			grpColagem	as object,;
			grpCura		as object,;
			grpAgRet	as object
			
	Local 	oAEntrar	as object,;
			oEntProd	as object,;
			oRetirado	as object,;
			oColagem	as object,;
			oCura		as object,;
			oAgRetira	as object

	Local 	_oAEntrar	as object,;
			_oEntProd	as object,;
			_oRetirado	as object,;
			_oColagem	as object,;
			_oCura		as object,;
			_oAgRet		as object

	local	oFontSit	as object,;
			oFontTitulo	as object

	local	pButtom		as object,;
			pCadastro	as object,;
			pTitulo		as object

	local	cVend		as caractere

	private	aHeader		as array,;
			aCols		as array

	Static oDlg01
	
	aHeader		:= {}
	aCols		:= {}
	oFontSit 	:= TFont():New("Calibri",,028,,.T.,,,,,.F.,.F.)
	oFontTitulo	:= TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)

	cVend:= alltrim(mv_par01)

	//Preenchendo os Label's do painel principal
	_oAEntrar	:= FSoma(xType,'S',cVend) 
	_oEntProd	:= FSoma('51','S',cVend) 
	_oRetirado	:= FSoma('52','S',cVend)
	_oColagem	:= FSoma('53','S',cVend)
	_oCura		:= FSoma('54','S',cVend)
	_oAgRet		:= FSoma('55','S',cVend)

	//nQtd:= val(_oAEntrar)-val(_oEntProd) - val(_oRetirado) - val(_oColagem) - val(_oCura) - val(_oAgRet)
	//_oAEntrar	:= transform(nQtd,'@E 999,999')

	DEFINE MSDIALOG oDlg01 TITLE "[RD05014] - Mapa de Produção OS" FROM 000, 000  TO 457, 630 COLORS 0, 16777215 PIXEL
	
		//paineis
		@ 000, 000 MSPANEL pTitulo PROMPT "Mapa de Produção OS" SIZE 313, 020 OF oDlg01 COLORS 0, 16777215 FONT oFontTitulo CENTERED RAISED
		@ 020, 000 MSPANEL pCadastro SIZE 313, 186 OF oDlg01 COLORS 0, 16777215 RAISED
		@ 207, 000 MSPANEL pButtom SIZE 313, 022 OF oDlg01 COLORS 0, 16777215 RAISED
		
		//grupos
		@ 003, 005 GROUP grpSituacao 	TO 193, 311 PROMPT "Situação dos Pedidos" OF pCadastro COLOR 0, 16777215 PIXEL

		@ 013, 011 GROUP grpAEntrar 	TO 050, 069 PROMPT "A Entrar" OF pCadastro COLOR 0, 16777215 PIXEL
		@ 013, 071 GROUP grpEntProd 	TO 050, 128 PROMPT "Entrada na Produção" OF pCadastro COLOR 0, 16777215 PIXEL

		@ 070, 011 GROUP grpRetirado 	TO 107, 069 PROMPT "Retirado da Maquina" OF pCadastro COLOR 0, 16777215 PIXEL
		@ 070, 071 GROUP grpColagem		TO 107, 128 PROMPT "Colagem" OF pCadastro COLOR 0, 16777215 PIXEL
		@ 070, 130 GROUP grpCura	 	TO 107, 188 PROMPT "Cura" OF pCadastro COLOR 0, 16777215 PIXEL
		@ 070, 190 GROUP grpAgRet	 	TO 107, 248 PROMPT "Ag Retirada" OF pCadastro COLOR 0, 16777215 PIXEL

		//label	
		@ 028, 012 SAY oAEntrar 	PROMPT _oAEntrar 	SIZE 053, 019 OF grpAEntrar FONT oFontSit COLORS 0, 16777215 PIXEL
		@ 028, 072 SAY oEntProd 	PROMPT _oEntProd 	SIZE 053, 019 OF grpEntProd FONT oFontSit COLORS 0, 16777215 PIXEL
	
		@ 088, 012 SAY oRetirado 	PROMPT _oRetirado 	SIZE 053, 019 OF grpRetirado FONT oFontSit COLORS 0, 16777215 PIXEL
		@ 088, 072 SAY oColagem		PROMPT _oColagem 	SIZE 053, 019 OF grpColagem FONT oFontSit COLORS 0, 16777215 PIXEL
		@ 088, 131 SAY oCura	 	PROMPT _oCura		SIZE 053, 019 OF grpCura FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 088, 191 SAY oAgRetira 	PROMPT _oAgRet	 	SIZE 053, 019 OF grpAgRet FONT oFontSit COLORS 0, 16777215 PIXEL

		//botoes
		@ 051, 012 BUTTON btnAEntrar 	PROMPT "A Entrar"		SIZE 055, 012 OF pCadastro ACTION bMostraReg('05',cVend) PIXEL
		@ 051, 072 BUTTON btnEntProd 	PROMPT "Ent Produção"	SIZE 055, 012 OF pCadastro ACTION bMostraReg('51',cVend) PIXEL

		@ 108, 012 BUTTON btnRetirado	PROMPT "Retirado"	 	SIZE 055, 012 OF pCadastro ACTION bMostraReg('52',cVend) PIXEL
		@ 108, 072 BUTTON btnColagem 	PROMPT "Colagem" 		SIZE 055, 012 OF pCadastro ACTION bMostraReg('53',cVend) PIXEL
		@ 108, 131 BUTTON btnCura		PROMPT "Cura" 			SIZE 055, 012 OF pCadastro ACTION bMostraReg('54',cVend) PIXEL
		@ 108, 191 BUTTON btnAgRet		PROMPT "Ag. Retirada"	SIZE 055, 012 OF pCadastro ACTION bMostraReg('55',cVend) PIXEL

		@ 004, 263 BUTTON btnVoltar PROMPT "Voltar" SIZE 037, 012 OF pButtom ACTION oDlg01:End() PIXEL

	ACTIVATE MSDIALOG oDlg01 CENTERED

return

static function bMostraReg(xType,pVend)

	local	aObjects	:= {},;
			aPosObj		:= {},;
			aSizeAut  	:= MsAdvSize(),;
			nOpc 		:= GD_DELETE + GD_UPDATE,;
			oDlg,;
			oSay1,;
			oButton2,;
			cTitulo		:= ''

	mnHeader()
	mnDados(xType,'D',pVend)
	
	//CORTE E DOBRA
	if xType	== '03'
		cTitulo	:= '[RD05014] - DETALHE A ENTRAR CORTE E DOBRA'
	elseif xType == '31'
		cTitulo	:= '[RD05014] - DETALHE ENTRADA CORTE E DOBRA'
	elseif xType	== '39'
		cTitulo	:= '[RD05014] - DETALHE AGUARDANDO RETIRADA'

	//TELHA
	elseif xType == '05'
		cTitulo	:= '[RD05014] - DETALHE A ENTRAR PRODUCAO'
	elseif xType == '51'
		cTitulo	:= '[RD05014] - DETALHE ENTRADA PRODUCAO'
	elseif xType == '52'
		cTitulo	:= '[RD05014] - DETALHE RETIRADA MAQUINA'
	elseif xType == '53'
		cTitulo	:= '[RD05014] - DETALHE COLAGEM'
	elseif xType == '54'
		cTitulo	:= '[RD05014] - DETALHE CURA'
	elseif xType == '55'
		cTitulo	:= '[RD05014] - DETALHE AGUARDANDO RETIRADA'
	endif
	
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

	oBrw:SetEditLine(.F.)

	//oBrw:bDelOk:={||AlterDados(2)}

	//Linha horizontal
	//@ 203, 005 SAY oSay1 PROMPT Repl("_",295) SIZE 280, 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL
	@ aPosObj[2,1], aPosObj[2,2] SAY oSay1 PROMPT Repl("_",aPosObj[1,4]) SIZE aPosObj[1,4], 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL

	@ aPosObj[3,1], aPosObj[1,4] - 40 BUTTON oButton2 PROMPT "Voltar" SIZE 040, 010 OF oDlg ACTION oDlg:End() PIXEL
	@ aPosObj[3,1], aPosObj[1,4] - 80 BUTTON oButton2 PROMPT "Exp.Excel" SIZE 040, 010 OF oDlg ACTION ExpExcel() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED
	
return

static function FSoma(xType,cSint,pVend)

	local	nRet		as numeric,;
			cQry		as caractere,;
			cSintaxe	as caractere

	nRet		:= 0
	cQry		:= ''
	cSintaxe	:= ''

	if alltrim(pVend) == "" .OR. alltrim(pVend) == "0"
		cSintaxe:= ', @SINT = "'+cSint+'", @VEND = NULL'
	else
		cSintaxe:= ', @SINT = "'+cSint+'", @VEND = "'+pVend+'"'
	end

	cQry	:= "exec dbo.PR_RD05006 @TIPO = '"+alltrim(xType)+"' "+cSintaxe
	
	if select('TMP1') <> 0
		dbSelectArea('TMP1')
		TMP1->(dbCloseArea())
	endif
	
	TCQUERY cQry NEW ALIAS 'TMP1'
	
	dbSelectArea('TMP1')
	TMP1->(dbGoTop())
	while !eof()
		nRet	:= transform(TMP1->QUANT,'@E 999,999')
		TMP1->(dbSkip())
	enddo
	TMP1->(dbCloseArea())

return nRet

static function bSair(oDlg01)

	oDlg01:End()
	
return

static function mnHeader()
	if empty(aHeader)
		aadd(aHeader,{'Item'					,'ITEM'			, '@!'						, 06						, 0, '', '', 'C', '', 'V'})
		aadd(aHeader,{U_UX3Titulo('F2_SERIE')	,'F2_SERIE'		, x3Picture('F2_SERIE')		, tamSx3('F2_SERIE')[1]		, 0, '', '', 'C', '', 'V'})
		aadd(aHeader,{U_UX3Titulo('F2_DOC')		,'F2_DOC'		, x3Picture('F2_DOC')		, tamSx3('F2_DOC')[1]		, 0, '', '', 'C', '', 'V'})
		aadd(aHeader,{U_UX3Titulo('F2_EMISSAO')	,'F2_EMISSAO'	, x3Picture('F2_EMISSAO')	, tamSx3('F2_EMISSAO')[1]	, 0, '', '', 'D', '', 'V'})
		aadd(aHeader,{'Dt Entrega'				,'DTENTREGA'	, x3Picture('F2_EMISSAO')	, tamSx3('F2_EMISSAO')[1]	, 0, '', '', 'D', '', 'V'})
		aadd(aHeader,{'Atrasado'				,'ATRASADO'		, '@!'						, 06						, 0, '', '', 'C', '', 'V'})
		aadd(aHeader,{U_UX3Titulo('F2_XTOTAL')	,'F2_XTOTAL'	, x3Picture('F2_XTOTAL')	, tamSx3('F2_XTOTAL')[1]	, 0, '', '', 'N', '', 'V'})
		aadd(aHeader,{U_UX3Titulo('C5_FLENT')	,'C5_FLENT'		, x3Picture('C5_FLENT')		, tamSx3('C5_FLENT')[1]		, 0, '', '', 'C', '', 'V'})
		aadd(aHeader,{U_UX3Titulo('F2_XVEND1')	,'F2_XVEND1'	, x3Picture('F2_XVEND1')	, tamSx3('F2_XVEND1')[1]	, 0, '', '', 'C', '', 'V'})
		aadd(aHeader,{U_UX3Titulo('F2_XDSTNOT')	,'F2_XDSTNOT'	, x3Picture('F2_XDSTNOT')	, tamSx3('F2_XDSTNOT')[1]	, 0, '', '', 'C', '', 'V'})
		aadd(aHeader,{U_UX3Titulo('C5_XNOMCON')	,'C5_XNOMCON'	, x3Picture('C5_XNOMCON')	, tamSx3('C5_XNOMCON')[1]	, 0, '', '', 'C', '', 'V'})
	endif
	
return

static function mnDados(xType,cSint,pVend)
	local	cQry		as caractere,;
			nvLinha		as caractere,;
			cSintaxe	as caractere

	cQry		:= ''
	nvLinha		:= 0
	nLinha		:= 0
	cSintaxe	:= ''

	if alltrim(pVend) == "" .OR. alltrim(pVend) == "0"
		cSintaxe:= ', @SINT = "'+cSint+'", @VEND = NULL'
	else
		cSintaxe:= ', @SINT = "'+cSint+'", @VEND = "'+pVend+'"'
	end

	cQry:= "exec dbo.PR_RD05006 @TIPO = '"+alltrim(xType)+"' "+cSintaxe

	if select('TMP1')
		TMP1->(dbCloseArea())
	endif
	
	TCQUERY cQry NEW ALIAS 'TMP1'
	
	TMP1->(dbGoTop())
	aCols	:= {}
	while TMP1->(!eof())
		nvLinha	:= len(aCols)+1
		aadd(aCols,array((len(aHeader)+1)))
		aCols[nvLinha][len(aHeader)+1]	:= .F.
		nLinha:= len(aCols)
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='ITEM'})]		:= PADL(cValToChar(nLinha),6,'0')
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='F2_SERIE'})]	:= TMP1->F2_SERIE
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='F2_DOC'})]		:= TMP1->F2_DOC
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='F2_EMISSAO'})]	:= stod(TMP1->F2_EMISSAO)
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DTENTREGA'})]	:= stod(TMP1->DTENTREGA)
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='ATRASADO'})]	:= padl(cValToChar(TMP1->ATRASADO),6,'0')
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='F2_XTOTAL'})]	:= TMP1->VLTOTAL
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='C5_FLENT'})]	:= TMP1->C5_FLENT
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='F2_XVEND1'})]	:= TMP1->F2_XVEND1
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='F2_XDSTNOT'})]	:= TMP1->F2_XDSTNOT
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='C5_XNOMCON'})]	:= TMP1->C5_XNOMCON
				
		TMP1->(dbSkip())
	enddo
return

static function CriaPergunta(cPerg)
	U_XPUTSX1(cPerg, "01", "Data Base ?"		, "", "", "mv_ch1", "D", 8, 2, 0, "G", "", "", "", "", "mv_par01")
return

static function ExpExcel()
	local	cDirDocs	as caracter,;
			nHandle		as numeric,;
			cArquivo	as array,;
			cPath		as caracter,;
			oExcelApp	as object
	
	local	cQry		as caracter,;
			cBody		as caracter,;
			cHeader		as caracter,;
			cTrailer	as caracter,;
			nLinha		as numeric

	cDirDocs	:= msDocPath()
	cArquivo	:= CriaTrab(,.F.)
	cPath		:= alltrim(GetTempPath())

	cQry		:= ''
	cBody		:= ''
	cHeader		:= ''
	cTrailer	:= ''
	nLinha		:= 0

	nHandle		:= msfCreate(cDirDocs+'\'+cArquivo+'.xls',0)
	if nHandle > 0
		//cabecalho
		procRegua(reccount())

		//cabecalho   
		cHeader := ' <html> ' 																																+ CRLF 
		cHeader += ' 	<head> ' 																															+ CRLF
		cHeader += '		<title>Editor HTML Online</title> ' 																							+ CRLF
		cHeader += '	</head> ' 																															+ CRLF
		cHeader += '	<body> ' 																															+ CRLF
		cHeader += '		<div> ' 																														+ CRLF
		cHeader += '			<p>&nbsp;</p> ' 																											+ CRLF
		cHeader += '		</div> ' 																														+ CRLF
		cHeader += '		<table style="width: 100%;" border="1" cellpadding="1" cellspacing="1"> ' 														+ CRLF
		cHeader += '			<tbody> ' 																													+ CRLF
	 	cHeader += '				<tr> ' 																													+ CRLF 
		cHeader += '					<td style="text-align: center; width: 50px; background-color: rgb(204, 204, 204);"> ' 				  			   + CRLF 
		cHeader += '						<strong>ITEM</strong></td> ' 											   										+ CRLF 
		cHeader += '					<td style="text-align: center; width: 50px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('F2_SERIE') + '</strong></td> '															+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('F2_DOC') + '</strong></td> ' 															+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('C5_XNOMCON') + '</strong></td> ' 															+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('F2_EMISSAO') + '</strong></td> ' 														+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('C5_FECENT') + '</strong></td> ' 														+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>ATRASADO</strong></td> ' 																				+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('F2_XTOTAL') + '</strong></td> ' 														+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('C5_FLENT')	+ '</strong></td> ' 														+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('F2_XVEND1') + '</strong></td> ' 														+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('F2_XDSTNOT') + '</strong></td> ' 														+ CRLF 
		cHeader += '				</tr> '  													   															+ CRLF 
		fwrite(nHandle, cHeader)

		nLinha:= 0
		TMP1->(dbGoTop())
		while !TMP1->(eof())
			nLinha += 1
			cBody := "				<tr> " 																					   								  	   					+ CRLF
			//A - C6_ITEM 
			cBody += "					<td style='width: 050px; text-align: center;	'> &nbsp;" 	+ cValToChar(nlinha) 					   							+ "</td> "	+ CRLF
			//B - C6_PRODUTO 
			cBody += "					<td style='width: 100px; text-align: center;	'> &nbsp;" 	+ TMP1->F2_SERIE	  						   						+ "</td> "	+ CRLF
			//C - C6_DESCRI 
			cBody += "					<td style='width: 250px; text-align: center; 	'> &nbsp;" 	+ TMP1->F2_DOC	  						   							+ "</td> "	+ CRLF
			//C - C6_DESCRI 
			cBody += "					<td style='width: 250px; text-align: left; 		'> &nbsp;" 	+ TMP1->C5_XNOMCON	  						   							+ "</td> "	+ CRLF
			//D - C6_UNSVEN 
			cBody += "					<td style='width: 100px; text-align: center;  	'> &nbsp;" 	+ dtoc(stod(TMP1->F2_EMISSAO))										+ "</td> "	+ CRLF
			//E - C6_SEGUM
			cBody += "					<td style='width: 100px; text-align: center; 	'> &nbsp;" 	+ dtoc(stod(TMP1->DTENTREGA))						   				+ "</td> "	+ CRLF
			//F - C6_XPRSEGU
			cBody += "					<td style='width: 100px; text-align: center;  	'> &nbsp;" 	+ cValToChar(TMP1->ATRASADO)										+ "</td> "	+ CRLF
			//G - C6_VALOR
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP1->VLTOTAL, x3Picture('E1_VALOR'))					+ "</td> "	+ CRLF
			//H - C6_DESCONT
			cBody += "					<td style='width: 100px; text-align: center;  	'> &nbsp;" 	+ TMP1->C5_FLENT													+ "</td> "	+ CRLF
			//I - C6_XPEM2
			cBody += "					<td style='width: 100px; text-align: left;  	'> &nbsp;" 	+ TMP1->F2_XVEND1													+ "</td> "	+ CRLF
			//J - PESO TOTAL
			cBody += "					<td style='width: 100px; text-align: left;  	'>&nbsp; " 	+ TMP1->F2_XDSTNOT													+ "</td> "	+ CRLF
			cBody += "				</tr> " 																	 								   									+ CRLF
			fwrite(nHandle, cBody)  
			TMP1->(dbSkip())
		enddo 

		//rodape
		cTrailer := "				<tr> " 														 		   																				+ CRLF 
		cTrailer += "					<td style='width: 100px; text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='width: 100px; text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='width: 100px; text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='width: 100px; text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='width: 100px; text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='width: 100px; text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='width: 100px; text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='width: 100px; text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='width: 100px; text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='width: 100px; text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='width: 100px; text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "				</tr> " 																	 									   									+ CRLF         
	
		fwrite(nHandle, cTrailer) 
		fClose(nHandle)
		CpyS2T(cDirDocs+'\'+cArquivo+'.xls' , cPath, .T. )   
		
		if ! ApOleClient( 'MsExcel' )
			MsgAlert( "Excel nao instalado!" ) //'MsExcel nao instalado'
			return
		endif
		
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".xls" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)
		oExcelApp:destroy()

	endif

return
