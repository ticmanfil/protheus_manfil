#include 'protheus.ch'
#include 'FWMVCDef.ch'
/*/
===============================================================================================================================
Programa----------: MATA030
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 28/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para acessar o PE da rotina MATA030
===============================================================================================================================
Uso---------------: MATA030
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
user function CRMA980()
	local	aParam		:= PARAMIXB,;
			xRet		:= .T.,;
			oObj		:= '',;
			cIdPonto	:= '',;
			cIdModel	:= ''
						
//	local cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))
	
	if aParam <> nil
		oObj		:= aParam[1]
		cIdPonto	:= aParam[2]
		cIdModel	:= aParam[3]

		if cIdPonto == 'MODELPOS' 
			//ApMsgInfo('Chamada apos a gravação total do modelo e fora da transação (MODELCOMMITNTTS).' + CRLF + 'ID ' + cIdModel +;
			//			CRLF+Transform(SA1->A1_LC,'@E 999,999.99')+' -> '+Transform(M->A1_LC, '@E 999,999.99'))
			if M->A1_LC >= 40000 .and. M->A1_LC != SA1->A1_LC
				EnviaEmail(M->A1_LC, SA1->A1_LC)
			endif

			CadIContab(M->A1_COD, substr(M->A1_NOME,1,40))

		elseif cIdPonto == 'MODELCOMMITNTTS'
			//MsgInfo("Chamada após a gravação total do modelo e fora da transação do MVC.")
			if reclock('SA1',.F.)
				SA1->A1_XLOGALT	:= CUSERNAME

				if alltrim(SA1->A1_REGIAO) $ '00|02|03|04'
					SA1->A1_TABELA:= '004'
					
				else
					SA1->A1_TABELA:= '001'

				endif

				SA1->(msUnLock())
			endif
			
		elseif cIdPonto == 'FORMPOS'
			//ApMsgInfo('Chamada na validação total do formulário. (FORMPOS)' + CRLF + 'ID ' + cIdModel +;
			//			CRLF+Transform(M->A1_LC,'@E 999,999.99')+' -> '+Transform(SA1->A1_LC, '@E 999,999.99'))
			if !M->A1_TIPO $ 'F|S'
				u_msgErro('Tipo de cliente inválido!')
				xRet:= .F.
			endif

/*		elseif cIdPonto == 'FORMLINEPRE'
			ApMsgInfo('Chamada na pré validação da linha do formulário. (FORMLINEPRE)' + CRLF + 'ID ' + cIdModel +;
						CRLF+Transform(M->A1_LC,'@E 999,999.99')+' -> '+Transform(SA1->A1_LC, '@E 999,999.99'))

		elseif cIdPonto == 'FORMLINEPOS'
			ApMsgInfo('Chamada na validação da linha do formulário. (FORMLINEPOS)' + CRLF + 'ID ' + cIdModel +;
						CRLF+Transform(M->A1_LC,'@E 999,999.99')+' -> '+Transform(SA1->A1_LC, '@E 999,999.99'))

		elseif cIdPonto == 'FORMLINEPOS'
			ApMsgInfo('Chamada na validação da linha do formulário. (FORMLINEPOS)' + CRLF + 'ID ' + cIdModel +;
						CRLF+Transform(M->A1_LC,'@E 999,999.99')+' -> '+Transform(SA1->A1_LC, '@E 999,999.99'))
		elseif cIdPonto == 'BUTTONBAR'
			if cAmbiente == '1'
				xRet := { {'Exportar_Fornec.', 'Exportar_Fornec.', 'U_RD06001()', 'Exportar Cadastro Para Fornecedor' } }
				xRet := { {'Consulta CEP.', 'Consulta CEP.', 'U_CEPInfo()', 'Consulta CEP' } }
			end
*/
		endif
	endif
return xRet


static function EnviaEmail(nVlNovo, nVlAntigo)

	local	_cTo			:= lower(AllTrim(GetMv('MV_RELACNT'))),;
			_cFrom			:= ' ',;	//'flavia@manfil.com.br;tic@manfil.com.br',; 	//alltrim(getMV('MV_XAUDITO')),;
			_cCopia			:= ' ',;
			_cCopiaOculta	:= ' ',;
			_cAssunto		:= ' ',;
			_cMensagem		:= ' ',;
			_lReturn		:= .F.
			
	_cFrom	:= u_Emails('000013')	//SUPERVISOR FINANCEIRO

	_cAssunto	:= OemToAnsi('[AUDIT-MANFIL] Limite de Credito Alterado Acima de R$ 40.000,00: '+alltrim(SA1->A1_COD)+' - '+allTrim(SA1->A1_LOJA)+' - '+alltrim(SA1->A1_NOME))
	_cMensagem	:= OemToAnsi('O Cliente abaixo teve seu limite de crédito alterado acima de R$ 40.000,00: ') + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Código/Loja do Cliente..: ') + alltrim(SA1->A1_COD)+'-'+allTrim(SA1->A1_LOJA) +chr(10)+' CNPJ/CPF..: '+alltrim(SA1->A1_CGC) + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Cliente: ') + alltrim(SA1->A1_NOME) + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Limite de Crédito ATUAL: R$ ') + transform(nVlAntigo,'@E 999,999,999.99') + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Limite de Crédito Novo: R$ ') + transform(nVlNovo,'@E 999,999,999.99') + CRLF + CRLF
	_cMensagem	+= CRLF + CRLF 
	_cMensagem	+= OemToAnsi('TIC - Manfil      ') + CRLF
	_cMensagem	+= OemToAnsi('Tecnologia, Informação e Comunicação') + CRLF

	Processa({ || U_EnvMail(_cTo,_cFrom,_cCopia,_cCopiaOculta,_cAssunto,_cMensagem,'',_lReturn)},'[M460FIM] - ENVIANDO EMAIL AGUARDE')

return

static function CadIContab(cCodCli, cNome) 

	dbSelectArea('CTD')
	CTD->(dbSetOrder(1))
	CTD->(dbSeek(xFilial('CTD')+'C'+cCodCli))
	if !found()
		if RecLock('CTD',.T.)
			CTD->CTD_FILIAL	:= xFilial('CTD')
			CTD->CTD_ITEM	:= 'C'+cCodCli
			CTD->CTD_CLASSE	:= '2'
			CTD->CTD_DESC01	:= cNome
			CTD->CTD_BLOQ	:= '2'
			CTD->CTD_DTEXIS	:= DDATABASE
			CTD->CTD_ITLP	:= 'C'+cCodCli
			CTD->CTD_ITSUP	:= 'C'
			CTD->(msUnlock())
		endif
	else
		if RecLock('CTD',.F.)
			CTD->CTD_DESC01	:= cNome
			CTD->(msUnlock())
		endif
	endif

return nil
