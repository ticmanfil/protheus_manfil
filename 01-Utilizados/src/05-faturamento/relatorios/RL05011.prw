#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'report.ch'

/*/
===============================================================================================================================
Programa----------: RL05011
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 14/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para gerar relatorio de meta x realizado por dec
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
RENATO FUZESSY 	| 20/07/2021	| ALTERANDO PARA PROC 																										
----------------:---------------:----------------------------------------------------------------------------------------------:
				|				|																											
================================================================================================================================
/*/
user function RL05011() 

	local oReport 	:= nil
	local cPerg		:= 'RL05011'

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
			oSection2	:= nil,;
			cTipo		:= mv_par02
	
	if cTipo = 1  //DECANATO
		oReport	:= TReport():New(cNome,'RELATÓRIO DE META X RELIZADO DECADONO '+mv_par01,cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO DE META X REALIZADO DECADONO - '+mv_par01)
	elseif cTipo = 2	//MENSAL
		oReport	:= TReport():New(cNome,'RELATÓRIO DE META X RELIZADO MENSAL '+mv_par01,cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO DE META X REALIZADO MENSAL - '+mv_par01)
	elseif cTipo = 3	//TRIMESTRAL
		oReport	:= TReport():New(cNome,'RELATÓRIO DE META X RELIZADO TRIMESTRAL '+mv_par01,cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO DE META X REALIZADO TRIMESTRAL - '+mv_par01)
	elseif cTipo = 4	//ANUAL
		oReport	:= TReport():New(cNome,'RELATÓRIO DE META X RELIZADO ANUAL '+mv_par01,cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO DE META X REALIZADO ANUAL - '+mv_par01)
	end
	oReport:cfontbody	:= 'courier new'
	oReport:SetPortrait()	//SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:SetTotalText('Total ')
	
	//configurando a primeira seção
	//TRSection():New( 	/*<oParent>	*/, /*<cTitle>*/, /*<uTable>*/, /*<aOrder>*/, /*<lLoadCells>*/, /*<lLoadOrder>*/, /*<uTotalText>, /*<lTotalInLine>*/, /*<lHeaderPage>*/, /*<lHeaderBreak>*/, /*<lPageBreak>*/, /*<lLineBreak>*/, /*<nLeftMargin>*/, /*<lLineStyle> */, /*<nColSpace>*/,	/*<lAutoSize>*/, /*<cCharSeparator>*/, /*<nLinesBefore>*/, /*<nCols>*/, /*<nClrBack>*/, /*<nClrFore>*/, /*<nPercentage>*/ )
	if cTipo = 1  //DECANATO
		oSection1:= TRSection():New(oReport,'DECANATO',{'SA3'},,.F.,.T.,'Sub Total',.F.)
	elseif cTipo = 2	//MENSAL
		oSection1:= TRSection():New(oReport,'MENSAL',{'SA3'},,.F.,.T.,'Sub Total',.F.)
	elseif cTipo = 3	//TRIMESTRAL
		oSection1:= TRSection():New(oReport,'TRIMESTRAL',{'SA3'},,.F.,.T.,'Sub Total',.F.)
	elseif cTipo = 4	//ANUAL
		oSection1:= TRSection():New(oReport,'ANUAL',{'SA3'},,.F.,.T.,'Sub Total',.F.)
	end
	//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>*/,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
	if cTipo = 1  //DECANATO
		TRCell():New(oSection1,'PERIODO'	,'TB1TMP','DECANATO'	,x3Picture('A3_NOME')	,tamsx3('A3_NOME')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	elseif cTipo = 2	//MENSAL
		TRCell():New(oSection1,'PERIODO'	,'TB1TMP','MÊS'			,x3Picture('A3_NOME')	,tamsx3('A3_NOME')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	elseif cTipo = 3	//TRIMESTRAL
		TRCell():New(oSection1,'PERIODO'	,'TB1TMP','TRIMESTRE'	,x3Picture('A3_NOME')	,tamsx3('A3_NOME')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	elseif cTipo = 4	//ANUAL
		TRCell():New(oSection1,'PERIODO'	,'TB1TMP','ANO'			,x3Picture('A3_NOME')	,tamsx3('A3_NOME')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	end

	oSection2:= TRSection():New(oReport,'FATURAMENTO',{'SE1'},,.F.,.T.,'Sub Total',.F.)
	TRCell():New(oSection2,'VEND'		,'TB1TMP',U_UX3Titulo('A3_NOME')	,x3Picture('A3_NOME')	,tamsx3('A3_NOME')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	//TRCell():New(oSection2,'VEND'		,'TB1TMP',U_UX3Titulo('A3_NOME')	,x3Picture('A3_NOME')	,20	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection2,'META'		,'TB1TMP','Meta'					,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection2,'VENLIQ'		,'TB1TMP','Venda'					,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection2,'PMETA'		,'TB1TMP','% Meta'					,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection2,'PFAT'		,'TB1TMP','% Fat'					,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection2,'PDEV'		,'TB1TMP','% Dev'					,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection2,'PDESC'		,'TB1TMP','% Desc'					,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection2,'METAA'		,'TB1TMP','Meta Ant'				,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection2,'VENLIQA'	,'TB1TMP','Venda Ant'				,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection2,'PMETAA'		,'TB1TMP','% Meta Ant'				,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection2,'PFATA'		,'TB1TMP','% Fat Ant'				,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection2,'PDEVA'		,'TB1TMP','% Dev Ant'				,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection2,'PDESCA'		,'TB1TMP','% Desc Ant'				,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)

	//configurando o totalizador
	//TRFunction():New(<oCell>,<cName>,<cFunction>,<oBreak>,<cTitle>,<cPicture>,<uFormula>,<lEndSection>,<lEndReport>,<lEndPage>,<oParent>,<bCondition>,<lDisable>,<bCanPrint>)
	TRFunction():New(oSection2:Cell('META'),nil,'SUM',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('VENLIQ'),nil,'SUM',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('PFAT'),nil,'SUM',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('PDEV'),nil,'AVERAGE',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('PDESC'),nil,'AVERAGE',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('METAA'),nil,'SUM',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('VENLIQA'),nil,'SUM',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('PFATA'),nil,'SUM',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('PDEVA'),nil,'AVERAGE',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection2)
	TRFunction():New(oSection2:Cell('PDESCA'),nil,'AVERAGE',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection2)

return(oReport)


static function ReportPrint(oReport) 

	local 	oSection1 	:= oReport:Section(1),;
			oSection2 	:= oReport:Section(2),;
			cQuery    	:= '',;
			nPeriodo	:= ''
	
	cQuery := query(mv_par01,mv_par02)
		
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
	
		//inicializo a primeira seção
		oSection1:Init()

		oReport:IncMeter()
					
		incProc('Imprimindo relatório')
		
		nPeriodo	:= TB1TMP->PERIODO

		//imprimo a primeira seção				
		oSection1:Cell('PERIODO'):SetValue(TB1TMP->PERIODO)
		oSection1:Printline()
	
		//inicializo a segunda seção
		oSection2:init()
		
		//imprimo a segunda seção
		while TB1TMP->PERIODO == nPeriodo
			oReport:IncMeter()

			incProc('Imprimindo vendedor '+alltrim(TB1TMP->VEND))
			oSection2:Cell('VEND'):SetValue(TB1TMP->VEND)
			oSection2:Cell('META'):SetValue(TB1TMP->VLMETA)
			oSection2:Cell('VENLIQ'):SetValue(TB1TMP->VLVENLIQ)
			oSection2:Cell('PMETA'):SetValue(TB1TMP->PMETA)
			oSection2:Cell('PFAT'):SetValue(TB1TMP->PFAT)
			oSection2:Cell('PDEV'):SetValue(TB1TMP->PDEV)
			oSection2:Cell('PDESC'):SetValue(TB1TMP->PDESC)
			oSection2:Cell('METAA'):SetValue(TB1TMP->VLMETAA)
			oSection2:Cell('VENLIQA'):SetValue(TB1TMP->VLVENLIQA)
			oSection2:Cell('PMETAA'):SetValue(TB1TMP->PMETAA)
			oSection2:Cell('PFATA'):SetValue(TB1TMP->PFATA)
			oSection2:Cell('PDEVA'):SetValue(TB1TMP->PDEVA)
			oSection2:Cell('PDESCA'):SetValue(TB1TMP->PDESCA)
			oSection2:Printline()

			TB1TMP->(dbSkip())
			
		enddo
		
		//finalizo a segunda seção para que seja reiniciada para o proximo registro
 		oSection2:Finish()

 		//imprimo uma linha para separar um vendedor de outro
 		oReport:ThinLine()

 		//finalizo a primeira seção
		oSection1:Finish()			
	
	enddo

return

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(cPerg,"01","Periodo?" ,"Perioodo?"     ,"Periodo?"       ,"mv_ch1","C",06,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"02","Tipo?"	,"Tipo?"         ,"Tipo?"          ,"mv_ch2","N",14,2,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")

return

static function Query(pPeriodo,pTipo)

	local cQuery	:= ''
	
	if pTipo = 1  //DECANATO
		cQuery	:='exec dbo.PR_RL05011C @vend = null, @pPeriodo = "'+pPeriodo+'"
	elseif pTipo = 2	//MENSAL
		cQuery	:='exec dbo.PR_RL05011D @vend = null, @pPeriodo = "'+pPeriodo+'"
	elseif pTipo = 3	//TRIMESTRAL
		cQuery	:='exec dbo.PR_RL05011E @vend = null, @pPeriodo = "'+pPeriodo+'"
	elseif pTipo = 4	//ANUAL
		cQuery	:='exec dbo.PR_RL05011F @vend = null, @pPeriodo = "'+pPeriodo+'"
	end

return cQuery
