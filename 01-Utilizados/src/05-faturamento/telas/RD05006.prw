#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'rwmake.ch'

/*/
===============================================================================================================================
Programa----------: RD05006
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 23/01/2019
===============================================================================================================================
Descrição---------: Este programa serve para visualizar o MAPA DA PRODUCAO
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
user function RD05006()

	//botoes
	Local 	btnFaturados,;
			btnGuarita,;
			btnTelha,;
			btnCorteDobra,;
			btnArmacao,;
			btnRetira,;
			btnEntParcial,;
			btnAlmox,;
			btnExpedicao,;
			btnReserva,;
			btnSaiuEnt,;
			btnSair,;
			btnDevol
	
	//GruposPainelPrincipal
	Local 	grpSituacao,;
			grpFaturados,;
			grpGuarita,;
			grpTelha,;
			grpCorteDobra,;
			grpArmacao,;
			grpEntParcial,;
			grpAlmox,;
			grpExpedicao,;
			grpRetira,;
			grpEntDireta,;
			grpReserva,;
			grpSaiuEnt,;
			grpDevol

	//Label Painel Principal
	Local 	oFaturados,;
			oGuarita,;
			oTelha,;
			oCorteDobra,;
			oArmacao,;
			oRetira,;
			oEntParcial,;
			oAlmox,;
			oExpedicao,;
			oEntDireta,;
			oReserva,;
			oSaiuEnt,;
			oDevol

	Local 	_oFaturados,;
			_oGuarita,;
			_oTelha,;
			_oCorteDobra,;
			_oArmacao,;
			_oRetira,;
			_oEntParcial,;
			_oAlmox,;
			_oExpedicao,;
			_oEntDireta,;
			_oReserva,;
			_oSaiuEnt,;
			_oDevol
			
	Local oFontSit := TFont():New("Calibri",,028,,.T.,,,,,.F.,.F.)
	Local oFontTitulo := TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)

	Local pButtom
	Local pCadastro
	Local pTitulo

	Local cVend:= ''

	cVend:= alltrim(mv_par01)
	
	//local dData	:= DDATABASE

	//Objetos usados no detalha de cada situacao
	private	aHeader	:= {}
	private aCols	:= {}

	Static oDlg01
	
	//Preenchendo os Label's do painel principal
	_oFaturados		:= FSoma('01','S',cVend) 
	_oGuarita		:= FSoma('02','S',cVend)
	_oTelha			:= FSoma('05','S',cVend)
	_oCorteDobra	:= FSoma('03','S',cVend)
	_oArmacao		:= FSoma('04','S',cVend)
	_oRetira		:= FSoma('06','S',cVend)
	_oEntParcial	:= FSoma('10','S',cVend)
	_oAlmox			:= FSoma('14','S',cVend)
	_oExpedicao		:= FSoma('07','S',cVend)
	_oEntDireta		:= FSoma('12','S',cVend)
	_oReserva		:= FSoma('13','S',cVend)
	_oSaiuEnt		:= FSoma('08','S',cVend)
	_oDevol			:= FSoma('11','S',cVend)
	
	  DEFINE MSDIALOG oDlg01 TITLE "[RD05006] - Mapa de Produção" FROM 000, 000  TO 457, 630 COLORS 0, 16777215 PIXEL
		
	    @ 000, 000 MSPANEL pTitulo PROMPT "Mapa de Produção" SIZE 313, 020 OF oDlg01 COLORS 0, 16777215 FONT oFontTitulo CENTERED RAISED
	    @ 020, 000 MSPANEL pCadastro SIZE 313, 186 OF oDlg01 COLORS 0, 16777215 RAISED
	    @ 207, 000 MSPANEL pButtom SIZE 313, 022 OF oDlg01 COLORS 0, 16777215 RAISED
	    
	    @ 003, 005 GROUP grpSituacao TO 193, 311 PROMPT "Situação dos Pedidos" OF pCadastro COLOR 0, 16777215 PIXEL

	    @ 013, 011 GROUP grpFaturados 	TO 050, 069 PROMPT "Faturados" OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 013, 071 GROUP grpGuarita 	TO 050, 128 PROMPT "Guarita" OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 013, 130 GROUP grpTelha 		TO 050, 188 PROMPT "Telha" OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 013, 190 GROUP grpCorteDobra 	TO 050, 248 PROMPT "Corte/Dobra" OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 013, 250 GROUP grpArmacao 	TO 050, 308 PROMPT "Armação" OF pCadastro COLOR 0, 16777215 PIXEL
	
	    @ 070, 011 GROUP grpEntDireta 	TO 107, 069 PROMPT "Entr. Direta" OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 070, 071 GROUP grpRetira 		TO 107, 128 PROMPT "Retira" OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 070, 130 GROUP grpEntParcial 	TO 107, 188 PROMPT "Entr. Parcial" OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 070, 190 GROUP grpAlmox 		TO 107, 248 PROMPT "Almoxarifado" OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 070, 250 GROUP grpReserva 	TO 107, 308 PROMPT "Reserva" OF pCadastro COLOR 0, 16777215 PIXEL
	
	    @ 127, 011 GROUP grpExpedicao 	TO 164, 069 PROMPT "Expedição" OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 127, 071 GROUP grpSaiuEnt 	TO 164, 128 PROMPT "Saiu Entr." OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 127, 131 GROUP grpDevol	 	TO 164, 188 PROMPT "Devolução" OF pCadastro COLOR 0, 16777215 PIXEL

	    @ 028, 012 SAY oFaturados 	PROMPT _oFaturados 	SIZE 053, 019 OF grpFaturados FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 028, 072 SAY oGuarita 	PROMPT _oGuarita 	SIZE 053, 019 OF grpGuarita FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 028, 131 SAY oTelha 		PROMPT _oTelha 		SIZE 053, 019 OF grpTelha FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 028, 191 SAY oCorteDobra 	PROMPT _oCorteDobra SIZE 053, 019 OF grpCorteDobra FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 028, 251 SAY oArmacao 	PROMPT _oArmacao 	SIZE 053, 019 OF grpArmacao FONT oFontSit COLORS 0, 16777215 PIXEL
	
	    @ 088, 012 SAY oEntDireta 	PROMPT _oEntDireta 	SIZE 053, 019 OF grpEntDireta FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 088, 072 SAY oRetira 		PROMPT _oRetira 	SIZE 053, 019 OF grpRetira FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 088, 131 SAY oEntParcial 	PROMPT _oEntParcial	SIZE 053, 019 OF grpEntParcial FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 088, 191 SAY oAlmox 		PROMPT _oAlmox	 	SIZE 053, 019 OF grpAlmox FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 088, 251 SAY oReserva 	PROMPT _oReserva 	SIZE 053, 019 OF grpReserva FONT oFontSit COLORS 0, 16777215 PIXEL

	    @ 138, 012 SAY oExpedicao 	PROMPT _oExpedicao 	SIZE 053, 019 OF grpExpedicao FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 138, 072 SAY oSaiuEnt 	PROMPT _oSaiuEnt 	SIZE 053, 019 OF grpSaiuEnt FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 138, 131 SAY oDevol		PROMPT _oDevol	 	SIZE 053, 019 OF grpDevol FONT oFontSit COLORS 0, 16777215 PIXEL

	    @ 051, 012 BUTTON btnFaturados 	PROMPT "Faturados" 		SIZE 055, 012 OF pCadastro ACTION bMostraReg('01',cVend) PIXEL
	    @ 051, 072 BUTTON btnGuarita 	PROMPT "Guarita" 		SIZE 055, 012 OF pCadastro ACTION bMostraReg('02',cVend) PIXEL
	    @ 051, 131 BUTTON btnTelha 		PROMPT "Telhas" 		SIZE 055, 012 OF pCadastro ACTION bMostraReg('05',cVend) PIXEL
	    @ 051, 191 BUTTON btnCorteDobra PROMPT "Corte/Dobra" 	SIZE 055, 012 OF pCadastro ACTION bMostraReg('03',cVend) PIXEL
	    @ 051, 251 BUTTON btnArmacao 	PROMPT "Armação" 		SIZE 055, 012 OF pCadastro ACTION bMostraReg('04',cVend) PIXEL

	    @ 108, 012 BUTTON btnEntDireta	PROMPT "Ent.Direta" 	SIZE 055, 012 OF pCadastro ACTION bMostraReg('12',cVend) PIXEL
	    @ 108, 072 BUTTON btnRetira 	PROMPT "Retira" 		SIZE 055, 012 OF pCadastro ACTION bMostraReg('06',cVend) PIXEL
	    @ 108, 131 BUTTON btnEntParcial	PROMPT "Ent.Parcial" 	SIZE 055, 012 OF pCadastro ACTION bMostraReg('10',cVend) PIXEL
	    @ 108, 191 BUTTON btnAlmox	 	PROMPT "Almoxarifado"	SIZE 055, 012 OF pCadastro ACTION bMostraReg('14',cVend) PIXEL
	    @ 108, 251 BUTTON btnExpedicao	PROMPT "Reserva" 		SIZE 055, 012 OF pCadastro ACTION bMostraReg('13',cVend) PIXEL

	    @ 165, 012 BUTTON btnReserva 	PROMPT "Expedição" 		SIZE 055, 012 OF pCadastro ACTION bMostraReg('07',cVend) PIXEL
	    @ 165, 072 BUTTON btnSaiuEnt	PROMPT "Saiu Entr." 	SIZE 055, 012 OF pCadastro ACTION bMostraReg('08',cVend) PIXEL
	    @ 165, 131 BUTTON btnDevol		PROMPT "Devolução"	 	SIZE 055, 012 OF pCadastro ACTION bMostraReg('11',cVend) PIXEL

	    @ 004, 263 BUTTON btnSair PROMPT "Sair" SIZE 037, 012 OF pButtom ACTION oDlg01:End() PIXEL

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
	mnDados(xType,'N',pVend)
	
	if xType == '01'
		cTitulo	:= '[RD05006] - DETALHE FATURADOS'
	elseif xType == '02'
		cTitulo	:= '[RD05006] - DETALHE GUARITA'
	elseif xType == '05'
		cTitulo	:= '[RD05006] - DETALHE TELHAS'
	elseif xType == '03'
		cTitulo	:= '[RD05006] - DETALHE CORTE E DOBRA'
	elseif xType == '04'
		cTitulo	:= '[RD05006] - DETALHE ARMAÇÃO'
	elseif xType == '06'
		cTitulo	:= '[RD05006] - DETALHE RETIRA'
	elseif xType == '07'
		cTitulo	:= '[RD05006] - DETALHE EXPEDIÇÃO'
	elseif xType == '12'
		cTitulo	:= '[RD05006] - DETALHE ENTREGA DIRETA'
	elseif xType == '10'
		cTitulo	:= '[RD05006] - DETALHE ENTREGA PARCIAL'
	elseif xType == '14'
		cTitulo	:= '[RD05006] - DETALHE ALMOXARIFADO'
	elseif xType == '13'
		cTitulo	:= '[RD05006] - DETALHE RESERVA'
	elseif xType == '08'
		cTitulo	:= '[RD05006] - DETALHE SAIU ENTREGA'
	elseif xType == '11'
		cTitulo	:= '[RD05006] - DETALHE DEVOLUÇÃO'
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

	@ aPosObj[3,1], aPosObj[1,4] -  40 BUTTON oButton2 PROMPT "Voltar" SIZE 040, 010 OF oDlg ACTION oDlg:End() PIXEL
	@ aPosObj[3,1], aPosObj[1,4] -  80 BUTTON oButton2 PROMPT "Detalhe" SIZE 040, 010 OF oDlg ACTION U_RD05014(xType) PIXEL
	@ aPosObj[3,1], aPosObj[1,4] - 120 BUTTON oButton2 PROMPT "Exp.Excel" SIZE 040, 010 OF oDlg ACTION ExpExcel() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED
	
return

static function FSoma(xType,cSint,pVend)
	local nRet		:= 0
	local cQuery	:= ''
	local cSintaxe	:= ''

	if alltrim(pVend) == "" .OR. alltrim(pVend) == "0"
		cSintaxe:= ', @SINT = "'+cSint+'", @VEND = NULL'
	else
		cSintaxe:= ', @SINT = "'+cSint+'", @VEND = "'+pVend+'"'
	end

	cQuery	:= "exec dbo.PR_RD05006 @TIPO = '"+xType+"'"+cSintaxe

	if select('TMP1') <> 0
		dbSelectArea('TMP1')
		TMP1->(dbCloseArea())
	endif
	
	TCQUERY cQuery NEW ALIAS 'TMP1'
	
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
	local cQuery	:= ''
	local nvLinha	:= 0
	local nLinha	:= 0
	local cSintaxe	:= ''

	if alltrim(pVend) == "" .OR. alltrim(pVend) == "0"
		cSintaxe:= ', @SINT = "'+cSint+'", @VEND = NULL'
	else
		cSintaxe:= ', @SINT = "'+cSint+'", @VEND = "'+pVend+'"'
	end

	cQuery	:= "exec dbo.PR_RD05006 @TIPO = '"+xType+"'"+cSintaxe

	if select('TMP1')
		TMP1->(dbCloseArea())
	endif
	
	TCQUERY cQuery NEW ALIAS 'TMP1'
	//cQuery	:= changeQuery(cQuery)
	//dbUseArea(.T.,'TOPCONN', tcGenQry(,, cQuery), 'TMP1', .F., .T.)
	
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
		cHeader += '						<strong>' + u_ux3Titulo('C5_XNOMCON') + '</strong></td> ' 														+ CRLF 
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
			//B - F2_SERIE 
			cBody += "					<td style='width: 100px; text-align: center;	'> &nbsp;" 	+ TMP1->F2_SERIE	  						   						+ "</td> "	+ CRLF
			//C - F2_DOC 
			cBody += "					<td style='width: 250px; text-align: center; 	'> &nbsp;" 	+ TMP1->F2_DOC	  						   							+ "</td> "	+ CRLF
			//D - C5_XNOMCON 
			cBody += "					<td style='width: 250px; text-align: left; 		'> &nbsp;" 	+ TMP1->C5_XNOMCON	  						   							+ "</td> "	+ CRLF
			//E - F2_EMISSAO 
			cBody += "					<td style='width: 100px; text-align: center;  	'> &nbsp;" 	+ dtoc(stod(TMP1->F2_EMISSAO))										+ "</td> "	+ CRLF
			//F - DTENTREGA
			cBody += "					<td style='width: 100px; text-align: center; 	'> &nbsp;" 	+ dtoc(stod(TMP1->DTENTREGA))						   				+ "</td> "	+ CRLF
			//G - ATRASADO
			cBody += "					<td style='width: 100px; text-align: center;  	'> &nbsp;" 	+ cValToChar(TMP1->ATRASADO)										+ "</td> "	+ CRLF
			//H - VLTOTAL
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP1->VLTOTAL, x3Picture('E1_VALOR'))					+ "</td> "	+ CRLF
			//I - C5_FLENT
			cBody += "					<td style='width: 100px; text-align: center;  	'> &nbsp;" 	+ TMP1->C5_FLENT													+ "</td> "	+ CRLF
			//J - F2_XVEND1
			cBody += "					<td style='width: 100px; text-align: left;  	'> &nbsp;" 	+ TMP1->F2_XVEND1													+ "</td> "	+ CRLF
			//K - F2_XDSTNOT
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
