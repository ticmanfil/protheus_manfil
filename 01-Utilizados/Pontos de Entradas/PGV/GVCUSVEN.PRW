
#Include "protheus.ch"
User Function GVCUSVEN()
    Local cWhere := " "

   //conout('GVCUSVEN: '+UPPER(ProcName(3)))

    If UPPER(ProcName(3)) == "TOTVS.PROTHEUS.BACKOFFICE.TGVSALESBUDGETS.GETQUERYHEADER"
       cWhere := " AND CJ_STATUS IN ('A','D') " 
    Else
       cWhere := "  " 
    Endif
Return cWhere
