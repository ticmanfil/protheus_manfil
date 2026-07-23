#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'
#include 'totvs.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: RD06008
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 29/08/2019
===============================================================================================================================
Descrição---------: Este programa serve para IMPORTAR os arquivo CONCILIARACAO CARTAO
===============================================================================================================================
Uso---------------: MV06001 - Concilacao dos Cartoes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FINANCEIRO
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

user function RD06008(cPerg)
	
	local	cForm		:= '[D06008] - Import. Arquivos'

	local	nTipo		:= 2,;
			cArq		:= '',;
			cDtIni		:= DDATABASE,;
			cBanco		:= '',;
			cAgencia	:= '',;
			cConta		:= '',;
			cArqAju		:= mv_par05
			
	local	cLinha		:= '',;
			lPrim		:= .T.,;
			aCampos		:= {},;
			aDados		:= {},;
			cIDCONC		:= ''
			
	local	nVlTx		:= 0,;
			nVlAjuste	:= 0,;
			i			:= 0,;
			lOk			:= .T.

	local	dData		:= DDATABASE,;
			nValor		:= nVlTx,;
			cNatur		:= '',;
			cNumDoc		:= '',;
			cBenef		:= '',;
			cHist		:= '',;
			aFINA100 	:= {}

	private	aErro	:= {}

	private lMsErroAuto := .F.

	pAjustaSX1(cPerg)

	if Pergunte(cPerg,.T.)
		nTipo		:= 2
		cArq		:= mv_par01
		cDtIni		:= DDATABASE
		cBanco		:= mv_par02
		cAgencia	:= mv_par03
		cConta		:= mv_par04
		cArqAju		:= mv_par05
		nVlTx		:= mv_par06

		if !file(cArq)
			u_msgErro('Arquivo '+alltrim(cArq)+' não encontrado. Importação será abortada.',cForm)
			return .F.
		endif

		//Lancando a taxa das vendas
		if nVlTx > 0 .and. lOk
			cNatur	:= '0202010403'
			cNumDoc	:= dtos(dData)+'01'
			cBenef	:= 'CARTAO REDE'
			cHist	:= 'TX VENDAS CARTAO'
			nValor	:= nVlTx
		
			aFINA100 := {	{"E5_DATA"		, dData		, Nil},;
							{"E5_MOEDA"		, 'R$'		, Nil},;
							{"E5_VALOR"		, nValor	, Nil},;
							{"E5_NATUREZ"	, cNatur	, Nil},;
							{"E5_BANCO"		, cBanco	, Nil},;
							{"E5_AGENCIA"	, cAgencia	, Nil},;
							{"E5_CONTA"		, cConta	, Nil},;
							{"CDOCTRAN"		, cNumDoc	, Nil},;
							{"E5_BENEF"		, cBenef	, Nil},;
							{"E5_HISTOR"    , cHist		, Nil}}
		
			MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)
		
			if lMsErroAuto
				MostraErro()
				lOk:= .F.
			else
				u_msgInforma('Taxa bancário INCLUIDO com sucesso !!!','')
			endif

		endif

		if file(cArqAju) .and. lOk
			//Lendo arquivo de ajuste
			aCampos:= {}
			aDados	:= {}

			FT_FUSE(cArqAju)
			ProcRegua(FT_FLASTREC())
			FT_FGOTOP()
			while !FT_FEOF()
			
				incproc('Lendo arquivo de ajuste...')
				
				cLinha	:= FT_FREADLN()
				
				if lPrim
					aCampos	:= separa(cLinha,';',.T.)
					lPrim	:= .F.
				else
					aadd(aDados,separa(cLinha,';',.T.))
				endif
			
				FT_FSKIP()
			enddo

			//Validando o arquivo importado
			if ctod(aDados[1][1]) != cDtIni
				u_msgErro('Datas divergentes entre o arquivo com o sistema. Favor acessar o sistema com a mesma data','')
				return .F.
			endif

			procregua(len(aDados))
			
			incproc('Iniciando importação...')
			
			cIDCONC	:= GETSX8NUM('Z15','Z15_IDCONC')
			
			//INSERIR CABECALHO
			for i:= 1 to len(aDados)
				nVlAjuste	+= val(strTran(StrTran(aDados[i][9],".",""),',','.'))
			next i
			
			FT_FUSE()
			
		endif

		//Lendo arquivo principal
		aCampos:= {}
		aDados	:= {}
		lPrim	:= .T.

		FT_FUSE(cArq)
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		while !FT_FEOF()
		
			incproc('Lendo arquivo...')
			
			cLinha	:= FT_FREADLN()
			
			if lPrim
				aCampos	:= separa(cLinha,';',.T.)
				lPrim	:= .F.
			else
				aadd(aDados,separa(cLinha,';',.T.))
			endif
		
			FT_FSKIP()
		enddo
		
		//Validando o arquivo importado
		if ctod(aDados[1][1]) != cDtIni
			u_msgErro('Datas divergentes entre o arquivo com o sistema. Favor acessar o sistema com a mesma data','')
			return .F.
		endif
		
		begin transaction

			procregua(len(aDados))
			
			incproc('Iniciando importação...')
			
			cIDCONC	:= GETSX8NUM('Z15','Z15_IDCONC')
			
			//INSERIR CABECALHO
			if recLock('Z15',.T.)
				Z15->Z15_FILIAL	:= xFilial('Z15')
				Z15->Z15_IDCONC	:= cIDCONC
				Z15->Z15_DATA	:= cDtIni
				Z15->Z15_TP		:= iif(nTipo=1,'V','R')
				Z15->Z15_BANCO	:= cBanco
				Z15->Z15_AGENCI	:= cAgencia
				Z15->Z15_CONTA	:= cConta
				//Z15->Z15_DTINI	:= cDtIni
				Z15->Z15_STATUS	:= '1'	// 1 - A CONCLIAR    
				Z15->Z15_TXOUT	:= nVlAjuste
				confirmSx8()
				Z15->(msUnlock())
			else
				rollbacksx8()
			endif

			if nTipo=2	//É RECEBIMENTO

				incproc('Importando dados...')
				
				//INSERIR NA Z16
				insItem(aDados,cIDCONC)
				
				//conciliando automático
				Concilia(aDados,cIDCONC,cBanco+cAgencia+cConta)

			endif
			
		end transaction
		
		FT_FUSE()
		
		u_msgInforma('Importação de Arquivo CONCLUÍDO com sucesso.',cForm)

	endif

	Z15->(dbGoBottom())

//	local	aArea		:= getArea(),;
//			aAreaZ16	:= Z16->(getArea()),;
//			aAreaSE5	:= SE5->(getArea())

//	restArea(aAreaSE5)
//	restArea(aAreaZ16)
//	restArea(aArea)
		
return

static function insItem(aDados,cIDCONC)

	local	cDTRec		:= DDATABASE,;
			cDTVen		:= DDATABASE,;
			cNSU		:= ''
			
	local	nQtdVen		:= 0,;
			nVlBrut		:= 0,;
			nVlLiq		:= 0,;
			nVlTx		:= 0

	local	i	:=0
			
	for i:= 1 to len(aDados)
		cDTRec	:= ctod(aDados[i][1])
		cDTVen	:= ctod(aDados[i][2])
		if cDTRec < ctod('26/07/2022')
			cNSU	:= upper(noacento(aDados[i][8]))
		elseif cDTRec < ctod('28/04/2023')	
			cNSU	:= upper(noacento(aDados[i][10]))
		else	//apartir do dia 28/04/2023 - inclusao da coluna posicao c (3) data original de vencimento
			cNSU	:= upper(noacento(aDados[i][11]))
		endif

		dbSelectArea('Z16')
		Z16->(dbSetOrder(1))
		Z16->(dbGoTop())
		if Z16->(dbSeek(xFilial('Z16')+cIDCONC+cNSU))
			if recLock('Z16',.F.)
				if cDTRec < ctod('26/07/2022')
					Z16->Z16_VLBRU		+= val(strTran(StrTran(aDados[i][3],".",""),',','.'))
					Z16->Z16_VLMDRD		+= val(strTran(StrTran(aDados[i][6],".",""),',','.'))
					Z16->Z16_VLLIQ		+= val(strTran(StrTran(aDados[i][7],".",""),',','.'))
				
				elseif cDTRec < ctod('28/04/2023')
					Z16->Z16_VLBRU		+= val(strTran(StrTran(aDados[i][3],".",""),',','.'))
					Z16->Z16_VLMDRD		+= val(strTran(StrTran(aDados[i][6],".",""),',','.'))
					Z16->Z16_VLLIQ		+= val(strTran(StrTran(aDados[i][7],".",""),',','.'))
				
				else	//apartir do dia 28/04/2023 - inclusao da coluna posicao c (3) data original de vencimento
					Z16->Z16_VLBRU		+= val(strTran(StrTran(aDados[i][4],".",""),',','.'))
					Z16->Z16_VLMDRD		+= val(strTran(StrTran(aDados[i][7],".",""),',','.'))
					Z16->Z16_VLLIQ		+= val(strTran(StrTran(aDados[i][8],".",""),',','.'))
				endif
				Z16->(msUnlock())
			endif
		
		else
			if recLock('Z16',.T.)
				if cDTRec < ctod('26/07/2022')
					Z16->Z16_FILIAL		:= xFilial('Z16')
					Z16->Z16_DTREC		:= cDTRec
					Z16->Z16_DTVEN		:= cDTVen
					Z16->Z16_VLBRU		:= val(strTran(StrTran(aDados[i][3],".",""),',','.'))
					Z16->Z16_TXMDR		:= val(strTran(StrTran(aDados[i][5],".",""),',','.'))
					Z16->Z16_VLMDRD		:= val(strTran(StrTran(aDados[i][6],".",""),',','.'))
					Z16->Z16_VLLIQ		:= val(strTran(StrTran(aDados[i][7],".",""),',','.'))
					Z16->Z16_NSUCV		:= cNSU
					Z16->Z16_NUMCAR		:= upper(noacento(aDados[i][13]))
					Z16->Z16_MODALI		:= upper(noacento(aDados[i][5]))
					Z16->Z16_BANDEI		:= upper(noacento(aDados[i][18]))
					Z16->Z16_IDCONC		:= cIDCONC
					Z16->Z16_STATUS		:= '1'

				elseif cDTRec < ctod('28/04/2023')
					Z16->Z16_FILIAL		:= xFilial('Z16')
					Z16->Z16_DTREC		:= cDTRec
					Z16->Z16_DTVEN		:= cDTVen
					Z16->Z16_VLBRU		:= val(strTran(StrTran(aDados[i][3],".",""),',','.'))
					Z16->Z16_TXMDR		:= val(strTran(StrTran(aDados[i][5],".",""),',','.'))
					Z16->Z16_VLMDRD		:= val(strTran(StrTran(aDados[i][6],".",""),',','.'))
					Z16->Z16_VLLIQ		:= val(strTran(StrTran(aDados[i][7],".",""),',','.'))
					Z16->Z16_NSUCV		:= cNSU
					Z16->Z16_NUMCAR		:= upper(noacento(aDados[i][15]))
					Z16->Z16_MODALI		:= upper(noacento(aDados[i][5]))
					Z16->Z16_BANDEI		:= upper(noacento(aDados[i][20]))
					Z16->Z16_IDCONC		:= cIDCONC
					Z16->Z16_STATUS		:= '1'

				else	//apartir do dia 28/04/2023
					Z16->Z16_FILIAL		:= xFilial('Z16')
					Z16->Z16_DTREC		:= cDTRec
					Z16->Z16_DTVEN		:= cDTVen
					Z16->Z16_VLBRU		:= val(strTran(StrTran(aDados[i][4],".",""),',','.'))
					Z16->Z16_TXMDR		:= val(strTran(StrTran(aDados[i][6],".",""),',','.'))
					Z16->Z16_VLMDRD		:= val(strTran(StrTran(aDados[i][7],".",""),',','.'))
					Z16->Z16_VLLIQ		:= val(strTran(StrTran(aDados[i][8],".",""),',','.'))
					Z16->Z16_NSUCV		:= cNSU
					Z16->Z16_NUMCAR		:= upper(noacento(aDados[i][16]))
					Z16->Z16_MODALI		:= upper(noacento(aDados[i][6]))
					Z16->Z16_BANDEI		:= upper(noacento(aDados[i][21]))
					Z16->Z16_IDCONC		:= cIDCONC
					Z16->Z16_STATUS		:= '1'
					
				endif
				Z16->(msUnlock())
		
				nQtdVen	+= 1
			endif

		endif

		if cDTRec < ctod('26/07/2022')
			nVlBrut	+= val(strTran(StrTran(aDados[i][3],".",""),',','.'))
			nVlTx	+= val(strTran(StrTran(aDados[i][6],".",""),',','.'))
			nVlLiq	+= val(strTran(StrTran(aDados[i][7],".",""),',','.'))

		elseif cDTRec < ctod('28/04/2023')
			nVlBrut	+= val(strTran(StrTran(aDados[i][3],".",""),',','.'))
			nVlTx	+= val(strTran(StrTran(aDados[i][6],".",""),',','.'))
			nVlLiq	+= val(strTran(StrTran(aDados[i][7],".",""),',','.'))

		else	//apartir do dia 28/04/2023
			nVlBrut	+= val(strTran(StrTran(aDados[i][4],".",""),',','.'))
			nVlTx	+= val(strTran(StrTran(aDados[i][7],".",""),',','.'))
			nVlLiq	+= val(strTran(StrTran(aDados[i][8],".",""),',','.'))

		endif
	next i
	
	Totaliza('I',nQtdVen,nVlBrut,nVlLiq,nVlTx)
	
return

static function Concilia(aDados,cIDCONC,cBanco)

	local	cNSU		as caracter,;
			cDTVen		as date
			
	local	nVlBrutA	as numeric

	local	nVl			as numeric,;
			nVlRede		as numeric

	cNSU		:= ''
	cDTVen		:= DDATABASE
	nVlBrutA	:= 0
	nVl			:= 0
	nVlRede		:= 0

	dbSelectArea('Z16')
	Z16->(dbSetOrder(1))
	Z16->(dbGoTop())
	Z16->(dbSeek(xFilial('Z16')+cIDCONC))
	while !Z16->(eof()) .and. Z16->Z16_IDCONC == cIDCONC
	
		cNSU		:= Z16->Z16_NSUCV
		cDTVen		:= Z16->Z16_DTVEN
		nVlRede		:= Z16->Z16_VLBRU
		nVl			:= 0
		
		dbSelectArea('SE5')
		SE5->(dbSetOrder(10))
		SE5->(dbGoTop())
		SE5->(dbSeek(xFilial('SE5')+cNSU))
		while !SE5->(eof()) ;
			.and. alltrim(SE5->E5_DOCUMEN) == alltrim(cNSU) ;
			.and. SE5->E5_DATA = cDTVen ;
			.and. SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA == cBanco ;
			.and. empty(SE5->E5_XIDCONC);
			.and. SE5->E5_RECONC == 'x'
			
			if recLock('SE5',.F.)
				SE5->E5_XIDCONC	:= cIDCONC
				SE5->E5_XDTCONC	:= DDATABASE
				SE5->(msUnlock())
			endif

			nVl	+= SE5->E5_VALOR
			
			if nVl = nVlRede
				nVlBrutA	+= nVl
				
				if recLock('Z16',.F.)
					Z16->Z16_STATUS	:= '2'
					Z16->(msUnlock())
				endif
				
			else
				if recLock('Z16',.F.)
					Z16->Z16_STATUS	:= '3'
					Z16->(msUnlock())
				endif
				
			endif
			
			SE5->(dbSkip())
		enddo

		Z16->(dbSkip())
	enddo

	Totaliza('P',0,nVlBrutA,0)

return

static function Totaliza(cTp,nQtd,nVlBrt,nVlLiq,nVlTx)
	if cTp == 'I'
		if recLock('Z15',.F.)
			Z15->Z15_QTVEN	:= nQtd
			Z15->Z15_VLBRUT	:= nVlBrt
			Z15->Z15_VLLIQ	:= nVlLiq
			Z15->Z15_VLTX	:= nVlTx
			Z15->(msUnlock())
		endif
	else
		if recLock('Z15',.F.)
			Z15->Z15_QTVENA	:= nQtd
			Z15->Z15_VLBRUA	:= nVlBrt
			Z15->Z15_VLLIQA	:= nVlLiq
			Z15->(msUnlock())
		endif
	endif

	if Z15->Z15_VLBRUT > 0 .and. Z15->Z15_VLBRUT = Z15->Z15_VLBRUA
		if recLock('Z15',.F.)
			Z15->Z15_STATUS	:= '2'
			Z15->(msUnlock())
		endif
	else
		if recLock('Z15',.F.)
			Z15->Z15_STATUS	:= '1'
			Z15->(msUnlock())
		endif
	endif
	
return

static function pAjustaSx1(cPerg)

//	local lRet

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '01'						, 											  ;
				/*cPergunt	*/ 'Aquivo a Importar:'		, /*cPerSpa		*/ 'Aquivo a Importar:'		, /*cPerEng		*/ 'Aquivo a Importar:'		, ;
				/*cVar		*/ 'mv_ch1'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 99						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ 'DIR'					, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par01'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '02'						, 											  ;
				/*cPergunt	*/ 'Banco:'					, /*cPerSpa		*/ 'Banco:'					, /*cPerEng		*/ 'Banco:'					, ;
				/*cVar		*/ 'mv_ch2'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 3						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ 'SA6'					, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par02'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '03'						, 											  ;
				/*cPergunt	*/ 'Agência:'				, /*cPerSpa		*/ 'Agência:'				, /*cPerEng		*/ 'Agência:'				, ;
				/*cVar		*/ 'mv_ch3'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 5						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'G'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par03'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '04'						, 											  ;
				/*cPergunt	*/ 'Conta:'					, /*cPerSpa		*/ 'Conta:'					, /*cPerEng		*/ 'Conta:'					, ;
				/*cVar		*/ 'mv_ch4'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 10						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'G'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par04'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '05'						, 											  ;
				/*cPergunt	*/ 'Aquivo de Ajuste:'		, /*cPerSpa		*/ 'Aquivo a Ajuste:'		, /*cPerEng		*/ 'Aquivo a Ajuste:'		, ;
				/*cVar		*/ 'mv_ch5'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 99						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ 'DIR'					, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par05'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '06'						, 											  ;
				/*cPergunt	*/ 'Tx Venda:'				, /*cPerSpa		*/ 'Tx Venda:'				, /*cPerEng		*/ 'Tx Venda:'		, ;
				/*cVar		*/ 'mv_ch6'					, /*cTipo 		*/ 'N'						, 											  ;
				/*nTamanho	*/ 8						, /*nDecimal	*/ 2						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par06'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

return
