#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'report.ch'
/*/
===============================================================================================================================
Programa----------: RD05005
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 20/12/2018
===============================================================================================================================
Descrição---------: RELATORIO DE INADIMPLENCIA POR VENDEDOR
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

user function RL05005() 

	local oReport 	:= nil
	local cPerg		:= 'RL05005'

	oReport	:= RptDef(cPerg)
	oReport:PrintDialog()

return
         
static function RptDef(cNome)

	local oReport	:= nil
	local oSection1	:= nil
	local oSection2	:= nil
	
	oReport	:= TReport():New(cNome,'RELATÓRIO DE INADIMPLÊNCIA POR VENDEDOR',cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO DE INADIMPLÊNCIA POR VENDEDOR')
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
	TRCell():New( 	/*<oParent> 	*/ oSection1				, /*<cName> 		*/ 'A3_NREDUZ'				, /*<cAlias> 		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ U_UX3Titulo('A3_NREDUZ')	, /*<cPicture>		*/ x3Picture('A3_NREDUZ')	, /*<nSize> 		*/ tamsx3('A3_NREDUZ')[1]	, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/							, /*<cAlign> 		*/ 'LEFT'					, ;
					/*<lLineBreak> 	*/							, /*<cHeaderAlign> 	*/ 'LEFT'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace> 	*/							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/							, /*<lBold> 		*/)

	//configurando a segunda seção
	oSection2:= TRSection():New( 	/*<oParent>			*/	oReport		, /*<cTitle>			*/	'TIPOS'			, /*<uTable>		*/	{'SE1'}	, ;
									/*<aOrder>			*/				, /*<lLoadCells>		*/	.F.				, /*<lLoadOrder>	*/	.T.		, ;
									/*<uTotalText>		*/	'Sub Total'	, /*<lTotalInLine>		*/	.F.				, /*<lHeaderPage>	*/			, ;
									/*<lHeaderBreak>	*/				, /*<lPageBreak> 		*/					, /*<lLineBreak> 	*/			, ;
									/*<nLeftMargin> 	*/	030			, /*<lLineStyle> 		*/					, /*<nColSpace> 	*/			, ;
									/*<lAutoSize> 		*/				, /*<cCharSeparator>	*/					, /*<nLinesBefore> 	*/			, ;
									/*<nCols> 			*/				, /*<nClrBack> 			*/					, /*<nClrFore> 		*/			, ;
									/*<nPercentage>		*/ )
//	oSection2:SetBorder('')
//	oSection2:SetBorder('',,,.T.)
	TRCell():New( 	/*<oParent> 	*/ oSection2				, /*<cName> 		*/ 'E1_TIPO'				, /*<cAlias>		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ U_UX3Titulo('E1_TIPO')	, /*<cPicture> 		*/ x3Picture('E1_TIPO')		, /*<nSize> 		*/ tamsx3('E1_TIPO')[1]		, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/ 							, /*<cAlign> 		*/ 'RIGHT'					, ;
					/*<lLineBreak> 	*/ .T.						, /*<cHeaderAlign> 	*/ 'CENTER'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace> 	*/ 							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/ 							, /*<lBold> 		*/)
	TRCell():New( 	/*<oParent> 	*/ oSection2				, /*<cName> 		*/ 'E1_VALOR'				, /*<cAlias> 		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ U_UX3Titulo('E1_VALOR')	, /*<cPicture> 		*/ x3Picture('E1_VALOR')	, /*<nSize> 		*/ tamsx3('E1_VALOR')[1]	, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/ 							, /*<cAlign> 		*/ 'RIGHT'					, ;
					/*<lLineBreak> 	*/ .T.						, /*<cHeaderAlign> 	*/ 'CENTER'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace>	*/ 							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/ 							, /*<lBold> 		*/)
	TRCell():New( 	/*<oParent> 	*/ oSection2				, /*<cName> 		*/ 'E1_SALDO'				, /*<cAlias> 		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ U_UX3Titulo('E1_SALDO')	, /*<cPicture> 		*/ x3Picture('E1_SALDO')	, /*<nSize> 		*/ tamsx3('E1_SALDO')[1]	, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/ 							, /*<cAlign> 		*/ 'RIGHT'					, ;
					/*<lLineBreak> 	*/ .T.						, /*<cHeaderAlign> 	*/ 'CENTER'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace> 	*/ 							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/ 							, /*<lBold> 		*/)
	TRCell():New( 	/*<oParent> 	*/ oSection2				, /*<cName> 		*/ 'DIAS'					, /*<cAlias> 		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ 'DIAS ATRASADOS'			, /*<cPicture> 		*/ '@E 9,999'				, /*<nSize> 		*/ 004						, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/ 							, /*<cAlign> 		*/ 'RIGHT'					, ;
					/*<lLineBreak> 	*/ .T.						, /*<cHeaderAlign> 	*/ 'CENTER'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace> 	*/							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/							, /*<lBold> 		*/)
	TRCell():New( 	/*<oParent> 	*/ oSection2				, /*<cName> 		*/ 'MAIORPARC'				, /*<cAlias> 		*/ 'TB1TMP'					, ;
					/*<cTitle> 		*/ 'MAIOR PARC ATRASADA'	, /*<cPicture> 		*/ x3Picture('E1_SALDO')	, /*<nSize> 		*/ tamsx3('E1_SALDO')[1]	, ;
					/*<lPixel> 		*/ .F.						, /*<bBlock> 		*/ 							, /*<cAlign> 		*/ 'RIGHT'					, ;
					/*<lLineBreak> 	*/ .T.						, /*<cHeaderAlign> 	*/ 'CENTER'					, /*<lCellBreak> 	*/							, ;
					/*<nColSpace> 	*/ 							, /*<lAutoSize> 	*/ .F.						, /*<nClrBack> 		*/							, ;
					/*<nClrFore> 	*/ 							, /*<lBold> 		*/)

	//configurando o totalizador
	TRFunction():New(	/*<oCell>		*/	oSection2:Cell('E1_SALDO')	, /*<cName>			*/	NIL				, /*<cFunction>		*/	'SUM'					, ;
						/*<oBreak>		*/								, /*<cTitle> 		*/					, /*<cPicture> 		*/	x3Picture('E1_SALDO')	, ;
						/*<uFormula>	*/								, /*<lEndSection> 	*/	.T.				, /*<lEndReport> 	*/	.T.						, ;
						/*<lEndPage> 	*/	.T.							, /*<oParent> 		*/	oSection2		, /*<bCondition> 	*/							, ;
						/*<lDisable> 	*/								, /*<bCanPrint>		*/)
	TRFunction():New(	/*<oCell>		*/	oSection2:Cell('DIAS')		, /*<cName>			*/	NIL				, /*<cFunction>		*/	'MAX'					, ;
						/*<oBreak>		*/								, /*<cTitle> 		*/					, /*<cPicture> 		*/	'E@ 9,999'				, ;
						/*<uFormula>	*/								, /*<lEndSection> 	*/	.T.				, /*<lEndReport> 	*/	.T.						, ;
						/*<lEndPage> 	*/	.T.							, /*<oParent> 		*/	oSection2		, /*<bCondition> 	*/							, ;
						/*<lDisable> 	*/								, /*<bCanPrint>		*/)
	TRFunction():New(	/*<oCell>		*/	oSection2:Cell('MAIORPARC')	, /*<cName>			*/	NIL				, /*<cFunction>		*/	'MAX'					, ;
						/*<oBreak>		*/								, /*<cTitle> 		*/					, /*<cPicture> 		*/	x3Picture('E1_SALDO')	, ;
						/*<uFormula>	*/								, /*<lEndSection> 	*/	.T.				, /*<lEndReport> 	*/	.T.						, ;
						/*<lEndPage> 	*/	.T.							, /*<oParent> 		*/	oSection2		, /*<bCondition> 	*/							, ;
						/*<lDisable> 	*/								, /*<bCanPrint>		*/)

return(oReport)


static function ReportPrint(oReport) 

	local oSection1 := oReport:Section(1)
	local oSection2 := oReport:Section(2)
	local cQuery    := ''
	local cVend		:= ''

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
		
		cVend	:= TB1TMP->A3_NREDUZ

		//imprimo a primeira seção				
		oSection1:Cell('A3_NREDUZ'):SetValue(TB1TMP->A3_NREDUZ)
		oSection1:Printline()
	
		//inicializo a segunda seção
		oSection2:init()
		
		//imprimo a segunda seção
		while TB1TMP->A3_NREDUZ == cVend
			oReport:IncMeter()

			incProc('Imprimindo vendedor '+alltrim(TB1TMP->A3_NREDUZ))
			oSection2:Cell('E1_TIPO'):SetValue(TB1TMP->E1_TIPO)
			oSection2:Cell('E1_VALOR'):SetValue(TB1TMP->E1_VALOR)
			oSection2:Cell('E1_VALOR'):SetAlign('RIGHT')
			oSection2:Cell('E1_SALDO'):SetValue(TB1TMP->E1_SALDO)
			oSection2:Cell('DIAS'):SetValue(TB1TMP->DIAS)
			oSection2:Cell('MAIORPARC'):SetValue(TB1TMP->MAIORPARC)
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


static function Query()

	local cQuery	:= ''
	
	cQuery	:='exec dbo.PR_RL05005'	

return cQuery
