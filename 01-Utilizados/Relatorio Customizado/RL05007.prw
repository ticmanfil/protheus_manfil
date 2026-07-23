#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'report.ch'

/*/
===============================================================================================================================
Programa----------: RL05007
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 14/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para gerar relatorio de meta x realizado
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
user function RL05007() 

	local oReport 	:= nil
	local cPerg		:= 'RL05007'
	local cTipo		:= ''

	//Incluo/Altero as perguntas na tabela SX1
	AjustaSX1(cPerg)

	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
	if Pergunte(cPerg,.T.)
		cTipo	:= mv_par02
		oReport	:= RptDef(cPerg,cTipo)
		oReport:PrintDialog()
	endif
	
return
         
static function RptDef(cNome,cTipo)

	local 	oReport		:= nil,;
			oSection1	:= nil
	
	oReport	:= TReport():New(cNome,'RELATÓRIO DE META X RELIZADO - '+cValToChar(FirstDate(mv_par01))+' a '+cValToChar(mv_par01),cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO DE META X REALIZADO - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02))
	oReport:SetLandscape()	//SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:SetTotalText('Total ')
	
	//configurando a primeira seção
	//TRSection():New( 	/*<oParent>	*/, /*<cTitle>*/, /*<uTable>*/, /*<aOrder>*/, /*<lLoadCells>*/, /*<lLoadOrder>*/, /*<uTotalText>, /*<lTotalInLine>*/, /*<lHeaderPage>*/, /*<lHeaderBreak>*/, /*<lPageBreak>*/, /*<lLineBreak>*/, /*<nLeftMargin>*/, /*<lLineStyle> */, /*<nColSpace>*/,	/*<lAutoSize>*/, /*<cCharSeparator>*/, /*<nLinesBefore>*/, /*<nCols>*/, /*<nClrBack>*/, /*<nClrFore>*/, /*<nPercentage>*/ )
	oSection1:= TRSection():New(oReport,'VENDEDORES',{'SCT'},,.F.,.T.,'Sub Total',.F.)
	//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>*/,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
	TRCell():New(oSection1,'CT_VEND'	,'TB1TMP',U_UX3Titulo('CT_VEND')	,x3Picture('CT_VEND')	,tamsx3('CT_VEND')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'A3_NOME'	,'TB1TMP',U_UX3Titulo('A3_NOME')	,x3Picture('A3_NOME')	,tamsx3('A3_NOME')[1]	,.F.,,'LEFT'	,,'LEFT',,,.F.,)
	TRCell():New(oSection1,'META'		,'TB1TMP','R$ Meta'					,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'FATURADO'	,'TB1TMP','R$ Realizado'			,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'PERMETA'	,'TB1TMP','%Meta'					,'@E 999.99'			,5						,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'PARTIC'		,'TB1TMP','%Partic.'				,'@E 999.99'			,5						,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'PFATANT'	,'TB1TMP','Tx Cresc.'				,'@E 999.99'			,5						,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'FATANT'		,'TB1TMP','R$ Real.Ano.Ant.'		,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'TICKET'		,'TB1TMP','Ticket Médio'			,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'QTDVEND'	,'TB1TMP','Qtd Venda'				,'@E 999,999'			,5						,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'BASEPROJ0'	,'TB1TMP','Base 4 anos'				,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'BASEPROJ1'	,'TB1TMP','Base 3 anos'				,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'BASEPROJ2'	,'TB1TMP','Base 2 anos'				,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'BASEPROJ3'	,'TB1TMP','Base 1 ano'				,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'INDICE'		,'TB1TMP','Indice'					,'@E 999.99'			,5						,.F.,,'RIGHT'	,,'RIGHT',,,.F.,)
	TRCell():New(oSection1,'METAPROJ'	,'TB1TMP','Meta Calculada'			,x3Picture('F2_VALBRUT'),tamsx3('F2_VALBRUT')[1],.F.,,'RIGHT'	,,'RIGHT',,,.F.,)

	//configurando o totalizador
	//TRFunction():New(<oCell>,<cName>,<cFunction>,<oBreak>,<cTitle>,<cPicture>,<uFormula>,<lEndSection>,<lEndReport>,<lEndPage>,<oParent>,<bCondition>,<lDisable>,<bCanPrint>)
	TRFunction():New(oSection1:Cell('META'),nil,'SUM',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('FATURADO'),nil,'SUM',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('PERMETA'),nil,'AVERAGE',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('PFATANT'),nil,'AVERAGE',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('FATANT'),nil,'SUM',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('TICKET'),nil,'AVERAGE',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('QTDVEND'),nil,'SUM',,,'@E 999,999',,.T.,.T.,.T.,oSection1)
	TRFunction():New(oSection1:Cell('METAPROJ'),nil,'SUM',,,x3Picture('F2_VALBRUT'),,.T.,.T.,.T.,oSection1)

return(oReport)


static function ReportPrint(oReport) 

	local 	oSection1 	:= oReport:Section(1),;
			cQuery    	:= '',;
			dIni		:= FirstDate(mv_par01),;
			dFin		:= mv_par01,;
			dIniAnt		:= FirstDate(YearSub(mv_par01,1)),;
			dFinAnt		:= YearSub(mv_par01,1),;
			aFaturado	:= {},;
			nVlFat		:= 0,;
			nPerMeta	:= 0,;
			nVlFatAnt	:= 0,;
			nPerFatAnt	:= 0,;
			nVlPartAtu	:= 0,;
			nVlPart		:= 0,;
			nIndCresc	:= 0,;
			nFatPrj0	:= 0,;
			nFatPrj1	:= 0,;
			nFatPrj2	:= 0,;
			nFatPrj3	:= 0,;
			nVlPrj		:= 0
	
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

	//busca os totais que será usado na media de participacao dos vendedores no Mes Atual
	nVlPartAtu	:= 0
	while !TB1TMP->(eof())
		aFaturado	:= {}
		aFaturado	:= FVendas(TB1TMP->CT_VEND,dIni,dFin)
		nVlPartAtu	+= aFaturado[5]

		TB1TMP->(dbSkip())
	enddo

	dbSelectArea('TB1TMP')
	TB1TMP->(dbGoTop())

	oReport:SetMeter(TB1TMP->(LastRec()))

	//inicializo a primeira seção
	oSection1:Init()

	//Irei percorrer todos os meus registros
	while !oReport:Cancel() .and. TB1TMP->(!Eof())
		
		oReport:IncMeter()
					
		incProc('Imprimindo relatório')
		
		//busca dados dos realizados
		aFaturado	:= {}
		aFaturado	:= FVendas(TB1TMP->CT_VEND,dIni,dFin)
		nVlFat		:= aFaturado[5]
		nPerMeta	:= ((nVlFat/TB1TMP->CT_VALOR)-1)*100
		nVlPart		:= (nVlFat/nVlPartAtu)*100
		
		//busca dados dos realizados periodo anterior
		aFaturado	:= {}
		aFaturado	:= FVendas(TB1TMP->CT_VEND,dIniAnt,dFinAnt)
		nVlFatAnt	:= aFaturado[5]
		nPerFatAnt	:= ((nVlFat/nVlFatAnt)*100)-100

		//Projetando meta proximo mes
		nIndCresc	:= FPrvMet(TB1TMP->CT_VEND)
		nFatPrj0	:= FFatAnt(TB1TMP->CT_VEND,FirstDate(yearSub(monthSum(mv_par01,1),4)),LastDate(yearSub(monthSum(mv_par01,1),4)))
		nFatPrj1	:= FFatAnt(TB1TMP->CT_VEND,FirstDate(yearSub(monthSum(mv_par01,1),1)),LastDate(yearSub(monthSum(mv_par01,1),1)))
		nFatPrj2	:= FFatAnt(TB1TMP->CT_VEND,FirstDate(yearSub(monthSum(mv_par01,1),2)),LastDate(yearSub(monthSum(mv_par01,1),2)))
		nFatPrj3	:= FFatAnt(TB1TMP->CT_VEND,FirstDate(yearSub(monthSum(mv_par01,1),3)),LastDate(yearSub(monthSum(mv_par01,1),3)))
		nVlPrj		:= (nFatPrj1*(1+nIndCresc))
		if nVlPrj = 0
			nVlPrj	:= nVlFat
		endif
		
		//imprimo a primeira seção				
		oSection1:Cell('CT_VEND'):SetValue(TB1TMP->CT_VEND)
		oSection1:Cell('A3_NOME'):SetValue(TB1TMP->A3_NOME)
		oSection1:Cell('META'):SetValue(TB1TMP->CT_VALOR)
		oSection1:Cell('FATURADO'):SetValue(nVlFat)
		oSection1:Cell('PERMETA'):SetValue(nPerMeta)
		oSection1:Cell('PARTIC'):SetValue(nVlPart)
		oSection1:Cell('PFATANT'):SetValue(nPerFatAnt)
		oSection1:Cell('FATANT'):SetValue(nVlFatAnt)
		oSection1:Cell('TICKET'):SetValue(TB1TMP->TICKET)
		oSection1:Cell('QTDVEND'):SetValue(TB1TMP->QTD)
		oSection1:Cell('BASEPROJ0'):SetValue(nFatPrj0)
		oSection1:Cell('BASEPROJ1'):SetValue(nFatPrj3)
		oSection1:Cell('BASEPROJ2'):SetValue(nFatPrj2)
		oSection1:Cell('BASEPROJ3'):SetValue(nFatPrj1)
		oSection1:Cell('INDICE'):SetValue(nIndCresc*100)
		oSection1:Cell('METAPROJ'):SetValue(round(nVlPrj,0))
		
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
	
	cQuery	:='exec dbo.PR_RL05007A @FILIAL	= "'+xFilial('SCT')+'", @DTINI = "'+DTOS(FirstDate(mv_par01))+'", @DTFIN = "'+DTOS(LastDate(mv_par01))+'"'	

return cQuery

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(cPerg,"01","Data Base ?" ,"Data Base ?"     ,"Data Base ?"       ,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	U_XPUTSX1(cPerg,"02","Tipo?"	   ,"Tipo?"           ,"Tipo?"             ,"mv_ch2","N",14,2,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")

return


static function FPrvMet(cVend)

	local	nVal01		:= 0,;
			nVal02		:= 0,;
			nTxCres01	:= 0,;
			nTxCres02	:= 0,;
			nTxCres03	:= 0,;
			nQtdMes		:= 0,;
			nPrvMet		:= 0

	//Buscando os faturamentos liquidos dos meses periodos anteriores
	//Faturado 1 ano atras referente no proximo mes
	nVal01		:= FFatAnt(cVend,FirstDate(yearSub(monthSum(mv_par01,1),1)),LastDate(yearSub(monthSum(mv_par01,1),1)))

	//Faturado 2 anos atras
	nVal02		:= FFatAnt(cVend,FirstDate(yearSub(monthSum(mv_par01,1),2)),LastDate(yearSub(monthSum(mv_par01,1),2)))
	nTxCres01	:= (nVal01-nVal02)/nVal02
	if	nVal02 > 0
		nQtdMes++
	endif

	//Faturando 3 anos atras referente no proximo mes
	nVal01		:= nVal02
	nVal02		:= FFatAnt(cVend,FirstDate(yearSub(monthSum(mv_par01,1),3)),LastDate(yearSub(monthSum(mv_par01,1),3)))
	nTxCres02	:= (nVal01-nVal02)/nVal02
	if	nVal02 > 0
		nQtdMes++
	endif

	//Faturando 4 anos atras referente no proximo mes
	nVal01		:= nVal02
	nVal02		:= FFatAnt(cVend,FirstDate(yearSub(monthSum(mv_par01,1),4)),LastDate(yearSub(monthSum(mv_par01,1),4)))
	nTxCres03	:= (nVal01-nVal02)/nVal02
	if	nVal02 > 0
		nQtdMes++
	endif
	
	nPrvMet		:= (nTxCres01+nTxCres02+nTxCres03)/nQtdMes
	
//	nPrvMet		:= nValAnt * (1+nPrvMet)

return nPrvMet

static function FFatAnt(cVend, dDtIni, dDtFin)
	local	nFat		:= 0
	
	local	aFaturado	:= {}

	if dtos(dDtIni) >= '20150101' .and. dtos(dDtFin) <= '20150131'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 340903.41
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 93391.83
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 141618.86
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 94893.55
		endif 

	elseif dtos(dDtIni) >= '20150201' .and. dtos(dDtFin) <= '20150228'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 251310.89
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 124047.30
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 146279.39
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 103543.96
		endif 

	elseif dtos(dDtIni) >= '20150301' .and. dtos(dDtFin) <= '20150331'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 246968.63
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 129026.75
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 72573.97
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 94897.57
		endif 

	elseif dtos(dDtIni) >= '20150401' .and. dtos(dDtFin) <= '20150430'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 414333.38
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 168951.36
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 174943.24
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 148120.99
		endif 

	elseif dtos(dDtIni) >= '20150501' .and. dtos(dDtFin) <= '20150531'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 355745.64
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 178493.25
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 124037.66
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 100825.94
		endif 

	elseif dtos(dDtIni) >= '20150601' .and. dtos(dDtFin) <= '20150630'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 589301.28
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 155305.97
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 48317.54
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 180420.53
		endif 

	elseif dtos(dDtIni) >= '20150701' .and. dtos(dDtFin) <= '20150731'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 430050.79
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 182349.36
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 0
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 161137.88 
		endif 

	elseif dtos(dDtIni) >= '20150801' .and. dtos(dDtFin) <= '20150831'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 418289.30
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 213768.91
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 0
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 205965.69 
		endif 

	elseif dtos(dDtIni) >= '20150901' .and. dtos(dDtFin) <= '20150930'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 279620.69
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 227828.14
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 0
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 160354.25 
		endif 

	elseif dtos(dDtIni) >= '20151001' .and. dtos(dDtFin) <= '20151031'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 379352.06
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 217402.58
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 0
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 193073.86 
		endif 

	elseif dtos(dDtIni) >= '20151101' .and. dtos(dDtFin) <= '20151130'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 491052.99
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 169445.35
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 88297.22
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 171437.25
		endif 

	elseif dtos(dDtIni) >= '20151201' .and. dtos(dDtFin) <= '20151231'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 554566.55
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 164417.60
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 161031.58
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 160485.39
		endif 

	elseif dtos(dDtIni) >= '20160101' .and. dtos(dDtFin) <= '20160131'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 332938.78
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 145985.34
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 142970.56
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 0
		endif 

	elseif dtos(dDtIni) >= '20160201' .and. dtos(dDtFin) <= '20160229'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 379197.74
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 0
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 216345.97   
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 177169.10
		endif 

	elseif dtos(dDtIni) >= '20160301' .and. dtos(dDtFin) <= '20160331'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 409317.26
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 106152.63
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 162392.99
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 188133.44
		endif 

	elseif dtos(dDtIni) >= '20160401' .and. dtos(dDtFin) <= '20160430'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 277924.13
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 130239.71
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 250609.83
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 155982.40
		endif 

	elseif dtos(dDtIni) >= '20160501' .and. dtos(dDtFin) <= '20160531'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 380098.44
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 205644.84
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 226211.23
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 225626.41
		endif 

	elseif dtos(dDtIni) >= '20160601' .and. dtos(dDtFin) <= '20160630'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 381186.55
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 237486.24
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 208010.20
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 177784.55
		endif 

	elseif dtos(dDtIni) >= '20160701' .and. dtos(dDtFin) <= '20160731'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 668398.93
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 320618.01
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 221919.52
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 206771.06
		endif 

	elseif dtos(dDtIni) >= '20160801' .and. dtos(dDtFin) <= '20160831'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 386152.55
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 203258.78
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 256520.42
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 266716.14
		endif 

	elseif dtos(dDtIni) >= '20160901' .and. dtos(dDtFin) <= '20160930'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 377839.68
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 169792.28
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 201123.15
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 228823.30
		endif 

	elseif dtos(dDtIni) >= '20161001' .and. dtos(dDtFin) <= '20161031'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 402661.61
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 0
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 223911.54   
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 250278.31
		endif 

	elseif dtos(dDtIni) >= '20161101' .and. dtos(dDtFin) <= '20161130'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 214643.07
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 112551.94
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 149542.75
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 167801.72
		endif 

	elseif dtos(dDtIni) >= '20161201' .and. dtos(dDtFin) <= '20161231'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 382305.75
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 174283.97
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 280601.94
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 0
		endif 

	elseif dtos(dDtIni) >= '20170101' .and. dtos(dDtFin) <= '20170131'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 365405.69
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 287764.28 
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 0   
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 207264.80 
		endif 

	elseif dtos(dDtIni) >= '20170201' .and. dtos(dDtFin) <= '20170228'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 277340.35
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 182545.46 
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 136360.86   
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 200009.43 
		endif 

	elseif dtos(dDtIni) >= '20170301' .and. dtos(dDtFin) <= '20170331'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 463090.82
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 230226.16 
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 216944.49   
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 265349.51 
		endif 

	elseif dtos(dDtIni) >= '20170401' .and. dtos(dDtFin) <= '20170430'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 258200.52
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 195556.93 
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 195629.33   
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 283918.64 
		endif 

	elseif dtos(dDtIni) >= '20170501' .and. dtos(dDtFin) <= '20170531'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 432177.66
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 262733.96 
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 194601.47   
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 251159.17 
		elseif alltrim(cVend) == '4'		//CRISTIANO
			nFat	:= 36900.15
		endif 

	elseif dtos(dDtIni) >= '20170601' .and. dtos(dDtFin) <= '20170630'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 362833.75
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 179331.38 
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 192451.28
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 308625.91 
		elseif alltrim(cVend) == '4'		//CRISTIANO
			nFat	:= 81791.98
		endif 

	elseif dtos(dDtIni) >= '20170701' .and. dtos(dDtFin) <= '20170731'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 236688.18
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 181109.38 
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 147891.34
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 270424.94 
		elseif alltrim(cVend) == '4'		//CRISTIANO
			nFat	:= 43865.98
		elseif alltrim(cVend) == '14'		//ANDREZA
			nFat	:= 10164.48
		endif 

	elseif dtos(dDtIni) >= '20170801' .and. dtos(dDtFin) <= '20170831'
		if alltrim(cVend) == '2'			//LEANDRO
			nFat	:= 259491.83
		elseif alltrim(cVend) == '6'		//RODRIGO
			nFat	:= 216917.03 
		elseif alltrim(cVend) == '13'		//POLYANE
			nFat	:= 168897.86
		elseif alltrim(cVend) == '5'		//JOYCE
			nFat	:= 295110 
		elseif alltrim(cVend) == '4'		//CRISTIANO
			nFat	:= 79323.11
		elseif alltrim(cVend) == '14'		//ANDREZA
			nFat	:= 35111.97
		endif 

	else
		aFaturado	:= {}
		aFaturado	:= FVendas(cVend,dDtIni,dDtFin)
		nFat		:= aFaturado[5]
	endif
	
	if nFat < 0
		nFat	:= 0
	endif

return nFat

static function FVendas(cVend,dDtIni, dDtFin)

	local	aFat	:= {}

	local cQuery	:= ''
	
	cQuery	:='exec dbo.PR_RL05007B @VEND = "'+cVend+'", @DTINI = "'+DTOS(dDtIni)+'", @DTFIM = "'+DTOS(dDtFin)+'"'	
	
	
	if select('TB2TMP') <> 0
		dbSelectArea('TB2TMP')
		TB2TMP->(dbCloseArea())
	endif

	//crio o novo alias
	TCQUERY cQuery NEW ALIAS 'TB2TMP'
	
	dbSelectArea('TB2TMP')
	TB2TMP->(dbGoTop())

	if !TB2TMP->(eof())
		while !TB2TMP->(eof())

			aadd(aFat,TB2TMP->A3_COD)
			aadd(aFat,TB2TMP->A3_NOME)
			aadd(aFat,TB2TMP->VENDA)
			aadd(aFat,TB2TMP->DEVOL)
			aadd(aFat,TB2TMP->VLLIQ)

			TB2TMP->(dbSkip())
		enddo
	else
		aFat	:= {'','',0,0,0}
	endif

	if select('TB2TMP') <> 0
		dbSelectArea('TB2TMP')
		TB2TMP->(dbCloseArea())
	endif

return aFat
