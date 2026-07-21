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
/*/
===============================================================================================================================
Programa----------: RL09001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 29/12/2018
===============================================================================================================================
Descrição---------: RELATORIO DE EDF CONTRIBUICOES DETALHADO
===============================================================================================================================
Uso---------------: SIGAFIS
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: CONTABIL FISCAL
===============================================================================================================================
/*/

user function RL09001() 

	local oReport 	:= nil
	local cPerg		:= 'RL09001'
	
	//Incluo/Altero as perguntas na tabela SX1
	AjustaSX1(cPerg)

	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
	if Pergunte(cPerg,.T.)
		oReport	:= RptDef(cPerg)
		oReport:PrintDialog()
	endif

return
         
static function RptDef(cNome)

	local oReport	:= nil
	local oSection1	:= nil
	local oSection2	:= nil
	
	oReport	:= TReport():New(cNome,'RELATÓRIO EFD CONTRIBUIÇÕES DETALHADO',cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO EFD CONTRIBUIÇÕES DETALHADO')
	oReport:cfontbody	:= 'courier new'
	oReport:SetLandscape(.T.)	//SetPortrait
	
	oSection1:= TRSection():New(oReport, 'NOTAS', {'SFT','SB1'}, NIL, .F., .T. ,/*<uTotalText>*/ ,/* <lTotalInLine> */, /*<lHeaderPage> */,/* <lHeaderBreak> */, /*<lPageBreak> */, /*<lLineBreak>*/ , /*<nLeftMargin>*/ ,/* <lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 3 /*<nLinesBefore> */, /*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore> */, /*<nPercentage>*/ )
	TRCell():New(oSection1, 'FT_EMISSAO'	, 'TB1TMP', U_UX3Titulo('FT_EMISSAO')	, x3Picture('FT_EMISSAO')	, tamsx3('FT_EMISSAO')[1]	,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'FT_SERIE'		, 'TB1TMP', U_UX3Titulo('FT_SERIE')		, x3Picture('FT_SERIE')		, tamsx3('FT_SERIE')[1]		,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'FT_NFISCAL'	, 'TB1TMP', U_UX3Titulo('FT_NFISCAL')	, x3Picture('FT_NFISCAL')	, tamsx3('FT_NFISCAL')[1]	,.F.,/*bBlock*/,'LEFT'		,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'FT_ESPECIE'	, 'TB1TMP', U_UX3Titulo('FT_ESPECIE')	, x3Picture('FT_ESPECIE')	, tamsx3('FT_ESPECIE')[1]	,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	
	oSection2:= TRSection():New(oReport, 'ITENS', {'SFT','SB1'}, NIL, .F., .T. ,/*<uTotalText>*/ ,/* <lTotalInLine> */, /*<lHeaderPage> */,/* <lHeaderBreak> */, /*<lPageBreak> */, /*<lLineBreak>*/ , /*<nLeftMargin>*/ ,/* <lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , /*<nLinesBefore> */, /*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore> */, /*<nPercentage>*/ )
	TRCell():New(oSection2, 'FT_ITEM'		, 'TB1TMP', U_UX3Titulo('FT_ITEM')		, x3Picture('FT_ITEM')		, tamsx3('FT_ITEM')[1]		,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'FT_PRODUTO'	, 'TB1TMP', U_UX3Titulo('FT_PRODUTO')	, x3Picture('FT_PRODUTO')	, tamsx3('FT_PRODUTO')[1]	,.F.,/*bBlock*/,'LEFT'		,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'B1_DESC'		, 'TB1TMP', U_UX3Titulo('B1_DESC')		, x3Picture('B1_DESC')		, tamsx3('B1_DESC')[1]		,.F.,/*bBlock*/,'LEFT'		,.T.,'LEFT'		,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'FT_QUANT'		, 'TB1TMP', U_UX3Titulo('FT_QUANT')		, x3Picture('FT_QUANT')		, tamsx3('FT_QUANT')[1]		,.F.,/*bBlock*/,'RIGHT'		,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'FT_CFOP'		, 'TB1TMP', U_UX3Titulo('FT_CFOP')		, x3Picture('FT_CFOP')		, tamsx3('FT_CFOP')[1]		,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'FT_TOTAL'		, 'TB1TMP', U_UX3Titulo('FT_TOTAL')		, x3Picture('FT_TOTAL')		, tamsx3('FT_TOTAL')[1]		,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'FT_VALCONT'	, 'TB1TMP', U_UX3Titulo('FT_VALCONT')	, X3Picture('FT_VALCONT')	, tamsx3('FT_VALCONT')[1]	,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'FT_BASEPIS'	, 'TB1TMP', U_UX3Titulo('FT_BASEPIS')	, X3Picture('FT_BASEPIS')	, tamsx3('FT_BASEPIS')[1]	,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'FT_ALIQPIS'	, 'TB1TMP', U_UX3Titulo('FT_ALIQPIS')	, X3Picture('FT_ALIQPIS')	, tamsx3('FT_ALIQPIS')[1]	,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'FT_VALPIS'		, 'TB1TMP', U_UX3Titulo('FT_VALPIS')	, x3Picture('FT_VALPIS')	, tamsx3('FT_VALPIS')[1]	,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'FT_BASECOF'	, 'TB1TMP', U_UX3Titulo('FT_BASECOF')	, x3Picture('FT_BASECOF')	, tamsx3('FT_BASECOF')[1]	,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'FT_ALIQCOF'	, 'TB1TMP', U_UX3Titulo('FT_ALIQCOF')	, x3Picture('FT_ALIQCOF')	, tamsx3('FT_ALIQCOF')[1]	,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'FT_VALCOF'		, 'TB1TMP', U_UX3Titulo('FT_VALCOF')	, x3Picture('FT_VALCOF')	, tamsx3('FT_VALCOF')[1]	,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)

	TRFunction():New(oSection2:Cell('FT_ITEM')		,NIL,'COUNT'	,,,x3Picture('FT_ITEM')		,,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('FT_TOTAL')		,NIL,'SUM'		,,,x3Picture('FT_TOTAL')	,,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('FT_VALCONT')	,NIL,'SUM'		,,,x3Picture('FT_VALCONT')	,,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('FT_VALPIS')	,NIL,'SUM'		,,,x3Picture('FT_VALPIS')	,,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('FT_VALCOF')	,NIL,'SUM'		,,,x3Picture('FT_VALCOF')	,,.T.,.T.,.T.,oSection2)
	
	oSection2:SetTotalInLine(.F.)
	oSection1:SetTotalInLine(.F.)
	oReport:SetTotalInLine(.F.)
	
	oSection2:SetTotalText('Sub Total')
	oSection1:SetTotalText('Sub Total')
	oReport:SetTotalText('Total ')

return(oReport)


static function ReportPrint(oReport) 

	local oSection1 := oReport:Section(1)
	local oSection2 := oReport:Section(2)
	local cQuery    := ''
	local cChave	:= ''

	cQuery := query()
		
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	if select('TB1TMP') <> 0
		dbSelectArea('TB1TMP')
		TB1TMP->(dbCloseArea())
	endif
	
	//crio o novo alias
	TCQUERY cQuery NEW ALIAS 'TB1TMP'
	
	dbSelectArea('TB1TMP')
	TB1TMP->(dbGoTop())
	
	oReport:SetMeter(TB1TMP->(LastRec()))

	//Irei percorrer todos os meus registros
	while !Eof()
		
		if oReport:Cancel()
			exit
		endif
	
		//inicializo a primeira seção
		oSection1:Init()

		oReport:IncMeter()
					
		incProc('Imprimindo relatório')
		
		cChave	:= TB1TMP->FT_SERIE+TB1TMP->FT_NFISCAL
		
		//imprimo a primeira seção				
		oSection1:Cell('FT_EMISSAO'):SetValue(STOD(TB1TMP->FT_EMISSAO))
		oSection1:Cell('FT_SERIE'):SetValue(TB1TMP->FT_SERIE)
		oSection1:Cell('FT_NFISCAL'):SetValue(TB1TMP->FT_NFISCAL)
		oSection1:Cell('FT_ESPECIE'):SetValue(TB1TMP->FT_ESPECIE)
		oSection1:Printline()

		//inicializo a primeira seção
		oSection2:Init()

		//imprimo a segunda seção
		while cChave == TB1TMP->FT_SERIE+TB1TMP->FT_NFISCAL				
			oSection2:Cell('FT_ITEM'):SetValue(TB1TMP->FT_ITEM)
			oSection2:Cell('FT_PRODUTO'):SetValue(TB1TMP->FT_PRODUTO)
			oSection2:Cell('B1_DESC'):SetValue(TB1TMP->B1_DESC)
			oSection2:Cell('FT_QUANT'):SetValue(TB1TMP->FT_QUANT)
			oSection2:Cell('FT_CFOP'):SetValue(TB1TMP->FT_CFOP)
			oSection2:Cell('FT_TOTAL'):SetValue(TB1TMP->FT_TOTAL)
			oSection2:Cell('FT_VALCONT'):SetValue(TB1TMP->FT_VALCONT)
			oSection2:Cell('FT_BASEPIS'):SetValue(TB1TMP->FT_BASEPIS)
			oSection2:Cell('FT_ALIQPIS'):SetValue(TB1TMP->FT_ALIQPIS)
			oSection2:Cell('FT_VALPIS'):SetValue(TB1TMP->FT_VALPIS)
			oSection2:Cell('FT_BASECOF'):SetValue(TB1TMP->FT_BASECOF)
			oSection2:Cell('FT_ALIQCOF'):SetValue(TB1TMP->FT_ALIQCOF)
			oSection2:Cell('FT_VALCOF'):SetValue(TB1TMP->FT_VALCOF)
			oSection2:Printline()
			
			TB1TMP->(dbSkip())
		enddo

		//finalizo a segunda seção
		oSection2:Finish()			
	
 		//imprimo uma linha para separar uma seção da outra
 		oReport:ThinLine()
// 		oReport:FatLine()

		//finalizo a primeira seção
		oSection1:Finish()			

	enddo

return

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(cPerg, "01", "Emissao de ?"		, "", "", "mv_ch1", "D", 8, 0, 0, "G", "", "", "", "", "mv_par01")
	U_XPUTSX1(cPerg, "02", "Emissao até ?"		, "", "", "mv_ch2", "D", 8, 0, 0, "G", "", "", "", "", "mv_par02")
	U_XPUTSX1(cPerg, "03", "Tipo Movimento ?"	, "", "", "mv_ch3", "C", 1, 0, 0, "G", "", "", "", "", "mv_par03")
	
return

static function Query()

	local cQuery	:= ''
	local cTipo		:= ''
	
	if mv_par03	= 1
		cTipo	:= 'E'
	elseif mv_par03	= 2
		cTipo	:= 'S'
	endif
	
	cQuery	:='exec dbo.PR_RL09001 @FILIAL = "'+xFilial('SFT')+'", @DTINI = "'+DTOS(mv_par01)+'", @DTFIM = "'+DTOS(mv_par02)+'", @TIPO = "'+cTipo+'"'	

return cQuery
