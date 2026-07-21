#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'rwmake.ch'

/*/
===============================================================================================================================
Programa----------: RD09001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/01/2019
===============================================================================================================================
Descrição---------: Este programa serve para Liberar sequencia de nota de saida rejeitado pelo SEFAZ
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
user function RD09001()

	local lRet			:= .F.

//	u_msgInforma('MODULO EM DESENVOLVIMENTO','[RD09001] - Liberar sequencia de nota de saida rejeitado pelo SEFAZ')

	local cPerg		:= 'RD09001'
	local cEmissao	:= DDATABASE
	local cSerie	:= space(tamsx3('F2_SERIE')[1])
	local cNumNota	:= space(tamsx3('F2_DOC')[1])
	local cClieFor	:= space(tamsx3('F3_CLIEFOR')[1])
	local cLoja		:= space(tamsx3('F3_LOJA')[1])

	local cQry		:= ''
	
	AjustaSx1(cPerg)
	
	if Pergunte(cPerg,.T.)
		cEmissao	:= mv_par01
		cSerie		:= mv_par02
		cNumNota	:= mv_par03
		cClieFor	:= mv_par04
		cLoja		:= mv_par05

		cQry := 'exec procedure dbo.PR_RD09001 @pFilial	= '+xFilial('SF3');
				+', @pEmissao = '+dtoc(cEmissao);
				+', @pSerie = '+cSerie;
				+', @pNumNota = '+cNumNota;
				+', @pClieFor = '+cClieFor;
				+', @pLoja = '+cLoja

		begin transaction
			
			lRet := u_ExecQry(cQry,.F.)

			if !lRet
				if !pEnviaAudit(cSerie, cNumNota)
					DisarmTransaction()
					lRet	:= .F.
				endif
				DisarmTransaction()
			endif

		end transaction

		if lRet
			u_msgInforma('Sequência '+cSerie+cNumNota+'liberado com sucesso!','[RD09001]')
		endif

	endif

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
