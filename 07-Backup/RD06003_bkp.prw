#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"   
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"

/*
===============================================================================================================================
Programa----------: RD06003
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para imprimir boletas do banco ITAU
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento) e Funções de Contas a Receber (financeiro)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
=====================================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor	|	Data	|										Motivo																
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|           | 																										
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			|																											
=====================================================================================================================================
*/
#DEFINE POS_CEDENTE1	1
#DEFINE POS_AGENCOB		2
#DEFINE POS_NUMTIT1		3
#DEFINE POS_VENCTIT1	4
#DEFINE POS_SACADO1		5                    
#DEFINE POS_DTENTREGA	6
#DEFINE POS_VALDOCTO	7
#DEFINE POS_LINDG1		8
#DEFINE POS_LOCPAGTO1	9
#DEFINE POS_VENCTIT2	10
#DEFINE POS_SACADO2		11
#DEFINE POS_AGENCOB2	12
#DEFINE POS_DTDOC1		13
#DEFINE POS_NRODOC1		14
#DEFINE POS_ESPECDOC1	15
#DEFINE POS_ACEITE1		16
#DEFINE POS_DTPROC1		17
#DEFINE POS_NUMTIT2		18
#DEFINE POS_CARTEIRA1	19
#DEFINE POS_ESPECIE1	20
#DEFINE POS_VALOR1		21
#DEFINE POS_VLRDOC1		22
#DEFINE POS_MEN1_1		23
#DEFINE POS_MEN1_2		24
#DEFINE POS_MEN1_3		25
#DEFINE POS_MEN1_4		26
#DEFINE POS_MEN1_5		27
#DEFINE POS_MEN1_6		28
#DEFINE POS_MEN1_7		29
#DEFINE POS_MEN1_8		30
#DEFINE POS_MEN1_9		71
#DEFINE POS_MEN1_10		73
#DEFINE POS_MEN1_11		74
#DEFINE POS_MEN1_12		75
#DEFINE POS_CEDENTE2	31
#DEFINE POS_CEDCNPJ2	32
#DEFINE POS_CEDCEI2		33
#DEFINE POS_CEDEND2		34
#DEFINE POS_LINDG2		35
#DEFINE POS_LOCPAGTO2	36
#DEFINE POS_VENCTIT3	37
#DEFINE POS_CEDENTE3	38
#DEFINE POS_AGENCOB3	39
#DEFINE POS_DTDOC2		40
#DEFINE POS_NRODOC2		41
#DEFINE POS_ESPECDOC2	42
#DEFINE POS_ACEITE2		43
#DEFINE POS_DTPROC2		44
#DEFINE POS_NUMTIT3		45
#DEFINE POS_CARTEIRA2	46
#DEFINE POS_ESPECIE2	47
#DEFINE POS_VALOR2		48
#DEFINE POS_VLRDOC2		49
#DEFINE POS_MEN2_1		50
#DEFINE POS_MEN2_2		51
#DEFINE POS_MEN2_3		52
#DEFINE POS_MEN2_4		53
#DEFINE POS_MEN2_5		54
#DEFINE POS_MEN2_6		55
#DEFINE POS_MEN2_7		56
#DEFINE POS_MEN2_8		57
#DEFINE POS_SAC2		58
#DEFINE POS_CNPJ2		59
#DEFINE POS_CEI2		60
#DEFINE POS_END2		61
#DEFINE POS_USOBANCO1	62
#DEFINE POS_USOBANCO2	63
#DEFINE POS_CIP1		64
#DEFINE POS_CIP2		65
#DEFINE POS_SACAVA1		66
#DEFINE POS_SACAVA2		67
#DEFINE POS_MEN2_9      68       
#DEFINE POS_MEN2_10     69
#DEFINE POS_MEN2_11     72
#DEFINE POS_MEN2_12     76
#DEFINE POS_NUMDOC      70
#DEFINE POS_COLFIM    2340

user function RD06003(cFuncao,cTitulo,plViewPDF)

	Local _aArea		:= GetArea()
	Local _aAreaSC5		:= SC5->(GetArea())
	Local _aAreaSE1		:= SE1->(GetArea())
	Local _aAreaSA1		:= SA1->(GetArea())
	Local cNomePDF		:=""
	
	//Chama a rotina de impressao do boleto
	Processa({|| U_RFIN002E(cTitulo,'',cFuncao,@cNomePDF,plViewPDF) })
	
Return(cNomePDF)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFIN002E  ºAutor  ³Microsiga           º Data ³  01/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montagem e impressao do boleto bancario.                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
  
//User Function RFIN002E(cBordero,cCliente,cLoja,cNF,cSerie,cTipo,email,cTitulos)
User Function RFIN002E(cTitulos,email,cFuncao,cNomePDF,plViewPDF)

																			 

Local oPrint := Nil
Local oFonte1:= TFont():New( "Arial",,10,,.T.,,,,.F.,.F.)
Local oFonte2:= TFont():New( "Arial",,08,,.F.,,,,.F.,.F.)
Local oFonte3:= TFont():New( "Arial",,18,,.T.,,,,.F.,.F.)
Local oFonte4:= TFont():New( "Arial",,11,,.T.,,,,.F.,.F.)
Local cQuery := ""
Local cMsg   := ""
Local aMsgs  := {"","","","","","","","","","","",""}  // informado 12 mensagens no boleto
Local nTotReg:= 0
Local nMulta := 0
Local aAnexos:= {}
Local oDlgRes:= Nil
Local oLisRes:= Nil
Local aCoord := MsAdvSize(.T.)
Local i
Local nI       := 0
Local nAbatim  := 0
Local nAcresc  := 0
Local nDecres  := 0
Local nTipo	   := IIF(EMPTY(email),"1","2") //Envia boleto por e-mail
Local oDlgo
Local aDados
Local cDestEmail
Local cEmailExtra
Local llImpBol
Local _cTituloImp := ""  

Local _dLastDay	:= DTOS(LASTDAY(IIF(MONTH(DDATABASE)==1,STOD(STRZERO(YEAR(DDATABASE)-1,4)+"1201"),STOD(STRZERO(YEAR(DDATABASE),4)+STRZERO(MONTH(DDATABASE)-1,2)+"01"))))
Local _dFirstDay 	:= SUBSTR(_dLastDay,1,6)+"01"

Local cConta 	 	:= ""
Local cAgencia		:= ""

local aTit			:= {}
local aReg			:= {}

local cULTitulo		:= ""


Default aDados     	:= {}
Default cDestEmail 	:= ""
Default cEmailExtra	:= "tic@manfil.com.br"
Default llImpBol   	:= .F.

Private aPosicoes 		:= Array(76)
Private aValores 		:= Array(5)
Private cNossoNum		:= ''
Private cCodigoBarras   := ""
Private cLinhaDigitavel := ""
Private _lReimprime		:= .F.
Private _lPrimeira		:= .T.
Private cNNumImp 		:="" 
Private _nLin			:= 10 //-250



If Len(aValores) <= 0
	aValores := Array(5)
EndIf       

IF Upper(AllTrim(FunName())) <> "RFIN002"
	cCli1 := ""
	cCli2 := ""
	cBol1 := ""
	cBol2 := ""
ENDIF

if Select("TMPBOL1") > 0
	TMPBOL1->(dbCloseArea())
endif   

cQuery	:= 'exec dbo.PR_RD06003 @TITULOS = ' + chr(39) + cTitulos + chr(39)

TCQUERY cQuery NEW ALIAS 'TMPBOL1'
dbSelectArea('TMPBOL1')
TMPBOL1->(dbGoTop())
If TMPBOL1->(Eof())
	llImpBol := .F.
	MsgAlert("Título(s) não localizados com os parâmetros informados, possíveis causas:"+CHR(13)+ "   1. Título não está no borderô, procure o departamento financeiro"+CHR(13)+"   2. Algum dado informado nos parâmetros esta incorreto.")
	Return(Nil)

else
	While TMPBOL1->(!Eof())
	
		aReg	:= {}
		aadd(aReg,TMPBOL1->REGSE1)
		aadd(aReg,TMPBOL1->REGSEA)
		
		aadd(aTit,aReg)
	
		nTotReg++
		TMPBOL1->(dbSkip())
	EndDo
EndIf




//Valida o diretorio dos boletos
MakeDir("\BOLETOS_EMAIL\")
Private cPathInServer 	:= "\workflow\boletos_email\"
Private _cNomeArq		:= ''
Private _cArqLocal 		:= alltrim(GetTempPath())
Private _cAnexo := ""
//Inicializa o objeto do relatorio

TMPBOL1->(dbGoTop())
//_cNomeArq	:= AllTrim("BOLETO")+"_"+ DtoS(Date())+ "_"+StrTran(Time(),':','')
_cNomeArq := AllTrim("BOLETO")+"_"+cValToChar(TMPBOL1->REGSE1)
/*if FunName() = "MV05002"
	_cNomeArq	:= AllTrim("BOLETO")+"_"+ DtoS(Date())+ "_"+StrTran(Time(),':','')
else
	_cNomeArq	:= AllTrim("BOLETO")+"_"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO + "_" + DtoS(Date())+ "_"+StrTran(Time(),':','')
endif
*/
If nTipo == "1"
	lPreview := .T.
	//Alteracao Fabricio Antunes 29/10/19 para geracao automatica de denfe e boleto para Manfil
	//IF Alltrim(FunName()) == "MV05002"
//w	IF Valtype(lGerPDF) = "L"
		lAdjustToLegacy := .T. // Inibe legado de resolução com a TMSPrinter
		lDisableSetup   := .T.
		//lViewPDF        := .F.
		oPrint:= FWMSPrinter():New(_cNomeArq, IMP_PDF, lAdjustToLegacy, , lDisableSetup,,,,,,,plViewPDF)	
		oPrint:cPathPDF := "C:\TEMP\"
/*	Else //Final customziacao Fabricio
		oPrint := FWMSPrinter():New(_cNomeArq, IMP_PDF, .T.,_cArqLocal,.T.)  
	EndIF
*/	//	oPrint := FWMSPrinter():New(_cNomeArq, IMP_PDF, .T.,_cArqLocal,.T.)  	
	oPrint:SetPortrait()
	oPrint:SetPaperSize(9)
	oPrint:SetMargin(0,10,10,10) // Margem
	
	//oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, , lDisableSetup,,,,,,,lViewPDF)
Endif
	
ProcRegua(nTotReg)

TMPBOL1->(dbGoTop())
While TMPBOL1->(!Eof())
	
	
	//Posiciona nas tabelas em uso pelo boleto
	dbSelectArea("SE1")
	SE1->(dbGoTo(TMPBOL1->REGSE1))
	
	//Se envia por e-mail
	If nTipo == "2"
		//_cNomeArq := AllTrim("BOLETO")+"_"+SE1->E1_CLIENTE+"_" + DtoS(Date())+ "_"+StrTran(Time(),':','-')
		_cNomeArq := AllTrim("BOLETO")+"_"+cValToChar(TMPBOL1->REGSE1)
		lPreview := .T.
		//cPathInServer := SubStr(GetSrvProfString("RootPath",""),1,Len(GetSrvProfString("RootPath",""))-1)+"\workflow\boletos_email\"
		cPathInServer := "\workflow\boletos_email\"		
	//	oPrint:= TMSPrinter():New("Boleto Laser")
		oPrint := FWMSPrinter():New(_cNomeArq, IMP_PDF, .T.,cPathInServer,.T.,.F.,,,.T.,.F.,,.F.)  
		oPrint:SetPortrait()
		oPrint:SetPaperSize(9)
		oPrint:SetMargin(0,200,10,10) // Margem
	EndIf

	//Tabela de Borderos
	dbSelectArea("SEA")
	SEA->(dbGoTo(TMPBOL1->REGSEA))
	
	//Cadastro de Clientes
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA ))
	
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA ))
	

	IncProc("Gerando Boletos do Cliente "+Alltrim(SA1->A1_NOME))
	
	//Cadastro de parametros bancos
	dbSelectArea("SEE")
	SEE->(dbSetOrder(1))
	If !SEE->(dbSeek(xFilial("SEE")+SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON ))
		MsgAlert("Tabela de parametros bancarios nao localizada para o banco+agencia+conta (" + SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON + ")")
		TMPBOL1->(dbSkip())
		Loop
	EndIf

	cConta := STRZERO(VAL(SEE->EE_CONTA),5)+SEE->EE_DVCTA
	cAgencia := STRZERO(VAL(SEE->EE_AGENCIA),4) //Right(SEE->EE_AGENCIA,4)

	
	//Substitui as variaveis do boleto
	If Len(aDados) <= 0
		nAbatim     := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		nAcresc     := SE1->E1_ACRESC
		nDecres     := SE1->E1_DECRESC
		nSaldo      := SE1->E1_SALDO  
						

		nDescFin	:= 0 //SE1->E1_C_VDEFI
		aValores[1] := SE1->E1_VENCTO
		aValores[2] := nSaldo + nAcresc - nAbatim - nDecres
		aValores[3]	:= ""
		aValores[4]	:= ""
		aValores[5]	:= ""
		cDestEmail 	:= "renato.filho@manfil.com.br"	//SA1->A1_EMAIL			--> corrigir quando for para producao
		
		If Len(AllTrim(cEmailExtra)) <> 0
			cDestEmail := AllTrim(cDestEmail) + ";" + AllTrim(cEmailExtra)
		EndIf
	EndIf
	
	IF !Empty(SE1->E1_NUMBCO)	//_lReimprime	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia o controle de transacao.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodigoBarras   := SE1->E1_CODBAR
		cLinhaDigitavel := SE1->E1_CODDIG
	Else 
	   
		Begin Transaction
			//Gera a expressao numerica do codigo de barras e linha digitavel
			cCodigoBarras   := CodBarra_341() //CodigoBarras()
			SE1->(RecLock("SE1",.F.))
			SE1->E1_CODBAR := cCodigoBarras
			SE1->(MsUnlock())

			cLinhaDigitavel := LinhaDig_341() //&(SEE->EE_C_LINDI) //LinhaDigitavel(cCodigoBarras)
			SE1->(RecLock("SE1",.F.))
			SE1->E1_CODDIG := cLinhaDigitavel
			SE1->(MsUnlock())

			FIncLog()
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza o controle de transacao.                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		End Transaction
	
	EndIf    

	_cAux := Alltrim(cLinhaDigitavel)
	
	cLinhaDigitavel := Transform(SubStr(_cAux,1,10),"@R 99999.99999")
	cLinhaDigitavel += "  "+Transform(SubStr(_cAux,11,11),"@R 99999.999999")
	cLinhaDigitavel += "  "+Transform(SubStr(_cAux,22,11),"@R 99999.999999")
	cLinhaDigitavel += "  "+SubStr(_cAux,33,1)+"  "+Right(_cAux,14)       

	_cParcela := IIF(Empty(SE1->E1_PARCELA),"01",StrZero(Val(SE1->E1_PARCELA),2))
	nJuros :=  Round(((GETMV("CP_TXJURO")/100)/30)*SE1->E1_SALDO,2) //VAL(U___VLRCNAB(2))
	//nJuros :=  Round(nJuros/100,2)
	nMulta :=  Round((GETMV("CP_MULTA")/100)*SE1->E1_SALDO,2)
//	nMulta :=  Round((2/100)*SE1->E1_SALDO,2)
	//Formata as mensagens do boleto
	If !Empty(cCli1)// .and. !'MSG' $ cCli1
	   	aMsgs[1] := cCli1 // Pega do parametro MV_PAR09
	   	Else
	   	aMsgs[1] :=" "
	Endif   	
	If !Empty(cCli2)// .and. !"MSG" $ cCli2
	   	aMsgs[2] := cCli2 // Pega do parametro MV_PAR10
	   	Else
	   	aMsgs[2] :=" "
	Endif   	
	
	If !Empty(cBol1)// .and. ! "MSG" $ cBol1
	   	aMsgs[3] := cBol1 // Pega do parametro MV_PAR11
	   	Else
	   	aMsgs[3] :=" "
	Endif
	
	If !Empty(cBol2)// .and. ! "MSG" $ cBol2
	   	aMsgs[4] := cBol2 // Pega do parametro MV_PAR12
	   	Else
	   	aMsgs[4] :=" "
	Endif
	
	aMsgs[5] := "APÓS VENCIMENTO COBRAR JUROS POR DIA DE R$ " + TransForm(nJuros,"@E 9,999,999.99") 
	aMsgs[6] := "APÓS VENCIMENTO COBRAR MULTA DE         R$ " + TransForm(nMulta,"@E 9,999,999.99")

	//aMsgs[7] := "NÃO RECEBER APÓS 3 DIAS DA DATA DO VENCIMENTO"			  	
	aMsgs[7] := "NÃO RECEBER APÓS "+SEE->EE_DIASPRT+" DIAS DA DATA DO VENCIMENTO"			  	
	aMsgs[8] :=	"BORDERO: " + AllTrim(SE1->E1_NUMBOR)
	aMsgs[9] :=	"Nota Fiscal: " + AllTrim(SE1->E1_PREFIXO)+AllTrim(SE1->E1_NUM)
//	aMsgs[7] := "Sujeito a inclusão no SERASA/SPC ou protesto em 5 dias, Pgto exclusivo em banco. Não fazer pagto via DOC, TED, DEPOSITO, "
//	aMsgs[8] :=	"o sistema não identifica estes Pagtos. Não Pagar a TERCEIROS ou REPRESENTANTES."



	//Imprime o LAYOUT do boleto
	__LAYOUT(@oPrint)
	
	//Substitui os campos pelos conteudos
	oPrint:Say(_nLin+410,060,aValores[3],oFonte1)
	oPrint:Say(_nLin+460,060,aValores[4],oFonte1)
	oPrint:Say(_nLin+510,060,aValores[5],oFonte1)
	
//	oPrint:Say(aPosicoes[POS_CEDENTE1 ,1],aPosicoes[POS_CEDENTE1 ,2],UpPer(AllTrim(SM0->M0_NOMECOM)) + "- CNPJ: " + TransForm(_cCNPJ,"@R 99.999.999/9999-99")   ,oFonte1)
// 	oPrint:Say(_nLin+211 ,60,UpPer(AllTrim(SM0->M0_ENDENT))+"  "+UpPer(AllTrim(SM0->M0_CIDENT))   ,oFonte1)
/*
   	IF SEE->EE_CODIGO == "756"
//   		oPrint:Say(_nLin+aPosicoes[POS_AGENCOB ,1],aPosicoes[POS_AGENCOB ,2],SubStr(SEA->EA_AGEDEP,1,4)+ "-" +SubStr(SEA->EA_AGEDEP,5,1)+"/"+StrZero(Val(SubStr(AllTrim(SEE->EE_CODEMP),1,LEN(AllTrim(SEE->EE_CODEMP))-1)),7)+ "-" +SubStr(SEE->EE_CODEMP,LEN(AllTrim(SEE->EE_CODEMP)),1),oFonte4)
//		oPrint:Say(aPosicoes[POS_AGENCOB ,1],aPosicoes[POS_AGENCOB ,2],SubStr(SEA->EA_AGEDEP,1,4)+ "/"+StrZero(Val(SubStr(AllTrim(SEE->EE_CODEMP),1,LEN(AllTrim(SEE->EE_CODEMP))-1)),7)+ "-" +SubStr(SEE->EE_CODEMP,LEN(AllTrim(SEE->EE_CODEMP)),1),oFonte4)   		
   	ELSEIF SEE->EE_CODIGO == "104"                                                                                                                                                                                                                                                                     
   		oPrint:Say(aPosicoes[POS_AGENCOB ,1],aPosicoes[POS_AGENCOB ,2],ALLTRIM(SEA->EA_AGEDEP)+"/"+StrZero(Val(SubStr(AllTrim(SEE->EE_CODEMP),1,LEN(AllTrim(SEE->EE_CODEMP))-1)),7)+ "-" +SubStr(SEE->EE_CODEMP,LEN(AllTrim(SEE->EE_CODEMP)),1),oFonte4)
    ELSE
		oPrint:Say(aPosicoes[POS_AGENCOB  ,1],aPosicoes[POS_AGENCOB  ,2],SubStr(SEA->EA_AGEDEP,1,4)+ "-" +SubStr(SEA->EA_AGEDEP,5,1)+"/"+StrZero(Val(SubStr(AllTrim(SEA->EA_NUMCON),1,LEN(AllTrim(SEA->EA_NUMCON))-1)),7)+ "-" +SubStr(SEA->EA_NUMCON,LEN(AllTrim(SEA->EA_NUMCON)),1),oFonte4)
    ENDIF
   	IF SEE->EE_CODIGO == "237" 
		oPrint:Say(aPosicoes[POS_NUMTIT1  ,1],aPosicoes[POS_NUMTIT1  ,2],AllTrim(SEE->EE_CODCART)+"/"+SubStr(SE1->E1_NUMBCO,1,11)+"-"+SubStr(SE1->E1_NUMBCO,12,1),oFonte4)
	ELSEIF SEE->EE_CODIGO == "756" 
//   		oPrint:Say(aPosicoes[POS_NUMTIT1  ,1],aPosicoes[POS_NUMTIT1  ,2],SubStr(SE1->E1_NUMBCO,1,7)+"-"+SubStr(SE1->E1_NUMBCO,8,1),oFonte4)
   	ELSEIF SEE->EE_CODIGO == "341" 
		oPrint:Say(aPosicoes[POS_NUMTIT1  ,1],aPosicoes[POS_NUMTIT1  ,2],SubStr(SE1->E1_NUMBCO,1,3)+"/"+SubStr(SE1->E1_NUMBCO,4,8)+"-"+SubStr(SE1->E1_NUMBCO,12,1),oFonte4)
	ELSEIF SEE->EE_CODIGO == "033" 
   		oPrint:Say(aPosicoes[POS_NUMTIT1  ,1],aPosicoes[POS_NUMTIT1  ,2],SubStr(SE1->E1_NUMBCO,1,12)+"-"+SubStr(SE1->E1_NUMBCO,13,1),oFonte4)
	ELSEIF SEE->EE_CODIGO == "001" 
   		oPrint:Say(aPosicoes[POS_NUMTIT1  ,1],aPosicoes[POS_NUMTIT1  ,2],SubStr(SE1->E1_NUMBCO,1,11)+"-"+SubStr(SE1->E1_NUMBCO,12,1),oFonte4)
	ELSEIF SEE->EE_CODIGO == "104" 
   		oPrint:Say(aPosicoes[POS_NUMTIT1  ,1],aPosicoes[POS_NUMTIT1  ,2],SubStr(SE1->E1_NUMBCO,1,2)+"/"+SubStr(SE1->E1_NUMBCO,3,15)+"-"+SubStr(SE1->E1_NUMBCO,18,1),oFonte4)
	ELSE
   		oPrint:Say(aPosicoes[POS_NUMTIT1  ,1],aPosicoes[POS_NUMTIT1  ,2],SubStr(SE1->E1_NUMBCO,1,Len(AllTrim(SE1->E1_NUMBCO))),oFonte4)
	ENDIF
*/
//	oPrint:Say(aPosicoes[POS_VENCTIT1 ,1],aPosicoes[POS_VENCTIT1 ,2],SUBSTR(DtoC(aValores[1]),1,6)+"20"+SUBSTR(DtoC(aValores[1]),7,8)            ,oFonte4)
//	oPrint:Say(aPosicoes[POS_NUMDOC,1],aPosicoes[POS_NUMDOC   ,2],AllTrim(SE1->E1_SERIE)+"/"+ALLTRIM(SE1->E1_NUM)+" / Parc: "+ALLTRIM(_cParcela),oFonte4)
//	oPrint:Say(aPosicoes[POS_SACADO1  ,1],aPosicoes[POS_SACADO1  ,2],UpPer(AllTrim(SA1->A1_NOME)) + ' - ' + SA1->A1_COD ,oFonte4)
//	oPrint:Say(aPosicoes[POS_DTENTREGA,1],aPosicoes[POS_DTENTREGA,2],SUBSTR(DtoC(dDataBase),1,6)+"20"+SUBSTR(DtoC(dDataBase),7,8)                          ,oFonte4)
//	oPrint:Say(aPosicoes[POS_VALDOCTO ,1],aPosicoes[POS_VALDOCTO ,2],TransForm(aValores[2],"@E 9,999,999.99"),oFonte4)
	oPrint:Say(aPosicoes[POS_LINDG1   ,1],aPosicoes[POS_LINDG1   ,2],cLinhaDigitavel                         ,oFonte3)
   	IF SEE->EE_CODIGO == "237"
   		oPrint:Say(aPosicoes[POS_LOCPAGTO1,1],aPosicoes[POS_LOCPAGTO1,2],"Pagável preferencialmente na Rede Bradesco ou Bradesco Expresso",oFonte1)
   	ELSEIF SEE->EE_CODIGO == "104"
		oPrint:Say(aPosicoes[POS_LOCPAGTO1,1],aPosicoes[POS_LOCPAGTO1,2],"PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE",oFonte1)
   	ELSEIF SEE->EE_CODIGO == "341"
		oPrint:Say(aPosicoes[POS_LOCPAGTO1,1],aPosicoes[POS_LOCPAGTO1,2],"ATÉ O VENCIMENTO EM QUALQUER BANCO OU CORRESPONDENTE NÃO BANCÁRIO. APÓS O VENCIMENTO,",oFonte1)
		oPrint:Say(aPosicoes[POS_LOCPAGTO1,1]+30,aPosicoes[POS_LOCPAGTO1,2],"ACESSO ITAU.COM.BR/BOLETOS E PAGUE EM QUALQUER BANCO OU CORRESPONDENTE NÃO BANCÁRIO.",oFonte1)		

   	ELSE	
		oPrint:Say(aPosicoes[POS_LOCPAGTO1,1],aPosicoes[POS_LOCPAGTO1,2],"ATÉ O VENCIMENTO PAGÁVEL EM QUALQUER AGÊNCIA BANCÁRIA.",oFonte4)
	ENDIF
	oPrint:Say(aPosicoes[POS_VENCTIT2 ,1],aPosicoes[POS_VENCTIT2 ,2],SUBSTR(DtoC(aValores[1]),1,6)+SUBSTR(DtoC(aValores[1]),7,8)              ,oFonte3,,,,1)
	oPrint:Say(aPosicoes[POS_SACADO2 ,1],aPosicoes[POS_SACADO2 ,2],UpPer(AllTrim(SM0->M0_NOMECOM)) + Space (10) + " CNPJ: " + TransForm(SM0->M0_CGC,"@R 99.999.999/9999-99")  ,oFonte1)

	oPrint:Say(aPosicoes[POS_SACADO2	,1]+30,aPosicoes[POS_SACADO2	,2],AllTrim(SM0->M0_ENDCOB) + " - " + AllTrim(SM0->M0_BAIRCOB) + " CEP: " + TransForm(SM0->M0_CEPCOB,"@R 99999-999") + " - " + AllTrim(SM0->M0_CIDCOB) + " - " + SM0->M0_ESTCOB,oFonte1)

//	oPrint:Say(aPosicoes[POS_CEDENTE2 ,1],aPosicoes[POS_CEDENTE2 ,2],UpPer(AllTrim(SA1->A1_NOME)) + ' - ' + SA1->A1_COD + Space (10) + " CNPJ/CPF: " + Iif(Len(AllTrim(SA1->A1_CGC)) <= 11,TransForm(SA1->A1_CGC,"@R 999.999.999-99"),TransForm(SA1->A1_CGC,"@R 99.999.999/9999-99")) ,oFonte4) //ALTERACAO VINICIUS

	IF SEE->EE_CODIGO == "341"
		oPrint:Say(aPosicoes[POS_AGENCOB2 ,1],aPosicoes[POS_AGENCOB2 ,2],cAgencia+ "/"+LEFT(cConta,5)+ "-" +RIGHT(cConta,1),oFonte4,,,,1)
//		oPrint:Say(aPosicoes[POS_AGENCOB2 ,1],aPosicoes[POS_AGENCOB2 ,2],SubStr(SEA->EA_AGEDEP,1,4)+ "/"+StrZero(Val(SubStr(AllTrim(SEA->EA_NUMCON),1,LEN(AllTrim(SEA->EA_NUMCON))-1)),7)+ "-" +SubStr(SEA->EA_NUMCON,LEN(AllTrim(SEA->EA_NUMCON)),1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "104"
		oPrint:Say(aPosicoes[POS_AGENCOB2 ,1],aPosicoes[POS_AGENCOB2 ,2],SubStr(SEA->EA_AGEDEP,1,4)+ "/"+SubStr(AllTrim(SEE->EE_CODEMP),1,LEN(AllTrim(SEE->EE_CODEMP))-1)+ "-" +SubStr(SEE->EE_CODEMP,LEN(AllTrim(SEE->EE_CODEMP)),1),oFonte4,,,,1)

	ELSEIF SEE->EE_CODIGO == "033"
   		oPrint:Say(aPosicoes[POS_AGENCOB2 ,1],aPosicoes[POS_AGENCOB2 ,2],ALLTRIM(SEA->EA_AGEDEP)+" / 3405613",oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "756"
	oPrint:Say(aPosicoes[POS_AGENCOB2 ,1],aPosicoes[POS_AGENCOB2 ,2],SubStr(SEA->EA_AGEDEP,1,4)+ "/"+StrZero(Val(SubStr(AllTrim(SEE->EE_CODEMP),1,LEN(AllTrim(SEE->EE_CODEMP))-1)),7)+ "-" +SubStr(SEE->EE_CODEMP,LEN(AllTrim(SEE->EE_CODEMP)),1),oFonte4,,,,1)

	ELSE
		oPrint:Say(aPosicoes[POS_AGENCOB2 ,1],aPosicoes[POS_AGENCOB2 ,2],SubStr(SEA->EA_AGEDEP,1,4)+ "-" +SubStr(SEA->EA_AGEDEP,5,1)+"/"+StrZero(Val(SubStr(AllTrim(SEA->EA_NUMCON),1,LEN(AllTrim(SEA->EA_NUMCON))-1)),7)+ "-" +SubStr(SEA->EA_NUMCON,LEN(AllTrim(SEA->EA_NUMCON)),1),oFonte4,,,,1)
	ENDIF
	_cTituloImp := ALLTRIM(SE1->E1_NUM)+" / Parc: "+ALLTRIM(_cParcela)

	oPrint:Say(aPosicoes[POS_DTDOC1   ,1],aPosicoes[POS_DTDOC1   ,2],SUBSTR(DtoC(SE1->E1_EMISSAO),1,6)+SUBSTR(DtoC(SE1->E1_EMISSAO),7,8)                   ,oFonte4)
	oPrint:Say(aPosicoes[POS_NRODOC1  ,1],aPosicoes[POS_NRODOC1  ,2],_cTituloImp,oFonte4)
	oPrint:Say(aPosicoes[POS_ESPECDOC1,1],aPosicoes[POS_ESPECDOC1,2],"DM",oFonte4)
	oPrint:Say(aPosicoes[POS_ACEITE1  ,1],aPosicoes[POS_ACEITE1  ,2],"NÂO",oFonte4)
	oPrint:Say(aPosicoes[POS_DTPROC1  ,1],aPosicoes[POS_DTPROC1  ,2],SUBSTR(DtoC(dDataBase),1,6)+SUBSTR(DtoC(dDataBase),7,8) ,oFonte4)
	IF SEE->EE_CODIGO == "237" 
   		oPrint:Say(aPosicoes[POS_NUMTIT2  ,1],aPosicoes[POS_NUMTIT2  ,2],AllTrim(SEE->EE_CODCART)+"/"+SubStr(SE1->E1_NUMBCO,1,11)+"-"+SubStr(SE1->E1_NUMBCO,12,1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "756" 
		oPrint:Say(aPosicoes[POS_NUMTIT2  ,1],aPosicoes[POS_NUMTIT2  ,2],SubStr(SE1->E1_NUMBCO,1,7)+"-"+SubStr(SE1->E1_NUMBCO,8,1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "341" 
   		oPrint:Say(aPosicoes[POS_NUMTIT2  ,1],aPosicoes[POS_NUMTIT2  ,2],SubStr(SE1->E1_NUMBCO,1,3)+"/"+SubStr(SE1->E1_NUMBCO,4,8)+"-"+SubStr(SE1->E1_NUMBCO,12,1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "033" 
   		oPrint:Say(aPosicoes[POS_NUMTIT2  ,1],aPosicoes[POS_NUMTIT2  ,2],SubStr(SE1->E1_NUMBCO,1,12)+"-"+SubStr(SE1->E1_NUMBCO,13,1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "001" 
   		oPrint:Say(aPosicoes[POS_NUMTIT2  ,1],aPosicoes[POS_NUMTIT2  ,2],SubStr(SE1->E1_NUMBCO,1,11)+"-"+SubStr(SE1->E1_NUMBCO,12,1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "104" 
   		oPrint:Say(aPosicoes[POS_NUMTIT2  ,1],aPosicoes[POS_NUMTIT2  ,2],SubStr(SE1->E1_NUMBCO,1,2)+"/"+SubStr(SE1->E1_NUMBCO,3,15)+"-"+SubStr(SE1->E1_NUMBCO,18,1),oFonte4,,,,1)

	ELSE
   		oPrint:Say(aPosicoes[POS_NUMTIT2  ,1],aPosicoes[POS_NUMTIT2  ,2],SubStr(SE1->E1_NUMBCO,1,Len(AllTrim(SE1->E1_NUMBCO))),oFonte4,,,,1)
	ENDIF
	oPrint:Say(aPosicoes[POS_CARTEIRA1,1],aPosicoes[POS_CARTEIRA1,2],AllTrim(SEE->EE_CODCART),oFonte4) //SEE->EE_C_CARBO
	oPrint:Say(aPosicoes[POS_ESPECIE1 ,1],aPosicoes[POS_ESPECIE1 ,2],"R$",oFonte4) //#CLAUDIO
	oPrint:Say(aPosicoes[POS_VLRDOC1  ,1],aPosicoes[POS_VLRDOC1  ,2],AllTrim(TransForm(aValores[2],"@E 9,999,999.99")),oFonte3,,,,1)

	IF SEE->EE_CODIGO <> "104" //SEE->EE_CODIGO <> "237" .or. 
		oPrint:Say(aPosicoes[POS_VALOR1   ,1],aPosicoes[POS_VALOR1  ,2],AllTrim(TransForm(aValores[2],"@E 9,999,999.99")),oFonte4)
	endif

	oPrint:Say(aPosicoes[POS_MEN1_1   ,1],aPosicoes[POS_MEN1_1   ,2],SubStr(aMsgs[1],1,75),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN1_2   ,1],aPosicoes[POS_MEN1_2   ,2],SubStr(aMsgs[2],1,75),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN1_3   ,1],aPosicoes[POS_MEN1_3   ,2],SubStr(aMsgs[3],1,95),oFonte1)
    oPrint:Say(aPosicoes[POS_MEN1_4   ,1],aPosicoes[POS_MEN1_4   ,2],SubStr(aMsgs[4],1,95),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN1_5   ,1],aPosicoes[POS_MEN1_5   ,2],SubStr(aMsgs[5],1,95),oFonte1)
    oPrint:Say(aPosicoes[POS_MEN1_6   ,1],aPosicoes[POS_MEN1_6   ,2],SubStr(aMsgs[6],1,120),oFonte1)
    oPrint:Say(aPosicoes[POS_MEN1_7   ,1],aPosicoes[POS_MEN1_7   ,2],SubStr(aMsgs[7],1,120),oFonte1)
    oPrint:Say(aPosicoes[POS_MEN1_8   ,1],aPosicoes[POS_MEN1_8   ,2],SubStr(aMsgs[8],1,120),oFonte1)    
	oPrint:Say(aPosicoes[POS_MEN1_9   ,1],aPosicoes[POS_MEN1_9   ,2],SubStr(aMsgs[9],1,95),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN1_10  ,1],aPosicoes[POS_MEN1_10  ,2],SubStr(aMsgs[10],1,95),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN1_11  ,1],aPosicoes[POS_MEN1_11  ,2],SubStr(aMsgs[11],1,95),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN1_12  ,1],aPosicoes[POS_MEN1_12  ,2],SubStr(aMsgs[12],1,95),oFonte1)
	oPrint:Say(aPosicoes[POS_CEDENTE2	,1],aPosicoes[POS_CEDENTE2	,2],UpPer(AllTrim(SA1->A1_NOME) + ' - ' + SA1->A1_COD + Space(10)+Iif(Len(AllTrim(SA1->A1_CGC)) <= 11,"CPF: "+TransForm(SA1->A1_CGC,"@R 999.999.999-99"),"CNPJ: "+TransForm(SA1->A1_CGC,"@R 99.999.999/9999-99"))),oFonte4)
//	oPrint:Say(aPosicoes[POS_CEDCNPJ2	,1],aPosicoes[POS_CEDCNPJ2	,2],Iif(Len(AllTrim(SA1->A1_CGC)) <= 11,TransForm(SA1->A1_CGC,"@R 999.999.999-99"),TransForm(SA1->A1_CGC,"@R 99.999.999/9999-99")),oFonte1)
//	oPrint:Say(aPosicoes[POS_CEDCNPJ2	,1],aPosicoes[POS_CEDCNPJ2	,2],TransForm(_cCNPJ,"@R 99.999.999/9999-99"),oFonte1)
//	oPrint:Say(aPosicoes[POS_CEDEND2	,1],aPosicoes[POS_CEDEND2	,2],Iif(Empty(SA2->A2_C_END),AllTrim(SA2->A2_END),AllTrim(SA2->A2_C_END)) + " - " + AllTrim(SA2->A2_C_BAIRR) + " CEP: " + TransForm(SA2->A2_C_CEP,"@R 99999-999") + " - " + AllTrim(SA2->A2_C_MUN) + " - " + SA2->A2_C_EST,oFonte4)
	_cEndCob:= Iif(Empty(SA1->A1_ENDCOB),AllTrim(SA1->A1_END),AllTrim(SA1->A1_ENDCOB)) + " - "
	_cEndCob+= Iif(Empty(SA1->A1_BAIRROC),AllTrim(SA1->A1_BAIRRO),AllTrim(SA1->A1_BAIRROC)) + " - " 
	_cEndCob+= " CEP: "+ Iif(Empty(SA1->A1_CEPC),TransForm(SA1->A1_CEP,"@R 99999-999"),TransForm(SA1->A1_CEPC,"@R 99999-999")) + " - " 
	_cEndCob+= Iif(Empty(SA1->A1_MUNC),AllTrim(SA1->A1_MUN),AllTrim(SA1->A1_MUNC)) + " - "
	_cEndCob+= Iif(Empty(SA1->A1_ESTC),SA1->A1_EST,SA1->A1_ESTC)
	oPrint:Say(aPosicoes[POS_CEDEND2	,1],aPosicoes[POS_CEDEND2	,2],_cEndCob,oFonte4)
//	oPrint:Say(aPosicoes[POS_CEDEND2	,1],aPosicoes[POS_CEDEND2	,2],AllTrim(SM0->M0_ENDCOB) + " - " + AllTrim(SM0->M0_BAIRCOB) + " CEP: " + TransForm(SM0->M0_CEPCOB,"@R 99999-999") + " - " + AllTrim(SM0->M0_CIDCOB) + " - " + SM0->M0_ESTCOB,oFonte1)
	oPrint:Say(aPosicoes[POS_LINDG2   ,1],aPosicoes[POS_LINDG2   ,2],cLinhaDigitavel,oFonte3)     

	IF SEE->EE_CODIGO == "237"
		oPrint:Say(aPosicoes[POS_LOCPAGTO2,1],aPosicoes[POS_LOCPAGTO2,2],"Pagável preferencialmente na Rede Bradesco ou Bradesco Expresso.",oFonte4)
   	ELSEIF SEE->EE_CODIGO == "104"
		oPrint:Say(aPosicoes[POS_LOCPAGTO2,1],aPosicoes[POS_LOCPAGTO2,2],"PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE",oFonte1)
   	ELSEIF SEE->EE_CODIGO == "341"
		oPrint:Say(aPosicoes[POS_LOCPAGTO2,1],aPosicoes[POS_LOCPAGTO2,2],"ATÉ O VENCIMENTO EM QUALQUER BANCO OU CORRESPONDENTE NÃO BANCÁRIO. APÓS O VENCIMENTO,",oFonte1)
		oPrint:Say(aPosicoes[POS_LOCPAGTO2,1]+30,aPosicoes[POS_LOCPAGTO2,2],"ACESSO ITAU.COM.BR/BOLETOS E PAGUE EM QUALQUER BANCO OU CORRESPONDENTE NÃO BANCÁRIO.",oFonte1)		

	ELSE
		oPrint:Say(aPosicoes[POS_LOCPAGTO2,1],aPosicoes[POS_LOCPAGTO2,2],"ATÉ O VENCIMENTO PAGÁVEL EM QUALQUER AGÊNCIA BANCÁRIA.",oFonte4)
	ENDIF

	oPrint:Say(aPosicoes[POS_VENCTIT3 ,1],aPosicoes[POS_VENCTIT3 ,2],SUBSTR(DtoC(aValores[1]),1,6)+SUBSTR(DtoC(aValores[1]),7,8),oFonte3,,,,1)
	oPrint:Say(aPosicoes[POS_CEDENTE3 ,1],aPosicoes[POS_CEDENTE3 ,2],UpPer(AllTrim(SM0->M0_NOMECOM))  + Space (10) + " CNPJ: " + TransForm(AllTrim(SM0->M0_CGC),"@R 99.999.999/9999-99")   ,oFonte4)

//	oPrint:Say(aPosicoes[POS_CEDENTE3 ,1],aPosicoes[POS_CEDENTE3 ,2],UpPer(AllTrim(SA1->A1_NOME))  + Space (10) + " CNPJ/CPF: " + Iif(Len(AllTrim(SA1->A1_CGC)) <= 11,TransForm(SA1->A1_CGC,"@R 999.999.999-99"),TransForm(SA1->A1_CGC,"@R 99.999.999/9999-99")) ,oFonte4) //ALTERACAO VINICIUS
	oPrint:Say(aPosicoes[POS_CEDENTE3	,1]+30,aPosicoes[POS_CEDENTE3	,2],AllTrim(SM0->M0_ENDCOB) + " - " + AllTrim(SM0->M0_BAIRCOB) + " CEP: " + TransForm(SM0->M0_CEPCOB,"@R 99999-999") + " - " + AllTrim(SM0->M0_CIDCOB) + " - " + SM0->M0_ESTCOB,oFonte1)

	IF SEE->EE_CODIGO == "341"
		oPrint:Say(aPosicoes[POS_AGENCOB3 ,1],aPosicoes[POS_AGENCOB3 ,2],cAgencia+ "/"+LEFT(cConta,5)+ "-" +RIGHT(cConta,1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "104"
		oPrint:Say(aPosicoes[POS_AGENCOB3 ,1],aPosicoes[POS_AGENCOB3 ,2],SubStr(SEA->EA_AGEDEP,1,4)+ "/"+SubStr(AllTrim(SEE->EE_CODEMP),1,LEN(AllTrim(SEE->EE_CODEMP))-1)+ "-" +SubStr(SEE->EE_CODEMP,LEN(AllTrim(SEE->EE_CODEMP)),1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "033"
   		oPrint:Say(aPosicoes[POS_AGENCOB3 ,1],aPosicoes[POS_AGENCOB3 ,2],ALLTRIM(SEA->EA_AGEDEP)+" / 3405613",oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "756"
		oPrint:Say(aPosicoes[POS_AGENCOB3 ,1],aPosicoes[POS_AGENCOB3 ,2],SubStr(SEA->EA_AGEDEP,1,4)+ "/"+StrZero(Val(SubStr(AllTrim(SEE->EE_CODEMP),1,LEN(AllTrim(SEE->EE_CODEMP))-1)),7)+ "-" +SubStr(SEE->EE_CODEMP,LEN(AllTrim(SEE->EE_CODEMP)),1),oFonte4,,,,1)
	ELSE
		oPrint:Say(aPosicoes[POS_AGENCOB3 ,1],aPosicoes[POS_AGENCOB3 ,2],SubStr(SEA->EA_AGEDEP,1,4)+ "-" +SubStr(SEA->EA_AGEDEP,5,1)+"/"+StrZero(Val(SubStr(AllTrim(SEA->EA_NUMCON),1,LEN(AllTrim(SEA->EA_NUMCON))-1)),7)+ "-" +SubStr(SEA->EA_NUMCON,LEN(AllTrim(SEA->EA_NUMCON)),1),oFonte4,,,,1)
	ENDIF
	oPrint:Say(aPosicoes[POS_DTDOC2   ,1],aPosicoes[POS_DTDOC2   ,2],SUBSTR(DtoC(SE1->E1_EMISSAO),1,6)+SUBSTR(DtoC(SE1->E1_EMISSAO),7,8)   ,oFonte4)
	oPrint:Say(aPosicoes[POS_NRODOC2  ,1],aPosicoes[POS_NRODOC2  ,2],_cTituloImp,oFonte4)
	oPrint:Say(aPosicoes[POS_ESPECDOC2,1],aPosicoes[POS_ESPECDOC2,2],"DM",oFonte4)
	oPrint:Say(aPosicoes[POS_ACEITE2  ,1],aPosicoes[POS_ACEITE2  ,2],"NÃO",oFonte4)
	oPrint:Say(aPosicoes[POS_DTPROC2  ,1],aPosicoes[POS_DTPROC2  ,2],SUBSTR(DtoC(dDataBase),1,6)+SUBSTR(DtoC(dDataBase),7,8)        ,oFonte1)
	IF SEE->EE_CODIGO == "237" 
		oPrint:Say(aPosicoes[POS_NUMTIT3  ,1],aPosicoes[POS_NUMTIT3  ,2],AllTrim(SEE->EE_CODCART)+"/"+SubStr(SE1->E1_NUMBCO,1,11)+"-"+SubStr(SE1->E1_NUMBCO,12,1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "104" 
		oPrint:Say(aPosicoes[POS_NUMTIT3  ,1],aPosicoes[POS_NUMTIT3  ,2],SubStr(SE1->E1_NUMBCO,1,2)+"/"+SubStr(SE1->E1_NUMBCO,3,15)+"-"+SubStr(SE1->E1_NUMBCO,18,1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "756" 
   		oPrint:Say(aPosicoes[POS_NUMTIT3  ,1],aPosicoes[POS_NUMTIT3  ,2],SubStr(SE1->E1_NUMBCO,1,7)+"-"+SubStr(SE1->E1_NUMBCO,8,1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "341" 
   		oPrint:Say(aPosicoes[POS_NUMTIT3  ,1],aPosicoes[POS_NUMTIT3  ,2],SubStr(SE1->E1_NUMBCO,1,3)+"/"+SubStr(SE1->E1_NUMBCO,4,8)+"-"+SubStr(SE1->E1_NUMBCO,12,1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "033" 
   		oPrint:Say(aPosicoes[POS_NUMTIT3  ,1],aPosicoes[POS_NUMTIT3  ,2],SubStr(SE1->E1_NUMBCO,1,12)+"-"+SubStr(SE1->E1_NUMBCO,13,1),oFonte4,,,,1)
	ELSEIF SEE->EE_CODIGO == "001" 
   		oPrint:Say(aPosicoes[POS_NUMTIT3  ,1],aPosicoes[POS_NUMTIT3  ,2],SubStr(SE1->E1_NUMBCO,1,11)+"-"+SubStr(SE1->E1_NUMBCO,12,1),oFonte4,,,,1)
	ELSE
   		oPrint:Say(aPosicoes[POS_NUMTIT3  ,1],aPosicoes[POS_NUMTIT3  ,2],SubStr(SE1->E1_NUMBCO,1,Len(AllTrim(SE1->E1_NUMBCO))),oFonte4,,,,1)
	ENDIF
	oPrint:Say(aPosicoes[POS_CARTEIRA2,1],aPosicoes[POS_CARTEIRA2,2],AllTrim(SEE->EE_CODCART),oFonte4) //SEE->EE_C_CARBO
	oPrint:Say(aPosicoes[POS_ESPECIE2 ,1],aPosicoes[POS_ESPECIE2 ,2],"R$",oFonte4)  //#CLAUDIO

	IF SEE->EE_CODIGO <> "104"  //SEE->EE_CODIGO <> "237" .or. 
		oPrint:Say(aPosicoes[POS_VALOR2   ,1],aPosicoes[POS_VALOR2   ,2],AllTrim(TransForm(aValores[2],"@E 9,999,999.99")),oFonte4)
	ENDIF

	oPrint:Say(aPosicoes[POS_VLRDOC2  ,1],aPosicoes[POS_VLRDOC2  ,2],AllTrim(TransForm(aValores[2],"@E 9,999,999.99")),oFonte3,,,,1)

	oPrint:Say(aPosicoes[POS_MEN2_1   ,1],aPosicoes[POS_MEN2_1   ,2],SubStr(aMsgs[1],1,75),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN2_2   ,1],aPosicoes[POS_MEN2_2   ,2],SubStr(aMsgs[2],1,75),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN2_3   ,1],aPosicoes[POS_MEN2_3   ,2],SubStr(aMsgs[3],1,95),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN2_4   ,1],aPosicoes[POS_MEN2_4   ,2],SubStr(aMsgs[4],1,95),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN2_5   ,1],aPosicoes[POS_MEN2_5   ,2],SubStr(aMsgs[5],1,95),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN2_6   ,1],aPosicoes[POS_MEN2_6   ,2],SubStr(aMsgs[6],1,120),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN2_7   ,1],aPosicoes[POS_MEN2_7   ,2],SubStr(aMsgs[7],1,120),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN2_8   ,1],aPosicoes[POS_MEN2_8   ,2],SubStr(aMsgs[8],1,120),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN2_9   ,1],aPosicoes[POS_MEN2_9   ,2],SubStr(aMsgs[9],1,95),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN2_10  ,1],aPosicoes[POS_MEN2_10  ,2],SubStr(aMsgs[10],1,95),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN2_11  ,1],aPosicoes[POS_MEN2_11  ,2],SubStr(aMsgs[11],1,95),oFonte1)
	oPrint:Say(aPosicoes[POS_MEN2_12  ,1],aPosicoes[POS_MEN2_12  ,2],SubStr(aMsgs[12],1,95),oFonte1)	
	oPrint:Say(aPosicoes[POS_SAC2     ,1],aPosicoes[POS_SAC2     ,2],SA1->A1_NOME + ' - ' + Alltrim(SA1->A1_COD)+ Space(10)+Iif(Len(AllTrim(SA1->A1_CGC)) <= 11,"CPF: "+TransForm(SA1->A1_CGC,"@R 999.999.999-99"),"CNPJ: "+TransForm(SA1->A1_CGC,"@R 99.999.999/9999-99")),oFonte1)

	_cEndCob:= Iif(Empty(SA1->A1_ENDCOB),AllTrim(SA1->A1_END),AllTrim(SA1->A1_ENDCOB)) + " - "
	_cEndCob+= Iif(Empty(SA1->A1_BAIRROC),AllTrim(SA1->A1_BAIRRO),AllTrim(SA1->A1_BAIRROC)) + " - " 
	_cEndCob+= " CEP: "+ Iif(Empty(SA1->A1_CEPC),TransForm(SA1->A1_CEP,"@R 99999-999"),TransForm(SA1->A1_CEPC,"@R 99999-999")) + " - " 
	_cEndCob+= Iif(Empty(SA1->A1_MUNC),AllTrim(SA1->A1_MUN),AllTrim(SA1->A1_MUNC)) + " - "
	_cEndCob+= Iif(Empty(SA1->A1_ESTC),SA1->A1_EST,SA1->A1_ESTC)
	oPrint:Say(aPosicoes[POS_END2	,1],aPosicoes[POS_END2	,2],_cEndCob,oFonte4)
//	oPrint:Say(aPosicoes[POS_END2     ,1],aPosicoes[POS_END2    ,2], Iif(Empty(SA2->A2_C_END),AllTrim(SA2->A2_END),AllTrim(SA2->A2_C_END)) + " - " + AllTrim(SA2->A2_C_BAIRR) + " CEP: " + TransForm(SA2->A2_C_CEP,"@R 99999-999") + " - " + AllTrim(SA2->A2_C_MUN) + " - " + SA2->A2_C_EST,oFonte1)
	//MSBAR("INT25",26.0,1,cCodigoBarras,oPrint,.F.,Nil,Nil,0.025,1.3,.T.,Nil,"A",.F.)
	//oPrint:FWMSBAR("INT25"/*cTypeBar*/,66.0/*nRow*/ ,1/*nCol*/, cCodigoBarras/*cCode*/,oPrint/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.025/*nWidth*/,1.5/*nHeigth*/,.T./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.T./*lCmtr2Pix*/	)
	oPrint:Int25(_nLin+2675,90/*26.25*/,cCodigoBarras,0.765897/*0.87*/,32.00,.F., .F. )
	//Salva a imagem para envio do emaily
	If nTipo == "2"
		oPrint:EndPage()
		oPrint:Preview()
        _cAnexo := cPathInServer+_cNomeArq+".PDF"
        //Funcao que copia o arquivo da pasta do cliente para o servidor
		If CPYT2S(_cArqLocal+_cNomeArq+".pdf",cPathInServer,.F.)
			If u_zEnvMail(cDestEmail, "Teste", "Teste TMailMessage - Protheus", , .T.)
//			If WFBOLETO(Alltrim(SA1->A1_EMAIL)+";renato.filho@manfil.com.br",SA1->A1_NOME,_cTituloImp,_cAnexo)	
				IF ALLTRIM(FUNNAME()) <> "AGLT044"
			   		MsgInfo("E-mail enviado com sucesso para o endereço: "+Alltrim(SA1->A1_EMAIL))
			 	ENDIF
			EndIf		
			FERASE(_cAnexo) //Apaga aruqivo no servidor
		Else
			Alert("Falha ao copiar arquivo PDF do boleto, o e-mail não será enviado!")
			FError() //mostra o erro ocorrido na copia do arquivo
		EndIf

//		AAdd(aAnexos,{	cPathInServer+AllTrim(cNomeArq)+".pdf",;
//		AllTrim(Lower(cDestEmail)),;
//		cNomeArq,;
//		aValores[1],;
//		cLinhaDigitavel,;
//		.F.,;
//		SE1->(RecNo()) })
		
	EndIf
	
	//dbSelectArea('TMPBOL1')

	TMPBOL1->(dbSkip())
Enddo

//oPrint:Preview()
 
If nTipo == "1"
	oPrint:Preview()
//Manda os boletos por email
Else
	ProcRegua(Len(aAnexos))
	For nI := 1 To Len(aAnexos)
		IncProc("Enviando E-Mails...")
		cMsg          := RetHTML(aAnexos,nI)
		lSendMail	  := U_MFIN001(AllTrim(aAnexos[nI,2]),"Boleto bancário para pagamento",cMsg,{aAnexos[nI,1]},.F.,.F.,.T.,.F.,"",)
		aAnexos[nI,6] := lSendMail
		
		//Flega o titulo como ja enviado por email
		
		//If lSendMail
		//SE1->(dbGoTo(aAnexos[nI,7]))
		//SE1->(RecLock("SE1",.F.))
		//SE1->E1_XENVBOL := 'S'
		//SE1->(MsUnlock())
		//EndIf
		
	Next nI
	
	//Monta tela de resumo dos envios de email
//	oDlgRes := TDialog():New(aCoord[7],000,aCoord[6]/1.5,aCoord[5]/1.5,OemToAnsi("LOG de Envio dos Boletos Por Email"),,,,,,,,oMainWnd,.T.)
//	oLisRes := TWBrowse():New(000,000,100,100,,{" ","ID Título","E-Mail Destinatário","Resultado Envio"},,oDlgRes,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
//	oLisRes:Align := CONTROL_ALIGN_ALLCLIENT
//	oLisRes:SetArray(aAnexos)
//	oLisRes:bLine := {||{		Iif(aAnexos[oLisRes:nAt][6],LoadBitmap( GetResources(), "lbtick_ocean" ),LoadBitmap( GetResources(), "lbno_ocean" )),;
//	aAnexos[oLisRes:nAt][3],;
//	aAnexos[oLisRes:nAt][2],;
//	Iif(aAnexos[oLisRes:nAt][6],"Boleto enviado com sucesso.","Falha no envio do boleto.") }}
// 	oDlgRes:Activate(,,,,,,{||EnchoiceBar(oDlgRes,{|| oDlgRes:End()},{|| oDlgRes:End()})})
EndIf

//Alterado fabricio para retornar nome do arquivo para envio por e-mail, variavel passada por referencia na funcao
cNomePDF:=_cNomeArq
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³__LAYOUT  ºAutor  ³Microsiga           º Data ³  01/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime layout do boleto bancario.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function __LAYOUT(oPrint)

Local aBitmap := ""       
Local oFonte1 := TFont():New( "Arial",,16,,.T.,,,,.F.,.F.)
Local oFonte2 := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFonte4 := TFont():New( "Arial",,11,,.F.,,,,.F.,.F.)
Local oFonte5 := TFont():New( "Arial",,06,,.T.,,,,.F.,.F.)
Local oFonte6 := TFont():New( "Arial",,10,,.F.,,,,.F.,.F.)
Local oFonte6it := TFont():New( "Arial",,10,,.F.,,,,.F.,.F.)


DbSelectArea("SA6")        //Posiciona o SA6 (Bancos)
	DbSetOrder(1)
	DbSeek(xFilial("SA6")+SE1->E1_PORTADO) 

_cCaminho	:= GetSrvProfString('Startpath','')// GetSrvProfString('Rootpath','')
IF SA6->A6_COD =='001'   //BRASIL
	aBitmap := {"",_cCaminho+"\Bitmaps\LogoBrasil.bmp"} 
ElseIf SA6->A6_COD =='341'   //ITAU
	aBitmap := {"",_cCaminho+"\logo_itau.bmp"} 
ElseIf  SA6->A6_COD = "237" // Bradesco
	aBitmap := {"",_cCaminho+"\Bitmaps\LogoBradesco.bmp"}
ElseIf  SA6->A6_COD = "756" // Bancoob
	aBitmap := {"",_cCaminho+"\Bitmaps\LogoBANCOOB.bmp"}
ElseIf  SA6->A6_COD = "356" // Banco Bancoob
	aBitmap := {"",_cCaminho+"\Bitmaps\LogoBcoReal.bmp"}
ElseIf  SA6->A6_COD = "033" // Banco Santander
	aBitmap := {"",_cCaminho+"\Bitmaps\LogoSantander.bmp"}
ElseIf  SA6->A6_COD = "104" // Banco Caixa
	aBitmap := {"",_cCaminho+"\logo_caixa.bmp"}

Endif
oPrint:EndPage()
oPrint:StartPage()

IF SA6->A6_COD =='104'
	oPrint:Say(450,060,"SAC CAIXA: 0800 726 0101 (informações, reclamações, sugestões e elogios)",oFonte6)
	oPrint:Say(480,060,"Para pessoas com deficiência auditiva ou de fala: 0800 726 2492",oFonte6)
	oPrint:Say(510,060,"Ouvidoria: 0800 725 7474",oFonte6)
	oPrint:Say(540,060,"caixa.gov.br",oFonte6)		
EndIf

//Desenha as 2 fichas de compensacao

// linha 1
	oPrint:SayBitmap(_nLin+080,060,aBitmap[2],400,106)
	//oPrint:Say(_nLin+625,060,"CAIXA",oFonte1)
	//oPrint:SayBitmap(_nLin+625,060,aBitmap[2],500,106)
	
	IF SA6->A6_COD =='001'
		oPrint:Say(_nLin+160,690,"001-9",oFonte1)
	ELSEIF SA6->A6_COD =='341'  
		oPrint:Say(_nLin+160,690,"341-7",oFonte1)
	ELSEIF SA6->A6_COD =='237' 
		oPrint:Say(_nLin+160,690,"237-2",oFonte1)
	ELSEIF SA6->A6_COD =='104'
		oPrint:Say(_nLin+160,690,"104-0",oFonte1)
	ELSEIF SA6->A6_COD =='756'
		oPrint:Say(_nLin+160,700,"756-0",oFonte1)
	ELSEIF SA6->A6_COD =='033'
		oPrint:Say(_nLin+160,690,"033-7",oFonte1)
	ELSE
		oPrint:Say(_nLin+160,690,"VER FONT",oFonte1)
	ENDIF
	aPosicoes[8] := {_nLin+160,890}
	
	oPrint:Line(_nLin+135,675,_nLin+185,675)
	oPrint:Line(_nLin+135,850,_nLin+185,850)
	
	oPrint:Box (_nLin+185,050,_nLin+1120,POS_COLFIM)   //oPrint:Box(750,050,1700,2500)
	
// linha 2
	oPrint:Say(_nLin+206,060,"Local de Pagamento",oFonte6)
	aPosicoes[9] := {_nLin+235,060}
	oPrint:Say(_nLin+206,1847,"Vencimento",oFonte6)
	aPosicoes[10] := {_nLin+265,2040}

	oPrint:Line(_nLin+185,1837,_nLin+275,1837)
	oPrint:Line(_nLin+275,050,_nLin+275,POS_COLFIM)         //oPrint:Line(836,050,836,2500)
		
// linha 3
	oPrint:Say(_nLin+296,060,"Nome do Beneficiário / CNPJ / CPF / Endereço:",oFonte6)
	aPosicoes[11] := {_nLin+325,060}
	oPrint:Say(_nLin+296,1847,"Agência/Código Beneficiário",oFonte6)
	aPosicoes[12] := {_nLin+355,2070}

	oPrint:Line(_nLin+275,1837,_nLin+365,1837)
	oPrint:Line(_nLin+365,050,_nLin+365,POS_COLFIM)   //oPrint:Line(922,050,922,2500)

// linha 4
	oPrint:Say(_nLin+386,060,"Data do Documento",oFonte6)
	aPosicoes[13] := {_nLin+445,060}
	oPrint:Say(_nLin+386,429,"No. Documento",oFonte6)
	aPosicoes[14] := {_nLin+445,429}
	oPrint:Say(_nLin+386,798,"Espécie do Doc.",oFonte6)
	aPosicoes[15] := {_nLin+445,798}
	oPrint:Say(_nLin+386,1117,"Aceite",oFonte6)
	aPosicoes[16] := {_nLin+445,1117}
	oPrint:Say(_nLin+386,1436,"Data do Processamento",oFonte6)
	aPosicoes[17] := {_nLin+445,1436}
	oPrint:Say(_nLin+386,1847,"Nosso Número",oFonte6)
	aPosicoes[18] := {_nLin+445,2000}

	oPrint:Line(_nLin+365, 419,_nLin+455,419)
	oPrint:Line(_nLin+365, 788,_nLin+455,788)
	oPrint:Line(_nLin+365,1107,_nLin+455,1107)
	oPrint:Line(_nLin+365,1426,_nLin+455,1426)
	oPrint:Line(_nLin+365,1837,_nLin+455,1837)
	oPrint:Line(_nLin+455, 050,_nLin+455,POS_COLFIM)  //oPrint:Line(1008,050,1008,2500)

// linha 5	
	oPrint:Say(_nLin+476,060,"Uso do Banco",oFonte6)
	aPosicoes[62] := {_nLin+535,060}
	oPrint:Say(_nLin+476,429,"Carteira",oFonte6)
	aPosicoes[19] := {_nLin+535,429}
	oPrint:Say(_nLin+476,798,"Espécie",oFonte6)
	aPosicoes[20] := {_nLin+535,798}
	oPrint:Say(_nLin+476,1117,"Quantidade",oFonte6)
	oPrint:Say(_nLin+476,1436,"Valor",oFonte6)
	aPosicoes[21] := {_nLin+535,1436}
	oPrint:Say(_nLin+476,1847,"(=)Valor Documento",oFonte6)  //oPrint:Say(_nLin+1006,1847,"(=)Valor Documento",oFonte6)
	aPosicoes[22] := {_nLin+535,2130}  //aPosicoes[22] := {_nLin+1036,1847}
	
	oPrint:Line(_nLin+455,419 ,_nLin+545,419)
	oPrint:Line(_nLin+455,788 ,_nLin+545,788)
	oPrint:Line(_nLin+455,1107,_nLin+545,1107)
	oPrint:Line(_nLin+455,1426,_nLin+545,1426)
	oPrint:Line(_nLin+455,1837,_nLin+545,1837)
	oPrint:Line(_nLin+545,050 ,_nLin+545,POS_COLFIM)  //oPrint:Line(1094,050,1094,2500) ####
	
// linha 6
	oPrint:Say(_nLin+566,060,"Instruções (Texto de Responsabilidade do BENEFICIÁRIO. Qualquer dúvida sobre este boleto contate o beneficiário.)",oFonte6)
	aPosicoes[23] := {_nLin+ 595,060}
	aPosicoes[24] := {_nLin+ 625,060}
	aPosicoes[25] := {_nLin+ 655,060}
	aPosicoes[26] := {_nLin+ 685,060}
	aPosicoes[27] := {_nLin+ 715,060}
	aPosicoes[28] := {_nLin+ 745,060}
	aPosicoes[29] := {_nLin+ 775,060}
	aPosicoes[30] := {_nLin+ 805,060}
	aPosicoes[71] := {_nLin+ 835,060}
	aPosicoes[73] := {_nLin+ 865,060}
	aPosicoes[74] := {_nLin+ 895,060}
	aPosicoes[75] := {_nLin+1025,060}

	oPrint:Say (_nLin+566 ,1847,"(-)Desconto/Abatimento",oFonte6)
	oPrint:Line(_nLin+545 ,1837,_nLin+635,1837)
	oPrint:Line(_nLin+635 ,1837,_nLin+635,POS_COLFIM)  //oPrint:Line(1176,1837,1176,2500)

	oPrint:Say (_nLin+656 ,1847,"(-)Outras Deduções",oFonte6)
	oPrint:Line(_nLin+635 ,1837,_nLin+725,1837)
	oPrint:Line(_nLin+725 ,1837,_nLin+725,POS_COLFIM)  //oPrint:Line(1266,1837,1266,2500)

	oPrint:Say (_nLin+746 ,1847,"(+)Juros/Multa",oFonte6)
	oPrint:Line(_nLin+725 ,1837,_nLin+815,1837)
	oPrint:Line(_nLin+815 ,1837,_nLin+815,POS_COLFIM)  //oPrint:Line(1356,1837,1356,2500)

	oPrint:Say (_nLin+836 ,1847,"(+)Outros Acréscimos",oFonte6)
	oPrint:Line(_nLin+815 ,1837,_nLin+905,1837)
	oPrint:Line(_nLin+905 ,1837,_nLin+905,POS_COLFIM)  //oPrint:Line(1446,1837,1446,2500)

	oPrint:Say (_nLin+926 ,1847,"(=)Valor Cobrado",oFonte6)
	oPrint:Line(_nLin+905 ,1837,_nLin+995,1837)
	oPrint:Line(_nLin+995 , 050,_nLin+995,POS_COLFIM)   //oPrint:Line(1528,050,1528,2500)
	 
// linha 7
	oPrint:Say(_nLin+1016,260,"Sacado:",oFonte6)
	aPosicoes[31] := {_nLin+1045,260}
	aPosicoes[34] := {_nLin+1075,260}
	aPosicoes[66] := {_nLin+1105,150}
	oPrint:Say(_nLin+1105,1570,"Autenticação Mecânica / Ficha de Compensação",oFonte6)
	oPrint:Say(_nLin+1156,1910,"RECIBO  DO  SACADO",oFonte2)


//2a. ficha de compensacao
oPrint:Say(_nLin+1500,050,Replicate("- ",224),oFonte6)

// linha 1
	oPrint:SayBitmap(_nLin+1580,065,aBitMap[2],400,106)
	oPrint:Say(_nLin+1660,690,"341-7",oFonte1)
	aPosicoes[35] := {_nLin+1660,885}
	oPrint:Line(_nLin+1635,0675,_nLin+1685,675)
	oPrint:Line(_nLin+1635,0850,_nLin+1685,850)
	oPrint:Box(_nLin+1685,0050,_nLin+2620,POS_COLFIM)

// linha 2	
	oPrint:Say(_nLin+1706,060,"Local de Pagamento",oFonte6)
	aPosicoes[36] := {_nLin+1735,060}
	oPrint:Say(_nLin+1706,1847,"Vencimento",oFonte6)
	aPosicoes[37] := {_nLin+1765,2040}
	oPrint:Line(_nLin+1685,1837,_nLin+1775,1837)
	oPrint:Line(_nLin+1775,0050,_nLin+1775,POS_COLFIM)
	
// linha 3
	oPrint:Say(_nLin+1796,060,"Nome do Beneficiário / CNPJ / CPF / Endereço:",oFonte6)
	aPosicoes[38] := {_nLin+1825,060}
	
	oPrint:Say(_nLin+1796,1847,"Agência/Código  Beneficiário",oFonte6)
	aPosicoes[39] := {_nLin+1855,2070}
	
	oPrint:Line(_nLin+1775,1837,_nLin+1865,1837)
	oPrint:Line(_nLin+1865,0050,_nLin+1865,POS_COLFIM)
	
// linha 4
	oPrint:Say(_nLin+1886,060,"Data do Documento",oFonte6)
	aPosicoes[40] := {_nLin+1945,060}
	oPrint:Say(_nLin+1886,429,"No. Documento",oFonte6)
	aPosicoes[41] := {_nLin+1945,429}
	oPrint:Say(_nLin+1886,798,"Espécie do Doc.",oFonte6)
	aPosicoes[42] := {_nLin+1945,798}
	oPrint:Say(_nLin+1886,1117,"Aceite",oFonte6)
	aPosicoes[43] := {_nLin+1945,1117}
	oPrint:Say(_nLin+1886,1436,"Data do Processamento",oFonte6)
	aPosicoes[44] := {_nLin+1945,1436}
	oPrint:Say(_nLin+1886,1847,"Nosso Número",oFonte6)
	aPosicoes[45] := {_nLin+1945,2000}

	oPrint:Line(_nLin+1865, 419,_nLin+1955,419)
	oPrint:Line(_nLin+1865, 788,_nLin+1955,788)
	oPrint:Line(_nLin+1865,1107,_nLin+1955,1107)
	oPrint:Line(_nLin+1865,1426,_nLin+1955,1426)
	oPrint:Line(_nLin+1865,1837,_nLin+1955,1837)
	oPrint:Line(_nLin+1955,0050,_nLin+1955,POS_COLFIM)

// linha 5
	oPrint:Say(_nLin+1976,060,"Uso do Banco",oFonte6)
	aPosicoes[63] := {_nLin+2035,060}
	oPrint:Say(_nLin+1976,429,"Carteira",oFonte6)
	aPosicoes[46] := {_nLin+2035,429}
	oPrint:Say(_nLin+1976,798,"Espécie",oFonte6)
	aPosicoes[47] := {_nLin+2035,798}
	oPrint:Say(_nLin+1976,1117,"Quantidade",oFonte6)
	oPrint:Say(_nLin+1976,1436,"Valor",oFonte6)
	aPosicoes[48] := {_nLin+2035,1436}
	oPrint:Say(_nLin+1976,1847,"(=)Valor Documento",oFonte6)
	aPosicoes[49] := {_nLin+2035,2130}
		
	oPrint:Line(_nLin+1955, 419,_nLin+2045,419)
	oPrint:Line(_nLin+1955, 788,_nLin+2045,788)
	oPrint:Line(_nLin+1955,1107,_nLin+2045,1107)
	oPrint:Line(_nLin+1955,1426,_nLin+2045,1426)
	oPrint:Line(_nLin+1955,1837,_nLin+2045,1837)
	oPrint:Line(_nLin+2045,0050,_nLin+2045,POS_COLFIM)

// linha 6
	oPrint:Say(_nLin+2066,060,"Instruções (Texto de Responsabilidade do BENEFICIÁRIO. Qualquer dúvida sobre este boleto contate o beneficiário.)",oFonte6)
	aPosicoes[50] := {_nLin+2095,060}
	aPosicoes[51] := {_nLin+2125,060}
	aPosicoes[52] := {_nLin+2155,060}
	aPosicoes[53] := {_nLin+2185,060}
	aPosicoes[54] := {_nLin+2215,060}
	aPosicoes[55] := {_nLin+2245,060}
	aPosicoes[56] := {_nLin+2275,060}
	aPosicoes[57] := {_nLin+2305,060}
	aPosicoes[68] := {_nLin+2335,060}
	aPosicoes[69] := {_nLin+2365,060}
	aPosicoes[72] := {_nLin+2395,060}
	aPosicoes[76] := {_nLin+2425,060}

	oPrint:Say(_nLin+2066,1847,"(-)Desconto/Abatimento",oFonte6)
	oPrint:Line(_nLin+2045 ,1837,_nLin+2135,1837)
	oPrint:Line(_nLin+2135,1837,_nLin+2135,POS_COLFIM)

	oPrint:Say(_nLin+2156,1847,"(-)Outras Deduções",oFonte6)
	oPrint:Line(_nLin+2135 ,1837,_nLin+2225,1837)
	oPrint:Line(_nLin+2225,1837,_nLin+2225,POS_COLFIM)
	
	oPrint:Say(_nLin+2246,1847,"(+)Juros/Multa",oFonte6)
	oPrint:Line(_nLin+2225 ,1837,_nLin+2315,1837)
	oPrint:Line(_nLin+2315,1837,_nLin+2315,POS_COLFIM)
	
	oPrint:Say(_nLin+2336,1847,"(+)Outros Acréscimos",oFonte6)
	oPrint:Line(_nLin+2315 ,1837,_nLin+2405,1837)
	oPrint:Line(_nLin+2405,1837,_nLin+2405,POS_COLFIM)

	oPrint:Say(_nLin+2426,1847,"(=)Valor Cobrado",oFonte6)
	oPrint:Line(_nLin+2405 ,1837,_nLin+2495,1837)
	oPrint:Line(_nLin+2495,0050,_nLin+2495,POS_COLFIM)
	
// linha 7
	oPrint:Say(_nLin+2516,260,"Sacado",oFonte6)
	aPosicoes[58] := {_nLin+2545,260}
	aPosicoes[61] := {_nLin+2575,260}
	aPosicoes[67] := {_nLin+2605,220}
	oPrint:Say(_nLin+2605,1570,"Autenticação Mecânica / Ficha de Compensação",oFonte6)
	
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetHTML   ºAutor  ³Microsiga           º Data ³  01/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para gerar HTML do boleto bancario a ser enviado porº±±
±±º          ³ e-mail conforme chamada através da funcao __BOLETO.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*/
Static Function RetHTML(aBoleto,nLinha)

Local cRetorno := ""

cRetorno := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
cRetorno += '<html xmlns="http://www.w3.org/1999/xhtml">'
cRetorno += '<head>'
cRetorno += '<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />'
cRetorno += '<title>Boleto Bancario</title>'
cRetorno += '<style type="text/css">'
cRetorno += '<!--'
cRetorno += '.a {'
cRetorno += '	font-family: Arial, Helvetica, sans-serif;'
cRetorno += '}'
cRetorno += '-->'
cRetorno += '</style>'
cRetorno += '</head>'
cRetorno += '<body class="a">'
cRetorno += '<p>Prezado cliente,</p>'
cRetorno += '<p>'
cRetorno += '<span style="font-weight: bold">Anexo o boleto bancario referente a cobranca ' + UpPer(AllTrim(aBoleto[nLinha,3])) + ', com vencimento em ' + DtoC(aBoleto[nLinha,4]) + '.</span><br>'
cRetorno += 'Caso nao consiga visualizar o boleto anexo, segue a linha digitavel para pagamento eletronico:<br>'
cRetorno += '<span style="font-weight: bold">' + aBoleto[nLinha,5] + '</span>'
cRetorno += '</p>'
cRetorno += '<p>Para atualizar seu email, favor contatar-nos atraves: <a href="mailto: adm@email.com.br">adm@email.com.br</a><br>'
cRetorno += 'Qualquer duvida, estamos a disposicao pelo <a href="mailto: faleconosco@email.com.br">faleconosco@email.com.br</a></p>'
cRetorno += '</body>'
cRetorno += '</html>'

Return(cRetorno)
/*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³__VLRCNAB ºAutor  ³Microsiga           º Data ³  01/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o valor do titulo considerando os abatimentos       º±±
±±º          ³e acrescimos.                                               º±±
±±º          ³Retorna o valor do juros por dia de atraso       			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function __VLRCNAB(nTipo)

Local nAbatim  := 0
Local nAcresc  := 0
Local nDecres  := 0
Local nSaldo   := 0
Local nRet	   := 0
Local nVlTotal := 0
Local nTxJur   := (GetNewPar("CP_TXJURO",10)/100)  // Parametro para calculo do valor dos juros diarios.

//Verifica o valor do titulo
If nTipo == 1  //se for impresso
	nAbatim  := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nAcresc  := SE1->E1_ACRESC
	nDecres  := SE1->E1_DECRESC
	nSaldo   := SE1->E1_SALDO
	nRet	 := nSaldo + nAcresc - nDecres - nAbatim
Else//Verifica o valor dos juros por dia de atraso
	nAbatim  := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nAcresc  := SE1->E1_ACRESC
	nDecres  := SE1->E1_DECRESC
	nSaldo   := SE1->E1_SALDO
	nRet	 := nSaldo + nAcresc - nDecres - nAbatim
	nRet	 := Round((nRet * nTxJur)/30,2)
EndIf

nRet := StrZero((nRet*100),13)

Return(nRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³__MODULO10ºAutor  ³Microsiga           º Data ³  01/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo do digito verificador atraves do Modulo10          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function __Modulo10(cData)
/*
Local lB := .T.
Local nP := 0
Local nD := 0          // Digito verificador
Local nL := Len(cData) // Tamanho de bytes do caracter

While nL > 0
	nP := Val(SubStr(cData, nL, 1))
	If (lB)
		nP := nP * 2
		If nP > 9
			nP := nP - 9
		EndIf
	EndIf
	nD := nD + nP
	nL := nL - 1
	lB := !lB
EndDo

nD := 10 - (Mod(nD,10))

If nD = 10
	nD := 0
EndIf

Return(nD)
*/

LOCAL L, D, P, nInt := 0

	L := Len(cdata)
	D := 0
	P := 2
	N := 0
	
	While L > 0
		N := (Val(SubStr(cData, L, 1)) * P)
		If N > 9
			D := D + (Val(SubsTr(Str(N,2),1,1)) + Val(SubsTr(Str(N,2),2,1)))
		Else
			D := D + N
		Endif
		If P = 2
			P := 1
		Elseif P = 1
			P := 2
		EndIf
		L := L - 1
	End
	/*/
	nInt := (Int((D / 10)) + 1) * 10
	D:= nInt - D
	/*/
	
	nInt := mod(D,10)
	
	D:= 10 - nInt
	
	If D == 10
		D:=0
	Endif

Return(D)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³__MODULO11ºAutor  ³Microsiga           º Data ³  01/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo do digito verificador atraves do Modulo11          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function __Modulo11(cData,nBaseDv,nBase,cBanc,cTipo)
Local L := 0
Local D := 0
Local E := 0
Local P := 0
Local cBanc := SEE->EE_CODIGO
DEFAULT nBaseDv := ""

If cBanc == "001" .AND. nBaseDv == 2  //Banco do brasil
	L := Len(cData)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		EndIf
		L := L - 1
	EndDo
	D := 11 - mod(D,11)
	
	If Len(ALLTRIM(cdata)) > 17 //Se for calculo do digito verificador do codigo de barras.
		D := If(D = 0 .OR. D = 10 .OR. D = 11,1,AllTrim(Str(D)))
	Else
		D := If(D = 10 ,"X",AllTrim(Str(D)))
	EndIf
	
	D := Iif(Valtype(D)=="N",AllTrim(Str(D)),AllTrim(D))   

ELSEIf cBanc == "001" .AND. nBaseDv == 9  //Banco do brasil
	L := Len(cData)
	D := 0
	P := 10
	While L > 0
		P := P - 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 2
			P := 10
		EndIf
		L := L - 1
	EndDo
	D := mod(D,11)
	
	D := If(D = 10 ,"X",AllTrim(Str(D)))
	
	D := Iif(Valtype(D)=="N",AllTrim(Str(D)),AllTrim(D))
	
ElseIf  cBanc == "104" //Caixa
	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	EndDo
    D := 11 - (mod(D,11))
	If !Empty(nBaseDv) //Regra para digito geral do codigo de barras que não aceita 0
		If (D > 9 ) .OR. D == 0
			D := 1
		EndIf
	Else
		If (D > 9 ) 
			D := 0
		EndIf
	EndIf
	
	D := AllTrim(Str(D))
	Return(D)


ElseIf cBanc == "237"//Bradesco
	L := Len(cData)
	E := 0
	P := 1
	nBaseDv := Iif(L > 13,9,7)
	While L > 0
		P := P + 1
		E := E + (Val(SubStr(cData, L, 1)) * P)
		If P = nBaseDv
			P := 1
		EndIf
		L := L - 1
	EndDo
	
	E := 11 - (mod(E,11))
	
	If Len(AllTrim(cData)) > 17 // se for calculo do digito verificador do código de barras.
		E := Iif(E = 0 .OR. E = 1 .OR. E > 9,1,E)
	Else   // Caso contrario sera considerado o calculo do digito verificador do Nosso Numero.
		If (E == 10)
			E := "P"
		ElseIf (E == 11)
			E:= 0
		EndIf
	EndIf
	
	D := Iif(Valtype(E)=="N",AllTrim(Str(E)),AllTrim(E))


ElseIf cBanc == "756"
	D := 0
	IF cTipo == "N"
		D := 0
		P := 0
		aConst	:= {3,1,9,7}
		FOR L := 1 TO Len(cdata)
   			P := P + 1
	   		D := D + (Val(SubStr(cData, L, 1)) * aConst[P])
			If P = 4
				P := 0
	   		End
   		NEXT
		nRest	:= mod(D,11)
		if nRest == 0 .OR. nRest == 1
			D	:= 0
		ELSE
			D := 11 - nRest //(mod(D,11))
		ENDIF
	ELSEIF cTipo == "C"
		L := Len(cdata)
		D := 0
		P := 1
		While L > 0
   			P := P + 1
	   		D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 9
				P := 1
	   		End
   			L := L - 1
		End
		D := 11 - (mod(D,11))
		If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
			D := 1
		End
	ENDIF
Return(D)
ElseIf cBanc == "341"       //itau                 
	L := Len(cdata)
	D := 0
	P := 1
// Some o resultado de cada produto efetuado e determine o total como (D);
	While L > 0
   		P := P + 1
   		D := D + (Val(SubStr(cData, L, 1)) * P)
   		If P = 9
			P := 1
   		EndIF
   	   	L := L - 1
	End
// DAC = 11 - Mod 11(D)
	D := 11 - (mod(D,11))
// OBS: Se o resultado desta for igual a 0, 1, 10 ou 11, considere DAC = 1.
	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	End
ElseIf cBanc == "399" 
	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P :=  P + 1
		D := D + (Val(Subs(cData, L, 1)) * P)
		If P = nBase
			P := 1
		EndIF
		L := L - 1
	EndDO            
	//alteração Vinícius - Motivo adequação ao layout do banco HSBC
	D := 11 - (mod(D,11))
                
	IF cTipo == "N"
		If (D == 0 .Or. D == 10 .Or. D == 11)
			D := 0                        
		elseif D == 1
			D := 1
		EndIF
	elseif cTipo == "B"
		If (D == 0 .Or. D == 1 .Or. D == 10) 
			D := 1
   		EndIF       
	elseif cTipo == "C"
		If D == 11
			D := 1
	   	elseif D == 10
			D := 0
		EndIF       	
	elseif cTipo == "I"
		If D == 10 
			D := "P"
		ELSEIF D == 11
			D := "0"
		ELSE
			D:= STR(D)
		EndIF 	
	endif

//Static Function Modulo11(cData) //ADD        
ElseIf cBanc == "033" //Santander
	L := Len(cdata)
	D := 0
	P := 1
		While L > 0
  			P := P + 1
  			D := D + (Val(SubStr(cData, L, 1)) * P)
  		If P = 9
	   		P := 1
	End
  		L := L - 1
End
//D := 11 - (mod(D,11))
	nInt := Int(D/11)
	nRes := Abs((nInt * 11) - D)
If nRes == 10
	nDig := 1
ElseIf nRes == 1 .OR. nRes == 0
	nDig := 0
Else
	nDig := Abs(nRes - 11)
EndIf

/*
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
End
*/

Return(nDig)			

Else  // Se não mostra esse
	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End
    D := 10 - (mod(D,10))
	If (D == 10 .Or. D == 11)
		D := 1
	End
	D := AllTrim(Str(D))
Endif
Return(D)

/*/
*-----------------------------------------------------------------------------------------*
* Static Function  * CodBarra_104 * Autor  * TOTVS       * Data *  11/12/2014        *
*-----------------------------------------------------------------------------------------*
* Descrição        * Static Function para retornar a representação do cod de barras - BCO *
*				   * CAIXA para convenio com 7 posições. 								  *
*				   * Verificar se o campo EE_FAXATU tem a quantidade de digitos adequada  *
*				   * No caso do BRASIL deve ser 10 digitos.								  *
*				   * Exemplo: EE_FAXATU = "0000000001"                              	  *  
*-----------------------------------------------------------------------------------------*
* Uso              * Especifico da User Function RFIN002()   Chamado no campo EE_C_CODBA  *
*-----------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------*
/*/
/*
Static Function CodBarra_104()  //CAIXA

Local cRetorno   	:= "" 
Local cAgencia	 	:= SEE->EE_AGENCIA 
Local cConta 	 	:= AllTrim(SEE->EE_CONTA)
Local cFatVencto 	:= AllTrim(Str(1000 + (aValores[1] - CToD("03/07/2000"))))
Local nTamFaxa   	:= 15 // Tamanho do sequencial informado no campo EE_FAXATU
Local nBaseM11   	:= 9  // Base de calculo da funcao __MODUlo11()
Local cCarteira  	:= AllTrim(SEE->EE_CODCART)+"4" //Carteira 1 indica registrada, e o 4 indica emissão do boleto pelo beneficiário
Local cMoed      	:= "9"
Local cConvenio  	:= AllTrim(SEE->EE_CODEMP)
Local cSequencial	:= StrZero(Val(ALLTRIM(SEE->EE_FAXATU))+1,nTamFaxa)
Private cNNumImp 
Private cNNumImp1
Private cBanc

While !MayIUseCode(cSequencial)
	cSequencial := StrZero(Val(cSequencial)+1,nTamFaxa)
ENDDO      

cNNumImp := cConvenio + cSequencial
cNNumImp1 := "14" + cSequencial + __Modulo11( "14"+cSequencial) 
cBanc := "104"      

dbSelectArea("SEE")
SEE->(dbSetOrder(1))

If !SEE->(dbSeek(xFilial("SEE")+SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON ))
	Return("")
Else           
	IF Val(SEE->EE_FAXATU) < Val(cSequencial)
		SEE->(RecLock("SEE",.F.))
   		SEE->EE_FAXATU := Right(cSequencial,12)
		SEE->(MsUnLock())
	ENDIF
EndIf
        
If Len(AllTrim(cConvenio)) == 7
	//Atualiza o NUMBCO (nosso numero)
   	SE1->(RecLock("SE1",.F.))
 	SE1->E1_NUMBCO := cNNumImp1
	SE1->(MsUnlock())
Else
	//Atualiza o NUMBCO (nosso numero)
	SE1->(RecLock("SE1",.F.))
   	SE1->E1_NUMBCO := cNNumImp1
	SE1->(MsUnlock())
EndIf

/*
COMPOSIÇÃO DO CÓDIGO DE BARRAS 
O código de barras para a cobrança contém 44 posições dispostas da seguinte forma: 
Posição Tamanho Picture Conteúdo Observação 
01 – 03 3 9 (3) Identificação do banco (104) 
04 – 04 1 9 Código da moeda (9 - Real) 
05 – 05 1 9 DV Geral do Código de Barras Nota 2 / Anexo I 
06 - 09 4 9 Fator de Vencimento Anexo II 
10 - 19 10 9 (8) V99 Valor do Documento 
##### ABAIXO O CAMPO LIVRE
20 – 25 6 9 (6) Código do Beneficiário 
26 – 26 1 9 (1) DV do Código do Beneficiário Nota 3 /Anexo VI 
27 – 29 3 9 (3) Nosso Número - Seqüência 1 Nota 1 
30 – 30 1 9 (1) Constante 1 Nota 1 
31 – 33 3 9 (3) Nosso Número - Seqüência 2 Nota 1 
34 – 34 1 9 (1) Constante 2 Nota 1 
35 – 43 9 9 (9) Nosso Número - Seqüência 3 Nota 1 
44 – 44 1 9 (1) DV do Campo Livre Nota 4 / Anexo III
*/


cCampoLivre := cConvenio+SubStr(cNNumImp1,3,3)+"1"+SubStr(cNNumImp1,6,3)+"4"+SubStr(cNNumImp1,9,9)
cCampoLivre += __Modulo11(cCampoLivre)
//O codigo de barras possui 44 posicoes no total,
//sendo as primeiras 19 posicoes:
cRetorno := cBanc //01 a 03 TAM 03 - Codigo do banco
cRetorno += cMoed //04 a 04 TAM 01 - Codigo da Moeda (Real = 9, Outras=0)
cRetorno += AllTrim(__Modulo11(cBanc+cMoed+cFatVencto+StrZero(aValores[2]*100,10)+cCampoLivre,"DV"))  //05 a 05 TAM 01 - Digito geral do codigo de barra 
cRetorno += cFatVencto //06 a 09 TAM 04 - Fator de vencimento
cRetorno += StrZero(aValores[2]*100,10) //10 a 19 TAM 10 - Saldo do titulo
cRetorno += ALLTRIM(cCampoLivre) //20 a 44 - CAMPO LIVRE

Return(cRetorno)
*/

/*
*-----------------------------------------------------------------------------------------*
* User Function  * CB341 * Autor  *              TOTVS                  * Data *  11/12/2014        *
*-----------------------------------------------------------------------------------------*
* Descrição        * Static Function para retornar expressão do codigo de barra BCO ITAU  *
*-----------------------------------------------------------------------------------------*
* Uso              * Especifico da User Function RFIN002()   							  *
*-----------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------*
*/
Static Function CodBarra_341()   //ITAU

Local cAgencia		:= STRZERO(VAL(SEE->EE_AGENCIA),4) //Right(SEE->EE_AGENCIA,4)
Local cContaSD 	 	:= STRZERO(VAL(SEE->EE_CONTA),5)
//Local cConta 	 	:= STRZERO(VAL(SEE->EE_CONTA),5)+SEE->EE_DVCTA
Local cConta 	 	:= STRZERO(VAL(SEE->EE_CONTA),5)        // Alterado em 09/01/18 porque manual do banco Itau não considera o digito para calculo do DAC nosso numero
Local cCarteira		:= SEE->EE_CODCART
Local dvencimento	:= aValores[1]
Local cRetorno   := ""
Local cFatVencto := AllTrim(Str(1000 + (dvencimento - CToD("03/07/2000"))))
//Local cSequencial := StrZero(Val(Right(SEE->EE_FAXATU,8))+1,8)  
Local cSequencial := Soma1(StrZero(Val(AllTrim(SEE->EE_FAXATU)),8))   //Alterado em 05/01/2018                     ·
//Local cConta := StrZero(Val(SUBSTR(SEA->EA_NUMCON,1,LEN(ALLTRIM(SEA->EA_NUMCON))-1)),5)  //Conta sem digito
local cNNumSDig := cCarteira + cSequencial    
Local cNNum := cAgencia + cConta + cNNumSDig       // digito verifacador Agencia + Conta + Carteira + Nosso Num 
Local cNNumDac := AllTrim(Str(__Modulo10(cNNum))) //DAC nosso numero
Local cMoed :="9"

Private cBanc :="341"
Private cNNumImp := cCarteira + "/" + cSequencial +"-"+ cNNumDac 			 

cNossoNum := cCarteira + cSequencial + cNNumDac //109/000003359 PARA IMPRESSÃO

//If Empty(SE1->E1_NUMBCO)                         
	//Pesquisa as informacoes na tabela de PARAMETROS BANCOS 
	dbSelectArea("SEE")
	SEE->(dbSetOrder(1))
	If !SEE->(dbSeek(xFilial("SEE")+SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON ))
		Return("")
	Else
		SEE->(RecLock("SEE",.F.))
		SEE->EE_FAXATU := cSequencial //StrZero(Val(SEE->EE_FAXATU)+1,6)   
		SEE->(MsUnLock())
	EndIf 

	//Atualiza o NUMBCO (nosso numero)
	SE1->(RecLock("SE1",.F.))
	SE1->E1_NUMBCO := cNossoNum
	SE1->(MsUnlock())   
//ELSE
//	cNossoNum	:= SE1->E1_NUMBCO  
//	cSequencial	:= substr(cNossoNum,LEN(ALLTRIM(cCarteira))+1,LEN(ALLTRIM(cSequencial)))
//	cNNumDac	:= SUBSTR(cNossoNum,LEN(ALLTRIM(cNossoNum)),1)
//EndIf
//TOTAL TEM QUE TER 44 DIGITOS
cRetorno := cBanc //Codigo do banco      
cRetorno += cMoed //Tipo de Moeda  
cRetorno += AllTrim(Str(__Modulo11(cBanc+cMoed+cFatVencto+StrZero(aValores[2]*100,10)+ALLTRIM(cNossoNum)+cAgencia+cContaSD+ AllTrim(Str(__Modulo10(cAgencia+cContaSD)))+"000")))  //Digito do codigo de barra 
cRetorno += cFatVencto //Fator de vencimento
cRetorno += StrZero(aValores[2]*100,10) //Saldo do titulo 
cRetorno += ALLTRIM(cCarteira) //carteira
cRetorno += cSequencial //Nosso Numero
cRetorno += cNNumDac //DAC [Agência /Conta/Carteira/Nosso Número] (Anexo 4)
cRetorno += cAgencia //N.º da Agência cedente
cRetorno += cContaSD //N.º da Conta Corrente
cRetorno += AllTrim(Str(__Modulo10(cAgencia+cContaSD))) //DAC [Agência/Conta Corrente] (Anexo 3)
cRetorno += "000" //ZEROS 000 FIXO  

Return(cRetorno)

/*
*-----------------------------------------------------------------------------------------*
* User Function  * LD341 * Autor  *              TOTVS                  * Data *  11/12/2014          *
*-----------------------------------------------------------------------------------------*
* Descrição        * Static Function para retornar expressão da linha digitavel BCO INDUS-*
*				   * TRIAL.																  *
*-----------------------------------------------------------------------------------------*
* Uso              * Especifico da User Function RFIN002()   							  *
*-----------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------*
*-----------------------------------------------------------------------------------------*
*/

Static Function LinhaDig_341()  //ITAU
Local aLinha 	:= {"","","","",""}
Local cCamLiv	:= SUBSTR(SE1->E1_CODBAR,20,25)
Local cCarteira		:= SEE->EE_CODCART
Local cSequencial := StrZero(Val(SEE->EE_FAXATU),2)
Local cConta 	 	:= STRZERO(VAL(SEE->EE_CONTA),5)+SEE->EE_DVCTA
Local cAgencia		:= STRZERO(VAL(SEE->EE_AGENCIA),4) //Right(SEE->EE_AGENCIA,4)

//1o. Grupo: BANCO + TIPO DE MOEDA + 5 PRIMEIROS DIGITOS DO SEQUENCIAL DO BANCO + 5 PRIMEIROS CARACTERES DO NOSSO NUMERO + DIGITO MODULO 10 
//AAABC.CCDDX DDDDD.DEFFFY FGGGG.GGHHHZ K UUUUVVVVVVVVVV
aLinha[1] := SUBSTR(SE1->E1_CODBAR,1,3) //AAA = Código do Banco na Câmara de Compensação (Itaú=341)
aLinha[1] += SUBSTR(SE1->E1_CODBAR,4,1) //Fixo tipo de moeda (9=Real) 
aLinha[1] += cCarteira //CCC =Código da carteira de cobrança
aLinha[1] += SUBSTR(SE1->E1_NUMBCO,4,2) //DD = Dois primeiros dígitos do Nosso Número
aLinha[1] += AllTrim(Str(__Modulo10(aLinha[1]))) //Digito de controle no modulo 10 //X = DAC que amarra o campo 1 (Anexo3)
                                              
//2o. Grupo: 5 ULTIMAS POSICOES DO NOSSO NUMERO + DIGITO DO NOSSO NUMERO + NUMERO DA CONTA DE COBRANCA + DIGITI VERIFICADOR MODULO 10 
aLinha[2] := SUBSTR(SE1->E1_NUMBCO,6,6) // DDDDDD= Restante do Nosso Número
aLinha[2] += SUBSTR(SE1->E1_NUMBCO,12,1) //E = DAC do campo [Agência/Conta/Carteira/ Nosso Número] 
//aLinha[2] += SUBSTR(SEE->EE_AGENCIA,1,3) //FFF =Três primeiros números que identificam a Agência
aLinha[2] += SUBSTR(cAgencia,1,3) //FFF =Três primeiros números que identificam a Agência
aLinha[2] += AllTrim(Str(__Modulo10(aLinha[2]))) //Digito de controle no modulo 10 //Y = DAC que amarra o campo 2 (Anexo 3)
//3o. Grupo: NUMERO + DIGITO DA CONTA + CODIGO DA CARTEIRA + CODIGO APLICATIVO + DIGITO DO BLOCO

aLinha[3] := SUBSTR(cAgencia,4,1) //F =Restante do número que identifica a agência
aLinha[3] += StrZero(Val(SUBSTR(cConta,1,6)),6) //GGGGGG = Número da conta corrente + DAC
aLinha[3] += "000" //HHH =Zeros ( Não utilizado )
aLinha[3] += AllTrim(Str(__Modulo10(aLinha[3]))) //Digito de controle no modulo 10 //Z = DAC que amarra o campo 3 (Anexo 3)

//4o. Grupo: DIGITO VERIFICADOR DO CODIGO DE BARRAS
aLinha[4] += SUBSTR(SE1->E1_CODBAR,5,1) //DAC do Código de Barras (Anexo 2)

//5o. Grupo: FATOR DE VENCIMENTO + VALOR DO TITULO 
aLinha[5] += AllTrim(Str(1000 + (aValores[1] - CToD("03/07/2000")))) //UUUU=Fator de vencimento
aLinha[5] += StrZero(aValores[2]*100,10) //Valor do Título (*)

Return(aLinha[1]+aLinha[2]+aLinha[3]+aLinha[4]+aLinha[5])                   
//Return(Transform(aLinha[1],"@R 99999.99999")+" "+Transform(aLinha[2],"@R 99999.999999")+" "+Transform(aLinha[3],"@R 99999.999999")+" "+aLinha[4]+" "+aLinha[5])       

static function FIncLog()

	//inserindo integração de boletas
	chkfile('Z18')
	dbSelectArea('Z18')
	Z18->(dbSetOrder(2))
	Z18->(dbGoTop())
	Z18->(dbSeek(xFilial('Z18')+SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA))
	cStatus	:= ''
	if Z18->(eof())
		cStatus	:= ''
	else
		while Z18->Z18_PREFIX == SE1->E1_PREFIXO .and. SE1->E1_NUM == Z18->Z18_NUMERO .and. alltrim(Z18->Z18_PARCEL) == alltrim(SE1->E1_PARCELA)
			cStatus	:= Z18->Z18_STATUS
			Z18->(dbSkip())
		enddo
	endif

	if !empty(cStatus) .and. cStatus != 'C'
		if reclock('Z18',.T.)
			Z18->Z18_FILIAL	:= xFilial('Z18')
			Z18->Z18_SEQ	:= GetSXENum('Z18','Z18_SEQ')
			Z18->Z18_PREFIX	:= SE1->E1_PREFIXO
			Z18->Z18_NUMERO	:= SE1->E1_NUM
			Z18->Z18_PARCEL	:= SE1->E1_PARCELA
			Z18->Z18_TIPO	:= SE1->E1_TIPO
			Z18->Z18_CLIENT	:= SE1->E1_CLIENTE
			Z18->Z18_LOJA	:= SE1->E1_LOJA
			Z18->Z18_STATUS	:= 'C'		// A CANCELAR
			Z18->Z18_DATA	:= DATE()
			Z18->Z18_HORA	:= TIME()
			Z18->Z18_INT	:= 'N'
			Z18->Z18_PORTAD	:= SE1->E1_PORTADO
			Z18->Z18_AGEDEP	:= SE1->E1_AGEDEP
			Z18->Z18_CONTA	:= SE1->E1_CONTA
			Z18->Z18_NUMBOR	:= SE1->E1_NUMBOR
			Z18->Z18_DTBORD	:= SE1->E1_DATABOR
			Z18->Z18_IDCNAB	:= SE1->E1_IDCNAB
			Z18->Z18_SERORI	:= FSerie(SE1->E1_PREFIXO+SE1->E1_NUM)
			Z18->Z18_DOCORI	:= FNota(SE1->E1_PREFIXO+SE1->E1_NUM)
			Z18->Z18_CODBAR	:= SE1->E1_CODBAR
			Z18->Z18_CODDIG	:= SE1->E1_CODDIG
			Z18->Z18_NUMBCO	:= SE1->E1_NUMBCO
			CONFIRMSX8()
			Z18->(msUnlock())
		else
			ROLLBACKSX8()
		endif
	endif

	cSeqInt	:= GetSXENum('Z18','Z18_SEQ')

	if reclock('Z18',.T.)
		Z18->Z18_FILIAL	:= xFilial('Z18')
		Z18->Z18_SEQ	:= cSeqInt
		Z18->Z18_PREFIX	:= SE1->E1_PREFIXO
		Z18->Z18_NUMERO	:= SE1->E1_NUM
		Z18->Z18_PARCEL	:= SE1->E1_PARCELA
		Z18->Z18_TIPO	:= SE1->E1_TIPO
		Z18->Z18_CLIENT	:= SE1->E1_CLIENTE
		Z18->Z18_LOJA	:= SE1->E1_LOJA
		Z18->Z18_STATUS	:= 'A'		// A CANCELAR
		Z18->Z18_DATA	:= DATE()
		Z18->Z18_HORA	:= TIME()
		Z18->Z18_INT	:= 'N'
		Z18->Z18_PORTAD	:= SE1->E1_PORTADO
		Z18->Z18_AGEDEP	:= SE1->E1_AGEDEP
		Z18->Z18_CONTA	:= SE1->E1_CONTA
		Z18->Z18_NUMBOR	:= SE1->E1_NUMBOR
		Z18->Z18_DTBORD	:= SE1->E1_DATABOR
		Z18->Z18_IDCNAB	:= SE1->E1_IDCNAB
		Z18->Z18_SERORI	:= FSerie(SE1->E1_PREFIXO+SE1->E1_NUM)
		Z18->Z18_DOCORI	:= FNota(SE1->E1_PREFIXO+SE1->E1_NUM)
		Z18->Z18_CODBAR	:= SE1->E1_CODBAR
		Z18->Z18_CODDIG	:= SE1->E1_CODDIG
		Z18->Z18_NUMBCO	:= SE1->E1_NUMBCO
		Z18->Z18_VENCTO	:= SE1->E1_VENCTO
		Z18->Z18_VALOR	:= SE1->E1_VALOR
		CONFIRMSX8()
		Z18->(msUnlock())
	else
		ROLLBACKSX8()
	endif

	Z18->(dbCloseArea())

return


static function FNota(pTitulo)
	local	aArea		:= getArea(),;
			aAreaSC5	:= SC5->(getArea())

	local	cNumNota	:= ''

	dbSelectArea('SC5')
	SC5->(dbSetOrder(10))
	SC5->(dbGoTop())
	if (SC5->(dbSeek(xFilial('SC5')+pTitulo)))

		if !SC5->(eof())
			cNumNota	:= SC5->C5_XNFINT 
		endif

	endif

	restArea(aAreaSC5)
	restArea(aArea)

return cNumNota

static function FSerie(pTitulo)
	local	aArea		:= getArea(),;
			aAreaSC5	:= SC5->(getArea())

	local	cSerie		:= ''

	dbSelectArea('SC5')
	SC5->(dbSetOrder(10))
	SC5->(dbGoTop())
	if (SC5->(dbSeek(xFilial('SC5')+pTitulo)))

		if !SC5->(eof())
			cSerie	:= SC5->C5_XSRORIG
		endif

	endif

	restArea(aAreaSC5)
	restArea(aArea)

return cSerie
