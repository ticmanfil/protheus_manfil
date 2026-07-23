#include 'protheus.ch'
#include 'parmtype.ch'
/*/
===============================================================================================================================
Programa----------: FA740BRW
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para incluir botoes na tela Funcoes Contas a Receber
===============================================================================================================================
Uso---------------: Funcoes Contas a Receber
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FINANCEIROS
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
user function FA740BRW()
	
	local	aMenu		as array,;
			aSubMenu	as array,;
			aSubMenuA	as array,;
			cAmbiente	as char
	
	aMenu:= {}
	aSubMenu:= {}
	aSubMenuA:= {}
	cAmbiente:= Alltrim(GetMv('MV_XLOCAL'))

	aadd(aSubMenuA, {'Rel. Retorno','FINSV051()'	,0,4 })
//	aadd(aSubMenuA, {'Rel. Retorno','FINR650()'	,0,4 })
	aadd(aSubMenuA, {'Proc. Baixa','FINA200()'	,0,4 })
	aadd(aSubMenuA, {'Consulta CNAB','U_MV06003()',0,4 })
	aadd(aMenu,{'CNAB Manfil',aSubMenuA,0,2,0,nil})
	//aSubMenu:= {}
	aadd(aSubMenu, {'Env. Advogado','U_RD06006(6)'	,0,4 })
	aadd(aSubMenu, {'Ret. Advogado','U_RD06006(2)'	,0,4 })
	aadd(aSubMenu, {'Env. Perda','U_RD06006(7)'		,0,4 })
	aadd(aSubMenu, {'Ret. Perda','U_RD06006(5)'		,0,4 })
	aadd(aSubMenu, {'Hist. Cessões','U_RD06006(3)'	,0,4 })
	aadd(aMenu,{'Customizado',aSubMenu,0,2,0,nil})

	if cAmbiente == '2'
		aadd(aMenu, {'DANFE','U_XDANFE()',	0 , 3    })
		aadd(aMenu, {'Boleto ITAU','u_RD06010(FunName(),.F.,.T.)',   0 , 3})
	endif

return aMenu

user function XDANFE()

	local	aArea	:=	getArea(),;
			aSC5	:= SC5->(getArea()),;
			aSF2	:= SF2->(getArea()),;
			aSL1	:= SL1->(getArea())

	dbSelectArea('SC5')
	SC5->(DbSetOrder(1))
	SC5->(dbGoTop())
	SC5->(dbSeek(xFilial('SC5')+SE1->E1_PEDIDO))

	dbSelectArea('SF2')
	SF2->(DbSetOrder(1))
	SF2->(dbGoTop())
	SF2->(dbSeek(xFilial('SF2')+SE1->E1_PEDIDO))

	dbSelectArea('SL1')
	SL1->(DbSetOrder(2))
	SL1->(dbGoTop())
	if SL1->(dbSeek(xFilial('SL1')+SC5->C5_SERIE+SC5->C5_NOTA))
		LjNfceImp(SL1->L1_FILIAL,SL1->L1_NUM)
	endif

	dbSelectArea('SL1')
	SL1->(DbSetOrder(2))
	SL1->(dbGoTop())
	if SL1->(dbSeek(xFilial('SL1')+SC5->C5_SERIE+SC5->C5_NOTA))
		LjNfceImp(SL1->L1_FILIAL,SL1->L1_NUM)
	endif

	SC5->(RestArea(aSC5))
	SF2->(RestArea(aSF2))
	SL1->(RestArea(aSL1))
	RestArea(aArea)

return(.T.)
