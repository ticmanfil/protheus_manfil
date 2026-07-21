#include 'totvs.ch'
/*/
===============================================================================================================================
Programa----------: MA415MNU
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 13/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para adiciona botoes na tela do orcamento
===============================================================================================================================
Uso---------------: No orcamentos (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
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

user function MA415MNU 

	local 	nLocal		as char,;
			aSubMenu	as array

	nLocal		:= Alltrim(GetMv("MV_XLOCAL"))
	aSubMenu	:= {}
	
	if RetCodUsr()="000000"
		aadd( aSubMenu,{ 'Recalc. Vl Total', 'U_MValor()', 0, 1} ) 
	endif

	if nLocal == "1"
		if RetCodUsr()$"000000"
			aadd(aRotina,{'Efetivar Orc.', 'U_RD05001(.T.)' , 0 , 1})  
		endif
		if RetCodUsr()$"000000/0000006/0000030/0000129"                
			aadd(aSubMenu,{'Analise Custo', 'U_RD05007(SCJ->CJ_FILIAL, SCJ->CJ_NUM)' , 0 , 1})
			aadd(aSubMenu,{'Novo Analise Custo', 'U_RD05013(SCJ->CJ_FILIAL, SCJ->CJ_NUM, SCJ->CJ_XNOMCLI)' , 0 , 1})
		endif
		//if RetCodUsr()$"000000/0000006/0000014/0000030/0000129"                
		//	aadd(aRotina,{'Acomp. Orçamento', 'U_RD05008()' , 0 , 1})
		//endif
		aadd(aSubMenu,{'Copiar Orçamento Manfil', 'U_RD05012(SCJ->CJ_NUM)' , 0 , 1})
		aadd(aRotina,{'Customizado',aSubMenu,0,1})
	endif

return

user function MValor()
	local	aArea		:= getArea(),;
			aSCJ		:= SCJ->(getArea()),;
			cNumOrc		:= '',;
			dDataOrc	:= DDATABASE

	dbSelectArea('SCJ')
	cNumOrc		:= SCJ->CJ_NUM
	dDataOrc	:= SCJ->CJ_EMISSAO
	if reclock("SCJ",.F.)
		SCJ->CJ_XVLTOT	:= U_UVlOrc(cNumOrc)
		SCJ->(msunlock())
	endif
	restArea(aSCJ)
	restArea(aArea)

return
