
#INCLUDE "PROTHEUS.CH"
 
//----------------------------------------------------------------------------------------
/*/{Protheus.doc} FI040TPCP
Define os tipos de colunas incluídas na rotina de Consulta de Títulos a Receber (FINC040).
 
@return aBrowPE[1] = Campo da tabela SE5 que foi adicionado nos PE's FI040MNCP/FI040CPTN
        aBrowPE[2] = Tipo do dado da coluna (D=Data/N=Numerico/C=Caracter)
        aBrowPE[3] = Tamanho da coluna
        aBrowPE[4] = Casas decimais (para dados numericos)   
/*/
//----------------------------------------------------------------------------------------
 
User FUNCTION FI040TPCP()
LOCAL aCampos := PARAMIXB[1] // Array recebido do FINC040
  
    IF EMPTY(aCampos)
        aCampos := {;
            { "OK","N",1,0},;
            { "DATAX ", "D", 08, 0 }, ;
            { "JUROS ", "N", 16, 2 }, ;
            { "MULTA ", "N", 16, 2 }, ;
            { "CORRECAO ", "N", 16, 2 }, ;
            { "DESCONTOS ", "N", 16, 2 }, ;
            { "VALACESS" , "N", 16, 2 }, ;
            { "VALORTRANS", "N", 16, 2 }, ;
            { "VALORRECEB", "N", 16, 2 }, ;
            { "MOTIVO ", "C", 03, 0 }, ;
            { "HISTORICO ", "C", 40 ,0 }, ;
            { "DATACONT ", "D", 08, 0 },;
            { "DATADISP ", "D", 08, 0 },;
            { "LOTE ", "C", 08, 0 }, ;
            { "BANCO ", "C", 03, 0 },;
            { "AGENCIA ", "C", 05, 0 },;
            { "CONTA ", "C", 10, 0 }, ;
            { "DOCUMENTO ", "C", 50, 0 }, ;
            { "FILIAL ", "C", FWSizeFilial(), 0 },;
            { "RECONC ", "C", 01, 0 },;
            { "IDORIG ", "C", TamSX3("E5_IDORIG")[1],TamSX3("E5_IDORIG")[2] };
        }
    ENDIF
    
    // Campos personalizados incluidos pelo cliente.
    IF ASCAN(aCampos,{|e| e[1] == "E5_XUSRLGI "}) == 0
        AADD(aCampos,{ "E5_XUSRLGI ", "C", 20, 0 } )
    ENDIF

    IF ASCAN(aCampos,{|e| e[1] == "E5_XDTLGIN "}) == 0
        AADD(aCampos,{ "E5_XDTLGIN ", "D", 8, 0 } )
    ENDIF

    IF ASCAN(aCampos,{|e| e[1] == "E5_XUSRLGA "}) == 0
        AADD(aCampos,{ "E5_XUSRLGA ", "C", 20, 0 } )
    ENDIF

    IF ASCAN(aCampos,{|e| e[1] == "E5_XDTLGA "}) == 0
        AADD(aCampos,{ "E5_XDTLGA ", "D", 8, 0 } )
    ENDIF
RETURN aCampos
