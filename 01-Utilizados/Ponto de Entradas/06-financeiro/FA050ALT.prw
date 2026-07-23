#include 'protheus.ch'
#include 'FWMVCDef.ch'
/*/
===============================================================================================================================
Programa----------: FA050ALT  
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 15/10/2020
===============================================================================================================================
Descrição---------: Este programa serve para acessar o MVC FA050ALT  (CONTAS A PAGAR)
===============================================================================================================================
Uso---------------: FA050ALT  
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
user function FA050ALT()
	local	cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))

	local	lRet	:= .T.

    local   aUser   := {},;
            nPos    := 0

	
	if cAmbiente == '1'	// ambiente 006

        aUser   := U_User('000013') // grupo supervisor financeiro
        aadd(aUser,'000000')        // adicionando o usuario administrador
        if !empty(aUser)
            nPos    := ascan(aUser,RetCodUsr())
        endif

        if nPos = 0
            if M->E2_ACRESC >= 10 .or. M->E2_DECRESC >= 10
                lRet    := .F.
            end
        else
            lRet    := .T.
        endif

        // Validações de usuário
    
        If !(lRet)
            // Mensagem de Help para esclarescer o motivo de interromper a inclusão
            Help( ,, 'Help',, "Desconto ou Acrescimo inválido", 1, 0 )
    
            // Alterando lMsErroAuto para .T. (verdadeiro), devido aos casos de integrações ou ExecAuto
            lMsErroAuto := .T.
        EndIf
  	endif

return lRet

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

