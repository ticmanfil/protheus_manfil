#INCLUDE "TOTVS.CH"

User Function FA080TIT()

    Local _lRetorno := .T.

	If _lRetorno
        SE2->E2_XUSRLGA := CUSERNAME
        SE2->E2_XDTLGA  := DATE()		
	EndIf

Return(_lRetorno)
