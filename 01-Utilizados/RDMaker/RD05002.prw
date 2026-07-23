#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: RD05002
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para importar os pedidos de vendas no ambiente 005
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Returna se foi importador SIM (T) ou NÃO (F)
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
=====================================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor		|	Data	|										Motivo																
----------------:-----------:-------------------------------------------------------------------------------------------------------:
RENATO FUZESSY	|14/01/2019 | FAZER TRATAMENTO PARA NÃO IMPORTAR PEDIDOS DE VENDAS COM VENDEDOR DE FÉRIAS 																										
----------------:-----------:-------------------------------------------------------------------------------------------------------:
				|			|																											
=====================================================================================================================================
/*/
  
User Function RD05002()

	local   cQry    	as char,;
			cNumDoc 	as char,;
			cSerie		as char,;
			aPedidos	as array,;
			lOk			as logical
	
	cQry	:= ''
	cNumDoc	:= ''
	cSerie	:= ''
	aPedidos:= {}
	lOk		:= .F.

	CriaSX1('RD05002') //Cria os parametros
	
	if Pergunte('RD05002',.T.)   //Chama a tela de parametros

		cNumDoc := iif(empty(mv_par02),'',strzero(val(mv_par01),9))
		cSerie  := iif(empty(mv_par02),'',mv_par02)

		cQry    := 'exec PR_MV05005 @pDATA = '+char(39)+''+char(39)+', @pNumDoc = '+char(39)+cNumDoc+char(39)+', @pSerie = '+char(39)+cSerie+char(39)+', @pCliente = '+char(39)+''+char(39)+''

		//Preenchendo com novos dados
		TCQUERY cQry NEW ALIAS 'TB01'
		dbSelectArea('TB01')
		while !TB01->(eof())
			aadd(aPedidos,{TB01->F2_CLIENTE,TB01->F2_LOJA,TB01->F2_SERIE,TB01->F2_DOC,TB01->F2_XCLIENTE,TB01->F2_EST,'X'})
			TB01->(dbSkip())
		enddo
		TB01->(dbCloseArea())

		if !empty(aPedidos)
			FWMsgRun(,{|| lOk:= u_FIntPed(aPedidos)},'Processando','Integrando registros...')
			if lOk
				u_msgInforma('Pedido integrado com sucesso!','[RD05002] - Importando Pedidos')
			else
				u_msgErro('Erro ao integrar PEDIDOS!','[RD05002] - Importando Pedidos')
			endif
		else
			u_msgInforma('Pedidos não encontrado!')
		endif
	endif
return

static function CriaSX1(cPerg)

	local 	aHelpPor	:= {},;
			aHelpEsp	:= {},;
			aHelpIng	:= {}

	//Grupo de Perguntas
	aHelpPor := {}
	Aadd( aHelpPor, 'Número Doc Saida')
	aHelpEsp := {}
	Aadd( aHelpEsp, 'Nota número de la Doc de venta	')
	aHelpIng := {}
	Aadd( aHelpIng, 'Note Number of the sale request		')
	U_xPutSX1(cPerg,'01','Num. Doc Saída?','Num. Doc Saída?','Num. Doc Saída?','mv_ch1','C',09,0,1,'G','','','','','mv_par01','','','','','','','','','','','','','','','','',aHelpPor,aHelpEsp,aHelpIng)
	//Grupo de Perguntas
	aHelpPor := {}
	Aadd( aHelpPor, 'Serie')
	aHelpEsp := {}
	Aadd( aHelpEsp, 'Serie')
	aHelpIng := {}
	Aadd( aHelpIng, 'Serie')
	U_xPutSX1(cPerg,'02','Serie?','Serie?','Serie?','mv_ch2','C',03,0,1,'G','','','','','mv_par02','','','','','','','','','','','','','','','','',aHelpPor,aHelpEsp,aHelpIng)
return()
