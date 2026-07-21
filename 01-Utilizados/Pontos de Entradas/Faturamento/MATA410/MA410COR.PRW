#include 'protheus.ch'

/*/
===============================================================================================================================
Programa----------: MA410COR 
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 18/06/2019
===============================================================================================================================
Descrição---------: Este programa serve para definir as legendas do PEDIDO DE VENDA TRABALHA EM CONJUNTO COM PE MA410LEG
===============================================================================================================================
Uso---------------: MATA410 - PEDIDO DE VENDA
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
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

user function MA410COR()

	local 	aCores 		:= PARAMIXB,;
			cAmbiente	:= Alltrim(GetMv("MV_XLOCAL")),;
			Item		:= 0

	Item:= len(aCores)

	if cAmbiente == '1'
		aCores[01]	:= {"empty(C5_XNUMPAR) .and. empty(C5_LIBEROK) .and. empty(C5_NOTA) .and. empty(C5_BLQ)",'ENABLE','Pedidos em Aberto' }
		aCores[02]	:= {"empty(C5_XNUMPAR) .and. !empty(C5_NOTA).Or.C5_LIBEROK=='E' .and. empty(C5_BLQ)",'DISABLE','Pedidos Encerrado' }
		Item:= FInsItem(aCores)
		aCores[Item]:= {"!empty(C5_XNUMPAR) .and. empty(C5_LIBEROK) .and. empty(C5_NOTA) .and. empty(C5_BLQ)",'BR_PINK','Reservas' }
		Item:= FInsItem(aCores)
		aCores[Item]:= {"!empty(C5_XNUMPAR) .and. !empty(C5_NOTA)",'BR_BRANCO','Reservas Impressas' }
		//Item: FInsItem(aCores)
		//aCores[Item]:= {"empty(C5_XNUMPAR) .and. empty(C5_LIBEROK) .and. empty(C5_NOTA) .and. empty(C5_BLQ) .and. empty(C5_XNUMORC)",'BR_VERDE_ESCURO','Orçamento'} 

	elseif cAmbiente == '2'
		aCores[01]	:= {"C5_XLOJA <> 'S' .and. Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)",'ENABLE','Pedidos em Aberto' }
		Item:= FInsItem(aCores)
		aCores[Item]:= {"C5_XLOJA == 'S' .and. empty(C5_LIBEROK) .and. empty(C5_NOTA) .and. empty(C5_BLQ)",'BR_PINK','Pedido em Aberto c/ CUPOM' }
		
	endif

return aCores

static function FInsItem(aCores)
	local item := 0

	Item:= len(aCores)

	Item+=1
	aadd(aCores,nil)
	aIns(aCores,Item)

return Item
