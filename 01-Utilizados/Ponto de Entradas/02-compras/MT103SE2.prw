#include 'protheus.ch'
#include 'parmtype.ch'

user function MT103SE2()

	Local aHead:= PARAMIXB[1]
	Local lVisual:= PARAMIXB[2]
	Local aRet:= {}// Customizações desejadas para adição do campo no grid de informações
	
	If  MsSeek('E2_DECRESC') 
		AADD(aRet,{ trim(X3Titulo()),;
					SX3->X3_CAMPO,;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					"",;
					SX3->X3_USADO,;
					SX3->X3_TIPO,;
					SX3->X3_F3,;
					SX3->X3_CONTEXT,;
					SX3->X3_CBOX,;
					SX3->X3_RELACAO,;
					'.T.';
					}) 
	EndIf 
	
Return (aRet)
