#include 'protheus.ch'
#include 'parmtype.ch'
/*/
===============================================================================================================================
Programa----------: FINALEG
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 02/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para Customiza legendas de Mbrowse CONTAS A RECEBER
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
user function FINALEG()
	
	local nReg		:= PARAMIXB[1]
	local cAlias	:= PARAMIXB[2]
	local uRetorno	:= {}
	local aLegenda	:= {	{"BR_VERDE"    , "Titulo em aberto"       },;	// "Titulo em aberto"
							{"BR_AZUL"     , "Baixado parcialmente"   },;	// "Baixado parcialmente"
							{"BR_VERMELHO" , "Titulo baixado"         },;	// "Titulo Baixado"
							{"BR_PRETO"    , "Titulo em bordero"      },;	// "Titulo em Bordero"
							{"BR_BRANCO"   , "Adiantamento com saldo" } }	// "Adiantamento com saldo"
	
	if nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
		uRetorno := {}
		if cAlias = "SE1"
			aadd(aLegenda, {"BR_LARANJA", "Titulo ADVOGADO"}) 			//"Titulo com Advogado"
			aadd(aLegenda, {"BR_MARROM", "Titulo PERDA"}) 	//"Titulo Parcial c/ Advogado"
			//-- Adicinando cor cinza para natureza N001 - CUSTOMIZADO		
			//aadd(aLegenda, {"BR_CINZA", "Teste"}) // Teste		
			
			aadd(uRetorno, {'ROUND(E1_SALDO,2) = 0'												, aLegenda[3][1] } )		
			aadd(uRetorno, {'E1_TIPO == "'+MVRECANT+'".and. ROUND(E1_SALDO,2) > 0'				, aLegenda[5][1] } )		
			aadd(uRetorno, {'!Empty(E1_NUMBOR)'													, aLegenda[4][1] } )		
			aadd(uRetorno, {'ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2)'								, aLegenda[2][1] } )		
			aadd(uRetorno, {'ROUND(E1_SALDO,2) > 0 .and. E1_SITUACA == "5"'						, aLegenda[6][1] } )		
			aadd(uRetorno, {'ROUND(E1_SALDO,2) > 0 .and. E1_SITUACA == "L"'						, aLegenda[7][1] } )		
			aadd(uRetorno, { '.T.'																, aLegenda[1][1] } )	
		else		
			if !Empty(GetMv("MV_APRPAG")) .or. GetMv("MV_CTLIPAG")			
				Aadd(aLegenda, {"BR_AMARELO", "Titulo aguardando liberacao"}) //Titulo aguardando liberacao			
				Aadd(uRetorno, {' EMPTY(E2_DATALIB) .AND. (SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) > GetMV("MV_VLMINPG") .AND. E2_SALDO > 0'	, aLegenda[6][1] } )		
			endif		
			aadd(uRetorno, { 'E2_TIPO == "'+MVPAGANT+'" .and. ROUND(E2_SALDO,2) > 0'							, aLegenda[5][1] } )		
			aadd(uRetorno, { 'ROUND(E2_SALDO,2) + ROUND(E2_SDACRES,2)  = 0'										, aLegenda[3][1] } )		
			aadd(uRetorno, { '!Empty(E2_NUMBOR)'																, aLegenda[4][1] } )		
			aadd(uRetorno, { 'ROUND(E2_SALDO,2)+ ROUND(E2_SDACRES,2) # ROUND(E2_VALOR,2)+ ROUND(E2_ACRESC,2)'	, aLegenda[2][1] } )		
			aadd(uRetorno, { '.T.'																				, aLegenda[1][1] } )	
		endif
	else
		if cAlias = "SE1"		
			aadd(aLegenda, {"BR_LARANJA", "Titulo ADVOGADO"}) 			//"Titulo com Advogado"
			aadd(aLegenda, {"BR_MARROM", "Titulo PERDA"}) 	//"Titulo Parcial c/ Advogado"
		else		
			if !Empty(GetMv("MV_APRPAG")) .or. GetMv("MV_CTLIPAG")			
				aadd(aLegenda, {"BR_AMARELO",  "Titulo aguardando liberacao"}) //Titulo aguardando liberacao		
			endif	
		endif
		
		BrwLegenda(cCadastro, "Teste", aLegenda)
	endif

return uRetorno
