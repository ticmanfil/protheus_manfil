#include 'protheus.ch'
#include 'parmtype.ch'

/*/
===============================================================================================================================
Programa----------: FA070TIT
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 23/10/2018
===============================================================================================================================
Descrição---------: Este programa serve para O ponto de entrada FA070TIT sera executado apos a confirmacao da baixa do contas a receber.
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

user function FA070TIT()

	local lRet		:= .T.
	local cAmbiente	:= Alltrim(GetMv('MV_XLOCAL'))
	local aUser
	
	aUser   := U_User('000013') // grupo supervisor financeiro
	aadd(aUser,'000000')        // adicionando o usuario administrador
	if !empty(aUser)
		nPos    := ascan(aUser,RetCodUsr())
	endif

	if nPos = 0

		if (alltrim(CMOTBX) != 'NORMAL')
			Alert('Motivo de Baixa Invalido!'+chr(13)+'Favor corrigir')
			lRet	:= .F.
		endif
		
		if (DBAIXA != DDATABASE)
			Alert('Data Receb. Invalido!'+chr(13)+'Favor corrigir')
			lRet	:= .F.
		endif
		
		if (DDTCREDITO != DDATABASE)
			Alert('Data Credito Invalido!'+chr(13)+'Favor corrigir')
			lRet	:= .F.
		endif
		
	endif
	
	if (NDESCONT < 0)
		Alert('Não é permitido DESCONTO negativo!'+chr(13)+'Favor corrigir')
		lRet	:= .F.
	endif
	
	if (NMULTA < 0)
		Alert('Não é permitido MULTA negativo!'+chr(13)+'Favor corrigir')
		lRet	:= .F.
	endif
	
	if (NJUROS < 0)
		Alert('Não é permitido JUROS negativo!'+chr(13)+'Favor corrigir')
		lRet	:= .F.
	endif

	if cAmbiente == '1'
		if (NDESCONT > 1) .and. (nPos = 0)
			Alert('Não é permitido DESCONTO acima R$ 1,00!'+chr(13)+'Favor corrigir')
			lRet	:= .F.
		endif
		
	endif

return lRet
