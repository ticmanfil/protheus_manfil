/*/
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
/*/
===============================================================================================================================
Programa----------: RD06005
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 10/09/2018
===============================================================================================================================
Descrição---------: Este programa serve para exportar os cadastro de funcionarios do Protheus para o DIMEP
===============================================================================================================================
Uso---------------: Folha de Pagamento
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: cRet	=> .F. - Falsou    ou .T. - Verdadeiro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGAPON
===============================================================================================================================
/*/
user function RD06005()

	private cPerg	:= 'RD06005'
	
	//pCriaSX1(cPerg)
	
	if !Pergunte('RD06005',.T.)   //Chama a tela de parametros
		return
	else
		Processa({|| RD06005a()}, 'Aguarde! Selecionando Registros...',,.T.)
	endif	
	
return


static function pCriaSX1(cPerg)
	//Grupo de Perguntas
	aHelpPor := {}
	Aadd( aHelpPor, 'Centro de custo do funcionário a ser exportado')
	aHelpEsp := {}
	Aadd( aHelpEsp, 'Centro de coste del empleado que se va a exportar')
	aHelpIng := {}
	Aadd( aHelpIng, 'Cost center of the employee to be exported')
	U_xPutSX1(cPerg,"01","Centro de Custo de: "		,"Centro de coste de:	"		,"Cost center off:	"		,"mv_ch1","G",09	,0,1,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEsp,aHelpIng)
	U_xPutSX1(cPerg,"02","Centro de Custo até: "	,"Centro de coste hasta:	"	,"Cost center until:	"	,"mv_ch2","G",09	,0,1,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEsp,aHelpIng)
	aHelpPor := {}
	Aadd( aHelpPor, 'Matricula do Funcionario a ser exportado')
	aHelpEsp := {}
	Aadd( aHelpEsp, 'Matricula del Funcionario a ser exportado')
	aHelpIng := {}
	Aadd( aHelpIng, 'Enrollment of the official to be exported')
	U_xPutSX1(cPerg,"03","Matricula de: "		,"Matricula de:	"		,"Registration:	"		,"mv_ch3","G",06	,0,1,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEsp,aHelpIng)
	U_xPutSX1(cPerg,"04","Matricula até: "		,"Matricula hasta:	"	,"Registration:	"		,"mv_ch4","G",06	,0,1,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEsp,aHelpIng)

	aHelpPor := {}
	Aadd( aHelpPor, 'Data de Admissao do Funcionarios')
	aHelpEsp := {}
	Aadd( aHelpEsp, 'Fecha de Admisión del Funcionario')
	aHelpIng := {}
	Aadd( aHelpIng, 'Date of Admission of Officials')
	U_xPutSX1(cPerg,"05","Dt Admissão de: "		,"Dt Admision de:	"		,"Dt Admission off:	"		,"mv_ch5","D",08	,0,1,"D","","","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEsp,aHelpIng)
	U_xPutSX1(cPerg,"06","Dt Admissão até: "	,"Dt Admision hasta:	"	,"Dt Admission until:	"	,"mv_ch6","D",08	,0,1,"D","","","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEsp,aHelpIng)
return


static function RD06005a()

	local cQuery	:= ''
	local dData		:= DtoS(dDatabase)	
	local _Str		:= ''
	local lFim		:= .F.
	local cSeqArq	:= '01'
	
	//Busca os dados do funcionários
	cQuery	:= " select SRA.RA_MAT, SRA.RA_PIS, SRA.RA_SENHA, substring(SRA.RA_ADMISSA,7,2)+SUBSTRING(SRA.RA_ADMISSA,5,2)+SUBSTRING(SRA.RA_ADMISSA,1,4) AS RA_ADMISSA, SRA.RA_NOME, SRJ.RJ_DESC"
//	cQuery	:= " select SRA.RA_MAT, SRA.RA_PIS, SRA.RA_NOME, SRJ.RJ_DESC "
	cQuery	+= " from "+retsqlname('SRA')+" as SRA "
	cQuery	+= " inner join "+retsqlname('SRJ')+" AS SRJ "
	cQuery	+= " on	SRJ.D_E_L_E_T_	= ' ' "
	cQuery	+= " and SRJ.RJ_FILIAL	= '"+XFILIAL('SRJ')+"' "
	cQuery	+= " and SRJ.RJ_FUNCAO	= SRA.RA_CODFUNC "
	cQuery	+= " where "
	cQuery	+= "		SRA.D_E_L_E_T_	= ' ' "
	cQuery	+= "    and SRA.RA_FILIAL	= '"+XFILIAL('SRA')+"' "
	cQuery	+= "	and SRA.RA_CC >= '"+mv_par01+"' and SRA.RA_CC <= '"+mv_par02+"'"
	cQuery	+= "	and SRA.RA_MAT >= '"+mv_par03+"' and SRA.RA_MAT <= '"+mv_par04+"' "
	cQuery	+= "    and SRA.RA_ADMISSA BETWEEN '"+DTOS(mv_par05)+"' and '"+DTOS(mv_par06)+"'""
	
	memowrite('RD06005a.SQL',cQuery)
	dbUseArea(.T.,'topconn',tcgenqry(,,cQuery),'TRB',.F.,.T.)
	Count To nRec
	ProcRegua(nRec)
	
	dbSelectArea('TRB')
	dbGoTop()
	_Str	:= ''
	while !EOF()
		IncProc()
		cMat	:= StrZero(val(alltrim(TRB->RA_MAT)),20)
		cPis	:= StrZero(val(alltrim(TRB->RA_PIS)),11)
		cSenha	:= StrZero(val(alltrim(TRB->RA_SENHA)),06)
		cAdmis	:= alltrim(TRB->RA_ADMISSA)+space(08-len(alltrim(TRB->RA_ADMISSA)))
		cNome	:= alltrim(TRB->RA_NOME)+space(52-len(alltrim(TRB->RA_NOME)))
		cFuncao	:= alltrim(TRB->RJ_DESC)+space(30-len(alltrim(TRB->RJ_DESC)))
		
		_Str	+= cMat+cPis+cSenha+cAdmis+cNome+cFuncao+cMat
		_Str	+= (chr(13)+chr(10))	// proxima linha
		dbSkip()
	end
	
	cPath	:= '\Arquivos\dimep\'
	
	while !lFim
		cArq	:= alltrim(mv_par01)+alltrim(mv_par02)+'_'+dData+'_'+cSeqArq+'.txt'
		
		if File(cPath+cArq)
			cSeqArq	:= Soma1(cSeqArq,2)
		else
			lFim	:= .T.
		endif
	
	enddo
	
	cPath	:= '\Arquivos\dimep\'+cArq
	MemoWrite(cPath,_Str)
	
	MsgInfo('Arquivo gerado com sucesso '+alltrim(cPath))

return