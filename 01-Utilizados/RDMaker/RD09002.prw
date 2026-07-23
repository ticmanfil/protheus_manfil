#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'rwmake.ch'

/*/
===============================================================================================================================
Programa----------: RD09002
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 08/01/2019
===============================================================================================================================
Descrição---------: Este programa serve para Acertar CHAVE NFE de Entrada
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
user function RD09002()

	local lRet			:= .F.

	u_msgInforma('MODULO EM DESENVOLVIMENTO','[RD09002] - Alterar CHAVE NFE de Entrada')
/*	local cPerg		:= 'RD09002'
	local cEmissao	:= DDATABASE
	local cSerie	:= space(tamsx3('F2_SERIE')[1])
	local cNumNota	:= space(tamsx3('F2_DOC')[1])
	local cClieFor	:= space(tamsx3('F3_CLIEFOR')[1])
	local cLoja		:= space(tamsx3('F3_LOJA')[1])
	local cCHVNFE	:= space(tamsx3('F3_CHVNFE')[1])
	
	AjustaSx1(cPerg)
	
	if Pergunte(cPerg,.T.)
		cEmissao	:= mv_par01
		cSerie		:= mv_par02
		cNumNota	:= mv_par03
		cClieFor	:= mv_par04
		cLoja		:= mv_par05
		cTipo		:= mv_par06
		cCHVNFE		:= mv_par07
		
		begin transaction
			dbSelectArea('SF1')
			SF1->(dbSetOrder(1))
			SF1->(dbGoTop())
			SF1->(dbSeek(XFILIAL('SF1')+cNumNota+cSerie+cClieFor+cLoja+cTipo))
			while !eof()
				if RecLock('SF1',.F.)
					SF1->F1_CHVNFE	:= cCHVNFE
					SF1->(msUnlock())
					lRet	:= .T.
				endif
				SF1->(dbSkip())
	
			enddo
			SF1->(dbCloseArea())

			if lRet
				dbSelectArea('SF3')
				SF3->(dbSetOrder(1))
				SF3->(dbGoTop())
				SF3->(dbSeek(XFILIAL('SF3')+dtos(cEmissao)+cNumNota+cSerie+cClieFor+cLoja))
				while !eof()
					if RecLock('SF3',.F.)
						SF3->(dbDelete())
						SF3->(msUnlock())
	
					endif
					SF3->(dbSkip())
		
				enddo
				SF3->(dbCloseArea())

			dbSelectArea('SFT')
			SFT->(dbSetOrder(1))
			SFT->(dbGoTop())
			SFT->(dbSeek(XFILIAL('SFT')+'E'+cSerie+cNumNota))
			while !eof()
				if RecLock('SFT',.F.)
					SFT->(dbDelete())
					SFT->(msUnlock())

				endif
				SFT->(dbSkip())

			enddo
			SFT->(dbCloseArea())
	
				lMsErroAuto	:= .F.
			
				if lMsErroAuto
					MostraErro()
					DisarmTransaction()
					lRet	:= .F.
	
				else
					if !pEnviaAudit(cSerie, cNumNota)
						DisarmTransaction()
						lRet	:= .F.
					endif
				endif
				
			endif
		end transaction

		if lRet
			u_msgInforma('Sequência liberado com sucesso!','[RD000013]')
		endif
	endif
*/	
	                                                                     
//	SetPrvt('oDlg1','oSay1','oSBtnOk','oSBtnCan')
//	
//	DEFINE MSDIALOG oDlg TITLE '[RD000013]-Liberando Seq Num Doc Saida' From 0,0 TO 175,530 PIXEL
//	
//	@ 010,004 SAY OemToansi('Este programa irá liberar a serie e numero para ser gerado novamente.') SIZE 052, 008 OF oDlg PIXEL
//	@ 010,060 MSGET oGet01 VAR cSerie SIZE 052,008 PICTURE X3PICTURE('F2_SERIE') OF oDlg PIXEL
//	@ 010,120 MSGET oGet02 VAR cNumNota SIZE 100,008 PICTURE X3PICTURE('F2_DOC') OF oDlg PIXEL
//			
//	DEFINE SBUTTON FROM 70, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:='1') ENABLE OF oDlg
//	DEFINE SBUTTON FROM 70, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:='2') ENABLE OF oDlg
//	
//	ACTIVATE MSDIALOG oDlg CENTERED	
//
//	if nOpca == '1'
//		
//		begin transaction
//			dbSelectArea('SF3')
//			SF3->(dbSetOrder(5))
//			SF3->(dbGoTop())
//			SF3->(dbSeek(XFILIAL('SF3')+cNumNota+cSerie))
//			while !eof()
//				if RecLock('SF3',.F.)
//					SF3->(dbDelete())
//					SF3->(msUnlock())
//
//				endif
//				SF3->(dbSkip())
//	
//			enddo
//			SF3->(dbCloseArea())
//	
//			dbSelectArea('SFT')
//			SFT->(dbSetOrder(1))
//			SFT->(dbGoTop())
//			SFT->(dbSeek(XFILIAL('SFT')+'S'+cSerie+cNumNota))
//			while !eof()
//				if RecLock('SFT',.F.)
//					SFT->(dbDelete())
//					SFT->(msUnlock())
//
//				endif
//				SFT->(dbSkip())
//
//			enddo
//			SFT->(dbCloseArea())
//
//			lMsErroAuto	:= .F.
//		
//			if lMsErroAuto
//				MostraErro()
//				DisarmTransaction()
//
//			else
//				if !pEnviaAudit()
//					DisarmTransaction()
//				endif
//			endif
//
//		end transaction
//	
//	else
//		lRet	:= .F.
//	
//	endif

return lRet

static function pEnviaAudit(cSerie, cNumNota)

	local lRet		:= .F.

	//variaveis para composicao do email auditoria
	local cPara		:= alltrim(UsrRetMail('000000')+';'+UsrRetMail(retCodUsr()))
	local cAssunto	:= '[Totvs-Auditoria] Sequencia Liberado para Reutilização '
	local cCorpo	:= ''
	
	cCorpo	:= 'A sequência abaixo foi liberado para ser reutilizado!!!'+chr(13)+chr(10)+chr(13)+chr(10)
	cCorpo	+= 'Serie.....: '+alltrim(cSerie)+chr(13)+chr(10)+chr(13)+chr(10)
	cCorpo	+= 'Num. Nota.: '+alltrim(cNumNota)

	lRet	:= U_EnvMail(	 /*cMailDe			*/ '';
							,/*cMailPara		*/ cPara;
							,/*cMailCopia		*/ '';
							,/*cMailCopiaOculta	*/ '';
							,/*cAssunto			*/ cAssunto;
							,/*cCorpo			*/ cCorpo;
							,/*cAnexo			*/ '';
							,/*_lReturn			*/ .F.)

return lRet

static function AjustaSx1(cPerg)

	u_XPUTSX1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '01'						,											  ;
				/*cPergunt	*/ 'Data Emissão ?'			, /*cPerSpa		*/ 'Fecha de emisión ?'		, /*cPerEng		*/ 'Issue date ?'			, ;
				/*cVar		*/ 'mv_ch1'					, /*cTipo 		*/ 'D'						, 											  ;
				/*nTamanho	*/ tamsx3('F3_EMISSAO')[1]	, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'G'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par01'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/)

	u_XPUTSX1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '02'						,											  ;
				/*cPergunt	*/ 'Serie ?'				, /*cPerSpa		*/ 'Serie ?'				, /*cPerEng		*/ 'Serie by ?'				, ;
				/*cVar		*/ 'mv_ch2'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ tamsx3('F3_SERIE')[1]	, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par02'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/)

	u_XPUTSX1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '03'						, 											  ;
				/*cPergunt	*/ 'Num.Nota ?'				, /*cPerSpa		*/ 'Num.Nota ?'				, /*cPerEng		*/ 'Num.Nota ?'				, ;
				/*cVar		*/ 'mv_ch3'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ tamsx3('F3_NFISCAL')[1]	, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par03'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

	u_XPUTSX1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '04'						, 											  ;
				/*cPergunt	*/ 'Clien/Fornec ?'			, /*cPerSpa		*/ 'Clien/Fornec ?'			, /*cPerEng		*/ 'Clien/Fornec ?'			, ;
				/*cVar		*/ 'mv_ch4'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ tamsx3('F3_CLIEFOR')[1]	, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par04'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

	u_XPUTSX1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '05'						, 											  ;
				/*cPergunt	*/ 'Loja ?'					, /*cPerSpa		*/ 'Loja ?'					, /*cPerEng		*/ 'Loja ?'					, ;
				/*cVar		*/ 'mv_ch5'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ tamsx3('F3_LOJA')[1]		, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par05'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 


return