#include 'protheus.ch'
#include 'parmtype.ch'

/*/
===============================================================================================================================
Programa----------: FA070CA4
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 26/08/2019
===============================================================================================================================
Descrição---------: Este programa serve para AUDITAR O CANCELAMENTO DE BAIXA DE TITULOS A RECEBER
===============================================================================================================================
Uso---------------: No recebimento
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

user function FA070CA4 ()
	local	cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))

	//local	cBCOTMP		:= Alltrim(GetMv("MV_XBCOTMP"))
	
	if cAmbiente == '1'	// ambiente 006
		EnviaEmail()
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

	_cAssunto	:= OemToAnsi('[AUDIT-PROTHEUS] Cancelamento de Baixa CR Tipo '+alltrim(SE1->E1_TIPO) + ' - Valor: R$ '+transform(SE5->E5_VALOR,'@E 999,999,999.99'))
	_cMensagem	:= OemToAnsi('Foi realizado CANCELAMENTO DE BAIXA para o titulo abaixo: ') + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Código/Loja do Cliente..: ') + alltrim(SE1->E1_CLIENTE)+'-'+allTrim(SE1->E1_LOJA) +chr(10)+' Nome..: '+alltrim(SE1->E1_NOMCLI) + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Titulo: ' + SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO + chr(10) + 'Emissao.: ' + dtoc(SE1->E1_EMISSAO) + chr(10) + 'Vencto.:' + dtoc(SE1->E1_VENCTO) + chr(10) + 'Valor Titulo: R$ ' + transform(SE1->E1_VALOR,'@E 999,999,999.99')) + CRLF + CRLF
	_cMensagem	+= CRLF + CRLF 
	_cMensagem	+= OemToAnsi('Banco.: ' + alltrim(SE5->E5_BANCO) +chr(10)+ 'Agencia: ' + alltrim(SE5->E5_AGENCIA)+chr(10)+ 'Conta: ' + alltrim(SE5->E5_CONTA)) + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Dt. Mov.: ' + dtoc(SE5->E5_DATA) + chr(10) + 'Valor Baixa: R$ ' + transform(SE5->E5_VALOR,'@E 999,999,999.99') + chr(10) + 'Motivo Baixa: ' + (SE5->E5_MOTBX)) + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Beneficiario.: ' + alltrim(SE5->E5_BENEF) +chr(10)+ 'Historico: ' + alltrim(SE5->E5_HISTOR)) + CRLF + CRLF
	_cMensagem	+= CRLF + CRLF 
	_cMensagem	+= OemToAnsi('TIC - Manfil      ') + CRLF
	_cMensagem	+= OemToAnsi('Tecnologia, Informação e Comunicação') + CRLF

	//Processa({ || U_EnvMail(_cTo,_cFrom,_cCopia,_cCopiaOculta,_cAssunto,_cMensagem,'',_lReturn)},'[FA070CA3] - ENVIANDO EMAIL AGUARDE')
	U_EnvMail(_cTo,_cFrom,_cCopia,_cCopiaOculta,_cAssunto,_cMensagem,'',_lReturn)

return
