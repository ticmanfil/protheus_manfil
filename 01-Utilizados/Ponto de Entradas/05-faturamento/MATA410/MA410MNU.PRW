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

	local 	cLocal		as char,;
			aSubRotina	as array

	local	aArea		as object

	aArea		:= getArea()

	cLocal		:= Alltrim(GetMv("MV_XLOCAL"))
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

	if cLocal == "1"
		aadd(aSubRotina,{'Imprimir','U_ImpPedVen(SC5->C5_NUM,FunName(),,SC5->C5_XVIAS)',0,2,0,Nil})
		aadd(aSubRotina,{'Imp Orçamento','u_RL05016()',0,2,0,nil})
		aadd(aSubRotina,{'Analise Custo', 'U_RL05003(SC5->C5_NUM)' , 0 , 1})
		aadd(aSubRotina,{'Gera Retorno de Remessa','u_RD05015()',0,2,0,nil})
		
	elseif cLocal == "2"	
		aadd(aSubRotina,{'Consulta Pedidos','U_MV05006()',0,1,0,Nil})
		aadd(aSubRotina,{'Imp Pedidos','U_RD05002()',0,1,0,Nil}) 
		aadd(aSubRotina,{'Imp Pedidos Aglutinados','U_MV05005()',0,1,0,Nil}) 
		aadd(aSubRotina,{'DANFE','U_XDANFEFAT()',0,2,0,Nil})
		aadd(aSubRotina,{'Gera Boleto','U_RD06010(FunName(), .T., .T.)',0,2,0,Nil})
		aadd(aSubRotina,{'Registra Boleto','MsgRun("Enviando boleta...","Processando...",{|| U_MA410_EnvioBoleta() })',0,2,0,Nil})

	endif

	aadd(aSubRotina,{'Dt Saída','u_AltParam("MV_DSAIENT")',0,2,0,Nil})

	aadd(aRotina,{'Customizado',aSubRotina,0,4,0,Nil})

	restArea(aArea)

return aRotina

user function MA410_EnvioBoleta()
	// Exibe mensagem de processamento enquanto a rotina FINA713('01') roda
	MsgRun('Registrando boleta...','Processando...',{|| FINA713('01')})
	u_msgInformacao('Boletas registradas com sucesso.','[MA410] - Envio de Boleta')

return .T.

user function xDanfeFAT()
	local	aArea		as object,;
			aSL1		as object
	
	local	cLocal		as caracter,;
			cEspecie	as caracter,;
			cLocalTmp	as caracter

	aArea		:=	getArea()
	aSL1		:= SL1->(getArea())

	cEspecie	:= posicione('SF2', 1, FwxFilial('SF2') + SC5->C5_NOTA + SC5->C5_SERIE, 'F2_ESPECIE')

	cLocalTmp	:= GetTempPath()

	cLocal		:= alltrim(getmv('MV_XLOCAL'))

	if cLocal == '2'
		if alltrim(cEspecie) $ 'SPED|RPS'
			u_zGerDanfe(SC5->C5_NOTA,SC5->C5_SERIE,.T.)
		
		elseif alltrim(cEspecie) == 'NFCE'
			dbSelectArea('SL1')
			SL1->(DbSetOrder(2))
			SL1->(dbGoTop())
			if SL1->(dbSeek(xFilial('SL1')+SC5->C5_SERIE+SC5->C5_NOTA))
				LjNfceImp(SL1->L1_FILIAL,SL1->L1_NUM)
			endif
		endif

	endif

	fwRestArea(aSL1)
	fwRestArea(aArea)

return .T.
