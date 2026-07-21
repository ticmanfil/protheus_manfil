#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'report.ch'

/*/
===============================================================================================================================
Programa----------: RL05012
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 09/08/2021
===============================================================================================================================
Descrição---------: Este programa serve para gerar relatorio de STATUS ORCAMENTO
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
===============================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
===============================================================================================================================
	Autor		|	Data		|										Motivo																
----------------:---------------:----------------------------------------------------------------------------------------------:
			 	| 				| 
----------------:---------------:----------------------------------------------------------------------------------------------:
				|				|																											
================================================================================================================================
/*/
user function RL05012() 

	local oReport 	:= nil
	local cPerg		:= 'RL05012'

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
			oSection1	:= nil,;
			oSection2	:= nil
	
	oReport	:= TReport():New(cNome,'RELATÓRIO DE STATUS ORCAMENTO '+mv_par01,cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO DE STATUS ORCAMENTO - '+mv_par01)
	oReport:cfontbody	:= 'courier new'
	oReport:SetPortrait()	//SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:SetTotalText('Total ')
	
	//configurando a primeira seção
	//TRSection():New( 	/*<oParent>	*/, /*<cTitle>*/, /*<uTable>*/, /*<aOrder>*/, /*<lLoadCells>*/, /*<lLoadOrder>*/, /*<uTotalText>, /*<lTotalInLine>*/, /*<lHeaderPage>*/, /*<lHeaderBreak>*/, /*<lPageBreak>*/, /*<lLineBreak>*/, /*<nLeftMargin>*/, /*<lLineStyle> */, /*<nColSpace>*/,	/*<lAutoSize>*/, /*<cCharSeparator>*/, /*<nLinesBefore>*/, /*<nCols>*/, /*<nClrBack>*/, /*<nClrFore>*/, /*<nPercentage>*/ )
	oSection1:= TRSection():New(oReport,'DECANATO',{'SA3'},,.F.,.T.,'Sub Total',.F.)
	//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>*/,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
	//TRCell():New(oSection1,'PERIODO'	,'TB1TMP','DECANATO'	,x3Picture('A3_NOME')	,tamsx3('A3_NOME')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)

	oSection2:= TRSection():New(oReport,'FATURAMENTO',{'SE1'},,.F.,.T.,'Sub Total',.F.)
	TRCell():New(oSection1,'VEND'		,'TB1TMP',U_UX3Titulo('A3_NOME')	,x3Picture('A3_NOME')	,tamsx3('A3_NOME')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'ABERTO'		,'TB1TMP','ABERTO'					,'@E 999,999,999,999,999',16,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'FATURADO'	,'TB1TMP','FATURADO'				,'@E 999,999,999,999,999',16,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'CANCELADO'	,'TB1TMP','CANCELADO'				,'@E 999,999,999,999,999',16,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'TOTAL'		,'TB1TMP','TOTAL'					,'@E 999,999,999,999,999',16,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)

	//configurando o totalizador
	//TRFunction():New(<oCell>,<cName>,<cFunction>,<oBreak>,<cTitle>,<cPicture>,<uFormula>,<lEndSection>,<lEndReport>,<lEndPage>,<oParent>,<bCondition>,<lDisable>,<bCanPrint>)
	TRFunction():New(oSection1:Cell('ABERTO'),nil,'SUM',,,'@E 999,999,999,999,999',,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('FATURADO'),nil,'SUM',,,'@E 999,999,999,999,999',,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('CANCELADO'),nil,'SUM',,,'@E 999,999,999,999,999',,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('TOTAL'),nil,'SUM',,,'@E 999,999,999,999,999',,.T.,.T.,.T.,oSection1)

return(oReport)


static function ReportPrint(oReport) 

	local 	oSection1 	:= oReport:Section(1)
			cQuery    	:= ''
	
	cQuery := query(mv_par01)
		
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
	//while !Eof()
		
		if oReport:Cancel()
			exit
		endif
	
		oReport:IncMeter()
					
		incProc('Imprimindo relatório')
		
		oSection1:Cell('VEND'):SetValue(TB1TMP->VEN)
		oSection1:Cell('ABERTO'):SetValue(TB1TMP->ABERTO)
		oSection1:Cell('FATURADO'):SetValue(TB1TMP->FATURADO)
		oSection1:Cell('CANCELADO'):SetValue(TB1TMP->CANCELADO)
		oSection1:Cell('TOTAL'):SetValue(TB1TMP->TOTAL)
		oSection1:Printline()

		TB1TMP->(dbSkip())

	enddo
			
	oReport:ThinLine()

	//finalizo a primeira seção
	oSection1:Finish()			

return

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(cPerg,"01","Periodo?" ,"Perioodo?"     ,"Periodo?"       ,"mv_ch1","C",06,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	//U_XPUTSX1(cPerg,"02","Tipo?"	,"Tipo?"         ,"Tipo?"          ,"mv_ch2","N",14,2,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")

return

static function Query(pPeriodo)

	local cQuery	:= ''
	
	cQuery	:='exec dbo.PR_RL05012 @mes = "'+pPeriodo+'"

return cQuery
