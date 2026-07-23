#include "rwmake.ch"
#include "protheus.ch"
/*/
===============================================================================================================================
Programa----------: RD09004
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 08/03/2022
===============================================================================================================================
Descrição---------: Este programa serve para Alterar o prazo de cancelamento extermporaneo
===============================================================================================================================
Uso---------------: Livros Fiscais
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: LIVROS FISCAIS
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
#define MINDIAS 1

user function RD09004()
	local oButton1, oButton2, oSay1, oSay2, oComboBox1, oGet1
	local cGet1 := AllTrim(Str(GetMV("MV_CANCEXT")))+Space(3)
	local cComboBox1 := IIf(Val(cGet1) == MINDIAS,"Nao","Sim")
	
	private oDlg
	
	define msdialog oDlg title "Canc. Extemporaneo" from 000,000 to 085,305 colors 0,16777215 pixel
		@003,004 say oSay1 prompt "Para ativar o cancelamento extemporaneo, configure abaixo:" size 152,007 of oDlg colors 0,16777215 pixel
		@012,004 mscombobox oComboBox1 var cComboBox1 items{"Sim","Nao"} size 072,010 of oDlg colors 0,16777215 pixel
		@014,090 say oSay2 prompt "Dias" size 010,007 of oDlg colors 0,16777215 pixel
		@012,105 msget oGet1 var cGet1 size 026,010 when Validar(cComboBox1) of oDlg colors 0,16777215 pixel
		@027,075 button oButton1 prompt "Confirmar" size 037,012 of oDlg action Ativar(cComboBox1,Val(cGet1)) pixel
		@027,114 button oButton2 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
	activate msdialog oDlg
return

static function Validar(cOpcao)
	lRet := IIf(cOpcao == "Sim",.T.,.F.)
return lRet

static function Ativar(cOpcao,nDias)
	if cOpcao == "Sim"
		PutMV("MV_SPEDEXC",nDias * 24)					//em horas
		PutMV("MV_CANCEXT",nDias)						//em dias
	else
		PutMV("MV_SPEDEXC",MINDIAS * 24)				//em horas
		PutMV("MV_CANCEXT",MINDIAS)						//em dias
	endif
	
	Close(oDlg)
return
