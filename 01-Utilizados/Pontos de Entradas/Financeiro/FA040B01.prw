#include 'protheus.ch'
#include 'parmtype.ch'

/*/
===============================================================================================================================
Programa----------: FA040B01
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 26/08/2019
===============================================================================================================================
Descrição---------: Este programa serve para AUDITAR EXCLUSAAO DE TITULOS A RECEBER
===============================================================================================================================
Uso---------------: Contas a Receber
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
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

user function FA040B01()

	local	cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))

	//local	cBCOTMP		:= Alltrim(GetMv("MV_XBCOTMP"))
	
	if cAmbiente == '1'	// ambiente 006
		if SE1->E1_TIPO == MVRECANT
			EnviaEmail()
		endif
  	endif
	
return .T.


static function EnviaEmail()

	local	_cTo			:= lower(AllTrim(GetMv('MV_RELACNT'))),;
			_cFrom			:= ' ',;	//'flavia@manfil.com.br;tic@manfil.com.br',; 	//alltrim(getMV('MV_XAUDITO')),;
			_cCopia			:= ' ',;
			_cCopiaOculta	:= ' ',;
			_cAssunto		:= ' ',;
			_cMensagem		:= ' ',;
			_lReturn		:= .F.
			
	_cFrom	:= u_Emails('000013')	//SUPERVISOR FINANCEIRO

	_cAssunto	:= OemToAnsi('[AUDIT-PROTHEUS] Exclusao de RA - Valor: R$ '+transform(SE1->E1_VALOR,'@E 999,999,999.99'))
	_cMensagem	:= OemToAnsi('Foi realizado EXCLUSAO DE RA segue dados do titulo abaixo: ') + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Código/Loja do Cliente..: ') + alltrim(SE1->E1_CLIENTE)+'-'+allTrim(SE1->E1_LOJA) +chr(10)+' Nome..: '+alltrim(SE1->E1_NOMCLI) + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Titulo: ' + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO + chr(10) + 'Emissao.: ' + dtoc(SE1->E1_EMISSAO) + chr(10) + 'Vencto.:' + dtoc(SE1->E1_VENCTO) + chr(10) + 'Valor Titulo: R$ ' + transform(SE1->E1_VALOR,'@E 999,999,999.99')) + CRLF + CRLF
	_cMensagem	+= CRLF + CRLF 
	_cMensagem	+= OemToAnsi('TIC - Manfil      ') + CRLF
	_cMensagem	+= OemToAnsi('Tecnologia, Informação e Comunicação') + CRLF

//	Processa({ || U_EnvMail(_cTo,_cFrom,_cCopia,_cCopiaOculta,_cAssunto,_cMensagem,'',_lReturn)},'[FA070CA3] - ENVIANDO EMAIL AGUARDE')
	U_EnvMail(_cTo,_cFrom,_cCopia,_cCopiaOculta,_cAssunto,_cMensagem,'',_lReturn)

return

