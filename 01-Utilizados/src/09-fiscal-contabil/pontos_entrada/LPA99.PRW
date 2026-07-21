#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LPA99  º Autor ³ Leonardo Peixoto 	  º Data ³  21/02/17  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Lancamento Padrao Folha Pagamento    					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MDM					                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

                  
User Function LPA99(cTipo)

    Local _aArea := GetArea()
	
	Local _cConta := ""             
	
	
DbSelectArea("SRA")
DbSetOrder(1)
DbSeek(xfilial("SRA")+SRZ->RZ_MAT)

DbSelectArea("SRV")
DbSetOrder(1)
DbSeek(xfilial("SRV")+SRZ->RZ_PD)

DbSelectArea("CTT") 
DbSetOrder(1)
DbSeek(xFilial("CTT")+SRZ->RZ_CC)


If SRV->RV_LCTOP <> "   "         
	
            Do Case
				Case  cTipo == "CD" .AND. ALLTRIM(SRA->RA_CATFUNC) = "M" .AND. CTT->CTT_M_GRUP == "1"  		// CONTA DÉBITO - ADMINISTRATIVO
				_cConta := SRV->RV_DEBA 		
				Case  cTipo == "CD" .AND. ALLTRIM(SRA->RA_CATFUNC) = "M" .AND. CTT->CTT_M_GRUP == "2"  		// CONTA DÉBITO - CUSTO
				_cConta := SRV->RV_DEBC 	
				Case  cTipo == "CD" .AND. ALLTRIM(SRA->RA_CATFUNC) = "A"                                    // CONTA DÉBITO - AUTÔNOMO
				_cConta := SRV->RV_DEBAUT
				Case  cTipo == "CD" .AND. ALLTRIM(SRA->RA_CATFUNC) = "P"                                    // CONTA DÉBITO - PRÓ-LABORE
				_cConta := SRV->RV_DEBPRO


				Case  cTipo == "CC" .AND. ALLTRIM(SRA->RA_CATFUNC) = "M" .AND. CTT->CTT_M_GRUP == "1"  		// CONTA CRÉDITO - ADMINISTRATIVO
				_cConta := SRV->RV_CREDA 		
			  	Case  cTipo == "CC" .AND. ALLTRIM(SRA->RA_CATFUNC) = "M" .AND. CTT->CTT_M_GRUP == "2"  		// CONTA CRÉDITO - CUSTO
				_cConta := SRV->RV_CREDC 	
				Case  cTipo == "CC" .AND. ALLTRIM(SRA->RA_CATFUNC) = "A"                                    // CONTA CRÉDITO - AUTÔNOMO
				_cConta := SRV->RV_CREDAUT
				Case  cTipo == "CC" .AND. ALLTRIM(SRA->RA_CATFUNC) = "P"                                    // CONTA CRÉDITO - PRÓ-LABORE
				_cConta := SRV->RV_CREDPRO
 				OtherWise 
 				MsgAlert("Verifique Centro de Custo "+SRA->RA_CC+", pois o campo 'GRUPO' CTT_M_GRUP esta vazio","AVISO")
 			EndCase 
 				
 			
ELSE
					
Endif			
	
Return(_cConta)