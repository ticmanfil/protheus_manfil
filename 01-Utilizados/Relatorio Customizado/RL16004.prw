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
Programa----------: RL16004
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 20/11/2020
===============================================================================================================================
Descrição---------: RELATORIO DE INTERVALO ALMOCO NO PROTHEUS 
===============================================================================================================================
Uso---------------: SIGAPON
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: RH
===============================================================================================================================
/*/

user function RL16004() 

	local oReport 	:= nil
	local cPerg		:= 'RL16004'
	
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
	
	oReport	:= TReport():New(cNome,'RELATORIO DE FUNCIONÁRIOS INTERVALOS ALMOCO',cNome,{|oReport| ReportPrint(oReport)},'RELATORIO DE FUNCIONÁRIOS INTERVALOS ALMOCO')
	oReport:cfontbody	:= 'courier new'
	oReport:SetPortrait(.T.)	//SetLandscape
	
	oSection1:= TRSection():New(oReport, 'SRA', {'SRA'}, NIL, .F., .T. ,/*<uTotalText>*/ ,/* <lTotalInLine> */, /*<lHeaderPage> */,/* <lHeaderBreak> */, /*<lPageBreak> */, /*<lLineBreak>*/ , /*<nLeftMargin>*/ ,/* <lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 3 /*<nLinesBefore> */, /*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore> */, /*<nPercentage>*/ )
	TRCell():New(oSection1, 'MATRICULA'		, 'TB1TMP', 'MATRICULA'		, x3Picture('RA_MAT')		, tamsx3('RA_MAT')[1]+5		,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'NOME'			, 'TB1TMP', 'NOME'			, x3Picture('RA_NOME')		, tamsx3('RA_NOME')[1]		,.F.,/*bBlock*/,'LEFT'		,.T.,'LEFT'		,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'ENTRADA'		, 'TB1TMP', 'ENTRADA'		, ''						, 5							,.F.,/*bBlock*/,'LEFT'		,.T.,'LEFT'		,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'SAIDA'			, 'TB1TMP', 'SAIDA'			, ''						, 5							,.F.,/*bBlock*/,'LEFT'		,.T.,'LEFT'		,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'RETORNO'		, 'TB1TMP', 'RETORNO'		, ''						, 5							,.F.,/*bBlock*/,'LEFT'		,.T.,'LEFT'		,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'INTERVALO'		, 'TB1TMP', 'INTERVALO'		, ''						, 5							,.F.,/*bBlock*/,'LEFT'		,.T.,'LEFT'		,/*lCellBreak*/,/*nColSpace*/,.F.)

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

	//Irei percorrer todos os meus registros
	while !Eof()
		
		if oReport:Cancel()
			exit
		endif
	
		//inicializo a primeira seção
		oSection1:Init()

		oReport:IncMeter()
					
		incProc('Imprimindo relatório')
		
		//imprimo a primeira seção				
		while !TB1TMP->(eof())
			oSection1:Cell('MATRICULA'):SetValue(TB1TMP->MATRICULA)
			oSection1:Cell('NOME'):SetValue(TB1TMP->NOME)
			oSection1:Cell('ENTRADA'):SetValue(TB1TMP->ENTRADA)
			oSection1:Cell('SAIDA'):SetValue(TB1TMP->SAIDA)
			oSection1:Cell('RETORNO'):SetValue(TB1TMP->RETORNO)
			oSection1:Cell('INTERVALO'):SetValue(TB1TMP->INTERVALO)
			oSection1:Printline()
			
			TB1TMP->(dbSkip())
		enddo

		//finalizo a segunda seção
		oSection1:Finish()			
	
 		//imprimo uma linha para separar uma seção da outra
 		oReport:ThinLine()
// 		oReport:FatLine()

	enddo

return

static function ajustaSx1(cPerg)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '01'						, 											  ;
				/*cPergunt	*/ 'Data Apuracao:'			, /*cPerSpa		*/ 'Data Apuracao:'			, /*cPerEng		*/ 'Data Apuracao:'			, ;
				/*cVar		*/ 'mv_ch1'					, /*cTipo 		*/ 'D'						, 											  ;
				/*nTamanho	*/ 8						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ ''						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par01'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '02'						, 											  ;
				/*cPergunt	*/ 'Tolerância:'			, /*cPerSpa		*/ 'Tolerância:'			, /*cPerEng		*/ 'Tolerância:'			, ;
				/*cVar		*/ 'mv_ch2'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 5						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ ''						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par02'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''			 			, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 
	
return

static function Query()

	local cQuery	:= ''
	
	cQuery	:='exec dbo.PR_RL16004 @DATA = "'+DTOS(mv_par01)+'", @TOLERA = "'+mv_par02+'"'	

return cQuery
