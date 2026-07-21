#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'report.ch'

/*/
===============================================================================================================================
Programa----------: RL05010
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 04/03/2020
===============================================================================================================================
Descrição---------: Este programa serve para IMPRIMIR CAPA DAS RESERVAS
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
user function RL05010() 

	local oReport 	:= nil
	local cPerg		:= 'RL05010'
	
	private	cNumNota	:= ''
	

	//Incluo/Altero as perguntas na tabela SX1
	//AjustaSX1(cPerg)

	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
/*	if Pergunte(cPerg,.T.)
		if !empty(mv_par01)
			cNumPed		:= mv_par01
		elseif !empty(mv_par02)
			cNumNota	:= mv_par02
		elseif !empty(mv_par03)
			cNumCTRL	:= mv_par03
		endif
		oReport	:= RptDef(cPerg)
		oReport:PrintDialog()
	endif
*/	

	cNumCTR	:= ADA->ADA_NUMCTR
	oReport		:= RptDef(cPerg)
	oReport:PrintDialog()

return
         
static function RptDef(cNome)

	local 	oReport		:= nil,;
			oSection1	:= nil,;
			oSection2	:= nil
			
	local	cTitulo	:= ''
	
	cTitulo	:= 'CAPA DE RESERVA DE PEDIDOS DE VENDAS - Num. Controle: '+cNumCTR
	
	oReport	:= TReport():New(cNome,cTitulo,cNome,{|oReport| ReportPrint(oReport)},cTitulo)
	oReport:cfontbody	:= 'courier new'
	oReport:SetPortrait()
	
	//configurando a primeira seção
	//TRSection():New( 	/*<oParent>	*/, /*<cTitle>*/, /*<uTable>*/, /*<aOrder>*/, /*<lLoadCells>*/, /*<lLoadOrder>*/, /*<uTotalText>, /*<lTotalInLine>*/, /*<lHeaderPage>*/, /*<lHeaderBreak>*/, /*<lPageBreak>*/, /*<lLineBreak>*/, /*<nLeftMargin>*/, /*<lLineStyle> */, /*<nColSpace>*/,	/*<lAutoSize>*/, /*<cCharSeparator>*/, /*<nLinesBefore>*/, /*<nCols>*/, /*<nClrBack>*/, /*<nClrFore>*/, /*<nPercentage>*/ )
	oSection1:= TRSection():New(oReport,'RESERVA',{'ADA'},,.F.,.T.,'Sub Total',.F.)
	//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>*/,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
	TRCell():New(oSection1,'ADA_NUMCTR'	,'TB1TMP',U_UX3Titulo('ADA_NUMCTR')	,x3Picture('ADA_NUMCTR')	,tamsx3('ADA_NUMCTR')[1]+4	,.F.,,'LEFT',,'LEFT',,,.F.,)
	TRCell():New(oSection1,'C5_NUM'		,'TB1TMP','Num. Pedido'				,x3Picture('C5_NUM')		,tamsx3('C5_NUM')[1]+4		,.F.,,'CENTER',,'CENTER',,,.F.,)
	TRCell():New(oSection1,'ADA_XNOTA'	,'TB1TMP',U_UX3Titulo('ADA_XNOTA')	,x3Picture('ADA_XNOTA')		,tamsx3('ADA_XNOTA')[1]+4	,.F.,,'CENTER',,'CENTER',,,.F.,)
	TRCell():New(oSection1,'ADA_EMISSA'	,'TB1TMP',U_UX3Titulo('ADA_EMISSA')	,x3Picture('ADA_EMISSA')	,tamsx3('ADA_EMISSA')[1]+4	,.F.,,'CENTER',,'CENTER',,,.F.,)
	TRCell():New(oSection1,'ADA_CODCLI'	,'TB1TMP',U_UX3Titulo('ADA_CODCLI')	,x3Picture('ADA_CODCLI')	,tamsx3('ADA_CODCLI')[1]+4	,.F.,,'LEFT',,'LEFT',,,.F.,)
	TRCell():New(oSection1,'ADA_LOJCLI'	,'TB1TMP',U_UX3Titulo('ADA_LOJCLI')	,x3Picture('ADA_LOJCLI')	,tamsx3('ADA_CODCLI')[1]+4	,.F.,,'LEFT',,'LEFT',,,.F.,)
	TRCell():New(oSection1,'A1_NOME'	,'TB1TMP',U_UX3Titulo('A1_NOME')	,x3Picture('A1_NOME')		,tamsx3('A1_NOME')[1]+4		,.F.,,'LEFT',,'LEFT',,,.F.,)
	TRCell():New(oSection1,'ADA_XNVEN1'	,'TB1TMP',U_UX3Titulo('ADA_XNVEN1')	,x3Picture('ADA_XNVEN1')	,tamsx3('ADA_VEND1')[1]+tamsx3('ADA_XNVEN1')[1]+4	,.F.,,'LEFT',,'LEFT',,,.F.,)
	TRCell():New(oSection1,'ADA_STATUS'	,'TB1TMP',U_UX3Titulo('ADA_STATUS')	,x3Picture('ADA_STATUS')	,tamsx3('ADA_STATUS')[1]+4	,.F.,,'CENTER',,'CENTER',,,.F.,)


	//configurando a segunda seção
	//TRSection():New( 	/*<oParent>	*/, /*<cTitle>*/, /*<uTable>*/, /*<aOrder>*/, /*<lLoadCells>*/, /*<lLoadOrder>*/, /*<uTotalText>, /*<lTotalInLine>*/, /*<lHeaderPage>*/, /*<lHeaderBreak>*/, /*<lPageBreak>*/, /*<lLineBreak>*/, /*<nLeftMargin>*/, /*<lLineStyle> */, /*<nColSpace>*/,	/*<lAutoSize>*/, /*<cCharSeparator>*/, /*<nLinesBefore>*/, /*<nCols>*/, /*<nClrBack>*/, /*<nClrFore>*/, /*<nPercentage>*/ )
	oSection2:= TRSection():New(oReport,'ITRESERVA',{'ADB'},,.F.,.T.,'Total',.F.)
//	//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>*/,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
	TRCell():New(oSection2,'ADB_ITEM'	,'TB1TMP',U_UX3Titulo('ADB_ITEM')	,x3Picture('ADB_ITEM')		,tamsx3('ADB_ITEM')[1]+4	,.F.,,'LEFT',,'LEFT',,,.F.,)
	TRCell():New(oSection2,'ADB_CODPRO'	,'TB1TMP',U_UX3Titulo('ADB_CODPRO')	,x3Picture('ADB_CODPRO')	,tamsx3('ADB_CODPRO')[1]+4	,.F.,,'LEFT',,'LEFT',,,.F.,)
	TRCell():New(oSection2,'ADB_DESPRO'	,'TB1TMP',U_UX3Titulo('ADB_DESPRO')	,x3Picture('ADB_DESPRO')	,tamsx3('ADB_DESPRO')[1]+4	,.F.,,'LEFT',,'LEFT',,,.F.,)
	TRCell():New(oSection2,'ADB_UM'		,'TB1TMP',U_UX3Titulo('ADB_UM')		,x3Picture('ADB_UM')		,tamsx3('ADB_UM')[1]+4		,.F.,,'LEFT',,'LEFT',,,.F.,)
	TRCell():New(oSection2,'ADB_QUANT'	,'TB1TMP',U_UX3Titulo('ADB_QUANT')	,x3Picture('ADB_QUANT')		,tamsx3('ADB_QUANT')[1]+4	,.F.,,'RIGTH',,'RIGTH',,,.F.,)
	//TRCell():New(oSection2,'SLDCNTR'	,'TB1TMP','Sld Contrato'			,x3Picture('ADB_QUANT')		,tamsx3('ADB_QUANT')[1]+4	,.F.,,'RIGTH',,'RIGTH',,,.F.,)

	//configurando o totalizador
	//TRFunction():New(<oCell>,<cName>,<cFunction>,<oBreak>,<cTitle>,<cPicture>,<uFormula>,<lEndSection>,<lEndReport>,<lEndPage>,<oParent>,<bCondition>,<lDisable>,<bCanPrint>)
	TRFunction():New(oSection2:Cell('ADB_ITEM'),nil,'COUNT',,,'@E 999,999',,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection2:Cell('ADB_QUANT'),nil,'SUM',,,x3Picture('ADB_QUANT'),,.T.,.T.,.T.,oSection1)

	oSection2:SetTotalInLine(.F.)
	oSection1:SetTotalInLine(.F.)
	oReport:SetTotalInLine(.F.)
	oReport:SetTotalText('Total ')

return(oReport)


static function ReportPrint(oReport) 

	local 	oSection1 	:= oReport:Section(1),;
			oSection2 	:= oReport:Section(2)
			
	local	cNFCTRL		:= ''
	
	//imprimir relatorio
		
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	if select('TB1TMP') <> 0
		dbSelectArea('TB1TMP')
		TB1TMP->(dbCloseArea())
	endif
	
	query()

	dbSelectArea('TB1TMP')
	TB1TMP->(dbGoTop())

	oReport:SetMeter(TB1TMP->(LastRec()))

	//inicializo a primeira seção
	oSection1:Init()

	//Irei percorrer todos os meus registros
	while !oReport:Cancel() .and. TB1TMP->(!Eof())
		
		//inicializo a primeira seção
		oSection1:Init()

		oReport:IncMeter()
					
		incProc('Imprimindo relatório')
		
		cNFCTRL	:= TB1TMP->XNOTA
		
		//imprimo a primeira seção				
		oSection1:Cell('ADA_NUMCTR'):SetValue(TB1TMP->ADA_NUMCTR)
		oSection1:Cell('C5_NUM'):SetValue(TB1TMP->C5_NUM)
		oSection1:Cell('ADA_XNOTA'):SetValue(TB1TMP->XNOTA)
		oSection1:Cell('ADA_EMISSA'):SetValue(TB1TMP->ADA_EMISSA)
		oSection1:Cell('ADA_CODCLI'):SetValue(TB1TMP->ADA_CODCLI)
		oSection1:Cell('ADA_LOJCLI'):SetValue(TB1TMP->ADA_LOJCLI)
		oSection1:Cell('A1_NOME'):SetValue(TB1TMP->A1_NOME)
		oSection1:Cell('ADA_XNVEN1'):SetValue(TB1TMP->ADA_XNVEN1)
		oSection1:Cell('ADA_STATUS'):SetValue(TB1TMP->ADA_STATUS)

		oSection1:Printline()

		//inicializo a primeira seção
		oSection2:Init()
		
		while TB1TMP->(!eof()) .and. cNFCTRL == TB1TMP->XNOTA 

			oSection2:Cell('ADB_ITEM'):SetValue(TB1TMP->ADB_ITEM)
			oSection2:Cell('ADB_CODPRO'):SetValue(TB1TMP->ADB_CODPRO)
			oSection2:Cell('ADB_DESPRO'):SetValue(TB1TMP->ADB_DESPRO)
			oSection2:Cell('ADB_UM'):SetValue(TB1TMP->ADB_UM)
			oSection2:Cell('ADB_QUANT'):SetValue(TB1TMP->ADB_QUANT)
			//oSection2:Cell('SLDCNTR'):SetValue(TB1TMP->SLDCNTR)
			oSection2:Printline()
	
			TB1TMP->(dbSkip())
			
		enddo
			
		//finalizo a segunda seção
		oSection2:Finish()			
	
 		//imprimo uma linha para separar uma seção da outra
 		oReport:ThinLine()
// 		oReport:FatLine()

		//finalizo a primeira seção
		oSection1:Finish()			

	enddo
	
return


static function Query()

	beginsql alias 'TB1TMP'
		column ADA_EMISSA as DATE
		select
			 ADA_NUMCTR
			,SC5.C5_NUM
			,SC5.C5_SERIE+SC5.C5_NOTA		AS XNOTA
			,ADA_EMISSA
			,ADA_CODCLI
			,ADA_LOJCLI
			,SA1.A1_NOME
			,ADA_XNVEN1
			,ADA_STATUS
			,ADB.ADB_ITEM
			,ADB.ADB_CODPRO
			,ADB.ADB_DESPRO
			,ADB.ADB_UM
			,ADB.ADB_QUANT
			,ADB.ADB_QUANT-ADB.ADB_QTDEMP	AS SLDCNTR
		
		from
			%table:ADA%	as ADA
		
			inner join %table:ADB%	as ADB
				on	ADB.%notdel%
				and ADB.ADB_FILIAL	= ADA.ADA_FILIAL
				and ADB.ADB_NUMCTR	= ADA.ADA_NUMCTR
		
			inner join %table:SC5%	as SC5
				on	SC5.%notdel%
				and SC5.C5_FILIAL	= ADB.ADB_FILIAL
				and SC5.C5_NUM		= ADB.ADB_PEDCOB

			inner join %table:SA1%	as SA1
				on	SA1.%notdel%
				and SA1.A1_COD		= ADA.ADA_CODCLI
				and SA1.A1_LOJA		= ADA.ADA_LOJCLI

		where
				ADA.%notdel%
			and ADA.ADA_NUMCTR	= %exp:cNumCTR%
				
		order by
			%order:ADB,1%
	endsql
	
return

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(cPerg,"01","Num. Ped. Princ.?" 	,"Num. Ped. Princ.?"	,"Num. Ped. Princ.?"	,"mv_ch1","C",tamsx3('C5_NUM')[1],0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"02","Num. Nota Princ.?" 	,"Num. Nota Princ.?"	,"Num. Nota Princ.?"	,"mv_ch2","C",tamsx3('C5_SERIE')[1]+tamsx3('C5_NOTA')[1],0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"03","Num. Controle?"	 	,"Num. Controle?"		,"Num. Controle?"		,"mv_ch3","C",tamsx3('ADA_NUMCTR')[1],0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","")
return
