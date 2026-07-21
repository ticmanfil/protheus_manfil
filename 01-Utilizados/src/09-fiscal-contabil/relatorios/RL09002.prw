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
Programa----------: RL09002
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 29/12/2018
===============================================================================================================================
Descrição---------: RELATORIO DE CONFERENCIA ICMS EM NOTAS FISCAIS DE VENDAS 
===============================================================================================================================
Uso---------------: SIGAFIS
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: CONTABIL / FISCAL
===============================================================================================================================
/*/

user function RL09002() 

	local oReport 	:= nil
	local cPerg		:= 'RL09002'
	
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
	
	oReport	:= TReport():New(cNome,'RELATORIO DE CONFERENCIA ICMS EM NOTAS FISCAIS DE VENDAS',cNome,{|oReport| ReportPrint(oReport)},'RELATORIO DE CONFERENCIA ICMS EM NOTAS FISCAIS DE VENDAS')
	oReport:cfontbody	:= 'courier new'
	oReport:SetPortrait(.T.)	//SetLandscape
	
	oSection1:= TRSection():New(oReport, 'SD2', {'SD2'}, NIL, .F., .T. ,/*<uTotalText>*/ ,/* <lTotalInLine> */, /*<lHeaderPage> */,/* <lHeaderBreak> */, /*<lPageBreak> */, /*<lLineBreak>*/ , /*<nLeftMargin>*/ ,/* <lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 3 /*<nLinesBefore> */, /*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore> */, /*<nPercentage>*/ )
	TRCell():New(oSection1, 'D2_EMISSAO'	, 'TB1TMP', U_UX3Titulo('D2_EMISSAO')	, x3Picture('D2_EMISSAO')	, tamsx3('D2_EMISSAO')[1]	,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	
	oSection2:= TRSection():New(oReport, 'NOTAS', {'SD2'}, NIL, .F., .T. ,/*<uTotalText>*/ ,/* <lTotalInLine> */, /*<lHeaderPage> */,/* <lHeaderBreak> */, /*<lPageBreak> */, /*<lLineBreak>*/ , /*<nLeftMargin>*/ ,/* <lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , /*<nLinesBefore> */, /*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore> */, /*<nPercentage>*/ )
	TRCell():New(oSection2, 'D2_DOC'		, 'TB1TMP', U_UX3Titulo('D2_DOC')		, x3Picture('D2_DOC')		, tamsx3('D2_DOC')[1]		,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'D2_SERIE'		, 'TB1TMP', U_UX3Titulo('D2_SERIE')		, x3Picture('D2_SERIE')		, tamsx3('D2_SERIE')[1]		,.F.,/*bBlock*/,'LEFT'		,.T.,'LEFT'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	//TRCell():New(oSection2, 'D2_QUANT'		, 'TB1TMP', U_UX3Titulo('D2_QUANT')		, x3Picture('D2_QUANT')		, tamsx3('D2_QUANT')[1]		,.F.,/*bBlock*/,'RIGHT'		,.T.,'RIGHT'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'D2_VALBRUT'	, 'TB1TMP', U_UX3Titulo('D2_VALBRUT')	, x3Picture('D2_VALBRUT')	, tamsx3('D2_VALBRUT')[1]	,.F.,/*bBlock*/,'RIGHT'		,.T.,'RIGHT'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'D2_VALIPI'		, 'TB1TMP', U_UX3Titulo('D2_VALIPI')	, x3Picture('D2_VALIPI')	, tamsx3('D2_VALIPI')[1]	,.F.,/*bBlock*/,'RIGHT'		,.T.,'RIGHT'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'D2_VALICM'		, 'TB1TMP', U_UX3Titulo('D2_VALICM')	, X3Picture('D2_VALICM')	, tamsx3('D2_VALICM')[1]	,.F.,/*bBlock*/,'RIGHT'		,.T.,'RIGHT'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'D2_VALISS'		, 'TB1TMP', U_UX3Titulo('D2_VALISS')	, X3Picture('D2_VALISS')	, tamsx3('D2_VALISS')[1]	,.F.,/*bBlock*/,'RIGHT'		,.T.,'RIGHT'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'D2_VALACRS'	, 'TB1TMP', U_UX3Titulo('D2_VALACRS')	, X3Picture('D2_VALACRS')	, tamsx3('D2_VALACRS')[1]	,.F.,/*bBlock*/,'RIGHT'		,.T.,'RIGHT'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection2, 'D2_TOTAL'		, 'TB1TMP', U_UX3Titulo('D2_TOTAL')		, x3Picture('D2_TOTAL')		, tamsx3('D2_TOTAL')[1]		,.F.,/*bBlock*/,'RIGHT'		,.T.,'RIGHT'	,/*lCellBreak*/,/*nColSpace*/,.F.)

	//TRFunction():New(oSection2:Cell('D2_QUANT')		,NIL,'SUM'		,,,x3Picture('D2_QUANT')	,,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('D2_VALBRUT')	,NIL,'SUM'		,,,x3Picture('D2_VALBRUT')	,,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('D2_VALIPI')	,NIL,'SUM'		,,,x3Picture('D2_VALIPI')	,,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('D2_VALICM')	,NIL,'SUM'		,,,x3Picture('D2_VALICM')	,,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('D2_VALISS')	,NIL,'SUM'		,,,x3Picture('D2_VALISS')	,,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('D2_VALACRS')	,NIL,'SUM'		,,,x3Picture('D2_VALACRS')	,,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('D2_TOTAL')		,NIL,'SUM'		,,,x3Picture('D2_TOTAL')	,,.T.,.T.,.T.,oSection2)
	
	oSection2:SetTotalInLine(.F.)
	oSection1:SetTotalInLine(.T.)
	oReport:SetTotalInLine(.F.)
	
	oSection2:SetTotalText('Total do Dia')
	oReport:SetTotalText('Total Geral')

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
		
		cChave	:= TB1TMP->D2_EMISSAO
		
		//imprimo a primeira seção				
		oSection1:Cell('D2_EMISSAO'):SetValue(STOD(TB1TMP->D2_EMISSAO))
		oSection1:Printline()

		//inicializo a primeira seção
		oSection2:Init()

		//imprimo a segunda seção
		while cChave == TB1TMP->D2_EMISSAO	
			oSection2:Cell('D2_DOC'):SetValue(TB1TMP->D2_DOC)
			oSection2:Cell('D2_SERIE'):SetValue(TB1TMP->D2_SERIE)
			//oSection2:Cell('D2_QUANT'):SetValue(TB1TMP->D2_QUANT)
			oSection2:Cell('D2_VALBRUT'):SetValue(TB1TMP->D2_VALBRUT)
			oSection2:Cell('D2_VALIPI'):SetValue(TB1TMP->D2_VALIPI)
			oSection2:Cell('D2_VALICM'):SetValue(TB1TMP->D2_VALICM)
			oSection2:Cell('D2_VALISS'):SetValue(TB1TMP->D2_VALISS)
			oSection2:Cell('D2_VALACRS'):SetValue(TB1TMP->D2_VALACRS)
			oSection2:Cell('D2_TOTAL'):SetValue(TB1TMP->D2_TOTAL)
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
	
return

static function Query()

	local cQuery	:= ''
	
	cQuery	:='exec dbo.PR_RL09002 @FILIAL = "'+xFilial('SFT')+'", @DTINI = "'+DTOS(mv_par01)+'", @DTFIM = "'+DTOS(mv_par02)+'"'	

return cQuery
