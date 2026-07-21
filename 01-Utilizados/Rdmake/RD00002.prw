#include "protheus.CH"
#include "tbiconn.ch" 
#include 'topconn.ch'

/*/
===============================================================================================================================
Programa----------: RD00002
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 17/08/2022
===============================================================================================================================
Descrição---------: Este programa serve para criar tabelas em produção
===============================================================================================================================
Uso---------------: Configurador
===============================================================================================================================
Parametros--------: pTabela	= '' >> nome da tabela a ser criado
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Configurador
===============================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor	|	Data	|										Motivo																
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|           | 																										
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			|																											
=====================================================================================================================================
/*/

user function RD00002()

	//tela
	local oGet01
	
	private cForm		:= '[RD00002] - Criando Tabelas...'
	
	private oDlg

	private	cTabela	:= '   '

		SetPrvt('oDlg1','oSay1','oSBtnOk','oSBtnCan','oMGet1')
		
		DEFINE MSDIALOG oDlg TITLE cForm From 0,0 TO 250,530 PIXEL
		
		@ 010,004 SAY OemToansi('Tabela:') SIZE 052, 008 OF oDlg PIXEL
		@ 010,060 MSGET oGet01 VAR cTabela SIZE 052,008 OF oDlg PIXEL

		DEFINE SBUTTON FROM 100, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:='1') ENABLE OF oDlg
		DEFINE SBUTTON FROM 100, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:='2') ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTERED	
	
		//if lConfirma
		if nOpca == '1'
		
			FSalva()
			
		endif
	
return

static function FSalva()

	chkfile(cTabela,.T.)
	if select(cTabela)
		DBCLOSEAREA(  )
	endif
	DbSelectArea(cTabela)
	DBCLOSEAREA(  )
	chkfile(cTabela,.F.)

return
