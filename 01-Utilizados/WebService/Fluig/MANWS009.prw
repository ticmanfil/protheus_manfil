#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.Ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "totvswebsrv.ch"
#include 'prtopdef.ch'

user Function _FTNRRNN ; Return  // "dummy" function - Internal Use 

	/* -------------------------------------------------------------------------------
	WSDL Service WSU_WSCEPINFO
	------------------------------------------------------------------------------- */

	WSCLIENT WSU_WSCEPINFO

		WSMETHOD NEW
		WSMETHOD INIT
		WSMETHOD RESET
		WSMETHOD CLONE
		WSMETHOD CEPSEARCH

		WSDATA   _URL                      AS String
		WSDATA   cCEP                      AS string
		WSDATA   cCEPSEARCHRESULT          AS string

	ENDWSCLIENT

	WSMETHOD NEW WSCLIENT WSU_WSCEPINFO
		::Init()
		If !FindFunction("XMLCHILDEX")
		UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.090818P-20100111] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
		EndIf
		Return Self

		WSMETHOD INIT WSCLIENT WSU_WSCEPINFO
	Return

	WSMETHOD RESET WSCLIENT WSU_WSCEPINFO
		::cCEP               := NIL 
		::cCEPSEARCHRESULT   := NIL 
		::Init()
	Return

	WSMETHOD CLONE WSCLIENT WSU_WSCEPINFO
		Local	oClone := WSU_WSCEPINFO():New()
				oClone:_URL          := ::_URL 
				oClone:cCEP          := ::cCEP
				oClone:cCEPSEARCHRESULT := ::cCEPSEARCHRESULT
	Return oClone

	// WSDL Method CEPSEARCH of Service WSU_WSCEPINFO

	WSMETHOD CEPSEARCH WSSEND cCEP WSRECEIVE cCEPSEARCHRESULT WSCLIENT WSU_WSCEPINFO
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD

		cSoap += ''
		cSoap += WSSoapValue("CEP", ::cCEP, cCEP , "string", .T. , .F., 0 , NIL, .F.) 
		cSoap += ""

		oXmlRet := SvcSoapCall( Self,cSoap,; 
		"http://localhost/naldo/ws/u_wscepinfo.apw/CEPSEARCH",; 
		"DOCUMENT","http://localhost/naldo/ws/u_wscepinfo.apw",,"1.031217",; 
		"http://187.94.60.197:98/ws/U_WSCEPINFO.apw")

		::Init()
		::cCEPSEARCHRESULT   :=  WSAdvValue( oXmlRet,"_CEPSEARCHRESPONSE:_CEPSEARCHRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL

return .T.
