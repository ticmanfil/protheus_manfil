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
Programa----------: RL16002
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 21/10/2019
===============================================================================================================================
Descrição---------: RELATORIO DE AUSENTES NO PROTHEUS 
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

user function RL16002() 

	local oReport 	:= nil
	local cPerg		:= 'RL16002'
	
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
	
	oReport	:= TReport():New(cNome,'RELATORIO DE FUNCIONÁRIOS AUSENTES',cNome,{|oReport| ReportPrint(oReport)},'RELATORIO DE FUNCIONÁRIOS AUSENTES')
	oReport:cfontbody	:= 'courier new'
	oReport:SetPortrait(.T.)	//SetLandscape
	
	oSection1:= TRSection():New(oReport, 'SRA', {'SRA'}, NIL, .F., .T. ,/*<uTotalText>*/ ,/* <lTotalInLine> */, /*<lHeaderPage> */,/* <lHeaderBreak> */, /*<lPageBreak> */, /*<lLineBreak>*/ , /*<nLeftMargin>*/ ,/* <lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 3 /*<nLinesBefore> */, /*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore> */, /*<nPercentage>*/ )
	TRCell():New(oSection1, 'DTMARCA'		, 'TB1TMP', U_UX3Titulo('P8_DATA')		, x3Picture('P8_DATA')		, tamsx3('P8_DATA')[1]+5	,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'CTT_DESC01'	, 'TB1TMP', U_UX3Titulo('CTT_DESC01')	, X3Picture('CTT_DESC01')	, tamsx3('CTT_DESC01')[1]	,.F.,/*bBlock*/,'LEFT'		,.T.,'LEFT'		,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'RA_MAT'		, 'TB1TMP', U_UX3Titulo('RA_MAT')		, x3Picture('RA_MAT')		, tamsx3('RA_MAT')[1]		,.F.,/*bBlock*/,'LEFT'		,.T.,'LEFT'		,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'RA_NOMECMP'	, 'TB1TMP', U_UX3Titulo('RA_NOMECMP')	, x3Picture('RA_NOMECMP')	, tamsx3('RA_NOMECMP')[1]	,.F.,/*bBlock*/,'LEFT'		,.T.,'LEFT'		,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'T1E'			, 'TB1TMP', 'Entrada'					, ''						, 5							,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'T1S'			, 'TB1TMP', 'Saída'						, ''						, 5							,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'T2E'			, 'TB1TMP', 'Entrada'					, ''						, 5							,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)
	TRCell():New(oSection1, 'T2S'			, 'TB1TMP', 'Saída'						, ''						, 5							,.F.,/*bBlock*/,'CENTER'	,.T.,'CENTER'	,/*lCellBreak*/,/*nColSpace*/,.F.)

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
			oSection1:Cell('DTMARCA'):SetValue(STOD(TB1TMP->DTMARCA))
			oSection1:Cell('CTT_DESC01'):SetValue(TB1TMP->CTT_DESC01)
			oSection1:Cell('RA_MAT'):SetValue(TB1TMP->RA_MAT)
			oSection1:Cell('RA_NOMECMP'):SetValue(TB1TMP->RA_NOMECMP)
			oSection1:Cell('T1E'):SetValue(TB1TMP->T1E)
			oSection1:Cell('T1S'):SetValue(TB1TMP->T1S)
			oSection1:Cell('T2E'):SetValue(TB1TMP->T2E)
			oSection1:Cell('T2S'):SetValue(TB1TMP->T2S)
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
				/*cPergunt	*/ 'Tipo Apuração:'			, /*cPerSpa		*/ 'Tipo Apuração:'			, /*cPerEng		*/ 'Tipo Apuração:'			, ;
				/*cVar		*/ 'mv_ch2'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 2						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ ''						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par02'				, ;
				/*cDef01	*/ '1E=1ª Entrada'			, /*cDefSpa1	*/ '1E=1ª Entrada'			, /*cDefEng1	*/ '1E=1ª Entrada'			, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ '1S=1ª Saída'			, /*cDefSpa2	*/ '1S=1ª Saída'			, /*cDefEng2	*/ '1S=1ª Saída'			, ; 
				/*cDef03	*/ '2E=2ª Entrada'			, /*cDefSpa3	*/ '2E=2ª Entrada'			, /*cDefEng3	*/ '2E=2ª Entrada'			, ; 
				/*cDef04	*/ '2S=2ª Saída'			, /*cDefSpa4	*/ '2S=2ª Saída'			, /*cDefEng4	*/ '2S=2ª Saída'			, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 
	
return

static function Query()

	local cQuery	:= ''
	
	local cTipo		:= ''
	
	if mv_par02 == 1
		cTipo	:= '1E'
	elseif mv_par02 == 2
		cTipo	:= '1S'
	elseif mv_par02 == 3
		cTipo	:= '2E'
	elseif mv_par02 == 4
		cTipo	:= '2S'
	endif
	
	cQuery	:='exec dbo.PR_RL16002 @DATA = "'+DTOS(mv_par01)+'", @TPMARCA = "'+cTipo+'"'	

return cQuery
