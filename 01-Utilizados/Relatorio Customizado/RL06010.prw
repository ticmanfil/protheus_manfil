#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'colors.ch'
#include 'rptdef.ch'
#include 'fwprintsetup.ch'
#include 'topconn.ch'

/*/
===============================================================================================================================
Programa----------: RL06010
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 04/07/2024
===============================================================================================================================
Descrição---------: Este programa serve para gerar os relatorios capa dos bancos
===============================================================================================================================
Uso---------------: Relatorio Financeiro
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
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
user function RL06010() 
	
	local cPerg		as char

	local	cImp		:= '',;
			cNArq		:= ''

	/*Parametros para geração da impressão*/
	local	lAdToLegacy	:= .T.,;
			cPath		:= "C:\TEMP\",;
			lDisabeSetup	:= .T.				// .t. desabilita a tela de configuração de impressao

	private	lImprimiu	:= .F.

	cPerg		:= 'RL06010'

	//Incluo/Altero as perguntas na tabela SX1
	AjustaSX1(cPerg)

	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
	if Pergunte(cPerg,.T.)
		cImp		:= ''
		cNArq		:= 'Movimento_'+dtos(date())+strtran(time(),':','')

		oPrinter := FWMSPrinter():New(cNArq, IMP_SPOOL, lAdToLegacy,cPath,lDisabeSetup,.F., ,cImp)
		oPrinter:SetDevice(IMP_PDF) //IMP_SPOOL=IMPRESSORA, IMP_PDF=PDF
		oPrinter:SetPortrait() // Formato Retrato
		//oPrinter:SetLandscape()	//Formato Paisagem
		oPrinter:SetPaperSize(9) // Papel A4
		oPrinter:SetMargin(10,10,10,10) // Margem BROTHER

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao das fontes.                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//TFont():New( [ cName ], [ uPar2 ], [ nHeight ], [ uPar4 ], [ lBold ], [ uPar6 ], [ uPar7 ]
		//			, [ uPar8 ], [ uPar9 ], [ lUnderline ], [ lItalic ] )
		oFontTit := TFont():New("Courier New",,20,,.T.,,,,,.F.,.F.)
		oFont05  := TFont():New("Courier New",,05,,.F.,,,,,.F.,.F.)
		oFont07  := TFont():New("Courier New",,07,,.F.,,,,,.F.,.F.)
		oFont10  := TFont():New("Courier New",,10,,.F.,,,,,.F.,.F.)
		oFont12  := TFont():New("Courier New",,12,,.F.,,,,,.F.,.F.)
		oFont14  := TFont():New("Courier New",,14,,.F.,,,,,.F.,.F.)

		oFont10N := TFont():New("Courier New",,10,,.T.,,,,,.F.,.F.)
		oFont12N := TFont():New("Courier New",,12,,.T.,,,,,.F.,.F.)
		oFont14N := TFont():New("Courier New",,14,,.T.,,,,,.F.,.F.)

		oPrinter:SetFont(oFont10N) // Fonte Padrao para calculo do objeto de impressao

		Processa({|| PrintRel() },"Imprimindo Movimento Diario: "+dtoc(mv_par01)+' a '+dtoc(mv_par02),"")

	endif

return lImprimiu
         
static function PrintRel()


	//variáveis de marcadores de impressão
	private	oFont		as char,;
			oFontN		as char,;
			nEspaco		as numeric,;
			nLinha		as numeric,;
			nColIni		as numeric,;
			nColFim		as numeric,;
			nPag		as numeric

	nPag:= 0	
	MontaTMP()
	Cabecalho()
	Grupo()
	Detalhe()
	SubDetalhe()
	xRodape()

	oPrinter:EndPage()
	lImprimiu:= oPrinter:Preview()

	if oPrinter # Nil
		FreeObj(oPrinter)
	endif
	oPrinter := Nil

	EncerraTMP()

return nil

static function MontaTMP() 

	local 	cQry	as char

	cQry := 'exec dbo.PR_RL06010 @FILIAL = "'+xFilial('SE2')+'", @DTINI = "'+DTOS(mv_par01)+'", @DTFIM = "'+DTOS(mv_par02)+'", @BANCO = "'+mv_par03+'"'	
		
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	if select('TB1TMP') <> 0
		dbSelectArea('TB1TMP')
		TB1TMP->(dbCloseArea())
	endif
	
	//crio o novo alias
	TCQUERY cQry NEW ALIAS 'TB1TMP'
	
	dbSelectArea('TB1TMP')
	TB1TMP->(dbGoTop())
	
return

static function EncerraTMP() 

	if select('TB1TMP') <> 0
		dbSelectArea('TB1TMP')
		TB1TMP->(dbCloseArea())
	endif
		
return

static function ajustaSx1(cPerg)

	U_XPUTSX1(     cPerg,"01","Vencto Inicial?" ,"."     ,"."       ,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	U_XPUTSX1(     cPerg,"02","Vencto Final?","."     ,"."       ,"mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")
	U_XPUTSX1(     cPerg,"03","Banco?","."     ,"."       ,"mv_ch3","C",03,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","")
//	U_XPUTSX1(     cPerg,"04","Dt Pagto Inicial?" ,"."     ,"."       ,"mv_ch4","D",08,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","")
//	U_XPUTSX1(     cPerg,"05","Dt Pagto Final?","."     ,"."       ,"mv_ch5","D",08,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","")

return

/**** FUNCOES DE CABECALHOS E RODAPÉ ****/
static function Cabecalho()
	local 	oFontPag:= oFont10

	oFont	:= oFont14
	oFontN	:= oFont14N
	nLinha	:= 0050
	nColIni	:= 0000
	nColFim	:= 2350

/*	configuracao qdo a impressao for paisagem
	nColIni	:= 0000
	nColFim	:= 2900*/

	nEspaco	:= 89
	nPag	:= nPag + 1

	oPrinter:StartPage()

	cTexto:= 'MOVIMENTO DIÁRIO'
	oPrinter:SayBitmap(nLinha,nColIni,'\\urano\TOTVS12\Protheus_data\system\logo1.bmp',400,150)
	oPrinter:SayAlign(nLinha,nColIni,cTexto,oFontTit,nColFim,,,2,0)

/**** NAO TEM CODIGO DE BARRAS ****/
//	cTexto	:= dtoc(mv_par01)+' à '+dtoc(mv_par02)
//	oPrinter:Code128(nLinha,nColFim-800,cTexto,1,30,.F.)
	//oPrinter:EAN13(nLinha,nColIni+1700,cTexto,100,20)
	//FWMsPrinter():EAN13(<nRow>, <nCol>, <cCodeBar>, <nTotalWidth>, <nHeight>)
	//FWMsPrinter():Code128(<nRow>, <nCol>, <cCodeBar>, <nWidth>, <nHeight>, [lSay], [oFont], [nTotalWidth]) 

	nLinha:= nLinha+nEspaco
	
	cTexto:= dtoc(mv_par01)+' à '+dtoc(mv_par02)
	oPrinter:SayAlign(nLinha,nColIni,cTexto,oFont,nColFim,,,2,0)

	cTexto:=  CUSERNAME + " " + DTOC(DATE()) + " " + SubStr(TIME(),1,8)
	oPrinter:SayAlign(nLinha+25,nColIni,cTexto,oFontPag,nColFim,,,1,0)

	cTexto:= 'Página: '+StrZero(nPag,3)
	oPrinter:SayAlign(nLinha+50,nColIni,cTexto,oFontPag,nColFim,,,1,0)
	
	nLinha:= nLinha+nEspaco
	oPrinter:Line(nLinha,nColIni,nLinha,nColFim)

return

static function xRodape()

	oFont	:= oFont10
	oFontN	:= oFont10N
	nEspaco	:= 50

	//reposiciona a linha atual para o fim da pagina
	//nLinha:= 2100		//configuracao para qdo o papel for paisagem
	nLinha:= 2700		//configuracao para qdo o papel for retrato
	oPrinter:Line(nLinha,nColIni,nLinha,nColFim)

	nLinha:= nLinha+nEspaco+nEspaco
	oPrinter:Say(nLinha,nColIni,"Caixa....................: _______________________________________________ ______/______/__________",oFont)

	nLinha:= nLinha+nEspaco+nEspaco
	oPrinter:Say(nLinha,nColIni,"Supervisor Financeiro....: _______________________________________________ ______/______/__________",oFont)

	nLinha:= nLinha+nEspaco+nEspaco
	oPrinter:Say(nLinha,nColIni,"Gerente Geral............: _______________________________________________ ______/______/__________",oFont)

return


//***** FUNCOES DE IMPRESSAO DO RELATORIO EM SI ****/
static function Grupo()

	local	cTexto		as char

	oFont	:= oFont14
	oFontN	:= oFont14N
	nEspaco	:= 50

	cTexto		:= ''

	//imprimindo dados no formularios
	nLinha:= nLinha+nEspaco
	nLinha:= nLinha+nEspaco

	cTexto:= 'SALDO BANCO DO BRASIL.........:'
	oPrinter:Say(nLinha,nColIni+100,cTexto,oFontN)

	//Proxima linha
	nLinha:= nLinha+nEspaco
	nLinha:= nLinha+nEspaco

	cTexto:= 'SALDO CAIXA ECONOMICA FEDERAL.:'
	oPrinter:Say(nLinha,nColIni+100,cTexto,oFontN)

	//Proxima linha
	nLinha:= nLinha+nEspaco
	nLinha:= nLinha+nEspaco

	cTexto:= 'SALDO BANCO ITAU..............:'
	oPrinter:Say(nLinha,nColIni+100,cTexto,oFontN)

	//Proxima linha
	nLinha:= nLinha+nEspaco
	nLinha:= nLinha+nEspaco

	cTexto:= 'SUPRIMENTO EM CHEQUE..........:'
	oPrinter:Say(nLinha,nColIni+100,cTexto,oFontN)

	nLinha:= nLinha+nEspaco
	nLinha:= nLinha+nEspaco
	oPrinter:Line(nLinha,nColIni,nLinha,nColFim)

return

static function Detalhe()

	local	cTexto		as char

	oFont	:= oFont12
	oFontN	:= oFont12N
	nEspaco	:= 50

	cTexto		:= ''

	//Colunas
	oPrinter:Line(nLinha,nColIni+0100,nLinha+nEspaco,nColIni+0100)
	oPrinter:Line(nLinha,nColIni+0700,nLinha+nEspaco,nColIni+0700)
	oPrinter:Line(nLinha,nColIni+1000,nLinha+nEspaco,nColIni+1000)
	oPrinter:Line(nLinha,nColIni+1250,nLinha+nEspaco,nColIni+1250)
	oPrinter:Line(nLinha,nColIni+1450,nLinha+nEspaco,nColIni+1450)
	oPrinter:Line(nLinha,nColIni+1700,nLinha+nEspaco,nColIni+1700)
	oPrinter:Line(nLinha,nColIni+2270,nLinha+nEspaco,nColIni+2270)

	nLinha:= nLinha+nEspaco

	//imprimindo os dados
	cTexto:= 'BANCO'
	oPrinter:Say(nLinha-20,nColIni,cTexto,oFontN)

	cTexto:= 'FORNECEDOR'
	oPrinter:Say(nLinha-20,nColIni+0200,cTexto,oFontN)

	cTexto:= 'TITULO'
	oPrinter:Say(nLinha-20,nColIni+0750,cTexto,oFontN)

	cTexto:= 'VALOR'
	oPrinter:Say(nLinha-20,nColIni+1050,cTexto,oFontN)

	cTexto:= 'VENCTO'
	oPrinter:Say(nLinha-20,nColIni+1300,cTexto,oFontN)

	cTexto:= 'VL.PAGTO'
	oPrinter:Say(nLinha-20,nColIni+1500,cTexto,oFontN)

	cTexto:= 'HISTORICO'
	oPrinter:Say(nLinha-20,nColIni+1800,cTexto,oFontN)

	cTexto:= 'PAGTO'
	oPrinter:Say(nLinha-20,nColIni+2270,cTexto,oFontN)

	//nLinha:= nLinha+nEspaco
	oPrinter:Line(nLinha,nColIni,nLinha,nColFim)

return

static function SubDetalhe()
	local	nSubLinha	as char,;
			cTexto		as char,;
			nValorBruto	as numeric,;
			nValorPagto	as numeric,;
			nTamTab		as numeric,;
			nXi			as numeric

	//backup das variaveis de controle
	local	boFont		as object,;
			boFontN		as object,;
			bnLinha		as numeric,;
			bnColIni	as numeric,;
			bnColFim	as numeric,;
			bnEspaco	as numeric

	oFont		:= oFont12
	oFontN		:= oFont12N
	nEspaco		:= 55
	nSubLinha	:= replicate('-',138)
//	nSubLinha	:= replicate('-',190)	//USAR QDO A IMPRESSAO FOR MODO PAISAGEM
	nValorBruto	:= 0.00
	nValorPagto	:= 0.00
	nTamTab		:= 31	// quantidade de linhas
	nXi			:= 0

	while nXi < nTamTab

		nXi+=1

		if nXi = nTamTab .and. !TB1TMP->(eof())	//nLinha >= 2700		//2100 qdo a impressao for paisagem
			//fazendo backup das variaives de controle
			boFont		:= oFont
			boFontN		:= oFontN
			bnLinha		:= nLinha
			bnColIni	:= nColIni
			bnColFim	:= nColFim
			bnEspaco	:= nEspaco
			bnPag		:= nPag
			nXi			:= 0

			//iniciando nova página com a impressão do rodapé e cabecalho com os dados de carga da nova página
			xRodape()
			cabecalho()
			Grupo()
			Detalhe()

			//restaurando o backup para continuar a impressao
			oFont		:= boFont
			oFontN		:= boFontN
			nLinha		:= nLinha
			nColIni		:= nColIni
			nColFim		:= nColFim
			nEspaco		:= nEspaco
			//nPag		:= nPag
		endif

		//Colunas
		oPrinter:Line(nLinha,nColIni+0100,nLinha+nEspaco,nColIni+0100)
		oPrinter:Line(nLinha,nColIni+0700,nLinha+nEspaco,nColIni+0700)
		oPrinter:Line(nLinha,nColIni+1000,nLinha+nEspaco,nColIni+1000)
		oPrinter:Line(nLinha,nColIni+1250,nLinha+nEspaco,nColIni+1250)
		oPrinter:Line(nLinha,nColIni+1450,nLinha+nEspaco,nColIni+1450)
		oPrinter:Line(nLinha,nColIni+1700,nLinha+nEspaco,nColIni+1700)
		oPrinter:Line(nLinha,nColIni+2270,nLinha+nEspaco,nColIni+2270)

		//nLinha	+= nEspaco
		oPrinter:Say(nLinha,nColIni,nSubLinha,oFont)

		//imprimindo os pedidos
		if !empty(TB1TMP->FORNECEDOR)
			cTexto	:= TB1TMP->BANCO
			oPrinter:Say(nLinha+25,nColIni+0000,cTexto,oFont)

			cTexto	:= alltrim(TB1TMP->FORNECEDOR)
			oPrinter:Say(nLinha+25,nColIni+0105,cTexto,oFont)

			cTexto	:= TB1TMP->TITULO
			oPrinter:Say(nLinha+25,nColIni+0705,cTexto,oFont)

			cTexto	:= Transform(TB1TMP->VALOR,'@E 999,999,999.99')
			oPrinter:Say(nLinha+25,nColIni+1005,cTexto,oFont)

			cTexto	:= dtoc(stod(TB1TMP->VENCTO))	//dtoc(TB1TMP->VENCTO)
			oPrinter:Say(nLinha+25,nColIni+1255,cTexto,oFont)

			cTexto	:= Transform(TB1TMP->VLPAGO,'@E 999,999,999.99')
			oPrinter:Say(nLinha+25,nColIni+1455,cTexto,oFont)

			cTexto	:= TB1TMP->HISTORICO
			oPrinter:Say(nLinha+25,nColIni+1705,cTexto,oFont)

			cTexto	:= TB1TMP->PAGTO
			oPrinter:Say(nLinha+25,nColIni+2275,cTexto,oFont)

			//soma do total
			nValorBruto	+= TB1TMP->VALOR
			nValorPagto	+= TB1TMP->VLPAGO
		
		endif

		nLinha	+= nEspaco

		TB1TMP->(dbSkip())
	enddo
	
//	nLinha	+=nEspaco
	oPrinter:Line(nLinha,nColIni,nLinha,nColFim)
	nLinha	+=nEspaco

	TB1TMP->(dbGoTop())

	//totalizando
	cTexto	:= Transform(nValorBruto,'@E 999,999,999.99')
	oPrinter:Say(nLinha,nColIni+1005,cTexto,oFontN)

	cTexto	:= Transform(nValorPagto,'@E 999,999,999.99')
	oPrinter:Say(nLinha,nColIni+1455,cTexto,oFontN)

return
