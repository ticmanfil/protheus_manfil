#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'colors.ch'
#include 'rptdef.ch'
#include 'fwprintsetup.ch'
#include 'topconn.ch'
/*/
===============================================================================================================================
Programa----------: RL39002
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 06/06/2024
===============================================================================================================================
Descrição---------: Este programa serve para IMPRIMIR CONTROLE DE CARGA
===============================================================================================================================
Uso---------------: 39 - OMS
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: DISTRIBUICAO
===============================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor	|	Data	|										Motivo																
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			| 																										
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			| 																						
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			|																											
=====================================================================================================================================
/*/
user function RL39002(pCarga, pSeqCarga)

	local	cControle	:= '',;
			cImp		:= '',;
			cNArq		:= ''

	/*Parametros para geração da impressão*/
	local	lAdToLegacy	:= .T.,;
			cPath		:= "C:\TEMP\",;
			lDisabeSetup	:= .T.				// .t. desabilita a tela de configuração de impressao

	private	lImprimiu	:= .F.

	cControle	:= pCarga+pSeqCarga
	//cImp		:= U_SelImp(cTitulo)
	cImp		:= ''
	cNArq		:= 'Carga_'+cControle+'_'+dtos(date())+strtran(time(),':','')

	oPrinter := FWMSPrinter():New(cNArq, IMP_SPOOL, lAdToLegacy,cPath,lDisabeSetup,.F., ,cImp)
	//if GetMv("MV_XPRGER")==cImp
		oPrinter:SetDevice(IMP_PDF) //IMP_SPOOL=IMPRESSORA, IMP_PDF=PDF
	//else
	//	oPrinter:SetDevice(IMP_SPOOL) //IMP_SPOOL=IMPRESSORA, IMP_PDF=PDF
	//endif
	//oPrinter:SetPortrait() // Formato Retrato
	oPrinter:SetLandscape()	//Formato Paisagem
	oPrinter:SetPaperSize(9) // Papel A4
	oPrinter:SetMargin(60,60,60,60) // Margem BROTHER

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

	Processa({|| PrintRel(cControle) },"Imprimindo Controle de Carga: "+cControle,"")

return lImprimiu

Static Function MontaTRB(cControle)
	local	cQry	:= ''

	cQry := 'exec PR_RL39002 @FILIAL = "'+xFilial('Z11')+'", @CONTROLE = "'+cControle+'"'
		
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	if select('TB1') <> 0
		dbSelectArea('TB1')
		TB1->(dbCloseArea())
	endif
	
	//crio o novo alias
	TCQUERY cQry NEW ALIAS 'TB1'
	
	dbSelectArea('TB1')
	TB1->(dbGoTop())

return

Static Function EncerraTRB()
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	if select('TB1') <> 0
		dbSelectArea('TB1')
		TB1->(dbCloseArea())
	endif

return

static function PrintRel(cControle)

	//variáveis de marcadores de impressão
	private	oFont		as char,;
			oFontN		as char,;
			nEspaco		as numeric,;
			nLinha		as numeric,;
			nColIni		as numeric,;
			nColFim		as numeric,;
			nPag		as numeric

	nPag:= 0	
	MontaTRB(cControle)
	Cabecalho()
	DadosCarga()
	ItCargaCab()
	ItCargaDet()
	xRodape()

	oPrinter:EndPage()
	lImprimiu:= oPrinter:Preview()

	if oPrinter # Nil
		FreeObj(oPrinter)
	endif
	oPrinter := Nil

	EncerraTRB()

return nil

static function Cabecalho()
	local 	oFontPag:= oFont10


	oFont	:= oFont14
	oFontN	:= oFont14N
	nLinha	:= 0150
	nColIni	:= 0002
	nColFim	:= 2900
	nEspaco	:= 89
	nPag	:= nPag + 1

	oPrinter:StartPage()

	cTexto:= 'CONTROLE DE CARGAS'
	oPrinter:SayBitmap(nLinha,nColIni,'\\urano\TOTVS12\Protheus_data\system\logo1.bmp',400,150)
	oPrinter:SayAlign(nLinha,nColIni,cTexto,oFontTit,nColFim,,,2,0)

	cTexto	:= TB1->NUMCONTROLE
	oPrinter:Code128(nLinha,nColFim-800,cTexto,1,30,.F.)
	//oPrinter:EAN13(nLinha,nColIni+1700,cTexto,100,20)
	//FWMsPrinter():EAN13(<nRow>, <nCol>, <cCodeBar>, <nTotalWidth>, <nHeight>)
	//FWMsPrinter():Code128(<nRow>, <nCol>, <cCodeBar>, <nWidth>, <nHeight>, [lSay], [oFont], [nTotalWidth]) 

	nLinha:= nLinha+nEspaco
	
	cTexto:= 'Nº: '+TB1->NUMCONTROLE
	oPrinter:SayAlign(nLinha,nColIni,cTexto,oFont,nColFim,,,2,0)

	cTexto:=  CUSERNAME
	oPrinter:SayAlign(nLinha,nColIni,cTexto,oFontPag,nColFim,,,1,0)

	cTexto:=  DTOC(DATE()) + " " + SubStr(TIME(),1,8)
	oPrinter:SayAlign(nLinha+25,nColIni,cTexto,oFontPag,nColFim,,,1,0)

	cTexto:= 'Página: '+StrZero(nPag,3)
	oPrinter:SayAlign(nLinha+50,nColIni,cTexto,oFontPag,nColFim,,,1,0)
	
	nLinha:= nLinha+nEspaco
	oPrinter:Line(nLinha,nColIni,nLinha,nColFim)

return

static function DadosCarga()

	local	nXi			as numeric,;
			nTamColunas	as numeric,;
			cTexto		as char,;
			nColIni2	as numeric,;
			nColIni3	as numeric

	oFont	:= oFont14
	oFontN	:= oFont14N
	nEspaco	:= 50

	nColIni2	:= 770
	nColIni3	:= 1700
	nTamColunas	:= 300
	cTexto		:= ''

	//imprimindo dados no formularios
	nLinha:= nLinha+nEspaco
	cTexto:= TB1->NUMCONTROLE
	oPrinter:Say(nLinha,nColIni ,"Nº..........:",oFont)
	oPrinter:Say(nLinha,nColIni+nTamColunas,cTexto,oFontN)

	cTexto:= dtoc(stod(TB1->DTCARREG))+' - '+TB1->HRCARREG
	oPrinter:Say(nLinha,nColIni2,"Data........:",oFont)
	oPrinter:Say(nLinha,nColIni2+nTamColunas,cTexto,oFontN)

	//Proxima linha
	nLinha:= nLinha+nEspaco

	cTexto:= dtoc(stod(TB1->DATASAIDA))+' '+TB1->HRSAIDA
	oPrinter:Say(nLinha,nColIni,"Data Saída..:",oFont)
	oPrinter:Say(nLinha,nColIni+nTamColunas,cTexto,oFontN)

	cTexto:= TB1->VEICULO
	oPrinter:Say(nLinha,nColIni2,"Veículo.....:",oFont)
	oPrinter:Say(nLinha,nColIni2+nTamColunas,cTexto,oFontN)

	cTexto:= Transform(TB1->KMINI,'@E 999,999,999')
	oPrinter:Say(nLinha,nColIni3,"KM Inicial..:",oFont)
	oPrinter:Say(nLinha,nColIni3+nTamColunas,cTexto,oFontN)

	//Proxima Linha
	nLinha:= nLinha+nEspaco

	cTexto:= dtoc(stod(TB1->DATARETORNO))+' '+TB1->HRRETORNO
	oPrinter:Say(nLinha,nColIni,"Data Retorno:",oFont)
	oPrinter:Say(nLinha,nColIni+nTamColunas,cTexto,oFontN)

	cTexto:= TB1->MOTORISTA
	oPrinter:Say(nLinha,nColIni2,"Motorista...:",oFont)
	oPrinter:Say(nLinha,nColIni2+nTamColunas,cTexto,oFontN)

	cTexto:= Transform(TB1->KMFIM,'@E 999,999,999')
	oPrinter:Say(nLinha,nColIni3,"KM Final....:",oFont)
	oPrinter:Say(nLinha,nColIni3+nTamColunas,cTexto,oFontN)

	//Proxima Linha
	nLinha:= nLinha+nEspaco

	cTexto:= transform(SubtHoras(stod(TB1->DATASAIDA),TB1->HRSAIDA,stod(TB1->DATARETORNO),TB1->HRRETORNO),'@E 999,999')+' HORAS'
	oPrinter:Say(nLinha,nColIni ,"Tempo.......:",oFont)
	oPrinter:Say(nLinha,nColIni+nTamColunas,cTexto,oFontN)

	cTexto:= TB1->CONFCARGA
	oPrinter:Say(nLinha,nColIni2,"Conferente..:",oFont)
	oPrinter:Say(nLinha,nColIni2+nTamColunas,cTexto,oFontN)

	cTexto:= transform(iif(TB1->KMFIM!=0,TB1->KMFIM-TB1->KMINI,0),'@E 999,999,999')+' KM'
//	cTexto:= Transform(TB1->TOTALPEDIDOS,'@E 999,999,999')
	oPrinter:Say(nLinha,nColIni3,"Distância...:",oFont)
	oPrinter:Say(nLinha,nColIni3+nTamColunas,cTexto,oFontN)

	//Proxima Linha
	nLinha:= nLinha+nEspaco

	cTexto:= Transform(TB1->TOTALPEDIDOS,'@E 999,999,999')
	oPrinter:Say(nLinha,nColIni ,"QTD.Pedidos.:",oFont)
	oPrinter:Say(nLinha,nColIni+nTamColunas,cTexto,oFontN)

	cTexto:= transform(TB1->PESOTOTAL,'@E 999,999,999.999')
	oPrinter:Say(nLinha,nColIni2,"Peso Real...:",oFont)
	oPrinter:Say(nLinha,nColIni2+nTamColunas,cTexto,oFontN)

	cTexto:= transform(TB1->VALTOTAL,'@E 999,999,999.99')
	oPrinter:Say(nLinha,nColIni3,"Valor Real..:",oFont)
	oPrinter:Say(nLinha,nColIni3+nTamColunas,cTexto,oFontN)

	//Proxima Linha
	nLinha:= nLinha+nEspaco

	//cTexto:= TB1->OBS
	cTexto:= DAK->DAK_XOBS
	oPrinter:Say(nLinha,nColIni ,"Observação..:",oFont)
//	oPrinter:Say(nLinha,nColIni,cTexto,oFontN)
	for nXi := 1 To MLCount(cTexto,070)
		if !Empty(MLCount(cTexto,070))
			if !Empty(MemoLine(cTexto,070,nXi))
				oPrinter:SayAlign(nLinha, nColIni+nTamColunas, OemToAnsi(MemoLine(cTexto,070,nXi)), oFontN, nColFim,,,0,1)
				nLinha += nEspaco                                          
			endif
		endif
	next nXi

	if nXi < 5
		nLinha := nLinha + (5*nEspaco) - (nXi*nEspaco)
	endif

	nLinha:= nLinha+nEspaco
	oPrinter:Line(nLinha,nColIni,nLinha,nColFim)

return

static function ImpColunas()

	oPrinter:Line(nLinha,nColIni+0123,nLinha+nEspaco,nColIni+0123)	//item
	oPrinter:Line(nLinha,nColIni+0375,nLinha+nEspaco,nColIni+0375)	//num.doc
	oPrinter:Line(nLinha,nColIni+1520,nLinha+nEspaco,nColIni+1520)	//cliente
	oPrinter:Line(nLinha,nColIni+1750,nLinha+nEspaco,nColIni+1750)	//VALOR
	oPrinter:Line(nLinha,nColIni+1890,nLinha+nEspaco,nColIni+1890)	//PAGTO
	oPrinter:Line(nLinha,nColIni+2045,nLinha+nEspaco,nColIni+2045)	//VL PAGTO
	oPrinter:Line(nLinha,nColIni+2282,nLinha+nEspaco,nColIni+2282)	//NF FSICAL
	oPrinter:Line(nLinha,nColIni+2544,nLinha+nEspaco,nColIni+2544)	//RESERVA
	oPrinter:Line(nLinha,nColIni+2744,nLinha+nEspaco,nColIni+2744)	//RETORNOU

return nil

static function ItCargaCab()

	local	cTexto			:= '',;
			nAjuste			as numeric

	oFont	:= oFont14
	oFontN	:= oFont14N
	nEspaco	:= 60
	nAjuste	:= 100

	//Colunas
	ImpColunas()

	//cabecalho
	cTexto	:= 'ITEM'
	oPrinter:SayAlign(nLinha,nColIni+0000,cTexto,oFontN,nColIni+0123,,,0,0)
	cTexto	:= 'NUM.DOC.'
	oPrinter:SayAlign(nLinha,nColIni+0145,cTexto,oFontN,nColIni+0375,,,0,0)
	cTexto	:= 'CLIENTE'
	oPrinter:SayAlign(nLinha,nColIni+0570,cTexto,oFontN,nColIni+1520,,,0,0)
	cTexto	:= 'VALOR'
	oPrinter:SayAlign(nLinha,nColIni+1545,cTexto,oFontN,nColIni+1750,,,0,0)
	cTexto	:= 'PAGTO'
	oPrinter:SayAlign(nLinha,nColIni+1780,cTexto,oFontN,nColIni+1890,,,0,0)
	cTexto	:= 'VLPAGTO'
	oPrinter:SayAlign(nLinha,nColIni+1895,cTexto,oFontN,nColIni+2045,,,0,0)
	cTexto	:= 'N. FISCAL'
	oPrinter:SayAlign(nLinha,nColIni+2080,cTexto,oFontN,nColIni+2312,,,0,0)
	cTexto	:= 'RESERVA'
	oPrinter:SayAlign(nLinha,nColIni+2332,cTexto,oFontN,nColIni+2534,,,0,0)
	cTexto	:= 'RETORNOU'
	oPrinter:SayAlign(nLinha,nColIni+2564,cTexto,oFontN,nColIni+2744,,,0,0)
	cTexto	:= 'ASS.'
	oPrinter:SayAlign(nLinha,nColIni+2774,cTexto,oFontN,nColIni+2874,,,0,0)

	nLinha:= nLinha+nEspaco
	oPrinter:Line(nLinha,nColIni,nLinha,nColFim)
	nLinha:= nLinha-nEspaco

return

static function ItCargaDet()

	local	cTexto			:= '',;
			nSize			as numeric,;
			nAlt			as numeric,;
			cCidade			as char,;
			nCentraliza		as numeric,;
			nSubLinha		as numeric,;			//qtd de pontos na sublinhas
			nPesoBruto		as numeric,;
			nValorBruto		as numeric

	//backup das variaveis de controle
	local	boFont		as object,;
			boFontN		as object,;
			bnLinha		as numeric,;
			bnColIni	as numeric,;
			bnColFim	as numeric,;
			bnEspaco	as numeric

	oFont		:= oFont14
	oFontN		:= oFont14N
	nEspaco		:= 60
	nSubLinha	:= replicate('-',156)
	nPesoBruto	:= 0
	nValorBruto	:= 0

	//calculo para centralizar as cidades dentro do formulario impresso
	nCentraliza:= round(oPrinter:nHorzSize() / 2 ,0)
	
	//nLinha	+= nEspaco
	//itens - pedidos
	while !TB1->(eof())
		if nLinha >= 1990
			//fazendo backup das variaives de controle
			boFont		:= oFont
			boFontN		:= oFontN
			bnLinha		:= nLinha
			bnColIni	:= nColIni
			bnColFim	:= nColFim
			bnEspaco	:= nEspaco
			bnPag		:= nPag

			//iniciando nova página com a impressão do rodapé e cabecalho com os dados de carga da nova página
			xRodape()
			Cabecalho()
			DadosCarga()
			ItCargaCab()

			//restaurando o backup para continuar a impressao
			oFont		:= boFont
			oFontN		:= boFontN
			nLinha		:= nLinha
			nColIni		:= nColIni
			nColFim		:= nColFim
			nEspaco		:= nEspaco
			//nPag		:= bnPag
		endif

		//destacando a cidade da entrega
		if cCidade != TB1->CIDADE
			nLinha	+= nEspaco
			cCidade	:= TB1->CIDADE
			cTexto	:= cCidade
			oPrinter:SayAlign(nLinha,nColIni,cTexto,oFontN,nColFim,,,2,1)
			nLinha	+= 10	// incremento para ajustar o tamanho da  linha
			oPrinter:Say(nLinha,nColIni,nSubLinha,oFont)
		endif

		nLinha	+= nEspaco
		oPrinter:Say(nLinha,nColIni,nSubLinha,oFont)

		//Colunas
		ImpColunas()

		//imprimindo os pedidos
		cTexto	:= TB1->ITEM+iif(TB1->DEVOL$'T|P','*','')
		oPrinter:Say(nLinha+25,nColIni+0000,cTexto,oFont)

		cTexto	:= alltrim(TB1->DOC)
		oPrinter:Say(nLinha+25,nColIni+0130,cTexto,oFont)

		cTexto	:= TB1->CLIENTE
		oPrinter:Say(nLinha+25,nColIni+0380,cTexto,oFont)

		cTexto	:= Transform(TB1->VALOR,'@E 999,999,999.99')
		oPrinter:Say(nLinha+25,nColIni+1485,cTexto,oFont)

		cTexto	:= TB1->PAGTO
		oPrinter:Say(nLinha+25,nColIni+1830,cTexto,oFont)

		cTexto	:= ''
		oPrinter:Say(nLinha+25,nColIni+1995,cTexto,oFont)

		cTexto	:= TB1->NF
		oPrinter:Say(nLinha+25,nColIni+2050,cTexto,oFont)

		cTexto	:= TB1->RESERV+iif(TB1->PEDRE=='S','*','')
		oPrinter:Say(nLinha+25,nColIni+2302,cTexto,oFont)

		//soma do total
		nValorBruto	+= TB1->VALOR
		nPesoBruto	+= TB1->PESO

		if TB1->DEVOL $ 'T|P'
			nLinha	+= nEspaco

			//Colunas
			ImpColunas()

			cTexto	:= '* Não entrega: '+TB1->CODOCOR + ' - ' + TB1->OCORREN
			oPrinter:Say(nLinha+25,nColIni+0430,cTexto,oFont)

		endif

		if TB1->PEDRE == 'S'
			nLinha	+= nEspaco

			//Colunas
			ImpColunas()
			cTexto	:= '* 1º VIA DO PEDIDO PRINCIPAL DA RESERVA FOI ENVIADO'
			oPrinter:Say(nLinha+25,nColIni+0430,cTexto,oFont)

		endif

		TB1->(dbSkip())
	enddo
	
	nLinha	+=nEspaco
	oPrinter:Line(nLinha,nColIni,nLinha,nColFim)
	nLinha	+=nEspaco

	TB1->(dbGoTop())
	//totalizando
	cTexto	:= Transform(nValorBruto,'@E 999,999,999.99')
	nSize 	:= oPrinter:GetTextWidth(cTexto, oFontN, 0)
	nAlt	:= oPrinter:GetTextHeight(cTexto, oFontN, 0)
	oPrinter:Say(nLinha,nColIni+1655,cTexto,oFontN)

return

static function xRodape()

	oFont	:= oFont10
	oFontN	:= oFont10N
	nEspaco	:= 50

	//reposiciona a linha atual para o fim da pagina
	nLinha:= 2100
	oPrinter:Line(nLinha,nColIni,nLinha,nColFim)

	nLinha:= nLinha+nEspaco+nEspaco
	oPrinter:Say(nLinha,nColIni,"Responsável Motorista.: _______________________________________________ ______/______/__________",oFont)

	nLinha:= nLinha+nEspaco+nEspaco
	oPrinter:Say(nLinha,nColIni,"Responsável Acerto....: _______________________________________________ ______/______/__________",oFont)

	nLinha:= nLinha+nEspaco+nEspaco
	oPrinter:Say(nLinha,nColIni,"Responsável Caixa.....: _______________________________________________ ______/______/__________",oFont)

return
