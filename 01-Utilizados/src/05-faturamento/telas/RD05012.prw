#include "protheus.CH"
#include "tbiconn.ch" 
#include 'topconn.ch'

/*/
===============================================================================================================================
Programa----------: RD05012
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 08/05/2024
===============================================================================================================================
Descrição---------: Este programa serve para COPIAR um orcamento
===============================================================================================================================
Uso---------------: No Orcamento (faturamento)
===============================================================================================================================
Parametros--------: pNumOrc -> Num do orcamento a ser copiado
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
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

user function RD05012(pNumOrc)

	local 	aArea     	:= GetArea(),;
			aAreaSCJ	:= SCJ->(GetArea()),;
			aAreaSCK	:= SCK->(GetArea()),;
			aAreaSA1	:= SA1->(GetArea())
			
	local	cNumOrc:= GetSxEnum("SCJ","CJ_NUM"),;
			cTPCli:= '',;
			aCab:= {},;
			aLinha:= {},;
			aItens:= {},;
			nX:= 0

	local lRet:= .T.

	//tela
	private cForm:= '[RD05012] - Copiando Orcamento'
	cTPCli:= iif(SA1->A1_TIPO=='S'.AND.SA1->A1_XDTSOL > DDATABASE,'F',SA1->A1_TIPO)

	dbSelectArea('SCJ')
	SCJ->(dbSetOrder(1))
	SCJ->(dbGoTop())
	if SCJ->(dbSeek(xFilial('SCJ')+pNumOrc))
		aCab:= {}
		dbSelectArea('SA1')
		SA1->(dbSetOrder(1))
		SA1->(dbGoTop())
		SA1->(dbSeek(FWxFilial('SA1')+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA))
		aadd(aCab,{'CJ_NUM', cNumOrc, nil})
		aadd(aCab,{'CJ_EMISSAO', DDATABASE, nil})
		aadd(aCab,{'CJ_CLIENTE', SCJ->CJ_CLIENTE, nil})
		aadd(aCab,{'CJ_LOJA', SCJ->CJ_LOJA, nil})
		aadd(aCab,{'CJ_XNOMCLI', SCJ->CJ_XNOMCLI, nil})
		aadd(aCab,{'CJ_TIPOCLI', cTPCli, nil})
		aadd(aCab,{'CJ_CLIENT', SCJ->CJ_CLIENT, nil})
		aadd(aCab,{'CJ_LOJAENT', SCJ->CJ_LOJAENT, nil})
		aadd(aCab,{'CJ_CONDPAG', SCJ->CJ_CONDPAG, nil})
		aadd(aCab,{'CJ_TABELA', SCJ->CJ_TABELA, nil})
		aadd(aCab,{'CJ_XVEND', SCJ->CJ_XVEND, nil})
		aadd(aCab,{'CJ_XNOMVEN', SCJ->CJ_XNOMVEN, nil})
		aadd(aCab,{'CJ_XOBS', SCJ->CJ_XOBS, nil})
		aadd(aCab,{'CJ_FRETE', SCJ->CJ_FRETE, nil})
		aadd(aCab,{'CJ_SEGURO', SCJ->CJ_SEGURO, nil})
		aadd(aCab,{'CJ_DESPESA', SCJ->CJ_DESPESA, nil})
		aadd(aCab,{'CJ_PARC1', SCJ->CJ_PARC1+SCJ->CJ_PARC2+SCJ->CJ_PARC3+SCJ->CJ_PARC4, nil})
		aadd(aCab,{'CJ_DATA1', SCJ->CJ_DATA1, nil})
		aadd(aCab,{'CJ_TIPLIB', SCJ->CJ_TIPLIB, nil})
		aadd(aCab,{'CJ_TPCARGA', SCJ->CJ_TPCARGA, nil})
		aadd(aCab,{'CJ_XFLDESC', SCJ->CJ_XFLDESC, nil})
		aadd(aCab,{'CJ_TPFRETE', SCJ->CJ_TPFRETE, nil})
		aadd(aCab,{'CJ_INDPRES', SCJ->CJ_INDPRES, nil})
		aadd(aCab,{'CJ_CODA1U', SCJ->CJ_CODA1U, nil})
		aadd(aCab,{'CJ_XCOPY', .T., nil})

		dbSelectArea('SCK')
		SCK->(dbSetOrder(1))
		SCK->(dbGoTop())
		if SCK->(dbSeek(xFilial('SCK')+pNumOrc))
			while !SCK->(eof()).and.(SCK->CK_FILIAL == xfilial('SCK').and.SCK->CK_NUM == SCJ->CJ_NUM)
				//IncProc()
				aLinha	:= {}
				nX	+= 1
				aadd(aLinha,{'CK_NUM',		,cNumOrc, nil})
				aadd(aLinha,{"CK_ITEM"		,StrZero(nX,tamsx3('CK_ITEM')[1]), Nil})
				aadd(aLinha,{"CK_PRODUTO"	,SCK->CK_PRODUTO	,Nil})
				aadd(aLinha,{"CK_QTDVEN "	,SCK->CK_QTDVEN 	,Nil})
				aadd(aLinha,{"CK_TES    "	,SCK->CK_TES    	,Nil})
				aadd(aItens,aLinha)
				SCK->(dbskip())
			enddo

			lMsErroAuto	:= .F.
		
			MsExecAuto({|x, y, z| MATA415(x, y, z)}, aCab, aItens, 3)
			if lMsErroAuto
				RollBackSX8()
				MostraErro()
				lRet:= .F.
				return (lRet)
			else
				ConfirmSX8()

				dbSelectArea('SCJ')
				SCJ->(dbSetOrder(1))
				SCJ->(dbSeek(xfilial('SCJ')+pNumOrc))
				if !SCJ->CJ_STATUS $ 'C|B'
					if U_msgPergunta('Deseja CANCELAR o orçamento anterior?',cForm) = 6 // 6=SIM
						if RecLock('SCJ',.F.)
							SCJ->CJ_STATUS	:= 'C'
							SCJ->CJ_XMOT	:= '999'
							SCJ->CJ_XDTCANC	:= DDATABASE
							SCJ->CJ_XUSRCAN	:= CUSERNAME
							SCJ->(MsUnLock())
						endif
					endif
				endif
				u_msgInforma('Orçamento gerado com sucesso! '+CRLF+cNumOrc,cForm)
			endif
		endif
	endif

	SA1->(restArea(aAreaSA1))
	SCK->(RestArea(aAreaSCK))
	SCJ->(restArea(aAreaSCJ))
	restArea(aArea)

	dbSelectArea('SCJ')
	SCJ->(dbSetOrder(1))
	SCJ->(dbSeek(xfilial('SCJ')+cNumOrc))
	
return lRet
