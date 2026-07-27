#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'rwmake.ch'

static oBmpOK	:= loadBitmap(getResource(), 'LBOK')
static oBmpNO	:= loadBitmap(getResource(), 'LBNO')

/*/
===============================================================================================================================
Programa----------: RD06013
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 19/03/2026
===============================================================================================================================
Descrição---------: Este programa serve para visualizar o MAPA dos PEDIDOS DE VENDAS E SUAS LOCALIDADES
===============================================================================================================================
Uso---------------: FINANCEIRO
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FINANCEIRO
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
user function RD06013()

	//botoes
	Local 	btnSair				as object,;
			btnAbertos			as object,;
			btnCancelados		as object,;
			btnDevoldidos		as object,;
			btnBaixados			as object,;
			btnDemaisDoc		as object,;
			btnSeqNaoIdentic	as object
			
	
	//GruposPainelPrincipal
	Local 	grpSituacao			as object,;
			grpAbertos			as object,;
			grpCancelados		as object,;
			grpDevolvidos		as object,;
			grpBaixados			as object,;
			grpDemaisDoc		as object,;
			grpSeqNaoIdentic	as object

	//Label Painel Principal
	Local 	oAbertos			as object,;
			oCancelados			as object,;
			oDevolvidos			as object,;
			oBaixados			as object,;
			oDemaisDoc			as object,;
			oSeqNaoIdentic		as object

	Local	aTotalizador		as array

	Local	oFontSit			as object,;
			oFontTitulo			as object

	Local 	pButtom				as object,;
			pCadastro			as object,;
			pTitulo				as object

	Static 	oDlg01				as object	
	
	oFontSit 	:= TFont():New("Calibri",,028,,.T.,,,,,.F.,.F.)
	oFontTitulo := TFont():New("MS Sans Serif",,020,,.T.,,,,,.F.,.F.)

	//Preenchendo os Label's do painel principal
	PKPi(@aTotalizador)
	
	DEFINE MSDIALOG oDlg01 TITLE "[RD06013] - Mapa dos Pedidos" FROM 000, 000  TO 457, 630 COLORS 0, 16777215 PIXEL
		
		@ 000, 000 MSPANEL pTitulo PROMPT "Mapa dos Pedidos" SIZE 313, 020 OF oDlg01 COLORS 0, 16777215 FONT oFontTitulo CENTERED RAISED
	    @ 020, 000 MSPANEL pCadastro SIZE 313, 186 OF oDlg01 COLORS 0, 16777215 RAISED
	    @ 207, 000 MSPANEL pButtom SIZE 313, 022 OF oDlg01 COLORS 0, 16777215 RAISED
	    
	    @ 003, 005 GROUP grpSituacao TO 193, 311 PROMPT "Situação dos Pedidos" OF pCadastro COLOR 0, 16777215 PIXEL

	    @ 013, 011 GROUP grpAbertos 		TO 050, 069 PROMPT "Abertos" 	OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 013, 071 GROUP grpCancelados 		TO 050, 128 PROMPT "Cancelados" OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 013, 130 GROUP grpDevolvidos		TO 050, 188 PROMPT "Devoldidos" OF pCadastro COLOR 0, 16777215 PIXEL
	    @ 013, 190 GROUP grpBaixados 		TO 050, 248 PROMPT "Baixados" 	OF pCadastro COLOR 0, 16777215 PIXEL

	    @ 070, 011 GROUP grpDemaisDoc 		TO 107, 069 PROMPT "Demais Documentos" OF pCadastro COLOR 0, 16777215 PIXEL
		@ 070, 071 GROUP grpSeqNaoIdentic 	TO 107, 128 PROMPT "Seq. n/ Identificada" OF pCadastro COLOR 0, 16777215 PIXEL
	
	    @ 028, 012 SAY oAbertos 			PROMPT aTotalizador[1] 	SIZE 053, 019 OF grpAbertos 		FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 028, 072 SAY oCancelados 			PROMPT aTotalizador[2]	SIZE 053, 019 OF grpCancelados 		FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 028, 131 SAY oDevolvidos			PROMPT aTotalizador[3]	SIZE 053, 019 OF grpDevolvidos 		FONT oFontSit COLORS 0, 16777215 PIXEL
	    @ 028, 191 SAY oBaixados 			PROMPT aTotalizador[4] 	SIZE 053, 019 OF grpBaixados		FONT oFontSit COLORS 0, 16777215 PIXEL
	    
	    @ 088, 012 SAY oDemaisDoc 			PROMPT aTotalizador[5] 	SIZE 053, 019 OF grpDemaisDoc		FONT oFontSit COLORS 0, 16777215 PIXEL
		@ 088, 072 SAY oSeqNaoIdentic 		PROMPT aTotalizador[6]	SIZE 053, 019 OF grpSeqNaoIdentic 	FONT oFontSit COLORS 0, 16777215 PIXEL

	    @ 051, 012 BUTTON btnAbertos 		PROMPT "Abertos" 				SIZE 055, 012 OF pCadastro ACTION bMostraReg(1,mv_par01,mv_par02,@oDlg01,@aTotalizador) PIXEL
	    @ 051, 072 BUTTON btnCancelados		PROMPT "Cancleados" 			SIZE 055, 012 OF pCadastro ACTION bMostraReg(2,mv_par01,mv_par02,@oDlg01,@aTotalizador) PIXEL
	    @ 051, 132 BUTTON btnDevoldidos		PROMPT "Devolvidos" 			SIZE 055, 012 OF pCadastro ACTION bMostraReg(3,mv_par01,mv_par02,@oDlg01,@aTotalizador) PIXEL
	    @ 051, 191 BUTTON btnBaixados		PROMPT "Baixados" 				SIZE 055, 012 OF pCadastro ACTION bMostraReg(5,mv_par01,mv_par02,@oDlg01,@aTotalizador) PIXEL
		
	    @ 108, 012 BUTTON btnDemaisDoc		PROMPT "Demais Doc." 			SIZE 055, 012 OF pCadastro ACTION bMostraReg(4,mv_par01,mv_par02,@oDlg01,@aTotalizador) PIXEL
		@ 108, 072 BUTTON btnSeqNaoIdentic	PROMPT "Seq. n/ Identificada" 	SIZE 055, 012 OF pCadastro ACTION bMostraReg(99,mv_par01,mv_par02,@oDlg01,@aTotalizador) PIXEL

	    @ 004, 263 BUTTON btnSair PROMPT "Sair" SIZE 037, 012 OF pButtom ACTION oDlg01:End() PIXEL

	ACTIVATE MSDIALOG oDlg01 CENTERED

return

static function PKPi(aTotalizador)

	if aTotalizador == nil
		aTotalizador := {}
		aadd(aTotalizador, FSoma(mv_par01,1,'S'))
		aadd(aTotalizador, FSoma(mv_par01,2,'S'))
		aadd(aTotalizador, FSoma(mv_par01,3,'S'))
		aadd(aTotalizador, FSoma(mv_par01,4,'S'))
		aadd(aTotalizador, FSoma(mv_par01,5,'S'))
		aadd(aTotalizador, FSoma(mv_par01,99,'S'))
	else
		aTotalizador[1]	:= FSoma(mv_par01,1,'S') 
		aTotalizador[2]	:= FSoma(mv_par01,2,'S')
		aTotalizador[3]	:= FSoma(mv_par01,3,'S')
		aTotalizador[4]	:= FSoma(mv_par01,4,'S')
		aTotalizador[5]	:= FSoma(mv_par01,5,'S')
		aTotalizador[6]	:= FSoma(mv_par01,99,'S')
	endif

return nil

static function bMostraReg(xType, dDtIni, dDtFim, oDlg01, aTotalizador)

	local	oDlg		as object,;
			oBrw		as object,;
			aSizeAut	as array,;
			bOk			as codeblock,;
			bCancel		as codeblock,;
			bBottom		as codeblock,;
			cTitulo		as caracter

	Local	aHeader		as array,;
			aCols		as array

	
	if 		xType = 1; cTitulo	:= '[RD06013] - DETALHE ABERTOS'
	elseif 	xType = 2; cTitulo	:= '[RD06013] - DETALHE CANCELADOS'
	elseif 	xType = 3; cTitulo	:= '[RD06013] - DETALHE DEVOLVIDOS'
	elseif 	xType = 4; cTitulo	:= '[RD06013] - DETALHE DEMAIS DOCUMENTOS'
	elseif 	xType = 5; cTitulo	:= '[RD06013] - DETALHE BAIXADOS'
	elseif 	xType = 99; cTitulo	:= '[RD06013] - DETALHE SEQUÊNCIA NÃO IDENTIFICADA'
	endif
	
	aHeader		:= criaCampo()
	msgRun('Carregando dados '+cTitulo+'...',,{||CursorWait(),aCols:= mnDados(@aHeader, dDtIni, dDtFim, xType, 'N'),CursorArrow()})

/*
	aSizeAut[1]	= linha da posição do canto superior esquerdo da janela
	aSizeAut[2] = coluna da posição do canto superior esquerdo da janela
	aSizeAut[3] = altura da janela
	aSizeAut[4] = largura da janela
	aSizeAut[5] = Largura da janela
	aSizeAut[6] = altura da janela
*/
	aSizeAut	:= msAdvSize()

	oDlg	:= MsDialog():New(aSizeAut[7], 000, aSizeAut[6], aSizeAut[5], cTitulo,	, , , , , , , , .T.)

	oBrw:= MsNewGetDados():New( aSizeAut[2], aSizeAut[1], aSizeAut[4], aSizeAut[3], GD_UPDATE, 'AllwaysTrue','AllwaysTrue',;
							 '' ,,, 999, 'AllwaysTrue', '', 'AllwaysTrue', oDlg, aHeader, aCols )

	oBrw:oBrowse:blDblClick := {|| flSeleciona(@oBrw)} //Ação do duplo clique

	bOk				:= {|| msgRun('Salvando dados ...!!!',,{||CursorWait(), fSalva(@oDlg,@oBrw,@oDlg01,@aTotalizador), CursorArrow()})}
	bCancel			:= {|| oDlg:End()}
	bBottom 		:= {{'BMP', {|| ExpExcel(xType, aCols)}, 'Exportar Excel'}}
    
	oDlg:bInit		:= {|| enchoicebar( oDlg, bOk, bCancel, , bBottom ) }
	oDlg:lCentered	:= .T.

	oBrw:Refresh(.T.)
	oBrw:oBrowse:lUseDefaultColors := .F. // Desabilita cor padrao das linhas
	oBrw:SetEditLine(.F.)

	oDlg:Activate()
	
return

static function flSeleciona(oBrw)
	local 	nLinha		as numeric,;
			nColumn		as numeric,;
			oCheck		as object

	nLinha	:= oBrw:oBrowse:nAt
	nColumn	:= aScan(oBrw:aHeader, {|x| x[2] == 'CONCILIADO'})
	oCheck	:= oBrw:aCols[nLinha][nColumn]

	if oCheck == oBmpNO
		oBrw:aCols[nLinha][nColumn] := oBmpOK
	else
		oBrw:aCols[nLinha][nColumn] := oBmpNO
	endif

	oBrw:refresh()

return nil

static function fSalva(oDlg, oBrw, oDlg01, aTotalizador)
	local 	nLinha		as numeric,;
			oCheck		as object,;
			cNota		as caracter,;
			cSerie		as caracter,;
			cCheck		as caracter

	Local	cQry		as caracter
	
	for nLinha := 1 to len(oBrw:aCols)
		oCheck	:= oBrw:aCols[nLinha][1]
		cSerie	:= substring(oBrw:aCols[nLinha][2], 1, 3)
		cNota	:= substring(oBrw:aCols[nLinha][2], 7, 9)
		cCheck	:= iif(oCheck == oBmpOK, 'T', 'F')

		cQry 	:= 'exec dbo.PR_MV06004C @serie = "'+cSerie+'", @nota = "'+cNota+'", @status = "'+cCheck+'"'
		
		//Executa a query de atualização do campo Conciliado
		if !u_ExecQry(cQry)
			u_msgErro('Erro ao atualizar o registro! ('+cSerie+'-'+cNota+')')
		endif

	next nLinha

	oDlg:End()

	PkPi(@aTotalizador)

	oDlg01:Refresh(.T.)

return nil

static function FSoma(dData,nType,cSint)
	local 	cRet			as caracter,;
			cQry			as caracter,;
			nTotal			as numeric,;
			nConciliado		as numeric

	nRet	:= 0
	cQry	:= "exec dbo.PR_MV06004B @dtini = '" + dtos(mv_par01) + "', @dtfim = '" + dtos(mv_par02) + "', @tipo = "+cValToChar(nType)+", @sintetico = '"+cSint+"'"

	if select('TMP1') <> 0
		dbSelectArea('TMP1')
		TMP1->(dbCloseArea())
	endif
	
	tcQuery cQry NEW ALIAS 'TMP1'
	
	dbSelectArea('TMP1')
	TMP1->(dbGoTop())
	nTotal		:= TMP1->TOTAL
	nConciliado	:= TMP1->CONCILIADO
	TMP1->(dbCloseArea())

	cRet:= alltrim(transform(nConciliado,'@E 999,999')) + ' / ' + alltrim(transform(nTotal,'@E 999,999'))

return cRet

static function bSair(oDlg01)

	oDlg01:End()
	
return

static function CriaCampo()
	local	aCposCab	as array
	
	aCposCab:= {}
	aadd(aCposCab,{'Conciliado'	,'CONCILIADO'	,'@BMP',02,0,'.T.','','C','','V'})
	aadd(aCposCab,{'Num.Doc.'	,'NOTA'			,'',15,0,'','','C','','V'})
	aadd(aCposCab,{'Dt. Emissão','EMISSAO'		,'',08,0,'','','D','','V'})
	aadd(aCposCab,{'Cliente'	,'CLIENTE'		,'',55,0,'','','C','','V'})
	aadd(aCposCab,{'Valor'		,'VALOR'		,'@E 9,999,999,999,999.99',16,2,'','','N','','V'})
	aadd(aCposCab,{'Saldo'		,'SALDO'		,'@E 9,999,999,999,999.99',16,2,'','','N','','V'})
	aadd(aCposCab,{'Cond. Pagto','CONDPAGTO'	,'',49,0,'','','C','','V'})
	aadd(aCposCab,{'Vendedor'	,'VENDEDOR'		,'',60,0,'','','C','','V'})
	aadd(aCposCab,{'Usuário'	,'USUARIO'		,'',60,0,'','','C','','V'})

return aCposCab

static function mnDados(aHeader, dDtIni, dDtFim, xType, cSint)
	local 	cQry		as caracter,;
			aCols		as array

	local	oCheck		as object

	cQry		:= "exec dbo.PR_MV06004B @dtini = '"+dtos(dDtIni)+"', @dtfim = '"+dtos(dDtFim)+"', @tipo = "+cValToChar(xType)+", @sintetico = '"+cSint+"'"

	if select('TMP1')
		TMP1->(dbCloseArea())
	endif
	
	tcQuery cQry new alias 'TMP1'
	
	TMP1->(dbGoTop())
	aCols	:= {}
	while TMP1->(!eof())

		oCheck := iif(TMP1->CONCILIADO == 'T', oBmpOK, oBmpNO)

		aadd(aCols,{;
					oCheck,;
					TMP1->NOTA,;
					TMP1->EMISSAO,;
					TMP1->CLIENTE,;
					TMP1->VALOR,;
					TMP1->SALDO,;
					TMP1->CONDPAGTO,;
					TMP1->VENDEDOR,;
					TMP1->USUARIO,;
					.F.;
				 	})

		TMP1->(dbSkip())
	enddo

	if select('TMP1')
		TMP1->(dbCloseArea())
	endif

return aCols

static function ExpExcel(xType, aCols)
	local	cDirDocs	as caracter,;
			nHandle		as numeric,;
			cArquivo	as array,;
			cPath		as caracter,;
			oExcelApp	as object
	
	local	cQry		as caracter,;
			cBody		as caracter,;
			cHeader		as caracter,;
			cTrailer	as caracter,;
			nLinha		as numeric,;
			cTitulo		as caracter

	cDirDocs	:= msDocPath()
	cArquivo	:= CriaTrab(,.F.)
	cPath		:= alltrim(GetTempPath())

	cQry		:= ''
	cBody		:= ''
	cHeader		:= ''
	cTrailer	:= ''
	nLinha		:= 0

	if 		xType = 1; cTitulo	:= 'ABERTOS'
	elseif 	xType = 2; cTitulo	:= 'CANCELADOS'
	elseif 	xType = 3; cTitulo	:= 'DEVOLVIDOS'
	elseif 	xType = 4; cTitulo	:= 'DEMAIS DOCUMENTOS'
	elseif 	xType = 99; cTitulo	:= 'SEQUÊNCIA NÃO IDENTIFICADA'
	endif

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
		//A - TIPO
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> ' 				  			   + CRLF 
		cHeader += '						<strong> Tipo </strong></td> ' 											   										+ CRLF 
		//B - NUMERO DOCUMENTO
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Num. Doc. </strong></td> '														+ CRLF 
		//C - EMISSÃO
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Emissão </strong></td> ' 														+ CRLF 
		//D - CLIENTE
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Cliente </strong></td> ' 														+ CRLF 
		//E - VALOR
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Valor </strong></td> ' 														+ CRLF 
		//F - COND. PAGTO
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Cond Pagto </strong></td> ' 													+ CRLF 
		//G - VENDEDOR
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Vendedor </strong></td> ' 																				+ CRLF 
		//H - USUÁRIO
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Usuário </strong></td> ' 																				+ CRLF 
		cHeader += '				</tr> '  													   															+ CRLF 
		fwrite(nHandle, cHeader)

		nLinha:= 0
		for nLinha := 1 to len(aCols)

			cBody := "				<tr> "
			//0 - A - TIPO
			cBody += "					<td style='text-align: left;	'> &nbsp;" 	+ cTitulo 					   							+ "</td> "	+ CRLF
			//1 - B - NUMERO DOCUMENTO
			cBody += "					<td style='text-align: left;	'> &nbsp;" 	+ aCols[nLinha][2]	  						   			+ "</td> "	+ CRLF
			//2 - C - EMISSÃO
			cBody += "					<td style='text-align: left; 	'> &nbsp;" 	+ dtoc(aCols[nLinha][3])	  						   	+ "</td> "	+ CRLF
			//3 - D - CLIENTE
			cBody += "					<td style='text-align: left; 	'> &nbsp;" 	+ aCols[nLinha][4]	  						   			+ "</td> "	+ CRLF
			//4 - E - VALOR
			cBody += "					<td style='text-align: right;	'>  	 "	+ Transform(aCols[nLinha][5], x3Picture('E1_VALOR'))	+ "</td> "	+ CRLF
			//5 - F - COND. PAGTO
			cBody += "					<td style='text-align: left; 	'> &nbsp;" 	+ aCols[nLinha][7]										+ "</td> "	+ CRLF
			//6 - G - VENDEDOR
			cBody += "					<td style='text-align: left;  '> &nbsp;" 	+ aCols[nLinha][8]										+ "</td> "	+ CRLF
			//7 - H - USUÁRIO
			cBody += "					<td style='text-align: left;  '> &nbsp;" 	+ aCols[nLinha][9]										+ "</td> "	+ CRLF
			cBody += "				</tr> " 																	 								   			+ CRLF
			fwrite(nHandle, cBody)  

		next nLinha 

		//rodape
		cTrailer := "				<tr> " 														 		   																				+ CRLF 
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
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
