/*/
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
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TopConn.ch'
#include 'prtopdef.ch'
/*/
===============================================================================================================================
Programa----------: RD000000
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 25/01/2017
===============================================================================================================================
Descrição---------: Este programa serve para adiciona botoes na tela do pedido de vendas
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
===============================================================================================================================
/*/


user function MA410MNU()

	local 	nLocal		as char,;
			aSubRotina	as array

	local	aArea		as object

	aArea		:= getArea()

	nLocal		:= Alltrim(GetMv("MV_XLOCAL"))
	aSubRotina	:= {}

/*
aadd(aRotina,{'TEXTO DO BOTÃO','NOME DA FUNÇÃO' , 0 , 3,0,NIL})   
ONDE:Parametros do array a Rotina:
	1. Nome a aparecer no cabecalho
	2. Nome da Rotina associada    
	3. Reservado                        
	4. Tipo de Transação a ser efetuada:     
		1 - Pesquisa e Posiciona em um Banco de Dados      
		2 - Simplesmente Mostra os Campos                  
		3 - Inclui registros no Bancos de Dados            
		4 - Altera o registro corrente                     
		5 - Remove o registro corrente do Banco de Dados 
	5. Nivel de acesso                                   
	6. Habilita Menu Funcional
*/
	aadd(aSubRotina,{'Pré Nota','FATSV012()',0,2,0,nil})

	if nLocal == "1"
		aadd(aSubRotina,{'Imprimir','U_ImpPedVen(SC5->C5_NUM,FunName(),,SC5->C5_XVIAS)',0,2,0,Nil})
		aadd(aSubRotina,{'Imp Orçamento','u_RL05016()',0,2,0,nil})
		aadd(aSubRotina,{'Analise Custo', 'U_RL05003(SC5->C5_NUM)' , 0 , 1})
		aadd(aSubRotina,{'Gera Retorno de Remessa','u_RD05015()',0,2,0,nil})
		
	elseif nLocal == "2"	
		aadd(aSubRotina,{'Consulta Pedidos','U_MV05006()',0,1,0,Nil})
		aadd(aSubRotina,{'Imp Pedidos','U_RD05002()',0,1,0,Nil}) 
		aadd(aSubRotina,{'Imp Pedidos Aglutinados','U_MV05005()',0,1,0,Nil}) 
		aadd(aSubRotina,{'DANFE','U_XDANFEFAT()',0,2,0,Nil})
		aadd(aSubRotina,{'Boleto Itaú','U_RD06010(FunName(), .T., .T.)',0,2,0,Nil})
		aadd(aSubRotina,{'Enviar Boleta','MsgRun("Enviando boleta...","Processando...",{|| U_MA410_EnvioBoleta() })',0,2,0,Nil})

	endif

	aadd(aSubRotina,{'Gerar PIX a VISTA','U_X410Pix()',0,2,0,nil})
	aadd(aSubRotina,{'Dt Saída','u_AltParam("MV_DSAIENT")',0,2,0,Nil})

	aadd(aRotina,{'Customizado',aSubRotina,0,4,0,Nil})

	restArea(aArea)

return aRotina

user function MA410_EnvioBoleta()
	// Exibe mensagem de processamento enquanto a rotina FINA713('01') roda
	MsgRun('Enviando boleta...','Processando...',{|| FINA713('01')})
	u_msgInformacao('Envio da boleta finalizado.','[MA410] - Envio de Boleta')

return .T.

user function xDanfeFAT()

	local	aArea	:=	getArea(),;
			aSL1	:= SL1->(getArea()),;
			cEspecie	as caracter

	//private lViewPDF	:= .T.

	cLocalTmp	:= GetTempPath()

	cEspecie:= posicione('SF2', 1, FwxFilial('SF2') + SC5->C5_NOTA + SC5->C5_SERIE, 'F2_ESPECIE')
	
	//IFF(SC5->C5_SERIE=="004",U_ImpDanfe(SC5->C5_NOTA,SC5->C5_SERIE,""),.T.)
	if alltrim(cEspecie) $ 'SPED|RPS'
		//U_ImpDanfe(SC5->C5_NOTA,SC5->C5_SERIE,.T.,.T.)
		u_zGerDanfe(SC5->C5_NOTA,SC5->C5_SERIE,.T.)
	
	elseif alltrim(cEspecie) == 'NFCE'
		dbSelectArea('SL1')
		SL1->(DbSetOrder(2))
		SL1->(dbGoTop())
		if SL1->(dbSeek(xFilial('SL1')+SC5->C5_SERIE+SC5->C5_NOTA))
			LjNfceImp(SL1->L1_FILIAL,SL1->L1_NUM)
		endif
		SL1->(RestArea(aSL1))
		RestArea(aArea)
	endif

return .T.

user function X410Pix()

	local	aArea		as object,;
			aAreaSE4	as object

	local	aCondAd	as array,;
			nVTotal	as numeric,;
			nOk		as numeric

	aArea		:= getArea()
	aAreaSE4	:= SE4->(getArea())

	aCondAd	:= {}
	nVTotal	:= 0
	nOk		:= 0

	dbSelectArea('SE4')
	SE4->(dbGoTop())
	while !SE4->(eof())
		aadd(aCondAd,SE4->E4_CODIGO)
		SE4->(dbSkip())
	enddo

	nOk:= aScan(aCondAd,SC5->C5_CONDPAG)

	if nOk > 0	//a condicao de pagamento do pedido é de adiantamento
		nVTotal:= VlTPed()
	endif

	fwRestArea(aAreaSE4)
	fwRestArea(aArea)

return nil

/*/{Protheus.doc} CalcMaFisBrowser
Recalcula o pedido posicionado no Browser usando a engine de impostos (MaFis).
/*/
Static Function VlTPed()
	local	cAlias		as caracter,;
			cProcedure	as caracter,;
			cWhere		as caracter

	local	cNumPed		as caracter,;
			nVlTotal	as decimal

	cNumped	:= SC5->C5_NUM

	cAlias		:= getNextAlias()
	cProcedure	:= 'PR_VALORPEDIDO'
	cWhere		:= '@FILIAL = "'+fwxFilial('SC5')+'", @NUMPED = "'+cNumped+'"'
	u_PesqProc(cAlias,cProcedure,cWhere)
	if !(cAlias)->(eof())
		nVlTotal:= (cAlias)->(VALOR)
	endif
	(cAlias)->(dbCloseArea())

return nVlTotal
