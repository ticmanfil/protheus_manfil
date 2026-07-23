#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'report.ch'

/*/
===============================================================================================================================
Programa----------: RL06009
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 15/02/2024
===============================================================================================================================
Descrição---------: Este programa serve para gerar os relatorios da consultoria Silvo Goncalves
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
user function RL06009() 
	local oDlg  := Nil
	
	local 	bConfirm,;
			bSair

	private	nTpRel,;
			aItems:= {}
	
/*	private lChk as logical,;
			lChkCR as logical,;
			lChkCP as logical	*/

	//bConfirm:= {|| MsgInfo('Insira seu processamento aqui','Processando')}
	bConfirm:= {|| RL06009_PR ()}
	bSair:= {|| Iif(MsgYesNo( 'Você tem certeza que deseja sair da rotina? ','Sair da rotina'),(oDialog:DeActivate()),NIL)}

    oDlg:=FwDialogModal():New()       
    oDlg:SetEscClose(.T.)
    oDlg:SetTitle('[RL06009] - Relatório Cons. Silvio Gonçalves')

    //Seta a largura e altura da janela em pixel
    oDlg:SetPos(000, 000)
    oDlg:SetSize(150, 250)

    oDlg:CreateDialog()
	oDlg:AddButton('Confirmar',bConfirm, 'Confirmar',,.T.,.F.,.T.,)
    oDlg:AddCloseButton(Nil, 'Fechar')

	oPanel := oDlg:GetPanelMain()

//	oCheck1 := TCheckBox():New(02,01,"Receitas" ,{||lChk},oPanel,180,210,,,,{||lChkCR := .T.},,,,.T.,,,)
//	oCheck2 := TCheckBox():New(13,01,"Despesas" ,{||lChk},oPanel,180,210,,,,{||lChkCP := .T.},,,,.T.,,,)

	nTpRel := 1
	aItems := {'1-Receitas (A)','2-Despesas (B)','3-Custos (C) - Somente EXCEL','4-Inadimplência (D)','5-Peso (E) - Somente EXCEL'}
	oRadio := TRadMenu():New (01,01,aItems,,oPanel,,,,,,,,100,12,,,,.T.)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nTpRel,nTpRel:=u)}

    oDlg:Activate()
	
return

static function RL06009_PR()
	
	local oReport 	:= nil

	local cPerg		:= ''

	if nTpRel = 1	//RECEITAS
		cPerg		:= 'RL06009A'
	elseif nTpRel = 2	//DEPESAS
		cPerg		:= 'RL06009B'
	elseif nTpRel = 3	//CUSTOS
		cPerg		:= 'RL06009C'
	elseif nTpRel = 4	//INADIMPLENCIA
		cPerg		:= 'RL06009D'
	elseif nTpRel = 5	//PESO
		cPerg		:= 'RL06009E'
	endif

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
	local cNArq:= ''
	
	if nTpRel = 1	//RECEITAS

		cNArq:= 'Receitas '+dtos(mv_par01)+' a '+dtos(mv_par02)
		oReport	:= TReport():New(cNArq,'['+cNome+'] - RELATÓRIO RECEITAS - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02),cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO RECEITAS - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02))
		oReport:cfontbody	:= 'courier new'
		oReport:SetLandscape()	//SetPortrait()
		oReport:SetTotalInLine(.F.)
		oReport:SetTotalText('Total ')
		
		//configurando a primeira seção
	//	oSection1:= TRSection():New(/*<oParent>*/,/*<cTitle>*/,/*<uTable>*/,/*<aOrder>*/,/*<lLoadCells>*/,/*<lLoadOrder>*/,/*<uTotalText>*/,/*<lTotalInLine>*/,/*<lHeaderPage>*/,/*<lHeaderBreak>*/,/*<lPageBreak>*/,/*<lLineBreak>*/,/*<nLeftMargin>*/,/*<lLineStyle>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<cCharSeparator>*/,/*<nLinesBefore>*/,/*<nCols>*/,/*<nClrBack>*/,/*<nClrFore>*/,	/*<nPercentage>	*/ )
		oSection1:= TRSection():New(oReport,'RECEITAS',{'SE1'},,.F.,.T.,'Sub Total',.F.)

		//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
		TRCell():New(oSection1,'NATUREZA','TB1TMP',U_UX3Titulo('ED_DESCRIC'),x3Picture('ED_DESCRIC'),tamsx3('ED_CODIGO')[1]+tamsx3('ED_DESCRIC')[1]+3,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'TITULO','TB1TMP',U_UX3Titulo('E1_NUM'),x3Picture('E1_NUM'),tamsx3('E1_PREFIXO')[1]+tamsx3('E1_NUM')[1]+tamsx3('E1_PARCELA')[1]+tamsx3('E1_TIPO')[1]+tamsx3('E1_CLIENTE')[1]+tamsx3('E1_LOJA')[1],.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'EMISSAO','TB1TMP',U_UX3Titulo('E1_EMISSAO'),x3Picture('E1_EMISSAO'),tamsx3('E1_EMISSAO')[1],.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'VENCTO','TB1TMP',U_UX3Titulo('E1_VENCTO'),x3Picture('E1_VENCTO'),tamsx3('E1_VENCTO')[1],.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'VALOR','TB1TMP',U_UX3Titulo('E1_VALOR'),x3Picture('E1_VALOR'),tamsx3('E1_VALOR')[1],.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'VALOR_RECEBIDO','TB1TMP',U_UX3Titulo('E1_VALLIQ'),x3Picture('E1_VALLIQ'),tamsx3('E1_VALLIQ')[1],.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'SALDO','TB1TMP',U_UX3Titulo('E1_SALDO'),x3Picture('E1_SALDO'),tamsx3('E1_SALDO')[1],.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'STATUS','TB1TMP',U_UX3Titulo('E1_STATUS'),x3Picture('E1_STATUS'),tamsx3('E1_STATUS')[1],.F.,,'LEFT',,'LEFT',,,.T.)
		TRCell():New(oSection1,'CODSUP','TB1TMP',U_UX3Titulo('ED_DESCRIC'),x3Picture('ED_DESCRIC'),tamsx3('ED_CODIGO')[1]+tamsx3('ED_DESCRIC')[1]+3,.F.,,'LEFT',,'LEFT',,,.T.)
		TRCell():New(oSection1,'EMPGRUPO','TB1TMP',U_UX3Titulo('A1_XGRUPO'),,3,.F.,,'LEFT',,'LEFT',,,.T.)

		//configurando o totalizador
		//TRFunction():New(/*<oCell>*/,/*<cName>*/,/*<cFunction>*/,/*<oBreak>*/,/*<cTitle>*/,/*<cPicture>*/,/*<uFormula>*/,/*<lEndSection>*/,/*<lEndReport>*/,/*<lEndPage>*/,/*<oParent>*/,/*<bCondition>*/,/*<lDisable>*/,/*<bCanPrint>*/)
		TRFunction():New(oSection1:Cell('VALOR'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_VALOR'),,.T.,.T.,.T.,oSection1)
		TRFunction():New(oSection1:Cell('VALOR_RECEBIDO'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_VALLIQ'),,.T.,.T.,.T.,oSection1)
		TRFunction():New(oSection1:Cell('SALDO'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_SALDO'),,.T.,.T.,.T.,oSection1)

	elseif nTpRel = 2	//DEPESAS

		cNArq:= 'Despesas '+dtos(mv_par01)+' a '+dtos(mv_par02)
		oReport	:= TReport():New(cNArq,'['+cNome+'] - RELATÓRIO DESPESAS - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02),cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO DESPESAS - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02))
		oReport:cfontbody	:= 'courier new'
		oReport:SetLandscape()	//SetPortrait()
		oReport:SetTotalInLine(.F.)
		oReport:SetTotalText('Total ')
		
		//configurando a primeira seção
	//	oSection1:= TRSection():New(/*<oParent>*/,/*<cTitle>*/,/*<uTable>*/,/*<aOrder>*/,/*<lLoadCells>*/,/*<lLoadOrder>*/,/*<uTotalText>*/,/*<lTotalInLine>*/,/*<lHeaderPage>*/,/*<lHeaderBreak>*/,/*<lPageBreak>*/,/*<lLineBreak>*/,/*<nLeftMargin>*/,/*<lLineStyle>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<cCharSeparator>*/,/*<nLinesBefore>*/,/*<nCols>*/,/*<nClrBack>*/,/*<nClrFore>*/,	/*<nPercentage>	*/ )
		oSection1:= TRSection():New(oReport,'DESPESAS',{'SE1'},,.F.,.T.,'Sub Total',.F.)

		//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
		TRCell():New(oSection1,'NATUREZA','TB1TMP',U_UX3Titulo('ED_DESCRIC'),x3Picture('ED_DESCRIC'),tamsx3('ED_CODIGO')[1]+tamsx3('ED_DESCRIC')[1]+3,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'TITULO','TB1TMP',U_UX3Titulo('E5_NUMERO'),x3Picture('E5_NUMERO'),tamsx3('E5_PREFIXO')[1]+tamsx3('E5_NUMERO')[1]+tamsx3('E5_PARCELA')[1]+tamsx3('E5_TIPO')[1]+tamsx3('E5_CLIFOR')[1]+tamsx3('E5_LOJA')[1],.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'FORNECEDOR','TB1TMP',U_UX3Titulo('A2_NREDUZ'),x3Picture('A2_NREDUZ'),tamsx3('A2_COD')[1]+tamsx3('A2_LOJA')[1]+tamsx3('A2_NREDUZ')[1]+3,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'DATA','TB1TMP',U_UX3Titulo('E5_DTDISPO'),x3Picture('E5_DTDISPO'),tamsx3('E5_DTDISPO')[1],.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'VALOR','TB1TMP',U_UX3Titulo('E5_VALOR'),x3Picture('E5_VALOR'),tamsx3('E5_VALOR')[1],.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'DESCRICAO','TB1TMP',U_UX3Titulo('E5_HISTOR'),x3Picture('E5_HISTOR'),tamsx3('E5_HISTOR')[1],.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'CAIXA','TB1TMP',U_UX3Titulo('E5_CONTA'),x3Picture('E5_CONTA'),tamsx3('E5_BANCO')[1]+tamsx3('E5_AGENCIA')[1]+tamsx3('E5_CONTA')[1]+3,.F.,,'LEFT',,'LEFT',,,.T.)
		TRCell():New(oSection1,'TIPOCCUSTO','TB1TMP',U_UX3Titulo('Z0A_DESC'),,tamsx3('Z0A_DESC')[1]+9,.F.,,'LEFT',,'LEFT',,,.T.)

		//configurando o totalizador
		//TRFunction():New(/*<oCell>*/,/*<cName>*/,/*<cFunction>*/,/*<oBreak>*/,/*<cTitle>*/,/*<cPicture>*/,/*<uFormula>*/,/*<lEndSection>*/,/*<lEndReport>*/,/*<lEndPage>*/,/*<oParent>*/,/*<bCondition>*/,/*<lDisable>*/,/*<bCanPrint>*/)
		TRFunction():New(oSection1:Cell('VALOR'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E5_VALOR'),,.T.,.T.,.T.,oSection1)

	elseif nTpRel = 3	//CUSTOS

		cNArq:= 'Custo '+dtos(mv_par01)+' a '+dtos(mv_par02)
		oReport	:= TReport():New(cNArq,'['+cNome+'] - RELATÓRIO FATURAMENTO POR CUSTOS - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02),cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO FATURAMENTO POR CUSTOS - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02))
		oReport:cfontbody	:= 'courier new'
		oReport:SetLandscape()	//SetPortrait()
		oReport:SetTotalInLine(.F.)
		oReport:SetTotalText('Total ')
		
		//configurando a primeira seção
	//	oSection1:= TRSection():New(/*<oParent>*/,/*<cTitle>*/,/*<uTable>*/,/*<aOrder>*/,/*<lLoadCells>*/,/*<lLoadOrder>*/,/*<uTotalText>*/,/*<lTotalInLine>*/,/*<lHeaderPage>*/,/*<lHeaderBreak>*/,/*<lPageBreak>*/,/*<lLineBreak>*/,/*<nLeftMargin>*/,/*<lLineStyle>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<cCharSeparator>*/,/*<nLinesBefore>*/,/*<nCols>*/,/*<nClrBack>*/,/*<nClrFore>*/,	/*<nPercentage>	*/ )
		oSection1:= TRSection():New(oReport,'FATURAMENTO POR CUSTOS',{'SE1'},,.F.,.T.,'Sub Total',.F.)

		//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
		TRCell():New(oSection1,'TIPO','TB1TMP','DTEMISSAO',,5,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'DTEMISSAO','TB1TMP','DTEMISSAO',,10,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'CONDPGTO','TB1TMP','CONDPGTO',,47,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'PRODUTO','TB1TMP','PRODUTO',,76,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'QTVEN','TB1TMP','QTVEN','@E 999,999,999.999999',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'PRUNIT','TB1TMP','PRUNIT','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'VLTOTAL','TB1TMP','VLTOTAL','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'PDESC','TB1TMP','PDESC','@E 99.99',5,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'DESC','TB1TMP','DESC','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'VLVENDA','TB1TMP','VLVENDA','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'CUSTO','TB1TMP','CUSTO','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'CODVEN','TB1TMP','CODVEN',,6,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'XVENDEDOR','TB1TMP','XVENDEDOR',,30,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'FRETE','TB1TMP','FRETE','@E 9,999,999,999,999.99',16,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'FRETERAT','TB1TMP','FRETE RAT','@E 9,999,999,999,999.99',16,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'GRUPO','TB1TMP','GRUPO',,40,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'TPVEND','TB1TMP','TPVEND',,10,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'REGIAO','TB1TMP','REGIAO',,10,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'EQUIPE','TB1TMP','EQUIPE',,10,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'META','TB1TMP','META','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'MPRAZO','TB1TMP','MPRAZO',,3,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'ULTVEND','TB1TMP','ULTVEND',,60,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'RENT_BRUTO','TB1TMP','RENT_BRUTO','@E 9,999,999,999,999.99',16,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'TIPOPROD','TB1TMP','TIPOPROD',,1,.F.,,'LEFT',,'LEFT',,,.F.)

		//configurando o totalizador
		//TRFunction():New(/*<oCell>*/,/*<cName>*/,/*<cFunction>*/,/*<oBreak>*/,/*<cTitle>*/,/*<cPicture>*/,/*<uFormula>*/,/*<lEndSection>*/,/*<lEndReport>*/,/*<lEndPage>*/,/*<oParent>*/,/*<bCondition>*/,/*<lDisable>*/,/*<bCanPrint>*/)
		TRFunction():New(oSection1:Cell('VLTOTAL'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_VALOR'),,.T.,.T.,.T.,oSection1)
		TRFunction():New(oSection1:Cell('CUSTO'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_VALLIQ'),,.T.,.T.,.T.,oSection1)
		TRFunction():New(oSection1:Cell('RENT_BRUTO'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_SALDO'),,.T.,.T.,.T.,oSection1)

	elseif nTpRel = 4	//INADIMPLENCIA

		cNArq:= 'Inadimplencia '+dtos(mv_par01)
		oReport	:= TReport():New(cNArq,'['+cNome+'] - RELATÓRIO INADIMPLENCIA - '+cValToChar(mv_par01),cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO INADIMPLENCIA - '+cValToChar(mv_par01))
		oReport:cfontbody	:= 'courier new'
		oReport:SetLandscape()	//SetPortrait()
		oReport:SetTotalInLine(.F.)
		oReport:SetTotalText('Total ')
		
		//configurando a primeira seção
	//	oSection1:= TRSection():New(/*<oParent>*/,/*<cTitle>*/,/*<uTable>*/,/*<aOrder>*/,/*<lLoadCells>*/,/*<lLoadOrder>*/,/*<uTotalText>*/,/*<lTotalInLine>*/,/*<lHeaderPage>*/,/*<lHeaderBreak>*/,/*<lPageBreak>*/,/*<lLineBreak>*/,/*<nLeftMargin>*/,/*<lLineStyle>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<cCharSeparator>*/,/*<nLinesBefore>*/,/*<nCols>*/,/*<nClrBack>*/,/*<nClrFore>*/,	/*<nPercentage>	*/ )
		oSection1:= TRSection():New(oReport,'INADIMPLENCIA',{'SE1'},,.F.,.T.,'Sub Total',.F.)

		//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
		TRCell():New(oSection1,'NATUREZA','TB1TMP',U_UX3Titulo('ED_DESCRIC'),x3Picture('ED_DESCRIC'),tamsx3('ED_CODIGO')[1]+tamsx3('ED_DESCRIC')[1]+3,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'TIPO','TB1TMP',U_UX3Titulo('E1_TIPO'),x3Picture('E1_TIPO'),tamsx3('E1_TIPO')[1],.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'TITULO','TB1TMP',U_UX3Titulo('E1_NUM'),x3Picture('E1_NUM'),tamsx3('E1_PREFIXO')[1]+tamsx3('E1_NUM')[1]+tamsx3('E1_PARCELA')[1]+tamsx3('E1_TIPO')[1]+tamsx3('E1_CLIENTE')[1]+tamsx3('E1_LOJA')[1],.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'EMISSAO','TB1TMP',U_UX3Titulo('E1_EMISSAO'),x3Picture('E1_EMISSAO'),tamsx3('E1_EMISSAO')[1],.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'VENCTO','TB1TMP',U_UX3Titulo('E1_VENCTO'),x3Picture('E1_VENCTO'),tamsx3('E1_VENCTO')[1],.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'VALOR','TB1TMP',U_UX3Titulo('E1_VALOR'),x3Picture('E1_VALOR'),tamsx3('E1_VALOR')[1],.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'VALOR_RECEBIDO','TB1TMP',U_UX3Titulo('E1_VALLIQ'),x3Picture('E1_VALLIQ'),tamsx3('E1_VALLIQ')[1],.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'SALDO','TB1TMP',U_UX3Titulo('E1_SALDO'),x3Picture('E1_SALDO'),tamsx3('E1_SALDO')[1],.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'STATUS','TB1TMP',U_UX3Titulo('E1_STATUS'),x3Picture('E1_STATUS'),tamsx3('E1_STATUS')[1],.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'DTBAIXA','TB1TMP',U_UX3Titulo('E1_BAIXA'),x3Picture('E1_BAIXA'),tamsx3('E1_BAIXA')[1],.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'CODSUP','TB1TMP',U_UX3Titulo('ED_DESCRIC'),x3Picture('ED_DESCRIC'),tamsx3('ED_CODIGO')[1]+tamsx3('ED_DESCRIC')[1]+3,.F.,,'LEFT',,'LEFT',,,.T.)
		TRCell():New(oSection1,'EMPGRUPO','TB1TMP',U_UX3Titulo('A1_XGRUPO'),,3,.F.,,'LEFT',,'LEFT',,,.T.)

		//configurando o totalizador
		//TRFunction():New(/*<oCell>*/,/*<cName>*/,/*<cFunction>*/,/*<oBreak>*/,/*<cTitle>*/,/*<cPicture>*/,/*<uFormula>*/,/*<lEndSection>*/,/*<lEndReport>*/,/*<lEndPage>*/,/*<oParent>*/,/*<bCondition>*/,/*<lDisable>*/,/*<bCanPrint>*/)
		TRFunction():New(oSection1:Cell('VALOR'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_VALOR'),,.T.,.T.,.T.,oSection1)
		TRFunction():New(oSection1:Cell('VALOR_RECEBIDO'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_VALLIQ'),,.T.,.T.,.T.,oSection1)
		TRFunction():New(oSection1:Cell('SALDO'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_SALDO'),,.T.,.T.,.T.,oSection1)

	elseif nTpRel = 5	//PESO

		cNArq:= 'Peso '+dtos(mv_par01)+' a '+dtos(mv_par02)
		oReport	:= TReport():New(cNArq,'['+cNome+'] - RELATÓRIO FATURAMENTO POR PESO - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02),cNome,{|oReport| ReportPrint(oReport)},'RELATÓRIO FATURAMENTO PESO - '+cValToChar(mv_par01)+' a '+cValToChar(mv_par02))
		oReport:cfontbody	:= 'courier new'
		oReport:SetLandscape()	//SetPortrait()
		oReport:SetTotalInLine(.F.)
		oReport:SetTotalText('Total ')
		
		//configurando a primeira seção
	//	oSection1:= TRSection():New(/*<oParent>*/,/*<cTitle>*/,/*<uTable>*/,/*<aOrder>*/,/*<lLoadCells>*/,/*<lLoadOrder>*/,/*<uTotalText>*/,/*<lTotalInLine>*/,/*<lHeaderPage>*/,/*<lHeaderBreak>*/,/*<lPageBreak>*/,/*<lLineBreak>*/,/*<nLeftMargin>*/,/*<lLineStyle>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<cCharSeparator>*/,/*<nLinesBefore>*/,/*<nCols>*/,/*<nClrBack>*/,/*<nClrFore>*/,	/*<nPercentage>	*/ )
		oSection1:= TRSection():New(oReport,'FATURAMENTO POR PESO',{'SE1'},,.F.,.T.,'Sub Total',.F.)

		//TRCell():New(/*<oParent>*/,/*<cName>*/,/*<cAlias>*/,/*<cTitle>*/,/*<cPicture>*/,/*<nSize>*/,/*<lPixel>*/,/*<bBlock>*/,/*<cAlign>*/,/*<lLineBreak>*/,/*<cHeaderAlign>,/*<lCellBreak>*/,/*<nColSpace>*/,/*<lAutoSize>*/,/*<nClrBack>*/,/*<nClrFore>*/,/*<lBold>*/)
		TRCell():New(oSection1,'TIPO','TB1TMP','DTEMISSAO',,5,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'DTEMISSAO','TB1TMP','DTEMISSAO',,10,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'PRODUTO','TB1TMP','PRODUTO',,76,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'QTVEN','TB1TMP','QTVEN','@E 999,999,999.999999',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'PRUNIT','TB1TMP','PRUNIT','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'VLTOTAL','TB1TMP','VLTOTAL','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'PDESC','TB1TMP','PDESC','@E 99.99',5,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'DESC','TB1TMP','DESC','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'VLVENDA','TB1TMP','VLVENDA','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'VLDEVOL','TB1TMP','VLDEVOL','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'CUSTO','TB1TMP','CUSTO','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'PESOTOTAL','TB1TMP','PESOTOTAL','@E 999,999,999.999999',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'CODVEN','TB1TMP','CODVEN',,6,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'XVENDEDOR','TB1TMP','XVENDEDOR',,30,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'FRETE','TB1TMP','FRETE','@E 9,999,999,999,999.99',16,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'FRETERAT','TB1TMP','FRETE RAT','@E 9,999,999,999,999.99',16,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'GRUPO','TB1TMP','GRUPO',,40,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'TPVEND','TB1TMP','TPVEND',,10,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'REGIAO','TB1TMP','REGIAO',,10,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'EQUIPE','TB1TMP','EQUIPE',,10,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'META','TB1TMP','META','@E 9,999,999,999,999.99',16,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'MPRAZO','TB1TMP','MPRAZO',,3,.F.,,'RIGHT',,'RIGHT',,,.F.)
		TRCell():New(oSection1,'ULTVEND','TB1TMP','ULTVEND',,60,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'RENT_BRUTO','TB1TMP','RENT_BRUTO','@E 9,999,999,999,999.99',16,.F.,,'LEFT',,'LEFT',,,.F.)
		TRCell():New(oSection1,'TIPOPROD','TB1TMP','TIPOPROD',,1,.F.,,'LEFT',,'LEFT',,,.F.)

		//configurando o totalizador
		//TRFunction():New(/*<oCell>*/,/*<cName>*/,/*<cFunction>*/,/*<oBreak>*/,/*<cTitle>*/,/*<cPicture>*/,/*<uFormula>*/,/*<lEndSection>*/,/*<lEndReport>*/,/*<lEndPage>*/,/*<oParent>*/,/*<bCondition>*/,/*<lDisable>*/,/*<bCanPrint>*/)
		TRFunction():New(oSection1:Cell('VLTOTAL'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_VALOR'),,.T.,.T.,.T.,oSection1)
		TRFunction():New(oSection1:Cell('CUSTO'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_VALLIQ'),,.T.,.T.,.T.,oSection1)
		TRFunction():New(oSection1:Cell('PESOTOTAL'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,'@E 999,999,999.999999',,.T.,.T.,.T.,oSection1)
		TRFunction():New(oSection1:Cell('RENT_BRUTO'),,'SUM',/*<oBreak>*/,/*<cTitle>*/,x3Picture('E1_SALDO'),,.T.,.T.,.T.,oSection1)

	endif

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
		
		//imprimindo a primeira seção
		if nTpRel = 1	//RECEITAS
			oSection1:Cell('NATUREZA'):SetValue(alltrim(TB1TMP->NATUREZA))
			oSection1:Cell('TITULO'):SetValue(TB1TMP->TITULO)
			oSection1:Cell('EMISSAO'):SetValue(stod(TB1TMP->EMISSAO))
			oSection1:Cell('VENCTO'):SetValue(stod(TB1TMP->VENCTO))
			oSection1:Cell('VALOR'):SetValue(TB1TMP->VALOR)
			oSection1:Cell('VALOR_RECEBIDO'):SetValue(TB1TMP->VALOR_RECEBIDO)
			oSection1:Cell('SALDO'):SetValue(alltrim(TB1TMP->SALDO))
			oSection1:Cell('STATUS'):SetValue(alltrim(TB1TMP->STATUS))
			oSection1:Cell('CODSUP'):SetValue(alltrim(TB1TMP->CODSUP))
			oSection1:Cell('EMPGRUPO'):SetValue(alltrim(TB1TMP->EMPGRUPO))
			oSection1:Printline()

		elseif nTpRel = 2	//DESPESAS
			oSection1:Cell('NATUREZA'):SetValue(TB1TMP->NATUREZA)
			oSection1:Cell('TITULO'):SetValue(TB1TMP->TITULO)
			oSection1:Cell('FORNECEDOR'):SetValue(alltrim(TB1TMP->FORNECEDOR))
			oSection1:Cell('DATA'):SetValue(dtoc(stod(TB1TMP->DATA)))
			oSection1:Cell('VALOR'):SetValue(TB1TMP->VALOR)
			oSection1:Cell('DESCRICAO'):SetValue(alltrim(TB1TMP->DESCRICAO))
			oSection1:Cell('CAIXA'):SetValue(alltrim(TB1TMP->CAIXA))
			oSection1:Cell('TIPOCCUSTO'):SetValue(alltrim(TB1TMP->TIPOCCUSTO))
			oSection1:Printline()

		elseif nTpRel = 3	//CUSTOS
			oSection1:Cell('TIPO'):SetValue(alltrim(TB1TMP->TIPO))
			oSection1:Cell('DTEMISSAO'):SetValue(dtoc(stod(TB1TMP->DTEMISSAO)))
			oSection1:Cell('CONDPGTO'):SetValue(alltrim(TB1TMP->CONDPGTO))
			oSection1:Cell('PRODUTO'):SetValue(alltrim(TB1TMP->PRODUTO))
			oSection1:Cell('QTVEN'):SetValue(TB1TMP->QTVEN)
			oSection1:Cell('PRUNIT'):SetValue(TB1TMP->PRUNIT)
			oSection1:Cell('VLTOTAL'):SetValue(TB1TMP->VLTOTAL)
			oSection1:Cell('PDESC'):SetValue(TB1TMP->PDESC)
			oSection1:Cell('DESC'):SetValue(TB1TMP->DESC)
			oSection1:Cell('VLVENDA'):SetValue(TB1TMP->VLVENDA)
			oSection1:Cell('CUSTO'):SetValue(TB1TMP->CUSTO)
			oSection1:Cell('CODVEN'):SetValue(alltrim(TB1TMP->CODVEN))
			oSection1:Cell('XVENDEDOR'):SetValue(alltrim(TB1TMP->XVENDEDOR))
			oSection1:Cell('FRETE'):SetValue(TB1TMP->FRETE)
			oSection1:Cell('FRETERAT'):SetValue(TB1TMP->FRETE_RAT)
			oSection1:Cell('GRUPO'):SetValue(alltrim(TB1TMP->GRUPO))
			oSection1:Cell('TPVEND'):SetValue(alltrim(TB1TMP->TPVEND))
			oSection1:Cell('REGIAO'):SetValue(alltrim(TB1TMP->REGIAO))
			oSection1:Cell('EQUIPE'):SetValue(alltrim(TB1TMP->EQUIPE))
			oSection1:Cell('META'):SetValue(TB1TMP->META)
			oSection1:Cell('MPRAZO'):SetValue(TB1TMP->MPRAZO)
			oSection1:Cell('ULTVEND'):SetValue(alltrim(TB1TMP->ULTVEND))
			oSection1:Cell('RENT_BRUTO'):SetValue(TB1TMP->RENT_BRUTO)
			oSection1:Cell('TIPOPROD'):SetValue(TB1TMP->TPPRODUTO)
			oSection1:Printline()

		elseif nTpRel = 4	//INADIMPLENCIA
			oSection1:Cell('NATUREZA'):SetValue(TB1TMP->NATUREZA)
			oSection1:Cell('TITULO'):SetValue(TB1TMP->TITULO)
			oSection1:Cell('EMISSAO'):SetValue(dtoc(stod(TB1TMP->EMISSAO)))
			oSection1:Cell('VENCTO'):SetValue(dtoc(stod(TB1TMP->VENCTO)))
			oSection1:Cell('VALOR'):SetValue(TB1TMP->VALOR)
			oSection1:Cell('VALOR_RECEBIDO'):SetValue(TB1TMP->VALOR_RECEBIDO)
			oSection1:Cell('SALDO'):SetValue(TB1TMP->SALDO)
			oSection1:Cell('STATUS'):SetValue(alltrim(TB1TMP->STATUS))
			oSection1:Cell('DTBAIXA'):SetValue(dtoc(stod(TB1TMP->DTBAIXA)))
			oSection1:Cell('CODSUP'):SetValue(alltrim(TB1TMP->CODSUP))
			oSection1:Cell('EMPGRUPO'):SetValue(alltrim(TB1TMP->EMPGRUPO))
			oSection1:Printline()

		elseif nTpRel = 5	//PESO
			oSection1:Cell('TIPO'):SetValue(alltrim(TB1TMP->TIPO))
			oSection1:Cell('DTEMISSAO'):SetValue(dtoc(stod(TB1TMP->DTEMISSAO)))
			oSection1:Cell('PRODUTO'):SetValue(alltrim(TB1TMP->PRODUTO))
			oSection1:Cell('QTVEN'):SetValue(TB1TMP->QTVEN)
			oSection1:Cell('PRUNIT'):SetValue(TB1TMP->PRUNIT)
			oSection1:Cell('VLTOTAL'):SetValue(TB1TMP->VLTOTAL)
			oSection1:Cell('PDESC'):SetValue(TB1TMP->PDESC)
			oSection1:Cell('DESC'):SetValue(TB1TMP->DESC)
			oSection1:Cell('VLVENDA'):SetValue(TB1TMP->VLVENDA)
			oSection1:Cell('CUSTO'):SetValue(TB1TMP->CUSTO)
			oSection1:Cell('VLVENDA'):SetValue(TB1TMP->VLVENDA)
			oSection1:Cell('VLDEVOL'):SetValue(TB1TMP->VLDEVOL)
			oSection1:Cell('CODVEN'):SetValue(alltrim(TB1TMP->CODVEN))
			oSection1:Cell('XVENDEDOR'):SetValue(alltrim(TB1TMP->XVENDEDOR))
			oSection1:Cell('FRETE'):SetValue(TB1TMP->FRETE)
			oSection1:Cell('FRETERAT'):SetValue(TB1TMP->FRETE_RAT)
			oSection1:Cell('GRUPO'):SetValue(alltrim(TB1TMP->GRUPO))
			oSection1:Cell('TPVEND'):SetValue(alltrim(TB1TMP->TPVEND))
			oSection1:Cell('REGIAO'):SetValue(alltrim(TB1TMP->REGIAO))
			oSection1:Cell('EQUIPE'):SetValue(alltrim(TB1TMP->EQUIPE))
			oSection1:Cell('META'):SetValue(TB1TMP->META)
			oSection1:Cell('MPRAZO'):SetValue(TB1TMP->MPRAZO)
			oSection1:Cell('ULTVEND'):SetValue(alltrim(TB1TMP->ULTVEND))
			oSection1:Cell('RENT_BRUTO'):SetValue(TB1TMP->RENT_BRUTO)
			oSection1:Cell('TIPOPROD'):SetValue(TB1TMP->TPPRODUTO)
			oSection1:Printline()
			
		endif

		TB1TMP->(dbSkip())
			
	enddo
	
	//imprimo uma linha para separar um vendedor de outro
	oReport:ThinLine()

	//finalizo a primeira seção
	oSection1:Finish()			

return

static function Query()

	local cQuery	:= ''
	
	if nTpRel = 1	//RECEITAS
		cQuery	:='exec dbo.PR_RL06009 @pTpRel = "'+cValToChar(nTpRel)+'", @pDtIni = "'+DTOS(mv_par01)+'", @pDtFim = "'+DTOS(mv_par02)+'"'	
	elseif nTpRel = 2	//DEPESAS
		cQuery	:='exec dbo.PR_RL06009 @pTpRel = "'+cValToChar(nTpRel)+'", @pDtIni = "'+DTOS(mv_par01)+'", @pDtFim = "'+DTOS(mv_par02)+'"'	
	elseif nTpRel = 3	//CUSTOS
		cQuery	:='exec dbo.PR_RL06009 @pTpRel = "'+cValToChar(nTpRel)+'", @pDtIni = "'+DTOS(mv_par01)+'", @pDtFim = "'+DTOS(mv_par02)+'"'	
	elseif nTpRel = 4	//INADIMPLENCIA
		cQuery	:='exec dbo.PR_RL06009 @pTpRel = "'+cValToChar(nTpRel)+'", @pDtIni = "19000101", @pDtFim = "'+DTOS(mv_par01)+'"'	
	elseif nTpRel = 5	//PESO
		cQuery	:='exec dbo.PR_RL06009 @pTpRel = "'+cValToChar(nTpRel)+'", @pDtIni = "'+DTOS(mv_par01)+'", @pDtFim = "'+DTOS(mv_par02)+'"'	
	endif

return cQuery

static function ajustaSx1(cPerg)

	if nTpRel = 1	//RECEITAS
		//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
		U_XPUTSX1(     cPerg,"01","Data Inicial?" ,"."     ,"."       ,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
		U_XPUTSX1(     cPerg,"02","Data Final?","."     ,"."       ,"mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")
	elseif nTpRel = 2	//DEPESAS
		//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
		U_XPUTSX1(     cPerg,"01","Data Inicial?" ,"."     ,"."       ,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
		U_XPUTSX1(     cPerg,"02","Data Final?","."     ,"."       ,"mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")
	elseif nTpRel = 3	//CUSTOS
		//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
		U_XPUTSX1(     cPerg,"01","Data Inicial?" ,"."     ,"."       ,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
		U_XPUTSX1(     cPerg,"02","Data Final?","."     ,"."       ,"mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")
	elseif nTpRel = 4	//INADIMPLENCIA
		//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
		U_XPUTSX1(     cPerg,"01","Data Corte?" ,"."     ,"."       ,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	elseif nTpRel = 5	//PESO
		//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
		U_XPUTSX1(     cPerg,"01","Data Inicial?" ,"."     ,"."       ,"mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
		U_XPUTSX1(     cPerg,"02","Data Final?","."     ,"."       ,"mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")
	endif

return
