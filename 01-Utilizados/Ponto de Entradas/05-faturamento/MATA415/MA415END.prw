#include 'protheus.ch'
#include 'topconn.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: MA415END
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2023
===============================================================================================================================
Descrição---------: Este programa executa apos GRAVAR O ORCAMENTO DE VENDA
===============================================================================================================================
Uso---------------: orcamento de pedidos de venda (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: <programa>
=====================================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor		|	Data	|										Motivo																
----------------:-----------:-----------------------------------------------------------------------------------------------------------:
				|			| 																										
----------------:-----------:-----------------------------------------------------------------------------------------------------------:
				|			|																											
=====================================================================================================================================
/*/
user function MA415END()
	local 	lRet	:= .T.,;
			cNumOrc	:= '',;
			nAudOrc	:= GetMv("MV_XORCAUD"),;
			cExt	:= ''

	local	aAreaSA3	:= GetArea("SA3")

	dbSelectArea('SA3')
	SA3->(dbSetOrder(1))
	if (SA3->(dbSeek(xFilial('A3')+SCJ->CJ_XVEND)))
		cExt:= SA3->A3_TIPO
	endif

	dbSelectArea("SCJ")
	cNumOrc:= SCJ->CJ_NUM
	if reclock("SCJ",.F.)
		SCJ->CJ_XVLTOT	:= U_UVlOrc(cNumOrc,'O')
		SCJ->(msunlock())
	endif

	if SCJ->CJ_XVLTOT > nAudOrc .and. !SCJ->CJ_XNOTIF .and. cExt == 'I'
		EnviaEmail(nAudOrc)
		if reclock("SCJ",.F.)
			SCJ->CJ_XNOTIF	:= .T.
			SCJ->(msunlock())
		endif
	elseif SCJ->CJ_XNOTIF <> .F.
		if reclock("SCJ",.F.)
			SCJ->CJ_XNOTIF	:= .F.
			SCJ->(msunlock())
		endif
	endif

	RestArea(aAreaSA3)

return lRet

static function EnviaEmail(pAudOrc)

	local	_cTo			:= lower(AllTrim(GetMv('MV_RELACNT'))),;
			_cFrom			:= ' ',;	//'flavia@manfil.com.br;tic@manfil.com.br',; 	//alltrim(getMV('MV_XAUDITO')),;
			_cCopia			:= ' ',;
			_cCopiaOculta	:= ' ',;
			_cAssunto		:= ' ',;
			_cMensagem		:= ' ',;
			_lReturn		:= .F.
			
	_cFrom	:= u_Emails('000030')	//COMERCIAL 1 (LEANDRO E MARGARETH) e COMERCIAL 1 (LEANDRO E MARGARETH)

	_cAssunto	:= OemToAnsi('[VENDAS-PROTHEUS] Orcamentos Valores Superior a R$ '+transform(pAudOrc,'@E 999,999,999.99')+' - '+alltrim(SCJ->CJ_XNOMCLI))
	_cMensagem	:= OemToAnsi('Foi realizado ORÇAMENTO com VALOR ALTOS: ') + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Cliente..: ') + alltrim(SCJ->CJ_CLIENTE)+'-'+allTrim(SCJ->CJ_LOJA) +chr(10)+' Nome..: '+alltrim(SCJ->CJ_XNOMCLI) + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Orçamento: ' + SCJ->CJ_NUM + chr(10) + 'Data: ' + dtoc(SCJ->CJ_EMISSAO) + chr(10) + 'Vendedor:' +alltrim(SCJ->CJ_XVEND) + ' - ' + alltrim(SCJ->CJ_XNOMVEN) + chr(10) + 'Valor: R$ ' + transform(SCJ->CJ_XVLTOT,'@E 999,999,999.99')) + CRLF + CRLF
	_cMensagem	+= CRLF + CRLF 
	_cMensagem	+= OemToAnsi('TIC - Manfil      ') + CRLF
	_cMensagem	+= OemToAnsi('Tecnologia, Informação e Comunicação') + CRLF

//	Processa({ || U_EnvMail(_cTo,_cFrom,_cCopia,_cCopiaOculta,_cAssunto,_cMensagem,'',_lReturn)},'[FA070CA3] - ENVIANDO EMAIL AGUARDE')
	U_EnvMail(_cTo,_cFrom,_cCopia,_cCopiaOculta,_cAssunto,_cMensagem,'',_lReturn)

return
