#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'report.ch'

/*/
===============================================================================================================================
Programa----------: RL06004
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 19/09/2019
===============================================================================================================================
Descrição---------: Este programa serve para gerar relatorio de CRA VENDEDORES
===============================================================================================================================
Uso---------------: Relatorio FINANCEIRO
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
user function RL06004() 

	local oReport 	:= nil
	local cPerg		:= 'RL06004'

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
			
	local	aArea		:= getArea(),;
			aAreaSA3	:= SA3->(getArea())
			
	local	cVend		:= ''
	
	cVend	:= posicione('SA3',1,xFilial('SA3')+mv_par01,'A3_NOME')
	
	oReport	:= TReport():New(cNome,'COBRANÇA VENDEDOR '+alltrim(cVend)+' até '+cValToChar(mv_par03),cNome,{|oReport| ReportPrint(oReport)},'COBRANÇA VENDEDOR '+mv_par01+' até '+cValToChar(mv_par03))
	oReport:SetLandscape()	//SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:SetTotalText('Total ')
	
	//configurando a primeira seção
	//TRSection():New( 	/*<oParent>	*/, /*<cTitle>*/, /*<uTable>*/, /*<aOrder>*/, /*<lLoadCells>*/, /*<lLoadOrder>*/, /*<uTotalText>, /*<lTotalInLine>*/, /*<lHeaderPage>*/, /*<lHeaderBreak>*/, /*<lPageBreak>*/, /*<lLineBreak>*/, /*<nLeftMargin>*/, /*<lLineStyle> */, /*<nColSpace>*/,	/*<lAutoSize>*/, /*<cCharSeparator>*/, /*<nLinesBefore>*/, /*<nCols>*/, /*<nClrBack>*/, /*<nClrFore>*/, /*<nPercentage>*/ )
	oSection1:= TRSection():New(oReport,'CIDADE',{'SA1'},,.F.,.T.,'Sub Total',.F.)
	//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>*/,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
	TRCell():New(oSection1,'A1_MUN'		,'TB1TMP',U_UX3Titulo('A1_MUN')		,x3Picture('A1_MUN')	,tamsx3('A1_MUN')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'E1_NOMCLI'	,'TB1TMP',U_UX3Titulo('E1_NOMCLI')	,x3Picture('E1_NOMCLI')	,tamsx3('E1_NOMCLI')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'E1_CLIENTE'	,'TB1TMP',U_UX3Titulo('E1_CLIENTE')	,x3Picture('E1_CLIENTE'),tamsx3('E1_CLIENTE')[1],.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'E1_LOJA'	,'TB1TMP',U_UX3Titulo('E1_LOJA')	,x3Picture('E1_LOJA')	,tamsx3('E1_LOJA')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'E1_NUM'		,'TB1TMP',U_UX3Titulo('E1_NUM')		,x3Picture('E1_NUM')	,tamsx3('E1_NUM')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'E1_PREFIXO'	,'TB1TMP',U_UX3Titulo('E1_PREFIXO')	,x3Picture('E1_PREFIXO'),tamsx3('E1_PREFIXO')[1],.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'E1_TIPO'	,'TB1TMP',U_UX3Titulo('E1_TIPO')	,x3Picture('E1_TIPO')	,tamsx3('E1_TIPO')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'E1_EMISSAO'	,'TB1TMP',U_UX3Titulo('E1_EMISSAO')	,x3Picture('E1_EMISSAO'),tamsx3('E1_EMISSAO')[1],.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'E1_VENCREA'	,'TB1TMP',U_UX3Titulo('E1_VENCREA')	,x3Picture('E1_VENCREA'),tamsx3('E1_VENCREA')[1],.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'DTREF'		,'TB1TMP','Data Base'				,x3Picture('E1_EMISSAO'),tamsx3('E1_EMISSAO')[1],.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'ATRS'		,'TB1TMP','Dia Atraso'				,'@E 999'				,3						,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'E1_VALOR'	,'TB1TMP',U_UX3Titulo('E1_VALOR')	,x3Picture('E1_VALOR')	,tamsx3('E1_VALOR')[1]	,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'E1_SALDO'	,'TB1TMP',U_UX3Titulo('E1_SALDO')	,x3Picture('E1_SALDO')	,tamsx3('E1_SALDO')[1]	,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'JRS'		,'TB1TMP','Valor Jrs'				,x3Picture('E1_VALOR')	,tamsx3('E1_VALOR')[1]	,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'VLATUAL'	,'TB1TMP','Valor Atual'				,x3Picture('E1_VALOR')	,tamsx3('E1_VALOR')[1]	,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)

	//configurando o totalizador
	oBreak := TRBreak():New(oSection1,{ || oSection1:Cell('A1_MUN'):uPrint },'Sub-Total',.F.) 
	
	//TRFunction():New(<oCell>,<cName>,<cFunction>,<oBreak>,<cTitle>,<cPicture>,<uFormula>,<lEndSection>,<lEndReport>,<lEndPage>,<oParent>,<bCondition>,<lDisable>,<bCanPrint>)
	TRFunction():New(oSection1:Cell('A1_MUN')	,nil,'COUNT',oBreak,,,,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('E1_VALOR')	,nil,'SUM',oBreak,,x3Picture('E1_VALOR'),,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('E1_SALDO')	,nil,'SUM',oBreak,,x3Picture('E1_SALDO'),,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('JRS')		,nil,'SUM',oBreak,,x3Picture('E1_SALDO'),,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('VLATUAL')	,nil,'SUM',oBreak,,x3Picture('E1_VALOR'),,.T.,.T.,.T.,oSection1)
	
	restArea(aArea)
	restArea(aAreaSA3)

return(oReport)


static function ReportPrint(oReport) 

	local 	oSection1 	:= oReport:Section(1),;
			cQuery    	:= '',;
			cVend		:= mv_par01,;
			nJrs		:= mv_par02,;
			dData		:= mv_par03,;
			cTipo		:= mv_par05
	
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
		oSection1:Cell('A1_MUN'):SetValue(alltrim(TB1TMP->A1_MUN))
		oSection1:Cell('E1_NOMCLI'):SetValue(TB1TMP->E1_NOMCLI)
		oSection1:Cell('E1_CLIENTE'):SetValue(TB1TMP->E1_CLIENTE)
		oSection1:Cell('E1_LOJA'):SetValue(TB1TMP->E1_LOJA)
		oSection1:Cell('E1_NUM'):SetValue(TB1TMP->E1_NUM)
		oSection1:Cell('E1_PREFIXO'):SetValue(TB1TMP->E1_PREFIXO)
		oSection1:Cell('E1_TIPO'):SetValue(TB1TMP->E1_TIPO)
		oSection1:Cell('E1_EMISSAO'):SetValue(stod(TB1TMP->E1_EMISSAO))
		oSection1:Cell('E1_VENCREA'):SetValue(stod(TB1TMP->E1_VENCREA))
		oSection1:Cell('DTREF'):SetValue(stod(TB1TMP->DTREF))
		oSection1:Cell('ATRS'):SetValue(TB1TMP->ATRS)
		oSection1:Cell('E1_VALOR'):SetValue(TB1TMP->E1_VALOR)
		oSection1:Cell('E1_SALDO'):SetValue(TB1TMP->E1_SALDO)
	//	oSection1:Cell('TXJRS'):SetValue(TXJRS)
		oSection1:Cell('JRS'):SetValue(TB1TMP->JRS)
		oSection1:Cell('VLATUAL'):SetValue(TB1TMP->VLATUAL)
		
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
	
	cQuery	:='exec dbo.PR_RL06004 @VEND = "'+mv_par01+'", @JRS = '+cvaltochar(mv_par02)+', @DTVENCTO = "'+DTOS(mv_par03)+'", @DTCOB = "'+DTOS(mv_par04)+'"'
	
	if !empty(mv_par05)	
		cQuery	+=' , @TIPO = "'+mv_par05+'"'
	endif
	
return cQuery

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(cPerg,"01","Vendedor ?", "Vendedor ?"     ,"Vendedor ?"       ,"mv_ch1","C",03,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"02","Juros ?", "Juros ?"     ,"Juros ?"       ,"mv_ch2","N",05,2,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"03","Dt Vencto Ate?", "Dt Vencto Ate?"     ,"Dt Vencto Ate ?"       ,"mv_ch3","D",08,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"04","Data Cobrança?", "Data Cobrança ?"     ,"Data Cobrança ?"       ,"mv_ch4","D",08,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"05","Tipo?" ,"Tipo?"     ,"Tipo?"       ,"mv_ch5","C",03,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","")

return
