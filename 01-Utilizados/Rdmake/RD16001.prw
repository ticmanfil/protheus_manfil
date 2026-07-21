#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'TbiCode.ch'
#include 'rwmake.ch'

/*/
===============================================================================================================================
Programa----------: RD16001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 24/09/2019
===============================================================================================================================
Descrição---------: Este programa serve para Exportar o cadastro de FUNCIONARIOS para o Ponto Eletronico
===============================================================================================================================
Uso---------------: RD07001 - Exportar Cadastro de Funcionarios para o Ponto
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: PONTO ELETRONICO
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

user function RD16001()
	local cPerg	as caracter

	cPerg:= 'RD16001'
	
	pAjustaSX1(cPerg)
	if Pergunte(cPerg,.T.)
		ArqCargos()
		ArqFunc()
	endif

return

static function ArqCargos ()
	local 	cLocal	:= 'C:\temp\cargos.txt',;
			nHandle;


	nHandle		:= FCreate(cLocal)

	if nHandle	< 0
		u_msgerro('Erro durante a criação do arquivo.',cForm)
	else
	
		if select('TB01') <> 0
			dbSelectArea('TB01')
			TB01->(dbCloseArea())
		endif
		
		cQuery	:= 'exec dbo.PR_RD16001B'
		
		TCQUERY cQuery NEW ALIAS 'TB01'
		
		dbSelectArea('TB01')
		TB01->(dbGoTop())
		while !TB01->(eof())
			FWrite(nHandle,strZero(val(alltrim(TB01->Q3_CARGO)),04))
			FWrite(nHandle,padr(alltrim(TB01->Q3_DESCSUM),75,'');
			+CRLF)

			TB01->(dbSkip())
		enddo

		FClose(nHandle)

	endif
return .T.

static function ArqFunc()
	local 	cLocal	:= 'C:\temp\func.txt',;
			nHandle,;
			cCracha	:= ''

	nHandle		:= FCreate(cLocal)

	if nHandle	< 0
		u_msgerro('Erro durante a criação do arquivo.',cForm)
	else
	
		if select('TB01') <> 0
			dbSelectArea('TB01')
			TB01->(dbCloseArea())
		endif
		
		cQuery	:= 'exec dbo.PR_RD16001A @DATA = '+char(39)+dtos(mv_par01)+char(39)+''
		
		TCQUERY cQuery NEW ALIAS 'TB01'
		
		dbSelectArea('TB01')
		TB01->(dbGoTop())
		while !TB01->(eof())
			cCracha:= iif(TB01->RA_CRACHA<>'',TB01->RA_CRACHA,TB01->RA_MAT)
			FWrite(nHandle,strZero(val(alltrim(TB01->RA_MAT)),06))
			FWrite(nHandle,strZero(val(alltrim(TB01->RA_PIS)),11))
			//FWrite(nHandle,padr(alltrim(TB01->RA_CRACHA),10,''))
			FWrite(nHandle,strZero(val(alltrim(cCracha)),10))
			FWrite(nHandle,padr(strtran(alltrim(TB01->RA_NOMECMP),"'",""),70,''))
			FWrite(nHandle,padr(alltrim(TB01->RA_NASC),08,''))
			FWrite(nHandle,padr(alltrim(TB01->RA_ADMISSA),08,''))
			FWrite(nHandle,padr(alltrim(TB01->RA_RG),20,''))
			FWrite(nHandle,strZero(val(alltrim(TB01->RA_CIC)),11))
			FWrite(nHandle,padr(alltrim(TB01->RA_TIPOPGT),01,''))
			FWrite(nHandle,strZero(val(str(TB01->RA_HRSMES)),03))
			FWrite(nHandle,strZero(val(alltrim(TB01->RA_CARGO)),04))
			FWrite(nHandle,padr(alltrim(iif(TB01->RA_SEXO=='M','1','2')),01,'');
			+CRLF)

			TB01->(dbSkip())
		enddo

		FClose(nHandle)

	endif
return .T.

static function pAjustaSx1(cPerg)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '01'						, 											  ;
				/*cPergunt	*/ 'Data Admitidos:'		, /*cPerSpa		*/ 'Data Admitidos:'		, /*cPerEng		*/ 'Data Admitidos:'		, ;
				/*cVar		*/ 'mv_ch1'					, /*cTipo 		*/ 'D'						, 											  ;
				/*nTamanho	*/ 8						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ ''						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par01'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

return
