#INCLUDE "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "protheus.ch"   
#include "shell.ch"
#DEFINE DIRXML  "NFEENT\"
#DEFINE DIRALER "NEW\"
#DEFINE DIRLIDO "OLD\"
#DEFINE DIRERRO "ERR\"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMEST 003  บ Autor ณ Ramon Teles        บ Data ณ  00/00/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Baixa Mensagens De NFE                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MEST003(cEmpresa,cFilix) 

	Local oMessage 
	Local oPopServer
	Local aAttInfo 
	Local cPopServer 
	Local cSmtpServer 
	Local cAccount 	  
	Local cPwd 	  
	Local nPortPop := 110 
	Local nPopResult := 0 
	Local nMessages := 0
	Local nMessage := 0
	Local lMessageDown := .F. 
	Local lWeb :=  .F.
	Local nCount := 0
	Local nAtach := 0 
	Local nMessageDown := 0
    Local _cLocal 
	Local nTam
	Local cIniFile 		
	Local cStartPath      
	Local cCaminho 
	Private cStartPath :="\system\NFEENT\NEW\"
	Default cEmpresa:='01'
	Default	cFilix:='060101'

	RpcSetType(3)
	If RpcSetEnv(cEmpresa,cFilix,,,"EST","MATA110")        
		ConOut("ImportXML")
		
		cPopServer		:=	GetMV("MV_C_POP") 
		cSmtpServer		:=	GetMV("MV_C_SMTP") 
		cAccount 		:=	GetMV("MV_C_USER")  
		cPwd 			:=	GetMV("MV_C_SENHA")  
		cIniFile 		:= GetADV97()
		
		If !ExistDir(DIRXML)     
			MakeDir(DIRXML)
			MakeDir(DIRXML +DIRALER)
			MakeDir(DIRXML +DIRLIDO)
			MakeDir(DIRXML +DIRERRO)
		EndIf
		//VERIFICA SE ESTA RODANDO VIA MENU OU SCHEDULE.
	           
		lWeb := .F. 	
		_cLocal := AllTrim(GetTempPath())	//Paga a pasta temporaria do usuario do sistema
	
		
		//cStartPath 	:= GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFEENT\ENTRADA\'
		
		//CRIA DIRETORIOS
		//MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFEENT\')
		//MakeDir(Trim(cStartPath)) //CRIA DIRETOTIO ENTRADA
		
	      
		ConOut('Conectando o servidor POP: '+cPopServer)
	 
	 	oPopServer := TMailManager():New() 
		//A informa็ใo do Servidor SMTP ้ irrelevante pois nใo ้ necessแrio enviar emails somente receber
		oPopServer:Init(cPopServer , cSmtpServer, cAccount, cPwd, nPortPop)     
		nPopResult := oPopServer:PopConnect()        
	     
		ConOut("Conectando...")
		If ( nPopResult == 0) 
			ConOut("Conectado...")
			//Conta quantas mensagens existem no servidor
			oPopServer:GetNumMsgs(@nMessages)
			nTam := nMessages              
			If( nMessages > 0 )           
				oMessage := TMailMessage():New()
				//Verifica todas mensagens no servidor 
				For nMessage := 1 To nMessages
					oMessage:Clear()
					nPopResult := oMessage:Receive( oPopServer, nMessage)
					Conout( oMessage:cFrom )
			        Conout( oMessage:cTo )
			        Conout( oMessage:cCc )
			        Conout( oMessage:cSubject )
			        
					If (nPopResult == 0 ) //Recebido com sucesso?
						nCount := 0 
						lMessageDown := .F.
						//Verifica todos anexos da mensagem e os salva  
						ConOut("Lendo Mensagem, anexos...")                
						ConOut(nMessage)  
						nQuantAne	:= oMessage:getAttachCount()  
						For nAtach := 1 to nQuantAne   
							ConOut(nAtach)
							aAttInfo:= oMessage:getAttachInfo(nAtach) 
							lSave:=.F.
						    lMove:=.F.
							IF Upper(SubStr(aAttInfo[1],At('.',aAttInfo[1])+1,3)) = 'XML'    //Verifica se a extensao do arquivo e XML
								lSave := oMessage:SaveAttach(nAtach, _cLocal+aAttInfo[1])
								IF lSave .and. !lWeb
									lMove:=CPYT2S(_cLocal+aAttInfo[1],"\" +DIRXML +DIRALER)
									IF lMove
										conout("Arquivo salvado com sucesso")
										cFile:=aAttInfo[1]
										lProces:=U_ReadXML(cFile,.T.)
										IF !lProces
											FErase("\" +DIRXML +DIRALER+aAttInfo[1])
											CPYT2S(_cLocal+aAttInfo[1],"\" +DIRXML +DIRERRO)
											FErase(_cLocal+aAttInfo[1])
										EndIF
									ENdIF
								Else 
									conout("Erro ao salvar arquivo")
								EndIF
							EndIF
						Next                                        
						nRet := oPopServer:DeleteMsg(nMessage) 
						If nRet == 0
				    		conout("Delete Successful")
				    		conout(nRet)
						Else
						    conout(nRet)
						    //conout(oMessage:GetErrorString(nRet))
						Endif
					EndIf
					If lMessageDown 
						nMessageDown++
					EndIf 
				Next
			EndIf  
			conout("Processado...")
			
			oPopServer:PopDisconnect()
		EndIf
		
	RESET ENVIRONMENT      
	RpcClearEnv()     
	
	EndIF
 
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTelaEmail บAutor  ณTotvs TM            บ Data ณ  12/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para configuracao dos parametros dos emails.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function TelaEmail()
Local oEmail
Local oSenha
Local oSPOP
Local oSSMTP
Local oFont1 := TFont():New("Britannic Bold",,028,,.F.,,,,,.F.,.F.)
Local oUsuario
Local _cUsuario := Alltrim(GETMV("MV_C_USER"))+Space(50-Len(Alltrim(GetMV("MV_C_USER"))))
Local _cEmail 	:= Alltrim(GetMV("MV_C_EMAIL"))+Space(50-Len(Alltrim(GetMV("MV_C_EMAIL"))))
Local _cSSMTP 	:= Alltrim(GETMV("MV_C_SMTP"))+Space(50-Len(Alltrim(GetMV("MV_C_SMTP"))))
Local _cSPOP 	:= Alltrim(GETMV("MV_C_POP"))+Space(50-Len(Alltrim(GetMV("MV_C_POP"))))
Local _cSenha 	:= Alltrim(GetMV("MV_C_SENHA"))+Space(15-Len(Alltrim(GetMV("MV_C_SENHA"))))

Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSButton1
Local oSButton2
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Parametros dos Emails" FROM 000, 000  TO 460, 500 COLORS 0, 16777215 PIXEL

    @ 009, 016 SAY oSay1 PROMPT "Parametros do e-mail utilizado para receber os XML das notas fiscais de entra para importa็ใo no sistema" SIZE 227, 047 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL
    @ 064, 010 SAY oSay2 PROMPT "Email" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 166, 010 SAY oSay3 PROMPT "Servidor SMTP" SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 137, 010 SAY oSay4 PROMPT "Servidor POP" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 110, 010 SAY oSay5 PROMPT "Senha" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 087, 010 SAY oSay6 PROMPT "Usuario" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 119, 010 MSGET oSenha VAR _cSenha SIZE 143, 010 OF oDlg COLORS 0, 16777215 PASSWORD PIXEL
    @ 146, 010 MSGET oSPOP VAR _cSPOP SIZE 143, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 073, 010 MSGET cEmail VAR _cEmail SIZE 145, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 173, 010 MSGET oSSMTP VAR _cSSMTP SIZE 143, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 095, 010 MSGET oUsuario VAR _cUsuario SIZE 143, 010 OF oDlg COLORS 0, 16777215 PIXEL
    DEFINE SBUTTON oSButton1 FROM 195, 074 TYPE 01 OF oDlg ENABLE ACTION Salvar(_cEmail, _cUsuario, _cSenha, _cSPOP, _cSSMTP)
    DEFINE SBUTTON oSButton2 FROM 195, 113 TYPE 02 OF oDlg ENABLE ACTION Close(oDlg)

  ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function Salvar (email, usuario, senha, pop, smtp)
Local nPortPop := 110 
	
	cPopServer := Alltrim(pop)
	cSmtpServer := Alltrim(smtp)
	cAccount := Alltrim(usuario)
	cPwd := Alltrim(senha)         
	ConOut('Conectando o servidor POP: '+cPopServer)
 
 	oPopServer := TMailManager():New() 
	//A informa็ใo do Servidor SMTP ้ irrelevante pois nใo ้ necessแrio enviar emails somente receber
	oPopServer:Init(cPopServer , cSmtpServer, cAccount, cPwd)
     
	ConOut("Conectando...")
	If ( (nPopResult := oPopServer:PopConnect()) == 0) 
        oPopServer:PopDisconnect()
		PutMV("MV_C_EMAIL",Alltrim(email))
		PutMV("MV_C_SENHA",Alltrim(senha))
		PutMV("MV_C_POP",Alltrim(pop))
		PutMV("MV_C_SMTP",Alltrim(smtp))
		PutMV("MV_C_USER",Alltrim(usuario))
		MsgInfo("Parametros alterados com exito!")
		Close(oDlg)      
	Else
	    MsgAlert("Dados nao validados favor conferir")
	EndIf
Return
