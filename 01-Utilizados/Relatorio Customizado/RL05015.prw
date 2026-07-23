#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'colors.ch'
#include 'rptdef.ch'
#include 'fwprintsetup.ch'
#include 'topconn.ch'

/*/
===============================================================================================================================
Programa----------: RL05015
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 17/09/2025
===============================================================================================================================
Descrição---------: Este programa serve para gerar os relatorios peditos entregue pela guarita
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
user function RL05015() 
	
	local cPerg		as char

	local	cImp		:= '',;
			cNArq		:= ''

	/*Parametros para geração da impressão*/
	local	lAdToLegacy	:= .T.,;
			cPath		:= "C:\TEMP\",;
			lDisabeSetup	:= .T.				// .t. desabilita a tela de configuração de impressao

	private	lImprimiu	:= .F.

	cPerg		:= 'RL05015'

	//Incluo/Altero as perguntas na tabela SX1
	AjustaSX1(cPerg)

	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
	if Pergunte(cPerg,.T.)
		cImp		:= ''
		cNArq		:= 'retira_'+dtos(date())+strtran(time(),':','')

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

		Processa({|| PrintRel() },"Imprimindo Relatório de Retira: "+dtoc(mv_par01)+' a '+dtoc(mv_par02),"")

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
	//Grupo()
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

	cQry := 'exec dbo.PR_RL05015 @FILIAL = "'+xFilial('SE2')+'", @DTINI = "'+DTOS(mv_par01)+'", @DTFIM = "'+DTOS(mv_par02)+'"'	
		
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

	cTexto:= 'ENTREGA DE PEDIDOS - GUARITA'
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
	oPrinter:Say(nLinha,nColIni,"Guarita..................: _______________________________________________    ______/______/__________",oFont)

	nLinha:= nLinha+nEspaco+nEspaco
	oPrinter:Say(nLinha,nColIni,"Analista Financeiro......: _______________________________________________    ______/______/__________",oFont)

	nLinha:= nLinha+nEspaco+nEspaco
	oPrinter:Say(nLinha,nColIni,"Supervisor Financeiro....: _______________________________________________    ______/______/__________",oFont)

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

//	cTexto:= 'SALDO BANCO DO BRASIL.........:'
//	oPrinter:Say(nLinha,nColIni+100,cTexto,oFontN)

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
	oPrinter:Line(nLinha,nColIni+0250,nLinha+nEspaco,nColIni+0250)
	oPrinter:Line(nLinha,nColIni+1150,nLinha+nEspaco,nColIni+1150)
	oPrinter:Line(nLinha,nColIni+1450,nLinha+nEspaco,nColIni+1450)
	oPrinter:Line(nLinha,nColIni+1750,nLinha+nEspaco,nColIni+1750)
	oPrinter:Line(nLinha,nColIni+2050,nLinha+nEspaco,nColIni+2050)

	nLinha:= nLinha+nEspaco

	//imprimindo os dados
	cTexto:= 'NUM PEDIDO'
	oPrinter:Say(nLinha-20,nColIni,cTexto,oFontN)

	cTexto:= 'NOME DO CLIENTE'
	oPrinter:Say(nLinha-20,nColIni+0450,cTexto,oFontN)

	cTexto:= 'PESO'
	oPrinter:Say(nLinha-20,nColIni+1250,cTexto,oFontN)

	cTexto:= 'VALOR'
	oPrinter:Say(nLinha-20,nColIni+1550,cTexto,oFontN)

	cTexto:= 'DATA FATURAMENTO'
	oPrinter:Say(nLinha-20,nColIni+1770,cTexto,oFontN)

	cTexto:= 'N. FISCAL'
	oPrinter:Say(nLinha-20,nColIni+2100,cTexto,oFontN)

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
	nTamTab		:= 44	// quantidade de linhas
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
		oPrinter:Line(nLinha,nColIni+0250,nLinha+nEspaco,nColIni+0250)
		oPrinter:Line(nLinha,nColIni+1150,nLinha+nEspaco,nColIni+1150)
		oPrinter:Line(nLinha,nColIni+1450,nLinha+nEspaco,nColIni+1450)
		oPrinter:Line(nLinha,nColIni+1750,nLinha+nEspaco,nColIni+1750)
		oPrinter:Line(nLinha,nColIni+2050,nLinha+nEspaco,nColIni+2050)

		//nLinha	+= nEspaco
		oPrinter:Say(nLinha,nColIni,nSubLinha,oFont)

		//imprimindo os pedidos
		if !empty(TB1TMP->CLIENTE)
			cTexto	:= TB1TMP->NUMDOC
			oPrinter:Say(nLinha+25,nColIni+0000,cTexto,oFont)

			cTexto	:= alltrim(TB1TMP->CLIENTE)
			oPrinter:Say(nLinha+25,nColIni+0255,cTexto,oFont)

			cTexto	:= Transform(TB1TMP->PESO,'@E 999,999,999.99')
			oPrinter:Say(nLinha+25,nColIni+1200,cTexto,oFont)

			cTexto	:= Transform(TB1TMP->VALOR,'@E 999,999,999.99')
			oPrinter:Say(nLinha+25,nColIni+1500,cTexto,oFont)
		
			cTexto	:= dtoc(TB1TMP->DATA)
			oPrinter:Say(nLinha+25,nColIni+1800,cTexto,oFont)

			cTexto	:= alltrim(TB1TMP->NFISCAL)
			oPrinter:Say(nLinha+25,nColIni+2100,cTexto,oFont)
		endif

		nLinha	+= nEspaco

		TB1TMP->(dbSkip())
	enddo
	
	oPrinter:Line(nLinha,nColIni,nLinha,nColFim)
	
	nLinha	+=nEspaco

	TB1TMP->(dbGoTop())

return
