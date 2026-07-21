#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'report.ch'

/*/
===============================================================================================================================
Programa----------: RL06003
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 06/12/2018
===============================================================================================================================
Descrição---------: Este programa serve para gerar relatorio de recebimento por vendedor
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
user function RL06003() 

	local oReport 	:= nil
	local cPerg		:= 'RL06003'

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
	
	oReport	:= TReport():New(cNome,'RELATÓRIO DE RECEBIMENTO POR VENDEDOR',cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO DE RECEBIMENTO POR VENDEDOR')
	oReport:cfontbody	:= 'courier new'
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:SetTotalText('Total ')
	
	//configurando a primeira seção
	oSection1:= TRSection():New( 	/*<oParent>			*/	oReport		, /*<cTitle>			*/	'VENDEDORES'	, /*<uTable>		*/	{'SA3'}	, ;
									/*<aOrder>			*/				, /*<lLoadCells>		*/	.F.				, /*<lLoadOrder>	*/	.T.		, ;
									/*<uTotalText>		*/	'Sub Total'	, /*<lTotalInLine>		*/	.F.				, /*<lHeaderPage>	*/			, ;
									/*<lHeaderBreak>	*/				, /*<lPageBreak> 		*/					, /*<lLineBreak> 	*/			, ;
									/*<nLeftMargin> 	*/				, /*<lLineStyle> 		*/					, /*<nColSpace> 	*/			, ;
									/*<lAutoSize> 		*/				, /*<cCharSeparator>	*/					, /*<nLinesBefore> 	*/			, ;
									/*<nCols> 			*/				, /*<nClrBack> 			*/					, /*<nClrFore> 		*/			, ;
									/*<nPercentage>		*/ )
	TRCell():New( 	/*<oParent> 	*/ oSection1				, /*<cName> 		*/ 'A3_NOME'				, /*<cAlias> 		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ U_UX3Titulo('A3_NOME')	, /*<cPicture>		*/ x3Picture('A3_NOME')		, /*<nSize> 		*/ tamsx3('A3_NOME')[1]		, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/							, /*<cAlign> 		*/ 'LEFT'					, ;
					/*<lLineBreak> 	*/							, /*<cHeaderAlign> 	*/ 'LEFT'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace> 	*/							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/							, /*<lBold> 		*/)

	//configurando a segunda seção
	TRCell():New( 	/*<oParent> 	*/ oSection1				, /*<cName> 		*/ 'VLNF'					, /*<cAlias>		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ 'VL DINHEIRO'			, /*<cPicture> 		*/ x3Picture('E1_SALDO')	, /*<nSize> 		*/ tamsx3('E1_SALDO')[1]	, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/ 							, /*<cAlign> 		*/ 'RIGHT'					, ;
					/*<lLineBreak> 	*/ .T.						, /*<cHeaderAlign> 	*/ 'CENTER'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace> 	*/ 							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/ 							, /*<lBold> 		*/)
	TRCell():New( 	/*<oParent> 	*/ oSection1				, /*<cName> 		*/ 'VLCH'					, /*<cAlias> 		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ 'VL CHEQUE'				, /*<cPicture> 		*/ x3Picture('E1_SALDO')	, /*<nSize> 		*/ tamsx3('E1_SALDO')[1]	, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/ 							, /*<cAlign> 		*/ 'RIGHT'					, ;
					/*<lLineBreak> 	*/ .T.						, /*<cHeaderAlign> 	*/ 'CENTER'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace> 	*/ 							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/ 							, /*<lBold> 		*/)
	TRCell():New( 	/*<oParent> 	*/ oSection1				, /*<cName> 		*/ 'VLBOL'					, /*<cAlias> 		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ 'VL BOLETA'				, /*<cPicture> 		*/ x3Picture('E1_SALDO')	, /*<nSize> 		*/ tamsx3('E1_SALDO')[1]	, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/ 							, /*<cAlign> 		*/ 'RIGHT'					, ;
					/*<lLineBreak> 	*/ .T.						, /*<cHeaderAlign> 	*/ 'CENTER'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace> 	*/							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/							, /*<lBold> 		*/)
	TRCell():New( 	/*<oParent> 	*/ oSection1				, /*<cName> 		*/ 'VLREN'					, /*<cAlias> 		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ 'VL RENEG'				, /*<cPicture> 		*/ x3Picture('E1_SALDO')	, /*<nSize> 		*/ tamsx3('E1_SALDO')[1]	, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/ 							, /*<cAlign> 		*/ 'RIGHT'					, ;
					/*<lLineBreak> 	*/ .T.						, /*<cHeaderAlign> 	*/ 'CENTER'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace> 	*/ 							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/ 							, /*<lBold> 		*/)
	TRCell():New( 	/*<oParent> 	*/ oSection1				, /*<cName> 		*/ 'VLOUT'					, /*<cAlias> 		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ 'VL OUTROS'				, /*<cPicture> 		*/ x3Picture('E1_SALDO')	, /*<nSize> 		*/ tamsx3('E1_SALDO')[1]	, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/ 							, /*<cAlign> 		*/ 'RIGHT'					, ;
					/*<lLineBreak> 	*/ .T.						, /*<cHeaderAlign> 	*/ 'CENTER'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace> 	*/ 							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/ 							, /*<lBold> 		*/)
	TRCell():New( 	/*<oParent> 	*/ oSection1				, /*<cName> 		*/ 'VLTOTAL'				, /*<cAlias> 		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ 'TOTAL'					, /*<cPicture> 		*/ x3Picture('E1_SALDO')	, /*<nSize> 		*/ tamsx3('E1_SALDO')[1]	, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/ 							, /*<cAlign> 		*/ 'RIGHT'					, ;
					/*<lLineBreak> 	*/ .T.						, /*<cHeaderAlign> 	*/ 'CENTER'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace> 	*/ 							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/ 							, /*<lBold> 		*/)

	//configurando o totalizador
	TRFunction():New(	/*<oCell>		*/	oSection1:Cell('VLNF')		, /*<cName>			*/	NIL				, /*<cFunction>		*/	'SUM'					, ;
						/*<oBreak>		*/								, /*<cTitle> 		*/					, /*<cPicture> 		*/	x3Picture('E1_SALDO')	, ;
						/*<uFormula>	*/								, /*<lEndSection> 	*/	.T.				, /*<lEndReport> 	*/	.T.						, ;
						/*<lEndPage> 	*/	.T.							, /*<oParent> 		*/	oSection1		, /*<bCondition> 	*/							, ;
						/*<lDisable> 	*/								, /*<bCanPrint>		*/)
	TRFunction():New(	/*<oCell>		*/	oSection1:Cell('VLCH')		, /*<cName>			*/	NIL				, /*<cFunction>		*/	'SUM'					, ;
						/*<oBreak>		*/								, /*<cTitle> 		*/					, /*<cPicture> 		*/	x3Picture('E1_SALDO')	, ;
						/*<uFormula>	*/								, /*<lEndSection> 	*/	.T.				, /*<lEndReport> 	*/	.T.						, ;
						/*<lEndPage> 	*/	.T.							, /*<oParent> 		*/	oSection1		, /*<bCondition> 	*/							, ;
						/*<lDisable> 	*/								, /*<bCanPrint>		*/)
	TRFunction():New(	/*<oCell>		*/	oSection1:Cell('VLBOL')		, /*<cName>			*/	NIL				, /*<cFunction>		*/	'SUM'					, ;
						/*<oBreak>		*/								, /*<cTitle> 		*/					, /*<cPicture> 		*/	x3Picture('E1_SALDO')	, ;
						/*<uFormula>	*/								, /*<lEndSection> 	*/	.T.				, /*<lEndReport> 	*/	.T.						, ;
						/*<lEndPage> 	*/	.T.							, /*<oParent> 		*/	oSection1		, /*<bCondition> 	*/							, ;
						/*<lDisable> 	*/								, /*<bCanPrint>		*/)
	TRFunction():New(	/*<oCell>		*/	oSection1:Cell('VLREN')		, /*<cName>			*/	NIL				, /*<cFunction>		*/	'SUM'					, ;
						/*<oBreak>		*/								, /*<cTitle> 		*/					, /*<cPicture> 		*/	x3Picture('E1_SALDO')	, ;
						/*<uFormula>	*/								, /*<lEndSection> 	*/	.T.				, /*<lEndReport> 	*/	.T.						, ;
						/*<lEndPage> 	*/	.T.							, /*<oParent> 		*/	oSection1		, /*<bCondition> 	*/							, ;
						/*<lDisable> 	*/								, /*<bCanPrint>		*/)
	TRFunction():New(	/*<oCell>		*/	oSection1:Cell('VLOUT')		, /*<cName>			*/	NIL				, /*<cFunction>		*/	'SUM'					, ;
						/*<oBreak>		*/								, /*<cTitle> 		*/					, /*<cPicture> 		*/	x3Picture('E1_SALDO')	, ;
						/*<uFormula>	*/								, /*<lEndSection> 	*/	.T.				, /*<lEndReport> 	*/	.T.						, ;
						/*<lEndPage> 	*/	.T.							, /*<oParent> 		*/	oSection1		, /*<bCondition> 	*/							, ;
						/*<lDisable> 	*/								, /*<bCanPrint>		*/)
	TRFunction():New(	/*<oCell>		*/	oSection1:Cell('VLTOTAL')	, /*<cName>			*/	NIL				, /*<cFunction>		*/	'SUM'					, ;
						/*<oBreak>		*/								, /*<cTitle> 		*/					, /*<cPicture> 		*/	x3Picture('E1_SALDO')	, ;
						/*<uFormula>	*/								, /*<lEndSection> 	*/	.T.				, /*<lEndReport> 	*/	.T.						, ;
						/*<lEndPage> 	*/	.T.							, /*<oParent> 		*/	oSection1		, /*<bCondition> 	*/							, ;
						/*<lDisable> 	*/								, /*<bCanPrint>		*/)

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
		oSection1:Cell('A3_NOME'):SetValue(TB1TMP->VENDEDOR)
		oSection1:Cell('VLNF'):SetValue(TB1TMP->VLNF)
		oSection1:Cell('VLCH'):SetValue(TB1TMP->VLCH)
		oSection1:Cell('VLBOL'):SetValue(TB1TMP->VLBOL)
		oSection1:Cell('VLREN'):SetValue(TB1TMP->VLREN)
		oSection1:Cell('VLOUT'):SetValue(TB1TMP->VLOUT)
		oSection1:Cell('VLTOTAL'):SetValue(TB1TMP->VLTOTAL)
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
	
	cQuery	:='exec dbo.PR_RL06003 @DATAINI = "'+DTOS(mv_par01)+'", @DATAFIM = "'+DTOS(mv_par02)+'"'	

return cQuery

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(     cPerg,"01","Data De?" ,"."     ,"."       ,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	U_XPUTSX1(     cPerg,"02","Data Ate?","."     ,"."       ,"mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")

return
