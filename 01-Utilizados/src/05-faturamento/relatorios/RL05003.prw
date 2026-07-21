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
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'prtopdef.ch'
/*/
===============================================================================================================================
Programa----------: RL05003
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 29/11/2018
===============================================================================================================================
DescriГЦo---------: Este programa serve para exportar para excel o PEDIDO DE VENDA escolhido
===============================================================================================================================
Uso---------------: MATA410 (Pedidos de Vendas)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
===============================================================================================================================
/*/

user function RL05003(cNumPed) 

	Processa( {|| ImpRel(cNumPed) },"Aguarde..." ) 

/*
	private cDirDocs  	:= MsDocPath(),;
			cArquivo 	:= CriaTrab(,.F.),;
			cPath		:= AllTrim(GetTempPath())   
*/
return

static function ImpRel(cNumPed)
	local	cDirDocs	as caracter,;
			nHandle		as numeric,;
			cArquivo	as array,;
			cPath		as caracter,;
			oExcelApp	as object
	
	local	cQry		as caracter,;
			cBody		as caracter,;
			cHeader		as caracter,;
			cTrailer	as caracter,;
			nPrcSegum	as numeric,;
			nPesoProd	as numeric,;
			nPesoTotal	as numeric

	cDirDocs	:= msDocPath()
	cArquivo	:= CriaTrab(,.F.)
	cPath		:= alltrim(GetTempPath())

	cQry		:= ''
	cBody		:= ''
	cHeader		:= ''
	cTrailer	:= ''
	nPrcSegum	:= 0
	nPesoProd	:= 0
	nPesoTotal	:= 0

	nHandle		:= msfCreate(cDirDocs+'\'+cArquivo+'.xls',0)
	if nHandle > 0

		if select('TMP') > 0
			TMP->(dbCloseArea())
		endif

		cQry:= "exec dbo.PR_RL05003 @FILIAL = '"+fwxFilial('SC6')+"', @NUMPED = '"+cNumPed+"'"
		tcQuery cQry new alias 'TMP'

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
		cHeader += '						<strong>' + u_ux3Titulo('C6_ITEM') 		+ '</strong></td> ' 											   		+ CRLF 
		cHeader += '					<td style="text-align: center; width: 50px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('C6_PRODUTO') 		+ '</strong></td> '													+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('C6_DESCRI')	+ '</strong></td> ' 													+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('C6_UNSVEN')	+ '</strong></td> ' 													+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('C6_SEGUM')	+ '</strong></td> ' 														+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('C6_XPRSEGU')	+ '</strong></td> ' 														+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('C6_VALOR')	+ '</strong></td> ' 														+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('C6_DESCONT')	+ '</strong></td> ' 														+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>' + u_ux3Titulo('C6_XPEM2')	+ '</strong></td> ' 														+ CRLF 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong>Peso Total</strong></td> ' 																				+ CRLF 
		cHeader += '				</tr> '  													   															+ CRLF 
		fwrite(nHandle, cHeader)

		//corpo
		nPrcSegum	:= 0
		nPesoProd	:= 0
		nPesoTotal	:= 0
		TMP->(dbGoTop())
		while !TMP->(eof()) 
			nPrcSegum	:= u_conv1unid(TMP->C6_PRODUTO,TMP->C6_PRCVEN)
			nPesoProd	:= posicione('SB1',1,fwxFilial('SB1')+TMP->C6_PRODUTO,'B1_PESO')
			nPesoTotal	:= TMP->C6_QTDVEN * nPesoProd
			cBody := "				<tr> " 																					   								  	   					+ CRLF
			//A - C6_ITEM 
			cBody += "					<td style='width: 050px; text-align: center;	'> &nbsp;" 	+ TMP->C6_ITEM	  						   							+ "</td> "	+ CRLF
			//B - C6_PRODUTO 
			cBody += "					<td style='width: 100px; text-align: left; 		'> &nbsp;" 	+ TMP->C6_PRODUTO	  						   						+ "</td> "	+ CRLF
			//C - C6_DESCRI 
			cBody += "					<td style='width: 250px; text-align: left; 		'> &nbsp;" 	+ TMP->C6_DESCRI	  						   						+ "</td> "	+ CRLF
			//D - C6_UNSVEN 
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP->C6_UNSVEN, x3Picture('C6_UNSVEN'))					+ "</td> "	+ CRLF
			//E - C6_SEGUM
			cBody += "					<td style='width: 100px; text-align: center; 	'> &nbsp;" 	+ TMP->C6_SEGUM  						   							+ "</td> "	+ CRLF
			//F - C6_XPRSEGU
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(nPrcSegum, x3Picture('C6_XPRSEGU'))						+ "</td> "	+ CRLF
			//G - C6_VALOR
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP->C6_VALOR, x3Picture('C6_VALOR'))					+ "</td> "	+ CRLF
			//H - C6_DESCONT
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP->C6_DESCONT, x3Picture('C6_DESCONT'))				+ "</td> "	+ CRLF
			//I - C6_XPEM2
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP->C6_XPEM2, x3Picture('C6_XPEM2'))					+ "</td> "	+ CRLF
			//J - PESO TOTAL
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(nPesoTotal, x3Picture('C6_XPEM2'))						+ "</td> "	+ CRLF
			cBody += "				</tr> " 																	 								   									+ CRLF
			fwrite(nHandle, cBody)  
			TMP->(dbSkip())
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
		cTrailer += "				</tr> " 																	 									   									+ CRLF         
	
		fwrite(nHandle, cTrailer)  
		TMP->(dbCloseArea())
		fClose(nHandle)
		CpyS2T(cDirDocs+'\'+cArquivo+'.xls' , cPath, .T. )   
		
		if ! ApOleClient( 'MsExcel' )
			MsgAlert( "Excel nao instalado!" ) //'MsExcel nao instalado'
			return
		endif
		
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".xls" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)   
	
	else
		msg_erro('Erro ao criar arquivo excel!','RL05003')
	endif

return

/*
static function ImpRel(cNumOrc)
                    
	local cQuery 		:= ""
	local cPulaLinha	:= CRLF // chr(13)+chr(10)   
	local cBody			:= ""
	local cHeader		:= "" 
	local cTrailer		:= ""
	local nContador		:= 0
	local nCont			:= 0
	local nHandle
	local nMargem		:= 0

	if Select("TMP01") > 0
		TMP01->(DbCloseArea())
	endif            
      
	nHandle := MsfCreate(cDirDocs+"\"+cArquivo+".xls",0)

	if nHandle > 0
	
	    cQuery := " select	SCK.CK_ITEM, SCK.CK_PRODUTO, SCK.CK_DESCRI, SCK.CK_QTDVEN, SCK.CK_UM, SCK.CK_XUNSVEN, SCK.CK_XSEGUM, SCK.CK_XPESUNI, SCK.CK_XPESUNI * SCK.CK_QTDVEN as CK_XPESO,SCK.CK_PRCVEN, SCK.CK_VALOR, SCK.CK_XCC2UM, SCK.CK_XCUSTO, SCK.CK_XCUSTOT, SCK.CK_XPRVALT, SCK.CK_XPRCTOT, SCK.CK_XMARGEM, CK_XTIPCON, CK_XCONV	"+cPulaLinha
	    cQuery += " from	"+RetSqlName("SCK")+" as SCK		"+cPulaLinha
	    cQuery += " where										"+cPulaLinha
	    cQuery += "		SCK.D_E_L_E_T_	= ''					"+cPulaLinha
	    cQuery += "	and SCK.CK_FILIAL	= '"+xFilial("SCK")+"'	"+cPulaLinha
	    cQuery += "	and SCK.CK_NUM		= '"+cNumOrc+"'			"+cPulaLinha

	    MemoWrit("C:\TEMP\RL05003.txt",cQuery)
		TcQuery cQuery New Alias "TMP01" // Cria uma nova area com o resultado do query
	 
		nContador:=0
		                                   
		while TMP01->(!Eof())      
			nContador++
			nMargem	:= TMP01->CK_XMARGEM 
			TMP01->(DbSkip())
		enddo
	
		if nContador = 0 
			apMsgInfo('Nao foram encontrados dados para esta pesquisa!')   
			return .F.
		endif

		ProcRegua(Reccount())
		
		///ииииииииииииииииииииииииииииииииииииииииииииииииииииииииК
		//=Monta o CabeГalho										=
		//ЬииииииииииииииииииииииииииииииииииииииииииииииииииииииииК   
		cHeader := ' <html> ' 																																+ cPulaLinha 
		cHeader += ' 	<head> ' 																															+ cPulaLinha
		cHeader += '		<title>Editor HTML Online</title> ' 																							+ cPulaLinha
		cHeader += '	</head> ' 																															+ cPulaLinha
		cHeader += '	<body> ' 																															+ cPulaLinha
		cHeader += '		<div> ' 																														+ cPulaLinha
		cHeader += '			<p>&nbsp;</p> ' 																											+ cPulaLinha
		cHeader += '		</div> ' 																														+ cPulaLinha
		cHeader += '		<table style="width: 100%;" border="1" cellpadding="1" cellspacing="1"> ' 														+ cPulaLinha
		cHeader += '			<tbody> ' 																													+ cPulaLinha
	 	cHeader += '				<tr> ' 																													+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 50px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_ITEM') 		+ '</strong></td> ' 											   		+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 50px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_PRODUTO') 		+ '</strong></td> ' 											   		+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 250px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_DESCRI')	+ '</strong></td> ' 													+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_QTDVEN')	+ '</strong></td> ' 													+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_UM')		+ '</strong></td> ' 													+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_XUNSVEN')	+ '</strong></td> ' 													+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_XSEGUM')		+ '</strong></td> ' 													+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_PRCVEN')	+ '</strong></td> ' 													+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_VALOR')		+ '</strong></td> ' 													+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_XCUSTO')	+ '</strong></td> ' 											   		+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_XCUSTOT')	+ '</strong></td> ' 											   		+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_XMARGEM')	+ '</strong></td> ' 											   		+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_XPRCTOT')	+ '</strong></td> ' 											   		+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_XPRVALT')	+ '</strong></td> ' 											   		+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + u_ux3Titulo('CK_XPESUNI')	+ '</strong></td> ' 													+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + "Peso Total" 				+ '</strong></td> ' 													+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + "TP Conv" 				+ '</strong></td> ' 													+ cPulaLinha 
		cHeader += '					<td style="text-align: center; width: 100px; background-color: rgb(204, 204, 204);"> ' 				  				+ cPulaLinha 
		cHeader += '						<strong>' + "Conv." 				+ '</strong></td> ' 													+ cPulaLinha 
		cHeader += '				</tr> '  													   															+ cPulaLinha 

		FWRITE(nHandle, cHeader)                      
	
		TMP01->(dbGoTop())
		while TMP01->(!Eof()) 
		
			///ииииииииииииииииииииииииииииииииииииииииииииииииииииииииК
			//=Monta o corpo											=
			//ЬииииииииииииииииииииииииииииииииииииииииииииииииииииииииК                              
			
	        //nAtraso :=  DateDiffDay(stod(QRYCTB->E1_VENCREA),(ddatabase) )                                   
	        
			cBody := "				<tr> " 																					   								  	   						+ cPulaLinha
			//A - CK_ITEM 
			cBody += "					<td style='width: 050px; text-align: center;	'> &nbsp;" 	+ TMP01->CK_ITEM	  						   							+ "</td> "	+ cPulaLinha
			//B - CK_PRODUTO 
			cBody += "					<td style='width: 100px; text-align: left; 		'> &nbsp;" 	+ TMP01->CK_PRODUTO	  						   							+ "</td> "	+ cPulaLinha
			//C - CK_DESCRI 
			cBody += "					<td style='width: 250px; text-align: left; 		'> &nbsp;" 	+ TMP01->CK_DESCRI	  						   							+ "</td> "	+ cPulaLinha
			//D - CK_QTDVEN 
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> =F" 		+ cValtoChar(nCont+4) + "*R" + cValtoChar(nCont+4)						+ "</td> "	+ cPulaLinha
			//E - CK_UM
			cBody += "					<td style='width: 100px; text-align: center; 	'> &nbsp;" 	+ TMP01->CK_UM  						   								+ "</td> "	+ cPulaLinha
			//F - CK_XUNSVEN 
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP01->CK_XUNSVEN, x3Picture('CK_XUNSVEN'))					+ "</td> "	+ cPulaLinha
			//G - CK_XSEGUM
			cBody += "					<td style='width: 100px; text-align: center; 	'> &nbsp;" 	+ TMP01->CK_XSEGUM  						   								+ "</td> "	+ cPulaLinha
			//H - CK_PRCVEN 
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP01->CK_PRCVEN, x3Picture('CK_PRCVEN'))					+ "</td> "	+ cPulaLinha
			//I - CK_VALOR 
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP01->CK_VALOR, x3Picture('CK_VALOR'))						+ "</td> "	+ cPulaLinha
			//J - CK_XCUSTO 
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP01->CK_XCUSTO, x3Picture('CK_XCUSTO'))					+ "</td> "	+ cPulaLinha
			//K - CK_XCUSTOT = CK_XCUSTO * CK_QTDVEN
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> =J" 		+ cValtoChar(nCont+4) + "*D" + cValtoChar(nCont+4)						+ "</td> "	+ cPulaLinha
			//L - CK_XMARGEM
			cBody += "					<td style='width: 100px; text-align: center; 	'> " 		+ Transform(TMP01->CK_XMARGEM, x3Picture('CK_XMARGEM'))					+ "</td> "	+ cPulaLinha
			//M - CK_XPRCTOT = CK_XPRVALT * CK_QTDVEN
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> =N" 		+ cValtoChar(nCont+4) + "*D" + cValtoChar(nCont+4)						+ "</td> "	+ cPulaLinha
			//N - CK_XPRVALT = CK_XCUSTO * N3<nMargem>
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> =J" 		+ cValtoChar(nCont+4) + "*L" + cValtoChar(nCont+4)						+ "</td> "	+ cPulaLinha
			//O - CK_XPESUNI 
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP01->CK_XPESUNI, x3Picture('CK_XPESUNI'))					+ "</td> "	+ cPulaLinha
			//P - CK_XPESO 
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP01->CK_XPESO, x3Picture('CK_XPESUNI'))					+ "</td> "	+ cPulaLinha
			//Q - CK_XTIPCON 
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP01->CK_XTIPCON, x3Picture('CK_XTIPCON'))					+ "</td> "	+ cPulaLinha
			//R - CK_XCONV 
			cBody += "					<td style='width: 100px; text-align: rigth;  	'> " 		+ Transform(TMP01->CK_XCONV, x3Picture('CK_XCONV'))						+ "</td> "	+ cPulaLinha
			cBody += "				</tr> " 																	 								   										+ cPulaLinha         
	
			FWRITE(nHandle, cBody)  
			nCont++ 

			TMP01->(DbSkip())
		enddo 
		
		cTrailer := "				<tr> " 														 		   																				+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " 										+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ " "										+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 250px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ " "										+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: center; background-color: rgb(204, 204, 204);'> " + " "						 				+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ " "										+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: center; background-color: rgb(204, 204, 204);'> " + " "						 				+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ " "										+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ " "										+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ "=SOMA(I4:I"+cValtoChar(nCont+3)+")"		+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ " "										+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> "	+ "=SOMA(K4:K"+cValtoChar(nCont+3)+")"		+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ " "										+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ "=SOMA(M4:M"+cValtoChar(nCont+3)+")"		+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ " "										+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ "	"	 									+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ "=SOMA(P4:P"+cValtoChar(nCont+3)+")"	 	+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ "	"	 									+ "</td> "	+ cPulaLinha 
		cTrailer += "					<td style='width: 100px; text-align: rigth; background-color: rgb(204, 204, 204);'> " 	+ "	"	 									+ "</td> "	+ cPulaLinha 
		cTrailer += "				</tr> " 																	 									   									+ cPulaLinha         
	
		FWRITE(nHandle, cTrailer)  
		TMP01->(dbCloseArea())
		fClose(nHandle)
		CpyS2T( cDirDocs+"\"+cArquivo+".xls" , cPath, .T. )   
		
		if ! ApOleClient( 'MsExcel' )
			MsgAlert( "Excel nao instalado!" ) //'MsExcel nao instalado'
			return
		endif
		
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".xls" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)   

	else
		apMsgAlert('Erro ao criar arquivo excel!','RL05003')
		
	endif
        
return
*/
