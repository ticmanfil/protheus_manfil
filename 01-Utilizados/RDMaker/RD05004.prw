#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'rwmake.ch'

/*/
===============================================================================================================================
Programa----------: RD05004
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 19/10/2018
===============================================================================================================================
Descrição---------: Este programa serve para reenviar danfe e xml
===============================================================================================================================
Uso---------------: NFESEFAZ
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
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
user function RD05004()

	local oDlgP			:= nil 
	private cTitulo 	:= 'Reenvio de arquivo XML da Nota Fiscal Eletronica' 
	private cNumSerie	:= SF2->F2_SERIE 
	private cNumNF		:= SF2->F2_DOC
	private cNumID		:= cNumSerie + cNumNF 
	private cEmail		:= space(250) 
	
	dbSelectArea('SA1')
	SA1->(dbSetOrder(1))
	if SA1->(dbSeek(xFILIAL('SA1')+SF2->F2_CLIENT+SF2->F2_LOJA))
		cEmail	:= SA1->A1_EMAIL
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
	//³ Tela de Entrada de Dados - Parametros                        ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
     DEFINE MSDIALOG oDlgP FROM 264,182 TO 441,613 TITLE cTitulo OF oDlgP PIXEL 
     @ 08,010 Say OemToAnsi("Informe o número de Série e NF-e para reenvio:") Size 250,20 OF oDlgP PIXEL                          
     @ 32,030 Say "Serie"      Size 40,10 OF oDlgP PIXEL 
     @ 30,70 GET cNumSerie      Size 40,10 OF oDlgP PIXEL 
     @ 47,030 Say "Nº Nota Fiscal:"    Size 40,10 OF oDlgP PIXEL 
     @ 45,70 GET cNumNF      Size 40,10 OF oDlgP PIXEL 
     @ 62,030 Say "E-mail"      Size 40,10 OF oDlgP PIXEL 
     @ 60,70 GET cEmail      Size 120,10 OF oDlgP PIXEL 
     @ 28,167 BUTTON "OK"      SIZE 036,012 ACTION (lOpcao:=.t.,close(oDlgP))     OF oDlgP PIXEL 
     @ 44,167 BUTTON "Cancelar" SIZE 036,012 ACTION (lOpcao:=.f.,close(oDlgP))      OF oDlgP PIXEL      
     ACTIVATE MSDIALOG oDlgP CENTERED                                    
     if lOpcao 
          cNumID := cNumSerie + cNumNF 
          FTENVNFU ( cNumID , cEmail ) 
          MSGINF('O arquivo XML da NFe está sendo reenviado em até 5 minutos.','Reenvio Xml e Danfe')           
     else            
        // botao cancelar 
     endif 
     
return

static function FTENVNFU( cId , cEmail )      
     Local _cQuery := "" 
     _cQuery := " UPDATE SPED050" 
     _cQuery += " SET " 
     _cQuery += " EMAIL = '" + alltrim(cEmail) +"' , " 
     _cQuery += " STATUSMAIL = '1' " 
     _cQuery += " WHERE NFE_ID = '"+ cId +"' " 
     TCSQlExec(_cQuery)              
Return
