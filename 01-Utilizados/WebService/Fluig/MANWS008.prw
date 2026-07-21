#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"   
#INCLUDE "TBICONN.CH"

/*пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДїпїЅпїЅ
пїЅпїЅпїЅPrograma  пїЅ  U_EnvMail пїЅ Autor пїЅ MARCIO R. LAPIDUSAS пїЅ Data пїЅ 15/05/13 пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДґпїЅпїЅ
пїЅпїЅпїЅLocacao   пїЅ  GENERICO  пїЅContatoпїЅ MLAPIDUSAS@GMAIL.COM                  пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДґпїЅпїЅ
пїЅпїЅпїЅDescricao пїЅ ROTINA PADRAO PARA ENVIO DE E-MAIL CONFORME PARAMETROS     пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДґпїЅпїЅ
пїЅпїЅпїЅParametrosпїЅ Parametro Tipo Descricao                                   пїЅпїЅпїЅ 
пїЅпїЅпїЅ          пїЅ _cPara    C                                                пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ _cCc      C                                                пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ _cBCC     C                                                пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ _cTitulo  C                                                пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ _aAnexo   A                                                пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ _cMsg     C                                                пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ _lAudit   L                                                пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДґпїЅпїЅ
пїЅпїЅпїЅRetorno   пїЅ LOGICO -> (.T.) ENVIO OK / (.F.) FALHA NO ENVIO            пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДґпїЅпїЅ
пїЅпїЅпїЅAplicacao пїЅ GENERICO                                                   пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДґпїЅпїЅ
пїЅпїЅпїЅUso       пїЅ ADICIONAR A TAG ABAIXO NO APPSERVER CASO HAJA PROBLEMAS:   пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ    [MAIL]                                                  пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ    AUTHLOGIN=1                                             пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ    AUTHNTLM=0                                              пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ    ExtendSMTP=1                                            пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ    Protocol=POP3                                           пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДґпїЅпїЅ
пїЅпїЅпїЅAnalista Resp.    пїЅ  Data  пїЅ Manutencao Efetuada                       пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅДґпїЅпїЅ
пїЅпїЅпїЅ MARCIO LAPIDUSAS пїЅ15/05/13пїЅ -Desenvolvimento da rotina U_EnvMail();   пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅЩ±пїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ*/
User Function MANWS008(_cPara, _cCc, _cBCC, _cTitulo, _aAnexo, _cMsg, _lAudit,cHtml,aDados)

Local _nX	:= 0

Private oMail
Private oMessage
Private nRet   


Private nTimeout := GetMV("MV_RELTIME")	//Timeout no Envio de E-Mail;
Private cServer  := GetMV("MV_RELSERV")	//Nome do Servidor de Envio de E-Mail utilizado nos relatorios;
Private cEmail   := GetMV("MV_RELACNT")	//Conta a ser utilizada no envio de E-Mail para os relatorios;
Private cEmailA  := GetMV("MV_RELAUSR") //GetMV("MV_RELAUSR")	//Usuario para Autenticacao no Servidor de E-Mail;
Private cEmailFr := GetMV("MV_RELFROM")	//E-Mail utilizado no campo FROM no envio de relatorios por E-Mail;
Private cPass    := GetMV("MV_RELPSW")	//Senha da Conta de E-Mail para envio de relatorios;
Private lAuth    := GetMv("MV_RELAUTH")	//Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor necessita de Autenticacao;
Private cMailAud := GetMv("MV_MAILADT")	//Conta oculta de auditoria utilizada no envio de E-Mail para os relatorios;
Private lUseSSL  := GetMv("MV_RELSSL")	//Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao segura (SSL);
Private lUseTLS  := GetMv("MV_RELTLS")	//Informe se o servidor de SMTP possui conexao do tipo segura (SSL/TLS);
Private _nPorta  := 465			//Porta Default 25;


DEFAULT _cPara		:= "tic@manfil.com.br"
DEFAULT _cCc		:= "tic@manfil.com.br"
DEFAULT _cBCC		:= ""
DEFAULT _cMsg		:= ""
DEFAULT _aAnexo		:= {}
DEFAULT _cTitulo	:= ""
DEFAULT _lAudit		:= .F.
DEFAULT cHtml		:= '1'
DEFAULT aDados		:= {}

//Alert('cEmail: '+cEmail+' cEmailA: '+cEmailA+' cEmailFr: '+cEmailFr+' cPass: '+cPass)
//Alert('_cPara: '+_cPara+' _cCc: '+_cCc+' _cBCC: '+_cBCC)
//alert('Anexo: '+_aAnexo[0][1])

	/*----------+-----------------------------------------------------------------------------+----------------------+----------------------+
	| PARAMETRO | DESCRICAO                                                                   | EXEMPLO E-MAIL TOTVS | EXEMPLO E-MAIL GMAIL |
	+-----------+-----------------------------------------------------------------------------+----------------------+----------------------+
	|*MV_RELTIME |Timeout no Envio de E-Mail; .................................................|120                   |120                   |
	|*MV_RELSERV |Nome do Servidor de Envio de E-Mail utilizado nos relatorios; ...............|mail.totvs.com.br:587 |smtp.gmail.com:465    |
	|*MV_RELACNT |Conta a ser utilizada no envio de E-Mail para os relatorios; ................|usuario               |usuario@gmail.com     |
	|MV_RELAUSR |Usuario para Autenticacao no Servidor de E-Mail; ............................|usuario               |usuario@gmail.com     |
	|MV_RELFROM |E-Mail utilizado no campo FROM no envio de relatorios por E-Mail; ...........|usuario@totvs.com.br  |usuario@gmail.com     |
	|MV_RELPSW  |Senha da Conta de E-Mail para envio de relatorios; ..........................|*** senha ***         |*** senha ***         |
	|MV_RELAUTH |Servidor de E-Mail necessita de Autenticacao? Determina se o Servidor........|.T.                   |.T.                   |
	|           |necessita de Autenticacao; ..................................................|                      |                      |
	|MV_MAILADT |Conta oculta de auditoria utilizada no envio de E-Mail para os relatorios; ..|email@dominio.com.br  |email@dominio.com.br  |
	|MV_RELSSL  |Define se o envio e recebimento de E-Mail na rotina SPED utilizara conexao...|.F.                   |.T.                   |
	|           |segura (SSL); ...............................................................|                      |                      |
	|MV_RELTLS  |Informe se o servidor de SMTP possui conexao do tipo segura (SSL/TLS); ......|.T.                   |.F.                   |
	+-----------+-----------------------------------------------------------------------------+----------------------+---------------------*/

	ProcRegua(15)

	//---------------------------------------------------------------------------------------------------------------------
	//VALIDANDO OS PARAMETROS INFORMADOS
	If Empty(cServer) .OR. Empty(cEmail) /*.OR. Empty(cEmailA)*/ .OR. Empty(cPass)
		CONOUT("Verifique os parametros: MV_RELSERV, MV_RELACNT, MV_RELAUSR ou MV_RELPSW!!!","Funcao EnvMail","STOP") 
		Return(.F.)
	EndIf

	If Empty(_cPara)
		CONOUT("Parametro 'Para' tem preenchimento obrigatorio!!!","Funcao EnvMail","STOP") 
		Return(.F.)
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CASO O ENDERECO DO SERVER TENHA A PORTA INFORMADA, SEPARA OS CAMPOS
	If(At(":",cServer) > 0)
		_nPorta := Val(Substr(cServer,At(":",cServer)+1,Len(cServer)))
		cServer := Substr(cServer,0,At(":",cServer)-1)
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CRIA UMA INSTANCIA DA CLASSE TMAILMANAGER
	oMail := TMailManager():New()
	If(lUseSSL)
		oMail:SetUseSSL(lUseSSL)
	EndIf
	If(lUseTLS)
		oMail:SetUseTLS(lUseTLS)
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//DEFINE AS CONFIGURACOES, DA CLASSE TMAILMANAGER, PARA REALIZAR UMA CONEXAO COM O SERVIDOR DE E-MAIL
	//oMail:Init("",cServer,cEmail,cPass,0,_nPorta)
	oMail:Init("",cServer,cEmail,cPass,,_nPorta)

	//---------------------------------------------------------------------------------------------------------------------
	//DEFINE O TEMPO DE ESPERA PARA UMA CONEXAO ESTABELECIDA COM O SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL)
	If (nTimeout <= 0)
		ConOut("[TIMEOUT] DISABLE")
	Else
		IncProc("[TIMEOUT] ENABLE()")
		ConOut("[TIMEOUT] ENABLE()")
		nRet := oMail:SetSmtpTimeOut(nTimeout)

		If nRet != 0
			ConOut("[TIMEOUT] Fail to set")
			ConOut("[TIMEOUT][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
			MsgBox("[TIMEOUT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
			oMail:SMTPDisconnect()
			Return(.F.)
		EndIf
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//CONECTA COM O SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL)
	IncProc("[SMTPCONNECT] connecting ...")
	ConOut("[SMTPCONNECT] connecting ...")
	nRet := oMail:SmtpConnect()
	If nRet <> 0
		ConOut("[SMTPCONNECT] Falha ao conectar")
		ConOut("[SMTPCONNECT][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
		MsgBox("[SMTPCONNECT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
		oMail:SMTPDisconnect()
		Return(.F.)
	Else
		ConOut("[SMTPCONNECT] Sucesso ao conectar")
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//REALIZA A AUTENTICACAO NO SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL) PARA ENVIO DE MENSAGENS
	
	If lAuth
		IncProc("[AUTH] ENABLE")
		ConOut("[AUTH] ENABLE")
		ConOut("[AUTH] TRY with ACCOUNT() and PASS()")

		nRet := oMail:SMTPAuth(cEmailA,cPass)
		If nRet != 0
			IncProc("[AUTH] FAIL TRY with ACCOUNT() and PASS()")
			ConOut("[AUTH] FAIL TRY with ACCOUNT() and PASS()")
			ConOut("[AUTH][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
			ConOut("[AUTH] TRY with USER() and PASS()")
			MsgBox("[AUTH][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
			nRet := oMail:SMTPAuth(cEmailA,cPass)

			If nRet != 0
				ConOut("[AUTH] FAIL TRY with USER() and PASS()")
				ConOut("[AUTH][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
				MsgBox("[AUTH][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
				oMail:SMTPDisconnect()
				Return(.F.)
			Else
				IncProc("[AUTH] SUCEEDED TRY with USER() and PASS()")
				ConOut("[AUTH] SUCEEDED TRY with USER() and PASS()")
			EndIf
		Else
			IncProc("[AUTH] SUCEEDED TRY with ACCOUNT and PASS")
			ConOut("[AUTH] SUCEEDED TRY with ACCOUNT and PASS")
		EndIf
	Else
		IncProc("[AUTH] DISABLE")
		ConOut("[AUTH] DISABLE")
	EndIf
    
	//---------------------------------------------------------------------------------------------------------------------
	//CRIA UMA INSTANCIA DA CLASSE TMAILMANAGER
	IncProc("[MESSAGE] Criando mail message")
	ConOut("[MESSAGE] Criando mail message")
	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom    := cEmailFr
	oMessage:cTo      := _cPara
	oMessage:cCc      := _cCc
	oMessage:cBCC     := _cBCC
	oMessage:cSubject := _cTitulo
	oMessage:SetConfirmRead(.T.)
	//oMessage:AddCustomHeader( "Disposition-Notification-To", "tic@manfil.com.br")
	//oMessage:cBody    := _cMsg
	oMessage:cBody    := RetHtml(cHtml,aDados) //"<hr>Envio de e-mail via Protheus<hr>"

	For _nX := 1 to Len(_aAnexo)
		oMessage:AddAttHTag("Content-ID: <" + _aAnexo[_nX] + ">")	//Essa tag, пїЅ a referecia para o arquivo ser mostrado no corpo, o nome declarado nela deve ser o usado no HTML
		oMessage:AttachFile("\#PDF\"+Alltrim(_aAnexo[_nX]))							//Adiciona um anexo, nesse caso a imagem esta no root
	Next _nX
	oMessage:MsgBodyType("text/html")

	//---------------------------------------------------------------------------------------------------------------------
	//ENVIA E-MAIL ATRAVГ‰S DO PROTOCOLO SMTP
	IncProc("[SEND] Sending ...")
	ConOut("[SEND] Sending ...")
	nRet := oMessage:Send(oMail)
	If nRet <> 0
		ConOut("[SEND] Fail to send message")
		ConOut("[SEND][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
		MsgBox("[SEND][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
		oMail:SMTPDisconnect()
		Return(.F.)
	Else
		IncProc("[SEND] Success to send message")
		ConOut("[SEND] Success to send message")
	EndIf

	//---------------------------------------------------------------------------------------------------------------------
	//FINALIZA A CONEXAO ENTRE A APLICACAO E O SERVIDOR DE E-MAIL SMTP (SIMPLE MAIL TRANSFER PROTOCOL)
	IncProc("[DISCONNECT] smtp disconnecting ... ")
	ConOut("[DISCONNECT] smtp disconnecting ... ")
	oMail:SMTPDisconnect()
	If nRet != 0
		IncProc("[DISCONNECT] Fail smtp disconnecting ... ")
		ConOut("[DISCONNECT] Fail smtp disconnecting ... ")
		ConOut("[DISCONNECT][ERROR] " + str(nRet,6) , oMail:GetErrorString(nRet))
		ConOut("[DISCONNECT][ERROR] " + str(nRet,6) + " - " + oMail:GetErrorString(nRet),"Funcao EnvMail","STOP")
	Else
		IncProc("[DISCONNECT] Success smtp disconnecting ... ")
		ConOut("[DISCONNECT] Success smtp disconnecting ... ")
	EndIf

Return(.T.)


Static Function RetHtml(cHtml,aDados)
Local _cRetorno := "",;
		i		:= 0

IF cHtml = '1'
	_cRetorno := "<html>"   
	_cRetorno += "<head>"
	_cRetorno += "<style type='text/css'>"
	_cRetorno += "<!--"
	_cRetorno += "p {margin-right: 200px; margin-left: 10px; text-align: justify; font-size: 1.5em;}"
	_cRetorno += "h1 {margin-right: 200px; margin-left: 10px; text-align: justify; font-size: 1em}"
	_cRetorno += "-->"
	_cRetorno += "</style>"
	_cRetorno += "</head>"
	_cRetorno += '  <img style='+"-webkit-user-select: none"+" src="+"http://www.manfil.com.br/views/imgs/logo.png>"
	_cRetorno += "  <table>"
	_cRetorno += "    <tr>"
	_cRetorno += "      <td style='color:#7F7F7F'>"
	
	_cRetorno += "	      <p>O orзamento abaixo foi LIBERADO para FATURAMENTO:</p>" 
	_cRetorno += "	      <p>Num..: "+aDados[1]+"</p> 
	_cRetorno += "	      <p>Cliente.: "+aDados[5]+"-"+aDados[6]+"-"+aDados[2]+"</p>
	_cRetorno += "	      <p>Vendedor: "+aDados[7]+"-"+aDados[3]+"</p> 
	_cRetorno += "	      <p>Total Orзamento: R$"+TRANSFORM(aDados[8], "@E 999,999,999.99")+"</p> 
	//_cRetorno += "	      <p>Valor Total..: R$ </p> 
	
	
	_cRetorno += "	      <p><strong>TIC - Manfil</strong></p>"
	_cRetorno += "	      <p><strong>Tecnologia, Informaзгo e Comunicaзгo</strong></p>"
	_cRetorno += "        "
	_cRetorno += "        </i></h1></p>"
	_cRetorno += "      </td>"
	_cRetorno += "    </tr>"
	_cRetorno += " </table>"
	_cRetorno += "</html>"
ElseIF cHtml = '2'
	_cRetorno := "<html>"   
	_cRetorno += "<head>"
	_cRetorno += "<style type='text/css'>"
	_cRetorno += "<!--"
	_cRetorno += "p {margin-right: 200px; margin-left: 10px; text-align: justify; font-size: 1.5em;}"
	_cRetorno += "h1 {margin-right: 200px; margin-left: 10px; text-align: justify; font-size: 1em}"
	_cRetorno += "-->"
	_cRetorno += "</style>"
	_cRetorno += "</head>"
	_cRetorno += '  <img style='+"-webkit-user-select: none"+" src="+"http://www.manfil.com.br/views/imgs/logo.png>"
	_cRetorno += "  <table>"
	_cRetorno += "    <tr>"
	_cRetorno += "      <td style='color:#7F7F7F'>"
	
	_cRetorno += "	      <p>O orзamento abaixo foi solicitaзгo AUTORIZAЗГO para DESCONTO::</p>" 
	_cRetorno += "	      <p>Num..: "+aDados[1]+"                 Data Orзamento: "+dToc(dDataBase)+"</p> 
	_cRetorno += "	      <p>Cliente.: "+aDados[5]+"-"+aDados[6]+"-"+aDados[2]+"</p>
	_cRetorno += "	      <p>Vendedor: "+aDados[7]+"-"+aDados[3]+"</p> 
	_cRetorno += "	      <p>Total Orзamento: R$ "+TRANSFORM(aDados[8], "@E 999,999,999.99")+"</p> 
	_cRetorno += "	      <p>Motivo: "+aDados[4]+"</p> 
	//_cRetorno += "	      <p>Valor Total..: R$ </p> 
	
	
	_cRetorno += "	      <p><strong>TIC - Manfil</strong></p>"
	_cRetorno += "	      <p><strong>Tecnologia, Informaзгo e Comunicaзгo</strong></p>"
	_cRetorno += "        "
	_cRetorno += "        </i></h1></p>"
	_cRetorno += "      </td>"
	_cRetorno += "    </tr>"
	_cRetorno += " </table>"
	_cRetorno += "</html>"
ElseIF cHtml = '3'
	/**		Monta o script HTML para ser enviado por email 	**/        
	_cRetorno:="<html>"
	_cRetorno+="<head>"
	_cRetorno+="<STYLE TYPE='text/css'>"
	_cRetorno+="<!--"
	_cRetorno+="TD{font-family: Calibri; font-size: 7pt;} "
	_cRetorno+="--->"
	_cRetorno+="</STYLE>"
	_cRetorno+="</head>"
	_cRetorno+="<body>"
	
	//DADOS DA NOTA
	_cRetorno+="<table  border=0 cellpadding=0 width='100%' style='border:none'>"
	_cRetorno += "    <tr>"
	_cRetorno += "      <td style='text-align:rigth;font-size:13.0px;font-family:Calibri'>"
	_cRetorno += "	      <p>Conforme solicitado segue em anexo e abaixo descriзгo da FATURA e BOLETOS para programaзгo de pagamentos.</p>" 
	_cRetorno += "	      <p>Sйrie.......: "+aDados[4]+"          Nъm. Nota.: "+aDados[5]+"          Data Emissгo.: "+dtoc(aDados[6])+"</p>" 
	_cRetorno += "	      <p>Valor Total.: "+transform(aDados[10],'@E 999,999,999.99')+"          Cliente.: "+aDados[7]+"-"+aDados[8]+" - "+aDados[9]+"</p>" 
	_cRetorno += "      </td>"
	_cRetorno += "    </tr>"
	_cRetorno+="</table>"

	//TITULO
	_cRetorno+="<table  border=1 cellpadding=0 width='100%' style='border:none'>"
	_cRetorno+="<tr>"
	_cRetorno+="<td width='20%' style='border:none'><img width='250px' height='100px' id='_x0000_i1033' src='http://www.manfil.com.br/logo.jpg'  alt='http://www.manfil.com.br/'></td>"
	_cRetorno+="<td width='80%'><p align=center><b><span style=' text-align:center;font-size:16.0px;font-weight:bold;font-family:Calibri;color:#000000'>DEMONSTRATIVO DE FATURA</span></b></p></td>"
	_cRetorno+="</tr>"
	_cRetorno+="</table>"
	
	//CABECALHO DOS ITENS
	_cRetorno+="<table  BORDER=1 width='100%' height='92'  style='border-collapse:collapse;border:none;mso-border-alt:solid black .5pt;'>"       
	_cRetorno+="<tr  BGCOLOR='#000000'>" //D2DDD4' 8B8682
	//Alimenta os titulos
	_cRetorno+="<th  style='font-size:13.0px;font-family:Calibri;color:#FFFAFA'  scope='col'><b>FATURA</th>" // +cQLinha //FFFAFA 8B8682	 
	_cRetorno+="<th  style='font-size:13.0px;font-family:Calibri;color:#FFFAFA'  scope='col'><b>VENCTO</th>" // +cQLinha //FFFAFA 8B8682	 
	_cRetorno+="<th  style='font-size:13.0px;font-family:Calibri;color:#FFFAFA'  scope='col'><b>VALOR</th>" // +cQLinha //FFFAFA 8B8682	 
	_cRetorno+="</tr>"  
			
	//ITENS
	for  i:=1 to Len(aDados[11]) 
	
		if i % 2 == 1
			_cRetorno+="<tr  BGCOLOR='#F4A460'>" // ;  FFA500
		else              
		    _cRetorno+="<tr>"
		endif                                                                                                                                                                                                                                                        
		    
		_cRetorno+="<td style='text-align:rigth;font-size:13.0px;font-family:Calibri' >"+aDados[11][i][2]+"</td>"	//NUM FATURA 
		_cRetorno+="<td style='text-align:center;font-size:13.0px;font-family:Calibri' >"+aDados[11][i][3]+"</td>"	//VENCTO 
		_cRetorno+="<td style='text-align:rigth;font-size:13.0px;font-family:Calibri' >"+alltrim(Transform(aDados[11][i][4], '@E 999,999,999.99'))+"</td>"	//VALOR 
		_cRetorno+="</tr>"
			    
	next i
	
	_cRetorno+="</table>"
	
	//Rodapй
	_cRetorno+="<table  border=0 cellpadding=0 width='100%' style='border:none'>"
	_cRetorno += "    <tr>"
	_cRetorno += "      <td style='text-align:rigth;font-size:13.0px;font-family:Calibri'>"
	_cRetorno += "	      <p>Este e-mail foi enviado automaticamente pelo Sistema de Nota Fiscal Eletrфnica (NF-e ou NFC-e) da MANFIL COMERCIO INDUSTRIA DE FERRO E ACO LTDA.</p>" 
	_cRetorno += "	      <p><strong>Equipe MANFIL</strong></p>"
	_cRetorno += "	      <p><strong>Tecnologia, Informaзгo e Comunicaзгo</strong></p>"
	_cRetorno += "      </td>"
	_cRetorno += "    </tr>"
	_cRetorno+="</table>"

	_cRetorno+="</body>"
	_cRetorno+="</html>"   
	
EndIF

Return(_cRetorno)
