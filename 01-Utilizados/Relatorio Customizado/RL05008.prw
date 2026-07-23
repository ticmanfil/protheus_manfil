#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'report.ch'

/*/
===============================================================================================================================
Programa----------: RL05008
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 26/03/2019
===============================================================================================================================
Descrição---------: Este programa serve para IMPRIMIR OS PEDIDOS CANCELADOS
===============================================================================================================================
Uso---------------: Relatorio FATURAMENTO
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGAFAT
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
user function RL05008() 

	local oReport 	:= nil
	local cPerg		:= 'RL05008'

	//Incluo/Altero as perguntas na tabela SX1
	AjustaSX1(cPerg)

	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
	if Pergunte(cPerg,.T.)
		oReport	:= RptDef(cPerg)
		oReport:PrintDialog()
	endif
	
return
         
static function RptDef(cNome)

	local 	oReport		:= nil,;
			oSection1	:= nil
	
	oReport	:= TReport():New(cNome,'RELATÓRIO DE NOTAS CANCELADAS - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par01),cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO DE NOTAS CANCELADAS - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02))
	oReport:SetPortrait()	//SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:SetTotalText('Total ')
	
	//configurando a primeira seção
	//TRSection():New( 	/*<oParent>	*/, /*<cTitle>*/, /*<uTable>*/, /*<aOrder>*/, /*<lLoadCells>*/, /*<lLoadOrder>*/, /*<uTotalText>, /*<lTotalInLine>*/, /*<lHeaderPage>*/, /*<lHeaderBreak>*/, /*<lPageBreak>*/, /*<lLineBreak>*/, /*<nLeftMargin>*/, /*<lLineStyle> */, /*<nColSpace>*/,	/*<lAutoSize>*/, /*<cCharSeparator>*/, /*<nLinesBefore>*/, /*<nCols>*/, /*<nClrBack>*/, /*<nClrFore>*/, /*<nPercentage>*/ )
	oSection1:= TRSection():New(oReport,'NOTA',{'SF3'},,.F.,.T.,'Sub Total',.F.)
	//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>*/,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
	TRCell():New(oSection1,'F3_DTCANC'	,'TB1TMP',U_UX3Titulo('F3_DTCANC')	,x3Picture('F3_DTCANC')		,tamsx3('F3_DTCANC')[1]		,.F.,,'LEFT',,'LEFT',,,.F.,)
	TRCell():New(oSection1,'F3_SERIE'	,'TB1TMP',U_UX3Titulo('F3_SERIE')	,x3Picture('F3_SERIE')		,tamsx3('F3_SERIE')[1]		,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'F3_NFISCAL'	,'TB1TMP',U_UX3Titulo('F3_NFISCAL')	,x3Picture('F3_NFISCAL')	,tamsx3('F3_NFISCAL')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'A1_NOME'	,'TB1TMP',U_UX3Titulo('A1_NOME')	,x3Picture('A1_NOME')		,tamsx3('A1_COD')[1]+tamsx3('A1_LOJA')[1]+tamsx3('A1_NOME')[1]+9,.F.,,'LEFT',,'LEFT',,,.F.,)
	TRCell():New(oSection1,'F3_EMISSAO'	,'TB1TMP',U_UX3Titulo('F3_EMISSAO')	,x3Picture('F3_EMISSAO')	,tamsx3('F3_EMISSAO')[1]	,.F.,,'LEFT',,'LEFT',,,.F.,)
	TRCell():New(oSection1,'F3_VALCONT'	,'TB1TMP',U_UX3Titulo('F3_VALCONT')	,x3Picture('F3_VALCONT')	,tamsx3('F3_VALCONT')[1]	,.F.,,'RIGHT',,'RIGHT',,,.F.,)

	//configurando o totalizador
	//TRFunction():New(<oCell>,<cName>,<cFunction>,<oBreak>,<cTitle>,<cPicture>,<uFormula>,<lEndSection>,<lEndReport>,<lEndPage>,<oParent>,<bCondition>,<lDisable>,<bCanPrint>)
	TRFunction():New(oSection1:Cell('F3_NFISCAL'),nil,'COUNT',,,'@E 999,999',,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('F3_VALCONT'),nil,'SUM',,,x3Picture('F3_VALCONT'),,.T.,.T.,.T.,oSection1)

return(oReport)


static function ReportPrint(oReport) 

	local 	oSection1 	:= oReport:Section(1),;
			cQuery    	:= ''
	
	//imprimir relatorio
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

	//inicializo a primeira seção
	oSection1:Init()

	//Irei percorrer todos os meus registros
	while !oReport:Cancel() .and. TB1TMP->(!Eof())
		
		oReport:IncMeter()
					
		incProc('Imprimindo relatório')
		
		//imprimo a primeira seção				
		oSection1:Cell('F3_DTCANC'):SetValue(dtoc(stod(TB1TMP->F3_DTCANC)))
		oSection1:Cell('F3_SERIE'):SetValue(TB1TMP->F3_SERIE)
		oSection1:Cell('F3_NFISCAL'):SetValue(TB1TMP->F3_NFISCAL)
		oSection1:Cell('A1_NOME'):SetValue(alltrim(TB1TMP->A1_COD)+'-'+alltrim(TB1TMP->A1_LOJA)+' - '+alltrim(TB1TMP->A1_NOME))
		oSection1:Cell('F3_EMISSAO'):SetValue(dtoc(stod(TB1TMP->F3_EMISSAO)))
		oSection1:Cell('F3_VALCONT'):SetValue(TB1TMP->F3_VALCONT)
		
		oSection1:Printline()

		TB1TMP->(dbSkip())
			
	enddo
	
	//imprimo uma linha para separar um vendedor de outro
	oReport:ThinLine()

	//finalizo a primeira seção
	oSection1:Finish()			

return


static function Query()

	local 	cQuery	:= '',;
			cFiltro	:= ''
	
	
	cFiltro	:= ' @FILIAL	= "'+xFilial('SF3')+'"'
	if !empty(mv_par01)
		cFiltro	+= ', @DTINIC = "'+DTOS(mv_par01)+'"'
	endif			
	if !empty(mv_par02)
		cFiltro	+= ', @DTFINC = "'+DTOS(mv_par02)+'"'
	endif			
	if !empty(mv_par03)
		cFiltro	+= ', @DTINIE = "'+DTOS(mv_par03)+'"'
	endif			
	if !empty(mv_par04)
		cFiltro	+= ', @DTFINE = "'+DTOS(mv_par04)+'"'
	endif			
	if !empty(mv_par05)
		cFiltro	+= ', @SERIEI = "'+mv_par05+'"'
	endif			
	if !empty(mv_par06)
		cFiltro	+= ', @SERIEF = "'+mv_par06+'"'
	endif			
	if !empty(mv_par07)
		cFiltro	+= ', @NOTAI = "'+mv_par07+'"'
	endif			
	if !empty(mv_par08)
		cFiltro	+= ', @NOTAF = "'+mv_par08+'"'
	endif			
	
	cQuery	:='exec dbo.PR_RL05008 '+cFiltro
return cQuery

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(cPerg,"01","Data Canc. De ?" 		,"Data Canc. De ?"	,"Data Canc. De ?"	,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"02","Data Canc. Até ?" 	,"Data Canc. Até ?"	,"Data Canc. Até ?"	,"mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"03","Data Emis. De ?" 		,"Data Emis. De ?"	,"Data Emis. De ?"	,"mv_ch3","D",08,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"04","Data Emis. Até ?" 	,"Data Emis. Até ?"	,"Data Emis. Até ?"	,"mv_ch4","D",08,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"05","Série De ?" 			,"Série De ?"		,"Série De ?"		,"mv_ch5","C",tamsx3('F3_SERIE')[1],0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"06","Série Até ?" 			,"Série Até ?"		,"Série Até ?"		,"mv_ch6","C",tamsx3('F3_SERIE')[1],0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"07","Num. Nota De ?" 		,"Num. Nota De ?"	,"Num. Nota De ?"	,"mv_ch7","C",tamsx3('F3_NFISCAL')[1],0,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"08","Num. Nota Até ?" 		,"Num. Nota Até ?"	,"Num. Nota Até ?"	,"mv_ch8","C",tamsx3('F3_NFISCAL')[1],0,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","")

return
