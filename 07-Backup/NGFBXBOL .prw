#include 'protheus.ch'
#include 'FWMVCDef.ch'
#include 'Totvs.ch'
/*/
===============================================================================================================================
Programa----------: NGFBXBOL 
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 17/04/2024
===============================================================================================================================
Descrição---------: Permite o download do boleto em PDF dos boletos personalizados através do Novo Gestor Financeiro e Portal do cliente
===============================================================================================================================
Uso---------------: FINA710
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
user function NGFBXBOL ()
    Local   aAreaSEA  as Array,;
            aRet      as Array,;
            nRecSEA   as Numeric,;
            lArqGer   as Logical,;
            cNomeArq  as Character,;
            cNomeBx   as Character  
 
    aAreaSEA    := GetArea('SEA')
    aRet        := {}
    nRecSEA     := PARAMIXB[1][1][1] // RECNO da tabela SEA
    lArqGer     := PARAMIXB[1][1][2] // Se .T. arquivo gerado por nossa aplicação. Se .F. Variavel nome do arquivo estará vazia.
    cNomeArq    := PARAMIXB[2]       // Arquivo gerado "\spool\NOMEDOARQUIVO.pdf"
    cNomeBx     := PARAMIXB[3]       // Chave do título (Prefixo + Numero + Parcela + Tipo.pdf"   
    
    dbSelectArea('SEA')
    SEA->(DbGoTo(nRecSEA))
 
    If !lArqGer
        cNomeArq := "Personalizado pelo cliente"
    Endif
 
    // Processo de download do arquivo - Lógica conforme necessidade do cliente
 
    // ...
    // cNomeArq := "\spool\NOMEDOARQUIVO.PDF" - Caminho e nome do arquivo que será baixado.
 
    // cNomeBx  := "NOMEDOARQUIVO" - Nome para o arquivo personalizado pelo cliente.
    // ....
 
    Aadd(aRet, {cNomeArq, cNomeBx} )
 
    RestArea(aAreaSEA)
 
Return aRet
