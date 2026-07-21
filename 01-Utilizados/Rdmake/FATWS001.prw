#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TOPConn.ch'
#INCLUDE "FWCOMMAND.CH"

#DEFINE VBOX       080
#DEFINE HMARGEM    030
#DEFINE DIRPDF  "\#PDF"

User Function FATWJOB


	RptStatus( {|| U_FATW009(cNF,cSerie)}, "Processando...","Rotina de gera��o de DANFE e BOLETO.", .T. )


Return

User Function FATWS001(cNF,cSerie,cCliente,cLoja,cPrefixo,cParcela,lViewPDF,cEspec)

	Local _cPasta	:= alltrim(GetTempPath())
	local cFuncao	:= FunName()
	Local aTitulo	:= {}
	Local aImp		:= {}
	Local cDanfe	:= ""
	Local cXml		:= ''
	Local cBoleto	:= ""
	Local _aAnexo	:= {}
	Local cAssunto	:= ''
	local aDados	:= {}

	Private _cXNomArq    :=""

	Default lViewPDF	:= .F.


	dbSelectArea("SF2")
	SF2->(dbSetOrder(1))

	aadd(aImp,xFilial('SE1'))
	aadd(aImp,cPrefixo)
	aadd(aImp,cNF)
	aadd(aImp,cCliente)
	aadd(aImp,cLoja)
	aadd(aImp,'N')			//Impresso Bordero
	aadd(aImp,'N')			//Impresso Boleto
	aadd(aImp,cSerie)
	aadd(aImp,cParcela)
	aadd(aTitulo,aImp)

	SF2->(dbGotop())
	IF SF2->(dbSeek(xFilial("SF2")+cNF+cSerie+cCliente+cLoja))

		//Verifica se a nota foi autorizada
		U_SpedMNTNF("SF2")
		IF (SF2->F2_FIMP = "S")  .OR. alltrim(SF2->F2_ESPECIE) = 'NFCE' .OR. (!empty(cSerie) .and. alltrim(cSerie = 'REN'))  //Caso altorizada gera danfe e boleto
			IF lDanfe
				if SF2->F2_ESPECIE = 'SPED'
					cAssunto	:= '[MANFIL] - Envio de Nota NFE '
					//cDanfe		:= U_ImpDanfe(SF2->F2_DOC,SF2->F2_SERIE,lViewPDF,.T.)
					cDanfe		:= u_zGerDanfe(SF2->F2_DOC, SF2->F2_SERIE, lViewPDF, .T. /*XML*/)
				
				elseif SF2->F2_ESPECIE = 'NFCE'
					cAssunto	:= '[MANFIL] - Envio de Nota NFCe '
					dbSelectArea("SL1")
					SL1->(dbSetOrder(2))
					IF SL1->(dbSeek(xFilial("SL1")+SF2->F2_SERIE+SF2->F2_DOC))
						//cMV_LJST:=GetMv("MV_LJSTPRT")
						//PutMV("MV_LJSTPRT",2)
						LjNfceImp(SL1->L1_FILIAL,SL1->L1_NUM)
						//PutMV("MV_LJSTPRT",cMV_LJST)
						cDanfe:='nfc-e_'+U_UChvNFE(SL1->L1_DOC, SL1->L1_SERIE)
					endif
				endif
				
				cXml:= cDanfe+".xml"
				If CPYT2S(_cPasta+Alltrim(cXml),"\#PDF")
					aadd(_aAnexo,cXml)
				EndIf
				cDanfe	:=cDanfe+".PDF"
				If CPYT2S(_cPasta+Alltrim(cDanfe),"\#PDF")
					aadd(_aAnexo,cDanfe)
				EndIf
			endIF

			IF lBolet

				aDados	:= {}
				aDados	:= pBuscaDado(cSerie, cNF, cParcela)

				if empty(cAssunto)
					cAssunto	:= '[MANFIL] - Envio de BOLETA BANCARIO para PAGAMENTO'
				else
					cAssunto	+= 'com BOLETO BANCARIO para PAGAMENTO'
				endif
				cBoleto:=U_RD06007(cFuncao,aTitulo,lViewPDF)
				cBoleto:=cBoleto+".PDF"
				CPYT2S(_cPasta+Alltrim(cBoleto),"\#PDF")
				aadd( _aAnexo,cBoleto)
			EndIF

			If !ExistDir(DIRPDF)
				MakeDir(DIRPDF)
			EndIf

			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))
			cEmailSA1		:= Alltrim(SA1->A1_EMAIL)
			if !empty(SA1->A1_XEMAIL)
				cEmailSA1	:= cEmailSA1+';'+alltrim(SA1->A1_XEMAIL)
			endif

			IF Alltrim(cEmailSA1) <> ""
				//U_MANWS008('tic@manfil.com.br', "tic@manfil.com.br", "", cAssunto, _aAnexo,, ,"3",aDados)
				//U_MANWS008(cEmailSA1, "tic@manfil.com.br;faturamento@manfil.com.br;administrativo01@manfil.com.br;administrativo02@manfil.com.br;administrativo03@manfil.com.br;administrativo04@manfil.com.br;administrativo05@manfil.com.br;valdirene@manfil.com.br;flavia@manfil.com.br", "", cAssunto, _aAnexo,, ,"3",aDados)
				U_MANWS008(cEmailSA1, "", "tic@manfil.com.br;faturamento@manfil.com.br;administrativo01@manfil.com.br;administrativo02@manfil.com.br;administrativo03@manfil.com.br;administrativo04@manfil.com.br;administrativo05@manfil.com.br;administrativo06@manfil.com.br;administrativo07@manfil.com.br;administrativo08@manfil.com.br;flavia@manfil.com.br", cAssunto, _aAnexo,, ,"3",aDados)
			EndIF

			ferase('\#PDF\'+cXml)
			ferase(_cPasta+Alltrim(cXml))
			ferase('\#PDF\'+cDanfe)
			ferase(_cPasta+Alltrim(cDanfe))
			if lBolet
				ferase('\#PDF\'+cBoleto)
				ferase(_cPasta+Alltrim(cBoleto))
			endif
		endif
	else
	
		MsgAlert("Nota fiscal de numero: "+cNF+" serie: "+cSerie+" especie: "+alltrim(SF2->F2_ESPECIE)+" nao sera enviada pois a mesma ainda nao foi autorizada na SEFAZ")
	endif

return

User Function SpedMNTNF(cAlias)

	Local cIdEnt     := ""
	Local cMensagem  := ""
	Local oWS
	Private cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)

	If IsReady()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o codigo da entidade                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cIdEnt := GetIdEnt()
		If !Empty(cIdEnt)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Instancia a classe                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cIdEnt)

				oWs:= WsNFeSBra():New()
				oWs:cUserToken   := "TOTVS"
				oWs:cID_ENT      := cIdEnt
				oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
				oWs:cNFECONSULTAPROTOCOLOID := IIF(cAlias=="SF1",SF1->F1_SERIE+SF1->F1_DOC,SF2->F2_SERIE+SF2->F2_DOC)
				If oWs:ConsultaProtocoloNfe()
					cMensagem := ""
					If !Empty(oWs:oWSCONSULTAPROTOCOLONFERESULT:cVERSAO)
						cMensagem += oWs:oWSCONSULTAPROTOCOLONFERESULT:cVERSAO+CRLF
					EndIf
					cMensagem += IIf(oWs:oWSCONSULTAPROTOCOLONFERESULT:nAMBIENTE==1,"Produção","Homologação")+CRLF //"Produção"###"Homologação"
					cMensagem += oWs:oWSCONSULTAPROTOCOLONFERESULT:cCODRETNFE+CRLF
					cMensagem += oWs:oWSCONSULTAPROTOCOLONFERESULT:cMSGRETNFE+CRLF
					If !Empty(oWs:oWSCONSULTAPROTOCOLONFERESULT:cPROTOCOLO)
						cMensagem+= oWs:oWSCONSULTAPROTOCOLONFERESULT:cPROTOCOLO+CRLF
					EndIf
					//	Aviso(STR0107,cMensagem,{STR0114},3)
					If !Empty(oWs:oWSCONSULTAPROTOCOLONFERESULT:cPROTOCOLO)
						Do Case
						Case cAlias == "SF1" .And. SF1->(FieldPos("F1_FIMP"))<>0
							RecLock("SF1")
							SF1->F1_FIMP := "S"
							MsUnlock()
						Case cAlias == "SF2"
							RecLock("SF2")
							SF2->F2_FIMP := "S"
							MsUnlock()
						EndCase
					EndIf
					If oWs:oWSCONSULTAPROTOCOLONFERESULT:cCODRETNFE $ RetCodDene() // Uso Denegado
						Do Case
						Case cAlias == "SF1" .And. SF1->(FieldPos("F1_FIMP"))<>0
							RecLock("SF1")
							SF1->F1_FIMP := "D"
							MsUnlock()
						Case cAlias == "SF2"
							RecLock("SF2")
							SF2->F2_FIMP := "D"
							MsUnlock()
						EndCase
					EndIf
				Else
					//	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
				EndIf
			EndIf
		Else
			//("SPED",STR0021,{STR0114},3)	 //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
		EndIf
	Else
		//	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf

Return

Static Function IsReady(cURL,nTipo,lHelp)

	Local nX       := 0
	Local cHelp    := ""
	Local oWS
	Local lRetorno := .F.
	DEFAULT nTipo := 1
	DEFAULT lHelp := .F.
	If !Empty(cURL) .And. !PutMV("MV_SPEDURL",cURL)
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "MV_SPEDURL"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "URL SPED NFe"
		MsUnLock()
		PutMV("MV_SPEDURL",cURL)
	EndIf
	SuperGetMv() //Limpa o cache de parametros - nao retirar
	DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o servidor da Totvs esta no ar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oWs := WsSpedCfgNFe():New()
	oWs:cUserToken := "TOTVS"
	oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	If oWs:CFGCONNECT()
		lRetorno := .T.
	Else
		If lHelp
//		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
		EndIf
		lRetorno := .F.
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o certificado digital ja foi transferido                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo <> 1 .And. lRetorno
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := GetIdEnt()
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		If oWs:CFGReady()
			lRetorno := .T.
		Else
			If nTipo == 3
				cHelp := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
				If lHelp .And. !"003" $ cHelp
					///	Aviso("SPED",cHelp,{STR0114},3)
					lRetorno := .F.
				EndIf
			Else
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o certificado digital ja foi transferido                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo == 2 .And. lRetorno
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := GetIdEnt()
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		If oWs:CFGStatusCertificate()
			If Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0
				For nX := 1 To Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE)
					If oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nx]:DVALIDTO-30 <= Date()

						//	Aviso("SPED",STR0127+Dtoc(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO),{STR0114},3) //"O certificado digital irá vencer em: "

					EndIf
				Next nX
			EndIf
		EndIf
	EndIf

Return(lRetorno)


/*/
	±±³Descri‡…o ³Obtem o codigo da entidade apos enviar o post para o Totvs  ³±±
	±±³          ³Service                                                     ³±±
	±±³Retorno   ³ExpC1: Codigo da entidade no Totvs Services                 ³±±
/*/
Static Function GetIdEnt(lConsulta)

	Local aArea  := GetArea()
	Local cIdEnt := ""
	Local oWs
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SM0")
	dbSetOrder(1)
	dbSeek(cEmpAnt + cFilAnt)


	oWS 						:= WsSPEDAdm():New()
	oWS:cUSERTOKEN 				:= "TOTVS"

	oWS:oWSEMPRESA:cCNPJ       	:= IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cCPF        	:= IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         	:= SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         	:= SM0->M0_INSCM
	oWS:oWSEMPRESA:cNOME       	:= SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   	:= SM0->M0_NOME
	oWS:oWSEMPRESA:cENDERECO   	:= FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        	:= FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      	:= FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         	:= SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        	:= SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    	:= SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   	:= "1058"
	oWS:oWSEMPRESA:cBAIRRO     	:= SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        	:= SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     	:= Nil
	oWS:oWSEMPRESA:cCP         	:= Nil
	oWS:oWSEMPRESA:cDDD        	:= Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       	:= AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        	:= AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      	:= UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       	:= SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       	:= SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        	:= IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  	:= ""
	oWS:oWSEMPRESA:cID_MATRIZ  	:= ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL 					:= AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else
		if lConsulta
			//Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{""},3)
		endif
	EndIf

	RestArea(aArea)

Return(cIdEnt)


/*User Function ImpDanfe(_pcNf,_pcSerie)

Local cIdEnt 
Local aIndArq   	:= {}
Local oDanfe
Local nHRes  		:= 0
Local nVRes  		:= 0
Local nDevice
Local cFilePrint 
Local oSetup
Local aDevice   	:= {}
Local cSession  	:= GetPrinterSession()
Local nRet 			:= 0
Local cProfile      := ""
Private cPerg       := "PRGLT304"
Private cURL      	:= PadR(GetMv("MV_SPEDURL"),250)
Private _lEntrada := .F.
Private _cAlias := GetNextAlias()
Private cDevice := ""
Private aNFImp	:={_pcNf,_pcSerie}
Private cDanfe  

cIdEnt 		:= GetIdEnt()
cFilePrint 	:= "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
cDevice		:=  "PDF"
cDanfe  := cFilePrint

AADD(aDevice,"DISCO") // 1
AADD(aDevice,"SPOOL") // 2
AADD(aDevice,"EMAIL") // 3
AADD(aDevice,"EXCEL") // 4
AADD(aDevice,"HTML" ) // 5
AADD(aDevice,"PDF"  ) // 6

Pergunte("NFSIGW",.F.)

MV_PAR01 := _pcNf
MV_PAR02 := _pcNf
MV_PAR03 := _pcSerie
MV_PAR04 := If(_lEntrada, 1, 2 )



nLocal       	:= 2
nOrientation 	:= 1
//cDevice     	:= "PDF" //"SPOOL"

nPrintType      := aScan(aDevice,{|x| x == cDevice })


dbSelectArea("SF2")
RetIndex("SF2")
dbClearFilter()


lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
lDisableSetup   := .T.

oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, , lDisableSetup,,,,,,,lViewPDF)

oDanfe:cPathPDF := "C:\TEMP\"
// ----------------------------------------------
// Cria e exibe tela de Setup Customizavel
// OBS: Utilizar include "FWPrintSetup.ch"
// ----------------------------------------------
//nFlags := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN

	oSetup := FWPrintSetup():New(nFlags, "DANFE")
	// ----------------------------------------------
	// Define saida
	// ----------------------------------------------
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , nOrientation)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)
	
	oSetup:AOPTIONS[4]	:= 1//Seta como sugestao duas copias do DANFE
	oSetup:AOPTIONS[6]	:= "C:\TEMP\"//Seta como sugestao duas copias do DANFE
	oSetup:CQTDCOPIA	:= '01'
	


// ----------------------------------------------
// Pressionado botão OK na tela de Setup
// ----------------------------------------------
//If oSetup:Activate() == PD_OK // PD_OK =1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva os Parametros no Profile             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	WriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
	WriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==1   ,"SPOOL"     ,"PDF"       ), .T. )
	WriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
	
	If oSetup:GetProperty(PD_ORIENTATION) == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Danfe Retrato DANFEII.PRW                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		//Para que seja possivel imprimir no DANFE a impressao de acordo com o numero de copias fornecidas
		oDanfe:NQTDCOPIES:= Val(oSetup:CQTDCOPIA)
		
		u_PrtNfeSef(cIdEnt,,,oDanfe, oSetup, cFilePrint,,,.T.)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Danfe Paisagem DANFEIII.PRW                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		u_DANFE_P1(cIdEnt,,,oDanfe, oSetup)
	EndIf
	

Else
	
	MsgInfo("Impressao do Danfe cancelada pelo usuário.")
	Pergunte("NFSIGW",.F.)
	//bFiltraBrw := {|| FilBrowse(aFilBrw[1],@aIndArq,@aFilBrw[2])}
	//Eval(bFiltraBrw)                                                     
	Return
	
Endif

oDanfe := Nil
oSetup := Nil

Return(cDanfe)

*/

static function pBuscaDado(pSerie, pNota, pParcela)

	local	aDados		:= {8,4},;
			aParcela	:= {},;
			nValor		:= 0,;
			nLinha		:= 0

	local 	aArea		:= getArea(),;
			aAreaSF2	:= SF2->(getArea()),;
			aAreaSA1	:= SA1->(getArea()),;
			aAreaSE1	:= SE1->(getArea()),;
			aAreaSD2	:= SD2->(getArea())

	dbSelectArea('SF2')
	SF2->(dbSetOrder(1))
	SF2->(dbGoTop())
	if (SF2->(dbSeek(xFilial('SF2')+pNota+pSerie)))

		nValor	:= U_xVlNota(SF2->F2_SERIE,SF2->F2_DOC)
		aadd(aDados,SF2->F2_FILIAL)
		aadd(aDados,SF2->F2_SERIE)
		aadd(aDados,SF2->F2_DOC)
		aadd(aDados,SF2->F2_EMISSAO)
		aadd(aDados,SF2->F2_CLIENTE)
		aadd(aDados,SF2->F2_LOJA)
		dbSelectArea('SA1')
		SA1->(dbSetOrder(1))
		SA1->(dbGoTop())
		if (SA1->(dbSeek(xFilial('SA1')+SF2->F2_CLIENTE+SF2->F2_LOJA)))
			aadd(aDados,SA1->A1_NOME)
		else
			aadd(aDados,'????????')
		end
		SA1->(dbCloseArea())
		aadd(aDados,nValor)

		aParcela	:= {}
		dbSelectArea('SE1')
		SE1->(dbSetOrder(1))
		SE1->(dbGoTop())
		SE1->(dbSeek(xFilial('SE1')+SF2->F2_SERIE+SF2->F2_DOC+pParcela))
		while !SE1->(eof()) .and. SE1->E1_PREFIXO == SF2->F2_SERIE .and. SE1->E1_NUM == SF2->F2_DOC

			if !empty(pParcela)

				if SE1->E1_PARCELA == pParcela

					nLinha	:= len(aParcela)+1
					aadd(aParcela,array(5))
					aParcela[nLinha][5]		:= .F.
					nLinha:= len(aParcela)
					aParcela[nLinha,1]		:= dtoc(SE1->E1_EMISSAO)
					aParcela[nLinha,2]		:= SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA
					aParcela[nlinha,3]		:= dtoc(SE1->E1_VENCTO)
					aParcela[nlinha,4]		:= SE1->E1_VALOR

				endif

			else

				nLinha	:= len(aParcela)+1
				aadd(aParcela,array(5))
				aParcela[nLinha][5]		:= .F.
				nLinha:= len(aParcela)
				aParcela[nLinha,1]		:= dtoc(SE1->E1_EMISSAO)
				aParcela[nLinha,2]		:= SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA
				aParcela[nlinha,3]		:= dtoc(SE1->E1_VENCTO)
				aParcela[nlinha,4]		:= SE1->E1_VALOR

			endif

			SE1->(dbSkip())

		enddo
		aadd(aDados,aParcela)

	endif
	SF2->(dbCloseArea())

	restArea(aAreaSD2)
	restArea(aAreaSE1)
	restArea(aAreaSA1)
	restArea(aAreaSF2)
	restArea(aArea)

return aDados
