#include 'protheus.ch'
#include 'parmtype.ch'
/*/
===============================================================================================================================
Programa----------: M425COPIA
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para atualizar registros a serem copiados
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
	Autor	|	Data	|										Motivo																
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|           | 																										
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			|																											
=====================================================================================================================================
/*/
user function M415COPIA()
	
	local 	lOk		:= .T.,;
			lRet	:= .F.

	if u_msgPergunta('Você está criando um orçamento apartir de uma cópia de orçamento.'+CRLF+;
					'Portanto pode sofrer algumas alterações em relação ao orçamento orignal por exemplo CONDIÇÃO DE PAGAMENTO, PREÇO DE VENDA, etc...'+CRLF+;
					'Deseja continuar?','[M415COPIA]') = 6				

		dbSelectArea('SA1')
		SA1->(dbSetOrder(1))
		SA1->(dbGoTop())
		if SA1->(dbSeek(xFilial('SA1')+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA))

			if !empty(SA1->A1_COND)
				if RecLock('SCJ',.F.)
					SCJ->CJ_CONDPAG := SA1->A1_COND
					SCJ->CJ_XDESCON	:= POSICIONE("SE4",1,XFILIAL("SE4")+SA1->A1_COND,"E4_DESCRI")
					msUnLock()
				endif
			endif

			if RecLock('SCJ',.F.)
				SCJ->CJ_TIPOCLI := iif(SA1->A1_TIPO=='S'.AND.SA1->A1_XDTSOL > DDATABASE,'F',SA1->A1_TIPO)
				msUnLock()
			endif

		endif

	else
		lOk:= .F.
	endif

	if lOk
		lRet := lOk
		if RecLock('SCJ',.F.)
			SCJ->CJ_XCOPY := lOk
			msUnLock()
		endif
	endif

return lRet
