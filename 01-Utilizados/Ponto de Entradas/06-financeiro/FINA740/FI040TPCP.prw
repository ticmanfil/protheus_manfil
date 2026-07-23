#include 'protheus.ch'
/*/
===============================================================================================================================
Programa----------: FI040TPCP
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 19/05/2026
===============================================================================================================================
Descrição---------: Este programa serve para definir os tipos de colunas incluídas 
                    na rotina de Consulta de Títulos a Receber (FINC040).
===============================================================================================================================
Uso---------------: FI040TPCP
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
user function FI040TPCP()
	local	aColunas as array

	aColunas:= paramixb[1]

	if empty(aColunas)
        aColunas := {;
            {'OK', 'N', 1, 0},;						    //Led de ativo, cancelado ou estornado
            {'DATAX', 'D', 8, 0},;     				    //Data
            {'JUROS', 'N', 16, 2},;     			    //Juros
            {'MULTA', 'N', 16, 2},;     			    //Multa
            {'CORRECAO', 'N', 16, 2},;  			    //Correção
            {'DESCONTOS', 'N', 16, 2},; 		        //Descontos
            {'VALACESS', 'N', 16, 2},;	                //Valores Acessórios
            {'VALORTRANS', 'N', 16, 2},;	            //Valor Descontado
            {'VALORRECEB', 'N', 16, 2},;	            //Valor Recebido
            {'VLMOED2', 'N', 16, 2},;	                //Valor em moeda 2
            {'MOTIVO', 'C', 3, 0},;    			        //Motivo
            {'HISTORICO', 'C', 40, 0},; 		        //Histórico
            {'DATACONT', 'D', 8, 0},;                   //Data Contabilização
            {'DATADISP', 'D', 8, 0},;                   //Data Contabilização
            {'LOTE', 'C', 8, 0},;      				    //Lote
            {'BANCO', 'C', 3, 0},;     			        //Banco
            {'AGENCIA', 'C', 5, 0},;   			        //Agência
            {'CONTA', 'C', 10, 0},;     			    //Conta
            {'DOCUMENTO','C', 50, 0},; 		            //Documento
            {'FILIAL','C', FWSizeFilial(), 0},;         //Filial Movto.
            {'RECONC','C', 1, 0},;    		            //Reconciliado
            {'IDORIG','C', TamSX3('E5_IDORIG')[1],TamSX3('E5_IDORIG')[2]};
        }
    endif
       
    // Campos personalizados incluidos pelo cliente.
    if ascan(aColunas,{|e| e[1] == "E5_XUSRLGI "}) == 0
        aadd(aColunas,{ 'E5_XUSRLGI ', 'C', 20, 0 } )
    endif

    if ascan(aColunas,{|e| e[1] == "E5_XDTLGIN "}) == 0
        aadd(aColunas,{ 'E5_XDTLGIN ', 'D', 8, 0 } )
    endif

    if ascan(aColunas,{|e| e[1] == "E5_XUSRLGA "}) == 0
        aadd(aColunas,{ 'E5_XUSRLGA ', 'C', 20, 0 } )
    endif

    if ascan(aColunas,{|e| e[1] == "E5_XDTLGA "}) == 0
        aadd(aColunas,{ 'E5_XDTLGA ', 'D', 8, 0 } )
    endif

return aColunas
