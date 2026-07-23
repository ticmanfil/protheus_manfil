#include 'protheus.ch'
#include 'FWMVCDef.ch'
/*/
===============================================================================================================================
Programa----------: MATA020
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 21/05/2019
===============================================================================================================================
Descrição---------: Este programa serve para acessar o PE da rotina MATA020
===============================================================================================================================
Uso---------------: MATA020
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGAFIN - FINANCEIRO
===============================================================================================================================
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
user function CUSTOMERVENDOR()
	local	aParam		:= PARAMIXB,;
			xRet		:= .T.,;
			oObj		:= '',;
			cIdPonto	:= '',;
			cIdModel	:= ''
						
	local cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))
	
	if aParam <> nil
		oObj		:= aParam[1]
		cIdPonto	:= aParam[2]
		cIdModel	:= aParam[3]

	/*	if cIdPonto == 'MENUDEF'
			xRet	:= {}
			aadd(xRet,{'Exp.p/Fornec.','U_RD06001' ,0,9})*/
			
		if cIdPonto == 'MODELPOS' 
			//ApMsgInfo('Chamada apos a gravação total do modelo e fora da transação (MODELCOMMITNTTS).' + CRLF + 'ID ' + cIdModel +;
			//			CRLF+Transform(SA1->A1_LC,'@E 999,999.99')+' -> '+Transform(M->A1_LC, '@E 999,999.99'))
	
			CadIContab(M->A2_COD, substr(M->A2_NOME,1,40))
			
/*		elseif cIdPonto == 'FORMPOS'
			ApMsgInfo('Chamada na validação total do formulário. (FORMPOS)' + CRLF + 'ID ' + cIdModel +;
						CRLF+Transform(M->A1_LC,'@E 999,999.99')+' -> '+Transform(SA1->A1_LC, '@E 999,999.99'))

		elseif cIdPonto == 'FORMLINEPRE'
			ApMsgInfo('Chamada na pré validação da linha do formulário. (FORMLINEPRE)' + CRLF + 'ID ' + cIdModel +;
						CRLF+Transform(M->A1_LC,'@E 999,999.99')+' -> '+Transform(SA1->A1_LC, '@E 999,999.99'))

		elseif cIdPonto == 'FORMLINEPOS'
			ApMsgInfo('Chamada na validação da linha do formulário. (FORMLINEPOS)' + CRLF + 'ID ' + cIdModel +;
						CRLF+Transform(M->A1_LC,'@E 999,999.99')+' -> '+Transform(SA1->A1_LC, '@E 999,999.99'))

		elseif cIdPonto == 'FORMLINEPOS'
			ApMsgInfo('Chamada na validação da linha do formulário. (FORMLINEPOS)' + CRLF + 'ID ' + cIdModel +;
						CRLF+Transform(M->A1_LC,'@E 999,999.99')+' -> '+Transform(SA1->A1_LC, '@E 999,999.99'))
*/
		endif
	endif
return xRet


static function CadIContab(cCodFor, cNome) 

	dbSelectArea('CTD')
	CTD->(dbSetOrder(1))
	CTD->(dbSeek(xFilial('CTD')+'F'+cCodFor))
	if !found()
		if RecLock('CTD',.T.)
			CTD->CTD_FILIAL	:= xFilial('CTD')
			CTD->CTD_ITEM	:= 'F'+cCodFor
			CTD->CTD_CLASSE	:= '2'
			CTD->CTD_DESC01	:= cNome
			CTD->CTD_BLOQ	:= '2'
			CTD->CTD_DTEXIS	:= DDATABASE
			CTD->CTD_ITLP	:= 'F'+cCodFor
			CTD->CTD_ITSUP	:= 'F'
			CTD->(msUnlock())
		endif
	else
		if RecLock('CTD',.F.)
			CTD->CTD_DESC01	:= cNome
			CTD->(msUnlock())
		endif
	endif

return nil