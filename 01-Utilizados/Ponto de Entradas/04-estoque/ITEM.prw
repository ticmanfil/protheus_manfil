#include 'protheus.ch'
#include 'FWMVCDef.ch'
/*/
===============================================================================================================================
Programa----------: MATA010
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 25/05/2020
===============================================================================================================================
Descrição---------: Este programa serve para acessar o PE da rotina MATA010
===============================================================================================================================
Uso---------------: MATA010
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGAFIN - FINANCEIRO
===============================================================================================================================
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
user function ITEM()
	local	aParam		:= PARAMIXB,;
			xRet		:= .T.,;
			oObj		:= '',;
			cIdPonto	:= '',;
			cIdModel	:= '',;
			lIsGrid		:= .F.,;
			nOpc
						
	if aParam <> nil
		oObj		:= aParam[1]
		cIdPonto	:= aParam[2]
		cIdModel	:= aParam[3]
		lIsGrid		:= (Len(aParam) > 3)
		nOpc		:= oObj:GetOperation() // PEGA A OPERAÇÃO

	/*	if cIdPonto == 'MENUDEF'
			xRet	:= {}
			aadd(xRet,{'Exp.p/Fornec.','U_RD06001' ,0,9})*/
			
		if cIdPonto == 'MODELPOS' 
			//ApMsgInfo('Chamada apos a gravação total do modelo e fora da transação (MODELCOMMITNTTS).' + CRLF + 'ID ' + cIdModel +;
			//			CRLF+Transform(SA1->A1_LC,'@E 999,999.99')+' -> '+Transform(M->A1_LC, '@E 999,999.99'))
	
			if 	M->B1_CUSTO != SB1->B1_CUSTO .or. M->B1_PRV1 != SB1->B1_PRV1
				CadTbPrc(M->B1_COD,M->B1_CUSTO,M->B1_PRV1)
			endif
			
/*		elseif cIdPonto == 'FORMPOS'
			ApMsgInfo('Chamada na validação total do formulário. (FORMPOS)' + CRLF + 'ID ' + cIdModel +;
						CRLF+Transform(M->A1_LC,'@E 999,999.99')+' -> '+Transform(SA1->A1_LC, '@E 999,999.99'))

		elseif cIdPonto == 'FORMLINEPRE'
			ApMsgInfo('Chamada na pré validação da linha do formulário. (FORMLINEPRE)' + CRLF + 'ID ' + cIdModel +;
						CRLF+Transform(M->A1_LC,'@E 999,999.99')+' -> '+Transform(SA1->A1_LC, '@E 999,999.99'))

		elseif cIdPonto == 'FORMLINEPOS'
			ApMsgInfo('Chamada na validação da linha do formulário. (FORMLINEPOS)' + CRLF + 'ID ' + cIdModel +;
						CRLF+Transform(M->A1_LC,'@E 999,999.99')+' -> '+Transform(SA1->A1_LC, '@E 999,999.99'))

		elseif cIdPonto == 'FORMLINEPOS'
			ApMsgInfo('Chamada na validação da linha do formulário. (FORMLINEPOS)' + CRLF + 'ID ' + cIdModel +;
						CRLF+Transform(M->A1_LC,'@E 999,999.99')+' -> '+Transform(SA1->A1_LC, '@E 999,999.99'))
*/
		endif
	endif
return xRet


static function CadTbPrc(cCodigo,nCusto,nPrc) 

//	local	aArea		:= getArea(),;
//			aAreaDA0	:= DA0->(getArea()),;
//			aAreaDA1	:= DA1->(getArea()),;
	local	cCodTab		:= '',;
			dDatVig		:= stod('')

	dbSelectArea('DA0')
	DA0->(dbSetOrder(1))
	DA0->(dbgoTop())
	while !DA0->(eof())
		cCodTab	:= DA0->DA0_CODTAB
		dDatVig	:= DA0->DA0_DATDE

		dbSelectArea('DA1')
		DA1->(dbSetOrder(1))
		DA1->(dbGoTop())
		DA1->(dbSeek(xFilial('DA1')+cCodTab+cCodigo))
		
		if !found()
			if RecLock('DA1',.T.)
				DA1->DA1_FILIAL	:= xFilial('DA1')
				DA1->DA1_CODTAB	:= cCodTab
				DA1->DA1_CODPRO	:= cCodigo
				if cCodTab == '003'
					DA1->DA1_PRCVEN	:= nCusto
				else
					DA1->DA1_PRCVEN	:= nPrc
				endif
				DA1->DA1_DATVIG	:= dDatVig
				DA1->DA1_ATIVO	:= '1'
				DA1->DA1_TPOPER	:= '4'
				DA1->DA1_QTDLOT	:= 999999.99
				DA1->DA1_INDLOT	:= '999999.99'
				DA1->DA1_MOEDA	:= 1
				DA1->(msUnlock())
			endif
		else
			if RecLock('DA1',.F.)
				if cCodTab == '003'
					DA1->DA1_PRCVEN	:= nCusto
				else
					DA1->DA1_PRCVEN	:= nPrc
				endif
				DA1->(msUnlock())
			endif
		endif

		DA0->(dbSkip())
	enddo

/*	resetArea(aAreaDA1)
	resetArea(aAreaDA0)
	resetArea(aArea)
*/
return nil
