#include "protheus.ch"
#include 'parmtype.ch'
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "fwprintsetup.ch" 
#include "topconn.ch"

#define imp_spool 2

/*/
===============================================================================================================================
Programa----------: RL06001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 21/08/2018
===============================================================================================================================
Descri็ใo---------: Este programa serve para imprimir relatorio de Tipos x Liquidacao
===============================================================================================================================
Uso---------------: Relatorio Contas a Receber
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
user function RL06001()
                                                                          
	_CriaSX1("RL06001") //Cria os parametros
	
	If !Pergunte("RL06001",.T.)   //Chama a tela de parametros
		Return
	EndIf
	
	//Parametros iniciais
	Private oPrinter      
	Private _nLin			:= 005
	Private _nCol	 		:= 800
    Private _nPage			:= 0
    Private _tLin			:= 580 // total de linhas
    
	Private tSumValor		:= 0
	Private tSumBaixa		:= 0
	Private tSumMulta		:= 0
	Private tSumJuros		:= 0
	Private tSumCorrecao	:= 0
	Private tSumDesconto	:= 0
	Private tSumValorGer	:= 0

	cNomePDF	:= 'RL06001'

	lPreview	:= .T.
//	If oPrinter == Nil
//		 lPreview		:= .T.
//		 oPrinter      	:= FWMSPrinter():New(cNomePDF,6,.F.,,.T.)
//		 oPrinter:SetPortrait()
//		 //oPrinter:Setup()
//		 oPrinter:SetPaperSize(9)
//		 oPrinter:SetMargin(60,60,60,60)
//		 oPrinter:cPathPDF	:= "C:\TEMP\"       
//	EndIf       

	Private _plAdjustToLegacy	:= .F.
	Private cPathInServer		:= GetTempPath()
	Private lDisabeSetup		:= .T.

	oPrinter := FWMSPrinter():New(cNomePDF, 6, _plAdjustToLegacy,cPathInServer,lDisabeSetup)  
	//oPrinter:SetDevice(IMP_PDF) //IMP_SPOOL=IMPRESSORA, IMP_PDF=PDF 
	oPrinter:SetResolution(72)
	oPrinter:SetLandscape() // Formato Paisagem
	oPrinter:SetPaperSize(9) // Papel A4
	oPrinter:SetMargin(60,60,60,60) // Margem

	//Fontes
	Private oFont06
	Private oFont06N
	Private oFont09
	Private oFont09N
	Private oFont10
	Private oFont10N
	Private oFont14
	Private oFont14N

	oFont06		:= TFontEx():New(oPrinter,"Courier New",06,06,.F.,.T.,.F.)
	oFont06N	:= TFontEx():New(oPrinter,"Courier New",06,06,.T.,.T.,.F.)
	oFont09		:= TFontEx():New(oPrinter,"Courier New",09,09,.F.,.T.,.F.)
	oFont09N	:= TFontEx():New(oPrinter,"Courier New",09,09,.T.,.T.,.F.)
	oFont10		:= TFontEx():New(oPrinter,"Courier New",10,10,.F.,.T.,.F.)
	oFont10N	:= TFontEx():New(oPrinter,"Courier New",10,10,.T.,.T.,.F.)
	oFont14		:= TFontEx():New(oPrinter,"Courier New",14,14,.F.,.T.,.F.)
	oFont14N	:= TFontEx():New(oPrinter,"Courier New",14,14,.T.,.T.,.F.)

	// Iniciando a Impressao
	oPrinter:StartPage()

	Processa({|| PrintRel() },"Aguarde a abertura do relatorio...","Gerando arquivo PDF ...")
			
	oPrinter:EndPage()
	SetPgEject(.F.) // Funcao pra n?o ejetar pagina em branco 

	If lPreview
		oPrinter:Preview()
	EndIf

	If oPrinter # Nil
		FreeObj(oPrinter)
	EndIf
	oPrinter := Nil

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ__CRIASX1 บAutor  ณMicrosiga           บ Data ณ  01/07/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria perguntas dos parametros                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function _CriaSX1(cPerg)

//Grupo de Perguntas
aHelpPor := {}
Aadd( aHelpPor, 'Data Inicial da liquidacao		')
aHelpEsp := {}
Aadd( aHelpEsp, 'Fecha de la liquidacion		')
aHelpIng := {}
Aadd( aHelpIng, 'Settlement start date			')
U_xPutSX1(cPerg,"01","Data Inicial"		,"Data Inicial"		,"Data Inicial"		,"mv_ch1","D",08	,0,1,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEsp,aHelpIng)
aHelpPor := {}
Aadd( aHelpPor, 'Data Final da Liquidacao		')
aHelpEsp := {}
Aadd( aHelpEsp, 'Fecha final de la liquidacion	')
aHelpIng := {}
Aadd( aHelpIng, 'Final Settlement Date			')
U_xPutSX1(cPerg,"02","Data Final"		,"Data Final"		,"Data Final"		,"mv_ch2","D",08	,0,1,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEsp,aHelpIng)
aHelpPor := {}
Aadd( aHelpPor, 'Tipo							')
aHelpEsp := {}
Aadd( aHelpEsp, 'Tipo							')
aHelpIng := {}
Aadd( aHelpIng, 'Kind							')
U_xPutSX1(cPerg,"03","Tipo"				,"Tipo"				,"Kind"				,"mv_ch3","C",03	,0,1,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEsp,aHelpIng)
Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintRel บAutor  ณRenato Fuzessy       บ Data ณ  31/07/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao Relatorio de Liquidacao                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Manfil                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PrintRel()

	Private aArea := GetArea()
	
	IncProc("Gerando relatorio ")
	
	ImpCabec()

	ImpItens()

	RestArea(aArea)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  MontaLIQ  บAutor  ณRenato Fuzessy       บ Data ณ  27/06/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona registros liquidacao                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaLIQ()

	Local _cDataIni		:= DTOS(mv_par01)
	Local _cDataFim		:= DTOS(mv_par02)
	Local _cTipo		:= mv_par03
		
	If Select("TB1")<>0
		TB1->(DbCloseArea())
	EndIf
	
	BeginSql alias "TB1"
		select
			 convert(varchar,convert(datetime,SE1.E1_EMISSAO),103)		as [DATA]
			,SE1.E1_TIPO												as [TIPO]
			,SE1.E1_NUMLIQ												as [NUMLIQ]
			,sum(SE1.E1_VALOR)											as [VALOR]
		from
			SE1010	as SE1
		where
				SE1.D_E_L_E_T_		= ''
			and SE1.E1_NUMLIQ		!= ''
			and SE1.E1_TIPO			= %Exp:_cTipo%
			and SE1.E1_EMISSAO		between %Exp:_cDataIni% AND %Exp:_cDataFim%
		group by
			 SE1.E1_EMISSAO
			,SE1.E1_TIPO
			,SE1.E1_NUMLIQ
		order by
			 SE1.E1_EMISSAO
			,SE1.E1_TIPO
			,SE1.E1_NUMLIQ
			
	EndSql
	
	DbSelectArea("TB1")
	TB1->(DbGoTop())
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  MontaPED  บAutor  ณRenato Fuzessy       บ Data ณ  28/06/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona registros dos pedidos baixados pela liquidacao   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MontaPED(_pNumLiq)

	Local _cDatabase	:= DTOS(mv_par02)
		
	If Select("TB2")<>0
		TB2->(DbCloseArea())
	EndIf
	
	BeginSql alias "TB2"
		select
			 SE1.E1_PREFIXO+'-'+SE1.E1_TIPO+'-'+SE1.E1_NUM					as TITULO
			,SE1.E1_CLIENTE+'-'+SE1.E1_LOJA+'-'+SE1.E1_NOMCLI				as CLIENTE
			,convert(varchar,convert(datetime,SE1.E1_VENCREA),103)			as VENCTOREAL
			,SE1.E1_VALOR													as VALOR
			,convert(varchar,convert(datetime,SE5.E5_DATA),103)				as DATA
			,SE5.E5_VALOR													as VLBAIXA
			,SE5.E5_VLMULTA													as VLMULTA
			,SE5.E5_VLJUROS													as VLJUROS
			,SE5.E5_VLCORRE													as VLCORRE
			,SE5.E5_VLDESCO													as VLDESCO

		from
			SE5010	as SE5

			inner join SE1010	as SE1
				on	SE1.D_E_L_E_T_			= ''
				and SE1.E1_FILIAL			= SE5.E5_FILIAL
				and SE1.E1_PREFIXO			= SE5.E5_PREFIXO
				and SE1.E1_NUM				= SE5.E5_NUMERO
				and	SE1.E1_PARCELA			= SE5.E5_PARCELA
				and SE1.E1_TIPO				= SE5.E5_TIPO

		where
				SE5.D_E_L_E_T_		= ''
			and SE5.E5_MOTBX		= 'LIQ'
			and SE5.E5_TIPODOC		= 'BA'
			and SE5.E5_DOCUMEN		= %Exp:_pNumLiq%
			and SE5.E5_DATA			<= %Exp:_cDatabase%
	EndSql
	
	DbSelectArea("TB2")
	TB2->(DbGoTop())
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  MontaGerados  บAutor  ณRenato Fuzessy   บ Data ณ  28/06/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona registros dos titulos gerados                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Manfil                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MontaGerados(_pNumLiq)

	If Select("TB3")<>0
		TB3->(DbCloseArea())
	EndIf
	
	BeginSql alias "TB3"
		select
			 SE1.E1_PREFIXO+'-'+SE1.E1_TIPO+'-'+SE1.E1_NUM					as TITULO
			,SE1.E1_CLIENTE+'-'+SE1.E1_LOJA+'-'+SE1.E1_NOMCLI				as CLIENTE
			,convert(varchar,convert(datetime,SE1.E1_VENCREA),103)			as VENCTOREAL
			,SE1.E1_VALOR													as VALOR

		from
			SE1010	as SE1

		where
				SE1.D_E_L_E_T_		= ''
			and SE1.E1_NUMLIQ		= %Exp:_pNumLiq%
			
	EndSql
	
	DbSelectArea("TB3")
	TB3->(DbGoTop())

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  TotalizaLIQ  บAutor  ณRenato Fuzessy    บ Data ณ  11/09/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Totaliza os registros liquidacao                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TotalizaLIQ()

	Local _cDataIni		:= DTOS(mv_par01)
	Local _cDataFim		:= DTOS(mv_par02)
	Local _cTipo		:= mv_par03
		
	If Select("TB4")<>0
		TB4->(DbCloseArea())
	EndIf
	
	BeginSql alias "TB4"
		select
			 SE1.E1_TIPO												as [TIPO]
			,sum(SE1.E1_VALOR)											as [VALOR]
		from
			SE1010	as SE1
		where
				SE1.D_E_L_E_T_		= ''
			and SE1.E1_NUMLIQ		!= ''
			and SE1.E1_TIPO			= %Exp:_cTipo%
			and SE1.E1_EMISSAO		between %Exp:_cDataIni% AND %Exp:_cDataFim%
		group by
			 SE1.E1_TIPO
			
	EndSql
	
	DbSelectArea("TB4")
	TB4->(DbGoTop())
	
Return



Static Function ImpCabec()

	//Dados da Empresa
	Local _cLogo := GetSrvProfString("StartPath","")+"lgrl01.bmp"
	
	_nPage	+= 1
	_nLin	:= 005

	oPrinter:SayBitMap	(_nLin		, 001, _cLogo) 
	oPrinter:SayAlign	(_nLin+040	, 001, "Relatorio de Liquidacao x Tipo"	,oFont14N:oFont ,_nCol,,,2,1)
	oPrinter:SayAlign	(_nLin+060	, 001, "Impressao: "+DTOC(DDATABASE)+" - "+SubStr(TIME(),1,8), oFont06:oFont,_nCol,,,1,1)
	oPrinter:Line		(_nLin+070	, 001, _nLin+070, _nCol)
	
	oPrinter:Line		(_nLin+590	, 001, _nLin+590, _nCol)
	oPrinter:SayAlign	(_nLin+595	, 001, "Pagina: "+cValToChar(_nPage), oFont06:oFont,_nCol,,,1,1)
	
	_nLin	:= 075  

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ               ?
ฑฑบPrograma  ณImpItens()  บAutor  ณMicrosiga         บ Data ณ  13/06/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpItens()

	Local aItens		:= Array(100,12)
	Local aX			:= 0
	
	Local nSumValor		:= 0
	Local nSumBaixa		:= 0
	Local nSumMulta		:= 0
	Local nSumJuros		:= 0
	Local nSumCorrecao	:= 0
	Local nSumDesconto	:= 0

	Local nSumValorGer	:= 0

	// IMPRIME LINHAS DE LIQUIDACAO + PEDIDOS + CHEQUES
	MontaLIQ()
	While !TB1->(Eof())
	
		nSumValor		:= 0
		nSumBaixa		:= 0
		nSumMulta		:= 0
		nSumJuros		:= 0
		nSumCorrecao	:= 0
		nSumDesconto	:= 0
		nSumValorGer	:= 0
		
		oPrinter:SayAlign	(_nLin		, 001, "Data: "+alltrim(TB1->DATA)+" Tipo: "+alltrim(TB1->TIPO)+" - Num. Liq: "+ALLTRIM(TB1->NUMLIQ)+" - "+TransForm(TB1->VALOR,"@E 999,999.99")	,oFont09N:oFont ,_nCol,,,0,1)
				
		// CABECALHO DOS GERADORES
		_nLin += 12
		oPrinter:SayAlign	(_nLin, 001, "Titulo"				,oFont09:oFont ,075,,,2,0)
		oPrinter:SayAlign	(_nLin, 075, "Cliente"				,oFont09:oFont ,150,,,2,0)
		oPrinter:SayAlign	(_nLin, 225, "Vencto Real"			,oFont09:oFont ,050,,,2,0)
		oPrinter:SayAlign	(_nLin, 300, "Valor"				,oFont09:oFont ,050,,,2,0)
		oPrinter:SayAlign	(_nLin, 350, "Baixa"				,oFont09:oFont ,050,,,2,0)
		oPrinter:SayAlign	(_nLin, 400, "Multa"				,oFont09:oFont ,050,,,2,0)
		oPrinter:SayAlign	(_nLin, 450, "Juros"				,oFont09:oFont ,050,,,2,0)
		oPrinter:SayAlign	(_nLin, 500, "Correcao"				,oFont09:oFont ,050,,,2,0)
		oPrinter:SayAlign	(_nLin, 550, "Desconto"	   			,oFont09:oFont ,050,,,2,0)

		// CABECALHO DOS GERADOS
		oPrinter:SayAlign	(_nLin, 625, "Titulo Gerados"		,oFont09:oFont ,075,,,2,0)
		oPrinter:SayAlign	(_nLin, 700, "Vencto Gerados"		,oFont09:oFont ,050,,,2,0)
		oPrinter:SayAlign	(_nLin, 750, "Valor Gerados"		,oFont09:oFont ,050,,,2,0)
		_nLin += 12
		oPrinter:Line		(_nLin, 001, _nLin, _nCol)

		// IMPRIME LINHA DOS TITULOS GERADOS
		MontaPED(TB1->NUMLIQ)
		DbSelectArea("TB2")
		DbGoTop()
		aX	:= 0
		While !TB2->(Eof())
			aX += 1

			nSumBaixa		+= TB2->VLBAIXA
			nSumValor		+= TB2->VALOR
			nSumMulta		+= TB2->VLMULTA
			nSumJuros		+= TB2->VLJUROS
			nSumCorrecao	+= TB2->VLCORRE
			nSumDesconto	+= TB2->VLDESCO

			aItens[aX,1]	:= TB2->TITULO
			aItens[aX,2]	:= TB2->CLIENTE
			aItens[aX,3]	:= TB2->VENCTOREAL
			aItens[aX,4]	:= TransForm(TB2->VALOR,"@E 999,999.99")
			aItens[aX,5]	:= TransForm(TB2->VLBAIXA,"@E 999,999.99")
			aItens[aX,6]	:= TransForm(TB2->VLMULTA,"@E 999,999.99")
			aItens[aX,7]	:= TransForm(TB2->VLJUROS,"@E 999,999.99")
			aItens[aX,8]	:= TransForm(TB2->VLCORRE,"@E 999,999.99")
			aItens[aX,9]	:= TransForm(TB2->VLDESCO,"@E 999,999.99")

			DbSelectArea("TB2")
			TB2->(DbSkip())

		EndDo
		TB2->(DbCloseArea())

		DbSelectArea("TB1")
		MontaGerados(TB1->NUMLIQ)
		DbSelectArea("TB3")
		DbGoTop()
		aX	:= 0
		While !TB3->(Eof())
			aX += 1

			nSumValorGer	+= TB3->VALOR

			aItens[aX,10]	:= alltrim(TB3->TITULO)
			aItens[aX,11]	:= alltrim(TB3->VENCTOREAL)
			aItens[aX,12]	:= TransForm(TB3->VALOR,"@E 999,999.99")

			DbSelectArea("TB3")
			TB3->(DbSkip())

		EndDo
		TB3->(DbCloseArea())

		for aX:= 1 to len(aItens)
			If ((cValToChar(aItens[aX,1]) != "").OR.(cValToChar(aItens[aX,10]) != ""))
				oPrinter:SayAlign	(_nLin, 001, cValToChar(aItens[aX,1])	,oFont09:oFont ,075,,,0,0)
				oPrinter:SayAlign	(_nLin, 075, cValToChar(aItens[aX,2])	,oFont09:oFont ,150,,,0,0)
				oPrinter:SayAlign	(_nLin, 225, cValToChar(aItens[aX,3])	,oFont09:oFont ,050,,,2,0)
				oPrinter:SayAlign	(_nLin, 300, cValToChar(aItens[aX,4])	,oFont09:oFont ,050,,,1,0)
				oPrinter:SayAlign	(_nLin, 350, cValToChar(aItens[aX,5])	,oFont09:oFont ,050,,,1,0)
				oPrinter:SayAlign	(_nLin, 400, cValToChar(aItens[aX,6])	,oFont09:oFont ,050,,,1,0)
				oPrinter:SayAlign	(_nLin, 450, cValToChar(aItens[aX,7])	,oFont09:oFont ,050,,,1,0)
				oPrinter:SayAlign	(_nLin, 500, cValToChar(aItens[aX,8])	,oFont09:oFont ,050,,,1,0)
				oPrinter:SayAlign	(_nLin, 550, cValToChar(aItens[aX,9])	,oFont09:oFont ,050,,,1,0)
				oPrinter:SayAlign	(_nLin, 625, cValToChar(aItens[aX,10])	,oFont09:oFont ,075,,,0,0)
				oPrinter:SayAlign	(_nLin, 700, cValToChar(aItens[aX,11])	,oFont09:oFont ,050,,,2,0)
				oPrinter:SayAlign	(_nLin, 750, cValToChar(aItens[aX,12])	,oFont09:oFont ,050,,,1,0)
				_nLin += 10
	
				If _nLin > _tLin
					oPrinter:EndPage()
					oPrinter:StartPage()
					ImpCabec()
				EndIf
			EndIf
		
		next

		oPrinter:Line		(_nLin	, 200, _nLin, _nCol)
		oPrinter:SayAlign	(_nLin	, 225, "Total ->>"								,oFont09N:oFont ,050,,,2,0)
		oPrinter:SayAlign	(_nLin	, 300, TransForm(nSumValor,"@E 999,999.99")		,oFont09N:oFont ,050,,,1,0)
		oPrinter:SayAlign	(_nLin	, 350, TransForm(nSumBaixa,"@E 999,999.99")		,oFont09N:oFont ,050,,,1,0)
		oPrinter:SayAlign	(_nLin	, 400, TransForm(nSumMulta,"@E 999,999.99")		,oFont09N:oFont ,050,,,1,0)
		oPrinter:SayAlign	(_nLin	, 450, TransForm(nSumJuros,"@E 999,999.99")		,oFont09N:oFont ,050,,,1,0)
		oPrinter:SayAlign	(_nLin	, 500, TransForm(nSumCorrecao,"@E 999,999.99")	,oFont09N:oFont ,050,,,1,0)
		oPrinter:SayAlign	(_nLin	, 550, TransForm(nSumDesconto,"@E 999,999.99")	,oFont09N:oFont ,050,,,1,0)
		oPrinter:SayAlign	(_nLin	, 700, "Total ->>"								,oFont09N:oFont ,050,,,2,0)
		oPrinter:SayAlign	(_nLin	, 750, TransForm(nSumValorGer,"@E 999,999.99")	,oFont09N:oFont ,050,,,1,0)
		_nLin += 17
		oPrinter:Line		(_nLin	, 001, _nLin, _nCol)
		
		//TOTALIZADOR GERAL
		tSumValor		+= nSumValor
		tSumBaixa		+= nSumBaixa
		tSumMulta		+= nSumMulta
		tSumJuros		+= nSumJuros
		tSumCorrecao	+= nSumCorrecao
		tSumDesconto	+= nSumDesconto
		tSumValorGer	+= nSumValorGer

		//alert(cValToChar(TransForm(nSumValorGer,"@E 999,999.99"))+" - "+cValToChar(TransForm(tSumValorGer,"@E 999,999.99")))
				
		//LIMPANDO MATRIZ
		for aX:= 1 to len(aItens)
			aItens[aX,1]	:= ""
			aItens[aX,2]	:= ""
			aItens[aX,3]	:= ""
			aItens[aX,4]	:= ""
			aItens[aX,5]	:= ""
			aItens[aX,6]	:= ""
			aItens[aX,7]	:= ""
			aItens[aX,8]	:= ""
			aItens[aX,9]	:= ""
			aItens[aX,10]	:= ""
			aItens[aX,11]	:= ""
			aItens[aX,12]	:= ""
		next

		DbSelectArea("TB1")
		TB1->(DbSkip())

		If _nLin +24 > _tLin
			oPrinter:EndPage()
			oPrinter:StartPage()
			ImpCabec()
		EndIf

	EndDo
	DbSelectArea("TB1")
	TB1->(dbCloseArea())
		
	//IMPRIMINDO O TOTAL DO Relatorio
	oPrinter:Line		(_nLin	, 200, _nLin, _nCol)
	oPrinter:SayAlign	(_nLin	, 225, "Total ->>"								,oFont09N:oFont ,050,,,2,0)
	oPrinter:SayAlign	(_nLin	, 300, TransForm(tSumValor,"@E 999,999.99")		,oFont09N:oFont ,050,,,1,0)
	oPrinter:SayAlign	(_nLin	, 350, TransForm(tSumBaixa,"@E 999,999.99")		,oFont09N:oFont ,050,,,1,0)
	oPrinter:SayAlign	(_nLin	, 400, TransForm(tSumMulta,"@E 999,999.99")		,oFont09N:oFont ,050,,,1,0)
	oPrinter:SayAlign	(_nLin	, 450, TransForm(tSumJuros,"@E 999,999.99")		,oFont09N:oFont ,050,,,1,0)
	oPrinter:SayAlign	(_nLin	, 500, TransForm(tSumCorrecao,"@E 999,999.99")	,oFont09N:oFont ,050,,,1,0)
	oPrinter:SayAlign	(_nLin	, 550, TransForm(tSumDesconto,"@E 999,999.99")	,oFont09N:oFont ,050,,,1,0)
	oPrinter:SayAlign	(_nLin	, 700, "Total ->>"								,oFont09N:oFont ,050,,,2,0)
	oPrinter:SayAlign	(_nLin	, 750, TransForm(tSumValorGer,"@E 999,999.99")	,oFont09N:oFont ,050,,,1,0)
	_nLin += 10
	
	TotalizaLIQ()
	While !TB4->(Eof())

		If _nLin +17 > _tLin
			oPrinter:EndPage()
			oPrinter:StartPage()
			ImpCabec()
		EndIf

		_nLin += 10
		oPrinter:Line		(_nLin	, 200, _nLin, _nCol)
		oPrinter:SayAlign	(_nLin	, 225, "Total por Tipo "+TB4->TIPO+" ->> "+TransForm(TB4->VALOR,"@E 999,999.99")	,oFont09N:oFont ,_nCol,,,2,1)
		_nLin += 17
		oPrinter:Line		(_nLin	, 200, _nLin, _nCol)

		DbSelectArea("TB4")
		TB4->(DbSkip())
	EndDo
	DbSelectArea("TB4")
	TB4->(dbCloseArea())

Return