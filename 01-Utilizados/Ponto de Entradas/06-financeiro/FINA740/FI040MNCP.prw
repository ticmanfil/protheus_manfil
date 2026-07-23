#include 'protheus.ch'
/*/
===============================================================================================================================
Programa----------: FI040MNCP
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 19/05/2026
===============================================================================================================================
Descrição---------: Este programa serve para acessar manipular as colunas do aBrowse na rotina de Consulta de Títulos a Receber (FINC040).
===============================================================================================================================
Uso---------------: FI040MNCP
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGAFIN - FINANCEIRO
===============================================================================================================================
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
user function FI040MNCP()
	local	aColunas as array

	aColunas:= paramixb[1]

	if empty(aColunas)
        aColunas := {;
            {' ','OK'},;						//Led de ativo, cancelado ou estornado
            {'Data','DATAX'},;     				//Data
            {'Juros','JUROS'},;     			//Juros
            {'Multa','MULTA'},;     			//Multa
            {'Correção','CORRECAO'},;  			//Correção
            {'Descontos','DESCONTOS'},; 		//Descontos
            {'Valores Acessórios','VALACESS'},;	//Valores Acessórios
            {'Valor Descontado','VALORTRANS'},;	//Valor Descontado
            {'Valor Recebido','VALORRECEB'},;	//Valor Recebido
            {'Valor em Moeda 2','VLMOED2'},;    //Valor em Moeda 2
            {'Motivo','MOTIVO'},;    			//Motivo
            {'Histórico','HISTORICO'},; 		//Histórico
            {'Data Contabilização','DATACONT'},;//Data Contabilização
            {'Data Contabilização','DATADISP'},;//Data Contabilização
            {'Lote','LOTE'},;      				//Lote
            {'Banco','BANCO'},;     			//Banco
            {'Agência','AGENCIA'},;   			//Agência
            {'Conta','CONTA'},;     			//Conta
            {'Documento','DOCUMENTO'},; 		//Documento
            {'Filial Movto.','FILIAL'},;    	//Filial Movto.
            {'Reconciliado','RECONC'},;    		//Reconciliado
            {'ID','IDORIG'},;
            {'Usuário Inclusão','E5_XUSRLGI'},; 	//Usuário Inclusão
            {'Data Inclusão','E5_XDTLGIN'},;    	//Data Inclusão
            {'Usuário Alteração','E5_XUSRLGA'},; 	//Usuário Alteração
            {'Data Alteração','E5_XDTLGA'};    	//Data Alteração
        }
    endif

return aColunas
