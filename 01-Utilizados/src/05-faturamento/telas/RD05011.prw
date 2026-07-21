/*/
===============================================================================================================================
Programa----------: RD05011
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 17/03/2020
===============================================================================================================================
Descrição---------: Este programa serve para acertar peso do pedido e das notas
===============================================================================================================================
Uso---------------: No pedido (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
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


#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'TbiCode.ch'
#include 'rwmake.ch'
#include 'font.ch'
#include 'colors.ch'

user function RD05011()

	local	_cDoc	:= SF2->F2_DOC,;
			_cSerie	:= SF2->F2_SERIE,;
			_dData	:= ddatabase,;
			_cHora	:= time(),;
			_nTara	:= 0,;
			_nPeso	:= U_zLeBalanca('JUNDIAI'),;
			_nPesol	:= _nTara-_nPeso
	
	Define MsDialog oDialog Title OemToAnsi("Digitacao de TICKET Balanca") From 020,030 To 250,555 Pixel 
	@ 013,007 To 095,255 Title OemToAnsi("  Digite os Dados ") //Color CLR_HBLUE
	@ 027,010 Say "Numero:" Size 030,8 
	@ 025,035 Get _cDoc When .F.
	@ 025,070 Get _cSerie When .F.
	@ 027,120 Say "Data:" Size 30,8            
	@ 025,135 Get _dData Picture "99/99/9999" When .F. Size 50,8 Object oData            
	@ 027,200 Say "Hora:" Size 30,8            
	@ 025,215 Get _cHora Picture "99:99:99" When .F. Size 25,8 Object oHora            

	@ 055,010 Say "Tara :" Color CLR_HBLUE  Size 050,8
	@ 055,050 Get _nTara Picture "@e 999,999.9999" When .T. Size 120,8 
	@ 065,010 Say "Peso Balanca :" Color CLR_HBLUE  Size 050,8
	@ 065,050 Get _nPeso Picture "@e 999,999.9999" When .T. Size 120,8 
	@ 075,010 Say "Peso Liquido :" Color CLR_HBLUE  Size 050,8
	@ 075,050 Get _nPesol Picture "@e 999,999.9999" When .T. Size 120,8 

	@ 100,010 BMPBUTTON TYPE 24 ACTION FPeso()
	@ 100,180 BMPBUTTON TYPE 02 ACTION fEnd() //FCancela()
	@ 100,225 BMPBUTTON TYPE 01 ACTION FGrava()
	Activate MsDialog oDialog Center //On Init EnchoiceBar(oDialog,bOk,bCancel,,) Centered valid fMot()

return

static function FGrava()

return

static function FPeso()
	local cPeso	:= U_zLeBalanca('JUNDIAI')

	alert('Peso: '+cValToChar(cPeso))

return