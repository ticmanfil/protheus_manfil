#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
/*/
===============================================================================================================================
Programa----------: RL05004
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 20/12/2018
===============================================================================================================================
Descrição---------: RELATORIO DE ORCAMENTOS EM ABERTOS POR VENDEDORES
===============================================================================================================================
Uso---------------: No orcamentos (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
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

user function RL05004() 

	local oReport 	:= nil
	local cPerg		:= 'RL05004'

	oReport	:= RptDef(cPerg)
	oReport:PrintDialog()

return
         
static function RptDef(cNome)

	local oReport	:= Nil
	local oSection1	:= Nil
	
	oReport	:= TReport():New(cNome,'RELATÓRIO DE ORÇAMENTOS EM ABERTOS A MAIS DE 2 DIAS',cNome,{|oReport| rptPrint(oReport)},'RELATÓRIO DE ORÇAMENTOS EM ABERTOS A MAIS DE 2 DIAS')
	oReport:cfontbody	:= 'courier new'
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	
	oSection1:= TRSection():New(oReport, 'Vendedores', {'SA3'}, NIL, .F., .T.)
	//TRCell():New( <oParent> , <cName>, <cAlias>, <cTitle>, <cPicture>, <nSize>, <lPixel>, <bBlock>, <cAlign>, <lLineBreak>, <cHeaderAlign>, <lCellBreak> ,;
	//				<nColSpace> , <lAutoSize> , <nClrBack> , <nClrFore> , <lBold> )
	TRCell():New(	/*oParent		*/ oSection1				,/*cName		*/ 'VENDEDOR'				,/*cAlias		*/ 'TB1TMP'					,;
					/*cTitle		*/ U_UX3Titulo('A3_NREDUZ')	,/*cPicture		*/ x3Picture('A3_NREDUZ')	,/*nSize		*/ tamsx3('A3_NREDUZ')[1]+5	,;
					/*lPixel		*/ .F.						,/*bBlock		*/ 							,/*cAlign		*/ 'LEFT'					,;
					/*lCellBreak	*/ .T.						,/*cHeaderAlign	*/ 'CENTER'					,/*lCellBreak	*/							,;
					/*nColSpace		*/							,/*lAutoSize	*/ .F.)
	TRCell():New(	/*oParent		*/ oSection1				,/*cName		*/ 'QTD'					,/*cAlias		*/ 'TB1TMP'					,;
					/*cTitle		*/ 'QUANT.'					,/*cPicture		*/ '@E 999,999,999'			,/*nSize		*/ 6						,;
					/*lPixel		*/ .F.						,/*bBlock		*/ 							,/*cAlign		*/ 'RIGHT'					,;
					/*lCellBreak	*/ .T.						,/*cHeaderAlign	*/ 'CENTER'					,/*lCellBreak	*/							,;
					/*nColSpace		*/							,/*lAutoSize	*/ .F.)
	TRCell():New(	/*oParent		*/ oSection1				,/*cName		*/ 'TIME'					,/*cAlias		*/ 'TB1TMP'					,;
					/*cTitle		*/ 'MAX.ATRASO'				,/*cPicture		*/ '@E 999,999,999'			,/*nSize		*/ 6						,;
					/*lPixel		*/ .F.						,/*bBlock		*/ 							,/*cAlign		*/ 'RIGHT'					,;
					/*lCellBreak	*/ .T.						,/*cHeaderAlign	*/ 'CENTER'					,/*lCellBreak	*/							,;
					/*nColSpace		*/							,/*lAutoSize	*/ .F.)
	TRCell():New(	/*oParent		*/ oSection1				,/*cName		*/ 'MESATUAL'				,/*cAlias		*/ 'TB1TMP'					,;
					/*cTitle		*/ 'MES ATUAL'				,/*cPicture		*/ '@E 999,999,999'			,/*nSize		*/ 6						,;
					/*lPixel		*/ .F.						,/*bBlock		*/ 							,/*cAlign		*/ 'RIGHT'					,;
					/*lCellBreak	*/ .T.						,/*cHeaderAlign	*/ 'CENTER'					,/*lCellBreak	*/							,;
					/*nColSpace		*/							,/*lAutoSize	*/ .F.)
	TRCell():New(	/*oParent		*/ oSection1				,/*cName		*/ 'MESANTERIOR'			,/*cAlias		*/ 'TB1TMP'					,;
					/*cTitle		*/ 'MES ANTERIOR'			,/*cPicture		*/ '@E 999,999,999'			,/*nSize		*/ 6						,;
					/*lPixel		*/ .F.						,/*bBlock		*/ 							,/*cAlign		*/ 'RIGHT'					,;
					/*lCellBreak	*/ .T.						,/*cHeaderAlign	*/ 'CENTER'					,/*lCellBreak	*/							,;
					/*nColSpace		*/							,/*lAutoSize	*/ .F.)
	TRCell():New(	/*oParent		*/ oSection1				,/*cName		*/ 'DEMAISMESES'			,/*cAlias		*/ 'TB1TMP'					,;
					/*cTitle		*/ 'OUTROS MESES'			,/*cPicture		*/ '@E 999,999,999'			,/*nSize		*/ 6						,;
					/*lPixel		*/ .F.						,/*bBlock		*/ 							,/*cAlign		*/ 'RIGHT'					,;
					/*lCellBreak	*/ .T.						,/*cHeaderAlign	*/ 'CENTER'					,/*lCellBreak	*/							,;
					/*nColSpace		*/							,/*lAutoSize	*/ .F.)
	//TRFunction():New( <oCell> , <cName> , <cFunction> , <oBreak> , <cTitle> , <cPicture> , <uFormula> , <lEndSection> , <lEndReport> , <lEndPage> , <oParent> , <bCondition> , <lDisable> , <bCanPrint> ) 
	TRFunction():New(oSection1:Cell('QTD'),NIL,'SUM',,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell('TIME'),NIL,'MAX',,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell('MESATUAL'),NIL,'SUM',,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell('MESANTERIOR'),NIL,'SUM',,,,,.F.,.T.)
	TRFunction():New(oSection1:Cell('DEMAISMESES'),NIL,'SUM',,,,,.F.,.T.)
       
	oSection1:SetTotalText("Total de Itens  .. ")

return(oReport)


static function rptPrint(oReport) 

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
		oSection1:Cell('VENDEDOR'):SetValue(TB1TMP->VENDEDOR)
		oSection1:Cell('QTD'):SetValue(TB1TMP->QTD)
		oSection1:Cell('TIME'):SetValue(TB1TMP->TIME)
		oSection1:Cell('MESATUAL'):SetValue(TB1TMP->MESATUAL)
		oSection1:Cell('MESANTERIOR'):SetValue(TB1TMP->MESANTERIOR)
		oSection1:Cell('DEMAISMESES'):SetValue(TB1TMP->DEMAISMESES)
		 		
		oSection1:Printline()
	
		TB1TMP->(dbSkip())
 				
 		//imprimo uma linha para separar uma NCM de outra
		oReport:ThinLine()
 		
 		
	Enddo
	
	//finalizo a primeira seção
	oSection1:Finish()
		
return


static function Query()

	local cQuery	:= ''
	
	cQuery	:='exec dbo.PR_RL05004'	

return cQuery
