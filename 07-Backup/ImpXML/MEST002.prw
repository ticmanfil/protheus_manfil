#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MEST002   º Autor ³ Ramon Teles        º Data ³  00/00/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importa os arquivos XML para a rotina de geracao NFE       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MEST002()
Local aFiles := {}
Local nX	 := 0
Local i		 := 0   
Local oFullXML  := NIL
Local cError    := ""
Local cWarning  := ""     
Local lFound    := .F.          
Private aContas		:= {}
Private cIniFile	:= GetADV97()
Private cStartPath 	:= GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFEENT\ENTRADA\'
Private cStartLido	:= Trim(cStartPath)+"OLD\"
Private c2StartPath	:= Trim(cStartLido)+AllTrim(Str(Year(Date())))+"\" 
Private c3StartPath	:= Trim(c2StartPath)+AllTrim(Str(Month(Date())))+"\"	//MES    
Private c4StartPath := Trim(c3StartPath)+AllTrim(Str(Day(Date())))+"\"    //DIA
Private c5StartPath := Trim(c4StartPath)+alltrim(str(POSICIONE("SM0",1,cNumEmp,AllTrim(SM0->M0_CGC))))+"\"
Private cStartError	:= Trim(cStartPath)+"ERRO\"


//CRIA DIRETORIOS
MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\')
MakeDir(Trim(cStartPath)) //CRIA DIRETOTIO ENTRADA
MakeDir(cStartLido) //CRIA DIRETORIO ARQUIVOS IMPORTADOS
MakeDir(c2StartPath) //CRIA DIRETOTIO ANO
MakeDir(c3StartPath) //CRIA DIRETOTIO MES              
MakeDir(c4StartPath) //CRIA DIRETOTIO DIA 
MakeDir(c5StartPath) //CRIA DIRETOTIO CNPJ  

MakeDir(cStartError) //CRIA DIRETORIO ERRO

//aFiles := Directory(GetSrvProfString("RootPath","") +"\" +cStartPath2 +"*.xml")
aFiles := Directory(cStartPath+"*.xml")      
nQtdArray:=0
For i=1 to Len(aFiles)
if !VALTYPE(aFiles[i])=='U'
   
	If UPPER(SubStr(aFiles[i][1],Len(aFiles[i][1])-7,4)) = 'CNFE'
 		// Move arquivo de cancelamento para pasta dos erros
		cArqTXT := cStartPath+aFiles[i][1]
		//copia o arquivo antes da transacao
		cNomNovArq  := cStartError+aFiles[i][1]
		If MsErase(cNomNovArq)
			__CopyFile(cArqTXT,cNomNovArq)
			FErase(cStartPath+aFiles[i][1])
		EndIf
		aFiles[i]:=nil
		Loop
	EndIF
	oFullXML  := NIL
	cError    := ""
    cWarning  := ""
    lFound    :=.F. 
	/* if !SM0->M0_CGC == SUBSTRING(aFiles[i][1],7,14)                      lculo do juros 
    	ADEL(aFiles,i)                        
    	nQtdArray ++  
    	i:=0
    EndIf  */   
    oFullXML := XmlParserFile(cStartPath + aFiles[i][1],"_",@cError,@cWarning)
    oXML    := oFullXML
	oAuxXML := oXML
		
		//-- Resgata o no inicial da NF-e
		While !lFound
			oAuxXML := XmlChildEx(oAuxXML,"_NFE")
			If !(lFound := oAuxXML # NIL)
				For nX := 1 To XmlChildCount(oXML)
					oAuxXML  := XmlChildEx(XmlGetchild(oXML,nX),"_NFE")
					lFound := oAuxXML:_InfNfe # Nil
					If lFound
						oXML := oAuxXML
						Exit
					EndIf
				Next nX
			EndIf
			
			If lFound
				oXML := oAuxXML
				Exit
			EndIf
		EndDo
    
    If Type("oXML:_INFNFE:_DEST:_CNPJ") <> "U"
		cCNPJInf := oXML:_InfNfe:_Dest:_CNPJ:Text 
		
		if !cCNPJInf == SM0->M0_CGC 
			ADEL(aFiles,i)                        
	    	nQtdArray ++  
	    	i:=0
		EndIf

	ELSEIf Type("oXML:_INFNFE:_DEST:_CPF") <> "U"
	    MsgAlert("EXISTEM NOTAS DE PESSOA FISICA NO DIRETORIO DE ENTRADA DE XML! ","A T E N C A O !!!")
	EndIf
ENDIF
Next               
ASize(aFiles, Len(aFiles)-nQtdArray)



nXml := 0 
conout(" ")
conout(Replicate("=",80))
conout("Processando Arquivos..... ")
conout(Replicate("=",80))
iF Len(aFiles)>0

For nX := 1 To Len(aFiles)
	IF VALTYPE(aFiles[nX]) = 'A'
		conout(" ")
		conout(Replicate("=",80))
		conout(OemtoAnsi("O sistem possui "+StrZero(Len(aFiles) -nXML,8)+" arquivos(s) para processar") ) //###
		conout(Replicate("=",80))
		
		nXml++
		U_ReadXML(aFiles[nX,1],.F.)
		
		//QUANDO TIVER 500 XML SAI DA ROTINA, SENAO ESTOURA O ARRAY DO XML
		If nXml == 500
			Return
		EndIf
	 EndIF
Next nX
ENDIF

//RpcClearEnv()


Return
