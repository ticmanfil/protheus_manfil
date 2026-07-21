#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'report.ch'

/*/
===============================================================================================================================
Programa----------: RL39001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 19/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para gerar relatorio de MOTORISTA X KM RODADO
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
user function RL39001() 

	local oReport 	:= nil
	local cPerg		:= 'RL39001'

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
	
	oReport	:= TReport():New(cNome,'RELATÓRIO KM RODADO X MOTORISTA - '+cValToChar(FirstDate(mv_par01))+' a '+cValToChar(mv_par01),cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO KM RODADO X MOTORISTA - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02))
//	oReport	:= TReport():New(cNome,'RELATÓRIO DE META X REALIZADO',cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO DE META X REALIZADO')
	oReport:cfontbody	:= 'courier new'
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:SetTotalText('Total ')
	
	//configurando a primeira seção
	//TRSection():New( 	/*<oParent>	*/, /*<cTitle>*/, /*<uTable>*/, /*<aOrder>*/, /*<lLoadCells>*/, /*<lLoadOrder>*/, /*<uTotalText>, /*<lTotalInLine>*/, /*<lHeaderPage>*/, /*<lHeaderBreak>*/, /*<lPageBreak>*/, /*<lLineBreak>*/, /*<nLeftMargin>*/, /*<lLineStyle> */, /*<nColSpace>*/,	/*<lAutoSize>*/, /*<cCharSeparator>*/, /*<nLinesBefore>*/, /*<nCols>*/, /*<nClrBack>*/, /*<nClrFore>*/, /*<nPercentage>*/ )
	oSection1:= TRSection():New(oReport,'MOTORISTA',{'Z11'},,.F.,.T.,'Sub Total',.F.)
	//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>*/,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
	TRCell():New(oSection1,'Z11_MOTORI'	,'TB1TMP',U_UX3Titulo('Z11_MOTORI')	,x3Picture('Z11_MOTORI')	,tamsx3('Z11_MOTORI')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'DA4_NREDUZ'	,'TB1TMP',U_UX3Titulo('DA4_NREDUZ')	,x3Picture('DA4_NREDUZ')	,tamsx3('DA4_NREDUZ')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'DISTANCIA'	,'TB1TMP','Distância'				,'@E 999,999,999' 	,0,.F.,,'RIGHT',,,,,.F.,)
	TRCell():New(oSection1,'TEMPO'		,'TB1TMP','Tempo Hora'				,'@E 999,999,999'	,0,.F.,,'RIGHT',,,,,.F.,)

	//configurando o totalizador
	//TRFunction():New(<oCell>,<cName>,<cFunction>,<oBreak>,<cTitle>,<cPicture>,<uFormula>,<lEndSection>,<lEndReport>,<lEndPage>,<oParent>,<bCondition>,<lDisable>,<bCanPrint>)
	TRFunction():New(oSection1:Cell('DISTANCIA'),nil,'SUM',,,'@E 999,999,999',,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('TEMPO'),nil,'SUM',,,'@E 999,999,999',,.T.,.T.,.T.,oSection1)

return(oReport)


static function ReportPrint(oReport) 

	local 	oSection1 	:= oReport:Section(1),;
			cQuery    	:= '',;
			dIni		:= FirstDate(mv_par01),;
			dFin		:= mv_par01

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
		oSection1:Cell('Z11_MOTORI'):SetValue(TB1TMP->Z11_MOTORI)
		oSection1:Cell('DA4_NREDUZ'):SetValue(TB1TMP->DA4_NREDUZ)
		oSection1:Cell('DISTANCIA'):SetValue(TB1TMP->DISTANCIA)
		oSection1:Cell('TEMPO'):SetValue(TEMPO)

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
	
	cQuery	:='exec PR_RL39001 @FILIAL	= "'+xFilial('SCT')+'", @DTINI = "'+DTOS(FirstDate(mv_par01))+'", @DTFIN = "'+DTOS(LastDate(mv_par01))+'"'	

return cQuery

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(cPerg,"01","Data Base ?" ,"Data Base ?"     ,"Data Base ?"       ,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")

return



 