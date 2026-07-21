#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'report.ch'

/*/
===============================================================================================================================
Programa----------: RL06008
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 20/03/2019
===============================================================================================================================
Descrição---------: Este programa serve para gerar relatorio CONTAS A PAGAR
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
user function RL06008() 

	local oReport 	:= nil
	local cPerg		:= 'RL06008'

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
	
	oReport	:= TReport():New(cNome,'MOVIMENTOS DIÁRIOS - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02),cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO CONTAS A PAGAR - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02))
	oReport:cfontbody	:= 'courier new'
	oReport:SetLandscape()	//SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:SetTotalText('Total ')
	
	//configurando a primeira seção
//	oSection1:= TRSection():New(/*<oParent>*/,/*<cTitle>*/,/*<uTable>*/,/*<aOrder>*/,/*<lLoadCells>*/,/*<lLoadOrder>*/,/*<uTotalText>*/,/*<lTotalInLine>*/,/*<lHeaderPage>*/,/*<lHeaderBreak>*/,/*<lPageBreak>*/,/*<lLineBreak>*/,/*<nLeftMargin>*/,/*<lLineStyle>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<cCharSeparator>*/,/*<nLinesBefore>*/,/*<nCols>*/,/*<nClrBack>*/,/*<nClrFore>*/,	/*<nPercentage>	*/ )
	oSection1:= TRSection():New(oReport,'TITULO',{'SE2'},,.F.,.T.,'Sub Total',.F.)

	//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
	TRCell():New(oSection1,'E2_XPBANC1','TB1TMP',U_UX3Titulo('E2_XPBANC1'),x3Picture('E2_XPBANC1'),tamsx3('E2_XPBANC1')[1],.F.,,'LEFT',,'LEFT',,,.F.)
	TRCell():New(oSection1,'E2_NOMFOR','TB1TMP',U_UX3Titulo('E2_NOMFOR'),x3Picture('E2_NOMFOR'),tamsx3('E2_FORNECE')[1]+tamsx3('E2_LOJA')[1]+tamsx3('E2_NOMFOR')[1]+9,.F.,,'LEFT',,'LEFT',,,.F.)
	TRCell():New(oSection1,'E2_NUM','TB1TMP',U_UX3Titulo('E2_NUM'),x3Picture('E2_NUM'),tamsx3('E2_PREFIXO')[1]+tamsx3('E2_NUM')[1]+tamsx3('E2_PARCELA')[1]+tamsx3('E2_TIPO')[1]+12,.F.,,'LEFT',,'LEFT',,,.F.)
	TRCell():New(oSection1,'E2_EMISSAO','TB1TMP',U_UX3Titulo('E2_EMISSAO'),x3Picture('E2_EMISSAO'),tamsx3('E2_EMISSAO')[1],.F.,,'LEFT',,'LEFT',,,.F.)
	TRCell():New(oSection1,'E2_VENCREA','TB1TMP',U_UX3Titulo('E2_VENCREA'),x3Picture('E2_VENCREA'),tamsx3('E2_VENCREA')[1],.F.,,'LEFT',,'LEFT',,,.F.)
	TRCell():New(oSection1,'E2_VALOR','TB1TMP',U_UX3Titulo('E2_VALOR'),x3Picture('E2_VALOR'),tamsx3('E2_VALOR')[1],.F.,,'RIGHT',,'RIGHT',,,.F.)
	TRCell():New(oSection1,'E2_SALDO','TB1TMP',U_UX3Titulo('E2_SALDO'),x3Picture('E2_SALDO'),tamsx3('E2_SALDO')[1],.F.,,'RIGHT',,'RIGHT',,,.F.)
	TRCell():New(oSection1,'E2_HIST','TB1TMP',U_UX3Titulo('E2_HIST'),x3Picture('E2_HIST'),tamsx3('E2_HIST')[1],.F.,,'LEFT',,'LEFT',,,.T.)

	//configurando o totalizador
	//TRFunction():New(/*<oCell>*/,/*<cName>*/,/*<cFunction>*/,/*<oBreak>*/,/*<cTitle>*/,/*<cPicture>*/,/*<uFormula>*/,/*<lEndSection>*/,/*<lEndReport>*/,/*<lEndPage>*/,/*<oParent>*/,/*<bCondition>*/,/*<lDisable>*/,/*<bCanPrint>*/)
	TRFunction():New(oSection1:Cell('E2_VALOR'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_SALDO'),,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('E2_SALDO'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E2_SALDO'),,.T.,.T.,.T.,oSection1)

return(oReport)


static function ReportPrint(oReport) 

	local oSection1 := oReport:Section(1)
	local cQuery    := ''

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
	while !Eof()
		
		if oReport:Cancel()
			exit
		endif
	
		oReport:IncMeter()
					
		incProc('Imprimindo relatório')
		
		//imprimo a primeira seção				
		oSection1:Cell('E2_XPBANC1'):SetValue(TB1TMP->E2_XPBANC1)
		oSection1:Cell('E2_NOMFOR'):SetValue(TB1TMP->E2_NOMFOR)
		oSection1:Cell('E2_NUM'):SetValue(TB1TMP->E2_NUM)
		oSection1:Cell('E2_EMISSAO'):SetValue(dtoc(stod(TB1TMP->E2_EMISSAO)))
		oSection1:Cell('E2_VENCREA'):SetValue(dtoc(stod(TB1TMP->E2_VENCREA)))
		oSection1:Cell('E2_VALOR'):SetValue(TB1TMP->E2_VALOR)
		oSection1:Cell('E2_SALDO'):SetValue(TB1TMP->E2_SALDO)
		oSection1:Cell('E2_HIST'):SetValue(alltrim(TB1TMP->E2_HIST))
		oSection1:Printline()

		TB1TMP->(dbSkip())
			
	enddo
	
	//imprimo uma linha para separar um vendedor de outro
	oReport:ThinLine()

	//finalizo a primeira seção
	oSection1:Finish()			

return


static function Query()

	local cQuery	:= ''
	
	cQuery	:='exec dbo.PR_RL06008 @FILIAL = "'+XFILIAL('SE2')+'", @DATAI = "'+DTOS(mv_par01)+'", @DATAF = "'+DTOS(mv_par02)+'"'	

return cQuery

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(     cPerg,"01","Vencto Real De?" ,"."     ,"."       ,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	U_XPUTSX1(     cPerg,"02","Vencto Real Ate?","."     ,"."       ,"mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")

return
