#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
  
//----------------------------------------------------------------------------------
/*/{Protheus.doc} FI040MNCP
Manipula as colunas do aBrowse na rotina de Consulta de Títulos a Receber (FINC040).
 
@return aBrowPE[1] = Nome da coluna a ser exibido em tela;
        aBrowPE[2] = Campo da tabela SE5 a ser adicionado;
/*/
//----------------------------------------------------------------------------------
 
User FUNCTION FI040MNCP()
    LOCAL aBrowPE := PARAMIXB[1] // Array para ser manipulado
  
    IF EMPTY(aBrowPE)
        aBrowPE:= {;
            {" ","OK"},; //Led de ativo, cancelado ou estornado
            {"Data","DATAX"},; //Data
            {"Juros","JUROS"},; //Juros
            {"Multa","MULTA"},; //Multa
            {"Correção","CORRECAO"},; //Correção
            {"Descontos","DESCONTOS"},; //Descontos
            {"Valores Acessórios","VALACESS"},; //Valores Acessórios
            {"Valor Descontado","VALORTRANS"},;//Valor Descontado
            {"Valor Recebido","VALORRECEB"},;//Valor Recebido
            {"Motivo","MOTIVO"},; //Motivo
            {"Histórico","HISTORICO"},; //Histórico
            {"Data Contabilização","DATACONT"},; //Data Contabilização
            {"Data Disponibilidade","DATADISP"},; //Data Disponibilidade
            {"Lote","LOTE"},; //Lote
            {"Banco","BANCO"},; //Banco
            {"Agência","AGENCIA"},; //Agência
            {"Conta","CONTA"},; //Conta
            {"Documento","DOCUMENTO"},; //Documento
            {"Filial Movto.","FILIAL"},; //Filial Movto.
            {"Reconciliado","RECONC"},; //Reconciliado
            {"ID","IDORIG"};
        }
    ENDIF
 
    // Campos personalizados incluidos pelo cliente.
    IF ASCAN(aBrowPE,{|e| e[2] $ 'E5_XUSRLGI' }) == 0
        AADD(aBrowPE,{"Usuário Inclusão","E5_XUSRLGI"}) 
    ENDIF

    IF ASCAN(aBrowPE,{|e| e[2] $ 'E5_XDTLGIN' }) == 0
        AADD(aBrowPE,{"Data Inclusão","E5_XDTLGIN"}) 
    ENDIF

    IF ASCAN(aBrowPE,{|e| e[2] $ 'E5_XUSRLGA' }) == 0
        AADD(aBrowPE,{"Usuário Alteração","E5_XUSRLGA"}) 
    ENDIF

    IF ASCAN(aBrowPE,{|e| e[2] $ 'E5_XDTLGA ' }) == 0
        AADD(aBrowPE,{"Data da Alteracao","E5_XDTLGA "}) 
    ENDIF


RETURN aBrowPE
